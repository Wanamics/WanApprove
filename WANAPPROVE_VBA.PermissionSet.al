permissionset 87420 WANAPPROVE
{
    Caption = 'Vendor Bank Account Approval';
    Assignable = true;
    Permissions =
        codeunit "WanApprove VBA Approval" = X,
        codeunit "WanApprove VBA Events Handler" = X,
        codeunit "WanApprove VBA Release" = X;
}