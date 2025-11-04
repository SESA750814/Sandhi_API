using ClosedXML.Excel;
using CsvHelper;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SE.API.DbContexts;
using SE.API.Entities;
using SE.API.Helpers;
using SE.API.Models;
using SE.API.ResourceParameters;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.OleDb;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace SE.API.Services
{
    public class ExcelImportRepository : IExcelImportRepository, IDisposable
    {
        private readonly SEDBContext _context;

        public ExcelImportRepository(SEDBContext context)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
        }

        #region Save/Add/Update/Remove/Dispose
        public bool Save()
        {
            return (_context.SaveChanges() >= 0);
        }


        public void AddEntity(object model)
        {
            _context.Add(model);
        }

        public void UpdateEntity(object model)
        {
            _context.Update(model);
        }

        public void RemoveEntity(object model)
        {
            _context.Remove(model);
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                // dispose resources when needed
            }
        }
        #endregion

        #region OLD IMPORT NOT USED
        private bool ImportFileOld(string fileName, string tableName, IConfiguration _config, ILogger _logger)
        {
            try
            {
                _logger.LogError(_config["ExcelImport:Folder"] + "/" + fileName);
                string filePath = _config["ExcelImport:Folder"] + "/" + fileName;
                using (SpreadsheetDocument spreadsheetDocument = SpreadsheetDocument.Open(filePath, false))
                {

                    SqlConnection sqlConnection = new SqlConnection(_config["ConnectionStrings:SqlConnectionString"]);
                    try
                    {
                        WorkbookPart workbookPart = spreadsheetDocument.WorkbookPart;
                        WorksheetPart worksheetPart = workbookPart.WorksheetParts.First();
                        string sheetName = workbookPart.Workbook.GetFirstChild<Sheets>().Elements<Sheet>().Select(u => u.Name).First();

                        SheetData sheetData = worksheetPart.Worksheet.Elements<SheetData>().First();
                        IEnumerable<Row> rows = sheetData.Elements<Row>();
                        string text;
                        int rowNum = 0;
                        int cols = 0;
                        string insSql = "Insert into [dbo].[" + tableName + "] (";
                        foreach (Row r in rows)
                        {
                            if (rowNum == 0)
                            {
                                //if (rowNum == 0)
                                //    continue;
                                string tableDDL = "";
                                tableDDL += "IF EXISTS (SELECT * FROM sys.objects WHERE object_id = ";
                                tableDDL += "OBJECT_ID(N'[dbo].[" + tableName + "]') AND type in (N'U'))";
                                //tableDDL += "exec sp_rename 'dbo." + tableName + "','" + tableName + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "' ";
                                tableDDL += " BEGIN DROP TABLE dbo." + tableName + "; END ";
                                //tableDDL += " GO "; 
                                tableDDL += " Create table [" + tableName + "]";
                                tableDDL += "(";
                                int i = 0;
                                cols = r.Elements<Cell>().Count();
                                foreach (Cell c in r.Elements<Cell>())
                                {
                                    text = GetColumnHeading(spreadsheetDocument, worksheetPart, c.CellReference.ToString());

                                    //_logger.LogInformation(text + " ");
                                    text = Regex.Replace(text, @"[^0-9a-zA-Z]+", "_");
                                    text = text.TrimEnd('_');
                                    tableDDL += "[" + text + "] " + "NVarchar(max)";
                                    insSql += "[" + text + "] ";
                                    if (i != r.Elements<Cell>().Count() - 1)
                                    {
                                        tableDDL += ",";
                                        insSql += ",";
                                    }
                                    i++;

                                }
                                tableDDL += ")";
                                insSql += ") Values (";
                                //_logger.LogInformation(tableDDL);
                                sqlConnection.Open();
                                var sqlCmd = sqlConnection.CreateCommand();
                                sqlCmd.CommandText = tableDDL;
                                sqlCmd.ExecuteNonQuery();
                                sqlConnection.Close();
                            }
                            else
                            {
                                string valSql = "";
                                int i = 0;
                                foreach (Cell c in r.Elements<Cell>())
                                {
                                    text = c.CellValue.Text;
                                    valSql += "'" + text + "'";
                                    if (i != r.Elements<Cell>().Count() - 1)
                                    {
                                        valSql += ",";
                                    }
                                    else if (i == r.Elements<Cell>().Count() - 1)
                                    {
                                        break;
                                    }
                                    i++;
                                }
                                valSql += ")";
                                //_logger.LogError(insSql + valSql);
                                if (!sqlConnection.State.Equals(ConnectionState.Open)) { sqlConnection.Open(); }
                                var sqlCmd = sqlConnection.CreateCommand();
                                sqlCmd.CommandText = insSql + valSql;
                                sqlCmd.ExecuteNonQuery();
                            }
                            rowNum++;
                        }
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                    finally
                    {
                        if (sqlConnection.State.Equals(ConnectionState.Open)) { sqlConnection.Close(); }
                    }


                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }


        }

        private static string GetColumnHeading(SpreadsheetDocument document, WorksheetPart worksheetPart, string cellName)
        {
            // Open the document as read-only.
            //using (SpreadsheetDocument document = SpreadsheetDocument.Open(docName, false))
            {
                //IEnumerable<Sheet> sheets = document.WorkbookPart.Workbook.Descendants<Sheet>().Where(s => s.Name == worksheetName);
                //if (sheets.Count() == 0)
                //{
                //    // The specified worksheet does not exist.
                //    return null;
                //}

                //WorksheetPart worksheetPart = (WorksheetPart)document.WorkbookPart.GetPartById(sheets.First().Id);

                // Get the column name for the specified cell.
                string columnName = GetColumnName(cellName);

                // Get the cells in the specified column and order them by row.
                IEnumerable<Cell> cells = worksheetPart.Worksheet.Descendants<Cell>().Where(c => string.Compare(GetColumnName(c.CellReference.Value), columnName, true) == 0)
                    .OrderBy(r => GetRowIndex(r.CellReference));

                if (cells.Count() == 0)
                {
                    // The specified column does not exist.
                    return null;
                }

                // Get the first cell in the column.
                Cell headCell = cells.First();

                // If the content of the first cell is stored as a shared string, get the text of the first cell
                // from the SharedStringTablePart and return it. Otherwise, return the string value of the cell.
                if (headCell.DataType != null && headCell.DataType.Value == CellValues.SharedString)
                {
                    SharedStringTablePart shareStringPart = document.WorkbookPart.GetPartsOfType<SharedStringTablePart>().First();
                    SharedStringItem[] items = shareStringPart.SharedStringTable.Elements<SharedStringItem>().ToArray();
                    return items[int.Parse(headCell.CellValue.Text)].InnerText;
                }
                else
                {
                    return headCell.CellValue.Text;
                }
            }
        }
        // Given a cell name, parses the specified cell to get the column name.
        private static string GetColumnName(string cellName)
        {
            // Create a regular expression to match the column name portion of the cell name.
            Regex regex = new Regex("[A-Za-z]+");
            Match match = regex.Match(cellName);

            return match.Value;
        }

        // Given a cell name, parses the specified cell to get the row index.
        private static uint GetRowIndex(string cellName)
        {
            // Create a regular expression to match the row index portion the cell name.
            Regex regex = new Regex(@"\d+");
            Match match = regex.Match(cellName);

            return uint.Parse(match.Value);
        }

        #endregion OLD IMPORT NOT USED
        public bool ImportFile(string fileName, string tableName, IConfiguration _config, ILogger _logger)
        {
            SqlConnection sqlConnection = new SqlConnection(_config["ConnectionStrings:SqlConnectionString"]);
            string path = Path.Combine(_config["ExcelImport:Folder"], fileName);
            //string path = _config["ExcelImport:Folder"] + "/" + fileName;
            _logger.LogInformation("Path for Excel Import: " + path);
            using (System.IO.Packaging.Package package = System.IO.Packaging.Package.Open(path, System.IO.FileMode.Open, System.IO.FileAccess.Read))
            {
                try
                {
                    var document = DocumentFormat.OpenXml.Packaging.SpreadsheetDocument.Open(package);
                    var workbookPart = document.WorkbookPart;
                    var workbook = workbookPart.Workbook;
                    var sheet = workbookPart.Workbook.Descendants<Sheet>().FirstOrDefault();
                    DocumentFormat.OpenXml.Spreadsheet.Worksheet ws = ((DocumentFormat.OpenXml.Packaging.WorksheetPart)(workbookPart.GetPartById(sheet.Id))).Worksheet;
                    DocumentFormat.OpenXml.Spreadsheet.SheetData sheetData = ws.GetFirstChild<SheetData>();

                    var worksheetPart = (DocumentFormat.OpenXml.Packaging.WorksheetPart)workbookPart.GetPartById(sheet.Id);
                    var sharedStringPart = workbookPart.SharedStringTablePart;
                    var values = sharedStringPart.SharedStringTable.Elements<SharedStringItem>().ToArray();
                    var rows = worksheetPart.Worksheet.Descendants<Row>();
                    string insSql = "Insert into [dbo].[" + tableName + "] (";
                    int rowNum = 0;
                    string text;
                    int colNum = 0;
                    List<string> lstColHeader = new List<string>();

                    // Variables for CSS_List_Payout_Slab_CSS_Manager_Details specific logic
                    bool isCSSPayoutTable = tableName.Equals("CSS_List_Payout_Slab_CSS_Manager_Details", StringComparison.OrdinalIgnoreCase);
                    bool hasBasePayoutPercentage = false;
                    bool hasIncentivePercentage = false;

                    if (rows.Count() > 0)
                    {
                        foreach (Row r in rows)
                        {
                            if (rowNum == 0)
                            {
                                string tableDDL = "";
                                tableDDL += "IF EXISTS (SELECT * FROM sys.objects WHERE object_id = ";
                                tableDDL += "OBJECT_ID(N'[dbo].[" + tableName + "]') AND type in (N'U'))";
                                //tableDDL += "exec sp_rename 'dbo." + tableName + "','" + tableName + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "' ";
                                tableDDL += " BEGIN DROP TABLE dbo." + tableName + "; END ";
                                //tableDDL += " GO ";
                                tableDDL += "Create table [" + tableName + "]";
                                tableDDL += "(";
                                var cells = r.Elements<Cell>();
                                var i = 0;

                                foreach (DocumentFormat.OpenXml.Spreadsheet.Cell cell in cells)
                                {
                                    if (cell.DataType != null && cell.DataType.Value == DocumentFormat.OpenXml.Spreadsheet.CellValues.SharedString)
                                    {
                                        text = values[int.Parse(cell.CellValue.Text)].InnerText;
                                    }
                                    else
                                    {
                                        text = cell.CellValue?.Text ?? "";
                                    }
                                    text = Regex.Replace(text, @"[^0-9a-zA-Z]+", "_");
                                    text = text.TrimEnd('_');

                                    // Check if required columns exist for CSS_List_Payout_Slab_CSS_Manager_Details
                                    if (isCSSPayoutTable)
                                    {
                                        if (text.Equals("base_payout_percentage", StringComparison.OrdinalIgnoreCase))
                                            hasBasePayoutPercentage = true;
                                        if (text.Equals("Incentive_Percentage", StringComparison.OrdinalIgnoreCase))
                                            hasIncentivePercentage = true;
                                    }

                                    tableDDL += "[" + text + "] " + "NVarchar(max)";
                                    insSql += "[" + text + "] ";
                                    if (i != r.Elements<Cell>().Count() - 1)
                                    {
                                        tableDDL += ",";
                                        insSql += ",";
                                    }
                                    lstColHeader.Add(text.ToLower());
                                    i++;
                                }

                                // Add missing columns for CSS_List_Payout_Slab_CSS_Manager_Details if they don't exist
                                if (isCSSPayoutTable)
                                {
                                    if (!hasBasePayoutPercentage)
                                    {
                                        tableDDL += ",[base_payout_percentage] NVarchar(max)";
                                        insSql += ",[base_payout_percentage] ";
                                        lstColHeader.Add("base_payout_percentage");
                                        i++;
                                    }
                                    if (!hasIncentivePercentage)
                                    {
                                        tableDDL += ",[Incentive_Percentage] NVarchar(max)";
                                        insSql += ",[Incentive_Percentage] ";
                                        lstColHeader.Add("incentive_percentage");
                                        i++;
                                    }
                                }

                                colNum = i;
                                tableDDL += ")";
                                insSql += ") Values (";
                                _logger.LogInformation(tableDDL);
                                sqlConnection.Open();
                                var sqlCmd = sqlConnection.CreateCommand();
                                sqlCmd.CommandText = tableDDL;
                                sqlCmd.ExecuteNonQuery();
                                sqlConnection.Close();
                            }
                            else
                            {
                                string valSql = "";
                                int i = 0;
                                bool hasValue = false;
                                text = "";
                                int cols = r.Descendants<Cell>().Count();
                                _logger.LogInformation("Header Columns Number - " + colNum);
                                _logger.LogInformation("Row Columns Number - " + cols);
                                if (cols > colNum)
                                {
                                    cols = colNum;
                                }

                                // Handle existing columns
                                int originalColCount = isCSSPayoutTable ?
                                    (colNum - (hasBasePayoutPercentage ? 0 : 1) - (hasIncentivePercentage ? 0 : 1)) :
                                    colNum;

                                for (int tmpI = 0; tmpI < Math.Min(cols, originalColCount); tmpI++)
                                {
                                    Cell cell = r.Descendants<Cell>().ElementAt(tmpI);
                                    int actualCellIndex = CellReferenceToIndex(cell);
                                    //_logger.LogInformation("Sequential Columns Number - " + i);
                                    //_logger.LogInformation("Actiual Cell Number - " + actualCellIndex);
                                    //_logger.LogInformation("ValSql  - " + valSql);
                                    if (((actualCellIndex != i && i <= 25)
                                        || (i > 25 && actualCellIndex + 26 != i && i <= 51)
                                        || (i > 51 && actualCellIndex != i)
                                        ) && actualCellIndex < originalColCount)
                                    {
                                        var tmpActualIndex = actualCellIndex;
                                        if (i >= 25 && i < 51 && tmpActualIndex < 52)
                                        {
                                            tmpActualIndex = tmpActualIndex + 26;
                                        }

                                        for (var j = i; j < tmpActualIndex; j++)
                                        {
                                            if (i != originalColCount - 1)
                                            {
                                                valSql += "'',";
                                            }
                                            else if (i == originalColCount - 1)
                                            {
                                                valSql += "''";
                                                break;
                                            }
                                            i++;
                                        }
                                    }

                                    text = GetCellValue(document, cell);
                                    if (!string.IsNullOrEmpty(text))
                                    {
                                        hasValue = true;
                                    }
                                    var currentString = lstColHeader[i].Contains("date") || lstColHeader[i].Contains("timestamp") || lstColHeader[i].Contains("completed_on");
                                    if (currentString)
                                    {
                                        double dblVal = -1;
                                        if (double.TryParse(text, out dblVal))
                                        {
                                            text = DateTime.FromOADate(dblVal).ToString();
                                        }
                                    }

                                    valSql += "'" + text.Replace("'", "") + "'";
                                    if (i != originalColCount - 1)
                                    {
                                        valSql += ",";
                                    }
                                    i++;
                                }

                                // Add default values for missing CSS_List_Payout_Slab_CSS_Manager_Details columns
                                if (isCSSPayoutTable)
                                {
                                    if (!hasBasePayoutPercentage)
                                    {
                                        valSql += ",'100'"; // Default value for base_payout_percentage
                                    }
                                    if (!hasIncentivePercentage)
                                    {
                                        valSql += ",'0'"; // Default value for Incentive_Percentage
                                    }
                                }

                                valSql += ")";
                                if (hasValue)
                                {
                                    //_logger.LogInformation("Inserting Row - " + rowNum.ToString() + " ****  " + insSql + valSql);
                                    if (!sqlConnection.State.Equals(ConnectionState.Open)) { sqlConnection.Open(); }
                                    var sqlCmd = sqlConnection.CreateCommand();
                                    sqlCmd.CommandText = insSql + valSql;
                                    sqlCmd.ExecuteNonQuery();
                                }
                            }
                            rowNum++;
                        }
                    }
                    //else
                    //{
                    //package.Close();
                    //}
                    return true;
                }
                catch (Exception ex)
                {
                    _logger.LogError("Error in import -" + ex.InnerException);
                    throw new Exception("Error importing file -" + fileName + "-" + ex.Message, ex.InnerException);

                }
                finally
                {
                    if (sqlConnection.State.Equals(ConnectionState.Open)) { sqlConnection.Close(); }
                    package.Close();
                }
            }


        }
        private static int CellReferenceToIndex(Cell cell)
        {
            int index = 0;
            string reference = cell.CellReference.ToString().ToUpper();
            foreach (char ch in reference)
            {
                if (Char.IsLetter(ch))
                {
                    int value = (int)ch - (int)'A';
                    index = (index == 0) ? value : ((index + 1) * 26) + value;
                }
                else
                {
                    return index;
                }
            }
            return index;
        }
        public static string GetCellValue(SpreadsheetDocument document, Cell cell)
        {
            SharedStringTablePart stringTablePart = document.WorkbookPart.SharedStringTablePart;
            if (cell.CellValue == null)
            {
                return "";
            }
            string value = cell.CellValue.InnerXml;
            if (cell.DataType != null && cell.DataType.Value == CellValues.SharedString)
            {
                return stringTablePart.SharedStringTable.ChildElements[Int32.Parse(value)].InnerText;
            }
            else
            {
                return value;
            }
        }



        public bool RawDumpImportFile(string fileName, string tableName, IConfiguration _config, ILogger _logger)
        {
            SqlConnection sqlConnection = new SqlConnection(_config["ConnectionStrings:SqlConnectionString"]);
            string path = Path.Combine(_config["ExcelImport:Folder"], fileName);
            _logger.LogInformation("Path for Excel Import: " + path);

            using (System.IO.Packaging.Package package = System.IO.Packaging.Package.Open(path, System.IO.FileMode.Open, System.IO.FileAccess.Read))
            {
                try
                {
                    var document = DocumentFormat.OpenXml.Packaging.SpreadsheetDocument.Open(package);
                    var workbookPart = document.WorkbookPart;
                    var sheet = workbookPart.Workbook.Descendants<Sheet>().FirstOrDefault();
                    DocumentFormat.OpenXml.Spreadsheet.Worksheet ws = ((DocumentFormat.OpenXml.Packaging.WorksheetPart)(workbookPart.GetPartById(sheet.Id))).Worksheet;
                    DocumentFormat.OpenXml.Spreadsheet.SheetData sheetData = ws.GetFirstChild<SheetData>();

                    var worksheetPart = (DocumentFormat.OpenXml.Packaging.WorksheetPart)workbookPart.GetPartById(sheet.Id);
                    var sharedStringPart = workbookPart.SharedStringTablePart;
                    var values = sharedStringPart.SharedStringTable.Elements<SharedStringItem>().ToArray();
                    var rows = worksheetPart.Worksheet.Descendants<Row>();
                    string insSql = "Insert into [dbo].[" + tableName + "] (";
                    int rowNum = 0;
                    string text;
                    int colNum = 0;
                    List<string> lstColHeader = new List<string>();
                    System.Diagnostics.Stopwatch.StartNew();

                    // STEP 1: Pre-load CSS zip codes COMPLETELY FIRST
                    Dictionary<string, string> cssZipCodes = new Dictionary<string, string>();
                    _logger.LogInformation("Loading CSS ZIP codes...");
                    LoadCSSZipCodes(sqlConnection, cssZipCodes, _logger);
                    _logger.LogInformation($"CSS ZIP codes loaded: {cssZipCodes.Count}");

                    // STEP 2: Pre-load ALL ZIP coordinates COMPLETELY BEFORE processing rows
                    Dictionary<string, (double lat, double lon)> allZipCoordinates = new Dictionary<string, (double lat, double lon)>();
                    _logger.LogInformation("Loading ALL ZIP coordinates from database...");
                    LoadAllZipCoordinatesOnce(sqlConnection, allZipCoordinates, _logger);
                    _logger.LogInformation($"All ZIP coordinates loaded: {allZipCoordinates.Count}");

                    using (var httpClient = new HttpClient())
                    {
                        httpClient.DefaultRequestHeaders.Add("User-Agent", "Excel Import Service/1.0");

                        if (rows.Count() > 0)
                        {
                            foreach (Row r in rows)
                            {
                                if (rowNum == 0)
                                {
                                    // Build table & insert header SQL, add columns
                                    string tableDDL = "";
                                    tableDDL += "IF EXISTS (SELECT * FROM sys.objects WHERE object_id = ";
                                    tableDDL += "OBJECT_ID(N'[dbo].[" + tableName + "]') AND type in (N'U'))";
                                    tableDDL += " BEGIN DROP TABLE dbo." + tableName + "; END ";
                                    tableDDL += "Create table [" + tableName + "]";
                                    tableDDL += "(";
                                    var cells = r.Elements<Cell>();
                                    var i = 0;
                                    foreach (DocumentFormat.OpenXml.Spreadsheet.Cell cell in cells)
                                    {
                                        if (cell.DataType != null && cell.DataType.Value == DocumentFormat.OpenXml.Spreadsheet.CellValues.SharedString)
                                        {
                                            text = values[int.Parse(cell.CellValue.Text)].InnerText;
                                        }
                                        else
                                        {
                                            text = cell.CellValue?.Text ?? "";
                                        }
                                        text = Regex.Replace(text, @"[^0-9a-zA-Z]+", "_");
                                        text = text.TrimEnd('_');
                                        tableDDL += "[" + text + "] " + "NVarchar(max)";
                                        insSql += "[" + text + "] ";
                                        if (i != r.Elements<Cell>().Count() - 1)
                                        {
                                            tableDDL += ",";
                                            insSql += ",";
                                        }
                                        lstColHeader.Add(text.ToLower());
                                        i++;
                                    }
                                    colNum = i;
                                    tableDDL += ",[Actual_Expense_converted] [int] NULL";
                                    tableDDL += ",[Actual_Expense] [int] NULL";
                                    insSql += ",[Actual_Expense_converted],[Actual_Expense]";
                                    tableDDL += ")";
                                    insSql += ") Values ";
                                    _logger.LogInformation(tableDDL);

                                    sqlConnection.Open();
                                    var sqlCmd = sqlConnection.CreateCommand();
                                    sqlCmd.CommandText = tableDDL;
                                    sqlCmd.ExecuteNonQuery();
                                    sqlConnection.Close();
                                }
                                else
                                {
                                    string valSql = "";
                                    int i = 0;
                                    bool hasValue = false;
                                    text = "";
                                    int cols = r.Descendants<Cell>().Count();
                                    _logger.LogInformation("Header Columns Number - " + colNum);
                                    _logger.LogInformation("Row Columns Number - " + cols);
                                    if (cols > colNum)
                                    {
                                        cols = colNum;
                                    }

                                    string currentZipCode = "";
                                    string currentServiceTeam = "";

                                    for (int tmpI = 0; tmpI < cols; tmpI++)
                                    {
                                        Cell cell = r.Descendants<Cell>().ElementAt(tmpI);
                                        int actualCellIndex = CellReferenceToIndex(cell);
                                        if (((actualCellIndex != i && i <= 25)
                                            || (i > 25 && actualCellIndex + 26 != i && i <= 51)
                                            || (i > 51 && actualCellIndex != i)
                                            ) && actualCellIndex < colNum)
                                        {
                                            var tmpActualIndex = actualCellIndex;
                                            if (i >= 25 && i < 51 && tmpActualIndex < 52)
                                            {
                                                tmpActualIndex = tmpActualIndex + 26;
                                            }
                                            for (var j = i; j < tmpActualIndex; j++)
                                            {
                                                if (i != colNum - 1)
                                                {
                                                    valSql += "'',";
                                                }
                                                else if (i == colNum - 1)
                                                {
                                                    valSql += "''";
                                                    break;
                                                }
                                                i++;
                                            }
                                        }
                                        text = GetCellValue(document, cell);
                                        if (!string.IsNullOrEmpty(text)) { hasValue = true; }

                                        // Improved column detection (case insensitive)
                                        string columnName = lstColHeader[i].ToLower();
                                        if (columnName.Contains("zip"))
                                        {
                                            currentZipCode = text?.Trim() ?? "";
                                            _logger.LogInformation($"Found ZIP code: {currentZipCode} in column: {columnName}");
                                        }
                                        if (columnName.Contains("service") && columnName.Contains("team") || columnName.Contains("serviceteam"))
                                        {
                                            currentServiceTeam = text?.Trim() ?? "";
                                            _logger.LogInformation($"Found Service Team: {currentServiceTeam} in column: {columnName}");
                                        }

                                        // Handle date columns
                                        if (columnName.Contains("date") || columnName.Contains("timestamp") || columnName.Contains("completed"))
                                        {
                                            double dblVal = -1;
                                            if (double.TryParse(text, out dblVal))
                                            {
                                                text = DateTime.FromOADate(dblVal).ToString();
                                            }
                                        }
                                        valSql += "'" + text.Replace("'", "''") + "'";
                                        if (i != colNum - 1) { valSql += ","; }
                                        i++;
                                    }

                                    // NOW Calculate distance using FULLY pre-loaded coordinates
                                    int distanceValue = 0;
                                    try
                                    {
                                        if (!string.IsNullOrEmpty(currentZipCode) && !string.IsNullOrEmpty(currentServiceTeam))
                                        {
                                            string matchingCSSZipCode = FindMatchingCSSZipCode(cssZipCodes, currentServiceTeam);

                                            if (!string.IsNullOrEmpty(matchingCSSZipCode))
                                            {
                                                // Now both ZIP codes should be checked against the FULLY loaded dictionary first
                                                var coordFrom = GetCoordinatesFromPreloadedData(matchingCSSZipCode, allZipCoordinates, httpClient, _logger);
                                                var coordTo = GetCoordinatesFromPreloadedData(currentZipCode, allZipCoordinates, httpClient, _logger);

                                                if (coordFrom.HasValue && coordTo.HasValue)
                                                {
                                                    double calculatedDistance = CalculateHaversineDistance(
                                                        coordFrom.Value.lat, coordFrom.Value.lon,
                                                        coordTo.Value.lat, coordTo.Value.lon
                                                    );
                                                    distanceValue = (int)Math.Round(calculatedDistance);
                                                    _logger.LogInformation($"Distance calculated: {matchingCSSZipCode} to {currentZipCode} = {distanceValue} km");
                                                }
                                            }
                                        }
                                    }
                                    catch (Exception ex)
                                    {
                                        _logger.LogError($"Error calculating distance for row {rowNum}: {ex.Message}");
                                    }

                                    valSql += "," + distanceValue + "," + distanceValue;

                                    // Insert single row directly
                                    if (hasValue)
                                    {
                                        try
                                        {
                                            string fullSql = insSql + "(" + valSql + ")";
                                            bool wasOpen = sqlConnection.State == ConnectionState.Open;
                                            if (!wasOpen) { sqlConnection.Open(); }

                                            using (var sqlCmd = sqlConnection.CreateCommand())
                                            {
                                                sqlCmd.CommandText = fullSql;
                                                sqlCmd.CommandTimeout = 120;
                                                sqlCmd.ExecuteNonQuery();
                                            }

                                            if (!wasOpen) { sqlConnection.Close(); }
                                            _logger.LogInformation("Successfully inserted row");
                                        }
                                        catch (Exception ex)
                                        {
                                            _logger.LogError($"Error in single row insert: {ex.Message}");
                                            if (sqlConnection.State == ConnectionState.Open) { sqlConnection.Close(); }
                                        }
                                    }
                                }
                                rowNum++;
                            }
                        }
                    }

                    return true;
                }
                catch (Exception ex)
                {
                    _logger.LogError("Error in import -" + ex.Message);
                    _logger.LogError("Stack trace: " + ex.StackTrace);
                    if (ex.InnerException != null)
                    {
                        _logger.LogError("Inner exception: " + ex.InnerException.Message);
                    }
                    throw new Exception("Error importing file -" + fileName + "-" + ex.Message, ex.InnerException);
                }
                finally
                {
                    if (sqlConnection.State.Equals(ConnectionState.Open)) { sqlConnection.Close(); }
                    package.Close();
                }
            }
        }

        // Updated method with better logging

        private static readonly Dictionary<string, (double lat, double lon)> _apiCache = new Dictionary<string, (double lat, double lon)>();

        private (double lat, double lon)? GetCoordinatesFromPreloadedData(string zipCode, Dictionary<string, (double lat, double lon)> zipCoordinates, HttpClient httpClient, ILogger _logger)
        {
            if (string.IsNullOrEmpty(zipCode)) return null;

            string cleanZipCode = zipCode.Trim();


            if (zipCoordinates.TryGetValue(cleanZipCode, out var coordinates))
            {
                _logger.LogInformation($"✓ Found ZIP {cleanZipCode} in PRE-LOADED database cache: {coordinates.lat}, {coordinates.lon}");
                return coordinates;
            }


            if (_apiCache.TryGetValue(cleanZipCode, out var cachedCoord))
            {
                _logger.LogInformation($"✓ Found ZIP {cleanZipCode} in API cache.");
                return cachedCoord;
            }

            var apiCoordinates = GetCoordinatesFromAPISync(httpClient, cleanZipCode, _logger);

            if (apiCoordinates.HasValue)
            {
                _apiCache[cleanZipCode] = apiCoordinates.Value;
                _logger.LogInformation($"✓ Got coordinates from API for ZIP {cleanZipCode}: {apiCoordinates.Value.lat}, {apiCoordinates.Value.lon}");

                // Optionally: Save to database for future use
                // SaveCoordinatesToDatabase(cleanZipCode, apiCoordinates.Value, _logger);

                return apiCoordinates;
            }

            _logger.LogError($"✗ Could not get coordinates for ZIP: {cleanZipCode} from either database OR API");
            return null;
        }

        // Load all ZIP coordinates once at the beginning
        private void LoadAllZipCoordinatesOnce(SqlConnection sqlConnection, Dictionary<string, (double lat, double lon)> zipCoordinates, ILogger _logger)
        {
            try
            {
                string selectAllZipsSql = "SELECT ZipCode, Latitude, Longitude FROM [dbo].[ZIP_COORDINATES]";

                bool wasOpen = sqlConnection.State == ConnectionState.Open;
                if (!wasOpen) { sqlConnection.Open(); }

                using (var sqlCmd = sqlConnection.CreateCommand())
                {
                    sqlCmd.CommandText = selectAllZipsSql;
                    sqlCmd.CommandTimeout = 60;

                    using (var reader = sqlCmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string zipCode = reader["ZipCode"]?.ToString()?.Trim();
                            if (!string.IsNullOrEmpty(zipCode))
                            {
                                try
                                {
                                    double lat = Convert.ToDouble(reader["Latitude"]);
                                    double lon = Convert.ToDouble(reader["Longitude"]);
                                    zipCoordinates[zipCode] = (lat, lon);
                                }
                                catch (Exception ex)
                                {
                                    _logger.LogWarning($"Invalid coordinates for ZIP {zipCode}: {ex.Message}");
                                }
                            }
                        }
                    }
                }

                if (!wasOpen) { sqlConnection.Close(); }

                _logger.LogInformation($"Successfully loaded {zipCoordinates.Count} ZIP coordinates");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading ZIP coordinates: {ex.Message}");
                if (sqlConnection.State == ConnectionState.Open) { sqlConnection.Close(); }
                throw;
            }
        }


        private (double lat, double lon)? GetCoordinatesFromAPISync(HttpClient client, string zipCode, ILogger _logger)
        {
            string url = $"https://nominatim.openstreetmap.org/search?postalcode={zipCode}&format=json&limit=1&countrycodes=in";

            try
            {
                _logger.LogInformation($"Calling API for ZIP: {zipCode}");
                Thread.Sleep(1000); // Rate limit delay

                var response = client.GetStringAsync(url).Result;
                var results = JsonSerializer.Deserialize<NominatimResult[]>(response);

                if (results != null && results.Length > 0 &&
                    !string.IsNullOrWhiteSpace(results[0].lat) &&
                    !string.IsNullOrWhiteSpace(results[0].lon))
                {
                    double lat = double.Parse(results[0].lat, CultureInfo.InvariantCulture);
                    double lon = double.Parse(results[0].lon, CultureInfo.InvariantCulture);
                    _logger.LogInformation($"API returned coordinates for {zipCode}: {lat}, {lon}");
                    return (lat, lon);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"API error for ZIP {zipCode}: {ex.Message}");
            }
            return null;
        }

        private string FindMatchingCSSZipCode(Dictionary<string, string> cssZipCodes, string serviceTeam)
        {
            if (string.IsNullOrEmpty(serviceTeam)) return "";

            serviceTeam = serviceTeam.Trim();

            // Try exact match
            if (cssZipCodes.TryGetValue(serviceTeam, out var exactMatch))
                return exactMatch;

            // Try fuzzy match
            var match = cssZipCodes.FirstOrDefault(kvp =>
                kvp.Key.Contains(serviceTeam, StringComparison.OrdinalIgnoreCase) ||
                serviceTeam.Contains(kvp.Key, StringComparison.OrdinalIgnoreCase));

            return match.Value ?? "";
        }

        private void LoadCSSZipCodes(SqlConnection sqlConnection, Dictionary<string, string> cssZipCodes, ILogger _logger)
        {
            try
            {
                string selectCSSQuery = @"SELECT CSS_Name_in_bFS_to_be_referred, Zip_Code 
                                  FROM [dbo].[SE_CSS_MASTER] 
                                  WHERE CSS_Name_in_bFS_to_be_referred IS NOT NULL 
                                  AND CSS_Name_in_bFS_to_be_referred != '' 
                                  AND Zip_Code IS NOT NULL 
                                  AND Zip_Code != ''";

                bool wasOpen = sqlConnection.State == ConnectionState.Open;
                if (!wasOpen) { sqlConnection.Open(); }

                using (var cssCmd = sqlConnection.CreateCommand())
                {
                    cssCmd.CommandText = selectCSSQuery;
                    using (var cssReader = cssCmd.ExecuteReader())
                    {
                        while (cssReader.Read())
                        {
                            string cssName = cssReader["CSS_Name_in_bFS_to_be_referred"]?.ToString()?.Trim() ?? "";
                            string zipCode = cssReader["Zip_Code"]?.ToString()?.Trim() ?? "";

                            if (!string.IsNullOrEmpty(cssName) && !string.IsNullOrEmpty(zipCode))
                            {
                                cssZipCodes[cssName] = zipCode;
                            }
                        }
                    }
                }

                if (!wasOpen) { sqlConnection.Close(); }
                _logger.LogInformation($"Loaded {cssZipCodes.Count} CSS zip codes");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error loading CSS zip codes: {ex.Message}");
                if (sqlConnection.State == ConnectionState.Open) { sqlConnection.Close(); }
            }
        }

        private double CalculateHaversineDistance(double lat1, double lon1, double lat2, double lon2)
        {
            double R = 6371; // Radius of Earth in km
            double dLat = ToRadians(lat2 - lat1);
            double dLon = ToRadians(lon2 - lon1);
            double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                       Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                       Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return R * c;
        }

        private double ToRadians(double deg) => deg * Math.PI / 180;






        public List<T> ExcelOrCSVDatas<T>(string fileName, IConfiguration _config, ILogger _logger) where T : class, new()
        {
            try
            {
                string filePath = _config["ExcelImport:Folder"] + "/" + fileName;
                this.CSVToExcel(ref filePath, fileName);
                //using (CsvReader csvReader = new CsvReader((IParser)new ExcelParser(filePath)))
                //    return csvReader.GetRecords<T>().ToList<T>();


                using var workbook = new XLWorkbook(filePath);
                var worksheet = workbook.Worksheet(1);
                var rows = worksheet.RangeUsed().RowsUsed();

                using var memoryStream = new MemoryStream();
                using var writer = new StreamWriter(memoryStream);
                foreach (var row in rows)
                {
                    var values = row.Cells().Select(c => $"\"{c.GetValue<string>().Replace("\"", "\"\"")}\"");
                    writer.WriteLine(string.Join(",", values));
                }
                writer.Flush();
                memoryStream.Position = 0;

                // Read CSV from memory stream
                using var reader = new StreamReader(memoryStream);
                using var csv = new CsvReader(reader, CultureInfo.InvariantCulture);
                return csv.GetRecords<T>().ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error reading Excel or CSV data.");
                throw;
            }
        }

        private void CSVToExcel(ref string filePath, string fileName)
        {
            FileInfo fileInfo = new FileInfo(filePath);
            if (!fileInfo.Extension.Equals(".csv"))
                return;
            using (StreamReader streamReader = new StreamReader(filePath))
            {
                using (CsvReader csvReader = new CsvReader((TextReader)streamReader, CultureInfo.InvariantCulture, false))
                {
                    using (CsvDataReader reader = new CsvDataReader(csvReader))
                    {
                        DataTable dataTable = new DataTable();
                        dataTable.Load((IDataReader)reader);
                        filePath = fileInfo.FullName.Replace(".csv", ".xlsx");
                        using (XLWorkbook xlWorkbook = new XLWorkbook())
                        {
                            xlWorkbook.Worksheets.Add(dataTable, fileName.Replace(".csv", string.Empty));
                            xlWorkbook.SaveAs(filePath);
                        }
                    }
                }
            }
        }

    }
}
