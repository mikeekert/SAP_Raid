local _, LUP = ...

function LUP:CreateAuraImportElement(parent)
    -- Outer frame
    local frame = CreateFrame("Frame", nil, parent)

    frame.height = 40

    frame:SetHeight(frame.height)

    -- Icon
    frame.icon = CreateFrame("Frame", nil, frame)

    frame.icon:SetSize(24, 24)
    frame.icon:Hide()
    frame.icon:SetPoint("LEFT", frame, "LEFT", 8, 0)

    frame.icon.tex = frame.icon:CreateTexture(nil, "BACKGROUND")
    frame.icon.tex:SetAllPoints(frame.icon)
    frame.icon.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Display name
    frame.displayName = frame:CreateFontString(nil, "OVERLAY")

    frame.displayName:SetFontObject(LiquidFont17)
    frame.displayName:SetPoint("LEFT", frame, "LEFT", 8, 0)

    function frame:SetDisplayName(displayName)
        frame.displayName:SetText(string.format("|cff%s%s|r", LUP.gs.visual.colorStrings.white, displayName))

        -- If this element shows an addon update instead of an aura update, don't add an update button script
        -- Icon is also hardcoded, rather than taken from aura data (there is no aura)
        if displayName == "SAP_Raid_Updater" then
            frame.icon.tex:SetTexture("Interface\\Addons\\SAP_Raid_Updater\\Media\\Textures\\Bart.tga")
            frame.icon:Show()
            frame.displayName:SetPoint("LEFT", frame, "LEFT", 38, 0)
        else
            local auraData = SAPUpdaterSaved.WeakAuras[displayName]

            frame.importButton:SetScript(
                "OnClick",
                function()
                    -- This should only be necessary if the user manually imported a version of the aura with a different UID, after logging in
                    -- Do it anyway just to be sure
                    LUP:MatchInstalledUID(auraData.d)

                    -- Apply existing "load: never" settings to the aura data before importing
                    local modifiedAuraData = CopyTable(auraData)
                    local installedAuraData = LUP:GetInstalledAuraDataByUID(modifiedAuraData.uid)

                    LUP:ApplyLoadSettings(modifiedAuraData.d, installedAuraData)
                    LUP:ApplyMiscellaneousPositionSettings(modifiedAuraData)

                    local versionString = string.format("1.0.%d", modifiedAuraData.d.sapVersion)
                    modifiedAuraData.d.semver = versionString
                    modifiedAuraData.d.version = versionString

                    if modifiedAuraData.c then
                        for _, childAuraData in pairs(modifiedAuraData.c) do
                            childAuraData.semver = nil
                            childAuraData.version = nil

                            local installedChildAuraData = LUP:GetInstalledAuraDataByUID(childAuraData.uid)

                            LUP:ApplyLoadSettings(childAuraData, installedChildAuraData)
                            LUP:ApplySoundSettings(childAuraData, installedChildAuraData)
                        end
                    end

                    -- Loop through children and save IDs of auras that have custom code on init
                    -- [aura_id] = custom_code (string)
                    local customOnInit = {}

                    for _, childData in ipairs(auraData.c or {auraData.d}) do
                        local doCustom = childData.actions and childData.actions.init and childData.actions.init.do_custom
                        local customCode = doCustom and childData.actions.init.custom

                        if doCustom and customCode and customCode ~= "" then
                            customOnInit[childData.id] = customCode
                        end
                    end

                    WeakAuras.Import(
                        modifiedAuraData,
                        nil,
                        function(success, id)
                            if not success then return end

                            local data = WeakAuras.GetData(id)
                            local version = SAPUpdaterSaved.WeakAuras[displayName].d.sapVersion

                            data.preferToUpdate = true
                            data.ignoreWagoUpdate = true
                            data.sapVersion = version
                            data.semver = string.format("1.0.%d", version)

                            LUP:ForceUpdateOnInit(customOnInit)
                            LUP:OnUpdateAura()
                        end
                    )
                end
            )

            local icon = auraData.d.groupIcon

            if icon then
                frame.icon.tex:SetTexture(icon)
            end

            frame.icon:SetShown(icon)
            frame.displayName:SetPoint("LEFT", frame, "LEFT", icon and 38 or 8, 0)
        end
    end

    -- Version count
    frame.versionCount = frame:CreateFontString(nil, "OVERLAY")

    frame.versionCount:SetFontObject(LiquidFont17)
    frame.versionCount:SetPoint("CENTER", frame, "CENTER")
    
    function frame:SetVersionsBehind(count, isAnchors, isMissing)
        if isAnchors then
            if isMissing then
                frame.versionCount:SetText(string.format("|cff%sMissing!|r", LUP.gs.visual.colorStrings.red))
            end
        elseif isMissing then
            frame.versionCount:SetText(string.format("|cff%sMissing!|r", LUP.gs.visual.colorStrings.red))
        else
            frame.versionCount:SetText(string.format("|cff%s%d version(s) behind|r", LUP.gs.visual.colorStrings.red, count))
        end
    end

    -- Import button
    frame.importButton = LUP:CreateButton(frame, "Import", function() end)

    frame.importButton:SetNormalFontObject(LiquidFont15)
    frame.importButton:SetHighlightFontObject(LiquidFont15)
    frame.importButton:SetDisabledFontObject(LiquidFont15)

    frame.importButton:SetPoint("RIGHT", frame, "RIGHT", -8, 0)

    frame.updateButton = LUP:CreateButton(frame, "Update", function() end)

    frame.updateButton:SetNormalFontObject(LiquidFont15)
    frame.updateButton:SetHighlightFontObject(LiquidFont15)
    frame.updateButton:SetDisabledFontObject(LiquidFont15)

    frame.updateButton:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
    frame.updateButton:Hide()

    -- Requires addon update text
    frame.requiresUpdateText = frame:CreateFontString(nil, "OVERLAY")

    frame.requiresUpdateText:SetFontObject(LiquidFont17)
    frame.requiresUpdateText:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
    frame.requiresUpdateText:SetText(string.format("|cff%sUpdate please!|r", LUP.gs.visual.colorStrings.red))
    frame.requiresUpdateText:Hide()

    LUP.LiquidUI:AddTooltip(frame.requiresUpdateText, "A newer version of this aura is available. Update the addon to receive it.")

    -- Border
    LUP.LiquidUI:AddBorder(frame)

    local borderColor = LUP.LiquidUI.settings.BORDER_COLOR

    frame:SetBorderColor(borderColor.r, borderColor.g, borderColor.b)

    function frame:SetRequiresAddOnUpdate(requiresUpdate, exists)
        frame.importButton:SetShown(not requiresUpdate and not exists)
        frame.updateButton:SetShown(not requiresUpdate and exists)
        frame.requiresUpdateText:SetShown(requiresUpdate)
    end

    return frame
end