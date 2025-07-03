local _, SAP = ... -- Internal namespace

SLASH_SAPUI1 = "/sap"
SlashCmdList["SAPUI"] = function(msg)
    if msg == "test" then
        SAP:DisplayExternal(nil, GetUnitName("player"))
    elseif msg == "wipe" then
        wipe(SAPRT)
        ReloadUI()
    elseif msg == "display" then
        SAP_API:DisplayText("Display text", 8)
    elseif msg == "debug" then
        if SAPRT.Settings["Debug"] then
            SAPRT.Settings["Debug"] = false
        else
            SAPRT.Settings["Debug"] = true
        end
        print("|cFF00FFFFSAPRT|r Debug mode is now "..(SAPRT.Settings["Debug"] and "enabled" or "disabled"))
    else
        SAP.SAPUI:ToggleOptions()
    end
end