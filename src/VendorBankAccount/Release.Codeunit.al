
namespace Wanamics.VendorBankAccountApproval;

using Microsoft.Purchases.Vendor;
using System.Automation;
codeunit 87422 "WanApprove VBA Release"
{
    TableNo = "Vendor Bank Account";

    trigger OnRun()
    begin
        VendorBankAccount.Copy(Rec);
        VendorBankAccount.SetHideValidationDialog(Rec.GetHideValidationDialog());
        Code();
        Rec := VendorBankAccount;
    end;

    var
        VendorBankAccount: Record "Vendor Bank Account";
        PreviewMode: Boolean;
        SkipCheckReleaseRestrictions: Boolean;
        WorkflowManagement: Codeunit "Workflow Management";
        VendorBankAccountApproval: Codeunit "WanApprove VBA Approval";

    local procedure Code()
    var
        IsHandled: Boolean;
    begin
        if VendorBankAccount."wan Approval Status" = VendorBankAccount."wan Approval Status"::Approved then
            exit;

        IsHandled := false;
        OnBeforeRelease(VendorBankAccount, SkipCheckReleaseRestrictions, IsHandled);
        if IsHandled then
            exit;

        if not (PreviewMode or SkipCheckReleaseRestrictions) then //begin
            // VendorBankAccount.CheckReleaseRestrictions();
            CheckPendingApproval(VendorBankAccount);
        // end;

        IsHandled := false;
        OnCodeOnAfterCheckReleaseRestrictions(VendorBankAccount, IsHandled);
        if IsHandled then
            exit;
        IsHandled := false;
        OnBeforeModify(VendorBankAccount, IsHandled);
        if IsHandled then
            exit;

        VendorBankAccount."wan Approval Status" := VendorBankAccount."wan Approval Status"::Approved;
        VendorBankAccount.Modify(true);
        OnAfterRelease(VendorBankAccount);
    end;

    procedure Reopen(var VendorBankAccount: Record "Vendor Bank Account")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReopen(VendorBankAccount, IsHandled);
        if IsHandled then
            exit;

        if VendorBankAccount."wan Approval Status" = VendorBankAccount."wan Approval Status"::Open then
            exit;
        VendorBankAccount."wan Approval Status" := VendorBankAccount."wan Approval Status"::Open;
        OnReopenOnBeforeModify(VendorBankAccount);
        VendorBankAccount.Modify(true);

        OnAfterReopen(VendorBankAccount);
    end;

    procedure PerformManualRelease(var VendorBankAccount: Record "Vendor Bank Account")
    begin
        OnBeforeManualRelease(VendorBankAccount);
        PerformManualCheckAndRelease(VendorBankAccount);
        OnAfterManualRelease(VendorBankAccount);
    end;

    procedure PerformManualCheckAndRelease(var VendorBankAccount: Record "Vendor Bank Account")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePerformManualCheckAndRelease(VendorBankAccount, IsHandled);
        if IsHandled then
            exit;
        CheckPendingApproval(VendorBankAccount);

        IsHandled := false;
        OnBeforePerformManualRelease(VendorBankAccount, IsHandled);
        if IsHandled then
            exit;

        Codeunit.Run(Codeunit::"WanApprove VBA Release", VendorBankAccount);

        OnAfterPerformManualCheckAndRelease(VendorBankAccount);
    end;

    local procedure CheckPendingApproval(var VendorBankAccount: Record "Vendor Bank Account")
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        IsHandled: Boolean;
        PendingApprovalErr: Label 'This %1 can only be released when the approval process is complete.', Comment = '%1:VendorBankAccount.TableCaption';
    begin
        IsHandled := false;
        OnBeforeCheckPendingApproval(VendorBankAccount, IsHandled);
        if IsHandled then
            exit;

        if IsPendingApproval(VendorBankAccount) then
            Error(PendingApprovalErr, VendorBankAccount.TableCaption);
    end;

    procedure PerformManualReopen(var VendorBankAccount: Record "Vendor Bank Account")
    var
        ApprovalStatusErr: Label 'The approval process must be cancelled or completed to reopen this %1.', Comment = '%1:VendorBankAccount.TableCaption';
    begin
        if VendorBankAccount."wan Approval Status" = VendorBankAccount."wan Approval Status"::"Pending" then
            Error(ApprovalStatusErr, VendorBankAccount.TableCaption);

        OnBeforeManualReopen(VendorBankAccount);
        Reopen(VendorBankAccount);
        OnAfterManualReopen(VendorBankAccount);
    end;

    procedure SetSkipCheckReleaseRestrictions()
    begin
        SkipCheckReleaseRestrictions := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPendingApproval(var VendorBankAccount: Record "Vendor Bank Account"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeManualRelease(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePerformManualCheckAndRelease(var PurchHeader: Record "Vendor Bank Account"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRelease(var VendorBankAccount: Record "Vendor Bank Account"; var SkipCheckReleaseRestrictions: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRelease(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterManualRelease(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeManualReopen(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopen(var VendorBankAccount: Record "Vendor Bank Account"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var VendorBankAccount: Record "Vendor Bank Account"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePerformManualRelease(var VendorBankAccount: Record "Vendor Bank Account"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopen(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterManualReopen(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCheckReleaseRestrictions(var VendorBankAccount: Record "Vendor Bank Account"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReopenOnBeforeModify(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPerformManualCheckAndRelease(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;

    procedure IsApprovalsWorkflowEnabled(var VendorBankAccount: Record "Vendor Bank Account") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsApprovalsWorkflowEnabled(VendorBankAccount, Result, IsHandled);
        if IsHandled then
            exit(Result);
        exit(WorkflowManagement.CanExecuteWorkflow(VendorBankAccount, VendorBankAccountApproval.RunWorkflowOnSendForApplovalCode()));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsApprovalsWorkflowEnabled(var VendorBankAccount: Record "Vendor Bank Account"; var Result: Boolean; var IsHandled: Boolean);
    begin
    end;

    procedure IsPendingApproval(var VendorBankAccount: Record "Vendor Bank Account"): Boolean
    begin
        if VendorBankAccount."wan Approval Status" <> VendorBankAccount."wan Approval Status"::Open then
            exit(false);

        exit(IsApprovalsWorkflowEnabled(VendorBankAccount));
    end;
}
