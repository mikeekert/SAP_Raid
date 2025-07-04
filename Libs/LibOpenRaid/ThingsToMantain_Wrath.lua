
--data for wrath of the lich king expansion

local versionString, revision, launchDate, gameVersion = GetBuildInfo()
if (gameVersion >= 40000 or gameVersion < 30000) then
    return
end

--localization
local gameLanguage = GetLocale()

local L = { --default localization
	["STRING_EXPLOSION"] = "explosion",
	["STRING_MIRROR_IMAGE"] = "Mirror Image",
	["STRING_CRITICAL_ONLY"]  = "critical",
	["STRING_BLOOM"] = "Bloom", --lifebloom 'bloom' healing
	["STRING_GLAIVE"] = "Glaive", --DH glaive toss
	["STRING_MAINTARGET"] = "Main Target",
	["STRING_AOE"] = "AoE", --multi targets
	["STRING_SHADOW"] = "Shadow", --the spell school 'shadow'
	["STRING_PHYSICAL"] = "Physical", --the spell school 'physical'
	["STRING_PASSIVE"] = "Passive", --passive spell
	["STRING_TEMPLAR_VINDCATION"] = "Templar's Vindication", --paladin spell
	["STRING_PROC"] = "proc", --spell proc
	["STRING_TRINKET"] = "Trinket", --trinket
}

if (gameLanguage == "enUS") then
	--default language

elseif (gameLanguage == "deDE") then
	L["STRING_EXPLOSION"] = "Explosion"
	L["STRING_MIRROR_IMAGE"] = "Bilder spiegeln"
	L["STRING_CRITICAL_ONLY"]  = "kritisch"

elseif (gameLanguage == "esES") then
	L["STRING_EXPLOSION"] = "explosión"
	L["STRING_MIRROR_IMAGE"] = "Imagen de espejo"
	L["STRING_CRITICAL_ONLY"]  = "crítico"

elseif (gameLanguage == "esMX") then
	L["STRING_EXPLOSION"] = "explosión"
	L["STRING_MIRROR_IMAGE"] = "Imagen de espejo"
	L["STRING_CRITICAL_ONLY"]  = "crítico"

elseif (gameLanguage == "frFR") then
	L["STRING_EXPLOSION"] = "explosion"
	L["STRING_MIRROR_IMAGE"] = "Effet miroir"
	L["STRING_CRITICAL_ONLY"]  = "critique"

elseif (gameLanguage == "itIT") then
	L["STRING_EXPLOSION"] = "esplosione"
	L["STRING_MIRROR_IMAGE"] = "Immagine Speculare"
	L["STRING_CRITICAL_ONLY"]  = "critico"

elseif (gameLanguage == "koKR") then
	L["STRING_EXPLOSION"] = "폭발"
	L["STRING_MIRROR_IMAGE"] = "미러 이미지"
	L["STRING_CRITICAL_ONLY"]  = "치명타"

elseif (gameLanguage == "ptBR") then
	L["STRING_EXPLOSION"] = "explosão"
	L["STRING_MIRROR_IMAGE"] = "Imagem Espelhada"
	L["STRING_CRITICAL_ONLY"]  = "critico"

elseif (gameLanguage == "ruRU") then
	L["STRING_EXPLOSION"] = "взрыв"
	L["STRING_MIRROR_IMAGE"] = "Зеркальное изображение"
	L["STRING_CRITICAL_ONLY"]  = "критический"

elseif (gameLanguage == "zhCN") then
	L["STRING_EXPLOSION"] = "爆炸"
	L["STRING_MIRROR_IMAGE"] = "镜像"
	L["STRING_CRITICAL_ONLY"]  = "爆击"

elseif (gameLanguage == "zhTW") then
	L["STRING_EXPLOSION"] = "爆炸"
	L["STRING_MIRROR_IMAGE"] = "鏡像"
	L["STRING_CRITICAL_ONLY"]  = "致命"
end

LIB_OPEN_RAID_MANA_POTIONS = {}

LIB_OPEN_RAID_FOOD_BUFF = {} --default
LIB_OPEN_RAID_FLASK_BUFF = {} --default

LIB_OPEN_RAID_BLOODLUST = {
	[2825] = true, --bloodlust
	[32182] = true, --heroism
	[80353] = true, --timewarp
	[90355] = true, --ancient hysteria
	[309658] = true, --current exp drums
}

--which gear slots can be enchanted on the latest retail version of the game
--when the value is a number, the slot only receives enchants for a specific attribute
LIB_OPEN_RAID_ENCHANT_SLOTS = {
	--[INVSLOT_NECK] = true,
	[INVSLOT_BACK] = true, --for all
	[INVSLOT_CHEST] = true, --for all
	[INVSLOT_FINGER1] = true, --for all
	[INVSLOT_FINGER2] = true, --for all
	[INVSLOT_MAINHAND] = true, --for all

	[INVSLOT_FEET] = 2, --agility only
	[INVSLOT_WRIST] = 1, --intellect only
	[INVSLOT_HAND] = 3, --strenth only
}

LIB_OPEN_RAID_MYTHICKEYSTONE_ITEMID = 180653
LIB_OPEN_RAID_AUGMENTATED_RUNE = 0

LIB_OPEN_RAID_COVENANT_ICONS = {}

LIB_OPEN_RAID_ENCHANT_IDS = {}

LIB_OPEN_RAID_GEM_IDS = {}

LIB_OPEN_RAID_WEAPON_ENCHANT_IDS = {}

LIB_OPEN_RAID_FOOD_BUFF = {}

LIB_OPEN_RAID_FLASK_BUFF = {}

LIB_OPEN_RAID_ALL_POTIONS = {}

LIB_OPEN_RAID_HEALING_POTIONS = {
	[33447] = true, --Runic Healing Potion
	[41166] = true, --Runic Healing Injector
	[47875] = true, --Warlock's Healthstone (0/2 Talent)
	[47867] = true, --Warlock's Healthstone (1/2 Talent)
	[47877] = true, --Warlock's Healthstone (2/2 Talent)
}

LIB_OPEN_RAID_MELEE_SPECS = {
	[251] = "DEATHKNIGHT",
	[252] = "DEATHKNIGHT",
	[577] = "DEMONHUNTER",
	[103] = "DRUID",
	--[255] = "Survival", --not in the list due to the long interrupt time
	[269] = "MONK",
	[70] = "PALADIN",
	[259] = "ROGUE",
	[260] = "ROGUE",
	[261] = "ROGUE",
	[263] = "SHAMAN",
	[71] = "WARRIOR",
	[72] = "WARRIOR",
}

--tells the duration, requirements and cooldown
--information about a cooldown is mainly get from tooltips
--if talent is required, use the command:
--/dump GetTalentInfo (talentTier, talentColumn, 1)
--example: to get the second talent of the last talent line, use: /dump GetTalentInfo (7, 2, 1)

LIB_OPEN_RAID_COOLDOWSAP_INFO = {

	-- Filter Types:
	-- 1 attack cooldown
	-- 2 personal defensive cooldown
	-- 3 targetted defensive cooldown
	-- 4 raid defensive cooldown
	-- 5 personal utility cooldown
	-- 6 interrupt

	--interrupts
	[6552] = {class = "WARRIOR", specs = {71, 72, 73}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Pummel
	[2139] = {class = "MAGE", specs = {62, 63, 64}, cooldown = 24, silence = 6, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Counterspell
	[15487] = {class = "PRIEST", specs = {258}, cooldown = 45, silence = 4, talent = false, cooldownWithTalent = 30, cooldownTalentId = 23137, type = 6, charges = 1}, --Silence (shadow) Last Word Talent to reduce cooldown in 15 seconds
	[1766] = {class = "ROGUE", specs = {259, 260, 261}, cooldown = 15, silence = 5, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Kick
	[96231] = {class = "PALADIN", specs = {66, 70}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Rebuke (protection and retribution)
	[116705] = {class = "MONK", specs = {268, 269}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Spear Hand Strike (brewmaster and windwalker)
	[57994] = {class = "SHAMAN", specs = {262, 263, 264}, cooldown = 12, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Wind Shear
	[47528] = {class = "DEATHKNIGHT", specs = {250, 251, 252}, cooldown = 15, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Mind Freeze
	[106839] = {class = "DRUID", specs = {103, 104}, cooldown = 15, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Skull Bash (feral, guardian)
	[78675] = {class = "DRUID", specs = {102}, cooldown = 60, silence = 8, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Solar Beam (balance)
	[147362] = {class = "HUNTER", specs = {253, 254}, cooldown = 24, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Counter Shot (beast mastery, marksmanship)
	[187707] = {class = "HUNTER", specs = {255}, cooldown = 15, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Muzzle (survival)
	[183752] = {class = "DEMONHUNTER", specs = {577, 581}, cooldown = 15, silence = 3, talent = false, cooldownWithTalent = false, cooldownTalentId = false, type = 6, charges = 1}, --Disrupt
	[19647] = {class = "WARLOCK", specs = {265, 266, 267}, cooldown = 24, silence = 6, talent = false, cooldownWithTalent = false, cooldownTalentId = false, pet = 417, type = 6, charges = 1}, --Spell Lock (pet felhunter ability)
	[89766] = {class = "WARLOCK", specs = {266}, cooldown = 30, silence = 4, talent = false, cooldownWithTalent = false, cooldownTalentId = false, pet = 17252, type = 6, charges = 1}, --Axe Toss (pet felguard ability)

	--paladin
	-- 65 - Holy
	-- 66 - Protection
	-- 70 - Retribution

	[31884] = 	{cooldown = 120, 	duration = 20, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 1}, --Avenging Wrath
	[216331] = 	{cooldown = 120, 	duration = 20, 		specs = {65}, 			talent =22190, charges = 1, class = "PALADIN", type = 1}, --Avenging Crusader (talent)
	[498] = 	{cooldown = 60, 	duration = 8, 		specs = {65}, 			talent =false, charges = 1, class = "PALADIN", type = 2}, --Divine Protection
	[642] = 	{cooldown = 300, 	duration = 8, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 2}, --Divine Shield
	[105809] = 	{cooldown = 90, 	duration = 20, 		specs = {65,66,70}, 	talent =22164, charges = 1, class = "PALADIN", type = 2}, --Holy Avenger (talent)
	[152262] = 	{cooldown = 45, 	duration = 15, 		specs = {65,66,70},		talent =17601, charges = 1, class = "PALADIN", type = 2}, --Seraphim
	[633] = 	{cooldown = 600, 	duration = false, 	specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 3}, --Lay on Hands
	[1022] = 	{cooldown = 300, 	duration = 10, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 3}, --Blessing of Protection
	[6940] = 	{cooldown = 120, 	duration = 12, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 3}, --Blessing of Sacrifice
	[31821] = 	{cooldown = 180, 	duration = 8, 		specs = {65},		 	talent =false, charges = 1, class = "PALADIN", type = 4}, --Aura Mastery
	[1044] = 	{cooldown = 25, 	duration = 8, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 5}, --Blessing of Freedom
	[853] = 	{cooldown = 60, 	duration = 6, 		specs = {65,66,70}, 	talent =false, charges = 1, class = "PALADIN", type = 5}, --Hammer of Justice
	[115750] = 	{cooldown = 90, 	duration = 6, 		specs = {65,66,70}, 	talent =21811, charges = 1, class = "PALADIN", type = 5}, --Blinding Light(talent)
	[327193] = 	{cooldown = 90, 	duration = 15, 		specs = {66}, 			talent =23468, charges = 1, class = "PALADIN", type = 1}, --Moment of Glory (talent)
	[31850] = 	{cooldown = 120, 	duration = 8, 		specs = {66}, 			talent =false, charges = 1, class = "PALADIN", type = 2}, --Ardent Defender
	[86659] = 	{cooldown = 300, 	duration = 8, 		specs = {66}, 			talent =false, charges = 1, class = "PALADIN", type = 2}, --Guardian of Ancient Kings
	[204018] = 	{cooldown = 180, 	duration = 10, 		specs = {66}, 			talent =22435, charges = 1, class = "PALADIN", type = 3}, --Blessing of Spellwarding (talent)
	[231895] = 	{cooldown = 120, 	duration = 25, 		specs = {70}, 			talent =22215, charges = 1, class = "PALADIN", type = 1}, --Crusade (talent)
	[205191] = 	{cooldown = 60, 	duration = 10, 		specs = {70}, 			talent =22183, charges = 1, class = "PALADIN", type = 2}, --Eye for an Eye (talent)
	[184662] = 	{cooldown = 120, 	duration = 15, 		specs = {70}, 			talent =false, charges = 1, class = "PALADIN", type = 2}, --Shield of Vengeance

	--warrior
	-- 71 - Arms
	-- 72 - Fury
	-- 73 - Protection

	[107574] = 	{cooldown = 90, 	duration = 20, 		specs = {71,73}, 		talent =22397, charges = 1, class = "WARRIOR", type = 1}, --Avatar
	[227847] = 	{cooldown = 90, 	duration = 5, 		specs = {71},	 		talent =false, charges = 1, class = "WARRIOR", type = 1}, --Bladestorm
	[46924] = 	{cooldown = 60, 	duration = 4, 		specs = {72},		 	talent =22400, charges = 1, class = "WARRIOR", type = 1}, --Bladestorm (talent)
	[152277] = 	{cooldown = 60, 	duration = 6, 		specs = {71},			talent =21667, charges = 1, class = "WARRIOR", type = 1}, --Ravager (talent)
	[228920] = 	{cooldown = 60, 	duration = 6, 		specs = {73}, 			talent =23099, charges = 1, class = "WARRIOR", type = 1}, --Ravager (talent)
	[118038] = 	{cooldown = 180, 	duration = 8, 		specs = {71},		 	talent =false, charges = 1, class = "WARRIOR", type = 2}, --Die by the Sword
	[97462] = 	{cooldown = 180, 	duration = 10, 		specs = {71,72,73}, 	talent =false, charges = 1, class = "WARRIOR", type = 4}, --Rallying Cry
	[1719] = 	{cooldown = 90, 	duration = 10, 		specs = {72},		 	talent =false, charges = 1, class = "WARRIOR", type = 1}, --Recklessness
	[184364] = 	{cooldown = 120, 	duration = 8, 		specs = {72},		 	talent =false, charges = 1, class = "WARRIOR", type = 2}, --Enraged Regeneration
	[12975] = 	{cooldown = 180, 	duration = 15, 		specs = {73}, 			talent =false, charges = 1, class = "WARRIOR", type = 2}, --Last Stand
	[871] = 	{cooldown = 8, 		duration = 240, 	specs = {73}, 			talent =false, charges = 1, class = "WARRIOR", type = 2}, --Shield Wall
	[64382]  = 	{cooldown = 180, 	duration = false, 	specs = {71,72,73}, 	talent =false, charges = 1, class = "WARRIOR", type = 5}, --Shattering Throw
	[5246]  = 	{cooldown = 90, 	duration = 8, 		specs = {71,72,73}, 	talent =false, charges = 1, class = "WARRIOR", type = 5}, --Intimidating Shout

	--warlock
	-- 265 - Affliction
	-- 266 - Demonology
	-- 267 - Destruction

	[205180] = 	{cooldown = 180, 	duration = 20, 		specs = {265}, 			talent =false, charges = 1, class = "WARLOCK", type = 1}, --Summon Darkglare
	--[342601] = {cooldown = 3600, 	duration = false, 	specs = {}, 	talent =false, charges = 1, class = "WARLOCK", type = 1}, --Ritual of Doom
	[113860] = 	{cooldown = 120, 	duration = 20, 		specs = {265}, 			talent =19293, charges = 1, class = "WARLOCK", type = 1}, --Dark Soul: Misery (talent)
	[104773] = 	{cooldown = 180, 	duration = 8, 		specs = {265,266,267}, 	talent =false, charges = 1, class = "WARLOCK", type = 2}, --Unending Resolve
	[108416] = 	{cooldown = 60, 	duration = 20, 		specs = {265,266,267}, 	talent =19286, charges = 1, class = "WARLOCK", type = 2}, --Dark Pact (talent)
	[265187] = 	{cooldown = 90, 	duration = 15, 		specs = {266}, 			talent =false, charges = 1, class = "WARLOCK", type = 1}, --Summon Demonic Tyrant
	[111898] = 	{cooldown = 120, 	duration = 15, 		specs = {266}, 			talent =21717, charges = 1, class = "WARLOCK", type = 1}, --Grimoire: Felguard (talent)
	[267171] = 	{cooldown = 60, 	duration = false, 	specs = {266}, 			talent =23138, charges = 1, class = "WARLOCK", type = 1}, --Demonic Strength (talent)
	[267217] = 	{cooldown = 180, 	duration = 20, 		specs = {266}, 			talent =23091, charges = 1, class = "WARLOCK", type = 1}, --Nether Portal
	[1122] = 	{cooldown = 180, 	duration = 30, 		specs = {267}, 			talent =false, charges = 1, class = "WARLOCK", type = 1}, --Summon Infernal
	[113858] = 	{cooldown = 120, 	duration = 20, 		specs = {267}, 			talent =23092, charges = 1, class = "WARLOCK", type = 1}, --Dark Soul: Instability (talent)
	[30283] = 	{cooldown = 60, 	duration = 3, 		specs = {265,266,267}, 	talent =false, charges = 1, class = "WARLOCK", type = 5}, --Shadowfury
	[333889] = 	{cooldown = 180, 	duration = 15, 		specs = {265,266,267}, 	talent =false, charges = 1, class = "WARLOCK", type = 5}, --Fel Domination
	[5484] = 	{cooldown = 40, 	duration = 20, 		specs = {265,266,267}, 	talent =23465, charges = 1, class = "WARLOCK", type = 5}, --Howl of Terror (talent)

	--shaman
	-- 262 - Elemental
	-- 263 - Enchancment
	-- 264 - Restoration

	[198067] = 	{cooldown = 150, 	duration = 30, 		specs = {262}, 			talent =false, charges = 1, class = "SHAMAN", type = 1}, --Fire Elemental
	[192249] = 	{cooldown = 150, 	duration = 30, 		specs = {262}, 			talent =19272, charges = 1, class = "SHAMAN", type = 1}, --Storm Elemental (talent)
	[108271] = 	{cooldown = 90, 	duration = 8, 		specs = {262,263,264}, 	talent =false, charges = 1, class = "SHAMAN", type = 2}, --Astral Shift
	[108281] = 	{cooldown = 120, 	duration = 10, 		specs = {262,263}, 		talent =22172, charges = 1, class = "SHAMAN", type = 4}, --Ancestral Guidance (talent)
	[51533] = 	{cooldown = 120, 	duration = 15, 		specs = {263}, 			talent =false, charges = 1, class = "SHAMAN", type = 1}, --Feral Spirit
	[114050] = 	{cooldown = 180, 	duration = 15, 		specs = {262}, 			talent =21675, charges = 1, class = "SHAMAN", type = 1}, --Ascendance (talent)
	[114051] = 	{cooldown = 180, 	duration = 15, 		specs = {263}, 			talent =21972, charges = 1, class = "SHAMAN", type = 1}, --Ascendance (talent)
	[114052] = 	{cooldown = 180, 	duration = 15, 		specs = {264}, 			talent =22359, charges = 1, class = "SHAMAN", type = 4}, --Ascendance (talent)
	[98008] = 	{cooldown = 180, 	duration = 6, 		specs = {264}, 			talent =false, charges = 1, class = "SHAMAN", type = 4}, --Spirit Link Totem
	[108280] = 	{cooldown = 180, 	duration = 10, 		specs = {264}, 			talent =false, charges = 1, class = "SHAMAN", type = 4}, --Healing Tide Totem
	[207399] = 	{cooldown = 240, 	duration = 30, 		specs = {264}, 			talent =22323, charges = 1, class = "SHAMAN", type = 4}, --Ancestral Protection Totem (talent)
	[16191] = 	{cooldown = 180, 	duration = 8, 		specs = {264}, 			talent =false, charges = 1, class = "SHAMAN", type = 4}, --Mana Tide Totem
	[198103] = 	{cooldown = 300, 	duration = 60, 		specs = {262,263,264}, 	talent =false, charges = 1, class = "SHAMAN", type = 2}, --Earth Elemental
	[192058] = 	{cooldown = 60, 	duration = false, 	specs = {262,263,264}, 	talent =false, charges = 1, class = "SHAMAN", type = 5}, --Capacitor Totem
	[8143] = 	{cooldown = 60, 	duration = 10, 		specs = {262,263,264}, 	talent =false, charges = 1, class = "SHAMAN", type = 5}, --Tremor Totem
	[192077] = 	{cooldown = 120, 	duration = 15, 		specs = {262,263,264}, 	talent =21966, charges = 1, class = "SHAMAN", type = 5}, --Wind Rush Totem (talent)
	
	--monk
	-- 268 - Brewmaster
	-- 269 - Windwalker
	-- 270 - Restoration

	[132578] = 	{cooldown = 180, 	duration = 25, 		specs = {268}, 			talent =false, charges = 1, class = "MONK", type = 1}, --Invoke Niuzao, the Black Ox
	[115080] = 	{cooldown = 180, 	duration = false, 	specs = {268,269,270}, 	talent =false, charges = 1, class = "MONK", type = 1}, --Touch of Death
	[115203] = 	{cooldown = 420, 	duration = 15, 		specs = {268}, 			talent =false, charges = 1, class = "MONK", type = 2}, --Fortifying Brew
	[115176] = 	{cooldown = 300, 	duration = 8, 		specs = {268}, 			talent =false, charges = 1, class = "MONK", type = 2}, --Zen Meditation
	[115399] = 	{cooldown = 120, 	duration = false, 	specs = {268}, 			talent =19992, charges = 1, class = "MONK", type = 2}, --Black Ox brew (talent)
	[122278] = 	{cooldown = 120, 	duration = 10, 		specs = {268,269,270}, 	talent =20175, charges = 1, class = "MONK", type = 2}, --Dampen Harm (talent)
	[137639] = 	{cooldown = 90, 	duration = 15, 		specs = {269}, 			talent =false, charges = 1, class = "MONK", type = 1}, --Storm, Earth, and Fire
	[123904] = 	{cooldown = 120, 	duration = 24, 		specs = {269}, 			talent =false, charges = 1, class = "MONK", type = 1}, --Invoke Xuen, the White Tiger
	[152173] = 	{cooldown = 90, 	duration = 12, 		specs = {269}, 			talent =21191, charges = 1, class = "MONK", type = 1}, --Serenity (talent)
	[122470] = 	{cooldown = 90, 	duration = 6, 		specs = {269}, 			talent =false, charges = 1, class = "MONK", type = 2}, --Touch of Karma
	[322118] = 	{cooldown = 180, 	duration = 25, 		specs = {270}, 			talent =false, charges = 1, class = "MONK", type = 4}, --Invoke Yulon, the Jade serpent
	[243435] = 	{cooldown = 90, 	duration = 15, 		specs = {269,270}, 		talent =false, charges = 1, class = "MONK", type = 2}, --Fortifying Brew
	[122783] = 	{cooldown = 90, 	duration = 6, 		specs = {269,270}, 		talent =20173, charges = 1, class = "MONK", type = 2}, --Diffuse Magic (talent)
	[116849] = 	{cooldown = 120, 	duration = 12, 		specs = {270}, 			talent =false, charges = 1, class = "MONK", type = 3}, --Life Cocoon
	[115310] = 	{cooldown = 180, 	duration = false, 	specs = {270}, 			talent =false, charges = 1, class = "MONK", type = 4}, --Revival
	[197908] = 	{cooldown = 90, 	duration = 10, 		specs = {270}, 			talent =22166, charges = 1, class = "MONK", type = 5}, --Mana tea (talent)
	[116844] = 	{cooldown = 45, 	duration = 5, 		specs = {268,269,270}, 	talent =19995, charges = 1, class = "MONK", type = 5}, --Ring of peace (talent)
	[119381] = 	{cooldown = 50, 	duration = 3, 		specs = {268,269,270}, 	talent =false, charges = 1, class = "MONK", type = 5}, --Leg Sweep
	
	--hunter
	-- 253 - Beast Mastery
	-- 254 - Marksmenship
	-- 255 - Survival

	[193530] = 	{cooldown = 120, 	duration = 20, 		specs = {253},		 	talent =false, charges = 1, class = "HUNTER", type = 1}, --Aspect of the Wild
	[19574] = 	{cooldown = 90, 	duration = 12, 		specs = {253}, 			talent =false, charges = 1, class = "HUNTER", type = 1}, --Bestial Wrath
	[201430] = 	{cooldown = 180, 	duration = 12, 		specs = {253}, 			talent =23044, charges = 1, class = "HUNTER", type = 1}, --Stampede (talent)
	[288613] = 	{cooldown = 180, 	duration = 15, 		specs = {254}, 			talent =false, charges = 1, class = "HUNTER", type = 1}, --Trueshot
	[199483] = 	{cooldown = 60, 	duration = 60, 		specs = {253,254,255}, 	talent =23100, charges = 1, class = "HUNTER", type = 2}, --Camouflage (talent)
	[281195] = 	{cooldown = 180, 	duration = 6, 		specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 2}, --Survival of the Fittest
	[266779] = 	{cooldown = 120, 	duration = 20, 		specs = {255}, 			talent =false, charges = 1, class = "HUNTER", type = 1}, --Coordinated Assault
	[186265] = 	{cooldown = 180, 	duration = 8, 		specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 2}, --Aspect of the Turtle
	[109304] = 	{cooldown = 120, 	duration = false, 	specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 2}, --Exhilaration
	[186257] = 	{cooldown = 144, 	duration = 14, 		specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 5}, --Aspect of the cheetah
	[19577] = 	{cooldown = 60, 	duration = 5, 		specs = {253,255}, 		talent =false, charges = 1, class = "HUNTER", type = 5}, --Intimidation
	[109248] = 	{cooldown = 45, 	duration = 10, 		specs = {253,254,255}, 	talent =22499, charges = 1, class = "HUNTER", type = 5}, --Binding Shot (talent)
	[187650] = 	{cooldown = 25, 	duration = 60, 		specs = {253,254,255}, 	talent =false, charges = 1, class = "HUNTER", type = 5}, --Freezing Trap
	[186289] = 	{cooldown = 72, 	duration = 15, 		specs = {255}, 			talent =false, charges = 1, class = "HUNTER", type = 5}, --Aspect of the eagle

	--druid
	-- 102 - Balance
	-- 103 - Feral
	-- 104 - Guardian
	-- 105 - Restoration

	[77761] = 	{cooldown = 120, 	duration = 8, 		specs = {102,103,104,105}, 	talent =false, charges = 1, class = "DRUID", type = 4}, --Stampeding Roar
	[194223] = 	{cooldown = 180, 	duration = 20, 		specs = {102}, 				talent =false, charges = 1, class = "DRUID", type = 1}, --Celestial Alignment
	[102560] = 	{cooldown = 180, 	duration = 30, 		specs = {102}, 				talent =21702, charges = 1, class = "DRUID", type = 1}, --Incarnation: Chosen of Elune (talent)
	[22812] = 	{cooldown = 60, 	duration = 12, 		specs = {102,103,104,105}, 	talent =false, charges = 1, class = "DRUID", type = 2}, --Barkskin
	[108238] = 	{cooldown = 90, 	duration = false, 	specs = {102,103,104,105}, 	talent =18570, charges = 1, class = "DRUID", type = 2}, --Renewal (talent)
	[29166] = 	{cooldown = 180, 	duration = 12, 		specs = {102,105}, 			talent =false, charges = 1, class = "DRUID", type = 3}, --Innervate
	[106951] = 	{cooldown = 180, 	duration = 15, 		specs = {103,104}, 			talent =false, charges = 1, class = "DRUID", type = 1}, --Berserk
	[102543] = 	{cooldown = 30, 	duration = 180, 	specs = {103}, 				talent =21704, charges = 1, class = "DRUID", type = 1}, --Incarnation: King of the Jungle (talent)
	[61336] = 	{cooldown = 120, 	duration = 6, 		specs = {103,104}, 			talent =false, charges = 2, class = "DRUID", type = 2}, --Survival Instincts (2min feral 4min guardian, same spellid)
	[102558] = 	{cooldown = 180, 	duration = 30, 		specs = {104}, 				talent =22388, charges = 1, class = "DRUID", type = 2}, --Incarnation: Guardian of Ursoc (talent)
	[33891] = 	{cooldown = 180, 	duration = 30, 		specs = {105}, 				talent =22421, charges = 1, class = "DRUID", type = 2}, --Incarnation: Tree of Life (talent)
	[102342] = 	{cooldown = 60, 	duration = 12, 		specs = {105}, 				talent =false, charges = 1, class = "DRUID", type = 3}, --Ironbark
	[203651] = 	{cooldown = 60, 	duration = false, 	specs = {105}, 				talent =22422, charges = 1, class = "DRUID", type = 3}, --Overgrowth (talent)
	[740] = 	{cooldown = 180, 	duration = 8, 		specs = {105}, 				talent =false, charges = 1, class = "DRUID", type = 4}, --Tranquility
	[197721] = 	{cooldown = 90, 	duration = 8, 		specs = {105}, 				talent =22404, charges = 1, class = "DRUID", type = 4}, --Flourish (talent)
	[132469] = 	{cooldown = 30, 	duration = false, 	specs = {102,103,104,105}, 	talent =false, charges = 1, class = "DRUID", type = 5}, --Typhoon
	[319454] = 	{cooldown = 300, 	duration = 45, 		specs = {102,103,104,105}, 	talent =18577, charges = 1, class = "DRUID", type = 5}, --Heart of the Wild (talent)
	[102793] = 	{cooldown = 60, 	duration = 10, 		specs = {102,103,104,105}, 	talent =false, charges = 1, class = "DRUID", type = 5}, --Ursol's Vortex

	--death knight
	-- 252 - Unholy
	-- 251 - Frost
	-- 252 - Blood

	[275699] = 	{cooldown = 90, 	duration = 15, 		specs = {252}, 			talent =false, charges = 1, class = "DEATHKNIGHT", type = 1}, --Apocalypse
	[42650] = 	{cooldown = 480, 	duration = 30, 		specs = {252}, 			talent =false, charges = 1, class = "DEATHKNIGHT", type = 1}, --Army of the Dead
	[49206] = 	{cooldown = 180, 	duration = 30, 		specs = {252}, 			talent =22110, charges = 1, class = "DEATHKNIGHT", type = 1}, --Summon Gargoyle (talent)
	[207289] = 	{cooldown = 78, 	duration = 12, 		specs = {252}, 			talent =22538, charges = 1, class = "DEATHKNIGHT", type = 1}, --Unholy Assault (talent)
	[48743] = 	{cooldown = 120, 	duration = 15, 		specs = {250,251,252}, 	talent =23373, charges = 1, class = "DEATHKNIGHT", type = 2}, --Death Pact (talent)
	[48707] = 	{cooldown = 60, 	duration = 10, 		specs = {250,251,252}, 	talent =23373, charges = 1, class = "DEATHKNIGHT", type = 2}, --Anti-magic Shell
	[152279] = 	{cooldown = 120, 	duration = 5, 		specs = {251}, 			talent =22537, charges = 1, class = "DEATHKNIGHT", type = 1}, --Breath of Sindragosa (talent)
	[47568] = 	{cooldown = 120, 	duration = 20, 		specs = {251}, 			talent =false, charges = 1, class = "DEATHKNIGHT", type = 1}, --Empower Rune Weapon
	[279302] = 	{cooldown = 120, 	duration = 10, 		specs = {251}, 			talent =22535, charges = 1, class = "DEATHKNIGHT", type = 1}, --Frostwyrm's Fury (talent)
	[49028] = 	{cooldown = 120, 	duration = 8, 		specs = {250}, 			talent =false, charges = 1, class = "DEATHKNIGHT", type = 1}, --Dancing Rune Weapon
	[55233] = 	{cooldown = 90, 	duration = 10, 		specs = {250}, 			talent =false, charges = 1, class = "DEATHKNIGHT", type = 2}, --Vampiric Blood
	[48792] = 	{cooldown = 120, 	duration = 8, 		specs = {250,251,252}, 	talent =false, charges = 1, class = "DEATHKNIGHT", type = 2}, --Icebound Fortitude
	[51052] = 	{cooldown = 120, 	duration = 10, 		specs = {250,251,252}, 	talent =false, charges = 1, class = "DEATHKNIGHT", type = 4}, --Anti-magic Zone
	[219809] = 	{cooldown = 60, 	duration = 8, 		specs = {250}, 			talent =23454, charges = 1, class = "DEATHKNIGHT", type = 2}, --Tombstone (talent)
	[108199] = 	{cooldown = 120, 	duration = false, 	specs = {250}, 			talent =false, charges = 1, class = "DEATHKNIGHT", type = 5}, --Gorefiend's Grasp
	[207167] = 	{cooldown = 60, 	duration = 5, 		specs = {251}, 			talent =22519, charges = 1, class = "DEATHKNIGHT", type = 5}, --Blinding Sleet (talent)
	[108194] = 	{cooldown = 45, 	duration = 4, 		specs = {251,252}, 		talent =22520, charges = 1, class = "DEATHKNIGHT", type = 5}, --Asphyxiate (talent)
	[221562] = 	{cooldown = 45, 	duration = 5, 		specs = {250}, 			talent =false, charges = 1, class = "DEATHKNIGHT", type = 5}, --Asphyxiate
	[212552] = 	{cooldown = 60, 	duration = 4, 		specs = {250,251,252}, 	talent =19228, charges = 1, class = "DEATHKNIGHT", type = 5}, --Wraith walk (talent)

	--demon hunter
	-- 577 - Havoc
	-- 581 - Vengance

	[191427] = 	{cooldown = 240, 	duration = 30, 		specs = {577}, 			talent =false, charges = 1, class = "DEMONHUNTER", type = 1}, --Metamorphosis
	[198589] = 	{cooldown = 60, 	duration = 10, 		specs = {577}, 			talent =false, charges = 1, class = "DEMONHUNTER", type = 2}, --Blur
	[196555] = 	{cooldown = 120, 	duration = 5, 		specs = {577}, 			talent =21865, charges = 1, class = "DEMONHUNTER", type = 2}, --Netherwalk (talent)
	[187827] = 	{cooldown = 180, 	duration = 15, 		specs = {581}, 			talent =false, charges = 1, class = "DEMONHUNTER", type = 2}, --Metamorphosis
	[196718] = 	{cooldown = 180, 	duration = 8, 		specs = {577}, 			talent =false, charges = 1, class = "DEMONHUNTER", type = 4}, --Darkness
	[188501] = 	{cooldown = 30, 	duration = 10, 		specs = {577,581}, 		talent =false, charges = 1, class = "DEMONHUNTER", type = 5}, --Spectral Sight
	[179057] = 	{cooldown = 60, 	duration = 2, 		specs = {577}, 			talent =false, charges = 1, class = "DEMONHUNTER", type = 5}, --Chaos Nova
	[211881] = 	{cooldown = 30, 	duration = 4, 		specs = {577}, 			talent =22767, charges = 1, class = "DEMONHUNTER", type = 5}, --Fel Eruption (talent)
	[320341] = 	{cooldown = 90, 	duration = false, 	specs = {581}, 			talent =21902, charges = 1, class = "DEMONHUNTER", type = 1}, --Bulk Extraction (talent)
	[204021] = 	{cooldown = 60, 	duration = 10, 		specs = {581}, 			talent =false, charges = 1, class = "DEMONHUNTER", type = 2}, --Fiery Brand
	[263648] = 	{cooldown = 30, 	duration = 12, 		specs = {581}, 			talent =22768, charges = 1, class = "DEMONHUNTER", type = 2}, --Soul Barrier (talent)
	[207684] = 	{cooldown = 90, 	duration = 12, 		specs = {581}, 			talent =false, charges = 1, class = "DEMONHUNTER", type = 5}, --Sigil of Misery
	[202137] = 	{cooldown = 60, 	duration = 8, 		specs = {581}, 			talent =false, charges = 1, class = "DEMONHUNTER", type = 5}, --Sigil of Silence
	[202138] = 	{cooldown = 90, 	duration = 6, 		specs = {581}, 			talent =22511, charges = 1, class = "DEMONHUNTER", type = 5}, --Sigil of Chains (talent)
	
	--mage
	-- 62 - Arcane
	-- 63 - Fire
	-- 64 - Frost

	[12042] = 	{cooldown = 90, 	duration = 10, 		specs = {62}, 			talent =false, charges = 1, class = "MAGE", type = 1},  --Arcane Power
	[12051] = 	{cooldown = 90, 	duration = 6, 		specs = {62}, 			talent =false, charges = 1, class = "MAGE", type = 1},  --Evocation
	[110960] = 	{cooldown = 120, 	duration = 20, 		specs = {62}, 			talent =false, charges = 1, class = "MAGE", type = 2},  --Greater Invisibility
	[235450] = 	{cooldown = 25, 	duration = 60, 		specs = {62}, 			talent =false, charges = 1, class = "MAGE", type = 5},  --Prismatic Barrier
	[235313] = 	{cooldown = 25, 	duration = 60, 		specs = {63}, 			talent =false, charges = 1, class = "MAGE", type = 5},  --Blazing Barrier
	[11426] = 	{cooldown = 25, 	duration = 60, 		specs = {64}, 			talent =false, charges = 1, class = "MAGE", type = 5},  --Ice Barrier
	[190319] = 	{cooldown = 120, 	duration = 10, 		specs = {63}, 			talent =false, charges = 1, class = "MAGE", type = 1},  --Combustion
	[55342] = 	{cooldown = 120, 	duration = 40, 		specs = {62,63,64}, 	talent =22445, charges = 1, class = "MAGE", type = 1},  --Mirror Image
	[66] = 		{cooldown = 300, 	duration = 20, 		specs = {63,64}, 		talent =false, charges = 1, class = "MAGE", type = 2},  --Invisibility
	[12472] = 	{cooldown = 180, 	duration = 20, 		specs = {64}, 			talent =false, charges = 1, class = "MAGE", type = 1},  --Icy Veins
	[205021] = 	{cooldown = 78, 	duration = 5, 		specs = {64}, 			talent =22309, charges = 1, class = "MAGE", type = 1},  --Ray of Frost (talent)
	[45438] = 	{cooldown = 240, 	duration = 10, 		specs = {62,63,64}, 	talent =false, charges = 1, class = "MAGE", type = 2},  --Ice Block
	[235219] = 	{cooldown = 300, 	duration = false, 	specs = {64}, 			talent =false, charges = 1, class = "MAGE", type = 5},  --Cold Snap
	[113724] = 	{cooldown = 45, 	duration = 10, 		specs = {62,63,64}, 	talent =22471, charges = 1, class = "MAGE", type = 5},  --Ring of Frost (talent)

	--priest
	-- 256 - Discipline
	-- 257 - Holy
	-- 258 - Shadow

	[10060] = 	{cooldown = 120, 	duration = 20, 		specs = {256,257,258}, 	talent =false, charges = 1, class = "PRIEST", type = 1},  --Power Infusion
	[34433] = 	{cooldown = 180, 	duration = 15, 		specs = {256,258}, 		talent =false, charges = 1, class = "PRIEST", type = 1, ignoredIfTalent = 21719},  --Shadowfiend
	[200174] = 	{cooldown = 60, 	duration = 15, 		specs = {258}, 			talent =21719, charges = 1, class = "PRIEST", type = 1},  --Mindbender (talent)
	[123040] = 	{cooldown = 60, 	duration = 12, 		specs = {256}, 			talent =22094, charges = 1, class = "PRIEST", type = 1},  --Mindbender (talent)
	[33206] = 	{cooldown = 180, 	duration = 8, 		specs = {256}, 			talent =false, charges = 1, class = "PRIEST", type = 3},  --Pain Suppression
	[62618] = 	{cooldown = 180, 	duration = 10, 		specs = {256}, 			talent =false, charges = 1, class = "PRIEST", type = 4},  --Power Word: Barrier
	[271466] = 	{cooldown = 180, 	duration = 10, 		specs = {256}, 			talent =21184, charges = 1, class = "PRIEST", type = 4},  --Luminous Barrier (talent)
	[47536] = 	{cooldown = 90, 	duration = 10, 		specs = {256}, 			talent =false, charges = 1, class = "PRIEST", type = 5},  --Rapture
	[19236] = 	{cooldown = 90, 	duration = 10, 		specs = {256,257,258}, 	talent =false, charges = 1, class = "PRIEST", type = 5},  --Desperate Prayer
	[200183] = 	{cooldown = 120, 	duration = 20, 		specs = {257}, 			talent =21644, charges = 1, class = "PRIEST", type = 2},  --Apotheosis (talent)
	[47788] = 	{cooldown = 180, 	duration = 10, 		specs = {257}, 			talent =false, charges = 1, class = "PRIEST", type = 3},  --Guardian Spirit
	[64843] = 	{cooldown = 180, 	duration = 8, 		specs = {257}, 			talent =false, charges = 1, class = "PRIEST", type = 4},  --Divine Hymn
	[64901] = 	{cooldown = 300, 	duration = 6, 		specs = {257}, 			talent =false, charges = 1, class = "PRIEST", type = 4},  --Symbol of Hope
	[265202] = 	{cooldown = 720, 	duration = false, 	specs = {257}, 			talent =23145, charges = 1, class = "PRIEST", type = 4},  --Holy Word: Salvation (talent)
	[109964] = 	{cooldown = 60, 	duration = 12, 		specs = {256}, 			talent =21184, charges = 1, class = "PRIEST", type = 4},  --Spirit Shell (talent)
	[8122] = 	{cooldown = 60, 	duration = 8, 		specs = {256,257,258}, 	talent =false, charges = 1, class = "PRIEST", type = 5},  --Psychic Scream
	[193223] = 	{cooldown = 240, 	duration = 60, 		specs = {258}, 			talent =21979, charges = 1, class = "PRIEST", type = 1},  --Surrender to Madness (talent)
	[47585] = 	{cooldown = 120, 	duration = 6, 		specs = {258}, 			talent =false, charges = 1, class = "PRIEST", type = 2},  --Dispersion
	[15286] = 	{cooldown = 120, 	duration = 15, 		specs = {258}, 			talent =false, charges = 1, class = "PRIEST", type = 4},  --Vampiric Embrace
	[64044] = 	{cooldown = 45, 	duration = 4, 		specs = {258}, 			talent =21752, charges = 1, class = "PRIEST", type = 5}, --Psychic Horror
	[205369] = 	{cooldown = 30, 	duration = 6, 		specs = {258}, 			talent =23375, charges = 1, class = "PRIEST", type = 5}, --Mind Bomb
	[228260] = 	{cooldown = 90, 	duration = 15, 		specs = {258}, 			talent =false, charges = 1, class = "PRIEST", type = 1}, --Void Erruption
	[73325] = 	{cooldown = 90, 	duration = false, 	specs = {256,257,258}, 	talent =false, charges = 1, class = "PRIEST", type = 5}, --Leap of Faith

	--rogue
	-- 259 - Assasination
	-- 260 - Outlaw
	-- 261 - Subtlety

	[79140] = 	{cooldown = 120, 	duration = 20, 		specs = {259}, 			talent =false, charges = 1, class = "ROGUE", type = 1},  --Vendetta
	[1856] = 	{cooldown = 120, 	duration = 3, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 2},  --Vanish
	[5277] = 	{cooldown = 120, 	duration = 10, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 2},  --Evasion
	[31224] = 	{cooldown = 120, 	duration = 5, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 2},  --Cloak of Shadows
	[2094] = 	{cooldown = 120, 	duration = 60, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 5},  --Blind
	[114018] = 	{cooldown = 360, 	duration = 15, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 5},  --Shroud of Concealment
	[185311] = 	{cooldown = 30, 	duration = 15, 		specs = {259,260,261}, 	talent =false, charges = 1, class = "ROGUE", type = 5},  --Crimson Vial
	[13750] = 	{cooldown = 180, 	duration = 20, 		specs = {260}, 			talent =false, charges = 1, class = "ROGUE", type = 1},  --Adrenaline Rush
	[51690] = 	{cooldown = 120, 	duration = 2, 		specs = {260}, 			talent =23175, charges = 1, class = "ROGUE", type = 1},  --Killing Spree (talent)
	[199754] = 	{cooldown = 120, 	duration = 10, 		specs = {260}, 			talent =false, charges = 1, class = "ROGUE", type = 2},  --Riposte
	[343142] = 	{cooldown = 90, 	duration = 10, 		specs = {260}, 			talent =19250, charges = 1, class = "ROGUE", type = 5},  --Dreadblades
	[121471] = 	{cooldown = 180, 	duration = 20, 		specs = {261}, 			talent =false, charges = 1, class = "ROGUE", type = 1},  --Shadow Blades
}

LIB_OPEN_RAID_COOLDOWSAP_BY_SPEC = {};
for spellID,spellData in pairs(LIB_OPEN_RAID_COOLDOWSAP_INFO) do
	for _,specID in ipairs(spellData.specs) do
		LIB_OPEN_RAID_COOLDOWSAP_BY_SPEC[specID] = LIB_OPEN_RAID_COOLDOWSAP_BY_SPEC[specID] or {};
		LIB_OPEN_RAID_COOLDOWSAP_BY_SPEC[specID][spellID] = spellData.type;
	end
end

-- DF Evoker
LIB_OPEN_RAID_COOLDOWSAP_BY_SPEC[1467] = {};
LIB_OPEN_RAID_COOLDOWSAP_BY_SPEC[1468] = {};

--list of all crowd control spells
--it is not transmitted to other clients
LIB_OPEN_RAID_CROWDCONTROL = { --copied from retail
	[331866] = {cooldown = 0,	class = "COVENANT|VENTHYR"}, --Agent of Chaos
	[334693] = {cooldown = 0,	class = "DEAHTKNIGHT"}, --Absolute Zero
	[221562] = {cooldown = 45,	class = "DEATHKNIGHT"}, --Asphyxiate
	[47528] = {cooldown = 15,	class = "DEATHKNIGHT"}, --Mind Freeze
	[207167] = {cooldown = 60,	class = "DEATHKNIGHT"}, --Blinding Sleet
	[91807] = {cooldown = 0,	class = "DEATHKNIGHT"}, --Shambling Rush
	[108194] = {cooldown = 45,	class = "DEATHKNIGHT"}, --Asphyxiate
	[211881] = {cooldown = 30,	class = "DEMONHUNTER"}, --Fel Eruption
	[200166] = {cooldown = 0,	class = "DEMONHUNTER"}, --Metamorphosis
	[217832] = {cooldown = 45,	class = "DEMONHUNTER"}, --Imprison
	[183752] = {cooldown = 15,	class = "DEMONHUNTER"}, --Disrupt
	[207685] = {cooldown = 0,	class = "DEMONHUNTER"}, --Sigil of Misery
	[179057] = {cooldown = 45,	class = "DEMONHUNTER"}, --Chaos Nova
	[221527] = {cooldown = 45,	class = "DEMONHUNTER"}, --Imprison with detainment talent
	[339] = {cooldown = 0,		class = "DRUID"}, --Entangling Roots
	[102359] = {cooldown = 30,	class = "DRUID"}, --Mass Entanglement
	[93985] = {cooldown = 0,	class = "DRUID"}, --Skull Bash
	[2637] = {cooldown = 0,		class = "DRUID"}, --Hibernate
	[5211] = {cooldown = 60,	class = "DRUID"}, --Mighty Bash
	[99] = {cooldown = 30,		class = "DRUID"}, --Incapacitating Roar
	[127797] = {cooldown = 0,	class = "DRUID"}, --Ursol's Vortex
	[203123] = {cooldown = 0,	class = "DRUID"}, --Maim
	[45334] = {cooldown = 0,	class = "DRUID"}, --Immobilized
	[33786] = {cooldown = 0,	class = "DRUID"}, --Cyclone
	[236748] = {cooldown = 30,	class = "DRUID"}, --Intimidating Roar
	[61391] = {cooldown = 0,	class = "DRUID"}, --Typhoon
	[163505] = {cooldown = 0,	class = "DRUID"}, --Rake
	[50259] = {cooldown = 0,	class = "DRUID"}, --Dazed
	[372245] = {cooldown = 0,	class = "EVOKER"}, --Terror of the Skies
	[360806] = {cooldown = 15,	class = "EVOKER"}, --Sleep Walk
	[162480] = {cooldown = 0,	class = "HUNTER"}, --Steel Trap
	[187707] = {cooldown = 15,	class = "HUNTER"}, --Muzzle
	[147362] = {cooldown = 24,	class = "HUNTER"}, --Counter Shot
	[190927] = {cooldown = 6,	class = "HUNTER"}, --Harpoon
	[117526] = {cooldown = 45,	class = "HUNTER"}, --Binding Shot
	[24394] = {cooldown = 0,	class = "HUNTER"}, --Intimidation
	[117405] = {cooldown = 0,	class = "HUNTER"}, --Binding Shot
	[19577] = {cooldown = 60,	class = "HUNTER"}, --Intimidation
	[1513] = {cooldown = 0,		class = "HUNTER"}, --Scare Beast
	[3355] = {cooldown = 30,	class = "HUNTER"}, --Freezing Trap
	[203337] = {cooldown = 30,	class = "HUNTER"}, --Freezing trap with diamond ice talent
	[31661] = {cooldown = 45,	class = "MAGE"}, --Dragon's Breath
	[161353] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[277787] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[157981] = {cooldown = 30,	class = "MAGE"}, --Blast Wave
	[82691] = {cooldown = 0,	class = "MAGE"}, --Ring of Frost
	[118] = {cooldown = 0,		class = "MAGE"}, --Polymorph
	[161354] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[157997] = {cooldown = 25,	class = "MAGE"}, --Ice Nova
	[391622] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[28271] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[122] = {cooldown = 0,		class = "MAGE"}, --Frost Nova
	[277792] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[61721] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[126819] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[61305] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[28272] = {cooldown = 0,	class = "MAGE"}, --Polymorph
	[2139] = {cooldown = 24,	class = "MAGE"}, --Counterspell
	[198909] = {cooldown = 0,	class = "MONK"}, --Song of Chi-Ji
	[119381] = {cooldown = 60,	class = "MONK"}, --Leg Sweep
	[107079] = {cooldown = 120,	class = "MONK"}, --Quaking Palm
	[116706] = {cooldown = 0,	class = "MONK"}, --Disable
	[115078] = {cooldown = 45,	class = "MONK"}, --Paralysis
	[116705] = {cooldown = 15,	class = "MONK"}, --Spear Hand Strike
	[31935] = {cooldown = 15,	class = "PALADIN"}, --Avenger's Shield
	[20066] = {cooldown = 15,	class = "PALADIN"}, --Repentance
	[217824] = {cooldown = 0,	class = "PALADIN"}, --Shield of Virtue
	[105421] = {cooldown = 0,	class = "PALADIN"}, --Blinding Light
	[10326] = {cooldown = 15,	class = "PALADIN"}, --Turn Evil
	[853] = {cooldown = 60,		class = "PALADIN"}, --Hammer of Justice
	[96231] = {cooldown = 15,	class = "PALADIN"}, --Rebuke
	[205364] = {cooldown = 30,	class = "PRIEST"}, --Dominate Mind
	[64044] = {cooldown = 45,	class = "PRIEST"}, --Psychic Horror
	[226943] = {cooldown = 0,	class = "PRIEST"}, --Mind Bomb
	[15487] = {cooldown = 45,	class = "PRIEST"}, --Silence
	[605] = {cooldown = 0,		class = "PRIEST"}, --Mind Control
	[8122] = {cooldown = 45,	class = "PRIEST"}, --Psychic Scream
	[200200] = {cooldown = 60,	class = "PRIEST"}, --Holy Word: Chastise
	[9484] = {cooldown = 0,		class = "PRIEST"}, --Shackle Undead
	[200196] = {cooldown = 60,	class = "PRIEST"}, --Holy Word: Chastise
	[6770] = {cooldown = 0,		class = "ROGUE"}, --Sap
	[2094] = {cooldown = 120,	class = "ROGUE"}, --Blind
	[1766] = {cooldown = 15,	class = "ROGUE"}, --Kick
	[427773] = {cooldown = 0,	class = "ROGUE"}, --Blind
	[408] = {cooldown = 20,		class = "ROGUE"}, --Kidney Shot
	[1776] = {cooldown = 20,	class = "ROGUE"}, --Gouge
	[1833] = {cooldown = 0,		class = "ROGUE"}, --Cheap Shot
	[211015] = {cooldown = 30,	class = "SHAMAN"}, --Hex
	[269352] = {cooldown = 30,	class = "SHAMAN"}, --Hex
	[277778] = {cooldown = 30,	class = "SHAMAN"}, --Hex
	[64695] = {cooldown = 0,	class = "SHAMAN"}, --Earthgrab
	[57994] = {cooldown = 12,	class = "SHAMAN"}, --Wind Shear
	[197214] = {cooldown = 40,	class = "SHAMAN"}, --Sundering
	[118905] = {cooldown = 0,	class = "SHAMAN"}, --Static Charge
	[277784] = {cooldown = 30,	class = "SHAMAN"}, --Hex
	[309328] = {cooldown = 30,	class = "SHAMAN"}, --Hex
	[211010] = {cooldown = 30,	class = "SHAMAN"}, --Hex
	[210873] = {cooldown = 30,	class = "SHAMAN"}, --Hex
	[211004] = {cooldown = 30,	class = "SHAMAN"}, --Hex
	[51514] = {cooldown = 30,	class = "SHAMAN"}, --Hex
	[305485] = {cooldown = 30,	class = "SHAMAN"}, --Lightning Lasso
	[89766] = {cooldown = 30,	class = "WARLOCK"}, --Axe Toss (pet felguard ability)
	[6789] = {cooldown = 45,	class = "WARLOCK"}, --Mortal Coil
	[118699] = {cooldown = 0,	class = "WARLOCK"}, --Fear
	[710] = {cooldown = 0,		class = "WARLOCK"}, --Banish
	[212619] = {cooldown = 60,	class = "WARLOCK"}, --Call Felhunter
	[19647] = {cooldown = 24,	class = "WARLOCK"}, --Spell Lock
	[30283] = {cooldown = 60,	class = "WARLOCK"}, --Shadowfury
	[5484] = {cooldown = 40,	class = "WARLOCK"}, --Howl of Terror
	[6552] = {cooldown = 15,	class = "WARRIOR"}, --Pummel
	[132168] = {cooldown = 0,	class = "WARRIOR"}, --Shockwave
	[132169] = {cooldown = 0,	class = "WARRIOR"}, --Storm Bolt
	[5246] = {cooldown = 90,	class = "WARRIOR"}, --Intimidating Shout
}

--[=[
Spell customizations:
	Many times there's spells with the same name which does different effects
	In here you find a list of spells which has its name changed to give more information to the player
	you may add into the list any other parameter your addon uses declaring for example 'icon = ' or 'texcoord = ' etc.

Implamentation Example:
	if (LIB_OPEN_RAID_SPELL_CUSTOM_NAMES) then
		for spellId, customTable in pairs(LIB_OPEN_RAID_SPELL_CUSTOM_NAMES) do
			local name = customTable.name
			if (name) then
				MyCustomSpellTable[spellId] = name
			end
		end
	end
--]=]

LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {} --default fallback

if (GetBuildInfo():match ("%d") == "1") then
		LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}

elseif (GetBuildInfo():match ("%d") == "2") then
	LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}

elseif (GetBuildInfo():match ("%d") == "3") then
	LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {}

else
	LIB_OPEN_RAID_SPELL_CUSTOM_NAMES = {
		[44461] = {name = GetSpellInfo(44461) .. " (" .. L["STRING_EXPLOSION"] .. ")"}, --Living Bomb (explosion)
		[59638] = {name = GetSpellInfo(59638) .. " (" .. L["STRING_MIRROR_IMAGE"] .. ")"}, --Mirror Image's Frost Bolt (mage)
		[88082] = {name = GetSpellInfo(88082) .. " (" .. L["STRING_MIRROR_IMAGE"] .. ")"}, --Mirror Image's Fireball (mage)
		[94472] = {name = GetSpellInfo(94472) .. " (" .. L["STRING_CRITICAL_ONLY"] .. ")"}, --Atonement critical hit (priest)
		[33778] = {name = GetSpellInfo(33778) .. " (" .. L["STRING_BLOOM"] .. ")"}, --lifebloom (bloom)
		[121414] = {name = GetSpellInfo(121414) .. " (" .. L["STRING_GLAIVE"] .. " #1)"}, --glaive toss (hunter)
		[120761] = {name = GetSpellInfo(120761) .. " (" .. L["STRING_GLAIVE"] .. " #2)"}, --glaive toss (hunter)
		[212739] = {name = GetSpellInfo(212739) .. " (" .. L["STRING_MAINTARGET"] .. ")"}, --DK Epidemic
		[215969] = {name = GetSpellInfo(215969) .. " (" .. L["STRING_AOE"] .. ")"}, --DK Epidemic
		[70890] = {name = GetSpellInfo(70890) .. " (" .. L["STRING_SHADOW"] .. ")"}, --DK Scourge Strike
		[55090] = {name = GetSpellInfo(55090) .. " (" .. L["STRING_PHYSICAL"] .. ")"}, --DK Scourge Strike
		[49184] = {name = GetSpellInfo(49184) .. " (" .. L["STRING_MAINTARGET"] .. ")"}, --DK Howling Blast
		[237680] = {name = GetSpellInfo(237680) .. " (" .. L["STRING_AOE"] .. ")"}, --DK Howling Blast
		[228649] = {name = GetSpellInfo(228649) .. " (" .. L["STRING_PASSIVE"] .. ")"}, --Monk Mistweaver Blackout kick - Passive Teachings of the Monastery
		[339538] = {name = GetSpellInfo(224266) .. " (" .. L["STRING_TEMPLAR_VINDCATION"] .. ")"}, --
		[343355] = {name = GetSpellInfo(343355)  .. " (" .. L["STRING_PROC"] .. ")"}, --shadow priest's void bold proc

		--shadowlands trinkets
		[345020] = {name = GetSpellInfo(345020) .. " ("  .. L["STRING_TRINKET"] .. ")"},
	}
end

--interrupt list using proxy from cooldown list
--this list should be expansion and combatlog safe
LIB_OPEN_RAID_SPELL_INTERRUPT = {
	[6552] = LIB_OPEN_RAID_COOLDOWSAP_INFO[6552], --Pummel

	[2139] = LIB_OPEN_RAID_COOLDOWSAP_INFO[2139], --Counterspell

	[15487] = LIB_OPEN_RAID_COOLDOWSAP_INFO[15487], --Silence (shadow) Last Word Talent to reduce cooldown in 15 seconds

	[1766] = LIB_OPEN_RAID_COOLDOWSAP_INFO[1766], --Kick

	[96231] = LIB_OPEN_RAID_COOLDOWSAP_INFO[96231], --Rebuke (protection and retribution)

	[116705] = LIB_OPEN_RAID_COOLDOWSAP_INFO[116705], --Spear Hand Strike (brewmaster and windwalker)

	[57994] = LIB_OPEN_RAID_COOLDOWSAP_INFO[57994], --Wind Shear

	[47528] = LIB_OPEN_RAID_COOLDOWSAP_INFO[47528], --Mind Freeze

	[106839] = LIB_OPEN_RAID_COOLDOWSAP_INFO[106839], --Skull Bash (feral, guardian)
	[78675] = LIB_OPEN_RAID_COOLDOWSAP_INFO[78675], --Solar Beam (balance)

	[147362] = LIB_OPEN_RAID_COOLDOWSAP_INFO[147362], --Counter Shot (beast mastery, marksmanship)
	[187707] = LIB_OPEN_RAID_COOLDOWSAP_INFO[187707], --Muzzle (survival)

	[183752] = LIB_OPEN_RAID_COOLDOWSAP_INFO[183752], --Disrupt

	[19647] = LIB_OPEN_RAID_COOLDOWSAP_INFO[19647], --Spell Lock (pet felhunter ability)
	[89766] = LIB_OPEN_RAID_COOLDOWSAP_INFO[89766], --Axe Toss (pet felguard ability)
}

--override list of spells with more than one effect, example: multiple types of polymorph
LIB_OPEN_RAID_SPELL_DEFAULT_IDS = {
	--stampeding roar (druid)
	[106898] = 77761,
	[77764] = 77761, --"Uncategorized" on wowhead, need to test if still exists
	--spell lock (warlock pet)
	[119910] = 19647, --"Uncategorized" on wowhead
	[132409] = 19647, --"Uncategorized" on wowhead
	--[115781] = 19647, --optical blast used by old talent observer, still a thing?
	--[251523] = 19647, --wowhead list this spell as sibling spell
	--[251922] = 19647, --wowhead list this spell as sibling spell
	--axe toss (warlock pet)
	[119914] = 89766, --"Uncategorized" on wowhead
	[347008] = 89766, --"Uncategorized" on wowhead
	--hex (shaman)
	[210873] = 51514, --Compy
	[211004] = 51514, --Spider
	[211010] = 51514, --Snake
	[211015] = 51514, --Cockroach
	[269352] = 51514, --Skeletal Hatchling
	[277778] = 51514, --Zandalari Tendonripper
	[277784] = 51514, --Wicker Mongrel
	[309328] = 51514, --Living Honey
	--typhoon
	--[61391] = 132469,
	--metamorphosis
	[191427] = 200166,
	--187827 vengeance need to test these spellIds
	--191427 havoc
}
--need to add mass dispell (32375)

LIB_OPEN_RAID_DATABASE_LOADED = true
