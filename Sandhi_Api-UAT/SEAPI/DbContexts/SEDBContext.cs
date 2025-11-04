using SE.API.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System;

namespace SE.API.DbContexts
{
    public class SEDBContext : Microsoft.AspNetCore.Identity.EntityFrameworkCore.IdentityDbContext<StoreUser>
    {
        public SEDBContext(DbContextOptions<SEDBContext> options)
           : base(options)
        {
        }
        public DbSet<WorkOrder> SE_Work_Order { get; set; }
        public DbSet<WorkOrderStatus> SE_Work_Order_Status { get; set; }
        public DbSet<CSS> SE_CSS_Master { get; set; }
        public DbSet<InvoiceStatus> SE_CSS_Invoice_Status { get; set; }

        public DbSet<PurchaseOrder> SE_CSS_Purchase_Order { get; set; }
        public DbSet<Invoice> SE_CSS_Invoice { get; set; }
        public DbSet<InvoiceDetail> SE_CSS_Invoice_Detail { get; set; }
        public DbSet<CurrentStatus> SE_CurrentStatus { get; set; }
        public DbSet<Notification> SE_Notification { get; set; }

        public DbSet<Gradation> SE_CSS_Gradation { get; set; }
        public DbSet<GradationDetail> SE_CSS_Gradation_Detail { get; set; }
        public DbSet<ApprovedData> SE_CSS_Approved_Data{ get; set; }
        public DbSet<ApprovedDataWorkOrder> SE_CSS_Approved_WorkOrder { get; set; }
        public DbSet<UploadErrors> SE_Upload_Errors { get; set; }


        public DbSet<ProductCategoryCooling> Cooling_Product_Category_list { get; set; }
        public DbSet<ProductCategoryHBN> HBN_Product_category_List { get; set; }
        public DbSet<ProductCategoryPPI> PSI_Product_Category { get; set; }
        public virtual DbSet<Cooling_Rate_Card> Cooling_Rate_Card { get; set; }
        public virtual DbSet<HBN_Rate_Card> HBN_Rate_Card { get; set; }
        public virtual DbSet<PSI_Rate_Card> PSI_Rate_Card { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)//, UserManager<StoreUser> _userManager
        {
            // seed the database with dummy data
            base.OnModelCreating(modelBuilder);
        }
    }
}
