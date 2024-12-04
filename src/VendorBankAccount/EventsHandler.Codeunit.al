namespace Wanamics.VendorBankAccountApproval;

using System.Automation;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;

codeunit 87421 "WanApprove VBA Events Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnOpenDocument, '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    begin
        case RecRef.Number of
            Database::"Vendor Bank Account":
                SetStatus(RecRef, Handled, "WanApprove VBA Status"::Open);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnSetStatusToPendingApproval, '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    begin
        case RecRef.Number of
            Database::"Vendor Bank Account":
                begin
                    SetStatus(RecRef, IsHandled, "WanApprove VBA Status"::"Pending");
                    RecRef.GetTable(Variant);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnPopulateApprovalEntryArgument, '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        case RecRef.Number of
            DataBase::"Vendor Bank Account":
                begin
                    RecRef.SetTable(VendorBankAccount);
                    ApprovalEntryArgument."Document No." := VendorBankAccount."Vendor No.";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnReleaseDocument, '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    begin
        case RecRef.Number of
            DataBase::"Vendor Bank Account":
                SetStatus(RecRef, Handled, "WanApprove VBA Status"::Approved);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnRejectApprovalRequest, '', false, false)]
    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        RecRef: RecordRef;
        Handled: Boolean;
    begin
        case ApprovalEntry."Table ID" of
            DataBase::"Vendor Bank Account":
                if RecRef.Get(ApprovalEntry."Record ID to Approve") then
                    SetStatus(RecRef, Handled, "WanApprove VBA Status"::Rejected);
        end;
    end;

    local procedure SetStatus(var RecRef: RecordRef; var Handled: Boolean; pStatus: Enum "WanApprove VBA Status")
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        RecRef.SetTable(VendorBankAccount);
        VendorBankAccount.Validate("wan Approval Status", pStatus);
        VendorBankAccount.Modify(true);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WanApprove VBA Approval", OnSendWorkflowForApploval, '', false, false)]
    local procedure RunWorkflowOnSendWorkflowForApproval(var RecRef: RecordRef)
    var
        VendorBankAccount: Record "Vendor Bank Account";
        WorkflowMgt: Codeunit "Workflow Management";
        Approval: Codeunit "WanApprove VBA Approval";
    begin
        RecRef.SetTable(VendorBankAccount);
        VendorBankAccount.CheckReleaseRestrictions();
        WorkflowMgt.HandleEvent(Approval.RunWorkflowOnSendForApplovalCode(), RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WanApprove VBA Approval", OnCancelWorkflowForApploval, '', false, false)]
    local procedure RunWorkflowOnCancelWorkflowForApproval(var RecRef: RecordRef)
    var
        WorkflowMgt: Codeunit "Workflow Management";
        Approval: Codeunit "WanApprove VBA Approval";
    begin
        WorkflowMgt.HandleEvent(Approval.RunWorkflowOnCancelApplovalRequestCode(), RecRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterValidateEvent, "Recipient Bank Account", false, false)]
    local procedure OnAfterValidateRecipientAccount(CurrFieldNo: Integer; var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if Rec."Recipient Bank Account" <> '' then begin
            if Rec."Account Type" = Rec."Account Type"::Vendor then
                if VendorBankAccount.Get(Rec."Account No.", Rec."Recipient Bank Account") then
                    VendorBankAccount.TestField("wan Approval Status", VendorBankAccount."wan Approval Status"::Approved);
        end;
    end;
}
