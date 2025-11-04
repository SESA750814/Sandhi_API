using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SE.API.Entities;
using SE.API.Helpers;
using SE.API.Models;
using SE.API.ResourceParameters;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace SE.API.Services
{
    public interface IWorkOrderRepository
    {
        Task<List<Invoice>> GetUnsentCollectorInvoices(CancellationToken cancellationToken);
        bool SendCollectorEmail(long invId, ILogger _logger, IConfiguration _config);
            PagedList<WorkOrder> GetWorkOrderList(WorkOrderResourceParameter workOrderResourceParameter);

        IEnumerable<SE.API.Models.PrevMonthWO> GetPreviousMonthsWO();
        bool SetWorkOrderStatus(WorkOrderStatusSubmitParameter workOrderStatusParameter, ILogger _logger, IConfiguration _config);

        IEnumerable<CSS> GetCSS(CSSResourceParameter cssParams);
        IEnumerable<CSS> GetCSSWithWorkOrderByMonth(CSSResourceParameter cssParams);

        bool SetInvoicePaidStatus_Linq(List<InvoiceUpdateDetails> invoiceUpdateDetails, string userName);
        IEnumerable<Invoice> GetInvoiceList(InvoiceResourceParameter invParams, int? userType = null);
        IEnumerable<Invoice> GetNoDueInvoiceList(InvoiceResourceParameter invParams);
        bool SetInvoiceStatus(InvoiceUpdateResourceParameter invParams);
        bool SetInvoicePaidStatus(InvoiceUpdateResourceParameter invParams);
        bool SetNoDueInvoiceStatus(InvoiceUpdateResourceParameter invParams);
        IEnumerable<CurrentStatus> GetCurrentStatus(CurrentStatusResourceParameter currentParams);
        IEnumerable<Notification> GetNotification(NotificationResourceParameter notifyParams);
        bool SetNotificationStatus(NotificationResourceParameter notifyParams);

        IEnumerable<CSS> GetGradation(GradationResourceParameter gradeParams);
        IEnumerable<ApprovedData> GetApprovedData(ApprovedDataResourceParameter currentParams);

        IEnumerable<string> GetRegion();
        IEnumerable<SE.API.Models.ReportWorkOrderCount> GetWorkOrderCounts(ReportParameter currentParams);
        IEnumerable<SE.API.Models.ReportWorkOrderSemiDraft> GetWorkOrderSemiDraft(ReportParameter currentParams);
        IEnumerable<SE.API.Models.ReportFinanceValidation> GetFinanceValidation(ReportParameter currentParams);
        IEnumerable<SE.API.Models.ReportNoDueCertificate> GetNoDueCertificate(ReportParameter currentParams);
        IEnumerable<SE.API.Models.ReportCSSInvoice> GetCSSInvoice(ReportParameter currentParams);
        IEnumerable<SE.API.Models.ReportWODiscrepency> GetWODiscrepency(ReportParameter currentParams);
        List<T> ExcelOrCSVDatas<T>(string fileName, IConfiguration config, ILogger _logger) where T : class, new();

        #region Admin

        IEnumerable<SE.API.Models.UserModel> GetUsers();
        bool DeleteUser(StoreUser user);
        bool UpdateCss(CSSUpdateResourceParameter currentParams);
        bool UploadCSS();
        bool UploadCSSUserData(CSSZipCodeUpdateResourceParameter currentParams);
  
        IEnumerable<ProductCategoryCooling> GetProductCategoryCooling();
        IEnumerable<ProductCategoryHBN> GetProductCategoryHBN();
        IEnumerable<ProductCategoryPPI> GetProductCategoryPPI();
        bool InsertCoolingProduct(ProductCategoryCoolingSubmitParameter currentParam);
        bool UpdateCoolingProduct(ProductCategoryCoolingSubmitParameter currentParam);
        bool InsertHBNProduct(ProductCategoryHBNSubmitParameter currentParam);
        bool UpdateHBNProduct(ProductCategoryHBNSubmitParameter currentParam);
        bool InsertPPIProduct(ProductCategoryPPISubmitParameter currentParam);
        bool UpdatePPIProduct(ProductCategoryPPISubmitParameter currentParam);
        bool UploadPPIProduct();
        bool UploadHBNProduct();
        bool UploadCoolingProduct();
        bool DeleteWorkOrderByMonth(int month, int year);
        bool ResetDefaultPassword(string Email);

        bool UploadPPIRateCard();
        bool UploadHBNRateCard();
        bool UploadCoolingRateCard();
        #endregion

        #region Dashboards
        SE.API.Models.GradationDashboardModel GetGradationDashboard(GradationDashboardParameter currentParams);
        SE.API.Models.PaymentDashboardModelByCount GetPaymentDashboardByCount(PaymentDashboardParameter currentParams);
        SE.API.Models.PaymentDashboardModelByValue GetPaymentDashboardByValue(PaymentDashboardParameter currentParams);
        IEnumerable<SE.API.Models.PurchaseOrderDashboardModel> GetPurchaseOrderDashboard(PurchaseOrderDashboardParameter currentParams);

        #endregion Dashboards


        Task<bool> StartWOProcessAndImport(bool isJob = false);
        Task<bool> ImportPurchaseOrder();
        Task<bool> CalculateGradation();
        bool ExcelImport(string fileName, string tableName, IConfiguration config, ILogger _logger);
        bool Save();
        void AddEntity(object model);
        void UpdateEntity(object model);
        void RemoveEntity(object model);

        IEnumerable<Cooling_Rate_Card> GetCoolingRateCard();
        IEnumerable<HBN_Rate_Card> GetHBNRateCard();
        IEnumerable<PSI_Rate_Card> GetPSIRateCard();

        bool InsertPPIRateCard(RateCardPPIModel currentParam);
        bool UpdatePPIRateCard(RateCardPPIModel currentParam);

        bool InsertHBNRateCard(RateCardHBNModel currentParam);
        bool UpdateHBNRateCard(RateCardHBNModel currentParam);

        bool UpdateCoolingRateCard(RateCardCoolingModel currentParam);
        bool InsertCoolingRateCard(RateCardCoolingModel currentParam);
        Task<IEnumerable<Invoice>> GetInvoices(InvoiceFilter filter);
        Task<IEnumerable<WorkOrder>> GetWorkOrder(WorkOrderFilter filter);
        Task<bool> RevertInvoiceStatus(RevertInvoiceStatus revertInvoiceStatus, string userName);
        Task CheckAndSendOverdueEmails_CSS(CancellationToken cancellationToken, IConfiguration _config, ILogger _logger);
        Task CheckAndSendOverdueEmails_Invoice(CancellationToken cancellationToken, IConfiguration _config, ILogger _logger);
        Task<InvoiceSummaryResponseModel> GetInvoiceSummaryAsync(long? cssId, DateTime fromDate, DateTime toDate, string businessUnit, bool isMonthSelected, ILogger _logger);
        Task<RegionalDashboardResponseModel> GetCentralInvoiceSummaryAsync(DateTime fromDate, DateTime toDate, bool isMonthSelected, ILogger _logger);
    }
}
