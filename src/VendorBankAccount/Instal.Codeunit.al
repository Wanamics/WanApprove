namespace Wanamics.VendorBankAccountApproval;

codeunit 87425 "WanApprove VBA Install"
{
    Subtype = Install;

    trigger OnRun()
    var
        VendorBankAccountApprovalSetup: Codeunit "WanApprove VBA Setup";
    begin
        VendorBankAccountApprovalSetup.InsertWorkflowTemplates();
    end;
}
