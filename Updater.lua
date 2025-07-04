local _, SAP = ...

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript(
        "OnEvent",
        function(_, event, ...)
            if event == "ADDON_LOADED" then
                local addOnName = ...

                if addOnName == "SAP_Raid" then
                    if not SAPUpdaterSaved then SAPUpdaterSaved = {} end
                    if not SAPUpdaterSaved.minimap then SAPUpdaterSaved.minimap = {} end
                    
                    if not InCombatLockdown() then
                        SetCVar("Sound_NumChannels", 128)
                    end

                    -- Minimap icon
                    SAP.LDB = LDB:NewDataObject(
                            "SAP Updater",
                            {
                                type = "data source",
                                text = "SAP Updater",
                                icon = [[Interface\Addons\SAP_Raid\Media\Images\S.tga]],
                                OnClick = function() SAP.window:SetShown(not SAP.window:IsShown()) end
                            }
                    )

                    LDBIcon:Register("SAP Updater", SAP.LDB, SAPUpdaterSaved.minimap)

                    SAP:UpdateMinimapIconVisibility()
                    --
                    --SAP.LiquidUI:Initialize(SAPUpdaterSaved)
                    --
                    --SAP:InitializeNicknames()
                    --SAP:InitializeBigWigsDisabler()
                    --SAP:InitializeWeakAurasImporter()
                    --SAP:InitializeInterface()
                    --SAP:InitializeSAP_Raid()
                    --SAP:InitializeAuraChecker()
                    --SAP:InitializeOtherChecker()
                end
            end
        end
)