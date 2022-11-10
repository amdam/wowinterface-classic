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
		return ArkInventory.CrossClient.GetContainerNumSlots( ArkInventory.Const.ENUM.BAGINDEX.BANK )
	end
end

function ArkInventory.CrossClient.IsAnimaItemByID( ... )
	if C_Item and C_Item.IsAnimaItemByID then
		return C_Item.IsAnimaItemByID( ... )
	end
end

function ArkInventory.CrossClient.GetProfessions( ... )
	
	local info = { }
	if GetProfessions then
		info = { GetProfessions( ... ) }
	else
		local good = false
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
					--ArkInventory.Output( "info[", skillnum, "] = ", k, " [", name, "]" )
					info[skillnum] = k
				end
				
			end
		end
		
	end
	
	return info
	
end

function ArkInventory.CrossClient.GetProfessionInfo( index )
	
	local info = { }
	
	if GetProfessionInfo then
		
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier = GetProfessionInfo( index )
		info.name = name
		info.texture = texture
		info.rank = rank
		info.rankMax = maxRank
		info.numSpells = numSpells
		info.spellOffset = spelloffset
		info.skillLine = skillLine
		info.rankModifier = rankModifier
		
	elseif GetSkillLineInfo then
		
		local name, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType = GetSkillLineInfo( index )
		
		for k, v in pairs( ArkInventory.Const.Tradeskill.Data ) do
			if v.text == name then
				--ArkInventory.Output( "skill [", index, "] found [", name, "]=[", k, "]" )
				info.name = name
				info.texture = ""
				info.rank = skillRank
				info.rankMax = skillMaxRank
				info.numSpells = 0
				info.spellOffset = 0
				info.skillLine = k
				info.rankModifier = 0
				break
			end
		end
		
	end
	
	return info
	
end

function ArkInventory.CrossClient.UIGetProfessionInfo( )
	
	-- get the profession that the tradeskill window was set for
	
	local info = { }
	
	if C_TradeSkillUI and C_TradeSkillUI.GetChildProfessionInfo then
		
		info = C_TradeSkillUI.GetChildProfessionInfo( )
		
	elseif C_TradeSkillUI and C_TradeSkillUI.GetTradeSkillLine then
		
		local tradeSkillID, skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier, parentSkillLineID, parentSkillLineName =  C_TradeSkillUI.GetTradeSkillLine( )
		info.skillLevel = skillLineRank
		info.maxSkillLevel = skillLineMaxRank
		info.professionID = tradeSkillID
		info.parentProfessionID = parentSkillLineID
		info.skillModifier = skillLineModifier
		info.professionName = skillLineName
		info.parentProfessionName = parentSkillLineName
		--info.profession = 
		--info.isPrimaryProfession = 
		
	end
	
	return info
	
end

function ArkInventory.CrossClient.GetItemReagentQuality( ... )
	if C_TradeSkillUI and C_TradeSkillUI.GetItemReagentQualityByItemInfo then
		return C_TradeSkillUI.GetItemReagentQualityByItemInfo( ... )
	end
end

function ArkInventory.CrossClient.GetItemCraftedQuality( ... )
	if C_TradeSkillUI and C_TradeSkillUI.GetItemCraftedQualityByItemInfo then
		return C_TradeSkillUI.GetItemCraftedQualityByItemInfo( ... )
	end
end

function ArkInventory.CrossClient.SetSortBagsRightToLeft( ... )
	if SetSortBagsRightToLeft then
		return SetSortBagsRightToLeft( ... )
	end
end

function ArkInventory.CrossClient.GetContainerItemQuestInfo( i, ... )
	
	local info = { }
	
	if C_Container and C_Container.GetContainerItemQuestInfo then
		info = C_Container.GetContainerItemQuestInfo( ... )
	elseif GetContainerItemQuestInfo then
		local questitem, questid, active = GetContainerItemQuestInfo( ... )
		info.isQuestItem = questitem
		info.questID = questid
		info.isActive = active
	else
		if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Quest.Start" ) then
			info.isQuestItem = true
			info.questID = true
			info.isActive = false
		end
	end
	
	return info
	
end

function ArkInventory.CrossClient.IsReagentBankUnlocked( ... )
	if IsReagentBankUnlocked then
		return IsReagentBankUnlocked( ... )
	end
end

function ArkInventory.CrossClient.IsItemArtifactPower( ... )
	if IsArtifactPowerItem then
		return IsArtifactPowerItem( ... )
	end
end

function ArkInventory.CrossClient.IsItemAzeriteEmpowered( ... )
	if C_AzeriteEmpoweredItem and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID then
		return C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID( ... )
	end
end

function ArkInventory.CrossClient.IsItemCorrupted( ... )
	if IsCorruptedItem then
		return IsCorruptedItem( ... )
	end
end

function ArkInventory.CrossClient.IsItemCosmetic( ... )
	if IsCosmeticItem then
		return IsCosmeticItem( ... )
	end
end

function ArkInventory.CrossClient.IsConduit( ... )
	if C_Soulbinds and C_Soulbinds.IsItemConduitByItemInfo then
		return C_Soulbinds.IsItemConduitByItemInfo( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyInfo( ... )
	
	local info = { }
	
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
		info = C_CurrencyInfo.GetCurrencyInfo( ... )
	elseif GetCurrencyInfo then
		local name, quantity, icon, quantityEarnedThisWeek, maxWeeklyQuantity, maxQuantity, discovered, quality = GetCurrencyInfo( ... )
--		info.canEarnPerWeek
--		info.description
--		info.isShowInBackpack
		info.iconFileID = icon
--		info.isHeader
--		info.isTypeUnused
		info.discovered = discovered
		info.quality = quality
		info.quantityEarnedThisWeek = quantityEarnedThisWeek
--		info.isHeaderExpanded
--		info.isTradeable
--		info.totalEarned
		info.quantity = quantity
		info.name = name
		info.maxWeeklyQuantity = maxWeeklyQuantity
--		info.useTotalEarnedForMaxQty
		info.maxQuantity = maxQuantity
--		info.trackedQuantity
	end
	
	return info
	
end

function ArkInventory.CrossClient.GetCurrencyLink( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyLink then
		return C_CurrencyInfo.GetCurrencyLink( ... )
	elseif GetCurrencyLink then
		return GetCurrencyLink( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyListSize( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListSize then
		return C_CurrencyInfo.GetCurrencyListSize( ... )
	elseif GetCurrencyListSize then
		return GetCurrencyListSize( ... )
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
	
	local info = { }
	
	if C_CurrencyInfo and C_CurrencyInfo.GetBackpackCurrencyInfo then
		info = C_CurrencyInfo.GetBackpackCurrencyInfo( ... )
	elseif GetBackpackCurrencyInfo then
		local name, quantity, icon, typesid = GetBackpackCurrencyInfo( ... )
		info.name = name
		info.quantity = quantity
		info.iconFileID = icon
		info.currencyTypesID = typesid
	end
	
	return info
	
end

function ArkInventory.CrossClient.GetCurrencyListLink( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListLink then
		return C_CurrencyInfo.GetCurrencyListLink( ... )
	elseif GetCurrencyListLink then
		return GetCurrencyListLink( ... )
	end
end

function ArkInventory.CrossClient.SetCurrencyUnused( ... )
	if C_CurrencyInfo and C_CurrencyInfo.SetCurrencyUnused then
		return C_CurrencyInfo.SetCurrencyUnused( ... )
	elseif SetCurrencyUnused then
		return SetCurrencyUnused( ... )
	end
end

function ArkInventory.CrossClient.ExpandCurrencyList( ... )
	if C_CurrencyInfo and C_CurrencyInfo.ExpandCurrencyList then
		return C_CurrencyInfo.ExpandCurrencyList( ... )
	elseif ExpandCurrencyList then
		return ExpandCurrencyList( ... )
	end
end

function ArkInventory.CrossClient.GetFriendshipReputation( ... )
	if GetFriendshipReputation then
		return GetFriendshipReputation( ... )
	end
end

function ArkInventory.CrossClient.IsFactionParagon( ... )
	if C_Reputation and C_Reputation.IsFactionParagon then
		return C_Reputation.IsFactionParagon( ... )
	end
end

function ArkInventory.CrossClient.GetCVar( ... )
	if C_CVar and C_CVar.GetCVar then
		return C_CVar.GetCVar( ... )
	elseif GetCVar then
		return GetCVar( ... )
	end
end

function ArkInventory.CrossClient.SetCVar( ... )
	if C_CVar and C_CVar.SetCVar then
		return C_CVar.SetCVar( ... )
	elseif SetCVar then
		return SetCVar( ... )
	end
end

function ArkInventory.CrossClient.GetCVarBool( ... )
	if C_CVar and C_CVar.GetCVarBool then
		return C_CVar.GetCVarBool( ... )
	elseif GetCVarBool then
		return GetCVarBool( ... )
	end
end

function ArkInventory.CrossClient.GetBagSlotFlag( ... )
	if C_Container and C_Container.GetBagSlotFlag then
		return C_Container.GetBagSlotFlag( ... )
	elseif GetBagSlotFlag then
		return GetBagSlotFlag( ... )
	end
end

function ArkInventory.CrossClient.SetBagSlotFlag( ... )
	if C_Container and C_Container.SetBagSlotFlag then
		return C_Container.SetBagSlotFlag( ... )
	elseif SetBagSlotFlag then
		return SetBagSlotFlag( ... )
	end
end

function ArkInventory.CrossClient.GetBankBagSlotFlag( ... )
	if C_Container and C_Container.GetBagSlotFlag then
		return C_Container.GetBagSlotFlag( ... )
	elseif GetBankBagSlotFlag then
		return GetBankBagSlotFlag( ... )
	end
end

function ArkInventory.CrossClient.SetBankBagSlotFlag( ... )
	if C_Container and C_Container.SetBagSlotFlag then
		return C_Container.SetBagSlotFlag( ... )
	elseif SetBankBagSlotFlag then
		return SetBankBagSlotFlag( ... )
	end
end

function ArkInventory.CrossClient.SetBackpackAutosortDisabled( ... )
	if C_Container and C_Container.SetBackpackAutosortDisabled then
		return C_Container.SetBackpackAutosortDisabled( ... )
	elseif SetBackpackAutosortDisabled then
		return SetBackpackAutosortDisabled( ... )
	end
end

function ArkInventory.CrossClient.SetBankAutosortDisabled( ... )
	if C_Container and C_Container.SetBankAutosortDisabled then
		return C_Container.SetBankAutosortDisabled( ... )
	elseif SetBankAutosortDisabled then
		return SetBankAutosortDisabled( ... )
	end
end

function ArkInventory.CrossClient.EnumerateBagGearFilters( ... )
	if ContainerFrameUtil_EnumerateBagGearFilters then
		return ContainerFrameUtil_EnumerateBagGearFilters( ... )
	else
		local bagGearFilters = {
			LE_BAG_FILTER_FLAG_EQUIPMENT,
			LE_BAG_FILTER_FLAG_CONSUMABLES,
			LE_BAG_FILTER_FLAG_TRADE_GOODS,
		}
		return ipairs( bagGearFilters )
	end
end

function ArkInventory.CrossClient.OptionNotAvailableExpansion( check, text )
	local disabled = not not check
	local text = text
	if disabled then
		text = string.format( "%s\n\n%s%s", text, RED_FONT_COLOR_CODE, ArkInventory.Localise["OPTION_NOT_AVILABLE_EXPANSION"] )
	end
	return disabled, text
end

function ArkInventory.CrossClient.GetContainerNumSlots( ... )
	if C_Container and C_Container.GetContainerNumSlots then
		return C_Container.GetContainerNumSlots( ... )
	elseif GetContainerNumSlots then
		return GetContainerNumSlots( ... )
	end
end

function ArkInventory.CrossClient.ContainerIDToInventoryID( ... )
	if C_Container and C_Container.ContainerIDToInventoryID then
		return C_Container.ContainerIDToInventoryID( ... )
	elseif ContainerIDToInventoryID then
		return ContainerIDToInventoryID( ... )
	end
end

function ArkInventory.CrossClient.GetContainerItemInfo( ... )
	
	local info = { }
	
	if C_Container and C_Container.GetContainerItemInfo then
		info = C_Container.GetContainerItemInfo( ... )
	elseif GetContainerItemInfo then
		local icon, count, locked, quality, readable, lootable, hyperlink, filtered, novalue, itemid, bound = GetContainerItemInfo( ... )
		info.iconFileID = icon
		info.stackCount = count
		info.isLocked = locked
		info.quality = quality
		info.isReadable = readable
		info.hasLoot = lootable
		info.hyperlink = hyperlink
		info.isFiltered = filtered
		info.hasNoValue = novalue
		info.itemID = itemid
		info.isBound = bound
	end
	
	if not info then
		info = { }
	end
	
	info.quality = info.quality or ArkInventory.Const.ENUM.ITEMQUALITY.POOR
	info.stackCount = info.stackCount or 1
	
	return info
	
end

function ArkInventory.CrossClient.IsBattlePayItem( ... )
	if C_Container and C_Container.IsBattlePayItem then
		return C_Container.IsBattlePayItem( ... )
	elseif IsBattlePayItem then
		return IsBattlePayItem( ... )
	end
end

function ArkInventory.CrossClient.GetContainerItemCooldown( ... )
	if C_Container and C_Container.GetContainerItemCooldown then
		return C_Container.GetContainerItemCooldown( ... )
	elseif GetContainerItemCooldown then
		return GetContainerItemCooldown( ... )
	end
end

function ArkInventory.CrossClient.GetContainerFreeSlots( ... )
	if C_Container and C_Container.GetContainerFreeSlots then
		return C_Container.GetContainerFreeSlots( ... )
	elseif GetContainerFreeSlots then
		return GetContainerFreeSlots( ... )
	end
end

function ArkInventory.CrossClient.GetContainerNumFreeSlots( ... )
	-- return the number of free slots, and the bag type
	if C_Container and C_Container.GetContainerNumFreeSlots then
		local f, t = C_Container.GetContainerNumFreeSlots( ... )
		if f == 0 and not t then
			f = #ArkInventory.CrossClient.GetContainerFreeSlots( ... )
			t = 0
		end
		return f, t
	elseif GetContainerNumFreeSlots then
		return GetContainerNumFreeSlots( ... )
	end
end

function ArkInventory.CrossClient.PickupContainerItem( ... )
	if C_Container and C_Container.PickupContainerItem then
		return C_Container.PickupContainerItem( ... )
	elseif PickupContainerItem then
		return PickupContainerItem( ... )
	end
end

function ArkInventory.CrossClient.UseContainerItem( ... )
	if C_Container and C_Container.UseContainerItem then
		return C_Container.UseContainerItem( ... )
	elseif UseContainerItem then
		return UseContainerItem( ... )
	end
end

function ArkInventory.CrossClient.SortBags( ... )
	if C_Container and C_Container.SortBags then
		return C_Container.SortBags( ... )
	elseif SortBags then
		return SortBags( ... )
	end
end

function ArkInventory.CrossClient.SortBankBags( ... )
	if C_Container and C_Container.SortBankBags then
		return C_Container.SortBankBags( ... )
	elseif SortBankBags then
		return SortBankBags( ... )
	end
end

function ArkInventory.CrossClient.SortReagentBankBags( ... )
	if C_Container and C_Container.SortReagentBankBags then
		return C_Container.SortReagentBankBags( ... )
	elseif SortReagentBankBags then
		return SortReagentBankBags( ... )
	end
end

function ArkInventory.CrossClient.GetInsertItemsLeftToRight( ... )
	if C_Container and C_Container.GetInsertItemsLeftToRight then
		return C_Container.GetInsertItemsLeftToRight( ... )
	elseif GetInsertItemsLeftToRight then
		return GetInsertItemsLeftToRight( ... )
	end
end

function ArkInventory.CrossClient.SetInsertItemsLeftToRight( ... )
	if C_Container and C_Container.SetInsertItemsLeftToRight then
		return C_Container.SetInsertItemsLeftToRight( ... )
	elseif SetInsertItemsLeftToRight then
		return SetInsertItemsLeftToRight( ... )
	end
end

function ArkInventory.CrossClient.ClearItemOverlays( frame )
	
	local overlayKeys = { "IconOverlay", "IconOverlay2", "ProfessionQualityOverlay" }
	for _, key in pairs( overlayKeys ) do
		local overlay = frame[key]
		if overlay then
			overlay:SetVertexColor( 1, 1, 1 )
			overlay:SetAtlas( nil )
			overlay:SetTexture( nil )
			overlay:Hide( )
		end
	end
	
	
	frame.isProfessionItem = false
	frame.isCraftedItem = false
	
end

function ArkInventory.CrossClient.ShowContainerSellCursor( ... )
	if C_Container and C_Container.ShowContainerSellCursor then
		return C_Container.ShowContainerSellCursor( ... )
	elseif ShowContainerSellCursor then
		return ShowContainerSellCursor( ... )
	end
end

function ArkInventory.CrossClient.PlayerHasTransmogByItemInfo( ... )
	if C_TransmogCollection and C_TransmogCollection.PlayerHasTransmogByItemInfo then
		return C_TransmogCollection.PlayerHasTransmogByItemInfo( ... )
	end
end















ArkInventory.Const.BLIZZARD.CLIENT.NAME = _G[string.format( "EXPANSION_NAME%s", GetExpansionLevel( ) )]
local a = string.lower( ArkInventory.CrossClient.GetCVar( "agentuid" ) )
local p = string.lower( ArkInventory.CrossClient.GetCVar( "portal" ) )

ArkInventory.CrossClient.TemplateVersion = 1

for k,v in pairs( ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION ) do
	--ArkInventory.Output( k, " = ", v )
	if ArkInventory.Const.BLIZZARD.TOC >= v.TOC.MIN and ArkInventory.Const.BLIZZARD.TOC <= v.TOC.MAX then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = v.ID
		break
	end
end
ArkInventory.Const.ENUM.EXPANSION.CURRENT = ArkInventory.Const.BLIZZARD.CLIENT.ID

if ArkInventory.Const.BLIZZARD.CLIENT.ID <= ArkInventory.Const.ENUM.EXPANSION.WRATH then
	ArkInventory.CrossClient.TemplateVersion = 2
end

if ArkInventory.Const.BLIZZARD.CLIENT.ID == nil then
	ArkInventory.OutputError( "code error: unable to determine game client, please contact the author with the following client data: project=[", WOW_PROJECT_ID, "], agent=[", a, "], portal=[", p, "] TOC=[", ArkInventory.Const.BLIZZARD.TOC, "]")
else
	if string.match( a, "beta" ) then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.ID + ArkInventory.Const.BLIZZARD.CLIENT.BETA
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: Beta", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	elseif string.match( a, "ptr" ) or p == "test" then
		ArkInventory.Const.BLIZZARD.CLIENT.ID = ArkInventory.Const.BLIZZARD.CLIENT.ID + ArkInventory.Const.BLIZZARD.CLIENT.PTR
		ArkInventory.Const.BLIZZARD.CLIENT.NAME = string.format( "%s: PTR", ArkInventory.Const.BLIZZARD.CLIENT.NAME )
	end
end


function ArkInventory.ClientCheck( id_toc_min, id_toc_max, loud )
	
	if type( id_toc_min ) == "boolean" then return id_toc_min end
	
	local tmin = id_toc_min or ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.Const.ENUM.EXPANSION.CLASSIC].TOC.MIN
	if tmin < ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.Const.ENUM.EXPANSION.CLASSIC].TOC.MIN then
		tmin = ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[tmin].TOC.MIN or ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.Const.ENUM.EXPANSION.CLASSIC].TOC.MIN
	end
	
	local tmax = id_toc_max or ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.Const.ENUM.EXPANSION.CURRENT].TOC.MAX
	if tmax < ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.Const.ENUM.EXPANSION.CLASSIC].TOC.MIN then
		tmax = ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[tmax].TOC.MAX or ArkInventory.Const.BLIZZARD.CLIENT.EXPANSION[ArkInventory.Const.ENUM.EXPANSION.CURRENT].TOC.MAX
	end
	
	if loud then
		ArkInventory.Output( ArkInventory.Const.BLIZZARD.TOC, " / ", tmin, " / ", tmax )
	end
	
	if ArkInventory.Const.BLIZZARD.TOC >= tmin and ArkInventory.Const.BLIZZARD.TOC <= tmax then
		return true
	end
	
	return false
	
end
