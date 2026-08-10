using System;
using System.IO;
using System.Data;
using Oracle.ManagedDataAccess.Client;

namespace AttendanceApp
{
    class DbSetup
    {
        static void Main(string[] args)
        {
            string connectionString = "User Id=system;Password=root;Data Source=//127.0.0.1:1521/xe;";
            
            if (!File.Exists("oracle_setup.sql"))
            {
                Console.WriteLine("Error: oracle_setup.sql file not found.");
                return;
            }

            string sqlScript = File.ReadAllText("oracle_setup.sql");
            
            System.Collections.Generic.List<string> commands = new System.Collections.Generic.List<string>();
            System.Text.StringBuilder currentCommand = new System.Text.StringBuilder();
            bool inTrigger = false;

            using (StringReader reader = new StringReader(sqlScript))
            {
                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    string trimmedLine = line.Trim();
                    if (string.IsNullOrEmpty(trimmedLine)) continue;
                    if (trimmedLine.StartsWith("--")) continue; // Skip comments

                    // If a slash is on a line by itself, it terminates the current statement
                    if (trimmedLine == "/")
                    {
                        string cmdText = currentCommand.ToString().Trim();
                        if (cmdText.EndsWith("/")) cmdText = cmdText.Substring(0, cmdText.Length - 1).Trim();
                        if (!string.IsNullOrEmpty(cmdText))
                        {
                            commands.Add(cmdText);
                        }
                        currentCommand.Clear();
                        inTrigger = false;
                        continue;
                    }

                    if (trimmedLine.StartsWith("CREATE OR REPLACE TRIGGER", StringComparison.OrdinalIgnoreCase) ||
                        trimmedLine.StartsWith("CREATE TRIGGER", StringComparison.OrdinalIgnoreCase))
                    {
                        inTrigger = true;
                    }

                    currentCommand.AppendLine(line);

                    if (inTrigger)
                    {
                        // PL/SQL trigger ends with END;
                        if (trimmedLine.Equals("END;", StringComparison.OrdinalIgnoreCase))
                        {
                            inTrigger = false;
                            string cmdText = currentCommand.ToString().Trim();
                            if (!string.IsNullOrEmpty(cmdText))
                            {
                                commands.Add(cmdText);
                            }
                            currentCommand.Clear();
                        }
                    }
                    else
                    {
                        // Standard SQL statement ends with semicolon
                        if (trimmedLine.EndsWith(";"))
                        {
                            string cmdText = currentCommand.ToString().Trim();
                            if (cmdText.EndsWith(";")) cmdText = cmdText.Substring(0, cmdText.Length - 1).Trim();
                            if (!string.IsNullOrEmpty(cmdText))
                            {
                                commands.Add(cmdText);
                            }
                            currentCommand.Clear();
                        }
                    }
                }
            }
            if (currentCommand.Length > 0)
            {
                string cmdText = currentCommand.ToString().Trim();
                if (cmdText.EndsWith(";")) cmdText = cmdText.Substring(0, cmdText.Length - 1).Trim();
                if (!string.IsNullOrEmpty(cmdText))
                {
                    commands.Add(cmdText);
                }
            }

            using (OracleConnection conn = new OracleConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    Console.WriteLine("Connected to Oracle Database. Executing setup script...");
                    
                    int successCount = 0;
                    foreach (string cmdText in commands)
                    {
                        if (string.IsNullOrEmpty(cmdText)) continue;

                        try
                        {
                            using (OracleCommand cmd = new OracleCommand(cmdText, conn))
                            {
                                cmd.ExecuteNonQuery();
                                successCount++;
                            }
                        }
                        catch (OracleException ex)
                        {
                            // ORA-01920: user name conflicts with another user or role name (user exists)
                            // ORA-00955: name is already used by an existing object (table exists)
                            // ORA-00942: table or view does not exist (expected on first run drop statements)
                            // ORA-02289: sequence does not exist (expected on first run sequence drop statements)
                            // ORA-02248: invalid option for ALTER SESSION (expected on Oracle 11g where CDB does not exist)
                            // ORA-65096: invalid common user or role name (expected if CDB user creation fails)
                            if (ex.Number == 1920 || ex.Number == 955 || ex.Number == 942 || ex.Number == 2289 || ex.Number == 2248 || ex.Number == 65096)
                            {
                                // Ignore these as they are expected on subsequent/first runs
                                continue;
                            }
                            else
                            {
                                Console.WriteLine("Warning on query: " + cmdText);
                                Console.WriteLine("Error: " + ex.Message);
                            }
                        }
                    }
                    Console.WriteLine("Oracle Database setup executed. Success statements: " + successCount);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Connection Error: " + ex.Message);
                }
            }
        }
    }
}
