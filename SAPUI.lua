local _, SAP = ... -- Internal namespace
local DF = _G["DetailsFramework"]
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0")
local WA = _G["WeakAuras"]

local window_width = 800
local window_height = 515
local expressway = [[Interface\AddOns\SAP_Raid\Media\Fonts\Expressway.TTF]]

local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

local SAPUI_panel_options = {
    UseStatusBar = true
}
local SAPUI = DF:CreateSimplePanel(UIParent, window_width, window_height, "|cFF00FFFFSAP|r Raid Tools", "SAPUI",
    SAPUI_panel_options)
SAPUI:SetPoint("CENTER")
SAPUI:SetFrameStrata("HIGH")
DF:BuildStatusbarAuthorInfo(SAPUI.StatusBar, _, "x |cFF00FFFFtemporary|r")
SAPUI.StatusBar.discordTextEntry:SetText(":)")

SAPUI.OptionsChanged = {
    ["general"] = {},
    ["externals"] = {},
    ["versions"] = {},
}

-- need to run this code on settings change
local function PASelfPingChanged()
    local macrocount = 0
    local pafound = false
    for i = 1, 120 do
        local macroname = C_Macro.GetMacroName(i)
        if not macroname then break end
        macrocount = i
        if macroname == "SAP PA Macro" then
            pafound = true
            local macrotext = "/run SAP_API:PrivateAura();"
            if SAPSaved.Settings["PASelfPing"] then
                 macrotext = macrotext.."\n/ping [@player] Warning;"
             end
            if SAPSaved.Settings["PAExtraAction"] then
                macrotext = macrotext.."\n/click ExtraActionButton1"
            end            

             EditMacro(i, "SAP PA Macro", 132288, macrotext, false)
            return
        end
    end
    if macrocount >= 120 then
        print("You reached the global Macro cap so the Private Aura Macro could not be created")
    elseif not pafound then
        macrocount = macrocount+1
        local macrotext = "/run SAP_API:PrivateAura();"
        if SAPSaved.Settings["PASelfPing"] then
             macrotext = macrotext.."\n/ping [@player] Warning;"
         end
        if SAPSaved.Settings["PAExtraAction"] then
            macrotext = macrotext.."\n/click ExtraActionButton1"
        end
        CreateMacro("SAP PA Macro", 132288, macrotext, false)
    end
end

-- version check ui
local component_type = "WA"
local checkable_components = { "WA", "Addon", "Note" }
local function build_checkable_components_options()
    local t = {}
    for i = 1, #checkable_components do
        tinsert(t, {
            label = checkable_components[i],
            value = checkable_components[i],
            onclick = function(_, _, value)
                component_type = value
            end
        })
    end
    return t
end

local component_name = ""
local function BuildVersionCheckUI(parent)
    local hide_version_response_button = DF:CreateSwitch(parent,
        function(self, _, value) SAPSaved.Settings["VersionCheckRemoveResponse"] = value end,
        SAPSaved.Settings["VersionCheckRemoveResponse"], 20, 20, nil, nil, nil, "VersionCheckResponseToggle", nil, nil, nil,
            "Hide Version Check Responses", options_switch_template, options_text_template)
    hide_version_response_button:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -100)
    hide_version_response_button:SetAsCheckBox()
    hide_version_response_button:SetTooltip(
        "Hides Version Check Responses of Users that are on the correct version and do not have any duplicates")
    local hide_version_response_label = DF:CreateLabel(parent, "Hide Version Check Responses", 10, "white", "", nil,
        "VersionCheckResponseLabel", "overlay")
    hide_version_response_label:SetTemplate(options_text_template)
    hide_version_response_label:SetPoint("LEFT", hide_version_response_button, "RIGHT", 2, 0)
    local component_type_label = DF:CreateLabel(parent, "Component Type", 9.5, "white")
    component_type_label:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -130)
    
    local component_type_dropdown = DF:CreateDropDown(parent, function() return build_checkable_components_options() end, checkable_components[1])
    component_type_dropdown:SetTemplate(options_dropdown_template)
    component_type_dropdown:SetPoint("LEFT", component_type_label, "RIGHT", 5, 0)

    local component_name_label = DF:CreateLabel(parent, "WeakAura/Addon Name", 9.5, "white")
    component_name_label:SetPoint("LEFT", component_type_dropdown, "RIGHT", 10, 0)

    local component_name_entry = DF:CreateTextEntry(parent, function(_, _, value) component_name = value end, 250, 18)
    component_name_entry:SetTemplate(options_button_template)
    component_name_entry:SetPoint("LEFT", component_name_label, "RIGHT", 5, 0)
    component_name_entry:SetHook("OnEditFocusGained", function(self)
        component_name_entry.WAAutoCompleteList = SAPSaved.SAPUI.AutoComplete["WA"] or {}
        component_name_entry.AddonAutoCompleteList = SAPSaved.SAPUI.AutoComplete["Addon"] or {}
        local _component_type = component_type_dropdown:GetValue()
        if _component_type == "WA" then
            component_name_entry:SetAsAutoComplete("WAAutoCompleteList", _, true)
        elseif _component_type == "Addon" then
            component_name_entry:SetAsAutoComplete("AddonAutoCompleteList", _, true)
        end
    end)

    local version_check_button = DF:CreateButton(parent, function()
    end, 120, 18, "Check Versions")
    version_check_button:SetTemplate(options_button_template)
    version_check_button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -30, -130)
    version_check_button:SetHook("OnShow", function(self)
        if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
            self:Enable()
        else
            self:Disable()
        end
    end)

    local character_name_header = DF:CreateLabel(parent, "Character Name", 11)
    character_name_header:SetPoint("TOPLEFT", component_type_label, "BOTTOMLEFT", 10, -20)

    local version_number_header = DF:CreateLabel(parent, "Version Number", 11)
    version_number_header:SetPoint("LEFT", character_name_header, "RIGHT", 120, 0)

    local duplicate_header = DF:CreateLabel(parent, "Duplicate", 11)
    duplicate_header:SetPoint("LEFT", version_number_header, "RIGHT", 50, 0)

    local function refresh(self, data, offset, totalLines)
        for i = 1, totalLines do
            local index = i + offset
            local thisData = data[index] -- thisData = {{name = "Ravxd", version = 1.0, duplicate = true}}
            if thisData then
                local line = self:GetLine(i)

                local name = thisData.name
                local version = thisData.version
                local duplicate = thisData.duplicate

                line.version:SetText(version)
                line.duplicates:SetText(duplicate and "Yes" or "No")

                -- version number color                
                if version and version == "Offline" then
                    line.version:SetTextColor(0.5, 0.5, 0.5, 1)
                elseif version and data[1] and data[1].version and version == data[1].version then
                    line.version:SetTextColor(0, 1, 0, 1)
                else
                    line.version:SetTextColor(1, 0, 0, 1)
                end

                -- duplicates color
                if duplicate then
                    line.duplicates:SetTextColor(1, 0, 0, 1)
                else
                    line.duplicates:SetTextColor(0, 1, 0, 1)
                end
                
                line:SetScript("OnClick", function(_)
                    local message = ""
                    local now = GetTime()
                    if (SAP.VersionCheckData.lastclick[name] and now < SAP.VersionCheckData.lastclick[name] + 5) or (thisData.version == SAP.VersionCheckData.version and not thisData.duplicate) or thisData.version == "No Response" then return end
                    SAP.VersionCheckData.lastclick[name] = now
                    if SAP.VersionCheckData.type == "WA" then
                        local url = SAP.VersionCheckData.url ~= "" and SAP.VersionCheckData.url or SAP.VersionCheckData.name
                        if thisData.version == "WA Missing" then message = "Please install the WeakAura: "..url
                        elseif thisData.version ~= SAP.VersionCheckData.version then message = "Please update your WeakAura: "..url end
                        if thisData.duplicate then
                            if message == "" then 
                                message = "Please delete the duplicate WeakAura of: '"..SAP.VersionCheckData.name.."'"
                            else 
                                message = message.." Please also delete the duplicate WeakAura"
                            end
                        end
                    elseif SAP.VersionCheckData.type == "Addon" then
                        if thisData.version == "Addon not enabled" then message = "Please enable the Addon: '"..SAP.VersionCheckData.name.."'"
                        elseif thisData.version == "Addon Missing" then message = "Please install the Addon: '"..SAP.VersionCheckData.name.."'"
                        else message = "Please update the Addon: '"..SAP.VersionCheckData.name.."'" end
                    elseif SAP.VersionCheckData.type == "Note" then
                        if thisData.version == "MRT not enabled" then message = "Please enable MRT"
                        elseif thisData.version == "MRT not installed" then message = "Please install MRT"
                        else return end
                    end
                    SAP.VersionCheckData.lastclick[name] = GetTime()
                    SendChatMessage(message, "WHISPER", nil, name)
                end)
            end
        end
    end

    local function createLineFunc(self, index)
        local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
        line:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -((index-1) * (self.LineHeight+1)) - 1)
        line:SetSize(self:GetWidth() - 2, self.LineHeight)
        DF:ApplyStandardBackdrop(line)
        DF:CreateHighlightTexture(line)
        line.index = index

        local name = line:CreateFontString(nil, "OVERLAY")
        name:SetWidth(100)
        name:SetJustifyH("LEFT")
        name:SetFont(expressway, 12, "OUTLINE")
        name:SetPoint("LEFT", line, "LEFT", 5, 0)
        line.name = name

        local version = line:CreateFontString(nil, "OVERLAY")
        version:SetWidth(100)
        version:SetJustifyH("LEFT")
        version:SetFont(expressway, 12, "OUTLINE")
        version:SetPoint("LEFT", name, "RIGHT", 110, 0)
        line.version = version

        local duplicates = line:CreateFontString(nil, "OVERLAY")
        duplicates:SetWidth(100)
        duplicates:SetJustifyH("LEFT")
        duplicates:SetFont(expressway, 12, "OUTLINE")
        duplicates:SetPoint("LEFT", version, "RIGHT", 30, 0)
        line.duplicates = duplicates

        return line
    end

    local scrollLines = 19
    -- sample data for testing
    local sample_data = {
        { name = "Player1",  version = "1.0.0",         duplicate = false },
        { name = "Player2",  version = "WA Missing",    duplicate = false },
        { name = "Player3",  version = "1.0.1",         duplicate = true },
        { name = "Player4",  version = "0.9.9",         duplicate = false },
        { name = "Player5",  version = "1.0.0",         duplicate = false },
        { name = "Player6",  version = "Addon Missing", duplicate = false },
        { name = "Player7",  version = "1.0.0",         duplicate = true },
        { name = "Player8",  version = "0.9.8",         duplicate = false },
        { name = "Player9",  version = "1.0.0",         duplicate = false },
        { name = "Player10", version = "Note Missing",  duplicate = false },
        { name = "Player11", version = "1.0.0",         duplicate = false },
        { name = "Player12", version = "0.9.9",         duplicate = true },
        { name = "Player13", version = "1.0.0",         duplicate = false },
        { name = "Player14", version = "WA Missing",    duplicate = false },
        { name = "Player15", version = "1.0.0",         duplicate = false },
        { name = "Player16", version = "0.9.7",         duplicate = false },
        { name = "Player17", version = "1.0.0",         duplicate = true },
        { name = "Player18", version = "Addon Missing", duplicate = false },
        { name = "Player19", version = "1.0.0",         duplicate = false },
        { name = "Player20", version = "0.9.9",         duplicate = false }
    }
    local version_check_scrollbox = DF:CreateScrollBox(parent, "VersionCheckScrollBox", refresh, {},
        window_width - 40,
        window_height - 200, scrollLines, 20, createLineFunc)
    DF:ReskinSlider(version_check_scrollbox)
    version_check_scrollbox.ReajustNumFrames = true
    version_check_scrollbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -170)
    for i = 1, scrollLines do
        version_check_scrollbox:CreateLine(createLineFunc)
    end
    version_check_scrollbox:Refresh()

    version_check_scrollbox.name_map = {}
    local addData = function(self, data, url)
        local currentData = self:GetData() -- currentData = {{name, version, duplicate}...}

        if self.name_map[data.name] then
            if SAPSaved.Settings["VersionCheckRemoveResponse"] and currentData[1] and currentData[1].version and data.version and data.version == currentData[1].version and data.version ~= "WA Missing" and data.version ~= "Addon Missing" and data.version ~= "Note Missing" and not data.duplicate then
                table.remove(currentData, self.name_map[data.name])
                for k, v in pairs(self.name_map) do
                    if v > self.name_map[data.name] then
                        self.name_map[k] = v - 1
                    end
                end
            else
                currentData[self.name_map[data.name]] = data
            end
        else
            self.name_map[data.name] = #currentData + 1
            tinsert(currentData, data)
        end
        self:Refresh()
    end

    local wipeData = function(self)
        self:SetData({})
        wipe(self.name_map)
        self:Refresh()
    end

    version_check_scrollbox.AddData = addData
    version_check_scrollbox.WipeData = wipeData

    version_check_button:SetScript("OnClick", function(self)
        
        local text = component_name_entry:GetText()
        local _component_type = component_type_dropdown:GetValue()
        if text and text ~= ""  and not tContains(SAPSaved.SAPUI.AutoComplete[_component_type], text) then
            tinsert(SAPSaved.AutoComplete[_component_type], text)
        end

        if not text or text == "" and _component_type ~= "Note" then return end
        
        local now = GetTime()
        if SAP.LastVersionCheck and SAP.LastVersionCheck > now-2 then return end -- don't let user spam requests
        SAP.LastVersionCheck = now
        version_check_scrollbox:WipeData()
        local userData, url = SAP:RequestVersionNumber(_component_type, text)
        if userData then
            SAP.VersionCheckData = { version = userData.version, type = _component_type, name = text, url = url, lastclick = {} }
            version_check_scrollbox:AddData(userData, url)
        end
    end)

    -- version check presets
    local preset_label = DF:CreateLabel(parent, "Preset:", 9.5, "white")

    local sample_presets = {
        { "WA: Northern Sky Liberation of Undermine", { "WA", "Northern Sky Liberation of Undermine" } },
        { "Addon: Plater",                            { "Addon", "Plater" } }
    }

    local function build_version_check_presets_options()
        SAPSaved.Settings["VersionCheckPresets"] = SAPSaved.Settings["VersionCheckPresets"] or
            {} -- structure will be {{label, {type, name}}}
        local t = {}
        for i = 1, #SAPSaved.Settings["VersionCheckPresets"] do
            local v = SAPSaved.Settings["VersionCheckPresets"][i]
            tinsert(t, {
                label = v[1], -- label
                value = v[2], -- {type, name}
                onclick = function(_, _, value)
                    component_type_dropdown:Select(value[1])
                    component_name_entry:SetText(value[2])
                end
            })
        end
        return t
    end
    local version_check_preset_dropdown = DF:CreateDropDown(parent,
        function() return build_version_check_presets_options() end)
    version_check_preset_dropdown:SetTemplate(options_dropdown_template)

    local version_presets_edit_frame = DF:CreateSimplePanel(parent, 400, window_height / 2, "Version Preset Management",
        "VersionPresetsEditFrame", {
            DontRightClickClose = true,
            NoScripts = true
        })
    version_presets_edit_frame:ClearAllPoints()
    version_presets_edit_frame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 2, 2)
    version_presets_edit_frame:Hide()

    local version_presets_edit_button = DF:CreateButton(parent, function()
        if version_presets_edit_frame:IsShown() then
            version_presets_edit_frame:Hide()
        else
            version_presets_edit_frame:Show()
        end
    end, 120, 18, "Edit Version Presets")
    version_presets_edit_button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -30, -100)
    version_presets_edit_button:SetTemplate(options_button_template)
    version_check_preset_dropdown:SetPoint("RIGHT", version_presets_edit_button, "LEFT", -10, 0)
    preset_label:SetPoint("RIGHT", version_check_preset_dropdown, "LEFT", -5, 0)

    local function refreshPresets(self, data, offset, totalLines)
        for i = 1, totalLines do
            local index = i + offset
            local presetData = data[index]
            if presetData then
                local line = self:GetLine(i)

                local label = presetData[1]
                local value = presetData[2]
                local _component_type = value[1]
                local _component_name = value[2]

                line.index = index

                line.value = value
                line.component_type = _component_type
                line.component_name = _component_name

                line.type:SetText(_component_type)
                line.name:SetText(_component_name)
            end
        end
    end

    local function createPresetLineFunc(self, index)
        local line = CreateFrame("Frame", "$parentLine" .. index, self, "BackdropTemplate")
        line:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -((index - 1) * (self.LineHeight)) - 1)
        line:SetSize(self:GetWidth() - 2, self.LineHeight)
        DF:ApplyStandardBackdrop(line)

        -- Type Dropdown
        line.type = DF:CreateLabel(line, "", 9.5, "white")
        line.type:SetPoint("LEFT", line, "LEFT", 5, 0)
        line.type:SetTemplate(options_text_template)

        -- Name text
        line.name = DF:CreateLabel(line, "", 9.5, "white")
        line.name:SetTemplate(options_text_template)
        line.name:SetPoint("LEFT", line, "LEFT", 50, 0)

        -- Delete button
        line.deleteButton = DF:CreateButton(line, function()
            tremove(SAPSaved.Settings["VersionCheckPresets"], line.index)
            self:SetData(SAPSaved.Settings["VersionCheckPresets"])
            self:Refresh()
            version_check_preset_dropdown:Refresh()
        end, 12, 12)
        line.deleteButton:SetNormalTexture([[Interface\GLUES\LOGIN\Glues-CheckBox-Check]])
        line.deleteButton:SetHighlightTexture([[Interface\GLUES\LOGIN\Glues-CheckBox-Check]])
        line.deleteButton:SetPushedTexture([[Interface\GLUES\LOGIN\Glues-CheckBox-Check]])

        line.deleteButton:GetNormalTexture():SetDesaturated(true)
        line.deleteButton:GetHighlightTexture():SetDesaturated(true)
        line.deleteButton:GetPushedTexture():SetDesaturated(true)
        line.deleteButton:SetPoint("RIGHT", line, "RIGHT", -5, 0)

        return line
    end

    local presetScrollLines = 9
    local version_presets_edit_scrollbox = DF:CreateScrollBox(version_presets_edit_frame,
        "$parentVersionPresetsEditScrollBox", refreshPresets, SAPSaved.Settings["VersionCheckPresets"], 360,
        window_height / 2 - 75, presetScrollLines, 20, createPresetLineFunc)
    version_presets_edit_scrollbox:SetPoint("TOPLEFT", version_presets_edit_frame, "TOPLEFT", 10, -30)
    DF:ReskinSlider(version_presets_edit_scrollbox)

    for i = 1, presetScrollLines do
        version_presets_edit_scrollbox:CreateLine(createPresetLineFunc)
    end

    version_presets_edit_scrollbox:Refresh()

    -- Add new preset
    local new_preset_type_label = DF:CreateLabel(version_presets_edit_frame, "Type:", 11)
    new_preset_type_label:SetPoint("TOPLEFT", version_presets_edit_scrollbox, "BOTTOMLEFT", 0, -20)

    local new_preset_type_dropdown = DF:CreateDropDown(version_presets_edit_frame,
        function() return build_checkable_components_options() end, checkable_components[1], 65)
    new_preset_type_dropdown:SetPoint("LEFT", new_preset_type_label, "RIGHT", 5, 0)
    new_preset_type_dropdown:SetTemplate(options_dropdown_template)

    local new_preset_name_label = DF:CreateLabel(version_presets_edit_frame, "Name:", 11)
    new_preset_name_label:SetPoint("LEFT", new_preset_type_dropdown, "RIGHT", 10, 0)

    local new_preset_name_entry = DF:CreateTextEntry(version_presets_edit_frame, function() end, 165, 20)
    new_preset_name_entry:SetPoint("LEFT", new_preset_name_label, "RIGHT", 5, 0)
    new_preset_name_entry:SetTemplate(options_dropdown_template)

    local add_button = DF:CreateButton(version_presets_edit_frame, function()
        local name = new_preset_name_entry:GetText()
        local type = new_preset_type_dropdown:GetValue()
        tinsert(SAPSaved.Settings["VersionCheckPresets"], { type .. ": " .. name, { type, name } })
        version_presets_edit_scrollbox:SetData(SAPSaved.Settings["VersionCheckPresets"])
        version_presets_edit_scrollbox:Refresh()
        version_check_preset_dropdown:Refresh()
        new_preset_name_entry:SetText("")
        new_preset_type_dropdown:Select(checkable_components[1])
    end, 60, 20, "New")
    add_button:SetPoint("LEFT", new_preset_name_entry, "RIGHT", 10, 0)
    add_button:SetTemplate(options_button_template)
    return version_check_scrollbox
end

function SAPUI:Init()
    -- Create the scale bar
    DF:CreateScaleBar(SAPUI, SAPSaved.SAPUI)
    SAPUI:SetScale(SAPSaved.SAPUI.scale)

    -- Create the tab container
    local tabContainer = DF:CreateTabContainer(SAPUI, "", "SAPUI_TabsTemplate", {
        { name = "General",   text = "General" },
        { name = "Versions",  text = "Versions" },
        { name = "WeakAuras",   text = "WeakAuras" },
    }, {
        width = window_width,
        height = window_height - 5,
        backdrop_color = { 0, 0, 0, 0.2 },
        backdrop_border_color = { 0.1, 0.1, 0.1, 0.4 }
    })
    tabContainer:SetPoint("CENTER", SAPUI, "CENTER", 0, 0)

    local general_tab = tabContainer:GetTabFrameByName("General")
    local versions_tab = tabContainer:GetTabFrameByName("Versions")
    local weakaura_tab = tabContainer:GetTabFrameByName("WeakAuras")
    
    -- generic text display
    local generic_display = CreateFrame("Frame", "SAPUIGenericDisplay", UIParent, "BackdropTemplate")
    generic_display:SetPoint("CENTER", UIParent, "CENTER", 0, 350)
    generic_display:SetSize(300, 100)
    generic_display.text = generic_display:CreateFontString(nil, "OVERLAY")
    generic_display.text:SetFont(expressway, 20, "OUTLINE")
    generic_display.text:SetPoint("CENTER", generic_display, "CENTER", 0, 0)
    generic_display:Hide()
    SAPUI.generic_display = generic_display

    local externals_anchor = CreateFrame("Frame", "ExternalsAnchor", UIParent, "BackdropTemplate")
    SAPUI.externals_anchor = externals_anchor
    externals_anchor:SetClampedToScreen(true)
    externals_anchor:SetMovable(true)
    externals_anchor:SetBackdrop({
        bgFile = "interface/editmode/editmodeuihighlightbackground",
        edgeFile = "interface/buttons/white8x8",
        edgeSize = 2,
        tile = true,
        tileSize = 16,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    })
    externals_anchor:SetBackdropBorderColor(1, 0, 0, 1)

    local externals_anchor_text = externals_anchor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    externals_anchor_text:SetPoint("CENTER", externals_anchor, "CENTER", 0, 0)
    externals_anchor_text:SetText("SAP_EXT")
    externals_anchor.text = externals_anchor_text

    externals_anchor:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        elseif button == "RightButton" then
            SAPUI:ResetExternalsAnchorPosition()
        end
    end)
    externals_anchor:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
        SAPUI:SaveExternalsAnchorPosition()
    end)
    externals_anchor:Hide()

    local external_frame = CreateFrame("Frame", "ExternalsFrame", UIParent)
    external_frame:SetPoint("BOTTOMLEFT", SAPUI.externals_anchor, "BOTTOMLEFT", 0, 0)
    external_frame:SetPoint("TOPRIGHT", SAPUI.externals_anchor, "TOPRIGHT", 0, 0)
    local external_frame_text = external_frame:CreateFontString(nil, "OVERLAY")
    external_frame_text:SetFont([[Interface\AddOns\SAP_Raid\Media\Fonts\Expressway.TTF]], 20, "OUTLINE")
    external_frame_text:SetTextColor(1, 1, 1, 1)
    external_frame_text:SetPoint("CENTER", external_frame, "TOP", 0, 10)
    external_frame_text:SetText("SAP_EXT")
    external_frame.text = external_frame_text
    local external_frame_texture = external_frame:CreateTexture("ExternalsFrameTexture", "OVERLAY")
    external_frame_texture:SetPoint("TOPLEFT", external_frame, "TOPLEFT", 0, 0)
    external_frame_texture:SetPoint("BOTTOMRIGHT", external_frame, "BOTTOMRIGHT", 0, 0)
    external_frame_texture:SetColorTexture(1, 0, 1, 0.5)
    external_frame.texture = external_frame_texture
    external_frame:Hide()
    SAPUI.external_frame = external_frame

    -- TTS voice preview
    local tts_text_preview = ""

    -- keybinding logic
    local function getMacroKeybind(macroName)
        local binding = GetBindingKey(macroName)
        if binding then
            return binding
        else
            return "Unbound"
        end
    end

    local function bindKeybind(keyCombo, macroName)
        keyCombo = keyCombo:gsub("LeftButton", "BUTTON1")
            :gsub("RightButton", "BUTTON2")
            :gsub("MiddleButton", "BUTTON3")
            :gsub("Button4", "BUTTON4")
            :gsub("Button5", "BUTTON5")

        local existingBinding = GetBindingAction(keyCombo)
        if existingBinding and existingBinding ~= macroName and existingBinding ~= "" then
            SetBinding(keyCombo, nil)
            print("|cFF00FFFFSAPSaved:|r Overriding existing binding for " .. existingBinding .. " to " .. macroName)
        end

        local existingKeybind = GetBindingKey(macroName)
        if existingKeybind and existingKeybind ~= keyCombo then
            SetBinding(existingKeybind, nil)
        end

        local ok = SetBinding(keyCombo, macroName)
        if ok then
            SaveBindings(GetCurrentBindingSet())
            return true
        else
            return false
        end
    end

    local listening = false

    local function GetModifiedKeyString(key)
        local modifier = ""
        if IsControlKeyDown() then modifier = modifier .. "CTRL-" end
        if IsShiftKeyDown() then modifier = modifier .. "SHIFT-" end
        if IsAltKeyDown() then modifier = modifier .. "ALT-" end

        return modifier .. key
    end

    local clearKeybinding = function(self, _, macroName)
        SetBinding(GetBindingKey(macroName), nil)
        SaveBindings(GetCurrentBindingSet())
        self:SetText("Unbound")
        print("|cFF00FFFFSAPSaved:|r Keybinding cleared for " .. macroName)
    end

    local registerKeybinding = function(self, macroName, keybindName)
        if not listening then
            listening = true
        else
            return
        end

        local displayName = (macroName == "MACRO NS Ext Macro" and "External Macro") or (macroName == "MACRO NS PA Macro" and "Private Aura Macro") or (macroName == "MACRO NS Innervate" and "Innervate Macro") or "Macro"
        local keybindingFrame = DF:CreateSimplePanel(SAPUI, 300, 75, "Keybinding: " .. displayName, "KeybindingFrame", {
            DontRightClickClose = true
        })
        keybindingFrame:SetPoint("CENTER", SAPUI, "CENTER", 0, 0)
        keybindingFrame:SetFrameStrata("DIALOG")
        local keybindingFrame_text = keybindingFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        keybindingFrame_text:SetPoint("CENTER", keybindingFrame, "CENTER", 0, 0)
        keybindingFrame_text:SetText([[Press a key or click here
    (with optional modifiers) to bind the]].."\n"..displayName)


        local function OnKeyDown(_self, key)
            if listening then
                if key == "ESCAPE" then
                    listening = false
                    _self:SetScript("OnKeyDown", nil)
                    _self:SetPropagateKeyboardInput(false)
                    _self:Hide()
                    SAPUI:Show()
                    return
                end

                key = key:gsub("^LCTRL$", "CTRL")
                    :gsub("^RCTRL$", "CTRL")
                    :gsub("^LSHIFT$", "SHIFT")
                    :gsub("^RSHIFT$", "SHIFT")
                    :gsub("^LALT$", "ALT")
                    :gsub("^RALT$", "ALT")

                if key == "CTRL" or key == "SHIFT" or key == "ALT" then
                    return nil -- Don't register this as a full keybind yet
                end
                local keyCombo = GetModifiedKeyString(key)
                if keyCombo == "LeftButton" or keyCombo == "RightButton" then
                    return nil -- dont register pure mouse buttons as keybinds, only with modifier
                end

                -- Bind keybind
                bindKeybind(keyCombo, macroName)

                listening = false
                _self:SetScript("OnKeyDown", nil)
                _self:SetPropagateKeyboardInput(false)
                _self:Hide()
                SAPUI:Show()

                if general_tab:GetWidgetById(macroName) ~= nil then
                    general_tab:GetWidgetById(macroName):SetText(keyCombo)
                elseif externals_tab:GetWidgetById(macroName) ~= nil then
                    externals_tab:GetWidgetById(macroName):SetText(keyCombo)
                end
            end
        end

        keybindingFrame:SetScript("OnKeyDown", OnKeyDown)
        keybindingFrame:SetScript("OnMouseDown", OnKeyDown)
        keybindingFrame:SetScript("OnHide", function()
            listening = false
        end)
    end
    -- end of keybinding logic

    
    local weakauras_importaccept_options = {"Guild only", "Anyone", "None"}
    local build_weakauras_importaccept_options = function()
        local t = {}
        for i = 1, #weakauras_importaccept_options do
            tinsert(t, {
                label = weakauras_importaccept_options[i],
                value = i,
                onclick = function(_, _, value)
                    SAPSaved.Settings["WeakAurasImportAccept"] = value
                end

            })
        end
        return t
    end

    -- WeakAuras imports
    local function ImportWeakAura(name)
        if WA and WA.Import then
            WA.Import(SAP:GetWeakAura(name))
        else
            print("Error:WeakAuras not found")
        end
    end

    local function SendWeakAuras()
        local popup = DF:CreateSimplePanel(SAPUI, 300, 150, "Send WeakAura", "SAPUISendWeakAurasPopup", {
            DontRightClickClose = true
        })
        popup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        popup:SetFrameLevel(100)

        popup.test_string_text_box = DF:NewSpecialLuaEditorEntry(popup, 280, 80, _, "SendWATextEdit", true, false, true)
        popup.test_string_text_box:SetPoint("TOPLEFT", popup, "TOPLEFT", 10, -30)
        popup.test_string_text_box:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -30, 40)
        DF:ApplyStandardBackdrop(popup.test_string_text_box)
        DF:ReskinSlider(popup.test_string_text_box.scroll)
        popup.test_string_text_box:SetFocus()

        popup.import_confirm_button = DF:CreateButton(popup, function()
            local import_string = popup.test_string_text_box:GetText()
            SAP:SendWAString(import_string)
            popup.test_string_text_box:SetText("")
            popup:Hide()
        end, 280, 20, "Send")
        popup.import_confirm_button:SetPoint("BOTTOM", popup, "BOTTOM", 0, 10)
        popup.import_confirm_button:SetTemplate(options_button_template)

        return popup
    end

    -- when any setting is changed, call these respective callback function
    local general_callback = function()

        if SAPUI.OptionsChanged.general["PA_MACRO"] then
            PASelfPingChanged()
        end        
        if SAPUI.OptionsChanged.general["DEBUGLOGS"] then
            if SAPSaved.Settings["DebugLogs"] then -- Add this data if enables this after a wipe as the data exists anyway
                SAP:Print("Macro Data", SAP.MacroPresses)
                SAP:Print("Assigned Externals", SAP.AssignedExternals)
                SAP.AssignedExternals = {}
                SAP.MacroPresses = {}
            end
        end
        wipe(SAPUI.OptionsChanged["general"])
    end

    -- options
    local general_options1_table = {
        { type = "label", get = function() return "General Options" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE") },
        {
            type = "toggle",
            boxfirst = true,
            name = "Disable Minimap Button",
            desc = "Hide the minimap button if up to date",
            get = function() return SAPSaved.Settings["Minimap"].hide end,
            set = function(self, fixedparam, value)
                SAPSaved.Settings["Minimap"].hide = value
                SAP:UpdateMinimapIconVisibility()
            end,
        },

        {
            type = "toggle",
            boxfirst = true,
            name = "Enable Debug Logging",
            desc = "Enables Debug Logging, which prints a bunch of information and adds it to DevTool. This might Error if you do not have the DevTool Addon installed.\nIf enabled after a wipe, it will still add External and Macro data to DevTool",
            get = function() return SAPSaved.Settings["DebugLogs"] end,
            set = function(self, fixedparam, value)
                SAPUI.OptionsChanged.general["DEBUGLOGS"] = true
                SAPSaved.Settings["DebugLogs"] = value
            end,
        },

        {
            type = "blank",
        },

        {
            type = "label",
            get = function() return "MRT Options" end,
            text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"),
        },
        {
            type = "toggle",
            boxfirst = true,
            name = "Enable MRT Note Comparison",
            desc = "Enables MRT note comparison on ready check.",
            get = function() return SAPSaved.Settings["MRTNoteComparison"] end,
            set = function(self, fixedparam, value)
                SAPUI.OptionsChanged.general["MRT_NOTE_COMPARISON"] = true
                SAPSaved.Settings["MRTNoteComparison"] = value
            end,
            nocombat = true
        },  

        {
            type = "breakline"
        },   
        { type = "label", get = function() return "TTS Options" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE") },
        {
            type = "range",
            name = "TTS Voice",
            desc = "Voice to use for TTS",
            get = function() return SAPSaved.Settings["TTSVoice"] end,
            set = function(self, fixedparam, value) 
                SAPUI.OptionsChanged.general["TTS_VOICE"] = true
                SAPSaved.Settings["TTSVoice"] = value
            end,
            min = 1,
            max = 5,
        },
        {
            type = "range",
            name = "TTS Volume",
            desc = "Volume of the TTS",
            get = function() return SAPSaved.Settings["TTSVolume"] end,
            set = function(self, fixedparam, value)
                SAPSaved.Settings["TTSVolume"] = value
            end,
            min = 0,
            max = 100,
        },
        {
            type = "textentry",
            name = "TTS Preview",
            desc = [[Enter any text to preview TTS
            Press 'Enter' to hear the TTS]],
            get = function() return tts_text_preview end,
            set = function(self, fixedparam, value)
                tts_text_preview = value
            end,
            hooks = {
                OnEnterPressed = function(self)
                    SAP_API:TTS(tts_text_preview, SAPSaved.Settings["TTSVoice"])
                end
            }
        },
        {
            type = "toggle",
            boxfirst = true,
            name = "Enable TTS",
            desc = "Enable TTS",
            get = function() return SAPSaved.Settings["TTS"] end,
            set = function(self, fixedparam, value)
                SAPUI.OptionsChanged.general["TTS_ENABLED"] = true
                SAPSaved.Settings["TTS"] = value
            end,
        },        
        {
            type = "breakline"
        },   
        {
            type = "label",
            get = function() return "Private Aura Macro" end,
            text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"),
        },

        {
            type = "label",
            get = function() return "Private Aura Keybind:" end,
        },
        {
            type = "button",
            name = getMacroKeybind("MACRO SAP PA Macro"),
            desc = "Set the keybind for the private aura macro",
            param1 = "MACRO SAP PA Macro",
            param2 = "Private Aura Keybind",
            func = function(self, _, param1, param2)
                registerKeybinding(self, param1, param2)
            end,
            id = "MACRO SAP PA Macro",
        },   
    }

    local weakaura_options1_table = {
        
        {
            type = "label",
            get = function() return "Permanent Auras" end,
            text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"),
        },

        {
            type = "button",
            name = "Anchor Auras",
            desc = "Import WeakAura Anchors required for all SAP WeakAuras",
            func = function(self)
                ImportWeakAura("anchor_weakaura")
            end,
            nocombat = true,
            spacement = true
        },

        {
            type = "button",
            name = "Interrupt WA",
            desc = "Import Interrupt Anchor WeakAura",
            func = function(self)
                ImportWeakAura("interrupt_weakaura")
            end,
            nocombat = true,
            spacement = true
        },

        {
            type = "breakline"
        },

        {
            type = "label",
            get = function() return "Raid Auras" end,
            text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"),
        },

        {
            type = "button",
            name = "Liberation Raid WA",
            desc = "Import Liberation of Undermine Raid WeakAuras",
            func = function(_)
                ImportWeakAura("raid_weakaura")
            end,
            nocombat = true,
        },

        {
            type = "breakline"
        },

        {
            type = "label",
            get = function() return "WeakAuras Sharing" end,
            text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"),
        },

        {
            type = "button",
            name = "Send WeakAura to Raid",
            desc = "Send an individual WeakAura string to the raid.",
            func = function(_)
                SendWeakAuras()
            end,
            nocombat = true,
            spacement = true
        },

        {
            type = "select",
            get = function() return SAPSaved.Settings["WeakAurasImportAccept"] end,
            values = function() return build_weakauras_importaccept_options() end,
            name = "Import Accept",
            desc = "Choose who you are accepting WeakAuras imports to come from. Note that even if guild is selected here this still only works when in the same raid as them",
            nocombat = true
        },
    }

    -- Build options menu for each tab
    DF:BuildMenu(general_tab, general_options1_table, 10, -100, window_height - 10, false, options_text_template,
        options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template,
        general_callback)
    DF:BuildMenu(weakaura_tab, weakaura_options1_table, 10, -100, window_height - 10, false, options_text_template,
        options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template,
        weakaura_callback)

    -- Set right click functions for clearing keybinding on keybind buttons
    local PAMacroButton = general_tab:GetWidgetById("MACRO NS PA Macro")

    if PAMacroButton then
        PAMacroButton:SetClickFunction(clearKeybinding, PAMacroButton.param1, PAMacroButton.param2, "RightButton")
    end
    if ExternalMacroButton then
        ExternalMacroButton:SetClickFunction(clearKeybinding, ExternalMacroButton.param1, ExternalMacroButton.param2, "RightButton")
    end
    if InnervateMacroButton then
        InnervateMacroButton:SetClickFunction(clearKeybinding, InnervateMacroButton.param1, InnervateMacroButton.param2, "RightButton")
    end

    -- Build version check UI
    SAPUI.version_scrollbox = BuildVersionCheckUI(versions_tab)

    -- Version Number in status bar
    local versionTitle = C_AddOns.GetAddOnMetadata("SAP_Raid", "Title")
    local verisonNumber = C_AddOns.GetAddOnMetadata("SAP_Raid", "Version")
    local statusBarText = versionTitle .. " v" .. verisonNumber
    SAPUI.StatusBar.authorName:SetText(statusBarText)
end

function SAPUI:ToggleOptions()
    if SAPUI:IsShown() then
        SAPUI:Hide()
    else
        SAPUI:Show()
    end
end

function SAP:WAImportPopup(unit, str)
    local popup = DF:CreateSimplePanel(UIParent, 300, 120, "WA Import", "WAImportPopup", {
        DontRightClickClose = true
    })
    popup:SetPoint("CENTER", UIParent, "CENTER", 0, 150)

    local label = DF:CreateLabel(popup, SAP_API:Shorten(unit) .. " is attempting to send you a WeakAura.", 11)

    label:SetPoint("TOPLEFT", popup, "TOPLEFT", 10, -30)
    label:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -10, 40)
    label:SetJustifyH("CENTER")

    local cancel_button = DF:CreateButton(popup, function() popup:Hide() end, 130, 20, "Cancel")
    cancel_button:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 10, 10)
    cancel_button:SetTemplate(options_button_template)

    local accept_button = DF:CreateButton(popup, function() 
        WA.Import(str)
        popup:Hide() 
    end, 130, 20, "Accept")
    accept_button:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -10, 10)
    accept_button:SetTemplate(options_button_template)

    return popup
end

function SAP_API:DisplayText(text, duration)
    if SAPUI and SAPUI.generic_display then
        SAPUI.generic_display.text:SetText(text)
        SAPUI.generic_display:Show()
        C_Timer.After(duration or 4, function() SAPUI.generic_display:Hide() end)
    end
end

SAP.SAPUI = SAPUI