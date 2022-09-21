﻿local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table
local C_MountJournal = _G.C_MountJournal

local loc_id = ArkInventory.Const.Location.Mount
local PLAYER_MOUNT_LEVEL = 20

ArkInventory.Tradeskill = {
	Const = {
		Type = {
			Enchant = 1,
			Result = 2,
			Recipe = 3,
		},
	},
}

local collection = {
	
	sv = nil, -- set after sv is ready
	cache = { }, -- [enchantID] = recipe info table
	taughtby = { }, -- [itemID] = enchantID
	result = { }, -- [itemID] = enchantID
	xref = { }, -- [enchantID] = xref entry was imported (wont exist unless dataexport is enabled)
	
	isInit = false,
	isReady = false,
	isClosed = true,
	isScanning = false,
	queue = { }, -- [skillID] = true
	
}


function ArkInventory.Tradeskill.ExtractData( )
	if not ArkInventory.Global.dataexport then
		ArkInventory.OutputWarning( "ArkInventory.Global.dataexport is not enabled" )
	else
		local x
		ArkInventory.Table.Wipe( ArkInventory.db.extract )
		for enchant, ed in pairs( collection.sv.enchant ) do
			if not collection.xref[enchant] then
				x = string.format( "%s|%s|%s|%s|%s|%s|%s|%s|0", ed.s, ed.cat, enchant, ed.r or 0, ed.t or 0, ed.name or "", ed.rank or 0, ed.src or -1 )
				table.insert( ArkInventory.db.extract, x )
				ArkInventory.Output( string.gsub( x, "\124", "**" ) )
			end
		end
	end
	
end


local ImportCrossRefTable = {
-- skillID|categoryID|enchantID|resultID|taughtbyID|name|rank|source
}

local function helper_CreateXrefKeys( key1, key2 )
	
	local osd = ArkInventory.ObjectStringDecode( key1 )
	if type( osd.id ) ~= "number" or osd.id == 0 then return end
	
	osd = ArkInventory.ObjectStringDecode( key2 )
	if type( osd.id ) ~= "number" or osd.id == 0 then return end
	
	--ArkInventory.Output( key1, " / ", key2 )
	
	if not ArkInventory.Global.ItemCrossReference[key1] then
		ArkInventory.Global.ItemCrossReference[key1] = { }
	end
	ArkInventory.Global.ItemCrossReference[key1][key2] = true
	
	if not ArkInventory.Global.ItemCrossReference[key2] then
		ArkInventory.Global.ItemCrossReference[key2] = { }
	end
	ArkInventory.Global.ItemCrossReference[key2][key1] = true
	
	return true
	
end

function ArkInventory.Tradeskill.ImportCrossRefTable( )
	
	if not ArkInventory.Tradeskill.IsReady( ) then return end
	if not ImportCrossRefTable then return end
	
	local sv = collection.sv
	local osd, ok, ed, skill, category, enchant, result, taughtby, name, rank, source
	
	-- update the cached data from the xref import table
	for k, v in pairs( ImportCrossRefTable ) do
		
		ok = true
		
		skill, category, enchant, result, taughtby, name, rank, source = strsplit( "\124", v )
		
		skill = tonumber( skill )
		if not skill then
			--ArkInventory.Output( "bad skill" )
			ok = false
		end
		
		category = tonumber( category )
		if not category then
			--ArkInventory.Output( "bad category" )
			ok = false
		end
		
		osd = ArkInventory.ObjectStringDecode( enchant )
		if osd.id == 0 or osd.h_base ~= enchant then
			ok = false
		end
		enchant = osd.h_base
		
		if result ~= "-1" then
			osd = ArkInventory.ObjectStringDecode( result )
			if osd.id == 0 or result == enchant then
				--ArkInventory.Output( "bad result" )
				ok = false
			end
			result = osd.h_base
		end
		
		if taughtby ~= "-1" then
			osd = ArkInventory.ObjectStringDecode( taughtby )
			if osd.id == 0 or osd.h_base == result then
				--ArkInventory.Output( "bad taughtby" )
				ok = false
			end
			taughtby = osd.h_base
		end
		
		if not name or name == "" then
			--ArkInventory.Output( "bad name" )
			ok = false
		end
		
		rank = tonumber( rank )
		if not rank then
			--ArkInventory.Output( "bad rank" )
			ok = false
		end
		
		if not source then
			ok = false
		end
		
		
		
		if ok then
			
			collection.xref[enchant] = true
			
			if helper_CreateXrefKeys( taughtby, enchant ) then
				collection.taughtby[taughtby] = enchant
			end
			
			ed = sv.enchant[enchant]
			ed.s = skill
			ed.r = result
			
			sv.result[result][enchant] = skill
			
			if ArkInventory.Global.dataexport then
				ed.cat = category
				ed.t = taughtby
				ed.name = name
				ed.src = source
				ed.rank = rank
			end
			--ArkInventory.Output( enchant, " = ", ed )
			
			
		else
			
			ArkInventory.OutputWarning( "code issue: bad xref entry [", v, "].  please let the author know" )
			
		end
		
	end
	
	
	-- use the cached data to create the xref keys for result
	for enchant, ed in pairs( sv.enchant ) do
		
		if helper_CreateXrefKeys( enchant, ed.r ) then
			--collection.result[ed.r] = enchant
		end
		
		-- clean up any leftover export data
		if not ArkInventory.Global.dataexport then
			ed.cat = nil
			ed.name = nil
			ed.rank = nil
			ed.src = nil
		end
		
	end
	
	
	ArkInventory.Table.Wipe( ImportCrossRefTable )
	ImportCrossRefTable = nil
	
end

function ArkInventory.Tradeskill.IsReady( )
	return collection.isReady
end

function ArkInventory.Tradeskill.OnHide( )
	ArkInventory:SendMessage( "EVENT_ARKINV_TRADESKILL_UPDATE_BUCKET", "FRAME_HIDE" )
end

function ArkInventory.Tradeskill.GetRecipeIDForItemID( itemID )
end

function ArkInventory.Tradeskill.GetItemIDForRecipeID( recipeID )
end

function ArkInventory.Tradeskill.Iterate( skillID )
	
	local i = 0
	local tbl = { }
	local data = collection.cache
	if type( skillID ) == "number" then
		for k, v in pairs( data ) do
			if v.skillID == skillID then
				table.insert( tbl, k )
			end
		end
	end
	--table.sort( tbl )
	
	return function( )
		i = i + 1
		if i > #tbl then
			return
		else
			return tbl[i], data[tbl[i]]
		end
	end
	
end

function ArkInventory.Tradeskill.isEnchant( h )
	
	if not ArkInventory.Tradeskill.IsReady( ) then return end
	
	local osd = ArkInventory.ObjectStringDecode( h )
	local info = collection.sv.enchant[osd.h_base]
	if info.s ~= 0 then
		return info
	end
	
end

function ArkInventory.Tradeskill.isResultItem( h )
	
	if not ArkInventory.Tradeskill.IsReady( ) then return end
	
	local osd = ArkInventory.ObjectStringDecode( h )
	--return osd.h_base, collection.result[osd.h_base]
	return ArkInventory.db.cache.tradeskill.result[osd.h_base]
	
end

function ArkInventory.Tradeskill.isRecipeItem( h )
	
	if not ArkInventory.Tradeskill.IsReady( ) then return end
	
	local osd = ArkInventory.ObjectStringDecode( h )
	return collection.taughtby[osd.h_base]
	
end

function ArkInventory.Tradeskill.isTradeskillObject( h )
	
	if not ArkInventory.Tradeskill.IsReady( ) then return end
	
	local info = ArkInventory.Tradeskill.isEnchant( h )
	if info then
		return ArkInventory.Tradeskill.Const.Type.Enchant, info
	end
	
	info = ArkInventory.Tradeskill.isResultItem( h )
	if info then
		return ArkInventory.Tradeskill.Const.Type.Result, info
	end
	
	key = ArkInventory.Tradeskill.isRecipeItem( h )
	if key then
		info = ArkInventory.Tradeskill.isEnchant( key )
		return ArkInventory.Tradeskill.Const.Type.Recipe, info
	end
	
end


local function helper_GoodToScan( )
	
	if not TradeSkillFrame:IsVisible( ) then
		--ArkInventory.Output( "SCAN ABORTED> window is no longer open" )
		return
	end
	
	if not C_TradeSkillUI.IsTradeSkillReady( ) then
		--ArkInventory.Output( "SCAN ABORTED> not ready" )
		return
	end
	
	if C_TradeSkillUI.IsTradeSkillGuild( ) then
		--ArkInventory.Output( "SCAN ABORTED> guild linked" )
		return
	end
	
	if C_TradeSkillUI.IsTradeSkillLinked( ) then
		
		local codex = ArkInventory.GetPlayerCodex( )
		local link, linkedPlayerName = C_TradeSkillUI.GetTradeSkillListLink( )
		
		local osd = ArkInventory.ObjectStringDecode( link )
		if osd.id ~= codex.player.data.info.guid then
			--ArkInventory.Output( "SCAN ABORTED> linked from another player: ", osd.id, " (", linkedPlayerName, ")" )
			return
		else
			--ArkInventory.Output( "LINKED> but its mine: ", osd.id )
			-- although the number of recipies dont seem to line up???
			-- posibly due the higher ranked recipes not being included in a linked list
			-- or it could be something else, when i figure it out i'll do something with it
			--ArkInventory.Output( "SCAN ABORTED> linked has issues i need to sort out first" )
			return
		end
		
	end
	
	local tradeSkillID, skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier, parentSkillLineID, parentSkillLineName =  C_TradeSkillUI.GetTradeSkillLine( )
	return parentSkillLineID or tradeSkillID
	
end

local function helper_LoadRecipe( skillID, rid )
	
	local cache = collection.cache
	local osd
	
	
	
	--/dump C_TradeSkillUI.GetRecipeInfo( 184493 )
	local info = C_TradeSkillUI.GetRecipeInfo( rid )
	if info and info.type == "recipe" then
		
		info.link = C_TradeSkillUI.GetRecipeLink( rid )
		osd = ArkInventory.ObjectStringDecode( info.link )
		key = osd.h_base
		
		if not cache[key] then
			
			info.key = key
			info.skillID = skillID
			
			info.recipeHB = key
			
			info.resultLink = C_TradeSkillUI.GetRecipeItemLink( rid )
			osd = ArkInventory.ObjectStringDecode( info.resultLink )
			info.resultHB = osd.h_base
			
			if osd.id == 0 or osd.h_base == key then
				info.resultLink = "item:0"
				info.resultHB = "0"
			end
			
			if info.previousRecipeID then
				osd = C_TradeSkillUI.GetRecipeLink( info.previousRecipeID )
				osd = ArkInventory.ObjectStringDecode( osd )
				info.previousRecipeID = osd.id
				info.previousRecipeHB = osd.h_base
			end
			
			if info.nextRecipeID then
				osd = C_TradeSkillUI.GetRecipeLink( info.nextRecipeID )
				osd = ArkInventory.ObjectStringDecode( osd )
				info.nextRecipeID = osd.id
				info.nextRecipeHB = osd.h_base
			end
			
			
			cache[key] = info
			
			update = true
			
			
		elseif cache[key].learned ~= info.learned then
			update = true
		end
		
		
	end
	
	return key, info, update
	
end

local function Scan_UI( )
	
	local update = false
	
	if not helper_GoodToScan( ) then
		--ArkInventory.Output( "NOT READY TO SCAN" )
		return
	end
	
	local codex = ArkInventory.GetPlayerCodex( )
	local link, linkedPlayerName = C_TradeSkillUI.GetTradeSkillListLink( )
	local tradeSkillID, skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier, parentSkillLineID, parentSkillLineName =  C_TradeSkillUI.GetTradeSkillLine( )
	
	local skillID = parentSkillLineID or tradeSkillID
	local name = parentSkillLineName or skillLineName
	--ArkInventory.Output( "SCANNING [", skillID, "]=[", name, "]" )
	
	local recipeList = C_TradeSkillUI.GetAllRecipeIDs( )
	
	local sd = collection.sv.data[skillID]
	sd.id = skillID
	sd.link = link
	sd.name = name
	sd.icon = C_TradeSkillUI.GetTradeSkillTexture( skillID )
	sd.numTotal = #recipeList
	
	local cache = collection.cache
	local sv = collection.sv
	local known = 0
	local info, osd, key
	for _, rid in pairs( recipeList ) do
		
		key, info, update = helper_LoadRecipe( skillID, rid )
		if info then
			
			if info.learned then
				known = known + 1
			end
			
			sv.enchant[key].s = skillID
			
			if sv.enchant[key].r == "0" then
				-- do not update unless result is empty.  it shouldnt change from blizzards side, and we can clear it if we have to, but this allows us to correct it
				sv.enchant[key].r = info.resultHB
			end
			
			if ArkInventory.Global.dataexport then
				sv.enchant[key].cat = cache[key].categoryID
				sv.enchant[key].name = cache[key].name
				sv.enchant[key].src = cache[key].sourceType
			end
			
			
			osd = ArkInventory.ObjectStringDecode( info.resultLink )
			if osd.h_base ~= key then
				--collection.result[osd.h_base] = key
				--ArkInventory.Output( "sv.result[", info.resultHB, "][", key, "] = ", skillID )
				sv.result[osd.h_base][key] = skillID
			end
			
			if update then
				helper_CreateXrefKeys( key, info.resultHB )
			end
			
		else
			
			ArkInventory.OutputWarning( "bad recipe data: ", rid, " = ", info )
			
		end
		
	end
	sd.numKnown = known
	
	
	local ranks = { }
	local rank, xid, xinfo
	for key, info in pairs( cache ) do
		if info.skillID == skillID and ( info.previousRecipeHB or info.nextRecipeHB ) and not info.rank then
			
			xinfo = info
			
			xid = xinfo.recipeHB
			while xid do
				
				xinfo = cache[xid]
				if not xinfo then
					ArkInventory.OutputWarning( "code issue: tradeskill rank (prev) chain is broken at ", xid )
				end
				
				xid = xinfo.previousRecipeHB
				
			end
			-- xinfo is at the base recipe
			
			
			
			-- now we go back up
			ArkInventory.Table.Wipe( ranks )
			rank = 0
			
			xid = xinfo.recipeHB
			while xid do
				
				xinfo = cache[xid]
				if not xinfo then
					ArkInventory.OutputWarning( "code issue: tradeskill rank (next) chain is broken at ", xid )
				end
				
				rank = rank + 1
				xinfo.rank = rank
				table.insert( ranks, xid )
				if ArkInventory.Global.dataexport then
					sv.enchant[xid].rank = rank
				end
				
				xid = xinfo.nextRecipeHB
				
			end
			
			-- update max rank on entire chain
			for _, xid in pairs( ranks ) do
				xinfo = cache[xid]
				xinfo.rankMax = rank
			end
			
		end
		
	end
	
	
	--ArkInventory.Output( "SCAN COMPLETE> ", sd.numTotal, " exist, ", sd.numKnown, " known" )
	
	collection.queue[skillID] = nil
	
	if update then
		--ArkInventory.Output( "SCHEDULE UPDATE" )
		ArkInventory:SendMessage( "EVENT_ARKINV_TRADESKILL_UPDATE_BUCKET", "UPDATE" )
	else
		--ArkInventory.Output( "IGNORED (NO UPDATES FOUND)" )
	end
	
end

local function Scan_Threaded( thread_id )
	
	--ArkInventory.Output( "SCAN THREAD START" )
	
	if collection.hasSound == nil then
		collection.hasSound = ArkInventory.CrossClient.GetCVarBool( "Sound_EnableSFX" )
		--ArkInventory.Output( "AUDIO IS MUTED? ", not hasSound )
	end
	
	if collection.hasSound then
		ArkInventory.CrossClient.SetCVar( "Sound_EnableSFX", "0" )
		ArkInventory.ThreadYield( thread_id )
	end
	
	
	while true do
		
		-- infinite loop until queue is empty
		
		--ArkInventory.Output( "QUEUE: ", collection.queue )
		
		-- get next in queue
		local skillID
		for k in pairs( collection.queue ) do
			skillID = k
			break
		end
		
		if not skillID then
			if collection.hasSound then
				-- restore sound
				ArkInventory.CrossClient.SetCVar( "Sound_EnableSFX", "1" )
				ArkInventory.ThreadYield( thread_id )
			end
			collection.hasSound = nil
			return
		end
		
		
		--ArkInventory.Output( " " )
		
		if TradeSkillFrame and TradeSkillFrame:IsVisible( ) and collection.isOpened then
			-- i opened it but its not closed
			-- the thread probably got restarted
			-- close it and keep going
			--ArkInventory.Output( "THREAD RESTART? - WINDOW IS OPEN - CLOSING WINDOW" )
			
			C_TradeSkillUI.CloseTradeSkill( )
			ArkInventory.ThreadYield( thread_id )
			
		end
		
		
		--ArkInventory.Output( "CHECK WINDOW IS CLOSED" )
		--while not collection.isClosed do
		while TradeSkillFrame and TradeSkillFrame:IsVisible( ) do
			-- if the user has the tradeskill window opened, wait here until it is closed
			ArkInventory.ThreadYield( thread_id )
		end
		--ArkInventory.Output( "WINDOW IS CLOSED" )
		
		
		--ArkInventory.Output( "OPEN WINDOW [", skillID, "]" )
		collection.isScanDone = false
		collection.isOpened = true
		
		C_TradeSkillUI.OpenTradeSkill( skillID )
		ArkInventory.ThreadYield( thread_id )
		
		
		-- wait for the event to trigger a scan and get back to us
		while not collection.isScanDone do
			--ArkInventory.Output( "WAITING FOR SCAN [", skillID, "]" )
			ArkInventory.ThreadYield( thread_id )
		end
		
		--ArkInventory.Output( "SCAN COMPLETED [", skillID, "]" )
		
		-- have to close the window or archaeology causes issues with the next tradeskill as it wasnt meant to be opened this way
		
		
		--ArkInventory.Output( "CLOSING WINDOW" )
		
		C_TradeSkillUI.CloseTradeSkill( )
		ArkInventory.ThreadYield( thread_id )
		
		while TradeSkillFrame and TradeSkillFrame:IsVisible( ) do
			-- if the user has the tradeskill window opened, wait here until it is closed
			ArkInventory.ThreadYield( thread_id )
		end
		collection.isOpened = false
		
		--ArkInventory.Output( "WINDOW IS CLOSED" )
		
	end
	
	--ArkInventory.Output( "SCAN THREAD END" )
	
	
end

local function Scan( )
	
	ArkInventory.Tradeskill.ImportCrossRefTable( )
	
	--ArkInventory.Output( "SCAN START" )
	
	local thread_id = ArkInventory.Global.Thread.Format.Tradeskill
	local thread_function = function ( )
		Scan_Threaded( thread_id )
	end
	
	if ArkInventory.Global.Thread.Use then
		ArkInventory.ThreadStart( thread_id, thread_function )
	else
		local tz = debugprofilestop( )
		ArkInventory.OutputThread( thread_id, " start" )
		thread_function( )
		tz = debugprofilestop( ) - tz
		ArkInventory.OutputThread( string.format( "%s took %0.0fms", thread_id, tz ) )
		return
	end
	
end

function ArkInventory.Tradeskill.ScanHeaders( )
	
	--ArkInventory.Output( "Tradeskill.ScanHeaders" )
	
	if not ArkInventory.Global.Mode.Database then
		-- not ready yet
		ArkInventory:SendMessage( "EVENT_ARKINV_TRADESKILL_UPDATE_BUCKET", "SCAN_HEADERS" )
		return
	end
	
	local loc_id = ArkInventory.Const.Location.Tradeskill
	local codex = ArkInventory.GetPlayerCodex( )
	
	if not collection.isReady then
		--ArkInventory.Output( "tradeskill ready" )
		collection.isReady = true
		collection.sv = ArkInventory.db.cache.tradeskill
		ArkInventory.ObjectCacheTooltipClear( )
	end
	
	local p = { ArkInventory.CrossClient.GetProfessions( ) }
	--ArkInventory.Output( "skills active = [", p, "]" )
	
	local info = codex.player.data.info
	info.tradeskill = info.tradeskill or { }
	--ArkInventory.Output( "skills saved = [", info.tradeskill, "]" )
	
	local changed = false
	for index = 1, ArkInventory.Const.Tradeskill.maxLearn do
		
		if p[index] then
			
			local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier = ArkInventory.CrossClient.GetProfessionInfo( p[index] )
			
			if info.tradeskill[index] ~= skillLine then
				
				if info.tradeskill[index] then
					
					-- had a different skill here before
					
					local oldSkillID = info.tradeskill[index]
					--ArkInventory.Output( "tradeskill [", index, "] changed from [", oldSkillID, "] ", ArkInventory.Const.Tradeskill.Data[oldSkillID].text, " to [", skillLine, "] ", name )
					
					-- need to clean codex.player.data.tradeskill.data[oldSkillID]
					
				else
					
					-- learnt a tradeskill
					--ArkInventory.Output( "tradeskill [", index, "] learnt [", skillLine, "] [", name, "]" )
					collection.queue[skillLine] = true
					
				end
				
				changed = true
				info.tradeskill[index] = skillLine
				
			end
			
			if ArkInventory.isLocationMonitored( loc_id ) and codex.profile.location[loc_id].loadscan and not collection.isInit then
				--ArkInventory.Output( "QUEUE ADD ", skillLine )
				if Skillet and Skillet:IsEnabled( ) then
					-- ignore scan on load
				else
					collection.queue[skillLine] = true
					changed = true
				end
			end
			
		else
			
			if info.tradeskill[index] ~= nil then
				
				local oldSkillID = info.tradeskill[index]
				--ArkInventory.Output( "tradeskill [", index, "] unlearned [", oldSkillID, "] ", ArkInventory.Const.Tradeskill.Data[oldSkillID].text )
				
				-- need to clean codex.player.data.tradeskill.data[oldSkillID]
				
				changed = true
				info.tradeskill[index] = nil
				
			end
			
		end
		
	end
	
	--ArkInventory.Output( "skills = ", info.tradeskill )
	collection.isInit = true
	
	if changed then
		ArkInventory.ItemCacheClear( )
		ArkInventory.Frame_Main_DrawStatus( nil, ArkInventory.Const.Window.Draw.Recalculate )
	end
	
	--ArkInventory.Output( "QUEUE_START" )
	ArkInventory:SendMessage( "EVENT_ARKINV_TRADESKILL_UPDATE_BUCKET", "QUEUE_START" )
	
end

function ArkInventory.Tradeskill.OnEnable( )
	
	--ArkInventory.Output( "tradeskill onenable" )
	local loc_id = ArkInventory.Const.Location.Tradeskill
	
	collection.isReady = false
	collection.isInit = false
	
	ArkInventory.Tradeskill.ScanHeaders( )
	
	ArkInventory.ObjectCacheTooltipClear( )
	--ArkInventory.ObjectCacheCountClear( nil, nil, loc_id )
	
end

function ArkInventory:EVENT_ARKINV_TRADESKILL_UPDATE_BUCKET( events )
	
	--ArkInventory.Output( "TRADESKILL BUCKET [", events, "]" )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	local loc_id = ArkInventory.Const.Location.Tradeskill
	if not ArkInventory.isLocationMonitored( loc_id ) then
		--ArkInventory.Output( "IGNORED (NOT MONITORED)" )
		return
	end
	
	
	if events["SCAN_HEADERS"] or events["SKILL_LINES_CHANGED"] then
		ArkInventory.Tradeskill.ScanHeaders( )
	end
	
	if events["NEW_RECIPE_LEARNED"] then
		-- do something with this?
	end
	
	if events["UPDATE"] then
		--ArkInventory.Output( "UPDATE LOCATION ", loc_id )
		--ArkInventory.ScanLocation( loc_id )
	end
	
	if events["QUEUE_START"] then
		Scan( )
	end
	
end

function ArkInventory:EVENT_ARKINV_TRADESKILL_UPDATE( event, ... )
	
	--ArkInventory.Output( "EVENT [", event, "]" )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	local loc_id = ArkInventory.Const.Location.Tradeskill
	if not ArkInventory.isLocationMonitored( loc_id ) then
		--ArkInventory.Output( "IGNORED (NOT MONITORED)" )
		return
	end
	
	
	if event == "SKILL_LINES_CHANGED" then
		ArkInventory:SendMessage( "EVENT_ARKINV_TRADESKILL_UPDATE_BUCKET", event )
		return
	end
	
	local codex = ArkInventory.GetPlayerCodex( )
	if not ArkInventory.isLocationMonitored( loc_id ) then
		--ArkInventory.Output( "IGNORED (TRADESKILL NOT MONITORED)" )
		return
	end
	
	
	if event == "TRADE_SKILL_CLOSE" then
		collection.isClosed = true
		return
	end
	
	
	if event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
		
		if not collection.isScanning then
			collection.isClosed = false
			collection.isScanning = true
			Scan_UI( )
			collection.isScanning = false
			collection.isScanDone = true
		else
			--ArkInventory.Output( "IGNORED (TRADESKILL BEING SCANNED???)" )
		end
		
		return
		
	end
	
	ArkInventory:SendMessage( "EVENT_ARKINV_TRADESKILL_UPDATE_BUCKET", event )
	
end
