namespace Wanamics.VendorBankAccountApproval;

using Microsoft.Purchases.Vendor;
using System.Automation;

pageextension 87420 "WanApprove VBA Card" extends "Vendor Bank Account Card"
{
    layout
    {
        addlast(General)
        {
            field(Status; Rec."wan Approval Status")
            {
                ApplicationArea = Suite;
                Importance = Promoted;
                StyleExpr = StatusStyleTxt;
                ToolTip = 'Specifies whether the record is open, waiting to be approved, or released to the next stage of processing.';
            }
        }
        addlast(factboxes)
        {
            part(PendingApprovalFactBox; "Pending Approval FactBox")
            {
                ApplicationArea = Suite;
                // SubPageLink = "Table ID" = const(288),
                //               "Document No." = field("Vendor No."), // No link for Code (PK2)
                //               Status = const(Open);
                Visible = OpenApprovalEntriesExistForCurrUser;
            }
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
    actions
    {
        addfirst(navigation)
        {
            action(Approvals)
            {
                AccessByPermission = TableData "Approval Entry" = R;
                ApplicationArea = Suite;
                Caption = 'Approvals';
                Image = Approvals;
                ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                trigger OnAction()
                begin
                    ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                end;
            }
        }
        addfirst(Processing)
        {
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = Suite;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the requested changes to the substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval of the %1.', Comment = '%1:VendorBankAccount.TableCaption';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "WanApprove VBA Approval";
                    begin
                        if ApprovalsMgmt.CheckApprovalWorkflowEnabled(RecRef) then
                            ApprovalsMgmt.OnSendWorkflowForApploval(RecRef);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        Approval: Codeunit "WanApprove VBA Approval";
                    begin
                        Approval.OnCancelWorkflowForApploval(RecRef);
                        WorkflowWebhookManagement.FindAndCancel(Rec.RecordId);
                    end;
                }
                group(Flow)
                {
                    Caption = 'Power Automate';
                    Image = Flow;

                    customaction(CreateFlowFromTemplate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Create approval flow';
                        ToolTip = 'Create a new flow in Power Automate from a list of relevant flow templates.';
                        // #if not CLEAN22
                        //                         Visible = IsSaaS and PowerAutomateTemplatesEnabled and IsPowerAutomatePrivacyNoticeApproved;
                        // #else
                        //                         Visible = IsSaaS and IsPowerAutomatePrivacyNoticeApproved;
                        // #endif
                        CustomActionType = FlowTemplateGallery;
                        FlowTemplateCategoryName = 'd365bc_approval_vendorbankaccount';
                    }
                    // #if not CLEAN22
                    //                     action(CreateFlow)
                    //                     {
                    //                         ApplicationArea = Basic, Suite;
                    //                         Caption = 'Create a Power Automate approval flow';
                    //                         Image = Flow;
                    //                         ToolTip = 'Create a new flow in Power Automate from a list of relevant flow templates.';
                    //                         Visible = IsSaaS and not PowerAutomateTemplatesEnabled and IsPowerAutomatePrivacyNoticeApproved;
                    //                         ObsoleteReason = 'This action will be handled by platform as part of the CreateFlowFromTemplate customaction';
                    //                         ObsoleteState = Pending;
                    //                         ObsoleteTag = '22.0';

                    //                         trigger OnAction()
                    //                         var
                    //                             FlowServiceManagement: Codeunit "Flow Service Management";
                    //                             FlowTemplateSelector: Page "Flow Template Selector";
                    //                         begin
                    //                             // Opens page 6400 where the user can use filtered templates to create new flows.
                    //                             FlowTemplateSelector.SetSearchText(FlowServiceManagement.GetPurchasingTemplateFilter());
                    //                             FlowTemplateSelector.Run();
                    //                         end;
                    //                     }
                    // #endif
                    // #if not CLEAN21
                    //                     action(SeeFlows)
                    //                     {
                    //                         ApplicationArea = Basic, Suite;
                    //                         Caption = 'See my flows';
                    //                         Image = Flow;
                    //                         RunObject = Page "Flow Selector";
                    //                         ToolTip = 'View and configure Power Automate flows that you created.';
                    //                         Visible = false;
                    //                         ObsoleteState = Pending;
                    //                         ObsoleteReason = 'This action has been moved to the tab dedicated to Power Automate';
                    //                         ObsoleteTag = '21.0';
                    //                     }
                    // #endif
                }
            }
            group(Action13)
            {
                Caption = 'Release';
                Image = ReleaseDoc;


                action(Release)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the %1 to the next stage of processing. You must reopen the %1 before you can make changes to it.', Comment = '%1:TableCaption';

                    trigger OnAction()
                    var
                        ReleaseVendorBankAccount: Codeunit "WanApprove VBA Release";
                    begin
                        ReleaseVendorBankAccount.Run(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&open';
                    Enabled = Rec."wan Approval Status" <> Rec."wan Approval Status"::Open;
                    Image = ReOpen;
                    ToolTip = 'Reopen the %1 to change it after it has been approved.', Comment = '%1:VendorBankAccount.TableCaption';

                    trigger OnAction()
                    var
                        ReleaseVendorBankAccount: Codeunit "WanApprove VBA Release";
                    begin
                        ReleaseVendorBankAccount.PerformManualReopen(Rec);
                    end;
                }
            }
        }

        addlast(Promoted)
        {
            group(ReleaseGroup)
            {
                ShowAs = SplitButton;
                Caption = 'Release';
                actionref(Release_Promoted; Release) { }
                actionref(Reopen_Promoted; Reopen) { }
            }
            group(Approver)
            {
                ShowAs = SplitButton;

                actionref(Approve_Promoted; Approve)
                {
                }
                actionref(Reject_Promoted; Reject)
                {
                }
                actionref(Comment_Promoted; Comment)
                {
                }
                actionref(Delegate_Promoted; Delegate)
                {
                }
            }
            group(RequestApproval)
            {
                Caption = 'Request Approval';
                ShowAs = SplitButton;

                actionref(SendApprovalRequest_Promoted; SendApprovalRequest)
                {
                }
                actionref(CancelApprovalRequest_Promoted; CancelApprovalRequest)
                {
                }
                // #if not CLEAN21
                //                 actionref(CreateFlow_Promoted; CreateFlow)
                //                 {
                //                     Visible = false;
                //                     ObsoleteState = Pending;
                //                     ObsoleteReason = 'Action is being demoted based on overall low usage.';
                //                     ObsoleteTag = '21.0';
                //                 }
                // #endif
                // #if not CLEAN21
                //                 actionref(SeeFlows_Promoted; SeeFlows)
                //                 {
                //                     Visible = false;
                //                     ObsoleteState = Pending;
                //                     ObsoleteReason = 'This action has been moved to the tab dedicated to Power Automate';
                //                     ObsoleteTag = '21.0';
                //                 }
                // #endif
                actionref(Approvals_Promoted; Approvals)
                {
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        if GuiAllowed() then
            OnAfterGetCurrRecordFunc();
    end;

    local procedure OnAfterGetCurrRecordFunc()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        ShowWorkflowStatus := CurrPage.WorkflowStatus.Page.SetFilterOnWorkflowRecord(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookManagement.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);

        CurrPage.Editable := Rec."wan Approval Status" = Rec."wan Approval Status"::Open;
        RecRef.GetTable(Rec);
        CurrPage.ApprovalFactBox.Page.UpdateApprovalEntriesFromSourceRecord(Rec.RecordId());
        ShowWorkflowStatus := CurrPage.WorkflowStatus.Page.SetFilterOnWorkflowRecord(Rec.RecordId());
        StatusStyleTxt := Rec.GetStatusStyleText();

        ApprovalEntry.SetRange("Record ID to Approve", Rec.RecordId());
        CurrPage.PendingApprovalFactBox.Page.SetTableView(ApprovalEntry);
    end;

    //     trigger OnInit()
    //     begin
    //         IsPowerAutomatePrivacyNoticeApproved := PrivacyNotice.GetPrivacyNoticeApprovalState(PrivacyNoticeRegistrations.GetPowerAutomatePrivacyNoticeId()) = "Privacy Notice Approval State"::Agreed;

    // #if not CLEAN22
    //         InitPowerAutomateTemplateVisibility();
    // #endif
    //     end;

    // trigger OnOpenPage()
    // begin
    //     if GuiAllowed() then
    //         OnOpenPageFunc();
    // end;

    // local procedure OnOpenPageFunc()
    // var
    //     EnvironmentInfo: Codeunit "Environment Information";
    // begin
    //     IsSaaS := EnvironmentInfo.IsSaaS();
    // end;

    var
        StatusStyleTxt: Text;
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        // PrivacyNotice: Codeunit "Privacy Notice";
        // PrivacyNoticeRegistrations: Codeunit "Privacy Notice Registrations";
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        ShowWorkflowStatus: Boolean;
        CanCancelApprovalForRecord: Boolean;
        // IsPowerAutomatePrivacyNoticeApproved: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        // IsSaaS: Boolean;



        RecRef: RecordRef;

    // #if not CLEAN22
    //     var
    //         PowerAutomateTemplatesEnabled: Boolean;
    //         PowerAutomateTemplatesFeatureLbl: Label 'PowerAutomateTemplates', Locked = true;

    //     local procedure InitPowerAutomateTemplateVisibility()
    //     var
    //         FeatureKey: Record "Feature Key";
    //     begin
    //         PowerAutomateTemplatesEnabled := true;
    //         if FeatureKey.Get(PowerAutomateTemplatesFeatureLbl) then
    //             if FeatureKey.Enabled <> FeatureKey.Enabled::"All Users" then
    //                 PowerAutomateTemplatesEnabled := false;
    //     end;
    // #endif
}
