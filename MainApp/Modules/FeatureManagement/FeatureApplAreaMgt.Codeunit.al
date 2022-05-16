codeunit 5282616 "ACA Feature Appl. Area Mgt."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        Feature: Interface "ACA IFeature";
        Ordinal: Integer;
    begin
        foreach Ordinal in "ACA Features".Ordinals() do begin
            Feature := "ACA Features".FromInteger(Ordinal);
            Feature.RefreshApplicationArea(TempApplicationAreaSetup);
        end;
    end;
}
