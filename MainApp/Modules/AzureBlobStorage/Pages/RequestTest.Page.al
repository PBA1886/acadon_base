// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 5282620 "ACA Request Test"
{
    Caption = 'Azure Blob Storage Request Test Page';
    PageType = List;
    UsageCategory = None;
    SourceTable = Integer;
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Code; BlobStorageConn.Code)
                {
                    ApplicationArea = All;
                    Lookup = true;
                    TableRelation = "ACA Blob Storage Connection".Code;

                    trigger OnValidate()
                    begin
                        BlobStorageConn.Get(BlobStorageConn.Code);
                    end;
                }
                field(APIAction; APIAction)
                {
                    ApplicationArea = All;
                    Caption = 'API Action';
                    OptionCaption = 'List Containers,Create Container,Delete Container';
                }
                field(ContainerName; ContainerName)
                {
                    ApplicationArea = All;
                    Caption = 'Container Name';
                }

                field(BlobName; BlobName)
                {
                    ApplicationArea = All;
                    Caption = 'Blob Name';
                }
            }
            group(Result)
            {
                field(GeneratedURI; GeneratedURI)
                {
                    ApplicationArea = All;
                    Caption = 'Generated URI';
                    Editable = false;
                }
                field(ResultText; ResultText)
                {
                    ApplicationArea = All;
                    Caption = 'Result';
                    Editable = false;
                    MultiLine = true;

                    trigger OnAssistEdit()
                    begin
                        Message(ResultText);
                    end;
                }
            }
            part(UriParams; "ACA Req. Test URI Params")
            {
                ApplicationArea = All;
                Editable = true;
            }
            part(ReqHeader; "ACA Req. Test Headers")
            {
                ApplicationArea = All;
                Editable = true;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Execute)
            {
                ApplicationArea = All;
                Image = Start;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Container: Record "ACA Container";
                    API: Codeunit "ACA Blob Storage API";
                    RequestObject: Codeunit "ACA Request Object";
                    OptionalUriParameters: Dictionary of [Text, Text];
                    OptionalReqHeaders: Dictionary of [Text, Text];
                begin
                    CurrPage.UriParams.Page.GetRecordAsDictionairy(OptionalUriParameters);
                    CurrPage.ReqHeader.Page.GetRecordAsDictionairy(OptionalReqHeaders);
                    RequestObject.InitializeRequest(BlobStorageConn."Storage Account Name", ContainerName, BlobName);
                    RequestObject.InitializeAuthorization(BlobStorageConn."Authorization Type", BlobStorageConn.Secret);
                    RequestObject.AddOptionalUriParameter(OptionalUriParameters);
                    RequestObject.AddOptionalHeader(OptionalReqHeaders);

                    case APIAction of
                        APIAction::"List Containers":
                            API.ListContainers(RequestObject, Container, false);
                    end;
                    GeneratedURI := RequestObject.ConstructUri();
                    ResultText := RequestObject.GetHttpResponseAsText();
                end;
            }
        }
    }
    var
        BlobStorageConn: Record "ACA Blob Storage Connection";
        APIAction: Option "List Containers","Create Container","Delete Container";
        ContainerName: Text;
        BlobName: Text;
        ResultText: Text;
        GeneratedURI: Text;
}
