using System;
using System.Collections.Generic;
using System.Data;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp.Utils
{
    public static class ActionLogger
    {
        private static Dictionary<string, object> RowToDict(DataRow row)
        {
            var dict = new Dictionary<string, object>();
            if (row != null)
            {
                foreach (DataColumn col in row.Table.Columns)
                {
                    object val = row[col];
                    if (val == DBNull.Value)
                    {
                        dict[col.ColumnName] = null;
                    }
                    else if (val is DateTime)
                    {
                        dict[col.ColumnName] = ((DateTime)val).ToString("yyyy-MM-dd HH:mm:ss");
                    }
                    else
                    {
                        dict[col.ColumnName] = val;
                    }
                }
            }
            return dict;
        }

        public static string CaptureEmployeeState(string masterId)
        {
            if (string.IsNullOrEmpty(masterId)) return null;

            try
            {
                string empQuery = "SELECT * FROM Employees WHERE MasterId = :MasterId";
                DataTable dtEmp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), empQuery, new OracleParameter("MasterId", masterId));
                
                if (dtEmp.Rows.Count == 0) return null; // No state to capture
                
                var empDict = RowToDict(dtEmp.Rows[0]);
                
                string engQuery = "SELECT * FROM EmployeeEngagements WHERE EmpID = :MasterId ORDER BY StartDate ASC";
                DataTable dtEng = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), engQuery, new OracleParameter("MasterId", masterId));
                
                var engList = new List<Dictionary<string, object>>();
                foreach (DataRow row in dtEng.Rows)
                {
                    engList.Add(RowToDict(row));
                }
                
                var state = new Dictionary<string, object>
                {
                    { "Employee", empDict },
                    { "Engagements", engList }
                };
                
                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                return serializer.Serialize(state);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error capturing employee state: " + ex.Message);
                return null;
            }
        }

        public static void LogAction(string actionType, string masterId, string description, string preState, string postState)
        {
            try
            {
                string getNextVal = "SELECT SEQ_EmployeeActionLogs.nextval FROM DUAL";
                int nextId = Convert.ToInt32(DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), getNextVal));

                string sql = @"
                    INSERT INTO EmployeeActionLogs (Id, ActionType, EmpMasterId, Description, PreState, PostState, IsUndone) 
                    VALUES (:Id, :ActionType, :EmpMasterId, :Description, :PreState, :PostState, 0)";

                OracleParameter[] p = new OracleParameter[] {
                    new OracleParameter("Id", nextId),
                    new OracleParameter("ActionType", actionType),
                    new OracleParameter("EmpMasterId", masterId),
                    new OracleParameter("Description", description),
                    new OracleParameter("PreState", string.IsNullOrEmpty(preState) ? (object)DBNull.Value : preState),
                    new OracleParameter("PostState", string.IsNullOrEmpty(postState) ? (object)DBNull.Value : postState)
                };

                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), sql, p);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error inserting action log: " + ex.Message);
            }
        }

        public static bool UndoAction(int logId, out string errorMessage)
        {
            errorMessage = "";
            try
            {
                // 1. Fetch action log
                string queryLog = "SELECT * FROM EmployeeActionLogs WHERE Id = :Id";
                DataTable dtLog = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), queryLog, new OracleParameter("Id", logId));
                if (dtLog.Rows.Count == 0)
                {
                    errorMessage = "Log entry not found.";
                    return false;
                }
                
                DataRow logRow = dtLog.Rows[0];
                if (Convert.ToInt32(logRow["IsUndone"]) == 1)
                {
                    errorMessage = "This action is already undone.";
                    return false;
                }
                
                string actionType = logRow["ActionType"].ToString();
                string empMasterId = logRow["EmpMasterId"].ToString();
                
                if (actionType == "BULK_LEAVE" || empMasterId == "ALL" || empMasterId == "BULK")
                {
                    errorMessage = "Bulk leave adjustments cannot be undone automatically.";
                    return false;
                }
                
                string preStateJson = logRow["PreState"] != DBNull.Value ? logRow["PreState"].ToString() : null;
                
                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                
                // 2. Decode PreState
                Dictionary<string, object> preState = null;
                if (!string.IsNullOrEmpty(preStateJson))
                {
                    preState = serializer.Deserialize<Dictionary<string, object>>(preStateJson);
                }
                
                using (OracleConnection conn = new OracleConnection(DBHelper.GetAttendanceDBConnection()))
                {
                    conn.Open();
                    using (OracleTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            if (preState == null || actionType == "ADD")
                            {
                                // Verify that no attendance is linked to the employee
                                string checkAtt = "SELECT COUNT(*) FROM Attendance WHERE EmpID = :EmpID";
                                using (OracleCommand checkCmd = new OracleCommand(checkAtt, conn))
                                {
                                    checkCmd.Transaction = trans;
                                    checkCmd.Parameters.Add(new OracleParameter("EmpID", empMasterId));
                                    int attCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                                    if (attCount > 0)
                                    {
                                        errorMessage = "Cannot undo: attendance records already exist for this employee.";
                                        trans.Rollback();
                                        return false;
                                    }
                                }
                                
                                // Delete overrides, engagements, and employee
                                string delOver = "DELETE FROM CalculationOverrides WHERE EmpID = :EmpID";
                                using (OracleCommand cmd = new OracleCommand(delOver, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("EmpID", empMasterId));
                                    cmd.ExecuteNonQuery();
                                }
                                
                                // Set CurrentEngagementId = null to bypass FK
                                string nullEmp = "UPDATE Employees SET CurrentEngagementId = NULL WHERE MasterId = :EmpID";
                                using (OracleCommand cmd = new OracleCommand(nullEmp, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("EmpID", empMasterId));
                                    cmd.ExecuteNonQuery();
                                }
                                
                                string delEng = "DELETE FROM EmployeeEngagements WHERE EmpID = :EmpID";
                                using (OracleCommand cmd = new OracleCommand(delEng, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("EmpID", empMasterId));
                                    cmd.ExecuteNonQuery();
                                }
                                
                                string delEmp = "DELETE FROM Employees WHERE MasterId = :EmpID";
                                using (OracleCommand cmd = new OracleCommand(delEmp, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("EmpID", empMasterId));
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            else
                            {
                                // Restore employee and engagements state
                                var empData = (Dictionary<string, object>)preState["Employee"];
                                var preEngagements = new List<Dictionary<string, object>>();
                                if (preState.ContainsKey("Engagements") && preState["Engagements"] != null)
                                {
                                    var rawEngs = preState["Engagements"] as System.Collections.IList;
                                    if (rawEngs != null)
                                    {
                                        foreach (var raw in rawEngs)
                                        {
                                            preEngagements.Add((Dictionary<string, object>)raw);
                                        }
                                    }
                                }
                                
                                var preEngIds = new List<int>();
                                foreach (var eng in preEngagements)
                                {
                                    if (eng.ContainsKey("ID") && eng["ID"] != null)
                                    {
                                        preEngIds.Add(Convert.ToInt32(eng["ID"]));
                                    }
                                }
                                
                                // Get current engagements
                                string currentEngsQuery = "SELECT Id FROM EmployeeEngagements WHERE EmpID = :EmpID";
                                var currentEngIds = new List<int>();
                                using (OracleCommand cmd = new OracleCommand(currentEngsQuery, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("EmpID", empMasterId));
                                    using (OracleDataReader r = cmd.ExecuteReader())
                                    {
                                        while (r.Read())
                                        {
                                            currentEngIds.Add(Convert.ToInt32(r["Id"]));
                                        }
                                    }
                                }
                                
                                // Verify that none of the engagements to be deleted have attendance or overrides
                                foreach (int engId in currentEngIds)
                                {
                                    if (!preEngIds.Contains(engId))
                                    {
                                        string checkAtt = "SELECT COUNT(*) FROM Attendance WHERE EngagementId = :EngId";
                                        using (OracleCommand checkCmd = new OracleCommand(checkAtt, conn))
                                        {
                                            checkCmd.Transaction = trans;
                                            checkCmd.Parameters.Add(new OracleParameter("EngId", engId));
                                            int attCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                                            if (attCount > 0)
                                            {
                                                errorMessage = "Cannot undo: attendance records are linked to a newly created engagement.";
                                                trans.Rollback();
                                                return false;
                                            }
                                        }
                                        
                                        string checkOver = "SELECT COUNT(*) FROM CalculationOverrides WHERE EngagementId = :EngId";
                                        using (OracleCommand checkCmd = new OracleCommand(checkOver, conn))
                                        {
                                            checkCmd.Transaction = trans;
                                            checkCmd.Parameters.Add(new OracleParameter("EngId", engId));
                                            int overCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                                            if (overCount > 0)
                                            {
                                                errorMessage = "Cannot undo: wage calculation overrides are linked to a newly created engagement.";
                                                trans.Rollback();
                                                return false;
                                            }
                                        }
                                    }
                                }
                                
                                // Nullify employee engagement link temporarily to prevent FK constraint errors during deletion
                                string nullEmpLink = "UPDATE Employees SET CurrentEngagementId = NULL WHERE MasterId = :EmpID";
                                using (OracleCommand cmd = new OracleCommand(nullEmpLink, conn))
                                {
                                    cmd.Transaction = trans;
                                    cmd.Parameters.Add(new OracleParameter("EmpID", empMasterId));
                                    cmd.ExecuteNonQuery();
                                }
                                
                                // Delete new engagements
                                foreach (int engId in currentEngIds)
                                {
                                    if (!preEngIds.Contains(engId))
                                    {
                                        string delEng = "DELETE FROM EmployeeEngagements WHERE Id = :Id";
                                        using (OracleCommand cmd = new OracleCommand(delEng, conn))
                                        {
                                            cmd.Transaction = trans;
                                            cmd.Parameters.Add(new OracleParameter("Id", engId));
                                            cmd.ExecuteNonQuery();
                                        }
                                    }
                                }
                                
                                // Restore historical engagements
                                foreach (var eng in preEngagements)
                                {
                                    int engId = Convert.ToInt32(eng["ID"]);
                                    string updateEng = @"
                                        UPDATE EmployeeEngagements 
                                        SET ContractPeriodId = :ContractPeriodId, 
                                            TierId = :TierId, 
                                            VendorId = :VendorId, 
                                            Department = :Department, 
                                            StartDate = :StartDate, 
                                            EndDate = :EndDate, 
                                            EndReason = :EndReason, 
                                            IsCarriedOver = :IsCarriedOver, 
                                            PrevEngagementId = :PrevEngagementId, 
                                            EmployeeId = :EmployeeId
                                        WHERE Id = :Id";
                                        
                                    using (OracleCommand cmd = new OracleCommand(updateEng, conn))
                                    {
                                        cmd.Transaction = trans;
                                        cmd.BindByName = true;
                                        cmd.Parameters.Add(new OracleParameter("ContractPeriodId", GetNullableInt(eng["CONTRACTPERIODID"])));
                                        object tierObj = eng.ContainsKey("TIERID") ? eng["TIERID"] : (eng.ContainsKey("CATEGORY") ? eng["CATEGORY"] : DBNull.Value);
                                        cmd.Parameters.Add(new OracleParameter("TierId", GetNullableInt(tierObj)));
                                        cmd.Parameters.Add(new OracleParameter("VendorId", GetNullableInt(eng["VENDORID"])));
                                        cmd.Parameters.Add(new OracleParameter("Department", eng["DEPARTMENT"]));
                                        cmd.Parameters.Add(new OracleParameter("StartDate", GetNullableDate(eng["STARTDATE"])));
                                        cmd.Parameters.Add(new OracleParameter("EndDate", GetNullableDate(eng["ENDDATE"])));
                                        cmd.Parameters.Add(new OracleParameter("EndReason", eng["ENDREASON"]));
                                        cmd.Parameters.Add(new OracleParameter("IsCarriedOver", GetNullableInt(eng["ISCARRIEDOVER"])));
                                        cmd.Parameters.Add(new OracleParameter("PrevEngagementId", GetNullableInt(eng["PREVENGAGEMENTID"])));
                                        cmd.Parameters.Add(new OracleParameter("EmployeeId", eng["EMPLOYEEID"]));
                                        cmd.Parameters.Add(new OracleParameter("Id", engId));
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                
                                 // Restore employee master
                                 string updateEmp = @"
                                     UPDATE Employees 
                                     SET ID = :ID, 
                                         Name = :Name, 
                                         Department = :Department, 
                                         TierId = :TierId, 
                                         OriginalJoinDate = :OriginalJoinDate, 
                                         JoinDate = :JoinDate, 
                                         LeaveBalance = :LeaveBalance, 
                                         Status = :Status, 
                                         ResignDate = :ResignDate, 
                                         ContractEndDate = :ContractEndDate, 
                                         CurrentEngagementId = :CurrentEngagementId,
                                         Phone = :Phone,
                                         Email = :Email,
                                         Aadhar = :Aadhar,
                                         Address = :Address
                                     WHERE MasterId = :MasterId";
                                     
                                 using (OracleCommand cmd = new OracleCommand(updateEmp, conn))
                                 {
                                     cmd.Transaction = trans;
                                     cmd.BindByName = true;
                                     cmd.Parameters.Add(new OracleParameter("ID", empData["ID"]));
                                     cmd.Parameters.Add(new OracleParameter("Name", empData["NAME"]));
                                     cmd.Parameters.Add(new OracleParameter("Department", empData["DEPARTMENT"]));
                                     object empTierObj = empData.ContainsKey("TIERID") ? empData["TIERID"] : (empData.ContainsKey("CATEGORY") ? empData["CATEGORY"] : DBNull.Value);
                                     cmd.Parameters.Add(new OracleParameter("TierId", GetNullableInt(empTierObj)));
                                     cmd.Parameters.Add(new OracleParameter("OriginalJoinDate", GetNullableDate(empData["ORIGINALJOINDATE"])));
                                     cmd.Parameters.Add(new OracleParameter("JoinDate", GetNullableDate(empData["JOINDATE"])));
                                     cmd.Parameters.Add(new OracleParameter("LeaveBalance", GetNullableFloat(empData["LEAVEBALANCE"])));
                                     cmd.Parameters.Add(new OracleParameter("Status", empData["STATUS"]));
                                     cmd.Parameters.Add(new OracleParameter("ResignDate", GetNullableDate(empData["RESIGNDATE"])));
                                     cmd.Parameters.Add(new OracleParameter("ContractEndDate", GetNullableDate(empData["CONTRACTENDDATE"])));
                                     cmd.Parameters.Add(new OracleParameter("CurrentEngagementId", GetNullableInt(empData["CURRENTENGAGEMENTID"])));
                                     cmd.Parameters.Add(new OracleParameter("Phone", empData.ContainsKey("PHONE") ? empData["PHONE"] : DBNull.Value));
                                     cmd.Parameters.Add(new OracleParameter("Email", empData.ContainsKey("EMAIL") ? empData["EMAIL"] : DBNull.Value));
                                     cmd.Parameters.Add(new OracleParameter("Aadhar", empData.ContainsKey("AADHAR") ? empData["AADHAR"] : DBNull.Value));
                                     cmd.Parameters.Add(new OracleParameter("Address", empData.ContainsKey("ADDRESS") ? empData["ADDRESS"] : DBNull.Value));
                                     cmd.Parameters.Add(new OracleParameter("MasterId", empMasterId));
                                     cmd.ExecuteNonQuery();
                                 }
                            }
                            
                            // 7. Mark log as undone
                            string markUndone = "UPDATE EmployeeActionLogs SET IsUndone = 1 WHERE Id = :Id";
                            using (OracleCommand cmd = new OracleCommand(markUndone, conn))
                            {
                                cmd.Transaction = trans;
                                cmd.Parameters.Add(new OracleParameter("Id", logId));
                                cmd.ExecuteNonQuery();
                            }
                            
                            trans.Commit();
                            return true;
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            errorMessage = "Database error: " + ex.Message;
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = "System error: " + ex.Message;
                return false;
            }
        }

        private static int? GetNullableInt(object val)
        {
            if (val == null || string.IsNullOrEmpty(val.ToString())) return null;
            return Convert.ToInt32(val);
        }

        private static float? GetNullableFloat(object val)
        {
            if (val == null || string.IsNullOrEmpty(val.ToString())) return null;
            return Convert.ToSingle(val);
        }

        private static DateTime? GetNullableDate(object val)
        {
            if (val == null || string.IsNullOrEmpty(val.ToString())) return null;
            DateTime dt;
            if (DateTime.TryParse(val.ToString(), out dt))
            {
                return dt;
            }
            return null;
        }
    }
}
