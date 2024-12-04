namespace Wanamics.VendorBankAccountApproval;
using System.Automation;
using Microsoft.Purchases.Vendor;

codeunit 87424 "WanApprove VBA Setup"
{
    var
        BlankDateFormula: DateFormula;
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        VendorBankAccountApproval: Codeunit "WanApprove VBA Approval";
        CustomTemplateToken: Label 'WAN', Locked = true;
        WorkflowCodeTxt: Label 'VBAAPW', Locked = true;
        WorkflowDescTxt: Label 'Vendor Bank Account Approval Workflow';
        WorkflowCategoryTxt: Label 'PURCH', Locked = true;
        WorkflowTypeConditionTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="Vendor Bank Account">%1</DataItem></DataItems></ReportParameters>', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", OnInsertWorkflowTemplates, '', false, false)]
    local procedure OnInsertWorkflowTemplates()
    begin
        InsertWorkflowTemplates();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", OnAddWorkflowCategoriesToLibrary, '', false, false)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", OnAfterInitWorkflowTemplates, '', false, false)]
    local procedure OnAfterInitWorkflowTemplates()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", OnAfterInsertApprovalsTableRelations, '', false, false)]
    local procedure OnAfterInsertApprovalsTableRelations()
    begin
    end;

    procedure InsertWorkflowTemplates()
    var
        Workflow: Record Workflow;
    begin
        WorkflowSetup.SetCustomTemplateToken(CustomTemplateToken);
        WorkflowSetup.InsertWorkflowTemplate(Workflow, WorkflowCodeTxt, WorkflowDescTxt, WorkflowCategoryTxt);
        InsertVendorBankAccountApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    procedure InsertVendorBankAccountApprovalWorkflow()
    var
        Workflow: Record Workflow;
    begin
        InsertWorkflow(Workflow, GetWorkflowCode(WorkflowCodeTxt), WorkflowDescTxt, WorkflowCategoryTxt);
        InsertVendorBankAccountApprovalWorkflowDetails(Workflow);
    end;

    local procedure InsertVendorBankAccountApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowSetup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
            WorkflowStepArgument."Approver Limit Type"::"Direct Approver",
            0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(
            Workflow,
            BuildTypeConditions("WanApprove VBA Status"::Open),
            VendorBankAccountApproval.RunWorkflowOnSendForApplovalCode(),
            BuildTypeConditions("WanApprove VBA Status"::"Pending"),
            VendorBankAccountApproval.RunWorkflowOnCancelApplovalRequestCode(),
            WorkflowStepArgument, true);
    end;
    // JournalLineCreatedEventID := InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnAfterInsertGeneralJournalLineCode(),
    //     CreatePmtLineResponseID);

    // GenJournalLine.SetRange("Document Type", GenJournalLine."Document Type"::Payment);
    // InsertEventArgument(JournalLineCreatedEventID, BuildGeneralJournalLineTypeConditions(GenJournalLine));

    // NotifyResponseID := InsertResponseStep(Workflow, WorkflowResponseHandling.CreateNotificationEntryCode(), JournalLineCreatedEventID);
    // InsertNotificationArgument(NotifyResponseID, false, '', PAGE::"Payment Journal", '');


    local procedure InsertWorkflow(var Workflow: Record Workflow; WorkflowCode: Code[20]; WorkflowDescription: Text[100]; CategoryCode: Code[20])
    begin
        Workflow.Init();
        Workflow.Code := WorkflowCode;
        Workflow.Description := WorkflowDescription;
        Workflow.Category := CategoryCode;
        Workflow.Enabled := false;
        Workflow.Insert();
    end;

    local procedure GetWorkflowCode(WorkflowCode: Text): Code[20]
    var
        Workflow: Record Workflow;
    begin
        exit(CopyStr(Format(Workflow.Count + 1) + '-' + WorkflowCode, 1, MaxStrLen(Workflow.Code)));
    end;

    local procedure BuildTypeConditions(Status: enum "WanApprove VBA Status"): Text
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        VendorBankAccount.SetRange("wan Approval Status", Status);
        exit(StrSubstNo(WorkflowTypeConditionTxt, WorkflowSetup.Encode(VendorBankAccount.GetView(false))));
    end;
}
