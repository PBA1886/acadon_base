codeunit 5282617 "ACA Feature Management"
{
    procedure Enable(var Feature: Record "ACA Feature")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        IFeature: Interface "ACA IFeature";
        Question: Text;
        FeatureEnableQst: Label 'Do you want to enable feature %1?', Comment = ' %1 = Feature Name';
        NotReversedMsg: Label 'This can not be reversed.';
        FeatureEnabledMsg: Label 'Feature %1 is now enabled.', Comment = ' %1 = Feature Name';
    begin
        if Feature.Enabled then
            exit;

        IFeature := Feature.Feature;
        Question := FeatureEnableQst;

        if not FeatureCanBeInstalled(IFeature) then
            exit;

        if not FeatureCanBeUninstalled(IFeature) then
            Question += '\' + NotReversedMsg;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(Question, IFeature.GetName()), true) then
            exit;

        InstallFeature(IFeature);
        Feature.Enabled := true;
        Feature.Modify();

        Message(FeatureEnabledMsg, IFeature.GetName());
    end;

    procedure Disable(var Feature: Record "ACA Feature")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        FeatureDisableQst: Label 'Do you want to disable feature %1?', Comment = ' %1 = Feature Name';
        FeatureDisabledMsg: Label 'Feature %1 is now disabled.', Comment = ' %1 = Feature Name';
        IFeature: Interface "ACA IFeature";
    begin
        if not Feature.Enabled then
            exit;

        IFeature := Feature.Feature;
        if not FeatureCanBeUninstalled(IFeature) then
            exit;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(FeatureDisableQst, IFeature.GetName()), true) then
            exit;

        FeatureUninstall(IFeature);
        Feature.Enabled := false;
        Feature.Modify();

        Message(FeatureDisabledMsg, IFeature.GetName());
    end;

    procedure FeatureCanBeInstalled(var IFeature: Interface "ACA IFeature") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeFeatureCanBeInstalled(IFeature, Result, IsHandled);
        if IsHandled then
            exit;

        Result := IFeature.CanBeInstalled();
    end;

    procedure FeatureCanBeUninstalled(var IFeature: Interface "ACA IFeature") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeFeatureCanBeUnInstalled(IFeature, Result, IsHandled);
        if IsHandled then
            exit;

        Result := IFeature.CanBeUninstalled();
    end;

    procedure InstallFeature(var IFeature: Interface "ACA IFeature")
    var
        IsHandled: Boolean;
        LogEventIdTok: Label 'ACAFI0001', Locked = true;
        LogDimensionTok: Label 'FeatureMgmt', Locked = true;
        LogDimension2Tok: Label 'Feature', Locked = true;
        LogValueTok: Label 'FeatureInstall', Locked = true;
        MessageTok: Label 'Feature %1 installed.', Locked = true;
    begin
        OnBeforeInstallFeature(IFeature, IsHandled);
        if IsHandled then
            exit;

        IFeature.Install();

        LogMessage(LogEventIdTok, StrSubstNo(MessageTok, IFeature.GetName()), Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, LogDimensionTok, LogValueTok, LogDimension2Tok, IFeature.GetName());
    end;

    procedure FeatureUninstall(var IFeature: Interface "ACA IFeature")
    var
        IsHandled: Boolean;
        LogEventIdTok: Label 'ACAFU0001', Locked = true;
        LogDimensionTok: Label 'FeatureMgmt', Locked = true;
        LogDimension2Tok: Label 'Feature', Locked = true;
        LogValueTok: Label 'FeatureUninstall', Locked = true;
        MessageTok: Label 'Feature %1 uninstalled.', Locked = true;
    begin
        OnBeforeUninstallFeature(IFeature, IsHandled);
        if IsHandled then
            exit;

        IFeature.Uninstall();

        LogMessage(LogEventIdTok, StrSubstNo(MessageTok, IFeature.GetName()), Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, LogDimensionTok, LogValueTok, LogDimension2Tok, IFeature.GetName());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFeatureCanBeInstalled(var IFeature: Interface "ACA IFeature"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFeatureCanBeUnInstalled(var IFeature: Interface "ACA IFeature"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInstallFeature(var IFeature: Interface "ACA IFeature"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUninstallFeature(var IFeature: Interface "ACA IFeature"; var IsHandled: Boolean)
    begin
    end;
}
