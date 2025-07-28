local _, LUP = ...

local ADDON_NAME = "MRT"

LUP.nicknameInitFunctions[ADDON_NAME] = function()
	-- If this is done in the same frame that MRT loads, it complains in chat
	C_Timer.After(
		0,
		function()
			if GMRT and GMRT.F then
				GMRT.F:RegisterCallback(
					"RaidCooldowns_Bar_TextName",
					function(_, _, gsubData)
						if gsubData and gsubData.name then
							gsubData.name = SAP_Raid_Updater:GetNickname(gsubData.name) or gsubData.name
						end
					end
				)
			end
		end
	)
end