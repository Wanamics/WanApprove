namespace Wanamics.VendorBankAccountApproval;
using Microsoft.Purchases.Vendor;
using System.Automation;

Report 87425 "WanApprove VBA Install"
{
    Description = 'Should be set while installation';
    ProcessingOnly = true;
    trigger OnPreReport()
    var
        ConfirmLbl: Label 'WARNING : Do you want to insert WorkflowTemplates and release all Vendor Bank Accounts?';
        VendorBankAccountApprovalSetup: Codeunit "WanApprove VBA Setup";
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if not Confirm(ConfirmLbl, false) then
            exit;
        RemoveTemplate('MJS-VBAOW');
        // RemoveTemplate('WANVBAAPW');
        VendorBankAccountApprovalSetup.InsertWorkflowTemplates();

        // TransferStatus(); //!!!!!!!!!!!!!
    end;

    //TODO  Undo
    local procedure TransferStatus()
    var
        RecRef: RecordRef;
        FldRef, FromField, ToField : FieldRef;
    begin
        RecRef.Open(Database::"Vendor Bank Account");
        FldRef := RecRef.Field(71416565);
        FldRef.SetFilter('<>%1', 0);
        if RecRef.FindSet() then
            repeat
                FromField := RecRef.Field(71416565);
                ToField := RecRef.Field(87420);
                ToField.Value := FromField.Value;
                RecRef.Modify();
            until RecRef.Next() = 0;
    end;

    local procedure RemoveTemplate(Filter: Code[20])
    var
        Workflow: Record Workflow;
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        Workflow.SetRange(Template, true);
        Workflow.SetFilter(Code, '%1', Filter + '*');
        Workflow.DeleteAll();

        WorkflowStep.SetFilter("Workflow Code", '%1', Filter + '*');
        if WorkflowStep.FindSet() then begin
            repeat
                WorkflowStepArgument.SetRange(ID, WorkflowStep.Argument);
                WorkflowStepArgument.DeleteAll();
            until WorkflowStep.Next() = 0;
            WorkflowStep.DeleteAll();
        end;
    end;
}
