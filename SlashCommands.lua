local _, SAP = ... -- Internal namespace

SLASH_NSUI1 = "/ns"
SlashCmdList["NSUI"] = function(msg)
    if msg == "anchor" then
        if SAP.NSUI.externals_anchor:IsShown() then
            SAP.NSUI.externals_anchor:Hide()
        else
            SAP.NSUI.externals_anchor:Show()
        end
    elseif msg == "test" then
        NSI:DisplayExternal(nil, GetUnitName("player"))
    elseif msg == "wipe" then
        wipe(SAPRT)
        ReloadUI()
    elseif msg == "sync" then
        NSI:NickNamesSyncPopup(GetUnitName("player"), "yayayaya")
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