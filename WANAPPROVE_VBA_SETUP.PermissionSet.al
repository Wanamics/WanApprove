permissionset 87421 WANAPPROVE_VBA_SETUP
{
    Caption = 'Vendor Bank Account Approval Setup';
    Assignable = true;
    Permissions =
        codeunit "WanApprove VBA Approval" = X,
        codeunit "WanApprove VBA Events Handler" = X,
        codeunit "WanApprove VBA Install" = X,
        codeunit "WanApprove VBA Release" = X,
        codeunit "WanApprove VBA Setup" = X;
}