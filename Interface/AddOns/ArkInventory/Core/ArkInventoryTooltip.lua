local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table

-- stuff to look at later? maybe
-- BattlePetTooltipTemplate_AddTextLine


local MissingFunctions = { }

local supportedHyperlinkClass = {
	["item"] = true,
	["spell"] = true,
	["currency"] = true,
	["reputation"] = true,
	["battlepet"] = true,
	["keystone"] = true,
	["enchant"] = true,
}

ArkInventory.Const.BLIZZARD.TooltipFunctions = {
	
	-- function name = project id
	
	["SetText"] = true,
	["ClearLines"] = true,
	["FadeOut"] = true,
	
	["SetItemKey"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetAuctionItem"] = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetAuctionSellItem"] = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetBagItem"] = true,
	["SetBackpackToken"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetBuybackItem"] = true,
	["SetCurrencyByID"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetCurrencyToken"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetCurrencyTokenByID"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetCraftItem"] = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetCraftSpell"] = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetGuildBankItem"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetHeirloomByItemID"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetHyperlink"] = true,
	["SetInboxItem"] = true,
	["SetInventoryItem"] = true,
	["SetItemByID"] = true,
	["SetLootCurrency"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetLootItem"] = true,
	["SetLootRollItem"] = true,
	["SetMerchantItem"] = true,
	["SetMerchantCostItem"] = true,
	["SetQuestCurrency"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetQuestItem"] = true,
	["SetQuestLogCurrency"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetQuestLogItem"] = true,
--	["SetQuestLogRewardSpell"] = true, -- seems pointless tracking a spell when i cant track it back to something
	["SetQuestLogSpecialItem"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
--	["SetQuestRewardSpell"] = true, -- seems pointless tracking a spell when i cant track it back to something
	["SetRecipeReagentItem"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetRecipeResultItem"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetSendMailItem"] = true,
	["SetToyByItemID"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetTradePlayerItem"] = true,
	["SetTradeSkillItem"] = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetTradeTargetItem"] = true,
--	["SetUnit"] = false, --  > conflicts with OnSetUnit, do NOT use
	["SetVoidItem"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetVoidDepositItem"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	["SetVoidWithdrawalItem"] = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
	
}

function ArkInventory.TooltipTextToNumber( v )
	if type( v ) == "number" then
		return v
	elseif type( v ) == "string" then
		local sep = string.gsub( LARGE_NUMBER_SEPERATOR, ".", "%%%1" )
		--ArkInventory.Output("LARGE_NUMBER_SEPERATOR=[", LARGE_NUMBER_SEPERATOR, "] [", sep, "]")
		return tonumber( ( string.gsub( v, sep, "" ) ) )
	end
end

function ArkInventory.GameTooltipHide( )
	--GameTooltip:ClearLines( )
	GameTooltip:Hide( )
end

function ArkInventory.GameTooltipSetPosition( frame, bottom )
	
	local frame = frame or UIParent
	GameTooltip:SetOwner( frame, "ANCHOR_NONE" )
	
	local anchorFromLeft = frame:GetLeft( ) + ( frame:GetRight( ) - frame:GetLeft( ) ) / 2 < GetScreenWidth( ) / 2
	
	if frame == UIParent then
		GameTooltip:ClearAllPoints( )
		GameTooltip:SetAnchorType( "ANCHOR_BOTTOMRIGHT" )
	elseif bottom then
		if anchorFromLeft then
			GameTooltip:SetAnchorType( "ANCHOR_BOTTOMRIGHT" )
		else
			GameTooltip:SetAnchorType( "ANCHOR_BOTTOMLEFT" )
		end
	else
		if anchorFromLeft then
			GameTooltip:SetAnchorType( "ANCHOR_RIGHT" )
		else
			GameTooltip:SetAnchorType( "ANCHOR_LEFT" )
		end
	end
	
end

function ArkInventory.GameTooltipSetText( frame, txt, r, g, b, bottom )
	ArkInventory.GameTooltipSetPosition( frame, bottom )
	GameTooltip:SetText( txt or "text is missing", r or 1, g or 1, b or 1 )
	GameTooltip:Show( )
end

function ArkInventory.GameTooltipSetHyperlink( frame, h )
	ArkInventory.GameTooltipSetPosition( frame )
	ArkInventory.TooltipSetHyperlink( GameTooltip, h )
end


local function checkAbortShow( tooltip )
	
	if not tooltip then return true end
	if not ArkInventory:IsEnabled( ) then return true end
	
	if not ArkInventory.db.option.tooltip.show then return true end
	
end

local function checkAbortItemCount( tooltip )
	
	if checkAbortShow( tooltip ) then return true end
	
	if not ArkInventory.db.option.tooltip.itemcount.enable then
		return true
	end
	
end

function ArkInventory.TooltipCleanText( txt )
	
	local txt = txt or ""
	
	if type( txt ) == "table" then
		ArkInventory.OutputWarning( "TooltipCleanText: txt was a table [", txt, "]" )
		return
	end
	
	txt = ArkInventory.StripColourCodes( txt )
	
	txt = txt:gsub( '"', "" )
	txt = txt:gsub( "'", "" )
	
	txt = string.gsub( txt, "\194\160", " " ) -- i dont remember what this is for
	
	txt = string.gsub( txt, "%s", " " )
	txt = string.gsub( txt, "|n", " " )
	txt = string.gsub( txt, "\n", " " )
	txt = string.gsub( txt, "\13", " " )
	txt = string.gsub( txt, "\10", " " )
	txt = string.gsub( txt, "  ", " " )
	
	txt = string.trim( txt )
	
	return txt
	
end

function ArkInventory.TooltipScanInit( name )
	
	local tooltip = _G[name]
	assert( tooltip, string.format( "XML Frame [%s] not found", name ) )
	
	ArkInventory.TooltipMyDataClear( tooltip )
	tooltip.ARKTTD.scan = true
	
	return tooltip
	
end

function ArkInventory.TooltipGetNumLines( tooltip )
	return tooltip:NumLines( ) or 0
end

function ArkInventory.TooltipSetHyperlink( tooltip, h )
	
	tooltip:ClearLines( )
	
	--ArkInventory.Output2( "TooltipSetHyperlink( ", tooltip:GetName( ), ", ", h, " )" )
	
	if h then
		
		local osd = ArkInventory.ObjectStringDecode( h )
		
		if osd.class == "battlepet" then
			
			return ArkInventory.TooltipCustomBattlepetShow( tooltip, h )
			
		elseif osd.class == "reputation" then
			
			ArkInventory.TooltipSetCustomReputation( tooltip, h )
			
		elseif osd.class == "currency" then
			
			tooltip:SetCurrencyByID( osd.id, osd.amount )
			
		elseif osd.class == "copper" then
			
			SetTooltipMoney( tooltip, osd.amount )
			tooltip:Show( )
			
		elseif osd.class == "empty" then
			
			tooltip:ClearLines( )
			tooltip:Hide( )
			
		else
			
			tooltip:SetHyperlink( h )
			
		end
		
	end
	
end

function ArkInventory.TooltipSetBagItem( tooltip, blizzard_id, slot_id )
	
	tooltip:ClearLines( )
	
	local arg1, arg2, bp_SpeciesID, bp_Level, bp_BreedQuality, bp_MaxHealth, bp_Power, bp_Speed, bp_Name = tooltip:SetBagItem( blizzard_id, slot_id )
--	ArkInventory.Output2( { tooltip:SetBagItem( blizzard_id, slot_id ) } )
	
	if bp_SpeciesID and bp_SpeciesID > 0 then
--		ArkInventory.Output2( "[", bp_SpeciesID, "] [", bp_Level, "] [", bp_BreedQuality, "] [", bp_MaxHealth, "] [", bp_Power, "] [", bp_Speed, "] [", bp_Name, "]" )
		local h = ArkInventory.BattlepetBaseHyperlink( bp_SpeciesID, bp_Level, bp_BreedQuality, bp_MaxHealth, bp_Power, bp_Speed, bp_Name )
		ArkInventory.TooltipCustomBattlepetBuild( tooltip, h )
		return h, bp_SpeciesID, bp_Level, bp_BreedQuality, bp_MaxHealth, bp_Power, bp_Speed, bp_Name
	end
	
end

function ArkInventory.TooltipSetInventoryItem( tooltip, inv_id )
	
	tooltip:ClearLines( )
	
	local arg1, arg2, arg3, bp_SpeciesID, bp_Level, bp_BreedQuality, bp_MaxHealth, bp_Power, bp_Speed, bp_Name = tooltip:SetInventoryItem( "player", inv_id )
--	ArkInventory.Output2( { tooltip:SetInventoryItem( "player", inv_id ) } )
	
	if bp_SpeciesID and bp_SpeciesID > 0 then
--		ArkInventory.Output2( "[", bp_SpeciesID, "] [", bp_Level, "] [", bp_BreedQuality, "] [", bp_MaxHealth, "] [", bp_Power, "] [", bp_Speed, "] [", bp_Name, "]" )
		local h = ArkInventory.BattlepetBaseHyperlink( bp_SpeciesID, bp_Level, bp_BreedQuality, bp_MaxHealth, bp_Power, bp_Speed, bp_Name )
		ArkInventory.TooltipCustomBattlepetBuild( tooltip, h )
		return h, bp_SpeciesID, bp_Level, bp_BreedQuality, bp_MaxHealth, bp_Power, bp_Speed, bp_Name
	end
	
end

function ArkInventory.TooltipSetGuildBankItem( tooltip, tab_id, slot_id )
	
	tooltip:ClearLines( )
	
	local bp_SpeciesID, bp_Level, bp_BreedQuality, bp_MaxHealth, bp_Power, bp_Speed, bp_Name = tooltip:SetGuildBankItem( tab_id, slot_id )
--	ArkInventory.Output2( { tooltip:SetGuildBankItem( tab_id, slot_id ) } )
	
	if bp_SpeciesID and bp_SpeciesID > 0 then
--		ArkInventory.Output2( "[", bp_SpeciesID, "] [", bp_Level, "] [", bp_BreedQuality, "] [", bp_MaxHealth, "] [", bp_Power, "] [", bp_Speed, "] [", bp_Name, "]" )
		local h = ArkInventory.BattlepetBaseHyperlink( bp_SpeciesID, bp_Level, bp_BreedQuality, bp_MaxHealth, bp_Power, bp_Speed, bp_Name )
		ArkInventory.TooltipCustomBattlepetBuild( tooltip, h )
		return h, bp_SpeciesID, bp_Level, bp_BreedQuality, bp_MaxHealth, bp_Power, bp_Speed, bp_Name
	end
	
end

function ArkInventory.TooltipSetMailboxItem( tooltip, msg_id, att_id )
	
	tooltip:ClearLines( )
	
	-- battlepet returns start at # 2
	return select( 2, tooltip:SetInboxItem( msg_id, att_id ) )
	
end

function ArkInventory.TooltipSetItem( tooltip, loc_id, bag_id, slot_id, h, i )
	
	-- where possible this will generate an online tooltip, but if that is not possible then an offline tooltip will be generated instead
	
	local tooltip = tooltip or ArkInventory.Global.Tooltip.Scan
	
	if loc_id then
		
		local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( loc_id, bag_id )
		
		if loc_id == ArkInventory.Const.Location.Bag then
			
			if blizzard_id and slot_id then
				return ArkInventory.TooltipSetBagItem( tooltip, blizzard_id, slot_id )
			end
			
		elseif loc_id == ArkInventory.Const.Location.Bank and ArkInventory.Global.Mode.Bank then
			
			if blizzard_id == BANK_CONTAINER then
				
				local inv_id = BankButtonIDToInvSlotID( slot_id )
				if inv_id then
					return ArkInventory.TooltipSetInventoryItem( tooltip, inv_id )
				end
				
			elseif blizzard_id == REAGENTBANK_CONTAINER then
				
				local inv_id = ReagentBankButtonIDToInvSlotID( slot_id )
				if inv_id then
					return ArkInventory.TooltipSetInventoryItem( tooltip, inv_id )
				end
				
			else
				
				if blizzard_id and slot_id then
					return ArkInventory.TooltipSetBagItem( tooltip, blizzard_id, slot_id )
				end
				
			end
			
		elseif loc_id == ArkInventory.Const.Location.Vault and ArkInventory.Global.Mode.Vault then
			
			if bag_id and slot_id then
				return ArkInventory.TooltipSetGuildBankItem( tooltip, bag_id, slot_id )
			end
			
		elseif loc_id == ArkInventory.Const.Location.Mailbox and ArkInventory.Global.Mode.Mailbox then
			
			if i and i.msg_id and i.att_id then
				ArkInventory.TooltipSetMailboxItem( tooltip, i.msg_id, i.att_id )
				return
			end
			
		elseif loc_id == ArkInventory.Const.Location.Wearing then
			
			local inv_id = GetInventorySlotInfo( ArkInventory.Const.InventorySlotName[slot_id] )
			if inv_id then
				return ArkInventory.TooltipSetInventoryItem( tooltip, inv_id )
			end
			
		elseif loc_id == ArkInventory.Const.Location.Keyring then
			
			local inv_id = KeyRingButtonIDToInvSlotID( slot_id )
			if inv_id then
				return ArkInventory.TooltipSetInventoryItem( tooltip, inv_id )
			end
			
		end
		
	end
	
	if h then
		ArkInventory.TooltipSetHyperlink( tooltip, h )
		return
	end
	
end

function ArkInventory.TooltipSetCustomReputation( tooltip, h )
	
	if checkAbortShow( tooltip ) then return true end
	
	if not h then return end
	
	local osd = ArkInventory.ObjectStringDecode( h )
	
	if osd.class ~= "reputation" then return end
	
	tooltip:ClearLines( )
	
	local data = ArkInventory.Collection.Reputation.GetByID( osd.id )
	if not data then
		
		tooltip:AddLine( string.format( ArkInventory.Localise["UNKNOWN_OBJECT"], h ) )
		
	else
		
		tooltip:AddLine( data.name )
		
		if ArkInventory.db.option.tooltip.reputation.description and ( data.description and data.description ~= "" ) then
			tooltip:AddLine( data.description, 1, 1, 1, true )
		end
		
		tooltip:AddLine( " " )
		
		local style_default = ArkInventory.Const.Reputation.Style.TooltipNormal
		local style = style_default
		if ArkInventory.db.option.tooltip.reputation.custom ~= ArkInventory.Const.Reputation.Custom.Default then
			style = ArkInventory.db.option.tooltip.reputation.style.normal
			if string.trim( style ) == "" then
				style = style_default
			end
		end
		local txt = ArkInventory.Collection.Reputation.LevelText( osd.id, style )
		tooltip:AddDoubleLine( "", txt, 1, 1, 1, 1, 1, 1 )
		
	end
	
	tooltip:Show( )
	
	ArkInventory.TooltipAddItemCount( tooltip, h )
	
	ArkInventory.API.CustomReputationTooltipReady( tooltip, h )
	
	local fn = "TooltipSetCustomReputation"
	ArkInventory.TooltipMyDataSave( tooltip, fn, h )
	
end

function ArkInventory.TooltipAddCustomReputationToCharacterFrame( frame )
	--[[
	ignore for now
	
	ArkInventory.Output2( "onenter ", frame )
	ArkInventory.Output2( "friend=", frame.friendshipID )
	ArkInventory.Output2( "hasrep=", frame.hasRep )
	ArkInventory.Output2( "collapsed=", frame.isCollapsed )
	]]--
	
	--[[
	if not frame then return end
	
	if frame.LFGBonusRepButton and frame.LFGBonusRepButton.factionID then
		
		local id = frame.LFGBonusRepButton.factionID
		ArkInventory.Output2( "faction=", id )
		
		local frame = _G[frame:GetName( ) .. "ReputationBarRight"]
		ArkInventory.GameTooltipSetPosition( frame )
		
		ArkInventory.GameTooltipSetText( " " )
		GameTooltip:Show( )
		
		ArkInventory.TooltipSetCustomReputation( GameTooltip, string.format( "reputatation:%s", id ) )
		
	end
	]]--
	
end

function ArkInventory.TooltipCustomBattlepetAddDetail( tooltip, speciesID, h, i )
	
--	test = check custom pet toltip
--	test = check unit tooltip (target a battle pet)
--	checked ok = 
	
	--ArkInventory.Output2( "TooltipCustomBattlepetAddDetail" )
	
	if not speciesID then return end
	
	local h = h or ( i and i.h ) or string.format( "battlepet:%s", speciesID )
	
	local sd = ArkInventory.Collection.Pet.GetSpeciesInfo( speciesID )
	if not sd then
		--ArkInventory.OutputWarning( "species data not found ", speciesID )
		return
	end
	if sd.isTrainer then
		-- this isnt a pet can obtain so no point checking if we have it
		return
	end
	
	ArkInventory.TooltipAddEmptyLine( tooltip )
	
	local numOwned, maxAllowed = C_PetJournal.GetNumCollectedInfo( speciesID )
	local info = ""
	
	if numOwned == 0 then
		info = ArkInventory.Localise["NOT_COLLECTED"]
	else
		info = string.format( ITEM_PET_KNOWN, numOwned, maxAllowed )
	end
	tooltip:AddLine( info )
	
	
	if checkAbortItemCount( tooltip ) then return end
	
	
	local tt = { }
	for _, pd in ArkInventory.Collection.Pet.Iterate( ) do
		if ( pd.sd.speciesID == speciesID ) then
			tt[#tt  + 1] = pd
		end
	end
	
	if ( i and numOwned > 1 ) or ( not i and numOwned > 0 ) then
		
		for k, pd in pairs( tt ) do
			
			info = ""
			
			if ArkInventory.Global.Mode.ColourBlind then
				info = string.format( "%s%s%s", info, _G[string.format( "ITEM_QUALITY%d_DESC", pd.quality )], "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:16:32:0:16|t" )
			else
				local qc = select( 5, ArkInventory.GetItemQualityColor( pd.quality ) )
				info = string.format( "%s%s%s|r%s", info, qc, _G[string.format( "ITEM_QUALITY%d_DESC", pd.quality )], "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:16:32:0:16|t" )
			end
			
			info = string.format( "%s  %s%s", info, pd.level, "|TInterface\\PetBattles\\BattleBar-AbilityBadge-Strong-Small:0|t" )
			
			if pd.sd.canBattle then
				
				local iconPetAlive = "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:16:32:16:32|t"
				local iconPetDead = "|TInterface\\Scenarios\\ScenarioIcon-Boss:0|t"
				if ( pd.health <= 0 ) then
					info = string.format( "%s  %.0f%s", info, pd.maxHealth, iconPetDead )
				else
					info = string.format( "%s  %.0f%s", info, pd.maxHealth, iconPetAlive )
				end
				
				info = string.format( "%s  %.0f%s", info, pd.power, "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:0:16:0:16|t" )
				info = string.format( "%s  %.0f%s", info, pd.speed, "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:0:16:16:32|t" )
				
				if pd.breed then
					info = string.format( "%s  %s", info, pd.breed )
				end
				
				if ( not i ) or ( i and i.guid ~= pd.guid ) then
					tooltip:AddLine( info )
				end
				
			end
			
		end
		
	end
	
	ArkInventory.TooltipAddItemCount( tooltip, h )
	
	ArkInventory.API.helper_CustomBattlePetTooltipReady( tooltip, h )
	
end

function ArkInventory.TooltipCustomBattlepetBuild( tooltip, h, i )
	
	if not tooltip then return true end
	if not ArkInventory:IsEnabled( ) then return true end
	if not h and not ( i and i.index ) then return end
	
--	test = check custom pet tooltip
--	checked ok = 
	
	--ArkInventory.Output2( "TooltipCustomBattlepetBuild: ", h )
	
	local pd = false
	local h = h
	
	if i and i.index then
		pd = ArkInventory.Collection.Pet.GetByID( i.index )
		h = pd.link
	end
	
	local osd = ArkInventory.ObjectStringDecode( h )
	if osd.class ~= "battlepet" then return end
	
	--ArkInventory.Output2( "[", osd.class, ":", osd.id, ":", osd.level, ":", osd.q, ":", osd.health, ":", osd.power, ":", osd.speed, ":", osd.cn, "]" )
	
	ArkInventory.Collection.Pet.GetSpeciesInfo( osd.id )
	local sd = ArkInventory.Collection.Pet.GetSpeciesInfo( osd.id )
	if not sd then
		--ArkInventory.OutputWarning( "no species data found for ", osd.id )
		return
	end
	
	local level = osd.level
	local quality = osd.q
	local health = osd.health
	local maxHealth = osd.health
	local power = osd.power
	local speed = osd.speed
	local name = sd.name
	local name2
	local breed = ""
	
	if pd then
		--ArkInventory.Output2( "using pet data ", pd )
		level = pd.level or level
		quality = pd.quality or quality
		health = pd.health or health
		maxHealth = pd.maxHealth or maxHealth
		power = pd.power or power
		speed = pd.speed or speed
		if pd.cn then
			name = pd.cn
			name2 = sd.name
		end
		breed = pd.breed or breed
	end
	
	local colour = select( 4, ArkInventory.GetItemQualityColor( quality ) )
	
	if sd.isTrainer then
		if sd.td then
			level = sd.td.level or level
			quality = sd.td.quality or quality
			colour = select( 4, ArkInventory.GetItemQualityColor( quality ) )
			health = sd.td.health or health
			maxHealth = sd.td.health or health
			power = sd.td.power or power
			speed = sd.td.speed or speed
			breed = sd.td.breed or breed
		else
			colour = sd.colour or colour
		end
		
	end
	
	colour = ArkInventory.CreateColour( colour )
	
	tooltip:ClearLines( )
	local txt1, txt2
	
	txt1 = string.format( "|T%s:32:32:-4:4:128:256:64:100:130:166|t %s", GetPetTypeTexture( sd.petType ), name )
	tooltip:AddLine( colour:WrapTextInColorCode( txt1 ) )
	
	if name2 then
		txt1 = string.format( "%s", name2 )
		tooltip:AddLine( colour:WrapTextInColorCode( txt1 ) )
		tooltip:AddLine( " " )
	end
	
	
	
	if ArkInventory.db.option.tooltip.battlepet.source then
		if sd.sourceText and sd.sourceText ~= "" then
			tooltip:AddLine( sd.sourceText, 1, 1, 1, true )
			tooltip:AddLine( " " )
		end
	end
	
	
	
	if ArkInventory.db.option.tooltip.battlepet.description and ( sd.description and sd.description ~= "" ) then
		tooltip:AddLine( sd.description, nil, nil, nil, true )
		tooltip:AddLine( " " )
	end
	
	
	
	txt1 = ArkInventory.Localise["TYPE"]
	txt2 = _G[string.format( "BATTLE_PET_NAME_%s", sd.petType )] or ArkInventory.Localise["UNKNOWN"]
	--txt2 = string.format( "%s |T%s:16:16:0:0:128:256:64:100:130:166|t", txt2, GetPetTypeTexture( sd.petType ) )
	tooltip:AddDoubleLine( txt1, txt2 )
	
	
	
	if level > 0 then
		
		
		txt1 = LEVEL
		txt2 = string.format( "%s %s", level, "|TInterface\\PetBattles\\BattleBar-AbilityBadge-Strong-Small:0|t" )
		if pd and pd.xp and pd.maxXp and pd.xp > 0 then
			
			local pc = math.floor( pd.xp / pd.maxXp * 100 )
			if pc < 1 then
				pc = 1
			elseif pc > 99 then
				pc = 99
			end
			
			txt1 = string.format( "%s (%d%%)", txt1, pc )
			
		end
		tooltip:AddDoubleLine( txt1, txt2 )
		
		
	end
		
		
		
	if sd.canBattle then
		
		
		if level > 0 then
			
			
			if health >= 0 then
				
				local iconPetAlive = "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:16:32:16:32|t"
				local iconPetDead = "|TInterface\\Scenarios\\ScenarioIcon-Boss:0|t"
				txt1 = PET_BATTLE_STAT_HEALTH
				txt2 = string.format( "%s %s", maxHealth, iconPetAlive )
				
				if health <= 0 then
					
					txt1 = string.format( "%s (%s)", txt1, DEAD )
					txt2 = string.format( "%s %s", maxHealth, iconPetDead )
					
				else
					
					if health ~= maxHealth then
						
						local pc = math.floor( health / maxHealth * 100 )
						if pc < 1 then
							pc = 1
						elseif pc > 99 then
							pc = 99
						end
						
						txt1 = string.format( "%s (%d%%)", txt1, pc )
						
					end
					
				end
				tooltip:AddDoubleLine( txt1, txt2 )
				
			end
			
			
			if power >= 0 then
				-- |TTexturePath:size1:size2:offset-x:offset-y:original-size-x:original-size-y:crop-x1:crop-x2:crop-y1:crop-y2|t
				tooltip:AddDoubleLine( PET_BATTLE_STAT_POWER, string.format( "%s %s", power, "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:0:16:0:16|t" ) )
			end
			
			
			if speed >= 0 then
				tooltip:AddDoubleLine( PET_BATTLE_STAT_SPEED, string.format( "%s %s", speed, "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:0:16:16:32|t" ) )
			end
			
			
			if quality >= 0 then
				-- ignore the -1, those will be from other peoples links and we cant get at that data
				txt1 = PET_BATTLE_STAT_QUALITY
				txt2 = "|TInterface\\PetBattles\\PetBattle-StatIcons:0:0:0:0:32:32:16:32:0:16|t"
				if ArkInventory.Global.Mode.ColourBlind then
					txt2 = string.format( "%s %s", _G[string.format( "ITEM_QUALITY%d_DESC", quality )], txt2 )
				else
					txt2 = string.format( "%s %s", colour:WrapTextInColorCode( _G[string.format( "ITEM_QUALITY%d_DESC", quality )] ), txt2 )
				end
				tooltip:AddDoubleLine( txt1, txt2 )
			end
			
			
		end
		
		
	elseif not sd.isTrainer then
		
		tooltip:AddLine( ArkInventory.Localise["PET_CANNOT_BATTLE"], RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true )
		
	end
	
	
	
	if not sd.isTrainer then
		
		if not sd.unique or not sd.isTradable then
			tooltip:AddLine( " " )
		end
		
		if sd.unique then
			tooltip:AddLine( ITEM_UNIQUE, WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b, true )
		end
		
		if not sd.isTradable then
			tooltip:AddLine( BATTLE_PET_NOT_TRADABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true )
		end
		
	end
	
end

function ArkInventory.TooltipCustomBattlepetShow( tooltip, h, i )
	
	if checkAbortShow( tooltip ) then return true end
	
	if not h then return end
	
	--ArkInventory.Output2( "TooltipCustomBattlepetShow" )
	
	ArkInventory.TooltipMyDataClear( tooltip )
	
	-- mouseover pet items, and clicking on pet links
	-- unit mouseover tooltip for wild and player pets is done at HookOnTooltipSetUnit, not here
	
	local osd = ArkInventory.ObjectStringDecode( h )
	
	if osd.class ~= "battlepet" then return end
	
	--ArkInventory.Output2( "[", osd.class, " : ", osd.id, " : ", osd.level, " : ", osd.q, " : ", osd.health, " : ", osd.power, " : ", osd.speed, "]" )
	
	if not ArkInventory.db.option.tooltip.battlepet.enable then
		BattlePetToolTip_Show( osd.id, osd.level, osd.q, osd.health, osd.power, osd.speed, osd.cn )
		return
	end
	
	local sd = ArkInventory.Collection.Pet.GetSpeciesInfo( osd.id )
	if not sd then
		--ArkInventory.OutputWarning( "no species data found for ", osd.id )
		return
	end
	
	ArkInventory.TooltipCustomBattlepetBuild( tooltip, h, i )
	
	tooltip:Show( )
	
	ArkInventory.TooltipCustomBattlepetAddDetail( tooltip, osd.id, h, i )
	
end

function ArkInventory.HookBattlePetToolTip_Show( ... )
	
	-- speciesID, level, breedQuality, maxHealth, power, speed, customName
	
	if not ArkInventory:IsEnabled( ) then return end
	if not ArkInventory.db.option.tooltip.show then return end
	if not ArkInventory.db.option.tooltip.battlepet.enable then return end
	
--	ArkInventory.Output2( "HookBattlePetToolTip_Show" )
	
	BattlePetTooltip:Hide( )
	
	local h = ArkInventory.BattlepetBaseHyperlink( ... )
	if h then
		
		-- anchor gametooltip to whatever originally called it
		ArkInventory.GameTooltipSetPosition( GetMouseFocus( ) )
		ArkInventory.TooltipCustomBattlepetShow( GameTooltip, h )
		
	end
	
end




function ArkInventory.TooltipGetMoneyFrame( tooltip )
	
	return _G[string.format( "%s%s", tooltip:GetName( ), "MoneyFrame1" )]
	
end

function ArkInventory.TooltipFindBackwards( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, maxDepth, searchMode )
	
	local TextToFind = ArkInventory.TooltipCleanText( TextToFind )
	if TextToFind == "" then
		return false
	end
	
	local IgnoreLeft = IgnoreLeft or false
	local IgnoreRight = IgnoreRight or false
	local CaseSensitive = CaseSensitive or false
	local maxDepth = maxDepth or 0
	local searchMode = searchMode or ArkInventory.Const.Tooltip.Search.Full
	
	local obj, txt
	local nextExit = false
	
	if not CaseSensitive then
		TextToFind = string.lower( TextToFind )
	end
	
	for i = ArkInventory.TooltipGetNumLines( tooltip ), 2, -1 do
		
		if nextExit then return end
		
		if maxDepth > 0 and i > maxDepth then return end
		
		obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", i )]
		if obj and obj:IsShown( ) then
			
			txt = obj:GetText( )
			
			if searchMode > ArkInventory.Const.Tooltip.Search.Full then
				if txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) then
					nextExit = true
				end
			end
			
			if not IgnoreLeft then
				
				txt = ArkInventory.TooltipCleanText( txt )
				if not CaseSensitive then
					txt = string.lower( txt )
				end
				
				local a, b = string.find( txt, TextToFind )
				if a then
					return a, b
				end
				
			end
			
		end
		
		if not IgnoreRight then
			
			obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextRight", i )]
			if obj and obj:IsShown( ) then
				
				txt = ArkInventory.TooltipCleanText( obj:GetText( ) )
				if txt ~= "" then
					
					if not CaseSensitive then
						txt = string.lower( txt )
					end
					
					local a, b = string.find( txt, TextToFind )
					if a then
						return a, b
					end
					
				end
				
			end
			
		end
		
	end
	
end

function ArkInventory.TooltipFind_NEW( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, maxDepth, searchMode )
	
	--ArkInventory.Output2( "z=[", TextToFind, "]" )
	
	local TextToFind = ArkInventory.TooltipCleanText( TextToFind )
	if TextToFind == "" then
		return false
	end
	
	local IgnoreLeft = IgnoreLeft or false
	local IgnoreRight = IgnoreRight or false
	local CaseSensitive = CaseSensitive or false
	local maxDepth = maxDepth or 0
	local searchMode = searchMode or ArkInventory.Const.Tooltip.Search.Full
	local Skip = false
	
	if not CaseSensitive then
		TextToFind = string.lower( TextToFind )
	end
	
	local obj, txt
	
	for i = 2, ArkInventory.TooltipGetNumLines( tooltip ) do
		
		if maxDepth > 0 and i > maxDepth then return end
		
		obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", i )]
		if obj and obj:IsShown( ) then
			
			txt = obj:GetText( )
			
			if searchMode > ArkInventory.Const.Tooltip.Search.Full then
				if txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) then
					if searchMode == ArkInventory.Const.Tooltip.Search.Base then
						Skip = not Skip
					elseif searchMode == ArkInventory.Const.Tooltip.Search.Short then
						return
					end
				end
			end
			
			if not Skip and not IgnoreLeft then
				
				txt = ArkInventory.TooltipCleanText( txt )
				if not CaseSensitive then
					txt = string.lower( txt )
				end
				
				if string.find( txt, TextToFind ) then
					return string.find( txt, TextToFind )
				end
				
			end
			
		end
		
		if not Skip and not IgnoreRight then
			
			obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextRight", i )]
			if obj and obj:IsShown( ) then
				
				txt = ArkInventory.TooltipCleanText( obj:GetText( ) )
				if txt ~= "" then
					
					if not CaseSensitive then
						txt = string.lower( txt )
					end
					
					if string.find( txt, TextToFind ) then
						return string.find( txt, TextToFind )
					end
					
				end
				
			end
			
		end
		
	end
	
end

function ArkInventory.TooltipFind( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, maxDepth, searchMode )
	
	--ArkInventory.Output2( "z=[", TextToFind, "]" )
	
	local TextToFind = ArkInventory.TooltipCleanText( TextToFind )
	if TextToFind == "" then
		return false
	end
	
	local IgnoreLeft = IgnoreLeft or false
	local IgnoreRight = IgnoreRight or false
	local CaseSensitive = CaseSensitive or false
	local maxDepth = maxDepth or 0
	local searchMode = searchMode or ArkInventory.Const.Tooltip.Search.Full
	
	if not CaseSensitive then
		TextToFind = string.lower( TextToFind )
	end
	
	local obj, txt
	
	for i = 2, ArkInventory.TooltipGetNumLines( tooltip ) do
		
		if maxDepth > 0 and i > maxDepth then return end
		
		obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", i )]
		if obj and obj:IsShown( ) then
			
			txt = obj:GetText( )
			
			if searchMode > ArkInventory.Const.Tooltip.Search.Full then
				if txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) then
					if searchMode == ArkInventory.Const.Tooltip.Search.Base then
						return ArkInventory.TooltipFindBackwards( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, maxDepth, searchMode )
					elseif searchMode == ArkInventory.Const.Tooltip.Search.Short then
						return
					end
				end
			end
			
			if not IgnoreLeft then
				
				txt = ArkInventory.TooltipCleanText( txt )
				if not CaseSensitive then
					txt = string.lower( txt )
				end
				
				if string.find( txt, TextToFind ) then
					return string.find( txt, TextToFind )
				end
				
			end
			
		end
		
		if not IgnoreRight then
			
			obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextRight", i )]
			if obj and obj:IsShown( ) then
				
				txt = ArkInventory.TooltipCleanText( obj:GetText( ) )
				if txt ~= "" then
					
					if not CaseSensitive then
						txt = string.lower( txt )
					end
					
					if string.find( txt, TextToFind ) then
						return string.find( txt, TextToFind )
					end
					
				end
				
			end
			
		end
		
	end
	
end

function ArkInventory.TooltipGetLine( tooltip, i, clean )
	
	if not i or i < 1 or i > ArkInventory.TooltipGetNumLines( tooltip ) then
		return
	end
	
	local obj, txt1, txt2, c1, c2, r, g, b, a
	
	obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", i )]
	if obj and obj:IsShown( ) then
		txt1 = obj:GetText( )
		if clean then
			txt1 = ArkInventory.TooltipCleanText( txt1 )
		end
		c1 = CreateColor( obj:GetTextColor( ) )
	end
	
	obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextRight", i )]
	if obj and obj:IsShown( ) then
		txt2 = obj:GetText( )
		if clean then
			txt2 = ArkInventory.TooltipCleanText( txt2 )
		end
		c2 = CreateColor( obj:GetTextColor( ) )
	end
	
	return txt1 or "", txt2 or "", c1, c2
	
end

function ArkInventory.TooltipGetBaseStats( tooltip, activeonly )
	
	local obj, txt, ctxt
	
	local started = false
	local rv = ""
	
--	obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", 1 )]
--	txt = obj:GetText( )
--	ArkInventory.Output( txt )
	
	for i = 2, ArkInventory.TooltipGetNumLines( tooltip ) do
		
		obj = _G[string.format( "%s%s%s", tooltip:GetName( ), "TextLeft", i )]
		if obj and obj:IsShown( ) then
			
			txt = obj:GetText( )
			ctxt = ArkInventory.TooltipCleanText( txt )
			
			local basestat = false
			if string.find( ctxt, "^%+?[%d,.]+ [%a ]+$" ) then
				--ArkInventory.Output( "1 - ", ctxt )
				basestat = true
			end
			
			if started and ( txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) or not basestat ) then
				--ArkInventory.Output( "X - ", ctxt )
				--ArkInventory.Output( "rv = ", rv )
				return rv
			end
			
			if basestat then
				
				started = true
				
				if activeonly then
					local r, g, b = obj:GetTextColor( )
					local c = string.format( "%02x%02x%02x", r * 255, g * 255, b * 255 )
					--ArkInventory.Output( string.format( "%04i = %s %s", i, c, txt ) )
					if c ~= "7f7f7f" then
						--ArkInventory.Output( "A - ", ctxt )
						rv = string.format( "%s %s", rv, ctxt )
					end
				else
					rv = string.format( "%s %s", rv, ctxt )
				end
				
			end
			
			--ArkInventory.Output( "Z - ", ctxt )
			
		end
		
	end
	
	--ArkInventory.Output( "rv = ", rv )
	return rv
	
	-- /run ArkInventory.TooltipGetBaseStats( GameTooltip )
	-- /run ArkInventory.TooltipGetBaseStats( GameTooltip, true )
	
end

function ArkInventory.TooltipContains( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, searchMode )
	
	if ArkInventory.TooltipFind( tooltip, TextToFind, IgnoreLeft, IgnoreRight, CaseSensitive, 0, searchMode ) then
		return true
	else
		return false
	end
	
end


local function helper_AcceptableRedText( txt, allow_known, allow_level )
	
	-- what red text is allowed to exist
	
	if txt == ArkInventory.Localise["ALREADY_KNOWN"] then
		--ArkInventory.Output( "ALREADY_KNOWN" )
		if allow_known then
			return true
		else
			return false
		end
	elseif txt == ArkInventory.Localise["DURABILITY"] then
		--ArkInventory.Output2( "DURABILITY" )
		return true
	elseif string.match( txt, ArkInventory.Localise["WOW_TOOLTIP_DURABLITY"] ) then
		--ArkInventory.Output2( "WOW_TOOLTIP_DURABLITY" )
		return true
	elseif txt == ArkInventory.Localise["ITEM_CANNOT_DISENCHANT"] then
		return true
	elseif txt == ArkInventory.Localise["ITEM_CANNOT_OBLITERATE"] then
		return true
	elseif txt == ArkInventory.Localise["ITEM_CANNOT_SCRAP"] then
		return true
	elseif txt == ArkInventory.Localise["PREVIOUS_RANK_UNKNOWN"] then
		return true
	elseif txt == ArkInventory.Localise["WOW_TOOLTIP_RETRIEVING_ITEM_INFO"] then
		return true
	elseif txt == ArkInventory.Localise["HEART_OF_AZEROTH_INACTIVE"] then
		return true
	elseif txt == ArkInventory.Localise["CANNOT_UNEQUIP_COMBAT"] then
		return true
	elseif txt == ArkInventory.Localise["CANNOT_UNEQUIP_ARENA"] then
		return true
	elseif txt == ArkInventory.Localise["CANNOT_UNEQUIP_MYTHIC_PLUS"] then
		return true
	elseif txt == ArkInventory.Localise["CANNOT_UNEQUIP_TORGHAST"] then
		return true
	elseif string.match( txt, ArkInventory.Localise["WOW_TOOLTIP_REQUIRES_LEVEL"] ) then
		--ArkInventory.Output( "WOW_TOOLTIP_REQUIRES_LEVEL" )
		if allow_level then
			return true
		else
			return false
		end
	end
	
	--ArkInventory.Output( "red text: ", txt )
	return false
	
end

function ArkInventory.TooltipCanUseBackwards( tooltip, allow_known, allow_level )
	
	local l = { "TextLeft", "TextRight" }
	local n = ArkInventory.TooltipGetNumLines( tooltip )
	
	for i = n, 2, -1 do
		for _, v in pairs( l ) do
			local obj = _G[string.format( "%s%s%s", tooltip:GetName( ), v, i )]
			if obj and obj:IsShown( ) then
				
				local txt = obj:GetText( )
				if txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) then
					return true
				end
				
				local r, g, b, a = obj:GetTextColor( )
				local c = ArkInventory.ColourRGBtoCode( r, g, b, a, true )
				if c == ArkInventory.Const.BLIZZARD.GLOBAL.FONT.COLOR.ALREADYKNOWN then
					txt = ArkInventory.TooltipCleanText( txt )
					if not helper_AcceptableRedText( txt, allow_known, allow_level ) then
						--ArkInventory.Output2( "line[", i, "]=[", txt, "] backwards - unusable" )
						return false
					end
				end
				
			end
		end
	end
	
	return true
	
end

function ArkInventory.TooltipCanUse( tooltip, allow_known, allow_level )
	
	local l = { "TextLeft", "TextRight" }
	local n = ArkInventory.TooltipGetNumLines( tooltip )
	
	for i = 2, n do
		for _, v in pairs( l ) do
			
			local obj = _G[string.format( "%s%s%s", tooltip:GetName( ), v, i )]
			if obj and obj:IsShown( ) then
				
				local txt = obj:GetText( )
				if txt == "" or string.find( txt, "^\10" ) or string.find( txt, "^\n" ) or string.find( txt, "^|n" ) then
					return ArkInventory.TooltipCanUseBackwards( tooltip, allow_known, allow_level )
				end
				
				local r, g, b, a = obj:GetTextColor( )
				local c = ArkInventory.ColourRGBtoCode( r, g, b, a, true )
				if c == ArkInventory.Const.BLIZZARD.GLOBAL.FONT.COLOR.ALREADYKNOWN then
					txt = ArkInventory.TooltipCleanText( txt )
					if not helper_AcceptableRedText( txt, allow_known, allow_level ) then
						--ArkInventory.Output( "line[", i, "]=[", txt, "] forwards - unusable" )
						return false
					end
				end
				
			end
		end
	end
	
	return true
	
end

function ArkInventory.TooltipIsReady( tooltip )
	local txt = ArkInventory.TooltipGetLine( tooltip, 1, true )
	if txt and txt ~= "" and txt ~= ArkInventory.Localise["WOW_TOOLTIP_RETRIEVING_ITEM_INFO"] then
		return true
	end
end




local function helper_CheckTooltipForItemOrSpell( tooltip )
	
	local h = nil
	
	-- check for an item
	if not h and tooltip["GetItem"] then
		--ArkInventory.Output2( "check item" )
		local name, link = tooltip:GetItem( )
		if link then
			h = link
			--ArkInventory.Output2( "ITEM [", string.gsub( h, "\124", "\124\124" ), "]" )
		end
	end
	
	-- check for a spell
	if not h and tooltip["GetSpell"] then
		--ArkInventory.Output2( "check spell" )
		local name, rank, id = tooltip:GetSpell( )
		if id then
			h = GetSpellLink( id )
			--ArkInventory.Output2( "SPELL [", string.gsub( h, "\124", "\124\124" ), "]" )
		end
	end
	
	return h
	
end

function ArkInventory.HookTooltipSetGeneric( fn, tooltip, ... )
	
	if checkAbortItemCount( tooltip ) then return end
	
	if not fn then return end
	
	-- not one of the tooltips im checking
	if not tooltip.ARKTTD then return end
	
	-- dont play with any of the scan tooltips
	if tooltip.ARKTTD.scan then return end
	
	
--	local arg1, arg2, arg3, arg4 = ...
--	if type( arg1 ) == "string" then
--		arg1 = string.gsub( arg1, "\124", "\124\124" )
--	end
--	ArkInventory.Output2( "G0: ", tooltip:GetName( ), ":", fn, " ( ", arg1, ", ", arg2, ", ", arg3, ", ", arg4, " )" )
	
	local h
	local afn = string.format( "TooltipValidateDataFrom%s", fn )
	if ArkInventory[afn] then
		
		-- use the TooltipGetHyperlink<FunctionName> function i made to get the hyperlink out of this function
		-- this will because it sometimes doesnt have an item, or you get the item via other means
		
		h = ArkInventory[afn]( tooltip, ... )
		--ArkInventory.Output2( "MINE [", string.gsub( h, "\124", "\124\124" ), "]" )
--		if type( h ) ~= "string" and not MissingFunctions[afn] then
--			MissingFunctions[afn] = true
--			ArkInventory.OutputWarning("Code Error: ", afn, " did not return a value.  Please let the author know.  The warning for this function will occur once per session." )
--			return
--		end
		
	else
		
		-- i didnt create a custom TooltipValidateDataFromXXXXX function for this function so just look for an item or a spell
		h = helper_CheckTooltipForItemOrSpell( tooltip )
		if ArkInventory.Global.Debug and type( h ) ~= "string" and not MissingFunctions[afn] then
			MissingFunctions[afn] = true
			local arg1, arg2, arg3, arg4 = ...
			ArkInventory.OutputWarning( "Code Error: ", "Unable to generate a hyperlink from ", tooltip:GetName( ), ":", fn, " ( ", arg1, ", ", arg2, ", ", arg3, ", ", arg4, " )" )
			ArkInventory.OutputWarning( "Code Error: ", "A function named ", afn, " will need to be created to allow item counts to update for this object type.  Please let the author know." )
			ArkInventory.OutputWarning( "Code Error: ", "The warning for this function will only occur once per session.  No you can't disable this warning." )
			--return
		end
		
	end
	
	if h then
		--ArkInventory.Output2( tooltip:GetName( ), ":", fn, " has a valid object, saving for reload" )
		ArkInventory.TooltipMyDataSave( tooltip, fn, ... )
	end
	
	if not tooltip:IsVisible( ) then
		-- dont add stuff to tooltips until after they become visible for the first time
		-- some of them just dont like it and it can stuff up the formatting
		return
	end
	
	ArkInventory.API.ReloadedTooltipReady( tooltip, fn, unpack( tooltip.ARKTTD.args ) )
	
	--ArkInventory.Output2( "h=", string.gsub( h, "\124", "\124\124" ) )
	
	-- it wont actually add the item counts if h is nil so i havent wrapped it in an if statement
	ArkInventory.TooltipAddItemCount( tooltip, h )
	
end


function ArkInventory.HookTooltipSetAuctionItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetAuctionItem", ... )
end

function ArkInventory.HookTooltipSetAuctionSellItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetAuctionSellItem", ... )
end

function ArkInventory.HookTooltipSetBackpackToken( ... )
	ArkInventory.HookTooltipSetGeneric( "SetBackpackToken", ... )
end

function ArkInventory.HookTooltipSetBagItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetBagItem", ... )
end

function ArkInventory.HookTooltipSetBuybackItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetBuybackItem", ... )
end

function ArkInventory.HookTooltipSetCraftItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetCraftItem", ... )
end

function ArkInventory.HookTooltipSetCraftSpell( ... )
	ArkInventory.HookTooltipSetGeneric( "SetCraftSpell", ... )
end

function ArkInventory.HookTooltipSetCurrencyByID( ... )
	ArkInventory.HookTooltipSetGeneric( "SetCurrencyByID", ... )
end

function ArkInventory.HookTooltipSetCurrencyToken( ... )
	ArkInventory.HookTooltipSetGeneric( "SetCurrencyToken", ... )
end

function ArkInventory.HookTooltipSetCurrencyTokenByID( ... )
	ArkInventory.HookTooltipSetGeneric( "SetCurrencyTokenByID", ... )
end

function ArkInventory.HookTooltipSetGuildBankItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetGuildBankItem", ... )
end

function ArkInventory.HookTooltipSetHeirloomByItemID( ... )
	ArkInventory.HookTooltipSetGeneric( "SetHeirloomByItemID", ... )
end

function ArkInventory.HookTooltipSetHyperlink( ... )
	ArkInventory.HookTooltipSetGeneric( "SetHyperlink", ... )
end

function ArkInventory.HookTooltipSetInboxItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetInboxItem", ... )
end

function ArkInventory.HookTooltipSetInventoryItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetInventoryItem", ... )
end

function ArkInventory.HookTooltipSetItemByID( ... )
	ArkInventory.HookTooltipSetGeneric( "SetItemByID", ... )
end

function ArkInventory.HookTooltipSetItemKey( ... )
	ArkInventory.HookTooltipSetGeneric( "SetItemKey", ... )
end

function ArkInventory.HookTooltipSetLootCurrency( ... )
	ArkInventory.HookTooltipSetGeneric( "SetLootCurrency", ... )
end

function ArkInventory.HookTooltipSetLootItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetLootItem", ... )
end

function ArkInventory.HookTooltipSetLootRollItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetLootRollItem", ... )
end

function ArkInventory.HookTooltipSetMerchantItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetMerchantItem", ... )
end

function ArkInventory.HookTooltipSetMerchantCostItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetMerchantCostItem", ... )
end

function ArkInventory.HookTooltipSetQuestCurrency( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestCurrency", ... )
end

function ArkInventory.HookTooltipSetQuestItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestItem", ... )
end

function ArkInventory.HookTooltipSetQuestLogCurrency( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestLogCurrency", ... )
end

function ArkInventory.HookTooltipSetQuestLogItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestLogItem", ... )
end

function ArkInventory.HookTooltipSetQuestLogRewardSpell( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestLogRewardSpell", ... )
end

function ArkInventory.HookTooltipSetQuestRewardSpell( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestRewardSpell", ... )
end

function ArkInventory.HookTooltipSetQuestLogSpecialItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetQuestLogSpecialItem", ... )
end

function ArkInventory.HookTooltipSetRecipeReagentItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetRecipeReagentItem", ... )
end

function ArkInventory.HookTooltipSetRecipeResultItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetRecipeResultItem", ... )
end

function ArkInventory.HookTooltipSetSendMailItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetSendMailItem", ... )
end

function ArkInventory.HookTooltipSetToyByItemID( ... )
	ArkInventory.HookTooltipSetGeneric( "SetToyByItemID", ... )
end

function ArkInventory.HookTooltipSetTradePlayerItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetTradePlayerItem", ... )
end

function ArkInventory.HookTooltipSetTradeSkillItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetTradeSkillItem", ... )
end

function ArkInventory.HookTooltipSetTradeTargetItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetTradeTargetItem", ... )
end

function ArkInventory.HookTooltipSetVoidDepositItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetVoidDepositItem", ... )
end

function ArkInventory.HookTooltipSetVoidItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetVoidItem", ... )
end

function ArkInventory.HookTooltipSetVoidWithdrawalItem( ... )
	ArkInventory.HookTooltipSetGeneric( "SetVoidWithdrawalItem", ... )
end



local function helper_CurrencyRepuationCheck( currencyID )
	--ArkInventory.Output2( "currencyID=", currencyID )
	if currencyID then
		local factionID = C_CurrencyInfo.GetFactionGrantedByCurrency( currencyID )
		--ArkInventory.Output2( "factionID=", factionID )
		if factionID then
			-- its actually reputation
			local obj = ArkInventory.Collection.Reputation.GetByID( factionID )
			--ArkInventory.Output2( "faction=", obj )
			if obj then
				return obj.link
			end
		else
			-- its a normal currency
			local obj = ArkInventory.Collection.Currency.GetByID( currencyID )
			--ArkInventory.Output2( "currency=", obj )
			if obj then
				return obj.link
			end
		end
	end
end

function ArkInventory.TooltipValidateDataFromSetAuctionSellItem( tooltip, ... )
	-- not sure why this needs to be here yet, but it does
	local h = helper_CheckTooltipForItemOrSpell( tooltip )
	if not h then
		local arg1, arg2, arg3, arg4
		ArkInventory.Output2( "SetAuctionSellItem: ", { arg1, arg2, arg3, arg4 } )
	end
	return h
end

function ArkInventory.TooltipValidateDataFromSetBagItem( tooltip, ... )
	-- needs to exist due to caged battlepet items, theyre handled elsewhere, this just needs to stop the error
	return helper_CheckTooltipForItemOrSpell( tooltip )
end

function ArkInventory.TooltipValidateDataFromSetBackpackToken( tooltip, ... )
	
--	test = mouseover backpack token in the original UI
--	checked ok = 30936
	
	local arg1 = ...
	
	if arg1 then
		local info = ArkInventory.CrossClient.GetBackpackCurrencyInfo( arg1 )
		helper_CurrencyRepuationCheck( info and info.currencyTypesID )
	end
	
end

function ArkInventory.TooltipValidateDataFromSetBagItem( tooltip, ... )
	-- needs to exist due to caged battlepet items, theyre handled elsewhere, this just needs to stop the error
	return helper_CheckTooltipForItemOrSpell( tooltip )
end

function ArkInventory.TooltipValidateDataFromSetBuybackItem( tooltip, ... )
	return helper_CheckTooltipForItemOrSpell( tooltip )
end

function ArkInventory.TooltipValidateDataFromSetCraftSpell( tooltip, ... )
	
--	fix later
	
--	test = 
--	checked ok = 30936
	
	--local arg1, arg2 = ...
	
	ArkInventory.Output2( "TooltipValidateDataFromSetCraftSpell" )
	
end

function ArkInventory.TooltipValidateDataFromSetCurrencyByID( tooltip, ... )
	
--	test = backpack currency tokens
--	test = check mission lists for currency/reputation reward
--	test = quest reward for reputation or currency
--	test = currency window
--	checked ok = 30936
	
	local arg1, arg2 = ... -- currencyID, amount
	return helper_CurrencyRepuationCheck( arg1 )
	
end

function ArkInventory.TooltipValidateDataFromSetCurrencyToken( tooltip, ... )
	
--	note - does not appear to be used in any way for reputation so we can skip that check here
	
--	test = the currency list on the character pane
--	checked ok = 
	
	local arg1, arg2 = ... -- index, amount
	if arg1 then
		return ArkInventory.CrossClient.GetCurrencyListLink( arg1, arg2 or 0 )
	end
	
end

function ArkInventory.TooltipValidateDataFromSetCurrencyTokenByID( tooltip, ... )
	
--	test = check mission table, war resources in top right hand corner
--	checked ok = 
	
	local arg1 = ... -- id
	return helper_CurrencyRepuationCheck( arg1 )
	
end

function ArkInventory.TooltipValidateDataFromSetHyperlink( tooltip, ... )
--	this is here to generically cover any hyperlinks that arent item or spell based
	
	local arg1 = ...
	local osd = ArkInventory.ObjectStringDecode( arg1 )
	--ArkInventory.Output2( osd.class, " / ", osd.h )
	if supportedHyperlinkClass[osd.class] then
		return arg1
	end
	
end

function ArkInventory.TooltipValidateDataFromSetInboxItem( tooltip, ... )
	-- needs to exist due to caged battlepet items, theyre handled elsewhere, this just needs to stop the error
	return helper_CheckTooltipForItemOrSpell( tooltip )
end

function ArkInventory.TooltipValidateDataFromSetInventoryItem( tooltip, ... )
	-- needs to exist to handle empty inventory slots
	return helper_CheckTooltipForItemOrSpell( tooltip )
end

function ArkInventory.TooltipValidateDataFromSetMerchantCostItem( tooltip, ... )
	
--	test = mouseover currency in merchant frame
--	checked ok = 30936
	
	local arg1, arg2 = ... -- index, currency
	
	if arg1 and arg2 then
		local itemTexture, itemValue, itemLink = GetMerchantItemCostItem( arg1, arg2 )
		return itemLink
	end
	
end

function ArkInventory.TooltipValidateDataFromSetQuestCurrency( tooltip, ... )
	
--	test = ?
--	checked ok = ?
	
	local arg1, arg2 = ...  --reward type, index
	if arg1 and arg2 then
		local currencyID = GetQuestCurrencyID( arg1, arg2 )
		return helper_CurrencyRepuationCheck( currencyID )
	end
	
end

function ArkInventory.TooltipValidateDataFromSetQuestLogCurrency( tooltip, ... )
	
--	test = quest reward that is a currency
--	test = quest reward that is a reputation
--	checked ok = ?
	
	local arg1, arg2 = ...  --reward type, index
	if arg1 and arg2 then
		local currencyID = GetQuestCurrencyID( arg1, arg2 )
		return helper_CurrencyRepuationCheck( currencyID )
	end
	
end

function ArkInventory.TooltipValidateDataFromSetQuestLogRewardSpell( tooltip, ... )
	-- not sure if this is worth hooking any more, just here to stop the error
	return helper_CheckTooltipForItemOrSpell( tooltip )
end

function ArkInventory.TooltipValidateDataFromSetRecipeReagentItem( tooltip, ... )
	
--	test = any profession recipe reagent
--	checked ok = 30936
	
	local arg1, arg2 = ...
	if arg1 and arg2 then
		return C_TradeSkillUI.GetRecipeReagentItemLink( arg1, arg2 )
	end
	
end

function ArkInventory.TooltipValidateDataFromSetRecipeResultItem( tooltip, ... )
	
--	test = any profession recipe result
--	checked ok = 30936
	
	local arg1 = ...
	if arg1 then
		return C_TradeSkillUI.GetRecipeItemLink( arg1 )
	end
	
end

function ArkInventory.TooltipValidateDataFromSetSendMailItem( tooltip, ... )
	-- needs to exist due to caged battlepet items, theyre handled elsewhere, this just needs to stop the error
	return helper_CheckTooltipForItemOrSpell( tooltip )
end

function ArkInventory.TooltipValidateDataFromSetTradeTargetItem( tooltip, ... )
	-- not sure if this is worth hooking any more, just here to stop the error
	return helper_CheckTooltipForItemOrSpell( tooltip )
end

function ArkInventory.TooltipValidateDataFromSetLootCurrency( tooltip, ... )
	
	local arg1 = ...
	local texture, item, quantity, currencyID = GetLootSlotInfo( arg1 )
	return helper_CurrencyRepuationCheck( currencyID )
	
end

function ArkInventory.TooltipValidateDataFromSetLootItem( tooltip, ... )
	-- not sure why but people are getting nil
	return helper_CheckTooltipForItemOrSpell( tooltip )
end

function ArkInventory.TooltipValidateDataFromSetToyByItemID( tooltip, ... )
	
--	test = blizzard toy collection
--	checked ok = 30936
	
	local arg1 = ... -- id
	if arg1 then
		return C_ToyBox.GetToyLink( arg1 )
	end
	
end




function ArkInventory.HookOnTooltipSetUnit( tooltip, ... )
--	this tooltip doesnt normally refresh
	
--	test = mouseover your active pet, or a wild battlepet
--	checked ok = 
	
	if not C_PetJournal then return end
	if not ArkInventory.db.option.tooltip.battlepet.enable then return end
	
	if checkAbortShow( tooltip ) then return true end
	
	local arg1, arg2, arg3, arg4, arg5 = ...
	--ArkInventory.Output2( arg1, " / ", arg2, " / ", arg3, " / ", arg4, " / ", arg5 )
	
	-- reload previous critter
	if arg4 or arg5 then
		
		local unit = "mouseover"
		local h = arg4
		local i = arg5
		
		if unit and UnitExists( unit ) and UnitIsBattlePet( unit ) then
			
			ArkInventory.TooltipCustomBattlepetShow( tooltip, h, i )
			
			local fn = "HookOnTooltipSetUnit"
			ArkInventory.TooltipMyDataSave( tooltip, fn, false, false, unit, h, i )
			
		else
			
			tooltip:Hide( )
			
		end
		
		return
		
	end
	
	
	-- new critter set
	local name, unit = tooltip:GetUnit( )
	
	--ArkInventory.Output2( "unit=", unit )
	
	if unit and UnitExists( unit ) and UnitIsBattlePet( unit ) then
		
		--ArkInventory.Output2( unit, " is a battlebet" )
		
		local bpSpeciesID = UnitBattlePetSpeciesID( unit )
		
		local sd = ArkInventory.Collection.Pet.GetSpeciesInfo( bpSpeciesID )
		if not sd then
			--ArkInventory.OutputWarning( "no species data found for ", bpSpeciesID )
			return
		end
		
		if sd.isTrainer and not sd.colour then
			--ArkInventory.Output2( "unknown species ", bpSpeciesID, " found and data has been updated." )
			-- found an unlisted battlepet, probably a legendary or a trainer pet
			-- update species data with some helpful infomation
			
			-- battlepets have the name wrapped in their quality code, but the legendaries dont so fall back if needed
			local txt1, txt2, c1, c2 = ArkInventory.TooltipGetLine( tooltip, 1 )
			sd.colour = ArkInventory.CreateColour( txt1 ) or c1
		end
		
		local bpLevel = UnitBattlePetLevel( unit )
		local h = ArkInventory.BattlepetBaseHyperlink( bpSpeciesID, bpLevel, -1, -1, -1, -1, sd.name )
		local i = false
		
		if UnitIsBattlePetCompanion( unit ) and not UnitIsOtherPlayersBattlePet( unit ) then
			-- its the players own battlepet
			local petID, GUID, pet = ArkInventory.Collection.Pet.GetCurrent( )
			if pet then
				i = { index = petID }
				h = pet.link
			end
		end
		
		ArkInventory.TooltipCustomBattlepetBuild( tooltip, h, i )
		ArkInventory.TooltipCustomBattlepetAddDetail( tooltip, bpSpeciesID, h, i )
		
		local fn = "HookOnTooltipSetUnit"
		ArkInventory.TooltipMyDataSave( tooltip, fn, false, false, false, h, i )
		
	end
	
end




function ArkInventory.TooltipMyDataClear( tooltip )
	
	if tooltip then
		
		if tooltip.ARKTTD then
			
			if not tooltip.ARKTTD.nopurge then
				wipe( tooltip.ARKTTD.onupdate )
				wipe( tooltip.ARKTTD.args )
				--ArkInventory.Output2( tooltip:GetName( ), " has been reset" )
			end
			
			tooltip.ARKTTD.nopurge = nil
			
		else
			
			tooltip.ARKTTD = { args = { }, onupdate = { } }
			--ArkInventory.Output2( tooltip:GetName( ), " has been initialised" )
			
		end
		
	end
	
end

function ArkInventory.TooltipMyDataSave( tooltip, fn, ... )
	
	ArkInventory.TooltipMyDataClear( tooltip )
	
	tooltip.ARKTTD.onupdate.timer = ArkInventory.Const.BLIZZARD.GLOBAL.TOOLTIP.UPDATETIMER
	tooltip.ARKTTD.onupdate.fn = fn
	
	local ac = select( '#', ... )
	for ax = 1, ac do
		tooltip.ARKTTD.args[ax] = ( select( ax, ... ) )
	end
	
	--ArkInventory.Output2( "S0: ", fn, "( ", tooltip.ARKTTD.args, " )" )
	
end

function ArkInventory.HookTooltipOnUpdate( tooltip, elapsed )
	
	if not tooltip then return end
	if not tooltip.ARKTTD or not tooltip.ARKTTD.onupdate.timer or not tooltip.ARKTTD.onupdate.fn then return end
	
	tooltip.ARKTTD.onupdate.timer = tooltip.ARKTTD.onupdate.timer - elapsed
	if tooltip.ARKTTD.onupdate.timer > 0 then return end
	
	tooltip.ARKTTD.onupdate.timer = ArkInventory.Const.BLIZZARD.GLOBAL.TOOLTIP.UPDATETIMER
	
	if checkAbortItemCount( tooltip ) then return end
	
	if tooltip == ItemRefTooltip then
		-- unlike GameTooltip the ItemRefTooltip does not do any checks, it just runs its OnUpdate function - if it has one set
		-- the problem is that OnUpdate is wiped in onLeave and OnHide, and then re-set in OnEnter, so normally it only updates when youre inside it
		-- to make it updates all the time we hook OnShow and OnLeave to set this function, if one isnt set already, as OnUpdate
		-- we hook OnEnter to re-hook the OnUpdate when its re-set in there
		-- the ItemRefTooltip.UpdateTooltip function does not reload the tooltip so we dont exit here, allowing it to be reloaded by our code
	else
		-- GameTooltip based tooltips have something similar to the below to check which function to run in their OnUpdate
		-- we rely on that code to reload the tooltip so if it exists then we dont have to do anything here and can exit
		-- if that code does not reload the tooltip then it will remain static and the item counts will not update
		local owner = tooltip:GetOwner( )
		if owner and owner.UpdateTooltip then
			-- if it has an owner and the owner has an UpdateTooltip function, then it will run that and we dont need to do anything.
			--ArkInventory.Output2( "owner (", owner:GetName( ), ") has an UpdateTooltip" )
			return
		elseif tooltip.UpdateTooltip then
			-- if it has its own UpdateTooltip function then it will run that and we dont need to do anything.
			--ArkInventory.Output2( "tooltip (", tooltip:GetName( ), ") has an UpdateTooltip" )
			return
		end
	end
	
	-- good to reload the tooltip
	
--	if tooltip == ItemRefTooltip then
		--ArkInventory.Output2( "reloading ", tooltip:GetName( ), ":", fn )
--	end
	
	local fn = tooltip.ARKTTD.onupdate.fn
	--ArkInventory.Output2( "R0: ", fn, " ", tooltip.ARKTTD.args )
	
	-- for tooltips that just relied on the OnHide to clear all lines (eg toybox)
	tooltip.ARKTTD.nopurge = true
	tooltip:ClearLines( )
	ArkInventory.API.ReloadedTooltipCleared( tooltip )
	
	if ArkInventory[fn] then
		-- so far its just reputation that is completely custom, pets have their own path
		ArkInventory[fn]( tooltip, unpack( tooltip.ARKTTD.args ) )
	else
		tooltip[fn]( tooltip, unpack( tooltip.ARKTTD.args ) )
	end
	
end

function ArkInventory.HookTooltipOnHide( tooltip )
	
	if checkAbortShow( tooltip ) then return true end
	
	ArkInventory.TooltipMyDataClear( tooltip )
	
end

function ArkInventory.HookTooltipOnShow( tooltip )
	
	if checkAbortShow( tooltip ) then return true end
	
	--ArkInventory.Output2( "onshow ", tooltip:GetName( ) )
	if tooltip == ItemRefTooltip then
		-- the OnUpdate script for ItemRefTooltip is not set in OnLoad and its wiped in OnLeave and OnHide, so add our own if its not there soit can reload
		if not tooltip:GetScript( "OnUpdate" ) then
			tooltip:SetScript( "OnUpdate", ArkInventory.HookTooltipOnUpdate )
		end
	end
	
end

function ArkInventory.HookTooltipOnEnter( tooltip )
	--ArkInventory.Output2( "onenter: ", tooltip:GetName( ) )
	if tooltip == ItemRefTooltip then
		-- the OnUpdate script for ItemRefTooltip is re-set in OnEnter so it destroys any previous hook you had and you need to re-hook it
		tooltip:HookScript( "OnUpdate", ArkInventory.HookTooltipOnUpdate )
	end
end

function ArkInventory.HookTooltipOnLeave( tooltip )
	
	if tooltip == ItemRefTooltip then
		-- the OnUpdate script is wiped in OnLeave so add our own
		--ArkInventory.Output2( "onleave: ", tooltip:GetName( ) )
		tooltip:SetScript( "OnUpdate", ArkInventory.HookTooltipOnUpdate )
	end
end

function ArkInventory.HookTooltipFadeOut( tooltip )
	--ArkInventory.Output2( "FadeOut" )
	ArkInventory.TooltipMyDataClear( tooltip )
end

function ArkInventory.HookTooltipClearLines( tooltip )
	--ArkInventory.Output2( "ClearLines" )
	ArkInventory.TooltipMyDataClear( tooltip )
end

function ArkInventory.HookTooltipSetText( tooltip )
	-- used in the menu system to convert a single line text tooltip containing an appropriatly encoded hyperlink into a proper hyperlijnk based tooltip
	
	if checkAbortShow( tooltip ) then return true end
	
	ArkInventory.TooltipMyDataClear( tooltip )
	
	if tooltip:NumLines( ) == 1 then
		
		local h = ArkInventory.TooltipGetLine( tooltip, 1, true )
		h = string.match( h, ArkInventory.Const.Tooltip.customHyperlinkMatch )
		if h then
			
			ArkInventory.TooltipSetHyperlink( tooltip, h )
			
		end
		
	end
	
end



function ArkInventory.TooltipAddEmptyLine( tooltip )
	if ArkInventory.db.option.tooltip.addempty then
		tooltip:AddLine( " ", 1, 1, 1, 0 )
	end
end

function ArkInventory.TooltipAddItemCount( tooltip, h )
	
	if not h or h == "" then return end
	
	if checkAbortItemCount( tooltip ) then return end
	
	--ArkInventory.Output2( "1 - TooltipAddItemCount" )
	
	local osd = ArkInventory.ObjectStringDecode( h )
	if not supportedHyperlinkClass[osd.class] then
		ArkInventory.Output2( "unsupported hyperlink: ", string.gsub( h, "\124", "\124\124" ) )
		return
	end
	
	local search_id = osd.h_base
	--ArkInventory.Output2( search_id )
	if ArkInventory.db.option.tooltip.itemcount.ignore[search_id] then return end
	
	--ArkInventory.Output2( "2 - TooltipAddItemCount - ", osd.class )
	
	search_id = ArkInventory.ObjectIDCount( h )
	--ArkInventory.Output2( search_id )
	
	ArkInventory.TooltipRebuildQueueAdd( search_id )
	
	local ta = ArkInventory.Global.Cache.ItemCountTooltip[search_id]
	
--[[
	data = {
		empty = true|false
		class[class] = { 1=user, 2=vault, 3=account
			count = 0
			total = "string - tooltip total"
			player_id[player_id] = {
				t1 = "string - tooltip left",
				t2 = "string - tooltip right"
			}
		}
	}
]]--	
	
	if ta and not ta.empty then
		
		ArkInventory.TooltipAddEmptyLine( tooltip )
		
		local tc = ArkInventory.db.option.tooltip.itemcount.colour.text
		
		local gap = false
		
		for class, cd in ArkInventory.spairs( ta.class ) do
			
			if cd.entries > 0 then
				
				if gap then
					ArkInventory.TooltipAddEmptyLine( tooltip )
				end
				
				for player_id, pd in ArkInventory.spairs( cd.player_id ) do
					tooltip:AddDoubleLine( pd.t1, pd.t2 )
				end
				
				if class == 1 and cd.entries > 1 and cd.total then
					tooltip:AddLine( cd.total )
				end
				
				gap = true
				
			end
			
		end
		
		tooltip:AppendText( "" )
		
		return true
		
	end
	
	tooltip:Show( )
	--ArkInventory.Output2( "3 - TooltipAddItemCount" )
	
end

function ArkInventory.TooltipAddItemAge( tooltip, h, blizzard_id, slot_id )
	
	if type( blizzard_id ) == "number" and type( slot_id ) == "number" then
		ArkInventory.TooltipAddEmptyLine( tooltip )
		local bag_id = ArkInventory.BlizzardBagIdToInternalId( blizzard_id )
		tooltip:AddLine( tt, 1, 1, 1, 0 )
	end

end

function ArkInventory.TooltipObjectCountGet( search_id, thread_id )
	
	local tc, changed = ArkInventory.ObjectCountGetRaw( search_id, thread_id )
	
	if not changed and ArkInventory.Global.Cache.ItemCountTooltip[search_id] then
		--ArkInventory.Output2( "using cached tooltip count ", search_id )
		return ArkInventory.Global.Cache.ItemCountTooltip[search_id]
	end
	
	--ArkInventory.Output2( "building tooltip count ", search_id )
	
	if thread_id then
		ArkInventory.ThreadYield( thread_id )
	end
	
	
	ArkInventory.Global.Cache.ItemCountTooltip[search_id] = { empty = true, class = { }, count = 0 }
--[[
		empty = true|false
		count = 0
		class[class] = {
			entries = 0,
			count = 0
			player_id[player_id] = {
				t1 = "string - tooltip left",
				t2 = "string - tooltip right"
			}
		}
]]--
	
	local data = ArkInventory.Global.Cache.ItemCountTooltip[search_id]
	
	if tc == nil then
		--ArkInventory.Output2( "no count data ", search_id )
		return data
	end
	
	local codex = ArkInventory.GetPlayerCodex( )
	local info = codex.player.data.info
	local player_id = info.player_id
	
	local just_me = ArkInventory.db.option.tooltip.itemcount.justme
	local ignore_vaults = not ArkInventory.db.option.tooltip.itemcount.vault
	local my_realm = ArkInventory.db.option.tooltip.itemcount.realm
	local include_crossrealm = ArkInventory.db.option.tooltip.itemcount.crossrealm
	local ignore_other_account = ArkInventory.db.option.tooltip.itemcount.account
	local ignore_other_faction = ArkInventory.db.option.tooltip.itemcount.faction
	local ignore_tradeskill = not ArkInventory.db.option.tooltip.itemcount.tradeskill
	
	local paint = ArkInventory.db.option.tooltip.itemcount.colour.class
	
	local c = ArkInventory.db.option.tooltip.itemcount.colour.text
	local c1 = ArkInventory.ColourRGBtoCode( c.r, c.g, c.b )
	
	local c = ArkInventory.db.option.tooltip.itemcount.colour.count
	local c2 = ArkInventory.ColourRGBtoCode( c.r, c.g, c.b )
	
	local pd = { }
	
	--ArkInventory.Output2( tc["Arkayenro - Khaz'goroth"] )
	for pid, rcd in ArkInventory.spairs( tc ) do
		
		local ok = false
		
		if ( not my_realm ) or ( my_realm and rcd.realm == info.realm ) or ( my_realm and include_crossrealm and ArkInventory.IsConnectedRealm( rcd.realm, info.realm ) ) then
			ok = true
		end
		
		if rcd.class == ArkInventory.Const.Class.Account then
			ok = true
		end
		
		if ignore_other_account and rcd.account_id ~= info.account_id then
			ok = false
		end
		
		if ignore_other_faction and rcd.faction ~= "" and rcd.faction ~= info.faction then
			ok = false
		end
		
		if rcd.class == ArkInventory.Const.Class.Guild and ignore_vaults then
			ok = false
		end
		
		if just_me and pid ~= player_id then
			ok = false
		end
		
		if ok then
			
			ArkInventory.GetPlayerStorage( pid, nil, pd )
			
			local class = rcd.class
			if class == ArkInventory.Const.Class.Account then
				class = 3
			elseif class == ArkInventory.Const.Class.Guild then
				class = 2
			else
				class = 1
			end
			
			if not data.class[class] then
				data.class[class] = { entries = 0, count = 0, player_id = { } }
			end
			
			if not data.class[class].player_id[pid] then
				data.class[class].player_id[pid] = { }
			end
			
			data.class[class].player_id[pid].count = rcd.total
			
			local name = ArkInventory.DisplayName3( pd.data.info, paint, codex.player.data.info )
			local location_entries = { }
			
			for loc_id, ld in pairs( rcd.location ) do
				
				if loc_id == ArkInventory.Const.Location.Tradeskill and ignore_tradeskill then
					
					-- ignore tradeskill data
					
				else
					
					if rcd.class == ArkInventory.Const.Class.Guild then
						
						if loc_id == ArkInventory.Const.Location.Vault and ld.e then
							
							local txt = ""
							
							if ArkInventory.db.option.tooltip.itemcount.tabs then
								
								local numtabs = ArkInventory.Table.Elements( ld.e )
								
								for tab, count in ArkInventory.spairs( ld.e ) do
									
									if numtabs > 1 then
										txt = string.format( "%s, %s%s %s: %s%s", txt, c1, ArkInventory.Localise["TOOLTIP_VAULT_TABS"], tab, c2, FormatLargeNumber( count ) )
									else
										txt = string.format( "%s%s %s", c1, ArkInventory.Localise["TOOLTIP_VAULT_TABS"], tab )
									end
									
								end
								
								if numtabs > 1 then
									txt = string.sub( txt, 3, string.len( txt ) )
								end
								
							else
								txt = string.format( "%s%s", c1, ArkInventory.Global.Location[loc_id].Name )
							end
							
							table.insert( location_entries, txt )
							
						end
						
					else
						
						if loc_id == ArkInventory.Const.Location.Reputation then
							
							if ArkInventory.db.option.tooltip.itemcount.reputation and ld.e then
								
								if ArkInventory.Collection.Reputation.IsReady( ) then
									local style_default = ArkInventory.Const.Reputation.Style.TooltipItemCount
									local style = style_default
									if ArkInventory.db.option.tooltip.reputation.custom ~= ArkInventory.Const.Reputation.Custom.Default then
										style = ArkInventory.db.option.tooltip.reputation.style.count
										if string.trim( style ) == "" then
											style = style_default
										end
									end
									
									local osd = ArkInventory.ObjectStringDecode( ld.e )
									local txt = ArkInventory.Collection.Reputation.LevelText( osd.id, style, osd.st, osd.bv, osd.bm, osd.ic, osd.pv, osd.pr )
									table.insert( location_entries, string.format( "%s%s", c1, txt ) )
								end
								
							end
							
						elseif loc_id == ArkInventory.Const.Location.Tradeskill then
							
							if ArkInventory.db.option.tooltip.itemcount.tradeskill and ( not ignore_tradeskill ) and ld.e then
								
								table.insert( location_entries, string.format( "%s%s", c1, ld.e ) )
								
							end
							
						elseif ld.c > 0 then
							
							if rcd.entries > 1 then
								table.insert( location_entries, string.format( "%s%s %s%s", c1, ArkInventory.Global.Location[loc_id].Name, c2, FormatLargeNumber( ld.c ) ) )
							else
								table.insert( location_entries, string.format( "%s%s", c1, ArkInventory.Global.Location[loc_id].Name ) )
							end
							
						end
						
					end
					
				end
				
			end
			
			--if data.class[class].player_id[pid].count > 0 then
			if #location_entries > 0 then
				
				data.empty = false
				
				local hl = ""
				if not ArkInventory.db.option.tooltip.itemcount.me and pd.data.info.player_id == player_id then
					hl = ArkInventory.db.option.tooltip.highlight
				end
				
				data.class[class].entries = data.class[class].entries + 1
				
				local count = data.class[class].player_id[pid].count
				if count > 0 then
					data.class[class].player_id[pid].t1 = string.format( "%s%s%s: %s%s", hl, c1, name, c2, FormatLargeNumber( count ) )
				else
					-- count should have been reset to zero for reputation and tradeskill back in getraw
					data.class[class].player_id[pid].t1 = string.format( "%s%s%s", hl, c1, name )
				end
				data.class[class].player_id[pid].t2 = string.format( "%s", table.concat( location_entries, ", " ) )
				
				data.class[class].count = data.class[class].count + data.class[class].player_id[pid].count
				data.count = data.count + data.class[class].count
				
			end
			
			if data.count > 0 then
				data.class[class].total = string.format( "%s%s: %s%s", c1, ArkInventory.Localise["TOTAL"], c2, FormatLargeNumber( data.class[class].count ) )
				data.total = string.format( "%s%s: %s%s", c1, ArkInventory.Localise["TOTAL"], c2, FormatLargeNumber( data.count ) )
			end
			
		end
		
	end
	
	return data
	
end

function ArkInventory.TooltipAddMoneyCoin( frame, amount, txt, r, g, b )
	
	if not frame or not amount then
		return
	end
	
	frame:AddDoubleLine( txt or " ", " ", r or 1, g or 1, b or 1 )
	
	local numLines = frame:NumLines( )
	if not frame.numMoneyFrames then
		frame.numMoneyFrames = 0
	end
	if not frame.shownMoneyFrames then
		frame.shownMoneyFrames = 0
	end
	
	local name = string.format( "%s%s%s", frame:GetName( ), "MoneyFrame", frame.shownMoneyFrames + 1 )
	local moneyFrame = _G[name]
	if not moneyFrame then
		frame.numMoneyFrames = frame.numMoneyFrames + 1
		moneyFrame = CreateFrame( "Frame", name, frame, "TooltipMoneyFrameTemplate" )
		name = moneyFrame:GetName( )
		ArkInventory.MoneyFrame_SetType( moneyFrame, "STATIC" )
	end
	
	moneyFrame:SetPoint( "RIGHT", string.format( "%s%s%s", frame:GetName( ), "TextRight", numLines ), "RIGHT", 15, 0 )
	
	moneyFrame:Show( )
	
	if not frame.shownMoneyFrames then
		frame.shownMoneyFrames = 1
	else
		frame.shownMoneyFrames = frame.shownMoneyFrames + 1
	end
	
	MoneyFrame_Update( moneyFrame:GetName( ), amount )
	
	local leftFrame = _G[string.format( "%s%s%s", frame:GetName( ), "TextLeft", numLines )]
	local frameWidth = leftFrame:GetWidth( ) + moneyFrame:GetWidth( ) + 40
	
	if frame:GetMinimumWidth( ) < frameWidth then
		frame:SetMinimumWidth( frameWidth )
	end
	
	frame.hasMoney = 1

end

function ArkInventory.TooltipAddMoneyText( frame, money, txt, r1, g1, b1, r2, g2, b2 )
	if not money then
		return
	else
		frame:AddDoubleLine( txt or ArkInventory.Localise["UNKNOWN"], ArkInventory.MoneyText( money ), r1, g1, b1, r2, g2, b2 )
	end
end


function ArkInventory.TooltipDump( tooltip )
	
	-- /run ArkInventory.TooltipDump( EmbeddedItemTooltip )
	-- /run ArkInventory.TooltipDump( GameTooltip )
	-- /run ArkInventory.TooltipDump( ArkInventory.Global.Tooltip.Scan )
	
	
	local tooltip = tooltip or ArkInventory.Global.Tooltip.Scan
	--local h = "|cffa335ee|Hkeystone:138019:234:2:0:0:0:0|h[Keystone: Return to Karazhan: Upper (2)]|h|r"
	--local h = "keystone:138019:234:2:0:0:0:0"
	--tooltip:SetHyperlink( h )
-- 
--	/run ArkInventory.TooltipDump( ArkInventory.Global.Tooltip.Scan )
--	/run ArkInventory.TooltipDump( GameTooltip )
	ArkInventory.Output( "----- ----- -----" )
	local c = ArkInventory.TooltipGetNumLines( tooltip )
	ArkInventory.Output( "lines = ", c )
	for i = 1, c do
		local a, b, ac, bc = ArkInventory.TooltipGetLine( tooltip, i, true )
		ArkInventory.Output( i, " left: ", ac:GenerateHexColor( ), ": ", a )
		if b ~= "" then
			ArkInventory.Output( i, " right: ", bc:GenerateHexColor( ), ": ", b )
		end
	end
	
	if tooltip:GetParent( ) then
		ArkInventory.Output( "parent = ", tooltip:GetParent( ):GetName( ) )
	else
		ArkInventory.Output( "parent = *not set*" )
	end
	
	if tooltip:GetOwner( ) then
		ArkInventory.Output( "owner = ", tooltip:GetOwner( ):GetName( ) )
	else
		ArkInventory.Output( "owner = *not set*" )
	end
	
end

function ArkInventory.ListAllTooltips( )
	local tooltip = EnumerateFrames( )
	while tooltip do
		if tooltip:GetObjectType( ) == "GameTooltip" then
			local name = tooltip:GetName( )
			if name then
				ArkInventory.Output( name )
			end
		end
		tooltip = EnumerateFrames( tooltip )
	end
end


function ArkInventory.TooltipExtractValueSuffixCheck( level, suffix )
	
	--ArkInventory.Output2( "check [", level, "] [", suffix, "]" )
	
	local level = level or 0
	if not ( level == 3 or level == 6 or level == 9 or level == 12 ) then
		return
	end
	
	local suffix = string.trim( suffix ) or ""
	if suffix == "" then
		return
	end
	
	local suffixes = ArkInventory.Localise[string.format( "WOW_ITEM_TOOLTIP_10P%dT", level )]
	if suffixes == "" then
		return
	end
	
	local check
	
	for s in string.gmatch( suffixes, "[^,]+" ) do
		
		check = string.sub( suffix, 1, string.len( s ) )
		
		
		
		if string.lower( check ) == string.lower( s ) then
			--ArkInventory.Output2( "pass [", check, "] [", s, "]" )
			return true
		end
		
		--ArkInventory.Output2( "fail [", check, "] [", s, "]" )
		
	end
	
end

function ArkInventory.TooltipExtractValueArtifactPower( h )
	
	ArkInventory.TooltipSetHyperlink( ArkInventory.Global.Tooltip.Scan, h )
	
	if not ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ARTIFACT_POWER"], false, true, false, 0, ArkInventory.Const.Tooltip.Search.Short ) then
		return
	end
	
	local _, _, amount, suffix = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ARTIFACT_POWER_AMOUNT"], false, true, true, 0, ArkInventory.Const.Tooltip.Search.Short )
	amount = ArkInventory.ArkInventory.TooltipTextToNumber( amount )
	
	--ArkInventory.Output2( h, "[", amount, "] [", suffix, "]" )
	
	if amount then
		
		if ArkInventory.TooltipExtractValueSuffixCheck( 12, suffix ) then
			--ArkInventory.Output2( "12: ", amount, " ", suffix, "]" )
			amount = amount * 1000000000000
		elseif ArkInventory.TooltipExtractValueSuffixCheck( 9, suffix ) then
			--ArkInventory.Output2( "9: ", amount, " ", suffix, "]" )
			amount = amount * 1000000000
		elseif ArkInventory.TooltipExtractValueSuffixCheck( 6, suffix ) then
			--ArkInventory.Output2( "6: ", amount, " ", suffix, "]" )
			amount = amount * 1000000
		elseif ArkInventory.TooltipExtractValueSuffixCheck( 3, suffix ) then
			--ArkInventory.Output2( "3: ", amount, " ", suffix, "]" )
			amount = amount * 1000
		end
		
		return amount
		
	end
	
end

function ArkInventory.TooltipExtractValueAncientMana( h )
	
	ArkInventory.TooltipSetHyperlink( ArkInventory.Global.Tooltip.Scan, h )
	
	if not ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ANCIENT_MANA"], false, true, false, 0, ArkInventory.Const.Tooltip.Search.Short ) then
		return
	end
	
	local _, _, amount, suffix = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ARTIFACT_POWER_AMOUNT"], false, true, true, 0, ArkInventory.Const.Tooltip.Search.Short )
	amount = ArkInventory.TooltipTextToNumber( amount )
	--local _, _, amount, suffix = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, "(%d+)(..)", false, true, true, 0, ArkInventory.Const.Tooltip.Search.Short )
	
	--ArkInventory.Output2( h, " [", amount, "] [", suffix, "]" )
	--ArkInventory.Output2( "[", string.byte( string.sub( suffix, 1, 1 ) ), "] [", string.byte( string.sub( suffix, 2, 2 ) ), "]" )
	
	return amount
	
end





local TooltipRebuildQueue = { }
local scanning = false

function ArkInventory.TooltipRebuildQueueAdd( search_id )
	
	if not ArkInventory.db.option.tooltip.show then return end
	if not ArkInventory.db.option.tooltip.itemcount.enable then return end
	if not search_id then return end
	
	--ArkInventory.Output2( "adding ", search_id )
	TooltipRebuildQueue[search_id] = true
	
	ArkInventory:SendMessage( "EVENT_ARKINV_TOOLTIP_REBUILD_QUEUE_UPDATE_BUCKET", "START" )
	
end

local function Scan_Threaded( thread_id )
	
	--ArkInventory.Output2( "rebuilding ", ArkInventory.Table.Elements( TooltipRebuildQueue ) )
	
	for search_id in pairs( TooltipRebuildQueue ) do
		
		--ArkInventory.Output2( "rebuilding ", search_id )
		
		ArkInventory.TooltipObjectCountGet( search_id, thread_id )
		ArkInventory.ThreadYield( thread_id )
		
		TooltipRebuildQueue[search_id] = nil
		
	end
	
end

local function Scan( )
	
	local thread_id = ArkInventory.Global.Thread.Format.Tooltip
	
	if not ArkInventory.Global.Thread.Use then
		local tz = debugprofilestop( )
		ArkInventory.OutputThread( thread_id, " start" )
		Scan_Threaded( )
		tz = debugprofilestop( ) - tz
		ArkInventory.OutputThread( string.format( "%s took %0.0fms", thread_id, tz ) )
		return
	end
	
	local tf = function ( )
		Scan_Threaded( thread_id )
	end
	
	ArkInventory.ThreadStart( thread_id, tf )
	
end

function ArkInventory:EVENT_ARKINV_TOOLTIP_REBUILD_QUEUE_UPDATE_BUCKET( events )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if ArkInventory.Global.Mode.Combat then
		return
	end
	
	if not scanning then
		scanning = true
		Scan( )
		scanning = false
	else
		ArkInventory:SendMessage( "EVENT_ARKINV_TOOLTIP_REBUILD_QUEUE_UPDATE_BUCKET", "RESCAN" )
	end
	
end
