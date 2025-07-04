local _, SAP = ... -- Internal namespace

SLASH_SAPUI1 = "/sap"
SlashCmdList["SAPUI"] = function(msg)
    if msg == "test" then
        SAP:DisplayExternal(nil, GetUnitName("player"))
    elseif msg == "wipe" then
        wipe(SAPSaved)
        ReloadUI()
    elseif msg == "display" then
        SAP_API:DisplayText("Display text", 8)
    elseif msg == "debug" then
        if SAPSaved.Settings["Debug"] then
            SAPSaved.Settings["Debug"] = false
        else
            SAPSaved.Settings["Debug"] = true
        end
        print("|cFF00FFFFSAPSaved|r Debug mode is now "..(SAPSaved.Settings["Debug"] and "enabled" or "disabled"))
    else
        SAP.SAPUI:ToggleOptions()
    end
end