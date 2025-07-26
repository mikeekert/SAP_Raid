local _, LUP = ...

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript(
    "OnEvent",
    function(_, event, ...)
        if event == "ADDON_LOADED" then
            local addOnName = ...

            if addOnName == "SAP_Raid_Updater" then
                if not SAPUpdaterSaved then SAPUpdaterSaved = {} end
                if not SAPUpdaterSaved.minimap then SAPUpdaterSaved.minimap = {} end
                if not SAPUpdaterSaved.settings then SAPUpdaterSaved.settings = {} end
                if not SAPUpdaterSaved.settings.frames then SAPUpdaterSaved.settings.frames = {} end
                if not SAPUpdaterSaved.nicknames then SAPUpdaterSaved.nicknames = {} end
                if SAPUpdaterSaved.settings.readyCheckPopup == nil then SAPUpdaterSaved.settings.readyCheckPopup = true end
                if SAPUpdaterSaved.settings.disableBigWigsAssignments == nil then SAPUpdaterSaved.settings.disableBigWigsAssignments = true end

                if not InCombatLockdown() then
                    SetCVar("Sound_NumChannels", 128)
                end

                -- Minimap icon
                LUP.LDB = LDB:NewDataObject(
                    "SAP Updater",
                    {
                        type = "data source",
                        text = "SAP Updater",
                        icon = [[Interface\Addons\SAP_Raid_Updater\Media\Textures\minimap_logo.tga]],
                        OnClick = function() LUP.window:SetShown(not LUP.window:IsShown()) end
                    }
                )

                LDBIcon:Register("SAP Updater", LUP.LDB, SAPUpdaterSaved.minimap)

                LUP:UpdateMinimapIconVisibility()

                LUP.LiquidUI:Initialize(SAPUpdaterSaved)

                LUP:InitializeNicknames()
                LUP:InitializeBigWigsDisabler()
                LUP:InitializeWeakAurasImporter()
                LUP:InitializeInterface()
                LUP:InitializeAuraUpdater()
                LUP:InitializeAuraChecker()
                LUP:InitializeOtherChecker()

                -- Popup window in case LiquidUpdater (old version of AuraUpdater) is loaded
                if C_AddOns.IsAddOnLoaded("LiquidUpdater") then
                    local liquidUpdaterPopup = LUP:CreatePopupWindowWithButton()

                    liquidUpdaterPopup:SetHideOnClickOutside(false)
                    liquidUpdaterPopup:SetText("LiquidUpdater is active, and interferes with AuraUpdater.|n|nPlease disable it.")
                    liquidUpdaterPopup:SetButtonText(string.format("|cff%sDisable and reload|r", LUP.gs.visual.colorStrings.green))
                    liquidUpdaterPopup:SetButtonOnClick(
                        function()
                            C_AddOns.DisableAddOn("LiquidUpdater")

                            C_UI.Reload()
                        end
                    )

                
                    liquidUpdaterPopup:Pop()
                    liquidUpdaterPopup:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
                end
            end
        end
    end
)

SLASH_AURAUPDATER1 = "/lu"
SLASH_AURAUPDATER2 = "/auraupdate"
SLASH_AURAUPDATER3 = "/auraupdater"
SLASH_AURAUPDATER4 = "/au"

function SlashCmdList.AURAUPDATER()
    LUP.window:SetShown(not LUP.window:IsShown())
end