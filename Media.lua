local _, SAP = ... -- Internal namespace
local LSM = LibStub("LibSharedMedia-3.0")
SAPMedia = {}
--Sounds
LSM:Register("sound","|cFF4BAAC8Macro|r", [[Interface\Addons\SAP_Raid\Media\Sounds\macro.mp3]])
LSM:Register("sound","|cFF4BAAC801|r", [[Interface\Addons\SAP_Raid\Media\Sounds\1.ogg]])
LSM:Register("sound","|cFF4BAAC802|r", [[Interface\Addons\SAP_Raid\Media\Sounds\2.ogg]])
LSM:Register("sound","|cFF4BAAC803|r", [[Interface\Addons\SAP_Raid\Media\Sounds\3.ogg]])
LSM:Register("sound","|cFF4BAAC804|r", [[Interface\Addons\SAP_Raid\Media\Sounds\4.ogg]])
LSM:Register("sound","|cFF4BAAC805|r", [[Interface\Addons\SAP_Raid\Media\Sounds\5.ogg]])
LSM:Register("sound","|cFF4BAAC806|r", [[Interface\Addons\SAP_Raid\Media\Sounds\6.ogg]])
LSM:Register("sound","|cFF4BAAC807|r", [[Interface\Addons\SAP_Raid\Media\Sounds\7.ogg]])
LSM:Register("sound","|cFF4BAAC808|r", [[Interface\Addons\SAP_Raid\Media\Sounds\8.ogg]])
LSM:Register("sound","|cFF4BAAC809|r", [[Interface\Addons\SAP_Raid\Media\Sounds\9.ogg]])
LSM:Register("sound","|cFF4BAAC810|r", [[Interface\Addons\NorthernSkyMRaidTools\Media\Sounds\10.ogg]])
LSM:Register("sound","|cFF4BAAC8Dispel|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Dispel.ogg]])
LSM:Register("sound","|cFF4BAAC8Yellow|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Yellow.ogg]])
LSM:Register("sound","|cFF4BAAC8Orange|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Orange.ogg]])
LSM:Register("sound","|cFF4BAAC8Purple|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Purple.ogg]])
LSM:Register("sound","|cFF4BAAC8Green|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Green.ogg]])
LSM:Register("sound","|cFF4BAAC8Moon|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Moon.ogg]])
LSM:Register("sound","|cFF4BAAC8Blue|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Blue.ogg]])
LSM:Register("sound","|cFF4BAAC8Red|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Red.ogg]])
LSM:Register("sound","|cFF4BAAC8Skull|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Skull.ogg]])
LSM:Register("sound","|cFF4BAAC8Gate|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Gate.ogg]])
LSM:Register("sound","|cFF4BAAC8Soak|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Soak.ogg]])
LSM:Register("sound","|cFF4BAAC8Fixate|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Fixate.ogg]])
LSM:Register("sound","|cFF4BAAC8Next|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Next.ogg]])
LSM:Register("sound","|cFF4BAAC8Interrupt|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Interrupt.ogg]])
LSM:Register("sound","|cFF4BAAC8Spread|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Spread.ogg]])
LSM:Register("sound","|cFF4BAAC8Break|r", [[Interface\Addons\SAP_Raid\Media\Sounds\Break.ogg]])
--Fonts
LSM:Register("font","Expressway", [[Interface\Addons\SAP_Raid\Media\Fonts\Expressway.TTF]])
--StatusBars
LSM:Register("statusbar","Atrocity", [[Interface\Addons\SAP_Raid\Media\StatusBars\Atrocity]])
-- Open WA Options
function SAPMedia.OpenWA()
    WeakAuras.OpenOptions()
end

-- Memes for Break-Timer
SAPMedia.BreakMemes = {
    {[[Interface\AddOns\SAP_Raid\Media\Memes\ZarugarPeace.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\ZarugarChad.blp]], 256, 147},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\Overtime.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\TherzBayern.blp]], 256, 24},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\senfisaur.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\schinky.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\TizaxHose.blp]], 202, 256},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\ponkyBanane.blp]], 256, 174},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\ponkyDespair.blp]], 256, 166},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\docPog.blp]], 195, 211},
}

-- Memes for WA updating
SAPMedia.UpdateMemes = {
    {[[Interface\AddOns\SAP_Raid\Media\Memes\ZarugarPeace.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\ZarugarChad.blp]], 256, 147},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\TherzBayern.blp]], 256, 24},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\senfisaur.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\schinky.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\TizaxHose.blp]], 202, 256},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\ponkyBanane.blp]], 256, 174},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\ponkyDespair.blp]], 256, 166},
    {[[Interface\AddOns\SAP_Raid\Media\Memes\docPog.blp]], 195, 211},
}

SAPMedia.EncounterPics = {
    {[[Interface\AddOns\SAP_Raid\Media\EncounterPics\Spider.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\EncounterPics\Worm.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\EncounterPics\Parasite.blp]], 256, 256},
    {[[Interface\AddOns\SAP_Raid\Media\EncounterPics\OvinaxBG.blp]], 256, 256},
}