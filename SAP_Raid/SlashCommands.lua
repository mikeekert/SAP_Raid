local _, SAP = ... -- Internal namespace

SLASH_SAPUI1 = "/ns"
SlashCmdList["SAPUI"] = function(msg)
    if msg == "anchor" then
        if SAP.SAPUI.externals_anchor:IsShown() then
            SAP.SAPUI.externals_anchor:Hide()
        else
            SAP.SAPUI.externals_anchor:Show()
        end
    elseif msg == "test" then
        SAP:DisplayExternal(nil, GetUnitName("player"))
    elseif msg == "wipe" then
        wipe(SAPRT)
        ReloadUI()
    elseif msg == "sync" then
        SAP:NickNamesSyncPopup(GetUnitName("player"), "yayayaya")
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