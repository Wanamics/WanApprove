#if FALSE
namespace Wanamics.VendorBankAccountApproval;
using Microsoft.Purchases.Vendor;

using Microsoft.Integration.Entity;
using System.Device;
using System.IO;
using System.Text;

page 87420 "WanApprove VBA Picture"
{
//     Caption = 'Vendor Bank Account Picture';
// namespace Microsoft.Inventory.VendorBankAccount."WanApprove VBA Picture";

// using Microsoft.Integration.Entity;
// using Microsoft.Inventory.VendorBankAccount;
// using System.Device;
// using System.IO;

// page 346 "VendorBankAccount Picture"
// {
    Caption = 'Vendor Bank Account Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "Vendor Bank Account";

    layout
    {
        area(content)
        {
            field(Picture; Rec."WanApprove VBA Picture")
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the picture that has been inserted for the Vendor Bank Account.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(TakePicture)
            {
                ApplicationArea = All;
                Caption = 'Take';
                Image = Camera;
                ToolTip = 'Activate the camera on the device.';
                Visible = CameraAvailable and (HideActions = false);

                trigger OnAction()
                begin
                    TakeNewPicture();
                end;
            }
            action(ImportPicture)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a picture file.';
                Visible = HideActions = false;

                trigger OnAction()
                begin
                    ImportFromDevice();
                end;
            }
#if ONPREM
            action(ExportFile)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Enabled = DeleteExportEnabled;
                Image = Export;
                ToolTip = 'Export the picture to a file.';
                Visible = HideActions = false;

                trigger OnAction()
                var
                    DummyPictureEntity: Record "Picture Entity";
                    FileManagement: Codeunit "File Management";
                    StringConversionManager: Codeunit StringConversionManagement;
                    ToFile: Text;
                    ConvertedCodeType: Text;
                    ExportPath: Text;
                begin
                    Rec.TestField("Vendor No.");
                    Rec.TestField(Code);
                    ConvertedCodeType := Format(Rec."Vendor No.");
                    ToFile := DummyPictureEntity.GetDefaultMediaDescription(Rec);
                    ConvertedCodeType := StringConversionManager.RemoveNonAlphaNumericCharacters(ConvertedCodeType);
                    ExportPath := TemporaryPath + ConvertedCodeType + Format(Rec."WanApprove VBA Picture".MediaId);
                    Rec."WanApprove VBA Picture".ExportFile(ExportPath + '.' + DummyPictureEntity.GetDefaultExtension());

                    FileManagement.ExportImage(ExportPath, ToFile);
                end;
            }
#endif
            action(DeletePicture)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Enabled = DeleteExportEnabled;
                Image = Delete;
                ToolTip = 'Delete the record.';
                Visible = HideActions = false;

                trigger OnAction()
                begin
                    DeleteVendorBankAccountPicture();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEditableOnPictureActions();
    end;

    trigger OnOpenPage()
    begin
        CameraAvailable := Camera.IsAvailable();
    end;

    var
        Camera: Codeunit Camera;
        CameraAvailable: Boolean;
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
        SelectPictureTxt: Label 'Select a picture to upload';
        DeleteExportEnabled: Boolean;
        HideActions: Boolean;
        MustSpecifyDescriptionErr: Label 'You must add a code to the Vendor Bank Account before you can import a picture.';
        MimeTypeTok: Label 'image/jpeg', Locked = true;

    procedure TakeNewPicture()
    begin
        Rec.Find();
        Rec.TestField("Vendor No.");
        Rec.TestField(Code);

        OnAfterTakeNewPicture(Rec, DoTakeNewPicture());
    end;

#if ONPREM
    [Scope('OnPrem')]
    procedure ImportFromDevice()
    var
        FileManagement: Codeunit "File Management";
        FileName: Text;
        ClientFileName: Text;
    begin
        Rec.Find();
        Rec.TestField("Vendor No.");
        if Rec.Code = '' then
            Error(MustSpecifyDescriptionErr);

        if Rec."WanApprove VBA Picture".Count > 0 then
            if not Confirm(OverrideImageQst) then
                Error('');

        ClientFileName := '';
        FileName := FileManagement.UploadFile(SelectPictureTxt, ClientFileName);
        if FileName = '' then
            Error('');

        Clear(Rec."WanApprove VBA Picture");
        Rec."WanApprove VBA Picture".ImportFile(FileName, ClientFileName);
        Rec.Modify(true);
        OnImportFromDeviceOnAfterModify(Rec);

        if FileManagement.DeleteServerFile(FileName) then;
    end;
#endif

    local procedure DoTakeNewPicture(): Boolean
    var
        PictureInstream: InStream;
        PictureDescription: Text;
    begin
        // if Rec."WanApprove VBA Picture".Count() > 0 then
        if Rec."WanApprove VBA Picture".HasValue then
            if not Confirm(OverrideImageQst) then
                exit(false);

        if Camera.GetPicture(PictureInstream, PictureDescription) then begin
            Clear(Rec."WanApprove VBA Picture");
            Rec."WanApprove VBA Picture".ImportStream(PictureInstream, PictureDescription, MimeTypeTok);
            Rec.Modify(true);
            exit(true);
        end;

        exit(false);
    end;

    local procedure SetEditableOnPictureActions()
    begin
        // DeleteExportEnabled := Rec."WanApprove VBA Picture".Count <> 0;
        DeleteExportEnabled := Rec."WanApprove VBA Picture".HasValue;
    end;

    procedure IsCameraAvailable(): Boolean
    begin
        exit(Camera.IsAvailable());
    end;

    procedure SetHideActions()
    begin
        HideActions := true;
    end;

    procedure DeleteVendorBankAccountPicture()
    begin
        Rec.TestField("Vendor No.");

        if not Confirm(DeleteImageQst) then
            exit;

        Clear(Rec."WanApprove VBA Picture");
        Rec.Modify(true);

        OnAfterDeleteVendorBankAccountPicture(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteVendorBankAccountPicture(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTakeNewPicture(var VendorBankAccount: Record "Vendor Bank Account"; IsPictureAdded: Boolean)
    begin
    end;

#if ONPREM
    [IntegrationEvent(false, false)]
    local procedure OnImportFromDeviceOnAfterModify(var VendorBankAccount: Record "Vendor Bank Account")
    begin
    end;
#endif
}

#endif