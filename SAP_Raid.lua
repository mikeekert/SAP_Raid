local _, SAP = ... -- Internal namespace
SAP.specs = {}

local eventFrame = CreateFrame("Frame")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript(
        "OnEvent",
        function(_, event, ...)
            if event == "ADDON_LOADED" then
                local addOnName = ...

                if addOnName == "SAP_Raid" then
                    if LDB then
                        SAP.LDB = LDB:NewDataObject(
                                "SAP Raid",
                                {
                                    type = "data source",
                                    text = "SAP Raid",
                                    icon = [[Interface\Addons\SAP_Raid\Media\Images\S.tga]],
                                    OnClick = function()
                                        SAP.SAPUI:ToggleOptions()
                                    end,
                                    OnTooltipShow = function(tooltip)
                                        tooltip:AddLine("SAP Raid Tools", 0, 1, 1)
                                        tooltip:AddLine("|cFFCFCFCFLeft click|r: Show/Hide Options Window")
                                    end
                                }
                        )

                        LDBIcon:Register("SAP Raid", SAP.LDB, SAPSaved.Settings["Minimap"])
                    end

                    SAP:InitializeWeakAurasImporter()
                    SAP:InitializeSAP_Updater()
                end
            end
        end
)