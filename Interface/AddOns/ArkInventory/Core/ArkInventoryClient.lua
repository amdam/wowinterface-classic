-- blizzzard functions that no longer exist, or have been replaced across clients

ArkInventory.CrossClient = { }


function ArkInventory.CrossClient.GetAverageItemLevel( )
	
	if GetAverageItemLevel then
		
		local overall, equipped, pvp = GetAverageItemLevel( )
		return math.floor( equipped )
		
	else
		
		return 1
		
	end
	
end

function ArkInventory.CrossClient.GetFirstBagBankSlotIndex( )
	
	if GetFirstBagBankSlotIndex then
		
		-- classic
		return GetFirstBagBankSlotIndex( )
		
	else
		
		-- retail and tbc
		return GetContainerNumSlots( BANK_CONTAINER )
		
	end
	
end

function ArkInventory.CrossClient.IsAnimaItemByID( ... )
	
	if C_Item and C_Item.IsAnimaItemByID then
		
		return C_Item.IsAnimaItemByID( ... )
		
	else
		
		return false
		
	end
	
end

function ArkInventory.CrossClient.GetProfessionInfo( ... )
	
	if GetProfessionInfo then
		
		return GetProfessionInfo( ... )
		
	else
		
		local index = ...
		local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType = GetSkillLineInfo( index )
		
		for k, v in pairs( ArkInventory.Const.Tradeskill.Data ) do
			if v.text == skillName then
				--ArkInventory.Output( "skill [", index, "] found [", skillName, "]=[", k, "]" )
				return skillName, "", 0, 0, 0, 0, k
			end
		end
		
		--ArkInventory.Output( "skill [", index, "] not found [", skillName, "]" )
		
	end
	
end

function ArkInventory.CrossClient.GetProfessions( ... )
	
	if GetProfessions then
		
		return GetProfessions( ... )
		
	else
		
		local good = false
		local skills = { }
		local skillnum = 0
		local header1 = string.lower( ArkInventory.Localise["TRADESKILLS"] )
		local header2 = string.lower( ArkInventory.Localise["SECONDARY_SKILLS"] )
		
		for k = 1, GetNumSkillLines( ) do
			local name, header = GetSkillLineInfo( k )
			--ArkInventory.Output( name, " / ", header )
			if header ~= nil then
				
				name = string.lower( name )
				
				if string.match( header1, name ) or string.match( header2, name ) then
					
					--ArkInventory.Output( "valid header = ", name )
					
					good = true
					
					if string.match( header2, name ) and skillnum < 2 then
						skillnum = 2
					end
					
				else
					
					good = false
					
				end
				
			else
				
				if good then
					skillnum = skillnum + 1
					--ArkInventory.Output( "skills[", skillnum, "] = ", k, " [", name, "]" )
					skills[skillnum] = k
				end
				
			end
		end
		
		
		return skills[1], skills[2], skills[3], skills[4], skills[5]
		
	end
	
end

function ArkInventory.CrossClient.SetSortBagsRightToLeft( ... )
	if SetSortBagsRightToLeft then
		return SetSortBagsRightToLeft( ... )
	end
end

function ArkInventory.CrossClient.GetContainerItemQuestInfo( ... )
	local b, s, i = ...
	if GetContainerItemQuestInfo then
		return GetContainerItemQuestInfo( b, s )
	else
		if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Quest.Start" ) then
			return true, true, false
		end
	end
end

function ArkInventory.CrossClient.IsArtifactPowerItem( ... )
	if IsArtifactPowerItem then
		return IsArtifactPowerItem( ... )
	end
end

function ArkInventory.CrossClient.IsReagentBankUnlocked( ... )
	if IsReagentBankUnlocked then
		return IsReagentBankUnlocked( ... )
	end
end

function ArkInventory.CrossClient.IsCorruptedItem( ... )
	if IsCorruptedItem then
		return IsCorruptedItem( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyInfo( ... )
	
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
		
		return C_CurrencyInfo.GetCurrencyInfo( ... )
		
	elseif GetCurrencyInfo then
		
		local info = { }
		local name, quantity, iconFileID, quantityEarnedThisWeek, maxWeeklyQuantity, maxQuantity, discovered, quality = GetCurrencyInfo( ... )
		
		info.name = name
--		{ Name = "isHeader", Type = "bool", Nilable = false },
--		{ Name = "isHeaderExpanded", Type = "bool", Nilable = false },
--		{ Name = "isTypeUnused", Type = "bool", Nilable = false },
--		{ Name = "isShowInBackpack", Type = "bool", Nilable = false },
		info.quantity = quantity
		info.iconFileID = iconFileID
		info.quantityEarnedThisWeek = quantityEarnedThisWeek
		info.maxQuantity = maxQuantity
--		{ Name = "canEarnPerWeek", Type = "bool", Nilable = false },
--		{ Name = "isTradeable", Type = "bool", Nilable = false },
		info.quality = quality
		info.maxWeeklyQuantity = maxWeeklyQuantity
		info.discovered = discovered
		
		return info
		
	end
	
end

function ArkInventory.CrossClient.GetCurrencyLink( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyLink then
		return C_CurrencyInfo.GetCurrencyLink( ... )
	elseif GetCurrencyLink then
		return GetCurrencyLink( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyListSize( ... )
	if GetCurrencyListSize then
		return GetCurrencyListSize( ... )
	elseif C_CurrencyInfo then
		return C_CurrencyInfo.GetCurrencyListSize( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyListInfo( ... )
	
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListInfo then
		
		return C_CurrencyInfo.GetCurrencyListInfo( ... )
		
	elseif GetCurrencyListInfo then
		
		local info = { }
		local name, isHeader, isHeaderExpanded, isTypeUnused, isShowInBackpack, quantity, iconFileID, maxQuantity, canEarnPerWeek, quantityEarnedThisWeek, unknown, itemID = GetCurrencyListInfo( ... )
		
		info.name = name
		info.isHeader = isHeader
		info.isHeaderExpanded = isHeaderExpanded
		info.isTypeUnused = isTypeUnused
		info.isShowInBackpack = isShowInBackpack
		info.quantity = quantity
		info.iconFileID = iconFileID
		info.maxQuantity = maxQuantity
		info.canEarnPerWeek = canEarnPerWeek
		info.quantityEarnedThisWeek = quantityEarnedThisWeek
--		{ Name = "isTradeable", Type = "bool", Nilable = false },
--		{ Name = "quality", Type = "ItemQuality", Nilable = false },
--		{ Name = "maxWeeklyQuantity", Type = "number", Nilable = false },
--		{ Name = "discovered", Type = "bool", Nilable = false },
		
		return info
		
	end
	
end

function ArkInventory.CrossClient.GetBackpackCurrencyInfo( ... )
	
	if C_CurrencyInfo and C_CurrencyInfo.GetBackpackCurrencyInfo then
		
		return C_CurrencyInfo.GetBackpackCurrencyInfo( ... )
		
	elseif GetBackpackCurrencyInfo then
		
		info = { }
		local name, quantity, iconFileID, currencyTypesID = GetBackpackCurrencyInfo( ... )
		
		info.name = name
		info.quantity = quantity
		info.iconFileID = iconFileID
		info.currencyTypesID = currencyTypesID
		
		return info
		
	end
	
end

function ArkInventory.CrossClient.GetCurrencyListLink( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListLink then
		return C_CurrencyInfo.GetCurrencyListLink( ... )
	elseif GetCurrencyListLink then
		return GetCurrencyListLink( ... )
	end
end

function ArkInventory.CrossClient.SetCurrencyUnused( ... )
	if SetCurrencyUnused then
		return SetCurrencyUnused( ... )
	elseif C_CurrencyInfo then
		return C_CurrencyInfo.SetCurrencyUnused( ... )
	end
end

function ArkInventory.CrossClient.ExpandCurrencyList( ... )
	if ExpandCurrencyList then
		return ExpandCurrencyList( ... )
	elseif C_CurrencyInfo then
		return C_CurrencyInfo.ExpandCurrencyList( ... )
	end
end

function ArkInventory.CrossClient.GetFriendshipReputation( ... )
	if GetFriendshipReputation then
		return GetFriendshipReputation( ... )
	end
end

function ArkInventory.CrossClient.IsFactionParagon( ... )
	if C_Reputation then
		if C_Reputation.IsFactionParagon then
			return C_Reputation.IsFactionParagon( ... )
		end
	end
end

function ArkInventory.CrossClient.SetCVar( ... )
	if C_CVar then
		return C_CVar.SetCVar( ... )
	else
		return SetCVar( ... )
	end
end

function ArkInventory.CrossClient.GetCVar( ... )
	if C_CVar then
		return C_CVar.GetCVar( ... )
	else
		return GetCVar( ... )
	end
end

function ArkInventory.CrossClient.GetCVarBool( ... )
	if C_CVar then
		return C_CVar.GetCVarBool( ... )
	else
		return GetCVarBool( ... )
	end
end



ArkInventory.Const.BLIZZARD.CLIENT.NAME = _G[string.format( "EXPANSION_NAME%s", GetExpansionLevel( ) )]
local a = string.lower( ArkInventory.CrossClient.GetCVar( "agentuid" ) )
local p = string.lower( ArkInventory.CrossClient.GetCVar( "portal" ) )

ArkInventory.CrossClient.TemplateVersion = 1

if WOW_PROJECT_ID == ( WOW_PROJECT_MAINLINE or 1 ) then
	if string.match( a, "beta" ) then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL_BETA
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: Beta", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	elseif string.match( a, "ptr" ) or p == "test" then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL_PTR
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: PTR", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	else
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL
	end
elseif WOW_PROJECT_ID == ( WOW_PROJECT_CLASSIC or 2 ) then
	ArkInventory.CrossClient.TemplateVersion = 2
	if string.match( a, "beta" ) then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC_BETA
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: Beta", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	elseif string.match( a, "ptr" ) or p == "test" then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC_PTR
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: PTR", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	else
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC
	end
elseif WOW_PROJECT_ID == ( WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5 ) then
	ArkInventory.CrossClient.TemplateVersion = 2
	if string.match( a, "beta" ) then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.TBC_BETA
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: Beta", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	elseif string.match( a, "ptr" ) or p == "test" then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.TBC_PTR
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: PTR", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	else
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.TBC
	end
elseif WOW_PROJECT_ID == ( WOW_PROJECT_WRATH_CLASSIC or 11 ) then
	ArkInventory.CrossClient.TemplateVersion = 2
	if string.match( a, "beta" ) then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.WRATH_BETA
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: Beta", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	elseif string.match( a, "ptr" ) or p == "test" then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.WRATH_PTR
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: PTR", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	else
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.CODE.WRATH
	end
end

if ArkInventory.Const.BLIZZARD.CLIENT.ID == "" then
	ArkInventory.OutputError( "code error: unable to determine game client, please contact the author with the following data: project=[", WOW_PROJECT_ID, "], agent=[", a, "], portal=[", p, "]")
end


function ArkInventory.ClientCheck( id, toc_min, toc_max )
	
--	ArkInventory.Output2( "----- ----- ------" )
--	ArkInventory.Output2( "check = ", id, " - ", type( id ) )
	
	if type( id ) == "boolean" then return id end
	
	if type( id ) ~= "string" then
		--ArkInventory.OutputError( "code error: id [", id, "] is not a string" )
		--assert(false,"barf here")
		return true
	end
	
	local ok = false
	for code in pairs( ArkInventory.Const.BLIZZARD.CLIENT.CODE ) do
		if id == code then
			ok = true
			break
		end
	end
	
	if not ok then
		ArkInventory.OutputError( "code error: id [", id, "] is not a valid code" )
		assert(false,"barf here")
		return true
	end
	
--	ArkInventory.Output2( "id = ", ArkInventory.Const.BLIZZARD.CLIENT.ID )
	
	if id == string.sub( ArkInventory.Const.BLIZZARD.CLIENT.ID, 1, string.len( id ) ) then
--		ArkInventory.Output2( "ok: ", id, " == ", string.sub( ArkInventory.Const.BLIZZARD.CLIENT.ID, 1, string.len( id ) ) )
		
		if ( not toc_min or ArkInventory.Const.BLIZZARD.TOC >= toc_min ) and ( not toc_max or ArkInventory.Const.BLIZZARD.TOC <= toc_max ) then
			--ArkInventory.Output2( "Client is correct and TOC is ok ", toc_min, " > ", ArkInventory.Const.BLIZZARD.TOC, " < ", toc_max  )
			return true
		else
			--ArkInventory.Output2( "Client is correct but TOC is out of bounds ", toc_min, " > ", ArkInventory.Const.BLIZZARD.TOC, " < ", toc_max  )
			return false
		end
		
	end
	
--	ArkInventory.Output2( "Client is incorrect, meant for ", id )
	
	return false
	
end
