// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 5282620 "ACA Authorization Type"
{
    Extensible = true;

    value(0; SasToken)
    {
        Caption = 'Shared Access Signature';
    }
    value(1; SharedKey)
    {
        Caption = 'Shared Key';
    }
}
