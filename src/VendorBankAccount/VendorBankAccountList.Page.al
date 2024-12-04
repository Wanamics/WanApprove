namespace Wanamics.VendorBankAccountApproval;

using Microsoft.Purchases.Vendor;
using System.Diagnostics;
using System.Security.User;

page 87420 "WanApprove VBA List"
{
    Caption = 'Vendor Bank Accounts';
    CardPageID = "Vendor Bank Account Card";
    DataCaptionFields = "Vendor No.";
    Editable = false;
    PageType = List;
    SourceTable = "Vendor Bank Account";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies Vendor No.';
                }
                field("Vendor Name"; Vendor.Name)
                {
                    Caption = 'Vendor Name';
                    ToolTip = 'Specifies the name of the vendor.';
                }
                field(VendorCountryRegionCode; Vendor."Country/Region Code")
                {
                    Caption = 'Vendor Country/region Code';
                    ToolTip = 'Specifies the country/region of the vendor.';
                    Visible = false;
                }
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this vendor bank account.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the bank where the vendor has this bank account.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the postal code.';
                    Visible = false;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region of the address.';
                    Visible = false;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the telephone number of the bank where the vendor has the bank account.';
                    Visible = false;
                }
                field("Fax No."; Rec."Fax No.")
                {
                    ToolTip = 'Specifies the fax number associated with the address.';
                    Visible = false;
                }
                field(Contact; Rec.Contact)
                {
                    ToolTip = 'Specifies the name of the bank employee regularly contacted in connection with this bank account.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                    Visible = false;
                }
                field("SWIFT Code"; Rec."SWIFT Code")
                {
                    ToolTip = 'Specifies the SWIFT code (international bank identifier code) of the bank where the vendor has the account.';
                    Visible = false;
                }
                field(IBAN; Rec.IBAN)
                {
                    ToolTip = 'Specifies the bank account''s international bank account number.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the relevant currency code for the bank account.';
                    Visible = false;
                }
                field("Language Code"; Rec."Language Code")
                {
                    ToolTip = 'Specifies the language that is used when translating specified text on documents to foreign business partner, such as an item description on an order confirmation.';
                    Visible = false;
                }
                field("wan Approval Status"; Rec."wan Approval Status")
                {
                    StyleExpr = StatusStyleTxt;
                    ToolTip = 'Specifies whether the record is open, waiting to be approved, or released to the next stage of processing.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetStatusApproved)
            {
                ApplicationArea = Suite;
                Caption = 'Set as Approved';
                Visible = IsSuper;

                trigger OnAction()
                var
                    lRec: Record "Vendor Bank Account";
                    ConfirmLbl: Label 'Do you want to set %1 to %2 for %3 selected line(s)?';
                begin
                    CurrPage.SetSelectionFilter(lRec);
                    CheckIBAN(lRec);
                    lRec.SetRange("wan Approval Status", "WanApprove VBA Status"::Open);
                    if not Confirm(ConfirmLbl, false, lRec.FieldCaption("wan Approval Status"), lrec."wan Approval Status"::Approved, lRec.Count()) then
                        exit;
                    lRec.ModifyAll("wan Approval Status", lRec."wan Approval Status"::Approved, true);
                end;
            }
        }
        area(Promoted)
        {
            actionref(SetStatusApproved_Promoted; SetStatusApproved) { }
        }
    }

    trigger OnOpenPage()
    var
        MonitorSensitiveField: Codeunit "Monitor Sensitive Field";
        UserPermissions: Codeunit "User Permissions";
    begin
        MonitorSensitiveField.ShowPromoteMonitorSensitiveFieldNotification();
        IsSuper := UserPermissions.IsSuper(UserSecurityId());
    end;

    trigger OnAfterGetRecord()
    begin
        StatusStyleTxt := Rec.GetStatusStyleText();
        Vendor.Get(Rec."Vendor No.");
    end;

    local procedure CheckIBAN(var pRec: Record "Vendor Bank Account")
    var
        MissingIBAN: Label '%1 is missing on %2 line(s).';
        lRec: Record "Vendor Bank Account";
    begin
        lRec.Copy(pRec);
        lRec.SetRange(IBAN, '');
        if not lRec.IsEmpty then
            Error(MissingIBAN, lRec.FieldCaption(IBAN), lRec.Count);
    end;

    var
        StatusStyleTxt: Text;
        IsSuper: Boolean;
        Vendor: Record Vendor;
}

