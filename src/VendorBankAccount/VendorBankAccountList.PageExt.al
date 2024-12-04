pageextension 87421 "WanApprove VBA List" extends "Vendor Bank Account List"
{
    layout
    {
        modify("Country/Region Code")
        {
            Visible = true;
        }
        // addfirst(Control1)
        // {
        // field("Vendor No."; Rec."Vendor No.")
        // {
        //     ApplicationArea = All;
        //     Visible = VendorVisible;
        // }
        // }
        addlast(Control1)
        {
            field("wan Approval Status"; Rec."wan Approval Status")
            {
                ApplicationArea = Suite;
                StyleExpr = StatusStyleTxt;
                ToolTip = 'Specifies whether the record is open, waiting to be approved, or released to the next stage of processing.';
            }
            // field("Pending Approval"; not ApprovalEntry.IsEmpty)
            // {
            //     ApplicationArea = Suite;
            //     BlankZero = true;
            //     Caption = 'Pending Approval';
            // }
        }
        addlast(factboxes)
        {
            // part(Control23; "Pending Approval FactBox")
            // {
            //     ApplicationArea = Suite;
            //     SubPageLink = "Table ID" = const(288),
            //                   "Document No." = field("Vendor No."), // No link for Code (PK2)
            //                   Status = const(Open);
            //     Visible = OpenApprovalEntriesExistForCurrUser;
            // }
            part(ApprovalFactBox; "Approval FactBox")
            {
                ApplicationArea = Suite;
                // Visible = false;
            }
            part(WorkflowStatus; "Workflow Status FactBox")
            {
                ApplicationArea = Suite;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatus;
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                // Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    // trigger OnOpenPage()
    // begin
    //     VendorVisible := Rec.GetFilter("Vendor No.") = '';
    // end;

    trigger OnAfterGetRecord()
    begin
        //     ApprovalEntry.SetRange("Table ID", Database::"Vendor Bank Account");
        //     ApprovalEntry.SetFilter(Status, '%1|%2', ApprovalEntry.Status::Open, ApprovalEntry.Status::Created);
        //     ApprovalEntry.SetCurrentKey("Record ID to Approve");
        //     ApprovalEntry.SetRange("Record ID to Approve", Rec.RecordId);
        StatusStyleTxt := Rec.GetStatusStyleText();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.ApprovalFactBox.Page.UpdateApprovalEntriesFromSourceRecord(Rec.RecordId());
        ShowWorkflowStatus := CurrPage.WorkflowStatus.Page.SetFilterOnWorkflowRecord(Rec.RecordId());
        StatusStyleTxt := Rec.GetStatusStyleText();
    end;

    var
        StatusStyleTxt: Text;
        ShowWorkflowStatus: Boolean;
    // VendorVisible: Boolean;
    // ApprovalEntry: Record "Approval Entry";
}
