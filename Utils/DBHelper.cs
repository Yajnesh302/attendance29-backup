using System;
using System.Configuration;
using System.Data;
using System.Collections.Generic;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp.Utils
{
    public static class DBHelper
    {
        public static string GetCompanyDBConnection()
        {
            return ConfigurationManager.ConnectionStrings["CompanyDB"].ConnectionString;
        }

        public static string GetAttendanceDBConnection()
        {
            return ConfigurationManager.ConnectionStrings["AttendanceDB"].ConnectionString;
        }

        [ThreadStatic]
        private static bool _inAutoClose;
        private static DateTime _lastAutoCloseCheck = DateTime.MinValue;
        private static readonly object _syncLock = new object();

        public static void AutoCloseExpiredContracts()
        {
            if (_inAutoClose) return;

            // Throttle checks to run at most once every 5 seconds per app domain
            if ((DateTime.UtcNow - _lastAutoCloseCheck).TotalSeconds < 5) return;

            lock (_syncLock)
            {
                if ((DateTime.UtcNow - _lastAutoCloseCheck).TotalSeconds < 5) return;
                _lastAutoCloseCheck = DateTime.UtcNow;
            }

            _inAutoClose = true;
            try
            {
                string connStr = GetAttendanceDBConnection();
                using (OracleConnection conn = new OracleConnection(connStr))
                {
                    conn.Open();

                    // Find all active contract periods whose EndDate has passed
                    List<Tuple<int, DateTime>> expiredPeriods = new List<Tuple<int, DateTime>>();
                    string selectExpiredSql = "SELECT Id, EndDate FROM ContractPeriods WHERE Status = 'Active' AND EndDate < TRUNC(SYSDATE)";
                    using (OracleCommand cmd = new OracleCommand(selectExpiredSql, conn))
                    {
                        using (OracleDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                int id = Convert.ToInt32(reader["Id"]);
                                DateTime endDate = Convert.ToDateTime(reader["EndDate"]);
                                expiredPeriods.Add(Tuple.Create(id, endDate));
                            }
                        }
                    }

                    if (expiredPeriods.Count > 0)
                    {
                        foreach (var period in expiredPeriods)
                        {
                            int periodId = period.Item1;
                            DateTime endDate = period.Item2;

                            using (OracleTransaction trans = conn.BeginTransaction())
                            {
                                try
                                {
                                    // a. Close ContractPeriod
                                    string closeCPSql = "UPDATE ContractPeriods SET Status = 'Closed' WHERE Id = :Id";
                                    using (OracleCommand cmd = new OracleCommand(closeCPSql, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("Id", periodId));
                                        cmd.ExecuteNonQuery();
                                    }

                                    // b. Find active employee engagements under this period
                                    List<Tuple<int, string>> activeEngs = new List<Tuple<int, string>>();
                                    string activeEngsSql = "SELECT Id, EmpID FROM EmployeeEngagements WHERE ContractPeriodId = :PeriodId AND EndDate IS NULL";
                                    using (OracleCommand cmd = new OracleCommand(activeEngsSql, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.Parameters.Add(new OracleParameter("PeriodId", periodId));
                                        using (OracleDataReader reader = cmd.ExecuteReader())
                                        {
                                            while (reader.Read())
                                            {
                                                int engId = Convert.ToInt32(reader["Id"]);
                                                string empId = reader["EmpID"].ToString();
                                                activeEngs.Add(Tuple.Create(engId, empId));
                                            }
                                        }
                                    }

                                    foreach (var eng in activeEngs)
                                    {
                                        int engId = eng.Item1;
                                        string empId = eng.Item2;

                                        // Close engagement
                                        string closeEngSql = "UPDATE EmployeeEngagements SET EndDate = :EndDate, EndReason = 'ContractEnd' WHERE Id = :Id";
                                        using (OracleCommand cmd = new OracleCommand(closeEngSql, conn))
                                        {
                                            cmd.Transaction = trans;
                                            cmd.Parameters.Add(new OracleParameter("EndDate", endDate));
                                            cmd.Parameters.Add(new OracleParameter("Id", engId));
                                            cmd.ExecuteNonQuery();
                                        }

                                        // Update Employee Master
                                        string updateEmpSql = "UPDATE Employees SET CurrentEngagementId = NULL, ContractEndDate = :ContractEndDate, Status = 'ContractEnded' WHERE MasterId = :MasterId AND CurrentEngagementId = :Id";
                                        using (OracleCommand cmd = new OracleCommand(updateEmpSql, conn))
                                        {
                                            cmd.Transaction = trans;
                                            cmd.Parameters.Add(new OracleParameter("ContractEndDate", endDate));
                                            cmd.Parameters.Add(new OracleParameter("MasterId", empId));
                                            cmd.Parameters.Add(new OracleParameter("Id", engId));
                                            cmd.ExecuteNonQuery();
                                        }
                                    }

                                    trans.Commit();
                                }
                                catch (Exception ex)
                                {
                                    trans.Rollback();
                                    System.Diagnostics.Debug.WriteLine("Error auto-closing contract period: " + ex.Message);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in AutoCloseExpiredContracts: " + ex.Message);
            }
            finally
            {
                _inAutoClose = false;
            }
        }

        private static T RunWithRetry<T>(Func<T> operation, int maxRetries = 3, int delayMs = 500)
        {
            int attempts = 0;
            while (true)
            {
                try
                {
                    attempts++;
                    return operation();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(string.Format("Database operation failed. Attempt {0} of {1}. Error: {2}", attempts, maxRetries, ex.Message));
                    if (attempts >= maxRetries)
                    {
                        throw;
                    }
                    // Wait before retrying (exponential backoff)
                    System.Threading.Thread.Sleep(delayMs * attempts);
                }
            }
        }

        private static OracleParameter[] CloneParameters(OracleParameter[] parameters)
        {
            if (parameters == null) return null;
            OracleParameter[] cloned = new OracleParameter[parameters.Length];
            for (int i = 0; i < parameters.Length; i++)
            {
                cloned[i] = new OracleParameter(parameters[i].ParameterName, parameters[i].Value)
                {
                    DbType = parameters[i].DbType,
                    Direction = parameters[i].Direction,
                    IsNullable = parameters[i].IsNullable,
                    Size = parameters[i].Size,
                    SourceColumn = parameters[i].SourceColumn,
                    SourceVersion = parameters[i].SourceVersion
                };
            }
            return cloned;
        }

        public static DataTable ExecuteQuery(string connectionString, string query, params OracleParameter[] parameters)
        {
            if (connectionString == GetAttendanceDBConnection())
            {
                EnsureSchema();
                AutoCloseExpiredContracts();
            }
            return RunWithRetry(() =>
            {
                DataTable dt = new DataTable();
                using (OracleConnection conn = new OracleConnection(connectionString))
                {
                    using (OracleCommand cmd = new OracleCommand(query, conn))
                    {
                        cmd.BindByName = true;
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(CloneParameters(parameters));
                        }
                        using (OracleDataAdapter sda = new OracleDataAdapter(cmd))
                        {
                            sda.Fill(dt);
                        }
                    }
                }
                return dt;
            });
        }

        public static int ExecuteNonQuery(string connectionString, string query, params OracleParameter[] parameters)
        {
            if (connectionString == GetAttendanceDBConnection())
            {
                EnsureSchema();
                AutoCloseExpiredContracts();
            }
            return RunWithRetry(() =>
            {
                int rowsAffected = 0;
                using (OracleConnection conn = new OracleConnection(connectionString))
                {
                    using (OracleCommand cmd = new OracleCommand(query, conn))
                    {
                        cmd.BindByName = true;
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(CloneParameters(parameters));
                        }
                        conn.Open();
                        rowsAffected = cmd.ExecuteNonQuery();
                    }
                }
                return rowsAffected;
            });
        }

        public static object ExecuteScalar(string connectionString, string query, params OracleParameter[] parameters)
        {
            if (connectionString == GetAttendanceDBConnection())
            {
                EnsureSchema();
                AutoCloseExpiredContracts();
            }
            return RunWithRetry(() =>
            {
                object result = null;
                using (OracleConnection conn = new OracleConnection(connectionString))
                {
                    using (OracleCommand cmd = new OracleCommand(query, conn))
                    {
                        cmd.BindByName = true;
                        if (parameters != null)
                        {
                            cmd.Parameters.AddRange(CloneParameters(parameters));
                        }
                        conn.Open();
                        result = cmd.ExecuteScalar();
                    }
                }
                return result;
            });
        }
        public static DataTable GetVisibleTiersDataTable(string pcno, int role)
        {
            string sql;
            OracleParameter[] parameters;

            if (role == 4) // Super Admin: All Tiers
            {
                sql = @"
                    SELECT t.Id AS TierId, 
                           mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') AS DisplayName
                    FROM Tiers t
                    JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                    ORDER BY mc.Name ASC, t.SortOrder ASC, t.TierName ASC";
                parameters = new OracleParameter[0];
            }
            else if (role == 1) // Admin: Scoped by RoleMode
            {
                string roleMode = System.Web.HttpContext.Current != null && System.Web.HttpContext.Current.Session != null 
                                  ? (System.Web.HttpContext.Current.Session["RoleMode"]?.ToString() ?? "") 
                                  : "";

                if (roleMode == "PrimaryAdmin")
                {
                    sql = @"
                        SELECT t.Id AS TierId, 
                               mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') AS DisplayName
                        FROM Tiers t
                        JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                        WHERE mc.AdminPCNO = :PCNO
                        ORDER BY mc.Name ASC, t.SortOrder ASC, t.TierName ASC";
                }
                else if (roleMode == "SecondaryAdmin")
                {
                    sql = @"
                        SELECT t.Id AS TierId, 
                               mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') AS DisplayName
                        FROM Tiers t
                        JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                        WHERE mc.Id IN (
                               SELECT sg.MainCategoryId 
                               FROM CategoryShareGrant sg 
                               WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL
                           )
                           OR t.Id IN (
                               SELECT sg.TierId 
                               FROM CategoryShareGrant sg 
                               WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL
                           )
                        ORDER BY mc.Name ASC, t.SortOrder ASC, t.TierName ASC";
                }
                else
                {
                    sql = @"
                        SELECT t.Id AS TierId, 
                               mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') AS DisplayName
                        FROM Tiers t
                        JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                        WHERE mc.AdminPCNO = :PCNO
                           OR mc.Id IN (
                               SELECT sg.MainCategoryId 
                               FROM CategoryShareGrant sg 
                               WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NULL
                           )
                           OR t.Id IN (
                               SELECT sg.TierId 
                               FROM CategoryShareGrant sg 
                               WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1 AND sg.TierId IS NOT NULL
                           )
                        ORDER BY mc.Name ASC, t.SortOrder ASC, t.TierName ASC";
                }

                parameters = new OracleParameter[] {
                    new OracleParameter("PCNO", pcno)
                };
            }
            else // Regular User: Explicitly assigned Tiers
            {
                sql = @"
                    SELECT t.Id AS TierId, 
                           mc.Name || ' › ' || t.TierName || NVL2(t.RoleLabel, ' (#' || t.RoleLabel || ')', '') AS DisplayName
                    FROM Tiers t
                    JOIN MainCategory mc ON t.MainCategoryId = mc.Id
                    JOIN UserTiers ut ON t.Id = ut.TierId
                    WHERE ut.PCNO = :PCNO
                    ORDER BY mc.Name ASC, t.SortOrder ASC, t.TierName ASC";
                parameters = new OracleParameter[] {
                    new OracleParameter("PCNO", pcno)
                };
            }

            return ExecuteQuery(GetAttendanceDBConnection(), sql, parameters);
        }

        public static List<int> GetVisibleTierIds(string pcno, int role)
        {
            List<int> list = new List<int>();
            DataTable dt = GetVisibleTiersDataTable(pcno, role);
            foreach (DataRow row in dt.Rows)
            {
                list.Add(Convert.ToInt32(row["TierId"]));
            }
            return list;
        }

        public static DataTable GetCompanyDivisionsDataTable()
        {
            // First try to get divisions from the Company HR database (live source)
            try
            {
                string sql = "SELECT DISTINCT DIVNAME AS Name FROM hrdata.empdetails WHERE DIVNAME IS NOT NULL AND DIVNAME != '*' ORDER BY DIVNAME ASC";
                DataTable dtCompany = ExecuteQuery(GetCompanyDBConnection(), sql);
                if (dtCompany != null && dtCompany.Rows.Count > 0)
                    return dtCompany;
            }
            catch
            {
                // CompanyDB unavailable — fall through to local Divisions table
            }

            // Fallback: read from the local AttendanceDB Divisions table
            try
            {
                EnsureDivisionsTableExists();
                string sql = "SELECT Name FROM Divisions ORDER BY Name ASC";
                DataTable dtLocal = ExecuteQuery(GetAttendanceDBConnection(), sql);
                if (dtLocal != null)
                    return dtLocal;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error fetching local divisions: " + ex.Message);
            }

            DataTable empty = new DataTable();
            empty.Columns.Add("Name", typeof(string));
            return empty;
        }

        /// <summary>
        /// Ensures the Divisions table exists in the AttendanceDB.
        /// Creates it automatically if it is missing (e.g. oracle_setup.sql was not fully run).
        /// </summary>
        public static void EnsureDivisionsTableExists()
        {
            try
            {
                // Quick existence check
                ExecuteScalar(GetAttendanceDBConnection(), "SELECT COUNT(*) FROM Divisions WHERE ROWNUM = 1");
            }
            catch
            {
                // Table does not exist — create it now
                try
                {
                    string createTable = @"
                        CREATE TABLE Divisions (
                            Id   NUMBER        PRIMARY KEY,
                            Name VARCHAR2(100) NOT NULL UNIQUE
                        )";
                    ExecuteNonQuery(GetAttendanceDBConnection(), createTable);
                }
                catch { }
            }

            try
            {
                string createSeq = "CREATE SEQUENCE SEQ_Divisions START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE";
                ExecuteNonQuery(GetAttendanceDBConnection(), createSeq);
            }
            catch { }

            try
            {
                string createTrigger = @"
                    CREATE OR REPLACE TRIGGER TRG_Divisions
                    BEFORE INSERT ON Divisions
                    FOR EACH ROW
                    BEGIN
                        IF :NEW.Id IS NULL THEN
                            SELECT SEQ_Divisions.NEXTVAL INTO :NEW.Id FROM DUAL;
                        END IF;
                    END;";
                ExecuteNonQuery(GetAttendanceDBConnection(), createTrigger);
            }
            catch { }
        }

        /// <summary>
        /// Ensures a division name exists in the local Divisions table.
        /// Silently skips if the Divisions table cannot be reached.
        /// </summary>
        public static void EnsureDivisionExists(string dept)
        {
            if (string.IsNullOrWhiteSpace(dept)) return;
            try
            {
                EnsureDivisionsTableExists();
                string cleanDept = dept.Trim();
                string sqlCheck = "SELECT COUNT(*) FROM Divisions WHERE UPPER(Name) = UPPER(:Name)";
                int count = Convert.ToInt32(ExecuteScalar(GetAttendanceDBConnection(), sqlCheck, new OracleParameter("Name", cleanDept)));
                if (count == 0)
                {
                    string sqlInsert = "INSERT INTO Divisions (Name) VALUES (:Name)";
                    ExecuteNonQuery(GetAttendanceDBConnection(), sqlInsert, new OracleParameter("Name", cleanDept));
                }
            }
            catch (Exception ex)
            {
                // Non-fatal - log and continue. Employee save should not be blocked by this.
                System.Diagnostics.Debug.WriteLine("Error ensuring division exists: " + ex.Message);
            }
        }

        private static bool _schemaEnsured = false;
        private static readonly object _schemaLock = new object();

        /// <summary>
        /// Automatically checks and adds missing columns to Oracle tables if running on an older database schema.
        /// </summary>
        public static void EnsureSchema()
        {
            if (_schemaEnsured) return;
            lock (_schemaLock)
            {
                if (_schemaEnsured) return;
                try
                {
                    using (OracleConnection conn = new OracleConnection(GetAttendanceDBConnection()))
                    {
                        conn.Open();
                        EnsureColumnExists(conn, "EMPLOYEES", "TIERID", "ALTER TABLE Employees ADD (TierId NUMBER)");
                        EnsureColumnExists(conn, "EMPLOYEES", "EMPLOYEEHISTORYID", "ALTER TABLE Employees ADD (EmployeeHistoryId VARCHAR2(50))");
                        EnsureColumnExists(conn, "EMPLOYEES", "CURRENTENGAGEMENTID", "ALTER TABLE Employees ADD (CurrentEngagementId NUMBER)");
                        EnsureColumnExists(conn, "EMPLOYEEENGAGEMENTS", "TIERID", "ALTER TABLE EmployeeEngagements ADD (TierId NUMBER)");
                        EnsureColumnExists(conn, "CONTRACTPERIODS", "TIERID", "ALTER TABLE ContractPeriods ADD (TierId NUMBER)");
                        EnsureColumnExists(conn, "NOTICES", "NOTICETEXT", "ALTER TABLE Notices ADD (NoticeText NCLOB)");
                        EnsureColumnExists(conn, "NOTICES", "CATEGORY", "ALTER TABLE Notices ADD (Category VARCHAR2(100) DEFAULT 'General')");
                        EnsureColumnExists(conn, "NOTICES", "MAINCATEGORYID", "ALTER TABLE Notices ADD (MainCategoryId NUMBER NULL)");
                        EnsureColumnExists(conn, "ATTENDANCEREMARKS", "MAINCATEGORYID", "ALTER TABLE AttendanceRemarks ADD (MainCategoryId NUMBER NULL)");
                        EnsureColumnExists(conn, "MAINCATEGORY", "EDITMODE", "ALTER TABLE MainCategory ADD (EditMode NUMBER(1) DEFAULT 0 NOT NULL)");
                        EnsureTableExists(conn, "NOTICEREADS", @"
                            CREATE TABLE NoticeReads (
                                NoticeId NUMBER NOT NULL,
                                PCNO VARCHAR2(100) NOT NULL,
                                ReadAt TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
                                CONSTRAINT PK_NoticeReads PRIMARY KEY (NoticeId, PCNO),
                                CONSTRAINT FK_NoticeReads_Notice FOREIGN KEY (NoticeId) REFERENCES Notices(Id) ON DELETE CASCADE
                            )");
                        try {
                            using (OracleCommand nullCmd = new OracleCommand("ALTER TABLE Notices MODIFY (FilePath VARCHAR2(500) NULL)", conn)) {
                                nullCmd.ExecuteNonQuery();
                            }
                        } catch { }
                    }
                    _schemaEnsured = true;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("EnsureSchema error: " + ex.Message);
                }
            }
        }

        private static void EnsureTableExists(OracleConnection conn, string tableName, string createTableSql)
        {
            try
            {
                string checkSql = "SELECT COUNT(*) FROM USER_TABLES WHERE UPPER(TABLE_NAME) = :TName";
                using (OracleCommand cmd = new OracleCommand(checkSql, conn))
                {
                    cmd.Parameters.Add(new OracleParameter("TName", tableName.ToUpper()));
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    if (count == 0)
                    {
                        using (OracleCommand createCmd = new OracleCommand(createTableSql, conn))
                        {
                            createCmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("EnsureTableExists ({0}) error: {1}", tableName, ex.Message));
            }
        }

        private static void EnsureColumnExists(OracleConnection conn, string tableName, string columnName, string alterSql)
        {
            try
            {
                string checkSql = "SELECT COUNT(*) FROM USER_TAB_COLUMNS WHERE UPPER(TABLE_NAME) = :TName AND UPPER(COLUMN_NAME) = :CName";
                using (OracleCommand cmd = new OracleCommand(checkSql, conn))
                {
                    cmd.Parameters.Add(new OracleParameter("TName", tableName.ToUpper()));
                    cmd.Parameters.Add(new OracleParameter("CName", columnName.ToUpper()));
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    if (count == 0)
                    {
                        using (OracleCommand alterCmd = new OracleCommand(alterSql, conn))
                        {
                            alterCmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(string.Format("EnsureColumnExists ({0}.{1}) error: {2}", tableName, columnName, ex.Message));
            }
        }

        public static List<UserRoleOption> GetAvailableUserRoles(string pcno)
        {
            var roles = new List<UserRoleOption>();
            if (string.IsNullOrEmpty(pcno)) return roles;

            try
            {
                // Fetch Base Role in AppUsers
                string queryRole = "SELECT Role FROM AppUsers WHERE PCNO = :PCNO AND ROWNUM <= 1";
                object resRole = ExecuteScalar(GetAttendanceDBConnection(), queryRole, new OracleParameter("PCNO", pcno));
                int baseRole = (resRole != null && resRole != DBNull.Value) ? Convert.ToInt32(resRole) : 0;

                // 1. Super Admin
                if (baseRole == 4)
                {
                    roles.Add(new UserRoleOption
                    {
                        RoleMode = "SuperAdmin",
                        Title = "Super Administrator",
                        Subtitle = "Full system configuration & global access",
                        EffectiveRole = 4,
                        Icon = "fas fa-crown",
                        BadgeColor = "#f59e0b"
                    });
                }

                // 2. Primary Category Admin (Category Owner)
                string queryMC = "SELECT Name FROM MainCategory WHERE AdminPCNO = :PCNO";
                DataTable dtMC = ExecuteQuery(GetAttendanceDBConnection(), queryMC, new OracleParameter("PCNO", pcno));

                if (baseRole == 1 || dtMC.Rows.Count > 0)
                {
                    string subtitleText = "Category Administrator";
                    if (dtMC.Rows.Count > 0)
                    {
                        List<string> mcNames = new List<string>();
                        foreach (DataRow r in dtMC.Rows) mcNames.Add(r["Name"].ToString());
                        subtitleText = "Category Owner (" + string.Join(", ", mcNames) + ")";
                    }

                    roles.Add(new UserRoleOption
                    {
                        RoleMode = "PrimaryAdmin",
                        Title = "Primary Category Admin",
                        Subtitle = subtitleText,
                        EffectiveRole = 1,
                        Icon = "fas fa-user-shield",
                        BadgeColor = "#4f46e5"
                    });
                }

                // 3. Secondary Category Admin (Category Sharing)
                string queryShared = @"
                    SELECT DISTINCT mc.Name 
                    FROM CategoryShareGrant sg 
                    JOIN MainCategory mc ON sg.MainCategoryId = mc.Id 
                    WHERE sg.SharedWithPCNO = :PCNO AND sg.IsActive = 1";
                DataTable dtShared = ExecuteQuery(GetAttendanceDBConnection(), queryShared, new OracleParameter("PCNO", pcno));
                if (dtShared.Rows.Count > 0)
                {
                    List<string> sharedNames = new List<string>();
                    foreach (DataRow r in dtShared.Rows) sharedNames.Add(r["Name"].ToString());

                    roles.Add(new UserRoleOption
                    {
                        RoleMode = "SecondaryAdmin",
                        Title = "Secondary Admin (Shared)",
                        Subtitle = "Shared Categories (" + string.Join(", ", sharedNames) + ")",
                        EffectiveRole = 1,
                        Icon = "fas fa-share-alt",
                        BadgeColor = "#0284c7"
                    });
                }

                // 4. Regular User (POC)
                string queryDivs = "SELECT DivisionName FROM UserDivisions WHERE PCNO = :PCNO";
                DataTable dtDivs = ExecuteQuery(GetAttendanceDBConnection(), queryDivs, new OracleParameter("PCNO", pcno));

                if (baseRole == 0 || dtDivs.Rows.Count > 0)
                {
                    List<string> divNames = new List<string>();
                    foreach (DataRow r in dtDivs.Rows) divNames.Add(r["DivisionName"].ToString());
                    string divText = divNames.Count > 0 ? string.Join(", ", divNames) : "All Divisions";

                    roles.Add(new UserRoleOption
                    {
                        RoleMode = "RegularUser",
                        Title = "Regular User (POC)",
                        Subtitle = "Directorate POC (" + divText + ")",
                        EffectiveRole = 0,
                        Icon = "fas fa-user",
                        BadgeColor = "#64748b"
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error in GetAvailableUserRoles: " + ex.Message);
            }

            return roles;
        }
    }

    [Serializable]
    public class UserRoleOption
    {
        public string RoleMode { get; set; }     // PrimaryAdmin, SecondaryAdmin, RegularUser, SuperAdmin
        public string Title { get; set; }        // e.g. "Primary Category Admin"
        public string Subtitle { get; set; }     // e.g. "Category Owner for Project"
        public int EffectiveRole { get; set; }   // 1, 0, or 4
        public string Icon { get; set; }         // e.g. "fas fa-user-shield"
        public string BadgeColor { get; set; }   // e.g. "#4f46e5"
    }
}
