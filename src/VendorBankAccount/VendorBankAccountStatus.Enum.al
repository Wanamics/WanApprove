namespace Wanamics.VendorBankAccountApproval;
enum 87420 "WanApprove VBA Status"
{
    Extensible = true;
    // AssignmentCompatibility = true;

    value(0; Open) { Caption = 'Open'; }
    value(1; Approved) { Caption = 'Approved'; }
    value(2; "Pending") { Caption = 'Pending'; }
    value(3; "Rejected") { Caption = 'Rejected'; }
}
