page 5282616 "ACA Features"
{
    Caption = 'acadon Upcoming Features';
    PageType = List;
    SourceTable = "ACA Feature";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;
    AboutTitle = 'About Upcoming Features';
    AboutText = 'Upcoming Features lists new features that will become part of the solution in the future. Here you can already enable these features now.';
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Feature; Rec.Feature)
                {
                    ToolTip = 'Specifies the value of the Feature field';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(AppName; IFeature.GetAppName())
                {
                    Caption = 'App Name';
                    ToolTip = 'Specifies the Name of the App where this feature is coming from';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(FeatureName; IFeature.GetName())
                {
                    Caption = 'Name';
                    ToolTip = 'Specifies the Name of the Feature.';
                    ApplicationArea = All;
                }
                field(FeatureDescription; IFeature.GetDescription())
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the Description of the Feature.';
                    ApplicationArea = All;
                    AboutTitle = 'What is the feature about';
                    AboutText = 'The description gives a short introduction of the feature.';
                }
                field("Mandantory By"; IFeature.GetMandantoryBy())
                {
                    Caption = 'Mandantory by';
                    ToolTip = 'Mandantory by version.';
                    ApplicationArea = All;
                    AboutTitle = 'When will the feature be released';
                    AboutText = 'Shows the expected date when the feature will be released as part of the solution.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Shows if the Feature is Enabled.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Creation)
        {
            action(Enable)
            {
                Caption = 'Enable';
                Image = Start;
                ApplicationArea = All;
                Enabled = EnableEnabled;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                AboutTitle = 'Do you want to enable this feature?';
                AboutText = 'It is possible to enable the feature before it is released.';

                trigger OnAction()
                begin
                    Rec.Enable();
                end;
            }
            action(Disable)
            {
                Caption = 'Disable';
                Image = Stop;
                ApplicationArea = All;
                Enabled = DisableEnabled;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.Disable();
                end;
            }
            action(Remove)
            {
                Caption = 'Remove';
                Image = Delete;
                ApplicationArea = All;
                Visible = IsUnknownFeature;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    if Rec.Feature.AsInteger() = 0 then
                        exit;

                    Rec.Delete();
                end;
            }
        }
    }

    var
        IFeature: Interface "ACA IFeature";
        EnableEnabled, DisableEnabled, IsUnknownFeature : Boolean;

    trigger OnAfterGetRecord()
    begin
        SetIFeature();

        EnableEnabled := Rec.CanBeInstalled() and not Rec.Enabled;
        DisableEnabled := Rec.CanBeUninstalled() and Rec.Enabled;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsUnknownFeature := Rec.IsUnkownFeature();
    end;

    trigger OnOpenPage()
    var
        UnknownFeature: Codeunit "ACA Unknown Feature Impl.";
        FeatureManagement: Codeunit "ACA Feature Management";
    begin
        Rec.UpdateFeatures();

        if Rec.IsEmpty() then
            IFeature := UnknownFeature;

        FeatureManagement.SendNotificationIfExperienceIsNotSet();
    end;

    local procedure SetIFeature()
    begin
        IFeature := Rec.Feature;
    end;
}
