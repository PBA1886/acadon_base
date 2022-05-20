page 5282617 "ACA Modules"
{
    Caption = 'acadon Module Management';
    PageType = List;
    SourceTable = "ACA Module";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;
    AboutTitle = 'About Module Managment';
    AboutText = 'Module Management lists modules that can be enabled/disabled. It makes it possible to hide not needed modules from the application';
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Module; Rec.Module)
                {
                    ToolTip = 'Specifies the value of the Module field';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(AppName; IModule.GetAppName())
                {
                    Caption = 'App Name';
                    ToolTip = 'Specifies the Name of the App where this Module is coming from';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ModuleName; Rec.Name)
                {
                    ToolTip = 'Specifies the Name of the Module.';
                    ApplicationArea = All;
                }
                field(ModuleCategory; Rec.Category)
                {
                    ToolTip = 'Specifies the Category of the Module.';
                    ApplicationArea = All;
                }
                field(ModuleDescription; IModule.GetDescription())
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the Description of the Module.';
                    ApplicationArea = All;
                    AboutTitle = 'What is the module about';
                    AboutText = 'The description gives a short introduction of the module.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Shows if the Module is Enabled.';
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
                AboutTitle = 'Do you want to hide this module?';
                AboutText = 'It is possible to disable the module so that it is hidden throughout the application. In case you want it enabled again, just use the Enable Action';

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
                Visible = IsUnknownModule;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.Delete();
                end;
            }
        }
    }

    var
        IModule: Interface "ACA IModule";
        EnableEnabled, DisableEnabled, IsUnknownModule : Boolean;

    trigger OnAfterGetRecord()
    begin
        SetIModule();

        EnableEnabled := Rec.CanBeInstalled() and not Rec.Enabled;
        DisableEnabled := Rec.CanBeUninstalled() and Rec.Enabled;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsUnknownModule := Rec.IsUnkownModule();
    end;

    trigger OnOpenPage()
    var
        ModuleManagement: Codeunit "ACA Module Management";
    begin
        Rec.UpdateModules();
        ModuleManagement.SendNotificationIfExperienceIsNotSet();
    end;

    local procedure SetIModule()
    begin
        IModule := Rec.Module;
    end;
}
