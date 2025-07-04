local _, SAP = ... -- Internal namespace
_G["SAP_API"] = {}
SAP.specs = {}

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0")

function SAP:InitLDB()
    if LDB then
        local databroker = LDB:NewDataObject("SAPSaved", {
            type = "launcher",
            label = "SAP Raid Tools",
            icon = [[Interface\AddOns\SAP_Raid\Media\Logo]],
            showInCompartment = true,
            OnClick = function(self, button)
                if button == "LeftButton" then
                    SAP.SAPUI:ToggleOptions()
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine("SAP Raid Tools", 0, 1, 1)
                tooltip:AddLine("|cFFCFCFCFLeft click|r: Show/Hide Options Window")
            end
        })

        if (databroker and not LDBIcon:IsRegistered("SAPSaved")) then
            LDBIcon:Register("SAPSaved", databroker, SAPSaved.Settings["Minimap"])
            LDBIcon:AddButtonToCompartment("SAPSaved")
        end

        SAP.databroker = databroker
    end
end
