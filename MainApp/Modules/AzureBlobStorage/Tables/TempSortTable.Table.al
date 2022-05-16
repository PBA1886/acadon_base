// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 5282621 "ACA Temp. Sort Table"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Key"; Text[250])
        {
        }
        field(2; Value; Text[250])
        {
        }
    }

    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
    }
}
