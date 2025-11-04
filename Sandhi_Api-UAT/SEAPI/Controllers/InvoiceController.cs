using AutoMapper;
using SE.API.Entities;
using SE.API.Helpers;
using SE.API.Models;
using SE.API.Services;
using Marvin.Cache.Headers;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using SE.API.ResourceParameters;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Http;
using SE.API.Utilities;
using System.Reflection.Metadata;
using iTextSharp.text.html.simpleparser;
using System.IO;
using iTextSharp.text.pdf;
using iTextSharp.text;
using System.Globalization;
using System.Data;
using ClosedXML.Excel;
using DocumentFormat.OpenXml.Wordprocessing;
using Microsoft.AspNetCore.JsonPatch.Internal;

namespace SE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [ResponseCache(CacheProfileName = "240SecsCacheProfile")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public class InvoiceController : BaseController
    {


        public InvoiceController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }



        [HttpGet(Name = "GetInvoicesList")]
        [Route("GetInvoices")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetInvoicesList([FromQuery] InvoiceResourceParameter invoiceResourceParameter,
            [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                invoiceResourceParameter.Statuses = new List<string>();
                List<Int64> cssIds = new List<Int64>();
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    List<CSS> lstCss = _seRepository.GetCSS(new CSSResourceParameter() { CSSManagerId = this.UserModel.Id }).ToList();
                    cssIds.AddRange(lstCss.Select(u => u.Id).ToList());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.PRF_Raised).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.PO_Waiting).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Raised).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Validated).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Rejected).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.GRN_Clarification).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.GRN_Raised).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Paid).ToString());

                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser))
                {
                    List<CSS> lstCss = _seRepository.GetCSS(new CSSResourceParameter() { FINUserId = this.UserModel.Id }).ToList();
                    cssIds.AddRange(lstCss.Select(u => u.Id).ToList());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Raised).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Validated).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Rejected).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.GRN_Clarification).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.GRN_Raised).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Paid).ToString());
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.SCMUser))
                {
                    List<CSS> lstCss = _seRepository.GetCSS(new CSSResourceParameter() { GRNUserId = this.UserModel.Id }).ToList();
                    cssIds.AddRange(lstCss.Select(u => u.Id).ToList());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Validated).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.GRN_Clarification).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.GRN_Raised).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Paid).ToString());
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    cssIds.Add(Convert.ToInt64(this.UserModel.CSSCode));
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.PRF_Raised).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Raised).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Validated).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Rejected).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.GRN_Clarification).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.GRN_Raised).ToString());
                    invoiceResourceParameter.Statuses.Add(((Int32)StatusType.Invoice_Paid).ToString());
                }
                invoiceResourceParameter.CSSIds = cssIds;

                var invoices = _seRepository.GetInvoiceList(invoiceResourceParameter, this.UserModel.UserType);
                if (invoices == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(invoiceResourceParameter.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                var shapedData_temp = _mapper.Map<IEnumerable<InvoiceModel>>(invoices);
               
              
                if (invoiceResourceParameter.BusinessUnit.ToLower() == "cooling")
                {
                    var coolingProductCategoryList = _seRepository.GetProductCategoryCooling();
                    AddProductCategoryTypeToWorkOrders(shapedData_temp, coolingProductCategoryList);
                }
                var shapedData = shapedData_temp.ShapeData(invoiceResourceParameter.Fields);
                return Ok(shapedData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Invoice:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }


        private void AddProductCategoryTypeToWorkOrders(IEnumerable<InvoiceModel> invoices, IEnumerable<ProductCategoryCooling> coolingProductCategoryList)
        {
            foreach (var invoice in invoices)
            {
                // Loop through WorkOrders
                foreach (var workOrder in invoice.WorkOrders)
                {
                    var matchingProduct = coolingProductCategoryList.FirstOrDefault(p => p.Group == workOrder.Product_Grouping?.Trim());
                    if (matchingProduct != null)
                    {
                        workOrder.Product_Category_Type = matchingProduct.Type;
                    }
                }

                // Loop through SupplyWorkOrders
                foreach (var supplyWorkOrder in invoice.SupplyWorkOrders)
                {
                    var matchingProduct = coolingProductCategoryList.FirstOrDefault(p => p.Group == supplyWorkOrder.Product_Grouping?.Trim());
                    if (matchingProduct != null)
                    {
                        supplyWorkOrder.Product_Category_Type = matchingProduct.Type;
                    }
                }
            }
        }


        [HttpGet(Name = "GetNoDueInvoicesList")]
        [Route("GetNoDueInvoices")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetNoDueInvoicesList([FromHeader(Name = "Accept")] string contentType)
        {
            try
            {
                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.CSSUser))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                InvoiceResourceParameter invoiceResourceParameter = new InvoiceResourceParameter();
                invoiceResourceParameter.CSSIds = new List<Int64>() { Convert.ToInt64(this.UserModel.CSSCode) };

                var invoices = _seRepository.GetNoDueInvoiceList(invoiceResourceParameter);
                if (invoices == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(invoiceResourceParameter.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                var shapedData = _mapper.Map<IEnumerable<InvoiceModel>>(invoices)
                    .ShapeData(invoiceResourceParameter.Fields);

                return Ok(shapedData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get No Due List:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }
        [HttpPost(Name = "SetNoDueDate")]
        [Route("SetNoDueDate")]
        /*
         * Parameters required are CSSId, Invoice Ids (comma seperated string)
         */
        public async Task<IActionResult> SetNoDueDate([FromBody] InvoiceUpdateResourceParameter invParams)
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.CSSUser))
                {
                    return Unauthorized();
                }
                // Set Status value based on the user and status value.


                if (ModelState.IsValid)
                {
                    invParams.UserName = this.UserModel.UserName;
                    var retVal = _seRepository.SetNoDueInvoiceStatus(invParams);
                    if (retVal == true)
                    {
                        try
                        {
                            SendNoDueEmail(invParams.CSSId ?? -1, invParams.NoDueAttachment);
                            await SendEmail();
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError("Error in Invoice Set No Due Date:" + ex.Message);
                        }
                        return StatusCode(StatusCodes.Status200OK);
                    }
                }
                return BadRequest();
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Set No Due Date:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return BadRequest();
            }
        }

        private bool SendNoDueEmail(long cssId, string noDueFile)
        {
            CSS css = _seRepository.GetCSS(new CSSResourceParameter() { CSSId = cssId.ToString() }).First();
            var folderPath = _config.GetSection("ExcelImport").GetValue<String>("Folder");
            var emailSubject = "NO DUE CERTIFICATE OF CSS __CSSCODE__ ";
            var emailBody = "Please find attached the NO DUE CERTIFICATE OF __CSSCODE__ - __CSSNAME__.";
            emailSubject = emailSubject.Replace("__CSSCODE__", css.CSS_Code);
            emailBody = emailBody.Replace("__CSSCODE__", css.CSS_Code).Replace("__CSSNAME__", css.CSS_Name_as_per_Oracle_SAP);

            string pdfFilePath = folderPath + "/" + noDueFile;
            byte[] bytes = System.IO.File.ReadAllBytes(pdfFilePath);
            var collectorEmail = _config.GetSection("Email").GetValue<String>("CollectorEmail");
            Email.SendEmail(_config, emailSubject, emailBody, bytes, collectorEmail, "No Due");
            return true;
        }

        /*
         * update invoice -CSS
         * request new po value - this should clear the existing PO Id and mark the invoice as "Pending PO"
         * update - invoice date, invoice no, invoice amount and upload an attachment
         * 
         * Finance User
         * - Approve/Reject Invoice with reason
         * 
         * SCM User
         * - Enter GRN No & Remarks
         */

        [HttpPost(Name = "SetInvoiceStatus")]
        [Route("SetInvoiceStatus")]
        public async Task<IActionResult> SetStatus([FromBody] InvoiceUpdateResourceParameter invParams)
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    return Unauthorized();
                }
                // Set Status value based on the user and status value.
                string errString = "";
                if (!CheckStatus(invParams, out errString))
                {
                    return StatusCode(StatusCodes.Status400BadRequest, new ResponseModel { Status = "Bad Request", Message = errString });
                }

                if (ModelState.IsValid)
                {
                    invParams.UserName = this.UserModel.UserName;
                    var retVal = _seRepository.SetInvoiceStatus(invParams);
                    if (retVal == true)
                    {
                        try
                        {
                            if (invParams.StatusType == (Int32)StatusType.GRN_Raised)
                            {
                                _seRepository.SendCollectorEmail(invParams.InvId ?? -1,_logger,_config);
                            }

                            _logger.LogInformation("call start SendEmail");
                            await SendEmail();
                            _logger.LogInformation("call end SendEmail");

                        }
                        catch (Exception ex)
                        {
                            _logger.LogError("Error in Invoice SetInvoiceStatus:" + ex.Message + "  " + ex.InnerException);
                        }
                        return StatusCode(StatusCodes.Status200OK);
                    }
                }
                return BadRequest();
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Inv Set Status:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return BadRequest();
            }
        }

        private bool CheckStatus(InvoiceUpdateResourceParameter invParams, out string errString)
        {
            string tmpString = "";
            if ((invParams.StatusType ?? -1) < 7 && (invParams.StatusType ?? -1) > 14)
            {
                tmpString += "Enter a valid Status<br/>";
            }
            if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
            {
                // can be new po
                // invoice update
                if (invParams.StatusType != (int)StatusType.PO_Waiting && invParams.StatusType != (int)StatusType.Invoice_Raised)
                {
                    tmpString += "Enter a valid Status<br/>";
                }

                if (invParams.StatusType == (int)StatusType.Invoice_Raised)
                {
                    if (String.IsNullOrEmpty(invParams.RefNo))
                    {
                        tmpString += "Enter a valid Invoice Number.<br/>";
                    }
                    if (!invParams.RefDate.HasValue)
                    {
                        tmpString += "Enter a valid Invoice Date.<br/>";
                    }
                    //if ((invParams.InvAmount ?? -1) == -1)
                    //{
                    //    tmpString += "Enter a valid Invoice Amount.<br/>";
                    //}
                }
                if (!string.IsNullOrEmpty(invParams.RefNo))
                {
                    List<long> lstCssIds = new List<long>();
                    lstCssIds.Add(invParams.CSSId ?? -1);
                    List<string> listStatuses = new List<string>();

                    listStatuses.Add(((Int32)StatusType.Invoice_Raised).ToString());
                    listStatuses.Add(((Int32)StatusType.Invoice_Validated).ToString());
                    listStatuses.Add(((Int32)StatusType.Invoice_Paid).ToString());
                    List<Invoice> lstInvoice = _seRepository.GetInvoiceList(new InvoiceResourceParameter() { CSSIds = lstCssIds, InvNo = invParams.RefNo, Statuses = listStatuses }).ToList();
                    if (lstInvoice.Count() > 0)
                    {
                        tmpString += "Invoice Number cannot be duplicated.<br/>";
                    }
                }

            }
            else if ((this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser))
            {
                // can be invoice approval /reject
                // payment processed
                if (invParams.StatusType != (int)StatusType.Invoice_Validated
                    && invParams.StatusType != (int)StatusType.Invoice_Rejected)
                {
                    tmpString += "Enter a valid Status<br/>";
                }

            }
            else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CentralUser))
            {
                if (invParams.StatusType != (int)StatusType.Invoice_Paid)
                {
                    tmpString += "Enter a valid Status<br/>";
                }
            }
            else if ((this.UserModel.UserType ?? -1) == ((int)UserType.SCMUser))
            {
                if (invParams.StatusType != (int)StatusType.GRN_Raised && invParams.StatusType != (int)StatusType.GRN_Clarification)
                {
                    tmpString += "Enter a valid Status<br/>";
                }

                if (invParams.StatusType == (int)StatusType.GRN_Raised)
                {
                    if (String.IsNullOrEmpty(invParams.RefNo))
                    {
                        tmpString += "Enter a valid GRN Number.<br/>";
                    }
                    if (!invParams.RefDate.HasValue)
                    {
                        tmpString += "Enter a valid GRN Date.<br/>";
                    }
                }
                else if (invParams.StatusType == (int)StatusType.GRN_Clarification)
                {
                    if (String.IsNullOrEmpty(invParams.Remarks))
                    {
                        tmpString += "Enter a valid Remarks.<br/>";
                    }
                }

            }
            if (string.IsNullOrEmpty(invParams.BusinessUnit))
            {
                tmpString += "Enter a valid Business Unit<br/>";
            }
            if ((invParams.CSSId ?? -1) == -1)
            {
                tmpString += "Enter a valid CSS<br/>";
            }
            if ((invParams.InvId ?? -1) == -1)
            {
                tmpString += "Enter a valid Invoice<br/>";
            }

            errString = tmpString;
            if (!string.IsNullOrEmpty(tmpString))
            {
                return false;
            }
            return true;
        }

      
       
        private string GenerateCollectorHtml_notworking(List<Invoice> lstInvoice)
        {
            var str = _config.GetSection("CollectorEmail").GetValue<String>("Template");
            var seLogo = _config.GetSection("CollectorEmail").GetValue<String>("SELogo");
            //List<Invoice> lstInvoice = _seRepository.GetInvoiceList(new InvoiceResourceParameter() { InvId = invId }).ToList();
            if (lstInvoice.Count > 0)
            {
                List<WorkOrder> lstWorkOrders = _seRepository.GetWorkOrderList(new WorkOrderResourceParameter() { InvId = lstInvoice.First().Id }).ToList();
                var strHead = "";
                var strWO = "";
                foreach (Invoice inv in lstInvoice)
                {
                    //strHead += "<table style='width:100%'>";
                    //strHead += "<tr><th colspan='3'><b>Partner</b>:" + inv.CSS.CSS_Code + "  " + inv.CSS.CSS_Name_as_per_Oracle_SAP + "</th></tr>";
                    //strHead += "<tr><th>PRF No.:" + inv.PRF_No + "</th>";
                    //strHead += "<th>Inv No.:" + inv.Inv_No + "</th>";
                    //strHead += "<th>GRN No.:" + inv.GRN_No + "</th>";
                    //strHead += "</tr><tr>";
                    //strHead += "<th>PRF Date.:" + inv.PRF_Gen_Date.ToString("dd-MMM-yyyy") + "</th>";
                    //strHead += "<th>Inv Date.:" + inv.Inv_Date?.ToString("dd-MMM-yyyy") + "</th>";
                    //strHead += "<th>GRN Date.:" + inv.GRN_GEN_DATE?.ToString("dd-MMM-yyyy") + "</th>";
                    //strHead += "</tr>";
                    //foreach(InvoiceDetail invDetail in inv.InvoiceDetails)
                    //{
                    //    strHead+= "<tr><th colspan='3'><b>" + invDetail.AMC_Warranty_Flag + "</b>:" + invDetail.INV_Amt + "</th></tr>";
                    //}
                    //strHead += "<tr><th colspan='3'><b>Invoice Amount after Gradation (inc.Tax)</b>:" + inv.Inc_Tax_Amt + "</th></tr>";
                    //strHead += "</table>";
                    strHead = "<table width='100%' border='1'>";
                    strHead += "<tr>";
                    strHead += "<th align='left' colspan='7'><b>PAYMENT REQUEST</b></th>";
                    strHead += "</tr>";
                    strHead += "<tr>";
                    strHead += "<td colspan='4' style='height: 70px; text-align-last: center;'>";
                    strHead += "<span style='color: rgb(0,149,75);font-size: 23px;word-spacing: -1px;'><b>Schneider Electric</b></span>";
                    strHead += "</td>";
                    strHead += "<td colspan='3' align='left'>";
                    strHead += "<font face='sans-serif' size='1'>Schneider Electric ITBU India Pvt. Ltd.<br/>";
                    strHead += "Bearys Global Research Triangle( BGRT ),63/3B, Gorvigere Village,Bidarahalli Hobli<br/>Whitefield Ashram road,Bangalore – 560067</font>";
                    strHead += "</td>";
                    strHead += "</tr>";
                    strHead += "<tr>";
                    strHead += "<td colspan='4' ><font face='sans-serif' size='1'>From:</font></td>";
                    strHead += "<td colspan='3' ><font face='sans-serif' size='1'>To:<b>Finance</b>&nbsp;&nbsp;&nbsp;&nbsp;Control No:___________</font></td>";
                    strHead += "</tr>";
                    strHead += "<tr>";
                    strHead += "<td colspan='4' ><font face='sans-serif' size='1'>Cheque Payable to:<br/><b>" + inv.CSS.CSS_Name_as_per_Oracle_SAP + "</b></font></td>";
                    strHead += "<td colspan='3' ><font face='sans-serif' size='1'>";
                    strHead += "Request Date  :" + DateTime.Now.ToString("dd/MM/yyyy") + "		<br/>";
                    strHead += "Payment Amount:";
                    strHead += "DD /Payorder payable at(Place)";
                    strHead += "</font></td>";
                    strHead += "</tr>";
                    strHead += "<tr>";
                    strHead += "<td width='15%'><font face='sans-serif' size='1'><b>Inv.No.</b></font></td>";
                    strHead += "<td width='10%'><font face='sans-serif' size='1'><b>Date</b></font></td>";
                    strHead += "<td  width='10%'><font face='sans-serif' size='1'><b>Amount</b></font></td>";
                    strHead += "<td width='10%'><font face='sans-serif' size='1'><b>Amount with Tax</b></font></td>";
                    strHead += "<td width='15%' ><font face='sans-serif' size='1'><b>PO No.</b></font></td>";
                    strHead += "<td width='15%'><font face='sans-serif' size='1'><b>GRN</b></font></td>";
                    strHead += "<td  width='25%'><font face='sans-serif' size='1'><b>Remarks</b></font></td>";
                    strHead += "</tr>";
                    strHead += "<tr >";
                    strHead += "<td ><font face='sans-serif' size='1'>" + inv.Inv_No + "</font></td>";
                    strHead += "<td ><font face='sans-serif' size='1'>" + inv.Inv_Date?.ToString("dd-MMM-yyyy") + "</font></td>";
                    strHead += "<td><font face='sans-serif' size='1'>" + inv.Inv_Amt + "</font></td>";
                    strHead += "<td><font face='sans-serif' size='1'>" + inv.Inc_Tax_Amt + "</font></td>";
                    strHead += "<td ><font face='sans-serif' size='1'>" + inv.PurchaseOrder.PO_NO + "</font></td>";
                    strHead += "<td ><font face='sans-serif' size='1'>" + inv.GRN_No + "</font></td>";
                    strHead += "<td><font face='sans-serif' size='1'>" + inv.Remarks + "</font></td>";
                    strHead += "</tr>";
                    strHead += "<tr >";
                    strHead += "<td >&nbsp;<br /></td>";
                    strHead += "<td >&nbsp;<br /></td>";
                    strHead += "<td>&nbsp;<br /></td>";
                    strHead += "<td>&nbsp;<br /></td>";
                    strHead += "<td >&nbsp;<br /></td>";
                    strHead += "<td >&nbsp;<br /></td>";
                    strHead += "<td>&nbsp;<br /></td>";
                    strHead += "</tr>";
                    strHead += "<tr >";
                    strHead += "<td >&nbsp;<br /></td>";
                    strHead += "<td >&nbsp;<br /></td>";
                    strHead += "<td>&nbsp;<br /></td>";
                    strHead += "<td>&nbsp;<br /></td>";
                    strHead += "<td >&nbsp;<br /></td>";
                    strHead += "<td >&nbsp;<br /></td>";
                    strHead += "<td>&nbsp;<br /></td>";
                    strHead += "</tr>";
                    strHead += "<tr >";
                    strHead += "<td><font face='sans-serif' size='1'><b>Total: &nbsp;</b></font></td>";
                    strHead += "<td >&nbsp;</td>";
                    strHead += "<td><font face='sans-serif' size='1'><b>" + inv.Inv_Amt + "</b></font></td>";
                    strHead += "<td><font face='sans-serif' size='1'><b>" + inv.Inc_Tax_Amt + "</b></font></td>";
                    strHead += "<td >&nbsp;</td>";
                    strHead += "<td >&nbsp;</td>";
                    strHead += "<td>&nbsp;</td>";
                    strHead += "</tr>";
                    strHead += "</table>";

                    var i = 1;
                    strWO = "<table width='100%' cellpadding='2' cellspacing='2'><tr><th bgcolor='#bbb'>WO Number</th><th bgcolor='#bbb'>Month</th><th  bgcolor='#bbb'>CSS Code</th><th  bgcolor='#bbb'>Partner Account</th><th bgcolor='#bbb'>Claim Type</th><th bgcolor='#bbb'>Labour Cost</th><th bgcolor='#bbb'>Supply Cost</th><th bgcolor='#bbb'>Claim</th></tr>";
                    /*if (lstInvoice.First().WO_BusinessUnit == "Cooling")
                    {
                        if (lstInvoice.First().Inv_Type == "Labour")
                        {
                            strWO += "<th bgcolor='#bbb'>Labour Cost</th></tr>";
                        }
                        else
                        {
                            strWO += "<th bgcolor='#bbb'>Supply Cost</th></tr>";
                        }
                    }
                    else
                    {
                        strWO += "<th bgcolor='#bbb'>Claim</th></tr>";
                    }*/
                    foreach (WorkOrder workOrder in lstWorkOrders)
                    {
                        if (i % 2 == 0)
                        {
                            strWO += "<tr bgcolor='#eee'>";
                        }
                        else
                        {
                            strWO += "<tr>";
                        }
                        strWO += "<td><font face='sans-serif' size='1'>" + workOrder.Work_Order_Number + "</font></td>";
                        strWO += "<td><font face='sans-serif' size='1'>" + workOrder.Month_Name + "</font></td>";
                        strWO += "<td><font face='sans-serif' size='1'>" + (workOrder.CSS.CSS_Code ?? "") + "</font></td>";
                        strWO += "<td><font face='sans-serif' size='1'>" + workOrder.Installed_At_Account + "</font></td>";
                        strWO += "<td><font face='sans-serif' size='1'>" + (workOrder.Claim_Type ?? "") + "</font></td>";
                        strWO += "<td><font face='sans-serif' size='1'>" + workOrder.LABOUR_COST + "</font></td>";
                        strWO += "<td><font face='sans-serif' size='1'>" + workOrder.SUPPLY_COST + "</font></td>";
                        strWO += "<td><font face='sans-serif' size='1'>" + workOrder.Claim + "</font></td>";
                        /*
                        if (inv.WO_BusinessUnit == "Cooling")
                        {
                            if (inv.Inv_Type == "Labour")
                            {
                                strWO += "<td><font face='sans-serif' size='1'>" + workOrder.LABOUR_COST + "</font></td>";
                            }
                            else
                            {
                                strWO += "<td><font face='sans-serif' size='1'>" + workOrder.SUPPLY_COST + "</font></td>";
                            }
                        }
                        else
                        {
                            strWO += "<td><font face='sans-serif' size='1'>" + workOrder.Claim + "</font></td>";
                        }*/
                        strWO += "</tr>";
                        i++;
                    }
                    strWO += "</table>";
                }
                var invoice = lstInvoice.FirstOrDefault();
                var Requestor = _config.GetSection("ApproverList").GetValue<String>("Requestor");
                var ApprovedBy = _config.GetSection("ApproverList").GetValue<String>("ApprovedBy");

                var approvalList = "<table border='1'>";
                approvalList += "<tr >";
                approvalList += "<th align='left' colspan='7'><b>Approver List :</b></th>";
                approvalList += "</tr>";
                approvalList += "<tr>";
                approvalList += "<td colspan='2'><font face='sans-serif' size='1'><b>PARTNER MANAGER</b><br/>" + invoice.CSS.CSS_Manager + "<br>" + invoice?.PRF_Gen_Date.ToString("M/d/yyyy h:mm:ss tt") + "</font></td>";
                approvalList += "<td colspan='1'><font face='sans-serif' size='1'><b>FINANCE</b><br/> " + invoice.CSS.Invoice_Validator_from_Finance_Team + "<br>" + invoice?.FIN_APPROVE_DATE.Value.ToString("M/d/yyyy h:mm:ss tt") + "</font></td>";
                approvalList += "<td colspan='2'><font face='sans-serif' size='1'><b>REQUESTER</b><br/>" + Requestor + "<br/>" + invoice?.GRN_Date.Value.ToString("M/d/yyyy h:mm:ss tt") + "</font></td>";
                approvalList += "<td colspan='2'><font face='sans-serif' size='1'><b>APPROVED BY</b><br/>" + ApprovedBy + "<br/> " + invoice?.GRN_Date.Value.ToString("M/d/yyyy h:mm:ss tt") + "</font></td>";
                approvalList += "</tr>";
                approvalList += "<tr ><td colspan='7'><font face='sans-serif' size='1'>Note : This document generated by Sandhi Application. No signature required.</font></td></tr>";
                approvalList += "</table><br/><br/><br/>";

                str = str.Replace("___BODY___", strHead + approvalList + strWO);
            }
            return str;
        }
       
     
       
        [HttpPost(Name = "SetStatusByExcel")]
        [Route("SetStatusByExcel")]
        public async Task<IActionResult> SetStatusByExcel(string fileName)
        {
            //    InvoiceController invoiceController = this;
            //    try
            //    {
            //        int? nullable = invoiceController.UserModel.UserType;
            //        if ((nullable ?? -1) == 2)
            //            return (IActionResult)invoiceController.Unauthorized();
            //        string[] formats = { "dd-MM-yyyy HH:mm:ss", "MM/dd/yyyy", "yyyy-MM-dd" };
            //        DateTime parsedDate;

            //        foreach (InvoiceUpdateDetails user in invoiceController._seRepository.ExcelOrCSVDatas<InvoiceUpdateDetails>(fileName, invoiceController._config, (ILogger)invoiceController._logger))
            //        {
            //            try
            //            {
            //                InvoiceUpdateResourceParameter invParams = new InvoiceUpdateResourceParameter();
            //                invParams.BusinessUnit = user.BusinessUnit;
            //                invParams.CSSId = new long?(Convert.ToInt64(user.CssId));
            //                invParams.InvId = new long?(Convert.ToInt64(user.InvoiceId));
            //                invParams.PaidDate =
            //                     DateTime.TryParseExact(user.PaidDate, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsedDate)
            //                             ? parsedDate
            //                             : DateTime.Now;
            //                //new DateTime?(user.PaidDate == string.Empty ? DateTime.Now : DateTime.ParseExact(user.PaidDate.Substring(0, 10), "dd-MM-yyyy", (IFormatProvider)null));
            //                invParams.StatusType = new int?(user.Status.ToLower() == "paid" ? 15 : 0);
            //                invParams.UserName = ((IdentityUser<string>)invoiceController.UserModel).UserName;
            //                nullable = invParams.StatusType;
            //                int num = 15;
            //                if (nullable.GetValueOrDefault() == num & nullable.HasValue)
            //                {
            //                    if (invoiceController._seRepository.SetInvoicePaidStatus(invParams))
            //                        await invoiceController.SendEmail();
            //                }
            //            }
            //            catch (Exception ex)
            //            {
            //                LoggerExtensions.LogError((ILogger)invoiceController._logger, "Error in Invoice SetStatus:" + ex.Message, Array.Empty<object>());
            //                Email.SendEmail(invoiceController._config, (ILogger)invoiceController._logger, "PAID STATUS ERROR for Invoice No: " + user.InvoiceNumber, "Error when updating status -" + ex.Message, ((IdentityUser<string>)invoiceController.UserModel).UserName);
            //            }
            //        }
            //    }
            //    catch (Exception ex)
            //    {
            //        LoggerExtensions.LogError((ILogger)invoiceController._logger, "Error in Invoice SetStatus:" + ex.Message, Array.Empty<object>());
            //        return (IActionResult)invoiceController.StatusCode(400, (object)new ResponseModel()
            //        {
            //            Status = "Bad Request",
            //            Message = ex.Message
            //        });
            //    }
            //    return (IActionResult)invoiceController.Ok();
            //}
            InvoiceController invoiceController = this;
            try
            {
                int? nullable = invoiceController.UserModel.UserType;
                if ((nullable ?? -1) == 2)
                    return (IActionResult)invoiceController.Unauthorized();

                List<InvoiceUpdateDetails> invoiceUpdateDetails = invoiceController._seRepository.ExcelOrCSVDatas<InvoiceUpdateDetails>(fileName, invoiceController._config, (ILogger)invoiceController._logger);

                var result = invoiceController._seRepository.SetInvoicePaidStatus_Linq(invoiceUpdateDetails, ((IdentityUser<string>)invoiceController.UserModel).UserName);
                if (result)
                {
                    await invoiceController.SendEmail();
                }

            }
            catch (Exception ex)
            {
                LoggerExtensions.LogError((ILogger)invoiceController._logger, "Error in Invoice SetStatus:" + ex.Message, Array.Empty<object>());
                return (IActionResult)invoiceController.StatusCode(400, (object)new ResponseModel()
                {
                    Status = "Bad Request",
                    Message = ex.Message
                });
            }
            return (IActionResult)invoiceController.Ok();
        }



        [HttpGet(Name = "InvoiceDashboardsummary")]
        [Route("InvoiceDashboardsummary")]
        public async Task<IActionResult> GetInvoiceSummary([FromQuery] string from, [FromQuery] string to, [FromQuery] string businessUnit, [FromQuery] bool isMonthSelected)
        {
            try
            {
                if (!DateTime.TryParse(from, out var fromDate) || !DateTime.TryParse(to, out var toDate))
                    return BadRequest(new { error = "Invalid from/to date format." });

                if ((this.UserModel.UserType ?? -1) != (int)UserType.CSSUser)
                {
                    return Forbid();
                }

                long cssId = Convert.ToInt64(this.UserModel.CSSCode);
                var summary = await _seRepository.GetInvoiceSummaryAsync(cssId, fromDate, toDate, businessUnit, isMonthSelected, _logger);
                return Ok(summary);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Invoice Summary:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return StatusCode(500, new { error = "Internal server error", message = ex.Message });
            }
        }



        [HttpGet(Name = "RegionalInvoiceDashboard")]
        [Route("RegionalInvoiceDashboard")]
        public async Task<IActionResult> GetCentralInvoiceDashboard([FromQuery] string from, [FromQuery] string to, [FromQuery] bool isMonthSelected)
        {
            try
            {
                if (!DateTime.TryParse(from, out var fromDate) || !DateTime.TryParse(to, out var toDate))
                    return BadRequest(new { error = "Invalid from/to date format." });

                var regionalData = await _seRepository.GetCentralInvoiceSummaryAsync(fromDate, toDate, isMonthSelected, _logger);
                return Ok(regionalData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Regional Invoice Dashboard:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return StatusCode(500, new { error = "Internal server error", message = ex.Message });
            }
        }

    }
}
