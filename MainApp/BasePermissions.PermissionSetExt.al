permissionsetextension 5282616 "ACA Base Permissions" extends LOGIN
{
    Permissions =
        tabledata "ACA Module" = RIMD,
        tabledata "ACA Feature" = RIMD,
        tabledata "ACA Blob Storage Connection" = RIMD,

        codeunit "ACA Json Management" = X,
        codeunit "ACA Rest Client" = X;
}