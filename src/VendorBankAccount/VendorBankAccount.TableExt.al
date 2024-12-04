namespace Wanamics.VendorBankAccountApproval;

using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Address;
using System.Automation;
tableextension 87420 "WanApprove VBA" extends "Vendor Bank Account"
{
    fields
    {
        field(87420; "wan Approval Status"; Enum "WanApprove VBA Status")
        {
            Caption = 'Approval Status';
            ToolTip = 'Specifie the Status of the vendor bank account.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
    trigger OnDelete()
    begin
        DeleteRecordInApprovalRequest();
    end;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        HideValidationDialog: Boolean;

    local procedure DeleteRecordInApprovalRequest()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteRecordInApprovalRequest(Rec, IsHandled);
        if IsHandled then
            exit;
        ApprovalsMgmt.OnDeleteRecordInApprovalRequest(RecordId);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteRecordInApprovalRequest(var VendorBankAccount: Record "Vendor Bank Account"; var IsHandled: Boolean)
    begin
    end;

    procedure GetStatusStyleText() StatusStyleText: Text
    begin
        if "wan Approval Status" = "wan Approval Status"::Open then
            StatusStyleText := 'Favorable'
        else
            StatusStyleText := 'Strong';

        OnAfterGetStatusStyleText(Rec, StatusStyleText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetStatusStyleText(VendorBankAccount: Record "Vendor Bank Account"; var StatusStyleText: Text)
    begin
    end;

    procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure CheckReleaseRestrictions()
    var
        CountryRegion: Record "Country/Region";
    begin
        TestField("Country/Region Code");
        CountryRegion.Get("Country/Region Code");
        if CountryRegion."SEPA Allowed" then
            TestField(IBAN);
    end;
}
