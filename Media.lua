local _, SAP = ... -- Internal namespace
local LSM = LibStub("LibSharedMedia-3.0")
SAPMedia = {}
--Fonts
LSM:Register("font","Expressway", [[Interface\Addons\SAP_Raid\Media\Fonts\Expressway.TTF]])

-- Open WA Options
function SAPMedia.OpenWA()
    WeakAuras.OpenOptions()
end