codeunit 5282630 "ACA Module Appl. Area Mgt."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        Module: Interface "ACA IModule";
        Ordinal: Integer;
    begin
        foreach Ordinal in "ACA Modules".Ordinals() do begin
            Module := "ACA Modules".FromInteger(Ordinal);
            Module.RefreshApplicationArea(TempApplicationAreaSetup);
        end;
    end;
}
