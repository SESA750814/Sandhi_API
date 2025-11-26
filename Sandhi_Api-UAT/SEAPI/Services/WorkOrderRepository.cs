using SE.API.DbContexts;
using SE.API.Entities;
using SE.API.Helpers;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SE.API.ResourceParameters;
using System.IO;
using System.Data.OleDb;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Data.Common;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using SE.API.Models;
using System.Globalization;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using DocumentFormat.OpenXml.InkML;
using DocumentFormat.OpenXml.Bibliography;
using DocumentFormat.OpenXml.Drawing.Charts;
using EFCore.BulkExtensions;
using Microsoft.EntityFrameworkCore.Internal;
using Org.BouncyCastle.Ocsp;
using DocumentFormat.OpenXml.Drawing;
using SE.API.Utilities;
using DocumentFormat.OpenXml.Wordprocessing;
using SE.API.Constants;
using Org.BouncyCastle.Asn1.Ocsp;
using Serilog.Filters;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.AspNetCore.Http;
using System.Threading;
using static Org.BouncyCastle.Math.EC.ECCurve;
using System.Text;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using ClosedXML.Excel;
using System.Drawing;
using DocumentFormat.OpenXml.ExtendedProperties;
using System.Security.Cryptography.Xml;
using System.Security.Cryptography;
using System.Net.NetworkInformation;
using System.Net.Http.Headers;
using DocumentFormat.OpenXml.Office2016.Drawing.ChartDrawing;


namespace SE.API.Services
{
    public class WorkOrderRepository : IWorkOrderRepository, IDisposable
    {
        private readonly SEDBContext _context;

        public WorkOrderRepository(SEDBContext context)
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


        public bool SetWorkOrderStatus(WorkOrderStatusSubmitParameter workOrderStatusParameter, ILogger _logger, IConfiguration _config)
        {
            DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
            bool returnValue = false;
            var strategy = _context.Database.CreateExecutionStrategy();

            strategy.Execute(() =>
            {
                if (dbConnection.State.Equals((object)ConnectionState.Closed))
                    dbConnection.Open();

                using (var transaction = _context.Database.BeginTransaction())
                {
                    _logger.LogInformation($"SetWorkOrderStatus : Transaction is Opened");

                    try
                    {
                        workOrderStatusParameter.WOAmount = workOrderStatusParameter.WOAmount ?? -1;
                        workOrderStatusParameter.LabourAmount = workOrderStatusParameter.LabourAmount ?? -1;
                        workOrderStatusParameter.SupplyAmount = workOrderStatusParameter.SupplyAmount ?? -1;

                        int currentStatus = Convert.ToInt32(workOrderStatusParameter.Status);
                        string wos = Convert.ToString(workOrderStatusParameter.WOIds)?.Trim();
                        bool cssVaidateWithAllWO = (currentStatus == (int)StatusType.CSS_Validated && string.IsNullOrWhiteSpace(wos));
                        var validStatuses = GetValidPreviousStatuses(currentStatus, cssVaidateWithAllWO);
                        DateTime currentDate = DateTime.Now;
                        var expiry = currentDate.AddDays(5);
                        var notifications = new List<Notification>();

                        _logger.LogInformation($"SetWorkOrderStatus : Request:- BussinessUnit :${workOrderStatusParameter.BusinessUnit}, CssID:${workOrderStatusParameter.CSSId},Month: ${workOrderStatusParameter.Month}, WO:${wos}, current status: ${Enum.GetName(typeof(StatusType), currentStatus)} , WOAmount: ${workOrderStatusParameter.WOAmount},LabourAmount: ${workOrderStatusParameter.LabourAmount},SupplyAmount: ${workOrderStatusParameter.SupplyAmount}");

                        var WoIds = !string.IsNullOrEmpty(workOrderStatusParameter.WOIds)
                     ? workOrderStatusParameter.WOIds.Split(',').Select(long.Parse).ToHashSet()
                     : null;

                        var users = _context.Users.ToList();
                        var workOrdersQuery = _context.SE_Work_Order.AsQueryable();
                        workOrdersQuery = workOrdersQuery.Where(w => w.Month_Name == workOrderStatusParameter.Month && validStatuses.Contains(w.WO_Process_Status));

                        if (workOrderStatusParameter.CSSId > 0)
                        {
                            workOrdersQuery = workOrdersQuery.Where(w => w.CSS_Id == workOrderStatusParameter.CSSId);
                        }
                        if (!string.IsNullOrEmpty(workOrderStatusParameter.BusinessUnit))
                        {
                            workOrdersQuery = workOrdersQuery.Where(w => w.WO_BusinessUnit == workOrderStatusParameter.BusinessUnit);
                        }
                        if (WoIds != null && WoIds.Count > 0)
                        {
                            workOrdersQuery = workOrdersQuery.Where(w => WoIds.Contains(w.Id));
                        }
                        if (cssVaidateWithAllWO)
                        {
                            workOrdersQuery = workOrdersQuery.Where(wo => wo.Claim > 0 || wo.Is_RepeatCall_NonMaterial == true);
                        }

                        var woList = workOrdersQuery.Include(x => x.CSS).ToList();

                        _logger.LogInformation($"SetWorkOrderStatus : WO count : ${woList.Count()}");

                        var workOrderStatusList = new List<WorkOrderStatus>();

                        foreach (var wo in woList)
                        {
                            wo.WO_Process_Status = currentStatus;
                            switch (currentStatus)
                            {
                                case (int)StatusType.Central_Approved:
                                case (int)StatusType.Central_Rejected:
                                    wo.Central_Status = currentStatus == (int)StatusType.Central_Approved;
                                    wo.Central_UpdatedDate = currentDate;
                                    wo.Central_User = workOrderStatusParameter.UserName;
                                    break;

                                case (int)StatusType.CSS_Validated:
                                case (int)StatusType.CSS_Discrepancy:
                                    wo.CSS_Status = cssVaidateWithAllWO ? true : currentStatus == (int)StatusType.CSS_Validated;
                                    wo.CSS_User = workOrderStatusParameter.UserName;
                                    wo.CSS_UpdatedDate = currentDate;
                                    wo.CSS_Remark = workOrderStatusParameter.Remarks;
                                    wo.CSS_Cost = cssVaidateWithAllWO ? wo.Claim : workOrderStatusParameter.WOAmount;
                                    wo.CSS_LABOUR_COST = cssVaidateWithAllWO ? wo.LABOUR_COST :
                                        (workOrderStatusParameter.LabourAmount == -1 ? wo.LABOUR_COST : workOrderStatusParameter.LabourAmount);
                                    wo.CSS_SUPPLY_COST = cssVaidateWithAllWO ? wo.SUPPLY_COST :
                                        (workOrderStatusParameter.SupplyAmount == -1 ? wo.SUPPLY_COST : workOrderStatusParameter.SupplyAmount);
                                    wo.Claim = workOrderStatusParameter.WOAmount == -1 ? wo.Claim : workOrderStatusParameter.WOAmount;
                                    wo.LABOUR_COST = workOrderStatusParameter.LabourAmount == -1 ? wo.LABOUR_COST : workOrderStatusParameter.LabourAmount;
                                    wo.SUPPLY_COST = workOrderStatusParameter.SupplyAmount == -1 ? wo.SUPPLY_COST : workOrderStatusParameter.SupplyAmount;
                                    wo.CSS_Reason = cssVaidateWithAllWO ? "Approve All" : workOrderStatusParameter.Reason;
                                    wo.CSS_Attachment = cssVaidateWithAllWO ? string.Empty : workOrderStatusParameter.Attachment;
                                    wo.CSS_Reason_Desc = cssVaidateWithAllWO ? string.Empty : workOrderStatusParameter.ReasonDesc;
                                    wo.CSS_Mgr_Status = false;
                                    break;

                                case (int)StatusType.CSS_Approved:
                                    wo.CSS_Status = currentStatus == (int)StatusType.CSS_Approved;
                                    wo.CSS_Approved_Date = currentDate;
                                    wo.CSS_User = workOrderStatusParameter.UserName;
                                    wo.CSS_Mgr_Status = false;
                                    break;

                                case (int)StatusType.CSS_MGR_Approved:
                                case (int)StatusType.CSS_MGR_Discrepancy:
                                case (int)StatusType.CSS_MGR_Approve_Discrepancy:
                                    if (currentStatus != (int)StatusType.CSS_MGR_Approved)
                                    {
                                        wo.CSS_Mgr_Cost = workOrderStatusParameter.WOAmount;
                                        wo.CSS_Mgr_LABOUR_COST = workOrderStatusParameter.LabourAmount == -1 ? wo.LABOUR_COST : workOrderStatusParameter.LabourAmount;
                                        wo.CSS_Mgr_SUPPLY_COST = workOrderStatusParameter.SupplyAmount == -1 ? wo.SUPPLY_COST : workOrderStatusParameter.SupplyAmount;
                                        wo.Claim = workOrderStatusParameter.WOAmount == -1 ? wo.Claim : workOrderStatusParameter.WOAmount;
                                        wo.LABOUR_COST = workOrderStatusParameter.LabourAmount == -1 ? wo.LABOUR_COST : workOrderStatusParameter.LabourAmount;
                                        wo.SUPPLY_COST = workOrderStatusParameter.SupplyAmount == -1 ? wo.SUPPLY_COST : workOrderStatusParameter.SupplyAmount;
                                    }
                                    wo.CSS_Mgr_Status = currentStatus == (int)StatusType.CSS_MGR_Approved || currentStatus == (int)StatusType.CSS_MGR_Approve_Discrepancy;
                                    wo.CSS_Mgr_UpdatedDate = currentDate;
                                    wo.CSS_Mgr_User = workOrderStatusParameter.UserName;
                                    wo.CSS_Mgr_Remark = workOrderStatusParameter.Remarks;
                                    wo.CSS_Mgr_Reason = workOrderStatusParameter.Reason;
                                    wo.CSS_Mgr_Attachment = workOrderStatusParameter.Attachment;
                                    wo.CSS_Mgr_Reason_Desc = workOrderStatusParameter.ReasonDesc;
                                    break;
                            }
                            //WorkOrder Status
                            var workOrderStatus = new WorkOrderStatus
                            {
                                Work_Order_Id = wo.Id,
                                Status_Type = currentStatus,
                                Updated_User = workOrderStatusParameter.UserName,
                                Updated_Date = currentDate,
                                Remarks = workOrderStatusParameter.Remarks,
                                Reason = workOrderStatusParameter.Reason,
                                Attachment = workOrderStatusParameter.Attachment,
                                Reason_Desc = workOrderStatusParameter.ReasonDesc,
                                Wo_Amt = workOrderStatusParameter.WOAmount == -1 ? wo.Claim : workOrderStatusParameter.WOAmount,
                                LABOUR_COST = workOrderStatusParameter.LabourAmount,
                                SUPPLY_COST = workOrderStatusParameter.SupplyAmount
                            };

                            workOrderStatus.WorkOrder = null;
                            workOrderStatus.Auto_Approval = false;
                            workOrderStatusList.Add(workOrderStatus);

                            //add notification
                            string toEmail;
                            if (!string.IsNullOrWhiteSpace(wo.CSS.Email_ID))
                            {
                                toEmail = wo.CSS.Email_ID;
                            }
                            else if (!string.IsNullOrWhiteSpace(wo.CSS.Contact_Person_Email_ID))
                            {
                                toEmail = wo.CSS.Contact_Person_Email_ID;
                            }
                            else
                            {
                                toEmail = users.FirstOrDefault(x => x.CSSCode == wo.CSS.Id.ToString())?.Email ?? string.Empty;
                            }

                            //notification

                            Notification notification = new Notification
                            {
                                Status_Type = currentStatus,
                                Created_User = "System",
                                Created_Date = currentDate,
                                Expiry_Date = expiry,
                            };
                            switch (currentStatus)
                            {
                                case (int)StatusType.Central_Approved:
                                    notification.Ref_No = $"{wo.Month_Name} - Work Orders";
                                    notification.Ref_Type = "";
                                    notification.CSS_Id = wo.CSS_Id;
                                    notification.Remarks = $"The work orders for the month of {wo.Month_Name} is available to be validated";
                                    notification.Action = "WOList";
                                    notification.SUBJECT = $"SE WORK ORDERS - {wo.Month_Name}";
                                    notification.Body = $"The work orders for the month of {wo.Month_Name} is available to be validated. Please login and validate.";
                                    notification.ToEmail = toEmail;
                                    notifications.Add(notification);
                                    break;

                                case (int)StatusType.CSS_Discrepancy:
                                    string Remarks_Body = $"Partner {wo.CSS.CSS_Code} have raised a discrepancy for {wo.Work_Order_Number}. With Reason-{wo.CSS_Reason} Reason Description-{wo.CSS_Reason_Desc} Remarks -{wo.CSS_Remark}";
                                    notification.Ref_No = wo.Work_Order_Number;
                                    notification.CSS_Id = wo.CSS_Id;
                                    notification.Ref_Type = "Work Order";
                                    notification.User_Id = wo.CSS.CSS_MGR_USER_ID;
                                    notification.Remarks = Remarks_Body;
                                    notification.Action = "WODiscrepency";
                                    notification.SUBJECT = $"Work order Discrepancy-{wo.CSS.CSS_Code}";
                                    notification.Body = Remarks_Body;
                                    notification.ToEmail = users.FirstOrDefault(x => x.Id == wo.CSS.CSS_MGR_USER_ID).UserName;
                                    notifications.Add(notification);
                                    break;
                                case (int)StatusType.CSS_Approved:
                                    string Remarks_Body_css_approve = $"The work orders for {wo.CSS.CSS_Code} the month of {wo.Month_Name} is available to be validated";
                                    notification.Ref_No = $"{wo.Month_Name}- Work Orders";
                                    notification.CSS_Id = wo.CSS_Id;
                                    notification.Ref_Type = "";
                                    notification.User_Id = wo.CSS.CSS_MGR_USER_ID;
                                    notification.Remarks = Remarks_Body_css_approve;
                                    notification.Action = "WOList";
                                    notification.SUBJECT = $"Work order Validated-{wo.CSS.CSS_Code}";
                                    notification.Body = Remarks_Body_css_approve;
                                    notification.ToEmail = users.FirstOrDefault(x => x.Id == wo.CSS.CSS_MGR_USER_ID).UserName;
                                    notifications.Add(notification);
                                    break;
                                case (int)StatusType.CSS_MGR_Discrepancy:
                                    string Remarks_Body_MGR_D = $"Partner Manager have raised a discrepency for {wo.Work_Order_Number}. With Reason -{wo.CSS_Mgr_Reason} Reason Description-{wo.CSS_Mgr_Reason_Desc} Remarks -{wo.CSS_Mgr_Remark}";
                                    notification.Ref_No = wo.Work_Order_Number;
                                    notification.CSS_Id = wo.CSS_Id;
                                    notification.Ref_Type = "Work Order";
                                    notification.Remarks = Remarks_Body_MGR_D;
                                    notification.Action = "WODiscrepency";
                                    notification.SUBJECT = $"Work order Discrepency-{wo.Work_Order_Number}";
                                    notification.Body = Remarks_Body_MGR_D;
                                    notification.ToEmail = toEmail;
                                    notifications.Add(notification);
                                    break;
                                case (int)StatusType.CSS_MGR_Approve_Discrepancy:
                                    string Remarks_Body_MGR_A = $"Partner Manager has approved the discrepancy raised by you, for {wo.Work_Order_Number}. With Remarks - {wo.CSS_Mgr_Remark}";
                                    notification.Ref_No = wo.Work_Order_Number;
                                    notification.CSS_Id = wo.CSS_Id;
                                    notification.Ref_Type = "Work Order";
                                    notification.Remarks = Remarks_Body_MGR_A;
                                    notification.Action = "WOList";
                                    notification.SUBJECT = $"Work order Discrepancy Approved-{wo.Work_Order_Number}";
                                    notification.Body = Remarks_Body_MGR_A;
                                    notification.ToEmail = toEmail;
                                    notifications.Add(notification);
                                    break;
                            }
                        }
                        //add in DB
                        if (woList.Count > 0)
                        {
                            _context.BulkUpdate(woList, new BulkConfig
                            {
                                UseTempDB = true,
                                SqlBulkCopyOptions = Microsoft.Data.SqlClient.SqlBulkCopyOptions.Default
                            });
                        }
                        //generate invoice
                        if (currentStatus == (int)StatusType.CSS_MGR_Approved)
                        {
                            _logger.LogInformation($"SetWorkOrderStatus : CSS Start Generating Invoice!!!");

                            CSSGenerateInvoice(woList, currentDate, workOrderStatusParameter, expiry, users, _logger, _config);

                            _logger.LogInformation($"SetWorkOrderStatus : CSS End Generating Invoice!!!");

                        }
                        if (workOrderStatusList.Count > 0)
                        {
                            _context.BulkInsert(workOrderStatusList, new BulkConfig
                            {
                                PropertiesToInclude = new List<string>
                            {
                            nameof(WorkOrderStatus.Work_Order_Id),
                            nameof(WorkOrderStatus.Status_Type),
                            nameof(WorkOrderStatus.Updated_User),
                            nameof(WorkOrderStatus.Updated_Date),
                            nameof(WorkOrderStatus.Remarks),
                            nameof(WorkOrderStatus.Reason),
                            nameof(WorkOrderStatus.Attachment),
                            nameof(WorkOrderStatus.Reason_Desc),
                            nameof(WorkOrderStatus.Wo_Amt),
                            nameof(WorkOrderStatus.LABOUR_COST),
                            nameof(WorkOrderStatus.SUPPLY_COST),
                            nameof(WorkOrderStatus.Auto_Approval)
                            },
                                UseTempDB = true,
                                SqlBulkCopyOptions = Microsoft.Data.SqlClient.SqlBulkCopyOptions.Default,
                            });
                        }

                        if (notifications.Count > 0)
                        {
                            var notifications1 = notifications.GroupBy(x => x.CSS_Id).Select(g => g.First()).ToList();
                            _context.BulkInsert(notifications1, new BulkConfig
                            {
                            });
                        }

                        _context.SaveChanges();
                        transaction.Commit();
                        returnValue = true;
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError($"SetWorkOrderStatus : Transaction is rollback : Exception :- ${ex.Message} ,----inner message--- ${ex.StackTrace}");
                        transaction?.Rollback();
                        returnValue = false;
                    }
                    finally
                    {
                        _logger.LogError($"SetWorkOrderStatus : Transaction is Closed Successfully!!!");
                        if (dbConnection.State.Equals(ConnectionState.Open)) { dbConnection.Close(); }
                    }
                }
            });

            return returnValue;
        }

        private void CSSGenerateInvoice(List<WorkOrder> updatedWo, DateTime currentDateTime, WorkOrderStatusSubmitParameter workOrderStatusParameter, DateTime expireDate, List<StoreUser> users, ILogger _logger, IConfiguration _config)
        {
            decimal taxPercentage = 18;
            int generateInvoice_DefaultStatus = -99;

            HBN_PPI(updatedWo, currentDateTime, workOrderStatusParameter, expireDate, users, generateInvoice_DefaultStatus, taxPercentage, _logger, _config);

            Cooling(updatedWo, currentDateTime, workOrderStatusParameter, expireDate, users, generateInvoice_DefaultStatus, taxPercentage, _logger, _config);
        }
        private void Cooling(List<WorkOrder> updatedWo, DateTime currentDateTime, WorkOrderStatusSubmitParameter workOrderStatusParameter,
           DateTime expireDate, List<StoreUser> users, int generateInvoice_DefaultStatus, decimal taxPercentage, ILogger _logger, IConfiguration _config)
        {
            try
            {
                if (workOrderStatusParameter.BusinessUnit.Trim().ToLower() == BussinessUnit.Cooling)
                {
                    var cssGroup_labour = updatedWo.Where(x => x.LABOUR_COST > 0)
                     .GroupBy(x => new { x.CSS_Id, x.WO_BusinessUnit, x.CSS.CSS_Code }).FirstOrDefault();

                    var cssGroup_Supply = updatedWo.Where(x => x.SUPPLY_COST > 0)
                    .GroupBy(x => new { x.CSS_Id, x.WO_BusinessUnit, x.CSS.CSS_Code }).FirstOrDefault();

                    string PRF_NO_fromLabour = null;

                    List<Invoice> invoice = new List<Invoice>();

                    if (cssGroup_labour != null)
                    {
                        var css_labour = cssGroup_labour.First().CSS;
                        decimal wo_amt = cssGroup_labour.Sum(x => x.LABOUR_COST) ?? 0;
                        _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : cssGroup_labour : CSS : ${css_labour.CSS_Code}");

                        var temp_invoice = new Invoice
                        {
                            CSS_Id = cssGroup_labour.Key.CSS_Id,
                            Month_Name = workOrderStatusParameter.Month,
                            Inv_Type = Common.Cooling_Labour,
                            WO_BusinessUnit = cssGroup_labour.Key.WO_BusinessUnit,
                            WO_Amt = wo_amt,
                            WO_COUNT = cssGroup_labour.Count(),
                            PRF_No = GeneratePRFNo(cssGroup_labour.Key.CSS_Code, currentDateTime, 0, workOrderStatusParameter.CSSId),
                            PRF_Gen_Date = currentDateTime,
                            Status_Type = wo_amt == 0 ? (int)StatusType.Zero_Value_Invoice : generateInvoice_DefaultStatus,
                            Updated_User = Common.System_User,
                            Updated_Date = currentDateTime,
                            Remarks = string.Empty,
                        };

                        PRF_NO_fromLabour = temp_invoice.PRF_No;

                        temp_invoice.Base_Payout = temp_invoice.WO_Amt * (css_labour.Base_Payout_Percentage ?? 0) / 100;
                        temp_invoice.Incentive_Amt = temp_invoice.Base_Payout * (css_labour.Incentive_Percentage ?? 0) / 100;
                        temp_invoice.Inv_Amt = temp_invoice.Base_Payout + temp_invoice.Incentive_Amt;
                        temp_invoice.Tax_Amt = temp_invoice.Inv_Amt * (taxPercentage / 100);
                        temp_invoice.Inc_Tax_Amt = temp_invoice.Inv_Amt + temp_invoice.Tax_Amt;
                        invoice.Add(temp_invoice);
                    }

                    if (cssGroup_Supply != null)
                    {
                        var css_sply = cssGroup_Supply.First().CSS;
                        decimal wo_amt = cssGroup_Supply.Sum(x => x.SUPPLY_COST) ?? 0;
                        _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : cssGroup_Supply : CSS : ${css_sply.CSS_Code}");

                        var temp_invoice = new Invoice
                        {
                            CSS_Id = cssGroup_Supply.Key.CSS_Id,
                            Month_Name = workOrderStatusParameter.Month,
                            Inv_Type = Common.Cooling_Supply,
                            WO_BusinessUnit = cssGroup_Supply.Key.WO_BusinessUnit,
                            WO_Amt = wo_amt,
                            WO_COUNT = cssGroup_Supply.Count(),
                            PRF_No = PRF_NO_fromLabour == null ? GeneratePRFNo(cssGroup_Supply.Key.CSS_Code, currentDateTime, 0, null) : PRF_NO_fromLabour,
                            PRF_Gen_Date = currentDateTime,
                            Status_Type = wo_amt == 0 ? (int)StatusType.Zero_Value_Invoice : generateInvoice_DefaultStatus,
                            Updated_User = Common.System_User,
                            Updated_Date = currentDateTime,
                            Remarks = string.Empty,
                        };

                        temp_invoice.Base_Payout = temp_invoice.WO_Amt * (css_sply.Base_Payout_Percentage ?? 0) / 100;
                        temp_invoice.Incentive_Amt = temp_invoice.Base_Payout * (css_sply.Incentive_Percentage ?? 0) / 100;
                        temp_invoice.Inv_Amt = temp_invoice.Base_Payout + temp_invoice.Incentive_Amt;
                        temp_invoice.Tax_Amt = temp_invoice.Inv_Amt * (taxPercentage / 100);
                        temp_invoice.Inc_Tax_Amt = temp_invoice.Inv_Amt + temp_invoice.Tax_Amt;
                        invoice.Add(temp_invoice);
                    }

                    //show logs for invoices
                    foreach (var item in invoice)
                    {
                        _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : Invoice : ${item.Id},WO_Amt: ${item.WO_Amt},WO_COUNT: ${item.WO_COUNT}, " +
                          $"PRF_No :${item.PRF_No},Base_Payout: ${item.Base_Payout}, Incentive_Amt: ${item.Incentive_Amt}, Inv_Amt: ${item.Inv_Amt}" +
                          $"Tax_Amt : ${item.Tax_Amt}, Inc_Tax_Amt: ${item.Inc_Tax_Amt}, Status_Type : ${item.Status_Type}");
                    }

                    _context.BulkInsert(invoice, new BulkConfig
                    {
                        PropertiesToInclude = new List<string>
                    {
                     nameof(Invoice.CSS_Id),
                     nameof(Invoice.Month_Name),
                     nameof(Invoice.Inv_Type),
                     nameof(Invoice.WO_BusinessUnit),
                     nameof(Invoice.WO_Amt),
                     nameof(Invoice.WO_COUNT),
                     nameof(Invoice.PRF_No),
                     nameof(Invoice.PRF_Gen_Date),
                     nameof(Invoice.Status_Type),
                     nameof(Invoice.Updated_User),
                     nameof(Invoice.Updated_Date),
                     nameof(Invoice.Remarks),
                     nameof(Invoice.Base_Payout),
                     nameof(Invoice.Incentive_Amt),
                     nameof(Invoice.Inv_Amt),
                     nameof(Invoice.Tax_Amt),
                     nameof(Invoice.Inc_Tax_Amt),
                    },

                        UseTempDB = true,
                        SqlBulkCopyOptions = Microsoft.Data.SqlClient.SqlBulkCopyOptions.Default,
                        SetOutputIdentity = true

                    });

                    List<InvoiceDetail> invoiceDetails = new List<InvoiceDetail>();
                    //labour
                    var labour_Invoice = invoice.First(x => x.Inv_Type == Common.Cooling_Labour);

                    var temp_labor_invoiceDetail = cssGroup_labour?
                      .GroupBy(w => (w.AMC_WARRANTY_FLAG ?? "").Trim())
                      .Select(g => new InvoiceDetail
                      {
                          INV_ID = labour_Invoice.Id,
                          AMC_WARRANTY_FLAG = g.Key,
                          INV_AMT = g.Sum(x => x.LABOUR_COST) ?? 0,
                          Updated_User = Common.System_User,
                          Updated_Date = currentDateTime
                      }).ToList();
                    invoiceDetails.AddRange(temp_labor_invoiceDetail);

                    //supply
                    Invoice? supply_Invoice = invoice.FirstOrDefault(x => x.Inv_Type == Common.Cooling_Supply);
                    List<InvoiceDetail> temp_supply_invoiceDetail = new List<InvoiceDetail>();
                    if (supply_Invoice != null)
                    {
                        temp_supply_invoiceDetail = cssGroup_Supply
                                         .GroupBy(w => (w.AMC_WARRANTY_FLAG ?? "").Trim())
                                         .Select(g => new InvoiceDetail
                                         {
                                             INV_ID = supply_Invoice.Id,
                                             AMC_WARRANTY_FLAG = g.Key,
                                             INV_AMT = g.Sum(x => x.SUPPLY_COST) ?? 0,
                                             Updated_User = Common.System_User,
                                             Updated_Date = currentDateTime
                                         }).ToList();
                        invoiceDetails.AddRange(temp_supply_invoiceDetail);

                        _context.BulkInsert(invoiceDetails, new BulkConfig
                        {
                            PropertiesToInclude = new List<string>
                     {
                     nameof(InvoiceDetail.INV_ID),
                     nameof(InvoiceDetail.AMC_WARRANTY_FLAG),
                     nameof(InvoiceDetail.INV_AMT),
                     nameof(InvoiceDetail.Updated_User),
                     nameof(InvoiceDetail.Updated_Date)
                     },
                            UseTempDB = true
                        });
                    }

                    //po link
                    var matchingPO = _context.SE_CSS_Purchase_Order
                       .Where(po => po.CSS_Id == workOrderStatusParameter.CSSId
                       && (po.Valid_Till ?? currentDateTime.AddDays(2)) > currentDateTime
                       && po.Status == "Active").ToList();

                    if (matchingPO.Count > 0)
                    {
                        //labour PO
                        if (labour_Invoice.WO_Amt != 0)
                        {
                            var amcAmt_labour = temp_labor_invoiceDetail
                       .Where(d => d.AMC_WARRANTY_FLAG?.ToUpper() == "AMC")
                       .Sum(d => d.INV_AMT);

                            var warrantyAmt_labour = temp_labor_invoiceDetail
                            .Where(d => d.AMC_WARRANTY_FLAG?.ToUpper() == "WARRANTY")
                            .Sum(d => d.INV_AMT);

                            //labout PO
                            var labour_matching_PO = matchingPO.FirstOrDefault(x =>
                                           x.AVAILABLE_LABOR_AMC_AMT >= amcAmt_labour
                                        && x.AVAILABLE_LABOR_WARRANTY_AMT >= warrantyAmt_labour);
                            if (labour_matching_PO != null)
                            {
                                labour_Invoice.PO_Id = labour_matching_PO.Id;
                                labour_Invoice.PO_ASSIGN_DATE = DateTime.Now;
                                labour_matching_PO.AVAILABLE_LABOR_AMC_AMT -= amcAmt_labour;
                                labour_matching_PO.AVAILABLE_LABOR_WARRANTY_AMT -= warrantyAmt_labour;
                                _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : Cooling Labour PO Updating : POID: ${labour_matching_PO.Id}, AVAILABLE_LABOR_AMC_AMT: ${labour_matching_PO.AVAILABLE_LABOR_AMC_AMT}, AVAILABLE_LABOR_WARRANTY_AMT: ${labour_matching_PO.AVAILABLE_LABOR_WARRANTY_AMT}");
                            }

                            //send mail po thressold
                            CheckThresold70AmountAndSendEmail(labour_matching_PO, workOrderStatusParameter.BusinessUnit, _config, _logger, cssGroup_labour?.FirstOrDefault().CSS, true);
                        }

                        if (supply_Invoice != null && supply_Invoice.WO_Amt != 0)
                        {
                            //SupplyPO
                            var amcAmt_supply = temp_supply_invoiceDetail
                            .Where(d => d.AMC_WARRANTY_FLAG?.ToUpper() == "AMC")
                            .Sum(d => d.INV_AMT);

                            var warrantyAmt_supply = temp_supply_invoiceDetail
                            .Where(d => d.AMC_WARRANTY_FLAG?.ToUpper() == "WARRANTY")
                            .Sum(d => d.INV_AMT);

                            //labout PO
                            var supply_matching_PO = matchingPO.FirstOrDefault(x =>
                                           x.AVAILABLE_SUPPLY_AMC_AMT >= amcAmt_supply
                                        && x.AVAILABLE_SUPPLY_WARRANTY_AMT >= warrantyAmt_supply);
                            if (supply_matching_PO != null)
                            {
                                supply_Invoice.PO_Id = supply_matching_PO.Id;
                                supply_Invoice.PO_ASSIGN_DATE = DateTime.Now;
                                supply_matching_PO.AVAILABLE_SUPPLY_AMC_AMT -= amcAmt_supply;
                                supply_matching_PO.AVAILABLE_SUPPLY_WARRANTY_AMT -= warrantyAmt_supply;

                                _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : Cooling Supply PO Updating : POID: ${supply_matching_PO.Id}, AVAILABLE_SUPPLY_AMC_AMT: ${supply_matching_PO.AVAILABLE_SUPPLY_AMC_AMT}, AVAILABLE_SUPPLY_WARRANTY_AMT: ${supply_matching_PO.AVAILABLE_SUPPLY_WARRANTY_AMT}");
                            }

                            //send mail po thressold
                            CheckThresold70AmountAndSendEmail(supply_matching_PO, workOrderStatusParameter.BusinessUnit, _config, _logger, cssGroup_Supply?.FirstOrDefault().CSS);

                        }
                        _context.BulkUpdate(matchingPO);
                    }
                    else
                    {
                        _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : Cooling Matching PO Not Found");
                    }
                    var statusEntries = new List<InvoiceStatus>();

                    foreach (var item in invoice)
                    {
                        var invoice_status = item.WO_Amt == 0 ? (int)StatusType.Zero_Value_Invoice
                      : ((item.PO_Id.HasValue && item.PO_Id.Value != -1))
                     ? (int)StatusType.PRF_Raised
                     : (int)StatusType.PO_Waiting;

                        statusEntries.Add(new InvoiceStatus
                        {
                            Inv_Id = item.Id,
                            Status_Type = invoice_status,
                            Remarks = "", // Placeholder for empty string fields
                            Attachment = "",
                            Updated_User = Common.System_User,
                            Updated_Date = currentDateTime
                        });
                        item.Status_Type = invoice_status;

                        _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : invoice ID {item.Id}, Invoice Status: ${invoice_status}");
                    }

                    _context.BulkInsert(statusEntries);

                    foreach (var wo in cssGroup_labour)
                    {
                        wo.INV_ID = labour_Invoice.Id;
                        //wo.WO_Process_Status = labour_Invoice.Status_Type;
                    }

                    _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : Labour WO Inv_Id updated ${labour_Invoice.Id} on updated Labour WOs ${cssGroup_labour.Count()}");

                    if (cssGroup_Supply != null)
                    {
                        foreach (var wo in cssGroup_Supply)
                        {
                            wo.SUPPLY_INV_ID = supply_Invoice.Id;
                            //wo.WO_Process_Status = supply_Invoice.Status_Type;
                        }

                        _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : Supply WO Inv_Id updated ${supply_Invoice.Id} on updated Supply WOs ${cssGroup_Supply.Count()}");
                    }

                    _context.BulkUpdate(updatedWo, new BulkConfig
                    {
                        UseTempDB = true,
                        SqlBulkCopyOptions = Microsoft.Data.SqlClient.SqlBulkCopyOptions.Default,
                    });

                    _context.BulkUpdate(invoice
                     , new BulkConfig
                     {
                         PropertiesToInclude = new List<string>
                      {
                  nameof(Invoice.Id),
                  nameof(Invoice.PO_Id),
                  nameof(Invoice.Status_Type)
                      },
                         UseTempDB = true
                     }
                     );

                    ///add notification for CSS or Central user based on status 
                    /// -- if po_id exists for status_type =-99 then send a prf raised notification to css  
                    ///  -- if po_id is null for status_type=-99 then send a notification to central user that this css needs PO for value  
                    List<Notification> notifications = new List<Notification>();
                    CSS css = updatedWo.First().CSS;
                    foreach (var item in invoice)
                    {
                        switch (item.Status_Type)
                        {
                            case (int)StatusType.PRF_Raised:
                                notifications.Add(new Notification
                                {
                                    Status_Type = (int)StatusType.PRF_Raised,
                                    Ref_No = item.Month_Name,
                                    Ref_Type = "PRF",
                                    CSS_Id = item.CSS_Id,
                                    Remarks = $"PRF ${item.PRF_No} for the month of ${item.Month_Name} has been raised. Please raise an invoice for the same.",
                                    Action = "Invoice",
                                    Created_User = Common.System_User,
                                    Created_Date = currentDateTime,
                                    Expiry_Date = expireDate,
                                    SUBJECT = "SE PRF RAISED -" + item.Month_Name,
                                    Body = $"PRF ${item.PRF_No} for the month of ${item.Month_Name} has been raised. Please raise an invoice for the same with PO reference {matchingPO.FirstOrDefault()?.PO_NO} and invoice amount ₹{item.WO_Amt}.",
                                    ToEmail = css.Email_ID
                                });
                                break;
                            case (int)StatusType.PO_Waiting:
                                var invoiceDetails1 = invoiceDetails.Where(x => x.INV_ID == item.Id)
                                   .GroupBy(d => d.INV_ID)
                                   .Select(g => new
                                   {
                                       INV_ID = g.Key,
                                       InvoiceDetail = string.Join(", ", g.Select(x => $"{x.AMC_WARRANTY_FLAG}:{x.INV_AMT}"))
                                   })
                                   .FirstOrDefault();

                                var groupedUsers = users
                                   .Where(x => x.UserType == 1)
                                   .GroupBy(u => u.UserType)
                                   .Select(g => new
                                   {
                                       UserType = g.Key,
                                       UserNames = string.Join(", ", g.Select(u => u.UserName))
                                   })
                                   .FirstOrDefault();

                                notifications.Add(new Notification
                                {
                                    Status_Type = (int)StatusType.PO_Waiting,
                                    Ref_No = item.Month_Name,
                                    Ref_Type = "Awaiting PO",
                                    User_Type = "1",
                                    Remarks = $"PRF {item.PRF_No} for {css.CSS_Code} for the month of {item.Month_Name} for Amount {item.Inv_Amt} is awaiting PO.<br/>Invoice Breakup - {invoiceDetails1.InvoiceDetail}",
                                    Action = "Invoice",
                                    Created_User = Common.System_User,
                                    Created_Date = currentDateTime,
                                    Expiry_Date = expireDate,
                                    SUBJECT = $"PRF AWAITING PURCHASE ORDER - {css.CSS_Code}",
                                    Body = $"PRF {item.PRF_No} for {css.CSS_Code} for the month of {item.Month_Name} for Amount {item.Inv_Amt} is awaiting PO.<br/>Invoice Breakup - {invoiceDetails1.InvoiceDetail}",
                                    ToEmail = groupedUsers.UserNames
                                });
                                break;
                            case (int)StatusType.Zero_Value_Invoice:
                                notifications.Add(new Notification
                                {
                                    Status_Type = (int)StatusType.Zero_Value_Invoice,
                                    Ref_No = item.Month_Name,
                                    Ref_Type = "Zero Value Invoice",
                                    CSS_Id = item.CSS_Id,
                                    Remarks = $"PRF ${item.PRF_No} for the month of ${item.Month_Name} has been raised with Zero Invoice Value.",
                                    Action = "Invoice",
                                    Created_User = Common.System_User,
                                    Created_Date = currentDateTime,
                                    Expiry_Date = expireDate,
                                    SUBJECT = "SE PRF RAISED WITH ZERO INVOICE VALUE -" + item.Month_Name,
                                    Body = $"PRF ${item.PRF_No} for the month of ${item.Month_Name} has been raised with Zero Invoice Value.",
                                    ToEmail = item.CSS.Email_ID
                                });
                                break;
                            default:
                                break;
                        }
                    }

                    _context.BulkInsert(notifications);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"SetWorkOrderStatus : Invoice Generating : Cooling : Error message {ex.InnerException?.Message?.ToString()}  Exception :- ${ex.Message} ,----inner message--- ${ex.StackTrace}");
                throw;
            }

        }
        private void HBN_PPI(List<WorkOrder> updatedWo, DateTime currentDateTime, WorkOrderStatusSubmitParameter workOrderStatusParameter,
            DateTime expireDate, List<StoreUser> users, int generateInvoice_DefaultStatus, decimal taxPercentage, ILogger _logger, IConfiguration _config)
        {
            if (workOrderStatusParameter.BusinessUnit.Trim().ToLower() == BussinessUnit.HBN || workOrderStatusParameter.BusinessUnit.Trim().ToLower() == BussinessUnit.PPI)
            {
                var cssGroup = updatedWo
                 .GroupBy(x => new { x.CSS_Id, x.WO_BusinessUnit, x.CSS.CSS_Code }).FirstOrDefault();

                if (cssGroup != null)
                {
                    var css = cssGroup.First().CSS;
                    decimal wo_amt = cssGroup.Sum(x => x.Claim) ?? 0;
                    _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : HBN_PPI : CSS : ${css.CSS_Code}");

                    var invoice = new Invoice
                    {
                        CSS_Id = cssGroup.Key.CSS_Id,
                        Month_Name = workOrderStatusParameter.Month,
                        Inv_Type = "All",
                        WO_BusinessUnit = cssGroup.Key.WO_BusinessUnit,
                        WO_Amt = wo_amt,
                        WO_COUNT = cssGroup.Count(),
                        PRF_No = GeneratePRFNo(cssGroup.Key.CSS_Code, currentDateTime, 0, null),
                        PRF_Gen_Date = currentDateTime,
                        Status_Type = wo_amt == 0 ? (int)StatusType.Zero_Value_Invoice : generateInvoice_DefaultStatus,
                        Updated_User = Common.System_User,
                        Updated_Date = currentDateTime,
                        Remarks = string.Empty,
                        Created_Date = currentDateTime
                    };

                    invoice.Base_Payout = invoice.WO_Amt * (css.Base_Payout_Percentage ?? 0) / 100;
                    invoice.Incentive_Amt = invoice.Base_Payout * (css.Incentive_Percentage ?? 0) / 100;
                    invoice.Inv_Amt = invoice.Base_Payout + invoice.Incentive_Amt;
                    invoice.Tax_Amt = invoice.Inv_Amt * (taxPercentage / 100);
                    invoice.Inc_Tax_Amt = invoice.Inv_Amt + invoice.Tax_Amt;

                    _context.SE_CSS_Invoice.Add(invoice);
                    _context.SaveChanges();

                    _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : Invoice : ${invoice.Id},WO_Amt: ${invoice.WO_Amt},WO_COUNT: ${invoice.WO_COUNT}, " +
                        $"PRF_No :${invoice.PRF_No},Base_Payout: ${invoice.Base_Payout}, Incentive_Amt: ${invoice.Incentive_Amt}, Inv_Amt: ${invoice.Inv_Amt}" +
                        $"Tax_Amt : ${invoice.Tax_Amt}, Inc_Tax_Amt: ${invoice.Inc_Tax_Amt}, Status: ${invoice.Status_Type}");

                    var invoiceDetails = updatedWo
                    .GroupBy(w => (w.AMC_WARRANTY_FLAG ?? "").Trim())
                    .Select(g => new InvoiceDetail
                    {
                        INV_ID = invoice.Id,
                        AMC_WARRANTY_FLAG = g.Key,
                        INV_AMT = g.Sum(x => x.Claim) ?? 0,
                        Updated_User = Common.System_User,
                        Updated_Date = currentDateTime
                    }).ToList();

                    _context.BulkInsert(invoiceDetails, new BulkConfig
                    {
                        PropertiesToInclude = new List<string>
                        {
                        nameof(InvoiceDetail.INV_ID),
                        nameof(InvoiceDetail.AMC_WARRANTY_FLAG),
                        nameof(InvoiceDetail.INV_AMT),
                        nameof(InvoiceDetail.Updated_User),
                        nameof(InvoiceDetail.Updated_Date)
                        },
                        UseTempDB = true
                    });

                    long? Po_ID = null;
                    PurchaseOrder? matchingPO = null;

                    if (wo_amt != 0)
                    {
                        if (workOrderStatusParameter.BusinessUnit.ToLower() == BussinessUnit.PPI)
                        {
                            matchingPO = _context.SE_CSS_Purchase_Order
                           .Where(po => po.CSS_Id == invoice.CSS_Id
                           && (po.Valid_Till ?? currentDateTime.AddDays(2)) > currentDateTime
                           && po.Status == "Active"
                           && po.Month_Name == invoice.Month_Name
                           && po.AVAILABLE_BASIC_AMT >= invoice.Inv_Amt).FirstOrDefault();
                            if (matchingPO != null)
                            {
                                Po_ID = matchingPO.Id;
                                matchingPO.AVAILABLE_BASIC_AMT = matchingPO.AVAILABLE_BASIC_AMT - invoice.Inv_Amt;
                                _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : PPI PO Updating : POID: ${Po_ID}, AVAILABLE_BASIC_AMT: ${matchingPO.AVAILABLE_BASIC_AMT}");
                                CheckThresold70AmountAndSendEmail(matchingPO, workOrderStatusParameter.BusinessUnit, _config, _logger, css);
                            }


                        }
                        else if (workOrderStatusParameter.BusinessUnit.ToLower() == BussinessUnit.HBN)
                        {
                            /////po link
                            var amcAmt = invoiceDetails
                            .Where(d => d.INV_ID == invoice.Id && d.AMC_WARRANTY_FLAG?.ToUpper() == "AMC")
                            .Sum(d => d.INV_AMT);

                            var warrantyAmt = invoiceDetails
                            .Where(d => d.INV_ID == invoice.Id && d.AMC_WARRANTY_FLAG?.ToUpper() == "WARRANTY")
                            .Sum(d => d.INV_AMT);

                            matchingPO = _context.SE_CSS_Purchase_Order
                                        .Where(po => po.CSS_Id == invoice.CSS_Id
                                        && (po.Valid_Till ?? currentDateTime.AddDays(2)) > currentDateTime
                                        && po.Status == "Active"
                                        && po.AVAILABLE_HBN_AMC_AMT >= amcAmt
                                        && po.AVAILABLE_HBN_WARRANTY_AMT >= warrantyAmt).FirstOrDefault();
                            if (matchingPO != null)
                            {
                                Po_ID = matchingPO.Id;
                                matchingPO.AVAILABLE_HBN_AMC_AMT -= amcAmt;
                                matchingPO.AVAILABLE_HBN_WARRANTY_AMT -= warrantyAmt;
                                _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : HBN PO Updating : POID: ${Po_ID}, AVAILABLE_HBN_AMC_AMT: ${matchingPO.AVAILABLE_HBN_AMC_AMT}, AVAILABLE_HBN_WARRANTY_AMT:${matchingPO.AVAILABLE_HBN_WARRANTY_AMT}");
                                CheckThresold70AmountAndSendEmail(matchingPO, workOrderStatusParameter.BusinessUnit, _config, _logger, css);

                            }
                        }

                        if (matchingPO != null)
                        {
                            _context.Update(matchingPO);
                        }
                    }

                    var statusEntries = new List<InvoiceStatus>();
                    var invoice_status = wo_amt == 0 ? (int)StatusType.Zero_Value_Invoice
                     : (Po_ID.HasValue && Po_ID.Value != -1)
                     ? (int)StatusType.PRF_Raised
                     : (int)StatusType.PO_Waiting;

                    _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : Invoice Status: ${invoice_status}");

                    statusEntries.Add(new InvoiceStatus
                    {
                        Inv_Id = invoice.Id,
                        Status_Type = invoice_status,
                        Remarks = "", // Placeholder for empty string fields
                        Attachment = "",
                        Updated_User = Common.System_User,
                        Updated_Date = currentDateTime
                    });

                    //update inv id in workorder

                    invoice.PO_Id = Po_ID;
                    invoice.PO_ASSIGN_DATE = DateTime.Now;
                    invoice.Status_Type = invoice_status;

                    foreach (var wo in updatedWo)
                    {
                        wo.INV_ID = invoice.Id;
                        //wo.WO_Process_Status = invoice_status;
                    }

                    _logger.LogInformation($"SetWorkOrderStatus : Invoice Generating : Inv_Id updated ${invoice.Id} on updated Wos ${updatedWo.Count()}");

                    _context.Update(invoice);
                    _context.BulkInsert(statusEntries);
                    _context.BulkUpdate(updatedWo, new BulkConfig
                    {
                        UseTempDB = true,
                        SqlBulkCopyOptions = Microsoft.Data.SqlClient.SqlBulkCopyOptions.Default,
                        PropertiesToInclude = new List<string> { nameof(WorkOrder.INV_ID) }
                    });

                    Notification notification = new Notification();
                    switch (invoice_status)
                    {
                        case (int)StatusType.PRF_Raised:
                            notification = new Notification
                            {
                                Status_Type = (int)StatusType.PRF_Raised,
                                Ref_No = invoice.Month_Name,
                                Ref_Type = "PRF",
                                CSS_Id = invoice.CSS_Id,
                                Remarks = $"PRF ${invoice.PRF_No} for the month of ${invoice.Month_Name} has been raised. Please raise an invoice for the same.",
                                Action = "Invoice",
                                Created_User = Common.System_User,
                                Created_Date = currentDateTime,
                                Expiry_Date = expireDate,
                                SUBJECT = "SE PRF RAISED -" + invoice.Month_Name,
                                Body = $"PRF ${invoice.PRF_No} for the month of ${invoice.Month_Name} has been raised. Please raise an invoice for the same with PO reference {matchingPO?.PO_NO} and invoice amount ₹{invoice.WO_Amt}.",
                                ToEmail = invoice.CSS.Email_ID
                            };
                            break;
                        case (int)StatusType.PO_Waiting:
                            var invoiceDetails1 = invoiceDetails

                                .GroupBy(d => d.INV_ID)
                                .Select(g => new
                                {
                                    INV_ID = g.Key,
                                    InvoiceDetail = string.Join(", ", g.Select(x => $"{x.AMC_WARRANTY_FLAG}:{x.INV_AMT}"))
                                })
                                .FirstOrDefault();

                            var groupedUsers = users
                               .Where(x => x.UserType == 1)
                               .GroupBy(u => u.UserType)
                               .Select(g => new
                               {
                                   UserType = g.Key,
                                   UserNames = string.Join(", ", g.Select(u => u.UserName))
                               })
                               .FirstOrDefault();

                            notification = new Notification
                            {
                                Status_Type = (int)StatusType.PO_Waiting,
                                Ref_No = invoice.Month_Name,
                                Ref_Type = "Awaiting PO",
                                User_Type = "1",
                                Remarks = $"PRF {invoice.PRF_No} for {invoice.CSS.CSS_Code} for the month of {invoice.Month_Name} for Amount {invoice.Inv_Amt} is awaiting PO.<br/>Invoice Breakup - {invoiceDetails1.InvoiceDetail}",
                                Action = "Invoice",
                                Created_User = Common.System_User,
                                Created_Date = currentDateTime,
                                Expiry_Date = expireDate,
                                SUBJECT = $"PRF AWAITING PURCHASE ORDER - {invoice.CSS.CSS_Code}",
                                Body = $"PRF {invoice.PRF_No} for {invoice.CSS.CSS_Code} for the month of {invoice.Month_Name} for Amount {invoice.Inv_Amt} is awaiting PO.<br/>Invoice Breakup - {invoiceDetails1.InvoiceDetail}",
                                ToEmail = groupedUsers.UserNames
                            };
                            break;
                        case (int)StatusType.Zero_Value_Invoice:
                            notification = new Notification
                            {
                                Status_Type = (int)StatusType.Zero_Value_Invoice,
                                Ref_No = invoice.Month_Name,
                                Ref_Type = "Zero Value Invoice",
                                CSS_Id = invoice.CSS_Id,
                                Remarks = $"PRF ${invoice.PRF_No} for the month of ${invoice.Month_Name} has been raised with Zero Invoice Value.",
                                Action = "Invoice",
                                Created_User = Common.System_User,
                                Created_Date = currentDateTime,
                                Expiry_Date = expireDate,
                                SUBJECT = "SE PRF RAISED WITH ZERO INVOICE VALUE -" + invoice.Month_Name,
                                Body = $"PRF ${invoice.PRF_No} for the month of ${invoice.Month_Name} has been raised with Zero Invoice Value.",
                                ToEmail = invoice.CSS.Email_ID
                            };
                            break;
                        default:
                            break;
                    }

                    if (notification != null)
                    {
                        _context.SE_Notification.Add(notification);
                    }
                }
            }
        }

        public void CheckThresold70AmountAndSendEmail(PurchaseOrder purchaseOrder, string bussinessUnit, IConfiguration _config, ILogger _logger, CSS css, bool islabour = false)
        {
            var IsPOThresoldEmailSend = _config.GetSection("newEnhancement").GetValue<bool>("IsPOThresoldEmailSend");

            if (IsPOThresoldEmailSend)
            {
                var thresoldPercentage = _config.GetSection("POEmailSetting").GetValue<int>("POAmountThresoldPercentage");

                if (bussinessUnit.ToLower() == "cooling")
                {
                    if (islabour)
                    {
                        //labour
                        decimal thresholdAmount_labour = purchaseOrder.LABOR_AMC_AMT * thresoldPercentage / 100;
                        decimal thresholdAmount_warranty = purchaseOrder.LABOR_WARRANTY_AMT * thresoldPercentage / 100;

                        if (purchaseOrder.AVAILABLE_LABOR_AMC_AMT <= thresholdAmount_labour || purchaseOrder.AVAILABLE_LABOR_WARRANTY_AMT <= thresholdAmount_warranty)
                        {
                            SendPOThresoldEmail(purchaseOrder, bussinessUnit, true, thresoldPercentage, _logger, _config, css);
                        }
                    }
                    else
                    {
                        //supply
                        decimal thresholdAmount_supply = purchaseOrder.SUPPLY_AMC_AMT * thresoldPercentage / 100;
                        decimal thresholdAmount_supply_warranty = purchaseOrder.SUPPLY_WARRANTY_AMT * thresoldPercentage / 100;

                        if (purchaseOrder.AVAILABLE_SUPPLY_AMC_AMT <= thresholdAmount_supply || purchaseOrder.AVAILABLE_SUPPLY_AMC_AMT <= thresholdAmount_supply_warranty)
                        {
                            SendPOThresoldEmail(purchaseOrder, bussinessUnit, false, thresoldPercentage, _logger, _config, css);
                        }
                    }
                }
                if (bussinessUnit.ToLower() == "hbn")
                {
                    decimal thresholdAmount_amc = purchaseOrder.HBN_AMC_AMT * thresoldPercentage / 100;
                    decimal thresholdAmount_warranty = purchaseOrder.HBN_WARRANTY_AMT * thresoldPercentage / 100;

                    if (purchaseOrder.AVAILABLE_HBN_AMC_AMT <= thresholdAmount_amc || purchaseOrder.AVAILABLE_HBN_WARRANTY_AMT <= thresholdAmount_warranty)
                    {
                        SendPOThresoldEmail(purchaseOrder, bussinessUnit, false, thresoldPercentage, _logger, _config, css);
                    }
                }
                if (bussinessUnit.ToLower() == "ppi")
                {

                    decimal thresholdAmount = purchaseOrder.BASIC_AMT * thresoldPercentage / 100;

                    if (purchaseOrder.AVAILABLE_BASIC_AMT <= thresholdAmount)
                    {
                        SendPOThresoldEmail(purchaseOrder, bussinessUnit, false, thresoldPercentage, _logger, _config, css);
                    }
                }
            }
        }

        public bool SendPOThresoldEmail(PurchaseOrder purchaseOrder, string bussinessUnit, bool islabour, int thresoldPercentage, ILogger _logger, IConfiguration _config, CSS css)
        {
            List<Invoice> lstInvoice = new List<Invoice>();
            try
            {
                _logger.LogInformation($"call started SendPOThresoldEmail on businessunit:- ${bussinessUnit}");

                var emailSubject = "PO Value Usage Alert";
                var body = string.Empty;
                var ccEmail = string.Concat(css.CSS_Manager_Email_ID, ",", css.Contact_Person_Email_ID);
                var toEmail = string.Concat(_config.GetSection("POEmailSetting").GetValue<string>("POThresoldToEmail"));
                if (bussinessUnit.ToLower() == "cooling")
                {
                    if (islabour)
                    {
                        body = $"<strong>Usage Alert For Cooling Labour PO:</strong><br/><br/>" +
                          $"- AMC Remaining Amount: <strong>₹{purchaseOrder.AVAILABLE_LABOR_AMC_AMT}</strong> out of the Actual <strong>₹{purchaseOrder.LABOR_AMC_AMT}</strong>. " +
                          $"Usage has reached the threshold of {thresoldPercentage}%.\n <br/><br/>" +
                          $"- Warranty Remaining Amount: <strong>₹{purchaseOrder.AVAILABLE_LABOR_WARRANTY_AMT}</strong> out of the Actual <strong>₹{purchaseOrder.LABOR_WARRANTY_AMT}</strong>. " +
                          $"Usage has reached the threshold of {thresoldPercentage}%.\n\n <br/><br/>" +
                          $"Please take necessary action as one or both amounts have exceeded the defined usage threshold.";
                    }
                    else
                    {
                        body = $"<strong>Usage Alert For Cooling Supply PO:</strong><br/><br/>" +
                         $"- AMC Remaining Amount: <strong>₹{purchaseOrder.AVAILABLE_SUPPLY_AMC_AMT}</strong> out of the Actual <strong>₹{purchaseOrder.SUPPLY_AMC_AMT}</strong>. " +
                         $"Usage has reached the threshold of {thresoldPercentage}%.\n <br/><br/>" +
                         $"- Warranty Remaining Amount: <strong>₹{purchaseOrder.AVAILABLE_SUPPLY_WARRANTY_AMT}</strong> out of the Actual <strong>₹{purchaseOrder.SUPPLY_WARRANTY_AMT}</strong>. " +
                         $"Usage has reached the threshold of {thresoldPercentage}%.\n\n <br/><br/>" +
                         $"Please take necessary action as one or both amounts have exceeded the defined usage threshold.";
                    }
                }
                if (bussinessUnit.ToLower() == "ppi")
                {
                    body = $"<strong>Usage Alert For PPI PO:</strong><br/><br/>\n" +
                             $"- Remaining Amount: <strong>₹{purchaseOrder.AVAILABLE_BASIC_AMT}</strong> out of the Actual <strong>₹{purchaseOrder.BASIC_AMT}</strong>. " +
                             $"Usage has reached the threshold of {thresoldPercentage}%.\n <br/><br/>" +
                             $"Please take necessary action as one or both amounts have exceeded the defined usage threshold.";
                }
                if (bussinessUnit.ToLower() == "hbn")
                {
                    body = $"<strong>Usage Alert For HBN PO:</strong><br/><br/>\n" +
                          $"- AMC Remaining Amount: <strong>₹{purchaseOrder.AVAILABLE_HBN_AMC_AMT}</strong> out of the Actual <strong>₹{purchaseOrder.HBN_AMC_AMT}</strong>. " +
                          $"Usage has reached the threshold of {thresoldPercentage}%.<br/><br/>\n" +
                          $"- Warranty Remaining Amount: <strong>₹{purchaseOrder.AVAILABLE_HBN_WARRANTY_AMT}</strong> out of the Actual <strong>₹{purchaseOrder.HBN_WARRANTY_AMT}</strong>. " +
                          $"Usage has reached the threshold of {thresoldPercentage}%.<br/><br/>" +
                          $"Please take necessary action as one or both amounts have exceeded the defined usage threshold.";
                }

                Email.SendEmail(_config, _logger, emailSubject, body, toEmail: toEmail, ccEmail: ccEmail);
                _logger.LogInformation($"Email Sent successfully for central user for PO thresold");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogInformation($"call get exception SendPOThresoldEmail.");
                return false;
                throw ex;
            }
        }
        private IEnumerable<long> GetValidPreviousStatuses(int newStatus, bool cssValidateWithAllWorkOrder)
        {
            switch (newStatus)
            {
                case (int)StatusType.Central_Approved:
                case (int)StatusType.Central_Rejected:
                    return new[] { (long)StatusType.Imported };

                case (int)StatusType.CSS_Validated:
                case (int)StatusType.CSS_Discrepancy:
                    return new[] { (long)StatusType.Central_Approved, (long)StatusType.CSS_MGR_Approved, !cssValidateWithAllWorkOrder ? (long)StatusType.CSS_MGR_Discrepancy : -1 };

                case (int)StatusType.CSS_MGR_Discrepancy:
                case (int)StatusType.CSS_MGR_Approve_Discrepancy:
                    return new[] { (long)StatusType.CSS_Approved, (long)StatusType.CSS_Discrepancy };

                case (int)StatusType.CSS_Approved:
                    return new[] { (long)StatusType.CSS_Validated, (long)StatusType.CSS_MGR_Approve_Discrepancy };

                case (int)StatusType.CSS_MGR_Approved:
                    return new[] { (long)StatusType.CSS_Approved };

                default:
                    return Enumerable.Empty<long>();
            }
        }

        private string GeneratePRFNo(string cssCode, DateTime currentDate, int indexOf, long? CssId = null)
        {
            string prfNos = null;
            if (CssId == null)
            {
                prfNos = _context.SE_CSS_Invoice.Select(invoice => invoice.PRF_No).FirstOrDefault();
            }
            else
            {
                prfNos = _context.SE_CSS_Invoice.Where(x => x.CSS_Id == CssId).Select(invoice => invoice.PRF_No).FirstOrDefault();
            }

            int lastPrfNumber = 0;

            if (!string.IsNullOrEmpty(prfNos))
            {
                var parts = prfNos.Split('-');
                if (parts.Length == 3 && int.TryParse(parts[2], out int parsed))
                {
                    lastPrfNumber = parsed;
                }
            }

            // 2. Get the work orders for the CSS ID
            var currentYearSuffix = currentDate.Year % 100;

            // 3. Generate PRF numbers
            var prfList = $"{cssCode}-{currentYearSuffix:D2}-{(lastPrfNumber + 1).ToString().PadLeft(5, '0')}";

            return prfList;
            //var prfNo = prfNos.Select(prf => GetRightPart(prf)).FirstOrDefault();
            //prfNo = prfNo ?? "0";
            //var test = workOrders
            //                        .OrderBy(a => a.CSS_Id)
            //                         .Select((a, index) => new
            //                         {
            //                             PRF_No = $"{a.CSS.CSS_Code}-{currentDate.Year % 100}-{(index + 2).ToString().PadLeft(5, '0')}"
            //                         })
            //                         .ToList();

            //return $"{cssCode}-{currentDate.Year % 100}-{(prfNo + indexOf + 1).ToString().PadLeft(5, '0')}";
        }

        public IEnumerable<SE.API.Models.PrevMonthWO> GetPreviousMonthsWO()
        {
            try
            {
                List<PrevMonthWO> monthWOs = new List<PrevMonthWO>();
                DbConnection conn = _context.Database.GetDbConnection();
                try
                {
                    if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }

                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "usp_GetPreviousMonthWOCount";
                        cmd.CommandType = CommandType.StoredProcedure;
                        var reader = cmd.ExecuteReader();
                        while (reader.Read())
                        {
                            PrevMonthWO data = new PrevMonthWO();

                            data.MonthName = reader.GetValue(0).ToString();
                            data.TotalWorkOrders = Convert.ToInt64(reader.GetValue(1).ToString());
                            data.HBNWorkOrders = Convert.ToInt64(reader.GetValue(2).ToString());
                            data.PPIWorkOrders = Convert.ToInt64(reader.GetValue(3).ToString());
                            data.CoolingWorkOrders = Convert.ToInt64(reader.GetValue(4).ToString());
                            data.LoadedDate = Convert.ToDateTime(reader.GetValue(5).ToString());
                            data.WoProcessStatus = Convert.ToInt64(reader.GetValue(6).ToString());
                            monthWOs.Add(data);
                        }
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
                }
                return monthWOs;
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        public PagedList<WorkOrder> GetWorkOrderList(WorkOrderResourceParameter workOrderResourceParameter)
        {
            try
            {
                var collection = _context.SE_Work_Order as IQueryable<WorkOrder>;
                if (!string.IsNullOrEmpty(workOrderResourceParameter.WorkOrderNumber))
                {
                    collection = collection.Where(u => u.Work_Order_Number == workOrderResourceParameter.WorkOrderNumber);

                }
                if (workOrderResourceParameter.CSSIds?.Count() > 0)
                {
                    collection = collection.Where(u => workOrderResourceParameter.CSSIds.Contains(u.CSS_Id));
                }
                if (!string.IsNullOrEmpty(workOrderResourceParameter.Month))
                {
                    collection = collection.Where(u => u.Month_Name.Trim().ToLower() == workOrderResourceParameter.Month.Trim().ToLower()
                        && !string.IsNullOrEmpty(u.Month_Name));
                }
                if (!string.IsNullOrEmpty(workOrderResourceParameter.BusinessUnit))
                {
                    collection = collection.Where(u => u.WO_BusinessUnit == workOrderResourceParameter.BusinessUnit);
                }
                collection = collection.Include(u => u.CSS);

                if (workOrderResourceParameter.Statuses?.Count() > 0)
                {
                    collection = collection.Where(u => workOrderResourceParameter.Statuses.Contains(u.WO_Process_Status.ToString()));
                }
                if (workOrderResourceParameter.UserType != ((int)UserType.CentralUser))
                {

                    collection = collection.Where(u => u.WO_Process_Status >= 0);
                }
                if ((workOrderResourceParameter.InvId ?? -1) != -1)
                {
                    collection = collection.Where(u => u.INV_ID == workOrderResourceParameter.InvId || u.SUPPLY_INV_ID == workOrderResourceParameter.InvId);
                }
                return PagedList<WorkOrder>.Create(collection, workOrderResourceParameter.PageNumber,
                workOrderResourceParameter.PageSize);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool ExcelImport(string fileName, string tableName, IConfiguration config, ILogger _logger)
        {
            _logger.LogInformation("In-excel import");
            try
            {
                IExcelImportRepository excelImport = new ExcelImportRepository(_context);
                bool isuAtoDitanceRun = Convert.ToBoolean(config["newEnhancement:IsAutoDistanceRun"]);
                if (tableName.Equals("RAW_DUMP_Expense") && isuAtoDitanceRun)
                {
                    _logger.LogInformation("New Enhancement Auto Distance Run!!!!!");
                    return excelImport.RawDumpImportFile(fileName, tableName, config, _logger);
                }
                else
                {
                    _logger.LogInformation("Old Distance Run!!!!!");
                    return excelImport.ImportFile(fileName, tableName, config, _logger);
                }


            }
            catch (Exception exception)
            {
                throw exception;

            }
        }

        public IEnumerable<CSS> GetCSS(CSSResourceParameter cssParams)
        {
            try
            {
                var collection = _context.SE_CSS_Master as IQueryable<CSS>;
                if (!string.IsNullOrEmpty(cssParams.CSSManagerId))
                {
                    collection = collection.Where(u => u.CSS_MGR_USER_ID == cssParams.CSSManagerId);
                }

                if (!string.IsNullOrEmpty(cssParams.FINUserId))
                {
                    collection = collection.Where(u => u.INV_FIN_USER_ID == cssParams.FINUserId);

                }
                if (!string.IsNullOrEmpty(cssParams.GRNUserId))
                {
                    collection = collection.Where(u => u.GRN_USER_ID == cssParams.GRNUserId);

                }
                if (!string.IsNullOrEmpty(cssParams.CSSId))
                {
                    collection = collection.Where(u => u.Id.ToString() == cssParams.CSSId);
                }
                if (!string.IsNullOrEmpty(cssParams.UserEmail))
                {
                    collection = collection.Where(u => u.Authorised_UserEmail.ToLower().Contains(cssParams.UserEmail.ToLower().Trim()));
                }
                //collection = collection.Include(u => u.WorkOrders);
                return collection.ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public IEnumerable<CSS> GetCSSWithWorkOrderByMonth(CSSResourceParameter cssParams)
        {
            try
            {
                List<string> lstStatus = new List<string>();
                lstStatus.Add(((Int32)StatusType.CSS_Approved).ToString());
                lstStatus.Add(((Int32)StatusType.CSS_Discrepancy).ToString());

                var collection = _context.SE_CSS_Master as IQueryable<CSS>;
                collection = collection.Include(u => u.WorkOrders);
                if (!string.IsNullOrEmpty(cssParams.CSSManagerId))
                {
                    collection = collection.Where(u => u.CSS_MGR_USER_ID == cssParams.CSSManagerId);
                }

                if (!string.IsNullOrEmpty(cssParams.FINUserId))
                {
                    collection = collection.Where(u => u.INV_FIN_USER_ID == cssParams.FINUserId);
                }
                if (!string.IsNullOrEmpty(cssParams.GRNUserId))
                {
                    collection = collection.Where(u => u.GRN_USER_ID == cssParams.GRNUserId);

                }

                //collection = collection.Where(u => u.WorkOrders.Any(u => u.WO_BusinessUnit == cssParams.BusinessUnit
                //    && u.Month_Name == cssParams.Month));

                List<CSS> lst = collection.ToList();


                lst = lst.Select(x => new CSS()
                {
                    Id = x.Id,
                    Region = x.Region,
                    CSS_Code = x.CSS_Code,
                    CSS_Name_in_bFS_to_be_referred = x.CSS_Name_in_bFS_to_be_referred,
                    CSS_Name_as_per_Oracle_SAP = x.CSS_Name_as_per_Oracle_SAP,
                    Vendor_Code = x.Vendor_Code,
                    Email_ID = x.Email_ID,
                    Business_Unit = x.Business_Unit,
                    City_Location = x.City_Location,
                    Primary_Contact_Person = x.Primary_Contact_Person,
                    Phone_Number = x.Phone_Number,
                    Grade = x.Grade,
                    Base_Payout_Percentage = x.Base_Payout_Percentage,
                    Incentive_Percentage = x.Incentive_Percentage,
                    CSS_Manager = x.CSS_Manager,
                    WorkOrders = x.WorkOrders.Where(u => u.Month_Name == cssParams.Month && u.WO_BusinessUnit == cssParams.BusinessUnit && lstStatus.Contains(u.WO_Process_Status.ToString()))
                }).Where(u => u.WorkOrders.Count() > 0).ToList();

                return lst;

            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public IEnumerable<Invoice> GetInvoiceList(InvoiceResourceParameter invParams, int? userType = null)
        {
            try
            {
                var collection = _context.SE_CSS_Invoice as IQueryable<Invoice>;

                if (invParams.CSSIds?.Count() > 0)
                {
                    collection = collection.Where(u => invParams.CSSIds.Contains(u.CSS_Id));
                }
                if (!string.IsNullOrEmpty(invParams.BusinessUnit))
                {
                    collection = collection.Where(u => u.WO_BusinessUnit == invParams.BusinessUnit);
                }
                if (!string.IsNullOrEmpty(invParams.InvNo))
                {
                    collection = collection.Where(u => u.Inv_No.ToLower().Trim() == invParams.InvNo.Trim().ToLower());
                }
                if ((invParams.InvId ?? -1) != -1)
                {
                    collection = collection.Where(u => u.Id == (invParams.InvId ?? -1));
                }

                if (!string.IsNullOrWhiteSpace(invParams.Month_Name))
                {
                    collection = collection.Where(u => u.Month_Name == invParams.Month_Name);
                }

                collection = collection.Include(u => u.CSS);
                collection = collection.Include(u => u.InvoiceDetails);
                collection = collection.Include(u => u.PurchaseOrder);
                //collection = collection.Include(u => u.WorkOrders

                //collection = collection.Include(u => u.WorkOrders)
                //           .ThenInclude(wo => wo.WorkOrderStatuses);

                if (userType == (int)UserType.FinanceUser)
                {
                    collection = collection.Include(u => u.WorkOrders)
                              .ThenInclude(wo => wo.WorkOrderStatuses);
                }
                else
                {
                    collection = collection.Include(u => u.WorkOrders);
                }
                //collection = collection.Include(u => u.SupplyWorkOrders);


                if (invParams.Statuses?.Count() > 0)
                {
                    collection = collection.Where(u => invParams.Statuses.Contains(u.Status_Type.ToString()));
                }


                return collection.OrderBy(u => u.Status_Type).ThenByDescending(u => u.Id).ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public IEnumerable<Invoice> GetNoDueInvoiceList(InvoiceResourceParameter invParams)
        {
            try
            {
                var collection = _context.SE_CSS_Invoice as IQueryable<Invoice>;

                if (invParams.CSSIds?.Count() > 0)
                {
                    collection = collection.Where(u => invParams.CSSIds.Contains(u.CSS_Id));
                }
                collection = collection.Where(u => u.Status_Type == (Int32)StatusType.Invoice_Paid);
                collection = collection.Where(u => !u.No_Due_Date.HasValue);

                collection = collection.Include(u => u.CSS);
                collection = collection.Include(u => u.InvoiceDetails);

                return collection.ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public bool SetNoDueInvoiceStatus(InvoiceUpdateResourceParameter invParams)
        {
            try
            {
                List<string> invIds = invParams.InvIds.Split(",").ToList();

                var collection = _context.SE_CSS_Invoice as IQueryable<Invoice>;
                collection = collection.Where(u => u.CSS_Id == invParams.CSSId);
                collection = collection.Where(u => invIds.Contains(u.Id.ToString()));
                collection = collection.Where(u => !u.No_Due_Date.HasValue);


                List<Invoice> lstInvoice = collection.ToList();
                foreach (Invoice inv in lstInvoice)
                {
                    //if (inv.CSS_Id == invParams.CSSId)
                    //{
                    //if (invIds.Contains(inv.Id.ToString()))
                    inv.No_Due_Date = invParams.NoDueDate ?? DateTime.Now;
                    _context.Update(inv);
                    //}
                }
                _context.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }

        public bool SetInvoicePaidStatus(InvoiceUpdateResourceParameter invParams)
        {
            try
            {
                DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
                try
                {
                    if (dbConnection.State.Equals((object)ConnectionState.Closed))
                        dbConnection.Open();
                    using (DbCommand command = dbConnection.CreateCommand())
                    {
                        command.CommandText = "usp_InvoicePaid";
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.Add((object)new SqlParameter("@Status", (object)invParams.StatusType));
                        command.Parameters.Add((object)new SqlParameter("@UserName", (object)invParams.UserName));
                        command.Parameters.Add((object)new SqlParameter("@BusinessUnit", (object)invParams.BusinessUnit));
                        command.Parameters.Add((object)new SqlParameter("@InvId", (object)invParams.InvId));
                        command.Parameters.Add((object)new SqlParameter("@CSSId", (object)invParams.CSSId));
                        command.Parameters.Add((object)new SqlParameter("@Remarks", (object)(invParams.Remarks ?? "")));
                        command.Parameters.Add((object)new SqlParameter("@PaymentDate", (object)(invParams.PaidDate ?? DateTime.Now)));
                        command.ExecuteNonQuery();
                        return true;
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    if (dbConnection.State.Equals((object)ConnectionState.Open))
                        dbConnection.Close();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool SetInvoicePaidStatus_Linq(List<InvoiceUpdateDetails> invoiceUpdateDetails, string userName)
        {

            DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
            bool returnValue = false;
            var strategy = _context.Database.CreateExecutionStrategy();

            strategy.Execute(() =>
            {


                if (dbConnection.State.Equals((object)ConnectionState.Closed))
                    dbConnection.Open();

                using (var transaction = _context.Database.BeginTransaction())
                {


                    try
                    {
                        string[] formats = { "dd-MM-yyyy HH:mm:ss", "MM/dd/yyyy", "yyyy-MM-dd" };
                        DateTime parsedDate;

                        foreach (InvoiceUpdateDetails invoice in invoiceUpdateDetails)
                        {
                            int currentStatus = new int?(invoice.Status.ToLower() == "paid" ? 15 : 0) ?? 0;

                            if (currentStatus == (int)StatusType.Invoice_Paid)
                            {
                                var invoiceToUpdate = _context.SE_CSS_Invoice
                                                 .FirstOrDefault(i => i.Id == invoice.InvoiceId &&
                                                 i.CSS_Id == invoice.CssId &&
                                                 i.WO_BusinessUnit == invoice.BusinessUnit &&
                                                 i.Status_Type == (int)StatusType.GRN_Raised);

                                if (invoiceToUpdate != null)
                                {
                                    // Update invoice
                                    invoiceToUpdate.Status_Type = currentStatus;
                                    invoiceToUpdate.Payment_Process_Date = DateTime.Now;
                                    invoiceToUpdate.Remarks = "";
                                    invoiceToUpdate.Updated_User = userName;
                                    invoiceToUpdate.Updated_Date = DateTime.Now;
                                    invoiceToUpdate.INV_PAID_DATE =

                                    invoiceToUpdate.INV_PAID_DATE =
                                     DateTime.TryParseExact(invoice.PaidDate, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsedDate)
                                     ? parsedDate
                                     : DateTime.Now;


                                    _context.SE_CSS_Invoice.Update(invoiceToUpdate);

                                    // Insert into status table
                                    _context.SE_CSS_Invoice_Status.Add(new InvoiceStatus
                                    {
                                        Inv_Id = invoice.InvoiceId,
                                        Status_Type = currentStatus,
                                        Remarks = "",
                                        Updated_User = userName,
                                        Updated_Date = DateTime.Now
                                    });

                                    // Insert into notification table

                                    var notification = (from a in _context.SE_CSS_Invoice
                                                        join b in _context.SE_CSS_Master on a.CSS_Id equals b.Id
                                                        where a.Id == invoice.InvoiceId
                                                        select new Notification
                                                        {
                                                            Status_Type = currentStatus,
                                                            Ref_No = a.Month_Name + "- Invoice",
                                                            Ref_Type = "",
                                                            CSS_Id = a.CSS_Id,
                                                            Remarks = $"The invoice {a.Inv_No} dated {a.Inv_Date:dd/MM/yyyy} for the month of {a.Month_Name} has been sent for payment.",
                                                            Action = "Invoice",
                                                            Created_User = "System",
                                                            Created_Date = DateTime.Now,
                                                            Expiry_Date = DateTime.Now.AddDays(5),
                                                            SUBJECT = "INVOICE PAID",
                                                            Body = $"The invoice {a.Inv_No} dated {a.Inv_Date:dd/MM/yyyy} for the month of {a.Month_Name} has been sent for payment.",
                                                            ToEmail = b.Email_ID
                                                        }).FirstOrDefault();

                                    _context.SE_Notification.Add(notification);
                                }
                            }
                        }

                        _context.SaveChanges();
                        transaction.Commit();
                        returnValue = true;
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        throw ex;
                    }
                    finally
                    {
                        if (dbConnection.State.Equals((object)ConnectionState.Open))
                            dbConnection.Close();
                    }
                }
            });
            return returnValue;
        }
        public bool SetInvoiceStatus(InvoiceUpdateResourceParameter invParams)
        {
            try
            {
                DbConnection conn = _context.Database.GetDbConnection();
                try
                {
                    if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }

                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "usp_InvoiceStatusUpdate";
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("@Status", invParams.StatusType));
                        cmd.Parameters.Add(new SqlParameter("@UserName", invParams.UserName));
                        cmd.Parameters.Add(new SqlParameter("@BusinessUnit", invParams.BusinessUnit));
                        cmd.Parameters.Add(new SqlParameter("@InvId", invParams.InvId));
                        cmd.Parameters.Add(new SqlParameter("@CSSId", invParams.CSSId));
                        cmd.Parameters.Add(new SqlParameter("@RefNo", invParams.RefNo ?? ""));
                        cmd.Parameters.Add(new SqlParameter("@RefDate", invParams.RefDate ?? DateTime.Now));
                        cmd.Parameters.Add(new SqlParameter("@InvAmount", invParams.InvAmount ?? 0M));
                        cmd.Parameters.Add(new SqlParameter("@InvAttachment", invParams.InvAttachment ?? ""));
                        cmd.Parameters.Add(new SqlParameter("@Remarks", invParams.Remarks ?? ""));
                        cmd.Parameters.Add(new SqlParameter("@NoDueDate", invParams.NoDueDate ?? DateTime.Now));
                        cmd.Parameters.Add(new SqlParameter("@PaymentDate", invParams.PaidDate ?? DateTime.Now));
                        cmd.ExecuteNonQuery();
                        return true;
                    }
                }
                catch (Exception)
                {
                    return false;
                }
                finally
                {
                    if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
                }
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }

        public IEnumerable<CurrentStatus> GetCurrentStatus(CurrentStatusResourceParameter currentParams)
        {
            try
            {
                DbConnection conn = _context.Database.GetDbConnection();
                Guid obj = Guid.NewGuid();
                try
                {
                    var Months = $"'{currentParams.MonthName}'";
                    if (!string.IsNullOrWhiteSpace(currentParams.StartMonthName) && !string.IsNullOrWhiteSpace(currentParams.EndMonthName))
                    {

                        List<string> monthsList = GenerateMonths(currentParams.StartMonthName, currentParams.EndMonthName);
                        Months = string.Join(",", monthsList);
                        //Months = $"'{currentParams.StartMonthName}','{currentParams.EndMonthName}'";
                    }

                    if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "usp_CurrentStatus";
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("@MonthName", Months));
                        cmd.Parameters.Add(new SqlParameter("@BusinessUnit", currentParams.BusinessUnit));
                        cmd.Parameters.Add(new SqlParameter("@CSSIds", string.Join(",", currentParams.CSSIds)));
                        cmd.Parameters.Add(new SqlParameter("@Gid", obj.ToString()));


                        cmd.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
                }
                List<CurrentStatus> currentStatuses = _context.SE_CurrentStatus.Where(u => u.Gid == obj.ToString()).ToList();

                return currentStatuses;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        public static List<string> GenerateMonths(string start, string end)
        {
            DateTime startDate = DateTime.ParseExact(start, "MMMM-yyyy", CultureInfo.InvariantCulture);
            DateTime endDate = DateTime.ParseExact(end, "MMMM-yyyy", CultureInfo.InvariantCulture);

            List<string> months = new List<string>();
            DateTime currentDate = startDate;

            while (currentDate <= endDate)
            {
                months.Add($"'{currentDate.ToString("MMMM-yyyy")}'");
                currentDate = currentDate.AddMonths(1);
            }

            return months;
        }

        public IEnumerable<ApprovedData> GetApprovedData(ApprovedDataResourceParameter currentParams)
        {
            try
            {
                DbConnection conn = _context.Database.GetDbConnection();
                Guid obj = Guid.NewGuid();
                try
                {
                    if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "usp_ApprovedData";
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("@finUserId", currentParams.FinUserId ?? "-1"));
                        cmd.Parameters.Add(new SqlParameter("@businessUnit", currentParams.BusinessUnit));
                        cmd.Parameters.Add(new SqlParameter("@monthName", currentParams.MonthName));
                        cmd.Parameters.Add(new SqlParameter("@gid", obj.ToString()));


                        cmd.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
                }
                //List<ApprovedData> approvedData = _context.SE_CSS_Approved_Data.Where(u => u.Gid == obj.ToString()).Include(u => u.WorkOrders).ToList();
                List<ApprovedData> approvedData = _context.SE_CSS_Approved_Data.Where(u => u.Gid == obj.ToString()).ToList();

                return approvedData;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public IEnumerable<Notification> GetNotification(NotificationResourceParameter notifyParams)
        {
            var collection = _context.SE_Notification as IQueryable<Notification>;
            if (notifyParams.IsEmail != "yes")
            {
                if ((notifyParams.CSSId ?? -1) != -1)
                {
                    collection = collection.Where(u => u.CSS_Id == notifyParams.CSSId);
                }
                else if (!string.IsNullOrEmpty(notifyParams.UserType))
                {
                    collection = collection.Where(u => u.User_Type == notifyParams.UserType);
                }
                else if (!string.IsNullOrEmpty(notifyParams.UserId))
                {
                    collection = collection.Where(u => u.User_Id == notifyParams.UserId);
                }
                else // if nothing then dont select any
                {
                    collection = collection.Where(u => u.Id != u.Id);
                }
            }
            else
            {
                collection = collection.Where(u => !u.Email_Date.HasValue && !string.IsNullOrEmpty(u.ToEmail.Trim()));
            }
            collection = collection.Where(u => u.Expiry_Date > DateTime.Now);
            return collection.OrderByDescending(u => u.Created_Date).ToList();
        }

        public bool SendCollectorEmail(long invId, ILogger _logger, IConfiguration _config)
        {
            List<Invoice> lstInvoice = new List<Invoice>();
            try
            {
                _logger.LogInformation($"call started SendCollectorEmail on inv:- ${invId}");
                var fileName = "Invoice-" + invId.ToString() + ".pdf";
                var folderPath = _config.GetSection("ExcelImport").GetValue<String>("Folder");
                var uploadFolderPath = _config.GetSection("ExcelImport").GetValue<String>("UploadFolderAPI");

                var emailSubject = "Details of Invoice __INVNO__ for CSS __CSSCODE__ ";
                string body = "Please find attachment of PRF & Work Order details for the Invoice __INVNO__ raised by __CSSCODE__ - __CSSNAME__ to process the partner payment.";
                string str = "Please find attachment of Invoice __INVNO__ raised by __CSSCODE__ - __CSSNAME__ to process the partner payment.";
                //var emailBody = "Please find attached the Work Order details for Invoice __INVNO__ raised by __CSSCODE__ - __CSSNAME__.";
                var collectorEmail = "";
                var ccEmail = "";
                byte[] pdfBytes = null;
                byte[] pdfBytes2 = null;
                byte[] excelbytes = null;
                lstInvoice = GetInvoiceList(new InvoiceResourceParameter() { InvId = invId }).ToList();
                if (lstInvoice.Count() > 0)
                {
                    emailSubject = emailSubject.Replace("__CSSCODE__", lstInvoice.First().CSS.CSS_Code).Replace("__INVNO__", lstInvoice.First().Inv_No);
                    body = body.Replace("__CSSCODE__", lstInvoice.First().CSS.CSS_Code).Replace("__INVNO__", lstInvoice.First().Inv_No).Replace("__CSSNAME__", lstInvoice.First().CSS.CSS_Name_as_per_Oracle_SAP);

                    if (lstInvoice.First().WO_BusinessUnit.ToLower() == "cooling" || lstInvoice.First().WO_BusinessUnit.ToLower() == "hbn")
                    {
                        collectorEmail = _config.GetSection("Email").GetValue<String>("CollectorEmail_HBN_Cooling");
                        ccEmail = _config.GetSection("Email").GetValue<String>("CCEmail_HBN_Cooling");

                        var strHtml = GenerateCollectorHtml(lstInvoice, _config);
                        string pdfFilePath = folderPath + "/" + fileName;
                        GeneratePdf(strHtml, folderPath, fileName, _logger);
                        pdfBytes = System.IO.File.ReadAllBytes(pdfFilePath);

                        this.GenerateExcel(lstInvoice, folderPath, ref fileName);
                        excelbytes = System.IO.File.ReadAllBytes(folderPath + "/" + fileName);

                    }
                    else if (lstInvoice.First().WO_BusinessUnit.ToLower() == "ppi")
                    {
                        body = str.Replace("__CSSCODE__", lstInvoice.First().CSS.CSS_Code)
                           .Replace("__INVNO__", lstInvoice.First().Inv_No).Replace("__CSSNAME__", lstInvoice.First().CSS.CSS_Name_as_per_Oracle_SAP)
                        + GeneratePPIInvoice(lstInvoice);

                        collectorEmail = _config.GetSection("Email").GetValue<String>("CollectorEmail_PPI");
                        ccEmail = _config.GetSection("Email").GetValue<String>("CCEmail_PPI");
                    }


                    string pdfFilePath2 = folderPath + "/" + lstInvoice.First()?.Inv_Attachment;
                    string pdfUploadFilePath2 = uploadFolderPath + "/" + lstInvoice.First()?.Inv_Attachment;
                    if (System.IO.File.Exists(pdfFilePath2))
                    {
                        pdfBytes2 = System.IO.File.ReadAllBytes(pdfFilePath2);
                        _logger.LogInformation($"Path is Exists for PDF 2: ${pdfFilePath2}");
                    }
                    else if (System.IO.File.Exists(pdfUploadFilePath2))
                    {
                        pdfBytes2 = System.IO.File.ReadAllBytes(pdfUploadFilePath2);
                        _logger.LogInformation($"Path is Exists for PDF 2: ${pdfUploadFilePath2}");
                    }
                    else
                    {
                        _logger.LogInformation($"Path is not Exists for PDF 2: ${pdfFilePath2} and ${pdfUploadFilePath2}");
                    }

                    bool isEmailSendToPartnerManager = _config.GetSection("Email").GetValue<bool?>("IsEmailSendToPartnerManager") ?? false;
                    if (isEmailSendToPartnerManager)
                    {
                        if (!string.IsNullOrWhiteSpace(lstInvoice.FirstOrDefault()?.CSS.CSS_Manager_Email_ID))
                        {
                            if (string.IsNullOrWhiteSpace(ccEmail))
                            {
                                ccEmail = lstInvoice.FirstOrDefault()?.CSS.CSS_Manager_Email_ID;
                            }
                            else
                            {
                                ccEmail = $"{ccEmail},{lstInvoice.FirstOrDefault()?.CSS.CSS_Manager_Email_ID}";
                            }
                        }
                        else
                        {
                            _logger.LogInformation($"There were no any css manager email exist: ${lstInvoice.FirstOrDefault()?.Id}");
                        }
                    }
                }

                Email.SendEmail(_config, emailSubject, body, pdfBytes, "InvoiceWorkOrders", pdfBytes2, "CSS_Invoice", excelbytes, collectorEmail, ccEmail);
                _logger.LogInformation($"Email Sent successfully for __INVNO__ {lstInvoice.First().Inv_No} __CSSCODE__  {lstInvoice.First().CSS.CSS_Code}  toemail__{collectorEmail}  ccemails__{ccEmail}");
                UpdateInvoice(lstInvoice, true);
                return true;

            }
            catch (Exception ex)
            {
                _logger.LogInformation($"call get exception SendCollectorEmail on inv:- ${invId}");

                UpdateInvoice(lstInvoice, false);

                return false;
                throw ex;
            }
        }

        private string GenerateCollectorHtml(List<Invoice> lstInvoice, IConfiguration _config)
        {
            var collectorHtml = _config.GetSection("CollectorEmail").GetValue<String>("Template");
            var seLogo = _config.GetSection("CollectorEmail").GetValue<String>("SELogo");
            if (lstInvoice.Count > 0)
            {
                var strHead = "";
                var strWO = "";
                List<WorkOrder> lstWorkOrders = GetWorkOrderList(new WorkOrderResourceParameter() { InvId = lstInvoice.First().Id, Month = lstInvoice.First().Month_Name }).ToList();

                StringBuilder stringBuilder1 = new StringBuilder();
                foreach (Invoice invoice in lstInvoice)
                {
                    stringBuilder1.Append("<table width='95%' border='1'>");
                    stringBuilder1.Append("<tr>");
                    stringBuilder1.Append("<th align='left' colspan='7'><b>PAYMENT REQUEST</b></th>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr>");
                    stringBuilder1.Append("<td colspan='4' >");
                    stringBuilder1.Append("<div style='color:#00954B; font-size:21px; text-align:center;'><strong>Schneider Electric</strong></div>");
                    stringBuilder1.Append("</td>");
                    stringBuilder1.Append("<td colspan='3' align='left'>");
                    stringBuilder1.Append("<font face='sans-serif' size='1'>Schneider Electric ITBU India Pvt. Ltd.<br/>");
                    stringBuilder1.Append("Bearys Global Research Triangle( BGRT ),63/3B, Gorvigere Village,Bidarahalli Hobli<br/>Whitefield Ashram road,Bangalore – 560067</font>");
                    stringBuilder1.Append("</td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr>");
                    stringBuilder1.Append("<td colspan='4' ><font face='sans-serif' size='1'>From:</font></td>");
                    stringBuilder1.Append("<td colspan='3' ><font face='sans-serif' size='1'>To:<b>Finance</b>&nbsp;&nbsp;&nbsp;&nbsp;Control No:___________</font></td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr>");
                    stringBuilder1.Append("<td colspan='4' ><font face='sans-serif' size='1'>Cheque Payable to:<br/><b>" + invoice.CSS.CSS_Name_as_per_Oracle_SAP + "</b></font></td>");
                    stringBuilder1.Append("<td colspan='3' ><font face='sans-serif' size='1'>");
                    stringBuilder1.Append("Request Date  :" + DateTime.Now.ToString("dd/MM/yyyy") + "\t\t<br/>");
                    stringBuilder1.Append("Payment Amount:");
                    stringBuilder1.Append("DD /Payorder payable at(Place)");
                    stringBuilder1.Append("</font></td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr>");
                    stringBuilder1.Append("<td width='15%'><font face='sans-serif' size='1'><b>Inv.No.</b></font></td>");
                    stringBuilder1.Append("<td width='10%'><font face='sans-serif' size='1'><b>Date</b></font></td>");
                    stringBuilder1.Append("<td  width='10%'><font face='sans-serif' size='1'><b>Amount</b></font></td>");
                    stringBuilder1.Append("<td width='10%'><font face='sans-serif' size='1'><b>Amount with Tax</b></font></td>");
                    stringBuilder1.Append("<td width='15%' ><font face='sans-serif' size='1'><b>PO No.</b></font></td>");
                    stringBuilder1.Append("<td width='15%'><font face='sans-serif' size='1'><b>GRN</b></font></td>");
                    stringBuilder1.Append("<td  width='25%'><font face='sans-serif' size='1'><b>Remarks</b></font></td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr >");
                    stringBuilder1.Append("<td ><font face='sans-serif' size='1'>" + invoice.Inv_No + "</font></td>");
                    StringBuilder stringBuilder2 = stringBuilder1;
                    DateTime? invDate = invoice.Inv_Date;
                    ref DateTime? local = ref invDate;
                    string str = "<td ><font face='sans-serif' size='1'>" + (local.HasValue ? local.GetValueOrDefault().ToString("dd-MMM-yyyy") : (string)null) + "</font></td>";
                    stringBuilder2.Append(str);
                    stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + invoice.Inv_Amt.ToString() + "</font></td>");
                    stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + invoice.Inc_Tax_Amt.ToString() + "</font></td>");
                    stringBuilder1.Append("<td ><font face='sans-serif' size='1'>" + invoice?.PurchaseOrder?.PO_NO + "</font></td>");
                    stringBuilder1.Append("<td ><font face='sans-serif' size='1'>" + invoice.GRN_No + "</font></td>");
                    stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + invoice.Remarks + "</font></td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr >");
                    stringBuilder1.Append("<td >&nbsp;<br /></td>");
                    stringBuilder1.Append("<td >&nbsp;<br /></td>");
                    stringBuilder1.Append("<td>&nbsp;<br /></td>");
                    stringBuilder1.Append("<td>&nbsp;<br /></td>");
                    stringBuilder1.Append("<td >&nbsp;<br /></td>");
                    stringBuilder1.Append("<td >&nbsp;<br /></td>");
                    stringBuilder1.Append("<td>&nbsp;<br /></td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr >");
                    stringBuilder1.Append("<td >&nbsp;<br /></td>");
                    stringBuilder1.Append("<td >&nbsp;<br /></td>");
                    stringBuilder1.Append("<td>&nbsp;<br /></td>");
                    stringBuilder1.Append("<td>&nbsp;<br /></td>");
                    stringBuilder1.Append("<td >&nbsp;<br /></td>");
                    stringBuilder1.Append("<td >&nbsp;<br /></td>");
                    stringBuilder1.Append("<td>&nbsp;<br /></td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr >");
                    stringBuilder1.Append("<td><font face='sans-serif' size='1'><b>Total: &nbsp;</b></font></td>");
                    stringBuilder1.Append("<td >&nbsp;</td>");
                    stringBuilder1.Append("<td><font face='sans-serif' size='1'><b>" + invoice.Inv_Amt.ToString() + "</b></font></td>");
                    stringBuilder1.Append("<td><font face='sans-serif' size='1'><b>" + invoice.Inc_Tax_Amt.ToString() + "</b></font></td>");
                    stringBuilder1.Append("<td >&nbsp;</td>");
                    stringBuilder1.Append("<td >&nbsp;</td>");
                    stringBuilder1.Append("<td>&nbsp;</td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr>");
                    stringBuilder1.Append("<td align='left' colspan='7' style='padding:0'><b>Approver List :</b></td>");
                    stringBuilder1.Append("<tr>");
                    stringBuilder1.Append("<td colspan='7' style='padding:0'>");
                    stringBuilder1.Append("<table width='100%' style='border-collapse: collapse;'");
                    stringBuilder1.Append("<tr>");
                    stringBuilder1.Append("<td colspan='2' style='padding:0'><font face='sans-serif' size='2'><b>PARTNER MANAGER</b><br>");
                    stringBuilder1.Append(invoice.CSS.CSS_Manager + " <br>" + invoice.PRF_Gen_Date.ToString() + "</font></td>");
                    stringBuilder1.Append("<td colspan='2' style='padding:0'><font face='sans-serif' size='2'><b>FINANCE</b><br>");
                    stringBuilder1.Append(invoice.CSS.Invoice_Validator_from_Finance_Team + "<br>" + invoice.FIN_APPROVE_DATE.ToString() + "</font></td>");
                    stringBuilder1.Append("<td colspan='2' style='padding:0'><font face='sans-serif' size='2'><b>REQUESTER</b><br>");
                    stringBuilder1.Append(ConfigurationBinder.GetValue<string>((IConfiguration)_config.GetSection("ApproverList"), "Requestor") + "<br>" + invoice.GRN_Date.ToString() + "</ font ></ td > ");
                    stringBuilder1.Append("<td colspan='2' style='padding:0'><font face='sans-serif' size='2'><b>APPROVED BY</b><br>");
                    stringBuilder1.Append(ConfigurationBinder.GetValue<string>((IConfiguration)_config.GetSection("ApproverList"), "ApprovedBy") + "<br>" + invoice.GRN_Date.ToString() + "</font></td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("</table>");
                    stringBuilder1.Append("</td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("<tr>");
                    stringBuilder1.Append("<td colspan='7' style='padding:0'><font face='sans-serif' size='15px'>Note : This document generated by Sandhi Application. No signature required.</font></td>");
                    stringBuilder1.Append("</tr>");
                    stringBuilder1.Append("</table><Br/><br/><br/><br/><br/><br/>");

                    var i = 1;
                    stringBuilder1.Append("<table width='100%' cellpadding='2' cellspacing='2'><tr><th bgcolor='#bbb'>WO Number</th><th bgcolor='#bbb'>Month</th><th  bgcolor='#bbb'>CSS Code</th><th  bgcolor='#bbb'>Partner Account</th><th bgcolor='#bbb'>Claim Type</th><th bgcolor='#bbb'>Labour Cost</th><th bgcolor='#bbb'>Supply Cost</th><th bgcolor='#bbb'>Claim</th></tr>");

                    foreach (WorkOrder workOrder in lstWorkOrders)
                    {
                        if (i % 2 == 0)
                        {
                            stringBuilder1.Append("<tr bgcolor='#eee'>");
                        }
                        else
                        {
                            stringBuilder1.Append("<tr>");
                        }
                        stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + workOrder.Work_Order_Number + "</font></td>");
                        stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + workOrder.Month_Name + "</font></td>");
                        stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + (workOrder.CSS.CSS_Code ?? "") + "</font></td>");
                        stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + workOrder.Installed_At_Account + "</font></td>");
                        stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + (workOrder.Claim_Type ?? "") + "</font></td>");
                        stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + workOrder.LABOUR_COST + "</font></td>");
                        stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + workOrder.SUPPLY_COST + "</font></td>");
                        stringBuilder1.Append("<td><font face='sans-serif' size='1'>" + workOrder.Claim + "</font></td>");
                        stringBuilder1.Append("</tr>");
                        i++;
                    }
                    stringBuilder1.Append("</table>");
                }
                collectorHtml = collectorHtml.Replace("___BODY___", stringBuilder1.ToString());
            }
            return collectorHtml;
        }

        private void GenerateExcel(List<Invoice> lstInvoice, string folderPath, ref string fileName)
        {
            IEnumerable<ProductCategoryCooling> productCategoryCoolings = new List<ProductCategoryCooling>();
            fileName = "Invoice-" + lstInvoice.First<Invoice>().Id.ToString() + ".xlsx";
            if (lstInvoice.Count <= 0)
                return;
            List<WorkOrder> list = this.GetWorkOrderList(new WorkOrderResourceParameter()
            {
                InvId = new long?(lstInvoice.First<Invoice>().Id),
                Month = lstInvoice.First<Invoice>().Month_Name
            }).ToList<WorkOrder>();
            if (lstInvoice.First<Invoice>().WO_BusinessUnit == "Cooling")
            {
                productCategoryCoolings = GetProductCategoryCooling();

            }
            foreach (Invoice invoice in lstInvoice)
            {
                System.Data.DataTable dataTable = new System.Data.DataTable("WorkOrders");
                dataTable.Columns.Add("Work Order Number");
                dataTable.Columns.Add("Month");
                dataTable.Columns.Add("work Order Completed Date");
                dataTable.Columns.Add("Installed at Account");
                dataTable.Columns.Add("Work Order Type");
                dataTable.Columns.Add("Case *");
                dataTable.Columns.Add("First Assigned DateTime");
                dataTable.Columns.Add("Main Installed Product *");
                dataTable.Columns.Add("IP Serial Number");
                dataTable.Columns.Add("Work Order Sub-Type *");
                dataTable.Columns.Add("Completed On *");
                dataTable.Columns.Add("Work Order Reason");
                dataTable.Columns.Add("Product");
                dataTable.Columns.Add("Non Billing Reason *");
                dataTable.Columns.Add("Is Billable");
                dataTable.Columns.Add("Street");
                dataTable.Columns.Add("City");
                dataTable.Columns.Add("Zip");
                dataTable.Columns.Add("State");
                dataTable.Columns.Add("Service Team");
                dataTable.Columns.Add("Primary FSR *");
                dataTable.Columns.Add("Partner Account");
                dataTable.Columns.Add("Work Performed");
                dataTable.Columns.Add("Work Order Status *");
                dataTable.Columns.Add("Distance Slab");
                dataTable.Columns.Add("Actual Expense Converted");
                dataTable.Columns.Add("WO Completed Timestamp");
                dataTable.Columns.Add("Claim Type");
                if (lstInvoice.First<Invoice>().WO_BusinessUnit == "Cooling")
                {
                    dataTable.Columns.Add("Region");
                    dataTable.Columns.Add("Product Category");
                    dataTable.Columns.Add("Product Grouping");
                    dataTable.Columns.Add("Actual Expenses Gas");
                    dataTable.Columns.Add("Cooling Gas Work Description");
                    dataTable.Columns.Add("Cooling Supplies Work Description");
                    dataTable.Columns.Add("Labour");
                    dataTable.Columns.Add("Supply");
                    dataTable.Columns.Add("Total Labour and Supply");
                    dataTable.Columns.Add("CSS Reason");
                    dataTable.Columns.Add("CSS Reason Desc");
                    dataTable.Columns.Add("CSS Remark");
                    dataTable.Columns.Add("CSS Labour Cost");
                    dataTable.Columns.Add("CSS Supply Cost");
                    dataTable.Columns.Add("CSS Claim Cost");
                    dataTable.Columns.Add("CSS Manager Remark");
                    dataTable.Columns.Add("CSS Manager Approved Labour Cost");
                    dataTable.Columns.Add("CSS Manager Approved Supply Cost");
                    dataTable.Columns.Add("CSS Manager Approved Claim Cost");
                    dataTable.Columns.Add("Labour Cost");
                    dataTable.Columns.Add("Supply Cost");
                    dataTable.Columns.Add("Claim Amount");
                }
                else
                {
                    dataTable.Columns.Add("Branch Code");
                    dataTable.Columns.Add("Payout Type");
                    dataTable.Columns.Add("Region");
                    dataTable.Columns.Add("CSS Name");
                    dataTable.Columns.Add("CSS Code");
                    dataTable.Columns.Add("Material used");
                    dataTable.Columns.Add("Product Grouping");
                    dataTable.Columns.Add("System Generated Cost");
                    dataTable.Columns.Add("CSS Reason");
                    dataTable.Columns.Add("CSS Reason Desc");
                    dataTable.Columns.Add("CSS Remark");
                    dataTable.Columns.Add("Manager Remark");
                    dataTable.Columns.Add("Actual Cost");
                    dataTable.Columns.Add("Claim Amount");
                    dataTable.Columns.Add("Remarks");
                }
                if (list.Count > 0)
                {
                    foreach (WorkOrder workOrder in list)
                    {
                        var matchingProduct = productCategoryCoolings?.FirstOrDefault(p => p.Group == workOrder.Product_Grouping?.Trim());

                        DataRow dataRow = dataTable.NewRow();
                        dataRow[0] = (object)workOrder.Work_Order_Number;
                        dataRow[1] = (object)workOrder.Month_Name;
                        dataRow[2] = (object)(workOrder.WO_Created_Date_Time ?? string.Empty);
                        dataRow[3] = (object)workOrder.Installed_At_Account;
                        dataRow[4] = (object)(workOrder.Work_Order_Type ?? string.Empty);
                        dataRow[5] = (object)(workOrder.Case ?? string.Empty);
                        dataRow[6] = (object)(workOrder.First_Assigned_DateTime ?? string.Empty);
                        dataRow[7] = (object)(workOrder.Main_Installed_Product ?? string.Empty);
                        dataRow[8] = (object)(workOrder.IP_Serial_Number ?? string.Empty);
                        dataRow[9] = (object)(workOrder.Work_Order_Sub_Type ?? string.Empty);
                        dataRow[10] = (object)(workOrder.Completed_On ?? string.Empty);
                        dataRow[11] = (object)(workOrder.Work_Order_Reason ?? string.Empty);
                        dataRow[12] = (object)(workOrder.Product ?? string.Empty);
                        dataRow[13] = (object)(workOrder.Non_Billing_Reason ?? string.Empty);
                        dataRow[14] = (object)(workOrder.Is_Billable ?? string.Empty);
                        dataRow[15] = (object)(workOrder.Street ?? string.Empty);
                        dataRow[16] = (object)(workOrder.City ?? string.Empty);
                        dataRow[17] = (object)(workOrder.Zip ?? string.Empty);
                        dataRow[18] = (object)(workOrder.State ?? string.Empty);
                        dataRow[19] = (object)(workOrder.Service_Team ?? string.Empty);
                        dataRow[20] = (object)(workOrder.Primary_FSR ?? string.Empty);
                        dataRow[21] = (object)(workOrder.Partner_Account ?? string.Empty);
                        dataRow[22] = (object)(workOrder.Work_Performed ?? string.Empty);
                        dataRow[23] = (object)(workOrder.Work_Order_Status ?? string.Empty);
                        dataRow[24] = (object)(workOrder.Distance_Slab ?? string.Empty);
                        dataRow[25] = (object)workOrder.Actual_Expense_converted.GetValueOrDefault();
                        dataRow[26] = (object)(workOrder.WO_Completed_Timestamp ?? string.Empty);
                        dataRow[27] = (object)(workOrder.Claim_Type ?? string.Empty);
                        if (invoice.WO_BusinessUnit == "Cooling")
                        {
                            dataRow[28] = (object)(workOrder.Region ?? string.Empty);
                            dataRow[29] = (object)(matchingProduct.Type ?? string.Empty);
                            dataRow[30] = (object)(workOrder.Product_Grouping ?? string.Empty);
                            dataRow[31] = (object)workOrder.Actual_Expenses_Gas;
                            dataRow[32] = (object)(workOrder.LABOUR_DESC ?? string.Empty);
                            dataRow[33] = (object)(workOrder.SUPPLY_DESC ?? string.Empty);
                            dataRow[34] = (object)workOrder.ACTUAL_LABOUR_COST;
                            dataRow[35] = (object)workOrder.ACTUAL_SUPPLY_COST;
                            dataRow[36] = (object)workOrder.Actual_Cost;
                            dataRow[37] = (object)(workOrder.CSS_Reason ?? string.Empty);
                            dataRow[38] = (object)(workOrder.CSS_Reason_Desc ?? string.Empty);
                            dataRow[39] = (object)(workOrder.CSS_Remark ?? string.Empty);
                            dataRow[40] = (object)workOrder.CSS_LABOUR_COST;
                            dataRow[41] = (object)workOrder.CSS_SUPPLY_COST;
                            dataRow[42] = (object)workOrder.CSS_Cost;
                            dataRow[43] = (object)(workOrder.CSS_Mgr_Remark ?? string.Empty);
                            dataRow[44] = (object)workOrder.CSS_Mgr_LABOUR_COST;
                            dataRow[45] = (object)workOrder.CSS_Mgr_SUPPLY_COST;
                            dataRow[46] = (object)workOrder.CSS_Mgr_Cost;
                            dataRow[47] = (object)workOrder.LABOUR_COST;
                            dataRow[48] = (object)workOrder.SUPPLY_COST;
                            dataRow[49] = (object)workOrder.Claim;
                        }
                        else
                        {
                            dataRow[28] = (object)(workOrder.Branch_Code ?? string.Empty);
                            dataRow[29] = (object)(workOrder.Payout_Type ?? string.Empty);
                            dataRow[30] = (object)(workOrder.Region ?? string.Empty);
                            dataRow[31] = (object)(lstInvoice.First<Invoice>().CSS.CSS_Name_as_per_Oracle_SAP ?? string.Empty);
                            dataRow[32] = (object)workOrder.CSS_Id;
                            dataRow[33] = (object)(workOrder.MaterialUsed ?? string.Empty);
                            dataRow[34] = (object)(workOrder.Product_Grouping ?? string.Empty);
                            dataRow[35] = (object)workOrder.CSS_Cost;
                            dataRow[36] = (object)(workOrder.CSS_Reason ?? string.Empty);
                            dataRow[37] = (object)(workOrder.CSS_Reason_Desc ?? string.Empty);
                            dataRow[38] = (object)(workOrder.CSS_Remark ?? string.Empty);
                            dataRow[39] = (object)(workOrder.CSS_Mgr_Remark ?? string.Empty);
                            dataRow[40] = (object)workOrder.Actual_Cost;
                            dataRow[41] = (object)workOrder.Claim;
                            dataRow[42] = (object)workOrder.Remarks;
                        }
                        dataTable.Rows.Add(dataRow);
                    }
                }
                using (XLWorkbook xlWorkbook = new XLWorkbook())
                {
                    xlWorkbook.Worksheets.Add(dataTable, "Work Orders");
                    xlWorkbook.SaveAs(folderPath + "/" + fileName);
                }
            }
        }

        private string GeneratePPIInvoice(List<Invoice> lstInvoice)
        {
            StringBuilder stringBuilder1 = new StringBuilder();
            stringBuilder1.Append("<br/><br/>");
            stringBuilder1.Append("<table width='100%' style='border: 1px solid black; border-spacing: 5; border-collapse: collapse'>");
            stringBuilder1.Append("<tr style='border: 1px solid black;'>");
            stringBuilder1.Append("<th style='border: 1px solid black;'>Vendor Code</th>");
            stringBuilder1.Append("<th style='border: 1px solid black;'>Vendor Name</th>");
            stringBuilder1.Append("<th style='border: 1px solid black;'>Invoice Number</th>");
            stringBuilder1.Append("<th style='border: 1px solid black;'>Invoice Date</th>");
            stringBuilder1.Append("<th style='border: 1px solid black;'>WH Location</th>");
            stringBuilder1.Append("<th style='border: 1px solid black;'>Invoice Amount</th>");
            stringBuilder1.Append("<th style='border: 1px solid black;'>Invoice with Tax Amount</th>");
            stringBuilder1.Append("<th style='border: 1px solid black;'>PO No</th>");
            stringBuilder1.Append("<th style='border: 1px solid black;'>GRN_No</th>");
            foreach (Invoice invoice in lstInvoice)
            {
                stringBuilder1.Append("<tr style='border: 1px solid black;'>");
                stringBuilder1.Append("<td style='border: 1px solid black;'><font face='sans-serif' size='1'>" + invoice.CSS.Vendor_Code + "</font></td>");
                stringBuilder1.Append("<td style='border: 1px solid black;'><font face='sans-serif' size='1'>" + (invoice.CSS.CSS_Name_as_per_Oracle_SAP ?? string.Empty) + "</font></td>");
                stringBuilder1.Append("<td style='border: 1px solid black;'><font face='sans-serif' size='1'>" + invoice.Inv_No + "</font></td>");
                stringBuilder1.Append("<td style='border: 1px solid black;'><font face='sans-serif' size='1'>" + (invoice.Inv_Date.ToString().Substring(0, 10) ?? string.Empty) + "</font></td>");
                stringBuilder1.Append("<td style='border: 1px solid black;'><font face='sans-serif' size='1'>" + (invoice.CSS.Region ?? string.Empty) + "</font></td>");
                StringBuilder stringBuilder2 = stringBuilder1;
                Decimal num = invoice.Inv_Amt;
                string str1 = "<td style='border: 1px solid black;'><font face='sans-serif' size='1'>" + num.ToString() + "</font></td>";
                stringBuilder2.Append(str1);
                StringBuilder stringBuilder3 = stringBuilder1;
                num = invoice.Inc_Tax_Amt;
                string str2 = "<td style='border: 1px solid black;'><font face='sans-serif' size='1'>" + num.ToString() + "</font></td>";
                stringBuilder3.Append(str2);
                stringBuilder1.Append("<td style='border: 1px solid black;'><font face='sans-serif' size='1'>" + invoice.PurchaseOrder.PO_NO + "</font></td>");
                stringBuilder1.Append("<td style='border: 1px solid black;'><font face='sans-serif' size='1'>" + invoice.GRN_No + "</font></td>");
                stringBuilder1.Append("</tr>");
            }
            stringBuilder1.Append("</table>");
            return stringBuilder1.ToString();
        }

        private void GeneratePdf(string htmlPdf, string folderPath, string fileName, ILogger _logger)
        {
            var pdfDoc = new iTextSharp.text.Document(iTextSharp.text.PageSize.A4, 10f, 10f, 10f, 0f);
            var htmlparser = new HTMLWorker(pdfDoc);
            using (var memoryStream = new MemoryStream())
            {
                var writer = PdfWriter.GetInstance(pdfDoc, memoryStream);
                pdfDoc.Open();

                htmlparser.Parse(new StringReader(htmlPdf));
                pdfDoc.Close();

                byte[] bytes = memoryStream.ToArray();
                try
                {
                    System.IO.File.WriteAllBytes(folderPath + "/" + fileName, bytes);
                }
                catch (Exception ex)
                {
                    _logger.LogError("Generate Pdf-" + ex.Message);
                }
                memoryStream.Close();
            }
        }

        //public IEnumerable<Gradation> GetGradation(GradationResourceParameter gradeParams)
        //{
        //    var collection = _context.SE_CSS_Gradation as IQueryable<Gradation>;
        //    collection = collection.Where(u =>gradeParams.CSSIds.Contains(u.Id));
        //    collection = collection.Include(u => u.GradationDetails);
        //    collection = collection.Include(u => u.CSS);
        //    collection = collection.OrderByDescending(u => u.Id);

        //    collection = collection.Where(u => u.Expiry_Date > DateTime.Now);
        //    return collection.ToList();
        //}


        public IEnumerable<CSS> GetGradation(GradationResourceParameter gradeParams)
        {
            try
            {
                var collection = _context.SE_CSS_Master as IQueryable<CSS>;
                if (gradeParams.CSSIds.Count > 0)
                {
                    collection = collection.Where(u => gradeParams.CSSIds.Contains(u.Id));
                }
                collection = collection.Include(u => u.Gradations).ThenInclude(u => u.GradationDetails);


                List<CSS> lst = collection.ToList();


                lst = lst.Select(x => new CSS()
                {
                    Id = x.Id,
                    Region = x.Region,
                    CSS_Code = x.CSS_Code,
                    CSS_Name_in_bFS_to_be_referred = x.CSS_Name_in_bFS_to_be_referred,
                    CSS_Name_as_per_Oracle_SAP = x.CSS_Name_as_per_Oracle_SAP,
                    Grade = x.Grade,
                    Vendor_Code = x.Vendor_Code,
                    Email_ID = x.Email_ID,
                    Business_Unit = x.Business_Unit,
                    City_Location = x.City_Location,
                    Primary_Contact_Person = x.Primary_Contact_Person,
                    Phone_Number = x.Phone_Number,
                    Gradations = x.Gradations.OrderByDescending(u => u.Id).Take(4)
                }).Where(u => u.Gradations.Count() > 0).ToList();

                return lst;

            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<bool> StartWOProcessAndImport(bool isJob = false)
        {
            try
            {
                Guid obj = Guid.NewGuid();
                DbConnection conn = _context.Database.GetDbConnection();
                try
                {
                    if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                    if (!isJob)
                    {
                        using (DbCommand cmd = conn.CreateCommand())
                        {
                            //cmd.CommandText = "SP_All_Start_Process_Rate_Mapping";
                            cmd.CommandTimeout = 500;
                            cmd.CommandText = "SP_InsertUpload";
                            cmd.Parameters.Add(new SqlParameter("@uploadType", "RAW DUMP UPLOAD"));
                            cmd.Parameters.Add(new SqlParameter("@gid", obj.ToString()));
                            cmd.CommandType = CommandType.StoredProcedure;
                            await cmd.ExecuteNonQueryAsync();

                        }
                    }
                    else
                    {
                        using (DbCommand cmd = conn.CreateCommand())
                        {
                            cmd.CommandText = "msdb.dbo.sp_start_job";
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add(new SqlParameter("@job_name", "StartProcessRateMapping"));
                            await cmd.ExecuteNonQueryAsync();
                        }
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
                }
                // check if upload erros have rows
                var collection = _context.SE_Upload_Errors as IQueryable<UploadErrors>;
                if (collection.Count() <= 0)
                {
                    return true;
                }
                else
                {
                    collection = collection.Where(u => u.Guid == obj.ToString());
                    List<UploadErrors> lstErrors = collection.ToList();
                    string strError = "";
                    if (lstErrors.Count() <= 0)
                    {
                        return true;
                    }
                    else
                    {
                        foreach (UploadErrors err in lstErrors)
                        {
                            strError += err.File_Name + "-" + err.Error_Information;
                        }
                        throw new Exception("Error in Import-" + strError);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }



        public async Task<bool> ImportPurchaseOrder()
        {
            try
            {
                DbConnection conn = _context.Database.GetDbConnection();
                try
                {
                    if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "usp_SEPurchaseOrderImport";
                        cmd.CommandType = CommandType.StoredProcedure;
                        await cmd.ExecuteNonQueryAsync();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<bool> CalculateGradation()
        {
            try
            {
                DbConnection conn = _context.Database.GetDbConnection();
                try
                {
                    if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "spSE_UpdateGradationDetails_Job";
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public bool SetNotificationStatus(NotificationResourceParameter notifyParams)
        {
            try
            {
                var collection = _context.SE_Notification as IQueryable<Notification>;
                collection = collection.Where(u => u.Id == notifyParams.NotificationId);
                var notifications = collection.ToList();
                foreach (Notification notify in notifications)
                {
                    notify.IsActive = false;
                    _context.Update(notify);
                    _context.SaveChanges();
                }
                return true;
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }


        public IEnumerable<ReportWorkOrderCount> GetWorkOrderCounts(ReportParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<ReportWorkOrderCount> reportWorkOrders = new List<ReportWorkOrderCount>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "spSE_GetWorkOrderCountReport";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@pFromDate", currentParams.FromDate));
                    cmd.Parameters.Add(new SqlParameter("@pToDate", currentParams.ToDate));
                    cmd.Parameters.Add(new SqlParameter("@pCSS_Id", currentParams.CssId));
                    cmd.Parameters.Add(new SqlParameter("@pRegion", currentParams.Region));
                    cmd.Parameters.Add(new SqlParameter("@pBusinessUnit", currentParams.BusinessUnit));
                    cmd.Parameters.Add(new SqlParameter("@cssManagerUserId", currentParams.CssMgrUserId));

                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        ReportWorkOrderCount workOrder = new ReportWorkOrderCount();
                        workOrder.Css_Id = reader.GetValue(0).ToString();
                        workOrder.Css_Code = reader.GetValue(1).ToString();
                        workOrder.CSS_Name = reader.GetValue(2).ToString();
                        workOrder.Region = reader.GetValue(3).ToString();
                        workOrder.Month_Name = reader.GetValue(4).ToString();
                        workOrder.Business_Unit = reader.GetValue(5).ToString();
                        workOrder.Warranty = Convert.ToInt32(reader.GetValue(6).ToString());
                        workOrder.AMC = Convert.ToInt32(reader.GetValue(7).ToString());
                        workOrder.NotCategorised = Convert.ToInt32(reader.GetValue(8).ToString());
                        workOrder.Total = Convert.ToInt32(reader.GetValue(9).ToString());

                        reportWorkOrders.Add(workOrder);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportWorkOrders;
        }



        public IEnumerable<ReportWorkOrderSemiDraft> GetWorkOrderSemiDraft(ReportParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<ReportWorkOrderSemiDraft> reportWorkOrders = new List<ReportWorkOrderSemiDraft>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "spSE_GetWorkOrderSemiDraftReport";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@pFromDate", currentParams.FromDate));
                    cmd.Parameters.Add(new SqlParameter("@pToDate", currentParams.ToDate));
                    cmd.Parameters.Add(new SqlParameter("@pCSS_Id", currentParams.CssId));
                    cmd.Parameters.Add(new SqlParameter("@pRegion", currentParams.Region));
                    cmd.Parameters.Add(new SqlParameter("@pBusinessUnit", currentParams.BusinessUnit));
                    cmd.Parameters.Add(new SqlParameter("@cssManagerUserId", currentParams.CssMgrUserId));

                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        ReportWorkOrderSemiDraft workOrder = new ReportWorkOrderSemiDraft();
                        workOrder.Css_Code = reader.GetValue(0).ToString();
                        workOrder.CSS_Name = reader.GetValue(1).ToString();
                        workOrder.Region = reader.GetValue(2).ToString();
                        workOrder.Month_Name = reader.GetValue(3).ToString();
                        workOrder.Business_Unit = reader.GetValue(4).ToString();
                        workOrder.WorkOrderCount = Convert.ToInt32(reader.GetValue(5).ToString());
                        workOrder.CSSValidatedCount = Convert.ToInt32(reader.GetValue(6).ToString());
                        workOrder.CSSApprovedCount = Convert.ToInt32(reader.GetValue(7).ToString());
                        workOrder.CSSDiscrepancyCount = Convert.ToInt32(reader.GetValue(8).ToString());
                        workOrder.CSSManagerApprovedDiscrepancyCount = Convert.ToInt32(reader.GetValue(9).ToString());

                        reportWorkOrders.Add(workOrder);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportWorkOrders;
        }

        public IEnumerable<ReportFinanceValidation> GetFinanceValidation(ReportParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<ReportFinanceValidation> reportData = new List<ReportFinanceValidation>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "spSE_GetFinanceValidationReport";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@pFromDate", currentParams.FromDate));
                    cmd.Parameters.Add(new SqlParameter("@pToDate", currentParams.ToDate));
                    cmd.Parameters.Add(new SqlParameter("@pCSS_Id", currentParams.CssId));
                    cmd.Parameters.Add(new SqlParameter("@pRegion", currentParams.Region));
                    cmd.Parameters.Add(new SqlParameter("@pBusinessUnit", currentParams.BusinessUnit));
                    cmd.Parameters.Add(new SqlParameter("@pFilterType", currentParams.ReportType));

                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        ReportFinanceValidation data = new ReportFinanceValidation();
                        data.Finance_Validator = reader.GetValue(0).ToString();
                        if (currentParams.ReportType == 'D')
                        {
                            data.Css_Code = reader.GetValue(1).ToString();
                            data.CSS_Name = reader.GetValue(2).ToString();
                        }
                        else
                        {
                            data.Css_Code = "";
                            data.CSS_Name = "";
                        }
                        data.Region = reader.GetValue(3).ToString();
                        data.Month_Name = reader.GetValue(4).ToString();
                        data.Business_Unit = reader.GetValue(5).ToString();
                        data.InvoiceCount = Convert.ToInt32(reader.GetValue(6).ToString());
                        data.AvgTATInHours = Convert.ToDecimal(reader.GetValue(7).ToString());

                        reportData.Add(data);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportData;
        }

        public IEnumerable<ReportNoDueCertificate> GetNoDueCertificate(ReportParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<ReportNoDueCertificate> reportData = new List<ReportNoDueCertificate>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "spSE_GetNoDueCertificateReport";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@pCSS_Id", currentParams.CssId));
                    cmd.Parameters.Add(new SqlParameter("@pRegion", currentParams.Region));
                    cmd.Parameters.Add(new SqlParameter("@pBusinessUnit", currentParams.BusinessUnit));

                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        ReportNoDueCertificate data = new ReportNoDueCertificate();
                        data.Css_Code = reader.GetValue(0).ToString();
                        data.CSS_Name = reader.GetValue(1).ToString();
                        data.Region = reader.GetValue(2).ToString();
                        data.LastNoDueDate = reader.GetValue(3).ToString();
                        data.LastNoDueMonths = reader.GetValue(4).ToString();
                        data.PendingMonths = reader.GetValue(5).ToString();
                        data.BusinessUnit = reader.GetValue(6).ToString();

                        reportData.Add(data);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportData;
        }

        public IEnumerable<ReportCSSInvoice> GetCSSInvoice(ReportParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<ReportCSSInvoice> reportData = new List<ReportCSSInvoice>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "spSE_GetCssMonthInvoiceReport";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@pFromDate", currentParams.FromDate));
                    cmd.Parameters.Add(new SqlParameter("@pToDate", currentParams.ToDate));
                    cmd.Parameters.Add(new SqlParameter("@pCSS_Id", currentParams.CssId));
                    cmd.Parameters.Add(new SqlParameter("@pRegion", currentParams.Region));
                    cmd.Parameters.Add(new SqlParameter("@pBusinessUnit", currentParams.BusinessUnit));

                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        ReportCSSInvoice data = new ReportCSSInvoice();
                        data.Css_Code = reader.GetValue(0).ToString();
                        data.CSS_Name = reader.GetValue(1).ToString();
                        data.Region = reader.GetValue(2).ToString();
                        data.Month_Name = reader.GetValue(3).ToString();
                        data.Business_Unit = reader.GetValue(4).ToString();
                        data.LabourAmount = Convert.ToDecimal(reader.GetValue(5).ToString());
                        data.SupplyAmount = Convert.ToDecimal(reader.GetValue(6).ToString());
                        data.InvoiceAmount = Convert.ToDecimal(reader.GetValue(7).ToString());

                        reportData.Add(data);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportData;
        }


        public IEnumerable<ReportWODiscrepency> GetWODiscrepency(ReportParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<ReportWODiscrepency> reportData = new List<ReportWODiscrepency>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "spSE_GetWorkOrderDiscrepencyReport";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@pFromDate", currentParams.FromDate));
                    cmd.Parameters.Add(new SqlParameter("@pToDate", currentParams.ToDate));
                    cmd.Parameters.Add(new SqlParameter("@pCSS_Id", currentParams.CssId));
                    cmd.Parameters.Add(new SqlParameter("@pRegion", currentParams.Region));
                    cmd.Parameters.Add(new SqlParameter("@pBusinessUnit", currentParams.BusinessUnit));

                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        ReportWODiscrepency data = new ReportWODiscrepency();

                        data.ReasonHeader = reader.GetValue(0).ToString();
                        data.Css_Code = reader.GetValue(1).ToString();
                        data.CSS_Name = reader.GetValue(2).ToString();
                        data.Month_Name = reader.GetValue(3).ToString();
                        data.Business_Unit = reader.GetValue(4).ToString();
                        data.Region = reader.GetValue(5).ToString();
                        data.WorkOrderCount = Convert.ToInt32(reader.GetValue(6).ToString());
                        data.ReasonCount = new List<int>();
                        for (int i = 7; i < reader.FieldCount; i++)
                        {
                            Int32 reasonVal = 0;
                            Int32.TryParse((reader.GetValue(i) ?? "0").ToString(), out reasonVal);

                            data.ReasonCount.Add(reasonVal);
                        }
                        reportData.Add(data);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportData;
        }


        public List<T> ExcelOrCSVDatas<T>(string fileName, IConfiguration config, ILogger _logger) where T : class, new()
        {
            try
            {

                return new ExcelImportRepository(this._context).ExcelOrCSVDatas<T>(fileName, config, _logger);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public IEnumerable<string> GetRegion()
        {
            try
            {
                return _context.SE_CSS_Master.Where(u => !string.IsNullOrEmpty(u.Region)).Select(u => u.Region).Distinct().ToList();
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }


        public IEnumerable<SE.API.Models.UserModel> GetUsers()
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<SE.API.Models.UserModel> userModels = new List<SE.API.Models.UserModel>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "sp_GetUsers";
                    cmd.CommandType = CommandType.StoredProcedure;

                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        SE.API.Models.UserModel userModel = new SE.API.Models.UserModel();
                        userModel.Id = reader.GetValue(0).ToString();
                        userModel.FirstName = reader.GetValue(1).ToString();
                        userModel.LastName = reader.GetValue(2).ToString();
                        userModel.UserTypeId = Convert.ToInt32(reader.GetValue(3).ToString());
                        userModel.UserType = ((UserType)Convert.ToInt32(reader.GetValue(3).ToString())).GetDescription();
                        userModel.UserStatus = Convert.ToInt32(reader.GetValue(4).ToString());
                        userModel.UserName = reader.GetValue(5).ToString();
                        userModel.CSSCode = reader.GetValue(6).ToString();
                        userModel.CSSName = reader.GetValue(7).ToString();
                        userModel.CSSRegion = reader.GetValue(8).ToString();
                        userModel.BusinessUnit = reader.GetValue(9).ToString();
                        userModels.Add(userModel);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return userModels;
        }

        public bool UpdateCss(CSSUpdateResourceParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<SE.API.Models.UserModel> userModels = new List<SE.API.Models.UserModel>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "usp_CSSUpdate";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@updateType", currentParams.UpdateType));
                    cmd.Parameters.Add(new SqlParameter("@userId", currentParams.UserId));
                    cmd.Parameters.Add(new SqlParameter("@cssIds", currentParams.CSSIds));

                    cmd.ExecuteNonQuery();

                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return true;
        }

        public bool UploadCSSUserData(CSSZipCodeUpdateResourceParameter currentParams)
        {
            try
            {
                CSS result = _context.SE_CSS_Master.Where(u => u.Id == currentParams.CSSIds).FirstOrDefault();
                if (result != null)
                {
                    result.Zip_Code = currentParams.Zip_Code;
                    result.Base_Payout_Percentage = currentParams.Base_Payout_Percentage;
                    result.Incentive_Percentage = currentParams.Incentive_Percentage;
                    _context.Update(result);
                    _context.SaveChanges();
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }


        public bool UploadCSS()
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<SE.API.Models.UserModel> userModels = new List<SE.API.Models.UserModel>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "[SP_Insert_CSS_Master]";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return true;
        }
        public bool DeleteUser(StoreUser user)
        {
            try
            {
                user.UserStatus = 0;
                _context.Update(user);
                _context.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        public IEnumerable<Cooling_Rate_Card> GetCoolingRateCard()
        {
            try
            {
                return _context.Cooling_Rate_Card.ToList();
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }

        public async Task<IEnumerable<WorkOrder>> GetWorkOrder(WorkOrderFilter filter)
        {
            try
            {
                var collection = _context.SE_Work_Order as IQueryable<WorkOrder>;

                if (filter.WorkOrder_Status != null && filter.WorkOrder_Status >= 0)
                {
                    collection = collection.Where(u => u.WO_Process_Status == filter.WorkOrder_Status);
                }
                if (!string.IsNullOrEmpty(filter.Bussines_Unit))
                {
                    collection = collection.Where(u => u.WO_BusinessUnit == filter.Bussines_Unit);
                }
                if (!string.IsNullOrEmpty(filter.Month_Name))
                {
                    collection = collection.Where(u => u.Month_Name.Trim().ToLower() == filter.Month_Name.Trim().ToLower()
                        && !string.IsNullOrEmpty(u.Month_Name));
                }

                collection = collection.Where(u => u.WO_Process_Status != (int)StatusType.Central_Approved && u.WO_Process_Status != (int)StatusType.Imported);

                return await collection.ToListAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        public async Task<IEnumerable<Invoice>> GetInvoices(InvoiceFilter filter)
        {
            try
            {
                var collection = _context.SE_CSS_Invoice as IQueryable<Invoice>;
                if (!string.IsNullOrEmpty(filter.PRF_Invoice_No))
                {
                    collection = collection.Where(u => u.PRF_No.Contains(filter.PRF_Invoice_No) || u.Inv_No.Contains(filter.PRF_Invoice_No));
                }
                if (!string.IsNullOrEmpty(filter.Invoice_Type))
                {
                    collection = collection.Where(u => u.Inv_Type == filter.Invoice_Type);
                }
                if (filter.Invoice_Status != null && filter.Invoice_Status >= 0)
                {
                    collection = collection.Where(u => u.Status_Type == filter.Invoice_Status);
                }
                if (!string.IsNullOrEmpty(filter.Bussines_Unit))
                {
                    collection = collection.Where(u => u.WO_BusinessUnit == filter.Bussines_Unit);
                }
                if (!string.IsNullOrEmpty(filter.Month_Name))
                {
                    collection = collection.Where(u => u.Month_Name.Trim().ToLower() == filter.Month_Name.Trim().ToLower()
                        && !string.IsNullOrEmpty(u.Month_Name));
                }
                collection = collection.Include(u => u.CSS);
                collection = collection.Include(u => u.WorkOrders);
                collection = collection.Include(u => u.SupplyWorkOrders);

                return await collection.ToListAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private List<int> GetStatusSequence()
        {
            return new List<int> {
                                     (int)StatusType.GRN_Raised,
                                     (int)StatusType.GRN_Clarification,
                                     (int)StatusType.Invoice_Validated,
                                     (int)StatusType.Invoice_Raised,
                                     (int)StatusType.PRF_Raised,
                                     (int)StatusType.CSS_MGR_Approved,
                                     (int)StatusType.CSS_Approved,
                                     (int)StatusType.Central_Approved
                                 };
        }
        private Dictionary<int, Action<Invoice>> GetInvoiceReversionRules()
        {
            return new Dictionary<int, Action<Invoice>>
                   {
                       { (int)StatusType.GRN_Raised, invoice =>
                           {
                               invoice.GRN_No = null;
                               invoice.GRN_Date = null;
                               invoice.GRN_GEN_DATE = null;
                           }
                       },
                       { (int)StatusType.GRN_Clarification, invoice => { } },
                       { (int)StatusType.Invoice_Validated, invoice =>
                           {
                               invoice.FIN_APPROVE_DATE = null;
                           }
                       },
                       { (int)StatusType.Invoice_Raised, invoice =>
                           {
                               invoice.Inv_No = null;
                               invoice.Inv_Date = null;
                               invoice.Inv_Attachment = null;
                               invoice.INV_GEN_DATE = null;
                           }
                       },
                       { (int)StatusType.PRF_Raised, invoice => { } }
                   };
        }
        private Dictionary<int, Action<List<WorkOrder>>> GetWorkOrderReversionRules()
        {
            return new Dictionary<int, Action<List<WorkOrder>>>
                   {
                       { (int)StatusType.CSS_MGR_Approved, (workOrders) =>
                       InvoiceToCssApprove(workOrders) },
                       { (int)StatusType.CSS_Approved, (workOrders) =>
                       InvoiceToCentral(workOrders ) }
                   };
        }
        private HashSet<int> GetInvoiceStatus()
        {
            return new HashSet<int>
                   {
                       (int)StatusType.GRN_Raised,
                       (int)StatusType.GRN_Clarification,
                       (int)StatusType.Invoice_Validated,
                       (int)StatusType.Invoice_Raised,
                       (int)StatusType.PRF_Raised,
                       (int)StatusType.PO_Waiting,
                   };
        }
        private HashSet<int> GetWorkOrderStatus()
        {
            return new HashSet<int>
                   {
                       (int)StatusType.CSS_MGR_Approved,
                       (int)StatusType.CSS_Approved,
                       (int)StatusType.Central_Approved
                   };
        }
        public async Task<bool> RevertInvoiceStatus(RevertInvoiceStatus revertInvoiceStatus, string userName)
        {
            try
            {
                var currentDateTime = DateTime.Now;
                var Reverting_Wo_status = new List<WorkOrderStatus>();

                var invoiceStatuses = GetInvoiceStatus();
                var workOrderStatuses = GetWorkOrderStatus();
                var statusSequence = GetStatusSequence();
                var invoiceResetRules = GetInvoiceReversionRules();
                var workOrderRevertRules = GetWorkOrderReversionRules();

                bool isInvoiceRevert = revertInvoiceStatus.Inv_Id != null;
                bool isWorkOrderRevert = revertInvoiceStatus.WorkOrderId != null;

                bool isInvoiceStatus = invoiceStatuses.Contains(revertInvoiceStatus.To_Status ?? 0);
                bool isWorkOrderStatus = workOrderStatuses.Contains(revertInvoiceStatus.To_Status ?? 0);

                var existingInvoice = isInvoiceRevert ? _context.SE_CSS_Invoice.FirstOrDefault(x => x.Id == revertInvoiceStatus.Inv_Id) : new Invoice();
                var existingInvoiceStatus = isInvoiceRevert ? _context.SE_CSS_Invoice_Status.Where(x => x.Inv_Id == revertInvoiceStatus.Inv_Id).ToList() : new List<InvoiceStatus>();
                var invoice_detail = isInvoiceRevert && isWorkOrderStatus ? _context.SE_CSS_Invoice_Detail.Where(x => x.INV_ID == revertInvoiceStatus.Inv_Id).ToList() : new List<InvoiceDetail>();

                var work_orders = isInvoiceRevert && isWorkOrderStatus
                    ? _context.SE_Work_Order.Where(x => x.INV_ID == revertInvoiceStatus.Inv_Id || x.SUPPLY_INV_ID == revertInvoiceStatus.Inv_Id).Include(x => x.WorkOrderStatuses).ToList()
                    : (isWorkOrderRevert ? _context.SE_Work_Order.Where(x => revertInvoiceStatus.WorkOrderId.Contains(x.Id)).Include(x => x.WorkOrderStatuses).ToList() : new List<WorkOrder>());

                var fromIndex = statusSequence.IndexOf(revertInvoiceStatus.From_Status);
                var toIndex = statusSequence.IndexOf(revertInvoiceStatus.To_Status ?? 0);

                if (fromIndex >= 0 && toIndex >= 0 && fromIndex < toIndex)
                {
                    var path = statusSequence.GetRange(fromIndex, toIndex - fromIndex);
                    foreach (var intermediateStatus in path)
                    {
                        if (invoiceResetRules.TryGetValue(intermediateStatus, out var resetAction) && isInvoiceStatus)
                        {
                            resetAction(existingInvoice);
                        }
                        else if (workOrderRevertRules.TryGetValue(intermediateStatus, out var workOrderResetAction) && isWorkOrderStatus)
                        {
                            workOrderResetAction(work_orders);
                        }
                    }
                }

                if (isInvoiceRevert && isInvoiceStatus)
                {
                    InvoiceStatus invoiceStatusInsert = new InvoiceStatus
                    {
                        Inv_Id = revertInvoiceStatus.Inv_Id ?? 0,
                        Status_Type = revertInvoiceStatus.To_Status ?? 0,
                        Updated_User = userName,
                        Updated_Date = currentDateTime,
                        Remarks = $"Reverting Status From {Enum.GetName(typeof(StatusType), revertInvoiceStatus.From_Status)}({revertInvoiceStatus.From_Status}) To {Enum.GetName(typeof(StatusType), revertInvoiceStatus.To_Status)}({revertInvoiceStatus.To_Status})."
                    };

                    await _context.SE_CSS_Invoice_Status.AddAsync(invoiceStatusInsert);

                    // Get audit info
                    existingInvoice.Status_Type = revertInvoiceStatus.To_Status ?? 0;
                    var invoiceToStatus = existingInvoiceStatus.FirstOrDefault(x => x.Status_Type == revertInvoiceStatus.To_Status);
                    if (invoiceToStatus != null)
                    {
                        existingInvoice.Remarks = invoiceToStatus?.Remarks;
                        existingInvoice.Updated_User = invoiceToStatus.Updated_User;
                        existingInvoice.Updated_Date = invoiceToStatus.Updated_Date;
                    }

                    _context.SE_CSS_Invoice.Update(existingInvoice);
                    _context.SaveChanges();
                }
                else
                {
                    foreach (var work_order in work_orders)
                    {
                        Reverting_Wo_status.Add(new WorkOrderStatus
                        {
                            Work_Order_Id = work_order.Id,
                            Status_Type = revertInvoiceStatus.To_Status ?? 0,
                            Updated_User = userName,
                            Updated_Date = currentDateTime,
                            Remarks = $"Reverting Status From {Enum.GetName(typeof(StatusType), revertInvoiceStatus.From_Status)}({revertInvoiceStatus.From_Status}) To {Enum.GetName(typeof(StatusType), revertInvoiceStatus.To_Status)}({revertInvoiceStatus.To_Status})."
                        });
                    }

                    await _context.SE_Work_Order_Status.AddRangeAsync(Reverting_Wo_status);
                    _context.SE_Work_Order.UpdateRange(work_orders);

                    if (isInvoiceRevert)
                    {
                        _context.SE_CSS_Invoice_Status.RemoveRange(existingInvoiceStatus);
                        _context.SE_CSS_Invoice_Detail.RemoveRange(invoice_detail);
                        _context.SE_CSS_Invoice.Remove(existingInvoice);
                    }

                    await _context.SaveChangesAsync();
                }

                return true;
            }
            catch (Exception ex)
            {
                return false;
                throw;
            }
        }

        public void InvoiceToCentral(List<WorkOrder> work_orders)
        {
            foreach (var workOrder in work_orders)
            {
                workOrder.WO_Process_Status = (int)StatusType.Central_Approved;
                workOrder.INV_ID = null;
                workOrder.SUPPLY_INV_ID = null;
                workOrder.CSS_Status = null;
                workOrder.CSS_User = null;
                workOrder.CSS_UpdatedDate = null;
                workOrder.CSS_Remark = null;
                workOrder.CSS_Cost = null;
                workOrder.CSS_LABOUR_COST = null;
                workOrder.CSS_SUPPLY_COST = null;
                workOrder.CSS_Reason = null;
                workOrder.CSS_Attachment = null;
                workOrder.CSS_Reason_Desc = null;
                workOrder.CSS_Approved_Date = null;
            }
        }

        public void InvoiceToCssApprove(List<WorkOrder> work_orders)
        {
            foreach (var workOrder in work_orders)
            {
                var current_WO_Status = workOrder.WorkOrderStatuses.OrderBy(x => x.Updated_Date).ToList();
                var lastStatus = current_WO_Status.LastOrDefault();
                var secondLastStatus = current_WO_Status.Count >= 2 ? current_WO_Status[^2] : null;
                if (secondLastStatus.Status_Type != (int)StatusType.CSS_MGR_Approved)
                {
                    workOrder.Claim = secondLastStatus.Wo_Amt == null || secondLastStatus.Wo_Amt <= 0 ? workOrder.Claim : secondLastStatus.Wo_Amt;
                    workOrder.LABOUR_COST = secondLastStatus.LABOUR_COST == null || secondLastStatus.LABOUR_COST <= 0 ? workOrder.LABOUR_COST : secondLastStatus.LABOUR_COST;
                    workOrder.SUPPLY_COST = secondLastStatus.SUPPLY_COST == null || secondLastStatus.SUPPLY_COST <= 0 ? workOrder.SUPPLY_COST : secondLastStatus.SUPPLY_COST;
                }

                workOrder.CSS_Mgr_Cost = null;
                workOrder.CSS_Mgr_LABOUR_COST = null;
                workOrder.CSS_Mgr_SUPPLY_COST = null;
                workOrder.CSS_Mgr_Status = null;
                workOrder.CSS_Mgr_UpdatedDate = null;
                workOrder.CSS_Mgr_User = null;
                workOrder.CSS_Mgr_Remark = null;
                workOrder.CSS_Mgr_Reason = null;
                workOrder.CSS_Mgr_Attachment = null;
                workOrder.CSS_Mgr_Reason_Desc = null;
                workOrder.WO_Process_Status = secondLastStatus.Status_Type;
                workOrder.INV_ID = null;
                workOrder.SUPPLY_INV_ID = null;
            }
        }

        public IEnumerable<HBN_Rate_Card> GetHBNRateCard()
        {
            try
            {
                return _context.HBN_Rate_Card.ToList();
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        public IEnumerable<PSI_Rate_Card> GetPSIRateCard()
        {
            try
            {
                return _context.PSI_Rate_Card.ToList();
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }

        public IEnumerable<ProductCategoryCooling> GetProductCategoryCooling()
        {
            try
            {
                return _context.Cooling_Product_Category_list.ToList();
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        public IEnumerable<ProductCategoryHBN> GetProductCategoryHBN()
        {
            try
            {
                return _context.HBN_Product_category_List.ToList();
            }
            catch (Exception ex)
            {

                throw;
            }
        }
        public IEnumerable<ProductCategoryPPI> GetProductCategoryPPI()
        {
            try
            {
                return _context.PSI_Product_Category.ToList();
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }


        public bool InsertCoolingProduct(ProductCategoryCoolingSubmitParameter currentParam)
        {
            try
            {
                ProductCategoryCooling product = new ProductCategoryCooling()
                {

                    Type = currentParam.Type,
                    Product = currentParam.Product,
                    Group = currentParam.Group
                };
                _context.Add(product);
                _context.SaveChanges();
                return true;

            }
            catch (Exception ex)
            {

                throw ex;
            }
        }

        public bool UpdateCoolingProduct(ProductCategoryCoolingSubmitParameter currentParam)
        {
            try
            {
                ProductCategoryCooling product = _context.Cooling_Product_Category_list.Where(u => u.Id == (currentParam.Id ?? -1)).First();
                if (product != null)
                {
                    product.Type = currentParam.Type;
                    product.Product = currentParam.Product;
                    product.Group = currentParam.Group;
                    _context.Update(product);
                    _context.SaveChanges();
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }

        public bool InsertPPIRateCard(RateCardPPIModel currentParam)
        {
            try
            {
                PSI_Rate_Card pSI_Rate_Card = new PSI_Rate_Card()
                {

                    Rate = currentParam.Rate,
                    Product_Grouping = currentParam.Product_Grouping,
                    Distance_Slab = currentParam.Distance_Slab
                };
                _context.Add(pSI_Rate_Card);
                _context.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public bool UpdatePPIRateCard(RateCardPPIModel currentParam)
        {
            try
            {
                PSI_Rate_Card rate_Card = _context.PSI_Rate_Card.Where(u => u.Id == (currentParam.Id ?? -1)).First();
                if (rate_Card != null)
                {
                    rate_Card.Product_Grouping = currentParam.Product_Grouping;
                    rate_Card.Distance_Slab = currentParam.Distance_Slab;
                    rate_Card.Rate = currentParam.Rate;
                    _context.Update(rate_Card);
                    _context.SaveChanges();
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }

        public bool UpdateHBNRateCard(RateCardHBNModel currentParam)
        {
            try
            {
                HBN_Rate_Card rate_Card = _context.HBN_Rate_Card.Where(u => u.Id == (currentParam.Id ?? -1)).First();
                if (rate_Card != null)
                {
                    rate_Card.Product_Grouping = currentParam.Product_Grouping;
                    rate_Card.Distance_Slab = currentParam.Distance_Slab;
                    rate_Card.Rate = currentParam.Rate;
                    rate_Card.Service_Type = currentParam.Service_Type;
                    rate_Card.PayOut_Type = currentParam.PayOut_Type;

                    _context.Update(rate_Card);
                    _context.SaveChanges();
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }

        public bool InsertHBNRateCard(RateCardHBNModel currentParam)
        {
            try
            {
                HBN_Rate_Card pSI_Rate_Card = new HBN_Rate_Card()
                {

                    Rate = currentParam.Rate,
                    Product_Grouping = currentParam.Product_Grouping,
                    Distance_Slab = currentParam.Distance_Slab,
                    Service_Type = currentParam.Service_Type,
                    PayOut_Type = currentParam.PayOut_Type
                };
                _context.Add(pSI_Rate_Card);
                _context.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool UpdateCoolingRateCard(RateCardCoolingModel currentParam)
        {
            try
            {
                Cooling_Rate_Card rate_Card = _context.Cooling_Rate_Card.Where(u => u.Id == (currentParam.Id ?? -1)).First();
                if (rate_Card != null)
                {
                    rate_Card.Rate = currentParam.Rate;
                    rate_Card.Product_Grouping = currentParam.Product_Grouping;
                    rate_Card.Distance_Slab = currentParam.Distance_Slab;
                    rate_Card.Payout_Type = currentParam.Payout_Type;
                    rate_Card.Work_Description = currentParam.Work_Description;
                    rate_Card.Unit_details = currentParam.Unit_details;
                    rate_Card.Region = currentParam.Region = currentParam.Work_Description;

                    _context.Update(rate_Card);
                    _context.SaveChanges();
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool InsertCoolingRateCard(RateCardCoolingModel currentParam)
        {
            try
            {
                Cooling_Rate_Card Rate_Card = new Cooling_Rate_Card()
                {
                    Rate = currentParam.Rate,
                    Product_Grouping = currentParam.Product_Grouping,
                    Distance_Slab = currentParam.Distance_Slab,
                    Payout_Type = currentParam.Payout_Type,
                    Work_Description = currentParam.Work_Description,
                    Unit_details = currentParam.Unit_details,
                    Region = currentParam.Region = currentParam.Work_Description
                };
                _context.Add(Rate_Card);
                _context.SaveChanges();
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool UpdateInvoice(List<Invoice> invoices, bool IsGRNCollectoreMailSent)
        {
            try
            {

                foreach (var invoice in invoices)
                {
                    invoice.IsGRNCollectoreMailSent = IsGRNCollectoreMailSent;
                }

                _context.BulkUpdate(invoices);
                return true;
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        public async Task<List<Invoice>> GetUnsentCollectorInvoices(CancellationToken cancellationToken)
        {
            try
            {
                return await _context.SE_CSS_Invoice.Where(x => x.IsGRNCollectoreMailSent == false).ToListAsync(cancellationToken);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task CheckAndSendOverdueEmails_CSS(CancellationToken cancellationToken, IConfiguration _config, ILogger _logger)
        {
            var today = DateTime.Today;

            var overdueWorkOrders = await _context.SE_Work_Order
                .Include(w => w.CSS)
                .Where(w =>
                    (w.Central_UpdatedDate == null && EF.Functions.DateDiffDay(w.Loaded_Date, today) > w.CSS.Central_TAT) ||
                    (w.CSS_UpdatedDate == null && EF.Functions.DateDiffDay(w.Central_UpdatedDate, today) > w.CSS.CSS_TAT) ||
                    (w.CSS_Mgr_UpdatedDate == null && EF.Functions.DateDiffDay(w.CSS_UpdatedDate, today) > w.CSS.CSS_Manager_TAT)).ToListAsync(cancellationToken);

            var groupedByCssId = overdueWorkOrders
                .GroupBy(x => x.CSS_Id)
                .ToList();

            foreach (var order in groupedByCssId)
            {
                var data = order.First();
                var master = data.CSS;
                string cssDetails = string.Empty;

                if (data.CSS_Mgr_UpdatedDate == null && (today - data.CSS_UpdatedDate)?.Days > master.CSS_Manager_TAT)
                {
                    cssDetails = $"<p><b>CSS Code:</b> {data.CSS.CSS_Code ?? string.Empty}<br/>" +
                                 $"<b>CSS Name:</b> {data.CSS.CSS_Name_as_per_Oracle_SAP ?? string.Empty}</p>";
                }

                string body = $@"<p>Dear User,</p>

                                <p>We hope this message finds you well.</p>

                                <p>
                                This is a reminder that you have pending tasks assigned to you
                                that have exceeded the defined Turnaround Time (TAT) for the month of
                                <b>[{data.Month_Name}]</b>.
                                </p>{cssDetails}
                                <p>
                                Please review and complete these tasks at the earliest to ensure a smooth workflow
                                and avoid escalation.
                                </p>

                                <p>
                                If you believe this notification is incorrect or if the tasks have already been completed,
                                please ignore this message.
                                </p>

                                <p>Regards,<br/>Team Sandhi</p>";

                if (data.Central_UpdatedDate == null && (today - data.Loaded_Date).Days > master.Central_TAT)
                {
                    await Email.SendEmailAsync(_config, _logger, "Central Work Overdue", body, toEmail: "central@se.com");
                }

                if (data.CSS_UpdatedDate == null && (today - data.Central_UpdatedDate)?.Days > master.CSS_TAT)
                {
                    string cssEmail = GetCCEmail(data.Central_UpdatedDate ?? DateTime.Now, master, StatusType.CSS_Approved, master.Central_TAT);
                    await Email.SendEmailAsync(_config, _logger, "Partner Work Overdue", body, toEmail: master.Contact_Person_Email_ID, ccEmail: cssEmail);
                }

                if (data.CSS_Mgr_UpdatedDate == null && (today - data.CSS_UpdatedDate)?.Days > master.CSS_Manager_TAT)
                {
                    string cssEmail = GetCCEmail(data.CSS_UpdatedDate ?? DateTime.Now, master, StatusType.CSS_MGR_Approved, master.CSS_Manager_TAT);
                    await Email.SendEmailAsync(_config, _logger, "Partner Manager Work Overdue", body, toEmail: master.CSS_Manager_Email_ID, ccEmail: cssEmail);
                }
            }
        }

        private string GetCCEmail(DateTime fromDate, CSS master, StatusType statusType, int TAT)
        {
            var daysSinceAssigned = (DateTime.Now - fromDate).TotalDays;
            int level1 = TAT * 2; // e.g., 6 days
            int level2 = TAT * 3; // e.g., 9 days

            List<string> emails = new List<string>();

            if (daysSinceAssigned > TAT && daysSinceAssigned <= level1)
            {
                emails.Add(GetEmailByStatusLevel1(master, statusType));
            }
            else if (daysSinceAssigned > level1 && daysSinceAssigned <= level2)
            {
                emails.AddRange(GetEmailsByStatusLevel2(master, statusType));
            }
            else if (daysSinceAssigned > level2)
            {
                emails.AddRange(GetEmailsByStatusLevel3(master, statusType));
            }

            return string.Join(",", emails.Where(e => !string.IsNullOrWhiteSpace(e)));
        }

        private string GetEmailByStatusLevel1(CSS master, StatusType statusType)
        {

            string email = statusType switch
            {
                StatusType.CSS_Approved => master.Email_ID,
                StatusType.CSS_MGR_Approved => master.CSS_Manager_Email_ID,
                StatusType.Invoice_Raised => master.Email_ID,
                StatusType.Invoice_Validated => master.Finance_Claim_Data_Validator,
                StatusType.GRN_Raised => master.GRN_Creater_Email_ID,
                _ => null
            };

            return string.IsNullOrWhiteSpace(email) ? null : email;
        }

        private IEnumerable<string> GetEmailsByStatusLevel2(CSS master, StatusType statusType)
        {
            return statusType switch
            {
                StatusType.CSS_Approved => FilterValidEmails(master.Email_ID, master.CSS_Manager_Email_ID),
                StatusType.CSS_MGR_Approved => FilterValidEmails(master.CSS_Manager_Email_ID, master.Css_Manager_Manager_Email),
                StatusType.Invoice_Raised => FilterValidEmails(master.Email_ID, master.CSS_Manager_Email_ID),
                StatusType.Invoice_Validated => FilterValidEmails(master.Finance_Claim_Data_Validator, master.Finance_Head_Email_ID),
                StatusType.GRN_Raised => FilterValidEmails(master.GRN_Creater_Email_ID, master.GRN_Manager_Email),
                _ => Enumerable.Empty<string>()
            };
        }

        private IEnumerable<string> GetEmailsByStatusLevel3(CSS master, StatusType statusType)
        {
            return statusType switch
            {
                StatusType.CSS_Approved => FilterValidEmails(master.Email_ID, master.CSS_Manager_Email_ID, master.Css_Manager_Manager_Email),
                StatusType.CSS_MGR_Approved => FilterValidEmails(master.CSS_Manager_Email_ID, master.Css_Manager_Manager_Email, "central@se.com"),
                StatusType.Invoice_Raised => FilterValidEmails(master.Email_ID, master.CSS_Manager_Email_ID, master.Css_Manager_Manager_Email),
                StatusType.Invoice_Validated => FilterValidEmails(master.Finance_Claim_Data_Validator, master.Finance_Head_Email_ID, master.CSS_Manager_Email_ID),
                StatusType.GRN_Raised => FilterValidEmails(master.GRN_Creater_Email_ID, master.GRN_Manager_Email, "central@se.com"),
                _ => Enumerable.Empty<string>()
            };
        }

        private IEnumerable<string> FilterValidEmails(params string[] emails)
        {
            return emails.Where(email => !string.IsNullOrWhiteSpace(email));
        }

        public async Task CheckAndSendOverdueEmails_Invoice(CancellationToken cancellationToken, IConfiguration _config, ILogger _logger)
        {
            var today = DateTime.Today;

            var overdueWorkOrders = await _context.SE_CSS_Invoice
                .Include(w => w.CSS)
                .Where(w =>
                    (w.INV_GEN_DATE == null && EF.Functions.DateDiffDay(w.Created_Date, today) > w.CSS.CSS_TAT) ||
                    (w.FIN_APPROVE_DATE == null && EF.Functions.DateDiffDay(w.INV_GEN_DATE, today) > w.CSS.Finance_TAT) ||
                    (w.GRN_GEN_DATE == null && EF.Functions.DateDiffDay(w.FIN_APPROVE_DATE, today) > w.CSS.GRN_TAT) ||
                    (w.INV_PAID_DATE == null && EF.Functions.DateDiffDay(w.GRN_GEN_DATE, today) > w.CSS.Central_TAT)).ToListAsync(cancellationToken);

            var groupedByCssId = overdueWorkOrders
                .GroupBy(x => x.CSS_Id)
                .ToList();

            foreach (var order in groupedByCssId)
            {
                var data = order.First();
                var master = data.CSS;

                string body = $@"<p>Dear User,</p>

                                <p>We hope this message finds you well.</p>

                                <p>
                                This is a reminder that you have pending tasks assigned to you that have exceeded 
                                the defined Turnaround Time (TAT) for the month of <b>[{data.Month_Name}]</b>.
                                </p>

                                <p>
                                Please review and complete these tasks at the earliest to ensure smooth workflow 
                                and avoid escalation.
                                </p>

                                <p>
                                If you believe this notification is incorrect or if the tasks have already been completed, 
                                please ignore.
                                </p>

                                <br/>

                                <p>Regards,<br/>Team Sandhi</p>";

                if (data.INV_GEN_DATE == null && (today - data.Created_Date).Days > master.CSS_TAT)
                {
                    string cssEmail = GetCCEmail(data.INV_GEN_DATE ?? DateTime.Now, master, StatusType.Invoice_Raised, master.CSS_TAT);
                    await Email.SendEmailAsync(_config, _logger, "Invoice Generation Overdue", body, toEmail: master.Contact_Person_Email_ID, ccEmail: cssEmail);
                }

                if (data.FIN_APPROVE_DATE == null && (today - data.INV_GEN_DATE)?.Days > master.Finance_TAT)
                {
                    string cssEmail = GetCCEmail(data.FIN_APPROVE_DATE ?? DateTime.Now, master, StatusType.Invoice_Validated, master.Finance_TAT);
                    await Email.SendEmailAsync(_config, _logger, "Finance Approval Overdue", body, toEmail: master.Finance_Claim_Data_Validator, ccEmail: cssEmail);
                }

                if (data.GRN_GEN_DATE == null && (today - data.FIN_APPROVE_DATE)?.Days > master.GRN_TAT)
                {
                    string cssEmail = GetCCEmail(data.GRN_GEN_DATE ?? DateTime.Now, master, StatusType.GRN_Raised, master.GRN_TAT);
                    await Email.SendEmailAsync(_config, _logger, "GRN Generation Overdue", body, toEmail: master.GRN_Creater_Email_ID, ccEmail: cssEmail);
                }
            }
        }

        public bool InsertHBNProduct(ProductCategoryHBNSubmitParameter currentParam)
        {
            try
            {
                ProductCategoryHBN product = new ProductCategoryHBN()
                {
                    Type = currentParam.Type,
                    Product = currentParam.Product,
                    Group = currentParam.Group
                };
                _context.Add(product);
                _context.SaveChanges();
                return true;

            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        public bool UpdateHBNProduct(ProductCategoryHBNSubmitParameter currentParam)
        {
            try
            {
                ProductCategoryHBN product = _context.HBN_Product_category_List.Where(u => u.Id == (currentParam.Id ?? -1)).First();
                if (product != null)
                {
                    product.Type = currentParam.Type;
                    product.Product = currentParam.Product;
                    product.Group = currentParam.Group;

                    _context.Update(product);
                    _context.SaveChanges();
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }

        public bool InsertPPIProduct(ProductCategoryPPISubmitParameter currentParam)
        {
            try
            {
                ProductCategoryPPI product = new ProductCategoryPPI()
                {
                    Type = currentParam.Type,
                    Product = currentParam.Product,
                    Group = currentParam.Group
                };
                _context.Add(product);
                _context.SaveChanges();
                return true;

            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        public bool UpdatePPIProduct(ProductCategoryPPISubmitParameter currentParam)
        {
            try
            {
                ProductCategoryPPI product = _context.PSI_Product_Category.Where(u => u.Id == (currentParam.Id ?? -1)).First();
                if (product != null)
                {
                    product.Type = currentParam.Type;
                    product.Product = currentParam.Product;
                    product.Group = currentParam.Group;
                    _context.Update(product);
                    _context.SaveChanges();
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {

                throw ex;
            }
        }
        public bool UploadPPIProduct()
        {
            DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
            try
            {
                if (dbConnection.State.Equals((object)ConnectionState.Closed))
                    dbConnection.Open();
                using (DbCommand command = dbConnection.CreateCommand())
                {
                    command.CommandText = "[INSERTPSIPRODUCT]";
                    command.CommandType = CommandType.StoredProcedure;
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (dbConnection.State.Equals((object)ConnectionState.Open))
                    dbConnection.Close();
            }
            return true;
        }

        public bool UploadHBNProduct()
        {
            DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
            try
            {
                if (dbConnection.State.Equals((object)ConnectionState.Closed))
                    dbConnection.Open();
                using (DbCommand command = dbConnection.CreateCommand())
                {
                    command.CommandText = "[INSERTHBNPRODUCT]";
                    command.CommandType = CommandType.StoredProcedure;
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (dbConnection.State.Equals((object)ConnectionState.Open))
                    dbConnection.Close();
            }
            return true;
        }

        public bool UploadCoolingProduct()
        {
            DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
            try
            {
                if (dbConnection.State.Equals((object)ConnectionState.Closed))
                    dbConnection.Open();
                using (DbCommand command = dbConnection.CreateCommand())
                {
                    command.CommandText = "[INSERTCOOLINGPRODUCT]";
                    command.CommandType = CommandType.StoredProcedure;
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (dbConnection.State.Equals((object)ConnectionState.Open))
                    dbConnection.Close();
            }
            return true;
        }
        public bool DeleteWorkOrderByMonth(int month, int year)
        {
            try
            {
                DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
                try
                {
                    if (dbConnection.State.Equals((object)ConnectionState.Closed))
                        dbConnection.Open();
                    using (DbCommand command = dbConnection.CreateCommand())
                    {
                        command.CommandText = "SP_Delete_SE_WorkOrder_ByMonth";
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.Add((object)new SqlParameter("@W_month", (object)month));
                        command.Parameters.Add((object)new SqlParameter("@W_Year", (object)year));
                        command.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    if (dbConnection.State.Equals((object)ConnectionState.Open))
                        dbConnection.Close();
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public bool ResetDefaultPassword(string Email)
        {
            try
            {
                int num = 0;
                DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
                try
                {
                    if (dbConnection.State.Equals((object)ConnectionState.Closed))
                        dbConnection.Open();
                    using (DbCommand command = dbConnection.CreateCommand())
                    {
                        command.CommandText = "SP_RESETDEFAULTPASSWORD";
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.Add((object)new SqlParameter("@EMAIL", (object)Email));
                        num = command.ExecuteNonQuery();
                    }
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    if (dbConnection.State.Equals((object)ConnectionState.Open))
                        dbConnection.Close();
                }
                return num > 0;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        #region Dashboards
        public SE.API.Models.GradationDashboardModel GetGradationDashboard(GradationDashboardParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            GradationDashboardModel reportData = new GradationDashboardModel();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "usp_DashboardGradation";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@FromDate", currentParams.FromDate));
                    cmd.Parameters.Add(new SqlParameter("@ToDate", currentParams.ToDate));
                    cmd.Parameters.Add(new SqlParameter("@region", currentParams.Region));
                    cmd.Parameters.Add(new SqlParameter("@businessUnit", currentParams.BusinessUnit));
                    cmd.Parameters.Add(new SqlParameter("@groupBy", "BusinessUnit"));
                    cmd.Parameters.Add(new SqlParameter("@cssManagerUserId", currentParams.CSSManagerUserId));
                    cmd.Parameters.Add(new SqlParameter("@finUserId", currentParams.FinUserId));
                    cmd.Parameters.Add(new SqlParameter("@grnUserId", currentParams.GRNUserId));
                    cmd.Parameters.Add(new SqlParameter("@cssId", currentParams.CSSId));

                    var reader = cmd.ExecuteReader();
                    List<GradationDashboardCSSModel> gradesByCss = new List<GradationDashboardCSSModel>();
                    while (reader.Read())
                    {
                        GradationDashboardCSSModel data = new GradationDashboardCSSModel();

                        data.CSS_CODE = reader.GetValue(0).ToString();
                        data.CSS_NAME = reader.GetValue(1).ToString();
                        data.Region = reader.GetValue(2).ToString();
                        data.BusinessUnit = reader.GetValue(3).ToString();
                        data.Month_Name = reader.GetValue(4).ToString();
                        data.FINAL_GRADE = reader.GetValue(5).ToString();
                        data.SRS_GRADE = reader.GetValue(6).ToString();
                        data.NSS_GRADE = reader.GetValue(7).ToString();
                        data.CSR_GRADE = reader.GetValue(8).ToString();
                        data.WOR_GRADE = reader.GetValue(9).ToString();
                        data.MTTR_GRADE = reader.GetValue(10).ToString();
                        data.PMC_GRADE = reader.GetValue(11).ToString();
                        data.DFR_HBN_GRADE = reader.GetValue(12).ToString();
                        data.DFR_PPI_GRADE = reader.GetValue(13).ToString();
                        data.NPF_GRADE = reader.GetValue(14).ToString();
                        data.ATTR_GRADE = reader.GetValue(15).ToString();
                        data.FRS_GRADE = reader.GetValue(16).ToString();
                        data.LEAD_GRADE = reader.GetValue(17).ToString();
                        data.IB_GRADE = reader.GetValue(18).ToString();
                        gradesByCss.Add(data);
                    }

                    reader.NextResult();
                    List<GradationDashboardGroupModel> gradesByGroup = new List<GradationDashboardGroupModel>();
                    while (reader.Read())
                    {
                        GradationDashboardGroupModel data = new GradationDashboardGroupModel();

                        data.Region = reader.GetValue(0).ToString();
                        data.BusinessUnit = reader.GetValue(1).ToString();
                        data.Month_Name = reader.GetValue(2).ToString();
                        data.TOTAL_CSS = Convert.ToInt32(reader.GetValue(3).ToString());
                        data.Grade_Text = reader.GetValue(4).ToString();
                        data.FINAL_GRADE = Convert.ToInt32(reader.GetValue(5).ToString());
                        data.SRS_GRADE = Convert.ToInt32(reader.GetValue(6).ToString());
                        data.SRS_PERCENTAGE = Convert.ToDecimal(reader.GetValue(7).ToString());
                        data.NSS_GRADE = Convert.ToInt32(reader.GetValue(8).ToString());
                        data.NSS_PERCENTAGE = Convert.ToDecimal(reader.GetValue(9).ToString());
                        data.CSR_GRADE = Convert.ToInt32(reader.GetValue(10).ToString());
                        data.CSR_PERCENTAGE = Convert.ToDecimal(reader.GetValue(11).ToString());
                        data.WOR_GRADE = Convert.ToInt32(reader.GetValue(12).ToString());
                        data.WOR_PERCENTAGE = Convert.ToDecimal(reader.GetValue(13).ToString());
                        data.MTTR_GRADE = Convert.ToInt32(reader.GetValue(14).ToString());
                        data.MTTR_PERCENTAGE = Convert.ToDecimal(reader.GetValue(15).ToString());
                        data.PMC_GRADE = Convert.ToInt32(reader.GetValue(16).ToString());
                        data.PMC_PERCENTAGE = Convert.ToDecimal(reader.GetValue(17).ToString());
                        data.DFR_HBN_GRADE = Convert.ToInt32(reader.GetValue(18).ToString());
                        data.DFR_HBN_PERCENTAGE = Convert.ToDecimal(reader.GetValue(19).ToString());
                        data.DFR_PPI_GRADE = Convert.ToInt32(reader.GetValue(20).ToString());
                        data.DFR_PPI_PERCENTAGE = Convert.ToDecimal(reader.GetValue(21).ToString());
                        data.NPF_GRADE = Convert.ToInt32(reader.GetValue(22).ToString());
                        data.NPF_PERCENTAGE = Convert.ToDecimal(reader.GetValue(23).ToString());
                        data.ATTR_GRADE = Convert.ToInt32(reader.GetValue(24).ToString());
                        data.ATTR_PERCENTAGE = Convert.ToDecimal(reader.GetValue(25).ToString());
                        data.FRS_GRADE = Convert.ToInt32(reader.GetValue(26).ToString());
                        data.FRS_PERCENTAGE = Convert.ToDecimal(reader.GetValue(27).ToString());
                        data.LEAD_GRADE = Convert.ToInt32(reader.GetValue(28).ToString());
                        data.LEAD_PERCENTAGE = Convert.ToDecimal(reader.GetValue(29).ToString());
                        data.IB_GRADE = Convert.ToInt32(reader.GetValue(30).ToString());
                        data.SRS_PERCENTAGE = Convert.ToDecimal(reader.GetValue(31).ToString());

                        gradesByGroup.Add(data);
                    }
                    reader.Close();


                    DbCommand secondCmd = conn.CreateCommand();
                    secondCmd.CommandText = "usp_DashboardGradation";
                    secondCmd.CommandType = CommandType.StoredProcedure;
                    secondCmd.Parameters.Add(new SqlParameter("@FromDate", currentParams.FromDate));
                    secondCmd.Parameters.Add(new SqlParameter("@ToDate", currentParams.ToDate));
                    secondCmd.Parameters.Add(new SqlParameter("@region", currentParams.Region));
                    secondCmd.Parameters.Add(new SqlParameter("@businessUnit", currentParams.BusinessUnit));
                    secondCmd.Parameters.Add(new SqlParameter("@groupBy", "Region"));
                    secondCmd.Parameters.Add(new SqlParameter("@cssManagerUserId", currentParams.CSSManagerUserId));
                    secondCmd.Parameters.Add(new SqlParameter("@finUserId", currentParams.FinUserId));
                    secondCmd.Parameters.Add(new SqlParameter("@grnUserId", currentParams.GRNUserId));
                    secondCmd.Parameters.Add(new SqlParameter("@cssId", currentParams.CSSId));

                    var secondReader = secondCmd.ExecuteReader();
                    secondReader.NextResult();
                    List<GradationDashboardGroupModel> gradesByRegion = new List<GradationDashboardGroupModel>();
                    while (secondReader.Read())
                    {
                        GradationDashboardGroupModel data = new GradationDashboardGroupModel();

                        data.Region = secondReader.GetValue(0).ToString();
                        data.BusinessUnit = secondReader.GetValue(1).ToString();
                        data.Month_Name = secondReader.GetValue(2).ToString();
                        data.TOTAL_CSS = Convert.ToInt32(secondReader.GetValue(3).ToString());
                        data.Grade_Text = secondReader.GetValue(4).ToString();
                        data.FINAL_GRADE = Convert.ToInt32(secondReader.GetValue(5).ToString());
                        data.SRS_GRADE = Convert.ToInt32(secondReader.GetValue(6).ToString());
                        data.SRS_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(7).ToString());
                        data.NSS_GRADE = Convert.ToInt32(secondReader.GetValue(8).ToString());
                        data.NSS_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(9).ToString());
                        data.CSR_GRADE = Convert.ToInt32(secondReader.GetValue(10).ToString());
                        data.CSR_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(11).ToString());
                        data.WOR_GRADE = Convert.ToInt32(secondReader.GetValue(12).ToString());
                        data.WOR_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(13).ToString());
                        data.MTTR_GRADE = Convert.ToInt32(secondReader.GetValue(14).ToString());
                        data.MTTR_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(15).ToString());
                        data.PMC_GRADE = Convert.ToInt32(secondReader.GetValue(16).ToString());
                        data.PMC_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(17).ToString());
                        data.DFR_HBN_GRADE = Convert.ToInt32(secondReader.GetValue(18).ToString());
                        data.DFR_HBN_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(19).ToString());
                        data.DFR_PPI_GRADE = Convert.ToInt32(secondReader.GetValue(20).ToString());
                        data.DFR_PPI_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(21).ToString());
                        data.NPF_GRADE = Convert.ToInt32(secondReader.GetValue(22).ToString());
                        data.NPF_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(23).ToString());
                        data.ATTR_GRADE = Convert.ToInt32(secondReader.GetValue(24).ToString());
                        data.ATTR_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(25).ToString());
                        data.FRS_GRADE = Convert.ToInt32(secondReader.GetValue(26).ToString());
                        data.FRS_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(27).ToString());
                        data.LEAD_GRADE = Convert.ToInt32(secondReader.GetValue(28).ToString());
                        data.LEAD_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(29).ToString());
                        data.IB_GRADE = Convert.ToInt32(secondReader.GetValue(30).ToString());
                        data.SRS_PERCENTAGE = Convert.ToDecimal(secondReader.GetValue(31).ToString());

                        gradesByRegion.Add(data);
                    }
                    secondReader.Close();
                    secondCmd.Dispose();
                    reportData = new GradationDashboardModel()
                    {
                        GradationByCss = gradesByCss,
                        GradationByGroup = gradesByGroup,
                        GradationByRegion = gradesByRegion
                    };
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportData;
        }

        public SE.API.Models.PaymentDashboardModelByCount GetPaymentDashboardByCount(PaymentDashboardParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            PaymentDashboardModelByCount reportData = new PaymentDashboardModelByCount();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "usp_DashboardPaymentCount";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@groupBy", "BusinessUnit"));
                    cmd.Parameters.Add(new SqlParameter("@cssManagerUserId", currentParams.CSSManagerUserId));
                    cmd.Parameters.Add(new SqlParameter("@finUserId", currentParams.FinUserId));
                    cmd.Parameters.Add(new SqlParameter("@grnUserId", currentParams.GRNUserId));
                    cmd.Parameters.Add(new SqlParameter("@cssId", currentParams.CSSId));

                    var reader = cmd.ExecuteReader();
                    List<PaymentDashboardGroupModelByCount> groupData = new List<PaymentDashboardGroupModelByCount>();
                    while (reader.Read())
                    {
                        PaymentDashboardGroupModelByCount data = new PaymentDashboardGroupModelByCount();

                        data.Ordinal = Convert.ToInt32(reader.GetValue(0).ToString());
                        data.HeaderTyp = reader.GetValue(1).ToString();
                        data.Region = reader.GetValue(2).ToString();
                        data.Cooling_Month1 = Convert.ToInt32(reader.GetValue(3).ToString());
                        data.Cooling_Month2 = Convert.ToInt32(reader.GetValue(4).ToString());
                        data.Cooling_Month3 = Convert.ToInt32(reader.GetValue(5).ToString());

                        data.HBN_Month1 = Convert.ToInt32(reader.GetValue(6).ToString());
                        data.HBN_Month2 = Convert.ToInt32(reader.GetValue(7).ToString());
                        data.HBN_Month3 = Convert.ToInt32(reader.GetValue(8).ToString());

                        data.PPI_Month1 = Convert.ToInt32(reader.GetValue(9).ToString());
                        data.PPI_Month2 = Convert.ToInt32(reader.GetValue(10).ToString());
                        data.PPI_Month3 = Convert.ToInt32(reader.GetValue(11).ToString());

                        groupData.Add(data);
                    }
                    reader.NextResult();
                    List<PaymentDashboardCSSModelByCount> cssData = new List<PaymentDashboardCSSModelByCount>();
                    while (reader.Read())
                    {
                        PaymentDashboardCSSModelByCount data = new PaymentDashboardCSSModelByCount();

                        data.CSS_Code = reader.GetValue(0).ToString();
                        data.CSS_Name = reader.GetValue(1).ToString();
                        data.BusinessUnit = reader.GetValue(2).ToString();
                        data.Region = reader.GetValue(3).ToString();
                        data.Month1 = Convert.ToInt32(reader.GetValue(4).ToString());
                        data.Month2 = Convert.ToInt32(reader.GetValue(5).ToString());
                        data.Month3 = Convert.ToInt32(reader.GetValue(6).ToString());

                        cssData.Add(data);
                    }
                    DbCommand secondCmd = conn.CreateCommand();
                    secondCmd.CommandText = "usp_DashboardPaymentCount";
                    secondCmd.CommandType = CommandType.StoredProcedure;
                    secondCmd.Parameters.Add(new SqlParameter("@groupBy", "Region"));
                    secondCmd.Parameters.Add(new SqlParameter("@cssManagerUserId", currentParams.CSSManagerUserId));
                    secondCmd.Parameters.Add(new SqlParameter("@finUserId", currentParams.FinUserId));
                    secondCmd.Parameters.Add(new SqlParameter("@grnUserId", currentParams.GRNUserId));
                    secondCmd.Parameters.Add(new SqlParameter("@cssId", currentParams.CSSId));


                    var secondReader = secondCmd.ExecuteReader();
                    List<PaymentDashboardGroupModelByCount> rangeData = new List<PaymentDashboardGroupModelByCount>();
                    while (secondReader.Read())
                    {
                        PaymentDashboardGroupModelByCount data = new PaymentDashboardGroupModelByCount();

                        data.Ordinal = Convert.ToInt32(secondReader.GetValue(0).ToString());
                        data.HeaderTyp = secondReader.GetValue(1).ToString();
                        data.Region = secondReader.GetValue(2).ToString();
                        data.Cooling_Month1 = Convert.ToInt32(secondReader.GetValue(3).ToString());
                        data.Cooling_Month2 = Convert.ToInt32(secondReader.GetValue(4).ToString());
                        data.Cooling_Month3 = Convert.ToInt32(secondReader.GetValue(5).ToString());

                        data.HBN_Month1 = Convert.ToInt32(secondReader.GetValue(6).ToString());
                        data.HBN_Month2 = Convert.ToInt32(secondReader.GetValue(7).ToString());
                        data.HBN_Month3 = Convert.ToInt32(secondReader.GetValue(8).ToString());

                        data.PPI_Month1 = Convert.ToInt32(secondReader.GetValue(9).ToString());
                        data.PPI_Month2 = Convert.ToInt32(secondReader.GetValue(10).ToString());
                        data.PPI_Month3 = Convert.ToInt32(secondReader.GetValue(11).ToString());

                        rangeData.Add(data);
                    }
                    secondReader.Close();
                    secondCmd.Dispose();
                    reportData = new PaymentDashboardModelByCount()
                    {
                        paymentDashboardSummary = groupData,
                        paymentDashboardByCSS = cssData,
                        paymentDashboardSummaryByRange = rangeData

                    };
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportData;
        }
        public SE.API.Models.PaymentDashboardModelByValue GetPaymentDashboardByValue(PaymentDashboardParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            PaymentDashboardModelByValue reportData = new PaymentDashboardModelByValue();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "usp_DashboardPaymentValue";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@groupBy", currentParams.GroupBy));
                    cmd.Parameters.Add(new SqlParameter("@cssManagerUserId", currentParams.CSSManagerUserId));
                    cmd.Parameters.Add(new SqlParameter("@finUserId", currentParams.FinUserId));
                    cmd.Parameters.Add(new SqlParameter("@grnUserId", currentParams.GRNUserId));
                    cmd.Parameters.Add(new SqlParameter("@cssId", currentParams.CSSId));

                    var reader = cmd.ExecuteReader();
                    List<PaymentDashboardGroupModelByValue> groupData = new List<PaymentDashboardGroupModelByValue>();
                    while (reader.Read())
                    {
                        PaymentDashboardGroupModelByValue data = new PaymentDashboardGroupModelByValue();

                        data.Ordinal = Convert.ToInt32(reader.GetValue(0).ToString());
                        data.HeaderTyp = reader.GetValue(1).ToString();
                        data.Region = reader.GetValue(2).ToString();
                        data.Cooling_Month1 = Convert.ToDecimal(reader.GetValue(3).ToString());
                        data.Cooling_Month2 = Convert.ToDecimal(reader.GetValue(4).ToString());
                        data.Cooling_Month3 = Convert.ToDecimal(reader.GetValue(5).ToString());

                        data.HBN_Month1 = Convert.ToDecimal(reader.GetValue(6).ToString());
                        data.HBN_Month2 = Convert.ToDecimal(reader.GetValue(7).ToString());
                        data.HBN_Month3 = Convert.ToDecimal(reader.GetValue(8).ToString());

                        data.PPI_Month1 = Convert.ToDecimal(reader.GetValue(9).ToString());
                        data.PPI_Month2 = Convert.ToDecimal(reader.GetValue(10).ToString());
                        data.PPI_Month3 = Convert.ToDecimal(reader.GetValue(11).ToString());

                        groupData.Add(data);
                    }

                    reader.NextResult();
                    List<PaymentDashboardCSSModelByValue> cssData = new List<PaymentDashboardCSSModelByValue>();
                    while (reader.Read())
                    {
                        PaymentDashboardCSSModelByValue data = new PaymentDashboardCSSModelByValue();

                        data.CSS_Code = reader.GetValue(0).ToString();
                        data.CSS_Name = reader.GetValue(1).ToString();
                        data.BusinessUnit = reader.GetValue(2).ToString();
                        data.Region = reader.GetValue(3).ToString();
                        data.Month1 = Convert.ToDecimal(reader.GetValue(4).ToString());
                        data.Month2 = Convert.ToDecimal(reader.GetValue(5).ToString());
                        data.Month3 = Convert.ToDecimal(reader.GetValue(6).ToString());

                        cssData.Add(data);
                    }


                    DbCommand secondCmd = conn.CreateCommand();
                    secondCmd.CommandText = "usp_DashboardPaymentValue";
                    secondCmd.CommandType = CommandType.StoredProcedure;
                    secondCmd.Parameters.Add(new SqlParameter("@groupBy", "Region"));
                    secondCmd.Parameters.Add(new SqlParameter("@cssManagerUserId", currentParams.CSSManagerUserId));
                    secondCmd.Parameters.Add(new SqlParameter("@finUserId", currentParams.FinUserId));
                    secondCmd.Parameters.Add(new SqlParameter("@grnUserId", currentParams.GRNUserId));
                    secondCmd.Parameters.Add(new SqlParameter("@cssId", currentParams.CSSId));

                    var secondReader = secondCmd.ExecuteReader();
                    List<PaymentDashboardGroupModelByValue> rangeData = new List<PaymentDashboardGroupModelByValue>();
                    while (secondReader.Read())
                    {
                        PaymentDashboardGroupModelByValue data = new PaymentDashboardGroupModelByValue();

                        data.Ordinal = Convert.ToInt32(secondReader.GetValue(0).ToString());
                        data.HeaderTyp = secondReader.GetValue(1).ToString();
                        data.Region = secondReader.GetValue(2).ToString();
                        data.Cooling_Month1 = Convert.ToDecimal(secondReader.GetValue(3).ToString());
                        data.Cooling_Month2 = Convert.ToDecimal(secondReader.GetValue(4).ToString());
                        data.Cooling_Month3 = Convert.ToDecimal(secondReader.GetValue(5).ToString());

                        data.HBN_Month1 = Convert.ToDecimal(secondReader.GetValue(6).ToString());
                        data.HBN_Month2 = Convert.ToDecimal(secondReader.GetValue(7).ToString());
                        data.HBN_Month3 = Convert.ToDecimal(secondReader.GetValue(8).ToString());

                        data.PPI_Month1 = Convert.ToDecimal(secondReader.GetValue(9).ToString());
                        data.PPI_Month2 = Convert.ToDecimal(secondReader.GetValue(10).ToString());
                        data.PPI_Month3 = Convert.ToDecimal(secondReader.GetValue(11).ToString());

                        rangeData.Add(data);
                    }

                    reportData = new PaymentDashboardModelByValue()
                    {
                        paymentDashboardSummary = groupData,
                        paymentDashboardByCSS = cssData,
                        paymentDashboardSummaryByRange = rangeData

                    };
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportData;
        }


        public IEnumerable<SE.API.Models.PurchaseOrderDashboardModel> GetPurchaseOrderDashboard(PurchaseOrderDashboardParameter currentParams)
        {
            DbConnection conn = _context.Database.GetDbConnection();
            List<PurchaseOrderDashboardModel> reportData = new List<PurchaseOrderDashboardModel>();
            try
            {
                if (conn.State.Equals(ConnectionState.Closed)) { conn.Open(); }
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "usp_DashboardPurchaseOrder";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@region", currentParams.Region));
                    cmd.Parameters.Add(new SqlParameter("@cssManagerUserId", currentParams.CSSManagerUserId));
                    cmd.Parameters.Add(new SqlParameter("@finUserId", currentParams.FinUserId));
                    cmd.Parameters.Add(new SqlParameter("@grnUserId", currentParams.GRNUserId));
                    cmd.Parameters.Add(new SqlParameter("@cssId", currentParams.CSSId));

                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        PurchaseOrderDashboardModel data = new PurchaseOrderDashboardModel();

                        data.CSS_Code = reader.GetValue(0).ToString();
                        data.CSS_Name = reader.GetValue(1).ToString();
                        data.BusinessUnit = reader.GetValue(2).ToString();
                        data.Region = reader.GetValue(3).ToString();
                        data.PO_NO = reader.GetValue(4).ToString();
                        data.PO_DATE = Convert.ToDateTime(reader.GetValue(5).ToString());

                        data.HBN_Warranty_Amount = Convert.ToDecimal(reader.GetValue(6).ToString());
                        data.Available_HBN_Warranty_Amount = Convert.ToDecimal(reader.GetValue(7).ToString());
                        data.HBN_AMC_Amount = Convert.ToDecimal(reader.GetValue(8).ToString());
                        data.Available_HBN_AMC_Amount = Convert.ToDecimal(reader.GetValue(9).ToString());

                        data.Labor_AMC_Amount = Convert.ToDecimal(reader.GetValue(10).ToString());
                        data.Available_Labor_AMC_Amount = Convert.ToDecimal(reader.GetValue(11).ToString());
                        data.Labor_Warranty_Amount = Convert.ToDecimal(reader.GetValue(12).ToString());
                        data.Available_Labor_Warranty_Amount = Convert.ToDecimal(reader.GetValue(13).ToString());

                        data.Supply_AMC_Amount = Convert.ToDecimal(reader.GetValue(14).ToString());
                        data.Available_Supply_AMC_Amount = Convert.ToDecimal(reader.GetValue(15).ToString());
                        data.Supply_Warranty_Amount = Convert.ToDecimal(reader.GetValue(16).ToString());
                        data.Available_Supply_Warranty_Amount = Convert.ToDecimal(reader.GetValue(17).ToString());

                        data.Basic_Amount = Convert.ToDecimal(reader.GetValue(18).ToString());
                        data.Available_Basic_Amount = Convert.ToDecimal(reader.GetValue(19).ToString());



                        reportData.Add(data);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (conn.State.Equals(ConnectionState.Open)) { conn.Close(); }
            }

            return reportData;
        }
        #endregion Dashboards


        public bool UploadPPIRateCard()
        {
            DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
            try
            {
                if (dbConnection.State.Equals((object)ConnectionState.Closed))
                    dbConnection.Open();
                using (DbCommand command = dbConnection.CreateCommand())
                {
                    command.CommandText = "[SP_INSERT_PSI_RATE_CARD]";
                    command.CommandType = CommandType.StoredProcedure;
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (dbConnection.State.Equals((object)ConnectionState.Open))
                    dbConnection.Close();
            }
            return true;
        }

        public bool UploadHBNRateCard()
        {
            DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
            try
            {
                if (dbConnection.State.Equals((object)ConnectionState.Closed))
                    dbConnection.Open();
                using (DbCommand command = dbConnection.CreateCommand())
                {
                    command.CommandText = "[SP_INSERT_HBN_RATE_CARD]";
                    command.CommandType = CommandType.StoredProcedure;
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (dbConnection.State.Equals((object)ConnectionState.Open))
                    dbConnection.Close();
            }
            return true;
        }
        public bool UploadCoolingRateCard()
        {
            DbConnection dbConnection = RelationalDatabaseFacadeExtensions.GetDbConnection(((DbContext)this._context).Database);
            try
            {
                if (dbConnection.State.Equals((object)ConnectionState.Closed))
                    dbConnection.Open();
                using (DbCommand command = dbConnection.CreateCommand())
                {
                    command.CommandText = "[SP_INSERT_COOLING_RATE_CARD]";
                    command.CommandType = CommandType.StoredProcedure;
                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (dbConnection.State.Equals((object)ConnectionState.Open))
                    dbConnection.Close();
            }
            return true;
        }

        public async Task<InvoiceSummaryResponseModel> GetInvoiceSummaryAsync(long? cssId, DateTime fromDate, DateTime toDate, string businessUnit, bool isMonthSelected, ILogger _logger)
        {
            try
            {
                DateTime? actualFromDate = null;
                DateTime? actualToDate = null;

                var invoices = await _context.SE_CSS_Invoice
                    .Where(i => i.CSS_Id == cssId)
                    .Select(i => new { i.Inv_Date, i.Status_Type, i.INV_PAID_DATE, i.Month_Name, i.Inv_No })
                    .AsNoTracking()
                    .ToListAsync();

                var workOrders = await _context.SE_Work_Order
                                    .Where(wo => wo.CSS_Id == cssId)
                                    .Select(wo => new { wo.Month_Name })
                                    .Distinct()
                                    .AsNoTracking()
                                    .ToListAsync();

                var monthDates = workOrders.Select(wo =>
                {
                    if (DateTime.TryParse(wo.Month_Name, out var parsedDate))
                    {
                        return parsedDate;
                    }
                    return (DateTime?)null;
                })
                .Where(d => d.HasValue)
                .Select(d => d.Value)
                .OrderBy(d => d)
                .ToList();

                if (monthDates.Any() && !isMonthSelected)
                {
                    DateTime currentMonth = DateTime.Now;

                    actualFromDate = monthDates.First();
                    actualToDate = new DateTime(currentMonth.Year, currentMonth.Month, 1).AddMonths(-1);
                }
                else
                {
                    actualFromDate = fromDate;
                    actualToDate = toDate;
                }

                var filteredInvoices = invoices.Where(i =>
                    {
                        if (string.IsNullOrEmpty(i.Month_Name))
                        {
                            return false;
                        }

                        if (DateTime.TryParse(i.Month_Name, out var monthDate))
                        {
                            return monthDate >= actualFromDate && monthDate <= actualToDate;
                        }

                        return false;
                    }).ToList();

                var filteredWorkOrders = workOrders.Where(i =>
                    {
                        if (string.IsNullOrEmpty(i.Month_Name))
                        {
                            return false;
                        }

                        if (DateTime.TryParse(i.Month_Name, out var monthDate))
                        {
                            return monthDate >= actualFromDate && monthDate <= actualToDate;
                        }

                        return false;
                    }).ToList();

                var expectedTotal = filteredWorkOrders.Count();

                if (!string.IsNullOrEmpty(businessUnit) && businessUnit.Equals("Cooling", StringComparison.OrdinalIgnoreCase))
                {
                    expectedTotal *= 2;
                }

                var actualReceived = filteredInvoices.Count(i => i.Status_Type >= (int)StatusType.PRF_Raised);

                var paymentCleared = filteredInvoices.Count(i => i.Status_Type == (int)StatusType.Invoice_Paid);

                var pendingInvoices = expectedTotal - actualReceived;

                double pctReceived = expectedTotal == 0 ? 0 : Math.Round((double)actualReceived / expectedTotal * 100);
                double pctCleared = actualReceived == 0 ? 0 : Math.Round((double)paymentCleared / expectedTotal * 100);
                double pctPending = expectedTotal == 0 ? 0 : Math.Round((double)pendingInvoices / expectedTotal * 100);

                var clearedMonthly = invoices
                                    .Where(i => i.Status_Type == (int)StatusType.Invoice_Paid && i.INV_PAID_DATE.HasValue)
                                    .AsEnumerable()
                                    .Select(i => new
                                    {
                                        Invoice = i,
                                        ParsedDate = DateTime.TryParseExact(i.Month_Name, "MMMM-yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date) ? date : (DateTime?)null
                                    })
                                    .Where(x => x.ParsedDate.HasValue)
                                    .GroupBy(x => new { x.ParsedDate.Value.Year, x.ParsedDate.Value.Month })
                                    .Select(g => new { year = g.Key.Year, month = g.Key.Month, cleared = g.Count() });

                var pendingMonthly = invoices
                                    .Where(i => i.Status_Type >= (int)StatusType.Invoice_Raised && i.Status_Type <= (int)StatusType.Invoice_Paid && i.Inv_Date.HasValue)
                                    .AsEnumerable()
                                    .Select(i => new
                                    {
                                        Invoice = i,
                                        ParsedDate = DateTime.TryParseExact(i.Month_Name, "MMMM-yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date) ? date : (DateTime?)null
                                    })
                                    .Where(x => x.ParsedDate.HasValue)
                                    .GroupBy(x => new { x.ParsedDate.Value.Year, x.ParsedDate.Value.Month })
                                    .Select(g => new { year = g.Key.Year, month = g.Key.Month, pending = g.Count() });

                var allMonths = clearedMonthly.Select(c => new { c.year, c.month, cleared = c.cleared, pending = 0 })
                    .Concat(pendingMonthly.Select(p => new { p.year, p.month, cleared = 0, pending = p.pending }))
                    .GroupBy(x => new { x.year, x.month })
                    .Select(g => new MonthlyData
                    {
                        Year = g.Key.year,
                        Month = g.Key.month,
                        Cleared = g.Sum(x => x.cleared),
                        PendingInvoices = g.Sum(x => x.pending)
                    })
                    .ToList();

                var existingMonths = allMonths.Select(m => new { m.Year, m.Month }).ToHashSet();

                allMonths.AddRange(
                    monthDates
                        .Where(d => !existingMonths.Contains(new { Year = d.Year, Month = d.Month }))
                        .Select(d => new MonthlyData { Year = d.Year, Month = d.Month, Cleared = 0, PendingInvoices = 0 })
                );

                allMonths = allMonths.OrderBy(x => x.Year).ThenBy(x => x.Month).ToList();


                var pendingInvoiceDetails = filteredInvoices
                                           .Where(i => i.Status_Type >= (int)StatusType.Invoice_Raised && i.Status_Type < (int)StatusType.Invoice_Paid)
                                           .Select(i => new InvoiceSummaryDataDetail
                                           {
                                               InvoiceNumber = i.Inv_No,
                                               PaymentDueDate = i.Inv_Date,
                                               Status = i.Status_Type,
                                               Month = i.Month_Name
                                           })
                                           .OrderBy(i => i.PaymentDueDate)
                                           .ToList();

                return new InvoiceSummaryResponseModel
                {
                    Overall = new OverallSummary
                    {
                        Expected = expectedTotal,
                        Actual = actualReceived,
                        Cleared = paymentCleared,
                        Pending = pendingInvoices,
                        PctReceived = pctReceived,
                        PctCleared = pctCleared,
                        PctPending = pctPending
                    },
                    MonthlyData = allMonths,
                    DateRange = new DateRangeInfo
                    {
                        FromDate = actualFromDate?.ToString("yyyy-MM-dd"),
                        ToDate = actualToDate?.ToString("yyyy-MM-dd"),
                        FromMonth = actualFromDate?.ToString("yyyy-MM"),
                        ToMonth = actualToDate?.ToString("yyyy-MM")
                    },
                    PendingInvoices = pendingInvoiceDetails
                };
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in GetInvoiceSummaryAsync:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw;
            }
        }


        public async Task<RegionalDashboardResponseModel> GetCentralInvoiceSummaryAsync(DateTime fromDate, DateTime toDate, bool isMonthSelected, ILogger _logger)
        {
            try
            {
                var businessUnitMapping = new Dictionary<string, string> { { "HBN", "HBN" }, { "COOLING", "Cooling" }, { "PPI", "PPI" }, { "PP&I", "PPI" } };

                var regions = new[] { "North", "South", "East", "West" };
                var woBusinessUnits = businessUnitMapping.Keys.ToList();

                var response = new RegionalDashboardResponseModel
                {
                    BusinessUnits = new List<BusinessUnitSummary>()
                };

                var activeCssIds = await _context.SE_Work_Order.Where(wo => woBusinessUnits.Contains(wo.WO_BusinessUnit.ToUpper()))
                                   .Select(wo => wo.CSS_Id)
                                   .Distinct()
                                   .ToListAsync();

                if (!activeCssIds.Any())
                {
                    _logger.LogWarning("No active CSS found with work orders for specified business units");
                    return response;
                }

                var workOrderMonths = await _context.SE_Work_Order
                    .Where(wo => activeCssIds.Contains(wo.CSS_Id) &&
                                woBusinessUnits.Contains(wo.WO_BusinessUnit.ToUpper()) &&
                                !string.IsNullOrEmpty(wo.Month_Name))
                    .Select(wo => wo.Month_Name)
                    .ToListAsync();

                DateTime? actualFromDate = null;
                DateTime? actualToDate = null;

                if (workOrderMonths.Any())
                {
                    var parsedMonths = workOrderMonths
                        .Select(m => DateTime.TryParse(m, out var date) ? new DateTime(date.Year, date.Month, 1) : (DateTime?)null)
                        .Where(d => d.HasValue)
                        .Select(d => d.Value)
                        .ToList();

                    if (parsedMonths.Any())
                    {
                        actualFromDate = parsedMonths.Min();
                        actualToDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).AddMonths(-1);
                    }
                }

                var allCss = await _context.SE_CSS_Master
                             .Where(c => activeCssIds.Contains(c.Id))
                             .Select(c => new
                             {
                                 c.Id,
                                 c.Region,
                                 c.CSS_Manager
                             })
                             .ToListAsync();


                var allInvoices = await _context.SE_CSS_Invoice
                                 .Where(i => activeCssIds.Contains(i.CSS_Id) &&
                                            woBusinessUnits.Contains(i.WO_BusinessUnit.ToUpper()))
                                 .Select(i => new
                                 {
                                     i.CSS_Id,
                                     i.WO_BusinessUnit,
                                     i.Month_Name,
                                     i.Status_Type
                                 })
                                 .ToListAsync();

                if (!allInvoices.Any())
                {
                    _logger.LogWarning("No invoices found in SE_CSS_Invoice");
                    return response;
                }

                var allWorkOrders = await _context.SE_Work_Order
                                   .Where(wo => activeCssIds.Contains(wo.CSS_Id) &&
                                               woBusinessUnits.Contains(wo.WO_BusinessUnit.ToUpper()))
                                   .Select(wo => new
                                   {
                                       wo.CSS_Id,
                                       wo.Month_Name,
                                       wo.WO_BusinessUnit
                                   })
                                   .ToListAsync();

                DateTime currentMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).AddMonths(-1);
                DateTime? rangeStart = null;
                DateTime? rangeEnd = null;

                if (isMonthSelected)
                {
                    rangeStart = new DateTime(fromDate.Year, fromDate.Month, 1);
                    rangeEnd = new DateTime(toDate.Year, toDate.Month, 1);
                }

                foreach (var mapping in businessUnitMapping)
                {
                    string woBusinessUnit = mapping.Key;
                    string displayName = mapping.Value;

                    var businessUnitInvoices = allInvoices.Where(i => i.WO_BusinessUnit?.ToUpper() == woBusinessUnit).ToList();

                    if (!businessUnitInvoices.Any())
                    {
                        _logger.LogWarning($"No invoices found for business unit: {woBusinessUnit}");
                        continue;
                    }

                    var cssIdsInBusinessUnit = businessUnitInvoices.Select(i => i.CSS_Id).Distinct().ToList();
                    var cssInBusinessUnit = allCss.Where(c => cssIdsInBusinessUnit.Contains(c.Id)).ToList();
                    int invoicesPerMonth = woBusinessUnit.Equals("COOLING", StringComparison.OrdinalIgnoreCase) ? 2 : 1;

                    var cssWorkOrderMonthsGrouped = allWorkOrders
                        .Where(wo => cssIdsInBusinessUnit.Contains(wo.CSS_Id) &&
                                     wo.WO_BusinessUnit?.Equals(woBusinessUnit, StringComparison.OrdinalIgnoreCase) == true &&
                                     !string.IsNullOrEmpty(wo.Month_Name))
                        .Select(wo => new
                        {
                            wo.CSS_Id,
                            MonthDate = DateTime.TryParse(wo.Month_Name, out var parsedDate)
                                ? new DateTime(parsedDate.Year, parsedDate.Month, 1)
                                : (DateTime?)null
                        })
                        .Where(x => x.MonthDate.HasValue)
                        .GroupBy(x => x.CSS_Id)
                        .Select(g => new
                        {
                            CssId = g.Key,
                            Months = g.Select(x => x.MonthDate.Value).Distinct().OrderBy(d => d).ToList()
                        })
                        .ToList();

                    int overallExpected = cssWorkOrderMonthsGrouped.Sum(css =>
                    {
                        if (!css.Months.Any())
                            return 0;

                        DateTime earliestMonth;

                        if (isMonthSelected)
                        {
                            var monthsInRange = css.Months
                                .Where(d => d >= rangeStart.Value && d <= rangeEnd.Value)
                                .ToList();

                            if (!monthsInRange.Any())
                                return 0;

                            earliestMonth = monthsInRange.First();
                        }
                        else
                        {
                            earliestMonth = css.Months.First();
                        }

                        int monthsDifference = ((currentMonth.Year - earliestMonth.Year) * 12) +
                                              (currentMonth.Month - earliestMonth.Month) + 1;

                        return Math.Max(1, monthsDifference) * invoicesPerMonth;
                    });

                    var filteredInvoices = businessUnitInvoices;
                    if (isMonthSelected)
                    {
                        filteredInvoices = businessUnitInvoices.Where(i =>
                        {
                            if (string.IsNullOrEmpty(i.Month_Name)) return false;
                            if (DateTime.TryParse(i.Month_Name, out var monthDate))
                            {
                                DateTime normalizedDate = new DateTime(monthDate.Year, monthDate.Month, 1);
                                return normalizedDate >= rangeStart.Value && normalizedDate <= rangeEnd.Value;
                            }
                            return false;
                        }).ToList();
                    }

                    int overallActual = filteredInvoices.Count(i => i.Status_Type >= (int)StatusType.PRF_Raised);
                    int overallCleared = filteredInvoices.Count(i => i.Status_Type == (int)StatusType.Invoice_Paid);

                    var buSummary = new BusinessUnitSummary
                    {
                        BusinessUnit = displayName,
                        Overall = new OverallSummary
                        {
                            Expected = overallExpected,
                            Actual = overallActual,
                            Cleared = overallCleared,
                            Pending = overallActual - overallCleared,
                            PctReceived = overallExpected == 0 ? 0 : Math.Round((double)overallActual / overallExpected * 100),
                            PctCleared = overallExpected == 0 ? 0 : Math.Round((double)overallCleared / overallExpected * 100),
                            PctPending = overallExpected == 0 ? 0 : Math.Round((double)(overallActual - overallCleared) / overallExpected * 100)
                        },
                        Regions = new List<RegionalSummary>()
                    };

                    var regionalSummaries = cssInBusinessUnit
                        .Where(c => !string.IsNullOrEmpty(c.Region))
                        .GroupBy(c => c.Region, StringComparer.OrdinalIgnoreCase)
                        .Select(regionGroup =>
                        {
                            var region = regions.FirstOrDefault(r => r.Equals(regionGroup.Key, StringComparison.OrdinalIgnoreCase)) ?? regionGroup.Key;
                            var regionalCssIds = regionGroup.Select(c => c.Id).ToList();
                            var managers = regionGroup
                                .Select(c => c.CSS_Manager)
                                .Where(m => !string.IsNullOrEmpty(m))
                                .Distinct()
                                .ToList();

                            int regionalExpected = cssWorkOrderMonthsGrouped
                                .Where(css => regionalCssIds.Contains(css.CssId))
                                .Sum(css =>
                                {
                                    if (!css.Months.Any())
                                        return 0;

                                    DateTime earliestMonth;

                                    if (isMonthSelected)
                                    {
                                        var monthsInRange = css.Months
                                            .Where(d => d >= rangeStart.Value && d <= rangeEnd.Value)
                                            .ToList();

                                        if (!monthsInRange.Any())
                                            return 0;

                                        earliestMonth = monthsInRange.First();
                                    }
                                    else
                                    {
                                        earliestMonth = css.Months.First();
                                    }

                                    int monthsDifference = ((currentMonth.Year - earliestMonth.Year) * 12) +
                                                          (currentMonth.Month - earliestMonth.Month) + 1;

                                    return Math.Max(1, monthsDifference) * invoicesPerMonth;
                                });

                            var regionalInvoices = filteredInvoices
                                .Where(i => regionalCssIds.Contains(i.CSS_Id))
                                .ToList();

                            var regionalActual = regionalInvoices.Count(i => i.Status_Type >= (int)StatusType.PRF_Raised);
                            var regionalCleared = regionalInvoices.Count(i => i.Status_Type == (int)StatusType.Invoice_Paid);

                            return new RegionalSummary
                            {
                                Region = region,
                                Spocs = managers,
                                Expected = regionalExpected,
                                Actual = regionalActual,
                                Cleared = regionalCleared,
                                PctReceived = regionalExpected == 0 ? 0 : Math.Round((double)regionalActual / regionalExpected * 100),
                                PctCleared = regionalExpected == 0 ? 0 : Math.Round((double)regionalCleared / regionalExpected * 100)
                            };
                        })
                        .ToList();

                    buSummary.Regions.AddRange(regionalSummaries);

                    response.BusinessUnits.Add(buSummary);
                }

                response.DateRange = new DateRangeInfo
                {
                    FromDate = actualFromDate?.ToString("yyyy-MM-dd"),
                    ToDate = actualToDate?.ToString("yyyy-MM-dd"),
                    FromMonth = actualFromDate?.ToString("yyyy-MM"),
                    ToMonth = actualToDate?.ToString("yyyy-MM")
                };

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in GetCentralInvoiceSummaryAsync: " + ex.Message +
                                 " ***Inner Exception*** " + ex.InnerException?.ToString());
                throw;
            }
        }
    }
}
