namespace Wanamics.VendorBankAccountApproval;

using System.Automation;
using Microsoft.Purchases.Vendor;

codeunit 87420 "WanApprove VBA Approval"
{
    var
        WorkflowMgt: Codeunit "Workflow Management";

    procedure RunWorkflowOnSendForApplovalCode(): Code[128];
    var
        Rec: Record "Vendor Bank Account";
    begin
        exit(StrSubstNo('RUNWORKFLOWONSEND%1FORAPPROVAL', DelChr(Rec.TableName, '=', ' ')))
    end;

    procedure RunWorkflowOnCancelApplovalRequestCode(): Code[128];
    var
        Rec: Record "Vendor Bank Account";
    begin
        exit(StrSubstNo('RUNWORKFLOWONCANCEL%1APPROVALREQUEST', DelChr(Rec.TableName, '=', ' ')))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventsToLibrary, '', true, true)]
    procedure OnAddWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        RecRef: RecordRef;
        SendForApprovalLbl: Label 'Send %1 for approval', Comment = '%1:RecRef.Caption';
        CancelForApprovalLbl: Label 'Cancel %1 for approval', Comment = '%1:RecRef.Caption';
    begin
        RecRef.Open(Database::"Vendor Bank Account");
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendForApplovalCode, Database::"Vendor Bank Account", StrSubstNo(SendForApprovalLbl, RecRef.Caption), 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelApplovalRequestCode, Database::"Vendor Bank Account", StrSubstNo(CancelForApprovalLbl, RecRef.Caption), 0, false);
    end;

    procedure CheckApprovalWorkflowEnabled(var RecRef: RecordRef): Boolean
    var
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
    begin
        if not WorkflowMgt.CanExecuteWorkflow(RecRef, RunWorkflowOnSendForApplovalCode()) then
            error(NoWorkflowEnabledErr);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendWorkflowForApploval(var RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelWorkflowForApploval(var RecRef: RecordRef)
    begin
    end;
}
