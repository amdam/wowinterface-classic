local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table
local C_Reputation = _G.C_Reputation

local loc_id = ArkInventory.Const.Location.Reputation

ArkInventory.Collection.Reputation = { }

local collection = {
	
	isInit = false,
	isScanning = false,
	isReady = false,
	
	numTotal = 0, -- number of total reputations
	numOwned = 0, -- number of known reputations
	
	list = { }, -- [index] = { } - reputations and headers in order from the blizard frame
	cache = { }, -- [id] -- all reputations
	
	filter = {
		ignore = false,
		expanded = { },
		backup = false,
	},
	
}

local ImportCrossRefTable = true

function ArkInventory.Collection.Reputation.ImportCrossRefTable( )
	
	if not ImportCrossRefTable then return end
	
	local rid, item, key1, key2
	
	for k, v in ArkInventory.Lib.PeriodicTable:IterateSet( "ArkInventory.System.XREF.Reputation" ) do
		
		item = tonumber( k ) or 0
		rid = tonumber( v ) or 0
		
		if rid > 0 and item > 0 then
			
			key1 = ArkInventory.ObjectIDCount( string.format( "item:%s", item ) )
			key2 = ArkInventory.ObjectIDCount( string.format( "reputation:%s", rid ) )
			
			--ArkInventory.Output2( key1, " / ", key2 )
			
			if not ArkInventory.Global.ItemCrossReference[key1] then
				ArkInventory.Global.ItemCrossReference[key1] = { }
			end
			
			ArkInventory.Global.ItemCrossReference[key1][key2] = true
			
			if not ArkInventory.Global.ItemCrossReference[key2] then
				ArkInventory.Global.ItemCrossReference[key2] = { }
			end
			
			ArkInventory.Global.ItemCrossReference[key2][key1] = true
			
		end
		
	end
	
	ImportCrossRefTable = nil
	
end

local function FilterActionBackup( )
	
	if collection.filter.backup then return end
	
	local n, e, c
	local p = 0
	ArkInventory.Table.Wipe( collection.filter.expanded )
	
	collection.filter.ignore = true
	
	repeat
		
		p = p + 1
		n = GetNumFactions( )
		--ArkInventory.Output( "pass=", p, " num=", n )
		e = true
		
		for index = 1, n do
			
			local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo( index )
			
			if isHeader and isCollapsed then
				--ArkInventory.Output( "expanding ", index, " / ", name )
				collection.filter.expanded[name] = true
				ExpandFactionHeader( index )
				e = false
				break
			end
			
		end
		
	until e or p > n * 1.5
	
	collection.filter.ignore = false
	
	collection.filter.backup = true
	
end

local function FilterActionRestore( )
	
	if not collection.filter.backup then return end
	
	local n, e, c
	local p = 0
	
	collection.filter.ignore = true
	
	repeat
		
		p = p + 1
		n = GetNumFactions( )
		--ArkInventory.Output( "pass=", p, " num=", n )
		e = true
		
		for index = 1, n do
			
			local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo( index )
			
			if isHeader and not isCollapsed and collection.filter.expanded[name] then
				--ArkInventory.Output( "collapsing ", index, " / ", name )
				collection.filter.expanded[name] = nil
				CollapseFactionHeader( index )
				e = false
				break
			end
			
		end
		
	until e or p > n * 1.5
	
	collection.filter.ignore = false
	
	collection.filter.backup = false
	
end

function ArkInventory.Collection.Reputation.OnHide( )
	--ArkInventory.Output2( "Reputation.OnHide" )
	ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_REPUTATION_UPDATE_BUCKET", "FRAME_CLOSED" )
end

function ArkInventory.Collection.Reputation.IsReady( )
	return collection.isReady
end

function ArkInventory.Collection.Reputation.GetCount( )
	return collection.numOwned, collection.numTotal
end

function ArkInventory.Collection.Reputation.Iterate( )
	local t = collection.cache
	return ArkInventory.spairs( t, function( a, b ) return ( t[a].name or "" ) < ( t[b].name or "" ) end )
end

function ArkInventory.Collection.Reputation.GetByID( id )
	if type( id ) == "number" then
		return collection.cache[id]
	end
end

function ArkInventory.Collection.Reputation.LevelText( ... )
	
	if not ArkInventory.Collection.Reputation.IsReady( ) then
		return "data not ready yet"  -- !!!fix me
	end
	
	local id, style, standingText, barValue, barMax, isCapped, paragonLevel, hasReward = ...
	
	local n = select( '#', ... )
	
	if n == 0 then
		return "no repuation data"  -- !!!fix me
	end
	
--[[
	*nn* = faction name
	*st* = standing text
	*pv* = paragon value (+N)
	*pr* = paragon reward icon
	*bv* = bar value
	*bm* = bar max
	*bc* = bar value / bar max
	*bp* = bar percent
	*br* = bar remaining
]]--
	
	local object = ArkInventory.Collection.Reputation.GetByID( id )
	if not object then
		return "repuation not found"  -- !!!fix me
	end
	
	local name = object.name or ArkInventory.Localise["UNKNOWN"]
	local barRemaining = 0
	--local rewardIcon = string.format( "|T%s:0|t", [[Interface\MINIMAP\TRACKING\Banker]] )
	local rewardIcon = string.format( "|T%s:0|t", [[Interface\ICONS\INV_Misc_Coin_01]] )
	
	local result = string.lower( style or ArkInventory.Const.Reputation.Style.OneLine )
	
	
	if n <= 2 then
		
		standingText = object.standingText
		barMax = object.barMax
		barValue = object.barValue
		
		isCapped = object.isCapped
		paragonLevel = object.paragonLevel
		hasReward = object.hasReward
		
	end
	
	
	standingText = standingText or ArkInventory.Localise["UNKNOWN"]
	barMax = barMax or 0
	barValue = barValue or 0
	
	isCapped = isCapped or 0
	paragonLevel = paragonLevel or 0
	hasReward = hasReward or 0
	
	
	if barValue == 0 then
		
		-- hit rep limit so clear all tokens
		result = string.gsub( result, "%*bv%*", "" )
		result = string.gsub( result, "%*bm%*", "" )
		result = string.gsub( result, "%*bc%*", "" )
		result = string.gsub( result, "%*bp%d?%*", "" )
		result = string.gsub( result, "%*br%*", "" )
		
	else
		
		result = string.gsub( result, "%*bv%*", FormatLargeNumber( barValue ) )
		result = string.gsub( result, "%*bm%*", FormatLargeNumber( barMax ) )
		result = string.gsub( result, "%*bc%*", string.format( "%s / %s", FormatLargeNumber( barValue ), FormatLargeNumber( barMax ) ) )
		
		result = string.gsub( result, "%*bp1%*", string.format( "%.1f", barValue / barMax * 100 ) .. "%%" )
		result = string.gsub( result, "%*bp2%*", string.format( "%.2f", barValue / barMax * 100 ) .. "%%" )
		result = string.gsub( result, "%*bp%d?%*", string.format( "%.0f", barValue / barMax * 100 ) .. "%%" )
		
		result = string.gsub( result, "%*br%*", FormatLargeNumber( barMax - barValue ) )
		
	end
	
	if isCapped == 1 then
		
		if paragonLevel > 0 then
			
			paragonLevel = paragonLevel - 1
			
			if paragonLevel == 0 then
				result = string.gsub( result, "%*pv%*", "" )
			else
				result = string.gsub( result, "%*pv%*", "+" .. FormatLargeNumber( paragonLevel ) )
			end
			
			if hasReward == 1 then
				result = string.gsub( result, "%*pr%*", rewardIcon )
			else
				result = string.gsub( result, "%*pr%*", "" )
			end
			
		else
			
			result = string.gsub( result, "%*pv%*", "" )
			result = string.gsub( result, "%*pr%*", "" )
			
		end
			
	else
		
		result = string.gsub( result, "%*pv%*", "" )
		result = string.gsub( result, "%*pr%*", "" )
		
	end
	
	result = string.gsub( result, "%*nn%*", name )
	result = string.gsub( result, "%*st%*", standingText )
	
	result = string.gsub( result, "%(%s*%)", "" )
	result = string.gsub( result, "\n$", "" )
	result = string.gsub( result, "|n$", "" )
	result = string.gsub( result, "  ", " " )
	result = string.trim( result )
	
	return result
	
end

function ArkInventory.Collection.Reputation.ListIterate( )
	local t = collection.list
	return ArkInventory.spairs( t, function( a, b ) return ( t[a].index or 0 ) < ( t[b].index or 0 ) end )
end

function ArkInventory.Collection.Reputation.GetByIndex( index )
	if type( index ) == "number" then
		return collection.list[index]
	end
end

function ArkInventory.Collection.Reputation.ToggleAtWar( id )
	
	if type( id ) == "number" then
		
		FilterActionBackup( )
		
		local data = ArkInventory.Collection.Reputation.GetByID( id )
		if data and data.canToggleAtWar then
			--ArkInventory.Output2( "FactionToggleAtWar( ", data.index, " )" )
			FactionToggleAtWar( data.index )
		end
		
		FilterActionRestore( )
		
	end
	
end

function ArkInventory.Collection.Reputation.ListSetActive( index, state, bulk )
	
	if type( index ) ~= "number" then return end
	if type( state ) ~= "boolean" then return end
	
	if not bulk then
		FilterActionBackup( )
	end
	
	local entry = ArkInventory.Collection.Reputation.GetByIndex( index )
	if entry then
		
		--ArkInventory.Output( state, " / ", entry.active )
		
		if state and not entry.active then
			--ArkInventory.Output2( "Active: INDEX[=", entry.index, "] NAME=[", entry.name, "]" )
			SetFactionActive( entry.index )
		end
		
		if not state and entry.active then
			--ArkInventory.Output2( "Inactive: INDEX[=", entry.index, "] NAME=[", entry.name, "]" )
			SetFactionInactive( entry.index )
		end
		
	end
	
	if not bulk then
		FilterActionRestore( )
	end
	
end

function ArkInventory.Collection.Reputation.ToggleShowAsExperienceBar( id )
	
	if type( id ) == "number" then
		
		FilterActionBackup( )
		
		local object = ArkInventory.Collection.Reputation.GetByID( id )
		if object then
			if object.isWatched then
				--ArkInventory.Output2( "SetWatchedFactionIndex( 0 )" )
				SetWatchedFactionIndex( 0 )
			else
				--ArkInventory.Output2( "SetWatchedFactionIndex( ", object.index, " )" )
				SetWatchedFactionIndex( object.index )
			end
		end
		
		FilterActionRestore( )
		
	end
	
end

function ArkInventory.Collection.Reputation.ReactivateAll( )
	
	FilterActionBackup( )
	
	for _, entry in ArkInventory.Collection.Reputation.ListIterate( ) do
		if not entry.isHeader then
			--ArkInventory.Output( "activate ", entry.index )
			ArkInventory.Collection.Reputation.ListSetActive( entry.index, true, true )
		end
	end
	
	FilterActionRestore( )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_REPUTATION_UPDATE_BUCKET", "REACTIVATE_ALL" )
	
end



local function ScanBase( id )
	
	if not id or type( id ) ~= "number" then
		return
	end
	
	local cache = collection.cache
	
	if not cache[id] then
		
		if id > 0 then
			
			local name, description, standingID, barMin, barMax, repValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfoByID( id )
			
			if name and name ~= "" then
				
				cache[id] = {
					id = id,
					link = string.format( "reputation:%s", id ),
					name = name,
					description = description,
					canToggleAtWar = canToggleAtWar,
					hasRep = hasRep,
				}
				
				collection.numTotal = collection.numTotal + 1
				
				ArkInventory.db.cache.reputation[id] = {
					n = name,
					d = description,
					w = canToggleAtWar,
					r = hasRep,
				}
				
			else
				
				local cr = ArkInventory.db.cache.reputation[id]
				if cr then
					cache[id] = {
						id = id,
						link = string.format( "reputation:%s", id ),
						name = cr.n,
						description = cr.d,
						canToggleAtWar = cr.w,
						hasRep = cr.r,
						icon = ArkInventory.Global.Location[ArkInventory.Const.Location.Reputation].Texture
					}
				end
				
			end
			
		else
			
			cache[id] = {
				id = id,
				link = "",
				name = string.format( "Header %s", math.abs( id ) ),
				description = "fake entry for an index header",
				canToggleAtWar = false,
				hasRep = false,
			}
			
		end
		
	end
	
end

local function ScanInit( )
	
	--ArkInventory.Output( "Reputation Init: Start Scan @ ", time( ) )
	
	for id = 1, 5000 do
		ScanBase( id )
	end
	
	if collection.numTotal > 0 then
		collection.isInit = true
	end
	
	--ArkInventory.Output( "Reputation Init: End Scan @ ", time( ), " [", collection.numTotal, "]" )
	
end

local function Scan_Threaded( thread_id )
	
	local update = false
	
	local numOwned = 0
	local YieldCount = 0
	
	--ArkInventory.Output( "Reputation: Start Scan @ ", time( ) )
	
	if not collection.isInit then
		ScanInit( )
		ArkInventory.ThreadYield_Scan( thread_id )
	end
	
	FilterActionBackup( )
	
	-- scan the reuptation frame (now fully expanded) for known factions
	
	ArkInventory.Table.Wipe( collection.list )
	local cache = collection.cache
	local list = collection.list
	local active = true
	local fakeID = 0
	local parentIndex
	local childIndex
	
	for index = 1, GetNumFactions( ) do
		
		YieldCount = YieldCount + 1
		
		if ReputationFrame:IsVisible( ) then
			--ArkInventory.Output( "ABORTED (REPUTATION FRAME WAS OPENED)" )
			--FilterActionRestore( )
			--return
		end
		
		local name, description, standingID, barMin, barMax, repValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo( index )
		--ArkInventory.Output2( index, " = ", name )
		
		if not factionID then
			-- cater for list headers like other and inactive that dont have a faction id assigned to them
			fakeID = fakeID - 1
			factionID = fakeID
		end
		
		if not list[index] then
			list[index] = {
				index = index,
				id = factionID,
				name = name,
				isHeader = isHeader,
				isChild = isChild,
				parentIndex = nil,
				data = nil, -- will eventually point to a cache entry
			}
		end
		
		if isHeader then
			
			childIndex = index
			
			if isChild then
				
				list[index].parentIndex = parentIndex
				
			else
				
				if name == ArkInventory.Localise["FACTION_INACTIVE"] then
					--ArkInventory.Output2( "inactive reputation header at ", index, " = ", name )
					active = false
				end
				
				parentIndex = index
				
			end
			
		else
			
			local id = name and name ~= "" and factionID
			if id then
				
				numOwned = numOwned + 1
				
				if not cache[id] then
					ScanBase( id )
					update = true
				end
				
				list[index].data = cache[id]
				list[index].parentIndex = childIndex
				
				
				-- update cached data if changed
				
				if cache[id].index ~= index then
					cache[id].index = index
					update = true
				end
				
				if cache[id].name ~= name then
					cache[id].name = name
					update = true
				end
				
				if cache[id].owned ~= true then
					cache[id].owned = true
					update = true
				end
				
				if cache[id].atWarWith ~= atWarWith then
					cache[id].atWarWith = atWarWith
					update = true
				end
				
				if cache[id].isWatched ~= isWatched then
					cache[id].isWatched = isWatched
					update = true
				end
				
				if cache[id].hasRep ~= hasRep then
					cache[id].hasRep = hasRep
					update = true
				end
				
				local icon = ArkInventory.Global.Location[ArkInventory.Const.Location.Reputation].Texture
				local barValue = 0
				local standingMax = 0
				local standingText = ""
				local isCapped = 0
				local paragonLevel = 0
				local hasParagonReward = 0
				
				local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendBarMin, friendBarMax = ArkInventory.CrossClient.GetFriendshipReputation( id )
				if friendID then
					
					cache[id].friendID = friendID
					
					local currentFriendRank, maxFriendRank = GetFriendshipReputationRanks( friendID )
					
					if not friendTexture then
						friendTexture = [[Interface\Challenges\challenges-copper]]
					end
					
					icon = friendTexture
					standingID = currentFriendRank
					standingMax = maxFriendRank
					standingText = friendTextLevel
					repValue = friendRep
					
					if friendBarMax then
						barMin = friendBarMin
						barMax = friendBarMax
					else
						barMin = repValue
						barMax = repValue
					end
					
				else
					
					standingMax = MAX_REPUTATION_REACTION
					standingText = _G["FACTION_STANDING_LABEL" .. standingID] or ArkInventory.Localise["UNKNOWN"]
					
				end
				
				
				if atWarWith then
					icon = [[Interface\Calendar\UI-Calendar-Event-PVP]]
				end
				
				
				if standingID == standingMax then
					if false then -- fix me
						-- dont care if youre 1/1000 or 1000/1000 in the last rank
						-- its really only important for the paragon reps as you have to get to the end to start the paragon stage (unless thats changed)
						isCapped = 1
					else
						if repValue == barMax and barMax == barMin then
							isCapped = 1
						end
					end
				end
				
				local isParagon = ArkInventory.CrossClient.IsFactionParagon( id )
				if isParagon then
					
					-- reputation level stops at exalted 42,000 - paragon values take over from there
					
					-- highmountain
					-- /dump GetFactionInfoByID( 1828 )
					-- /dump C_Reputation.GetFactionParagonInfo( 1828 ) 
					
					local paragonValue, paragonThreshold, paragonRewardQuestID, hasParagonRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo( id )
					
					if paragonValue and paragonThreshold and not tooLowLevelForParagon then
						
						standingText = ArkInventory.Localise["PARAGON"]
						paragonLevel = math.floor( paragonValue / paragonThreshold ) + 1
						barMin = 0
						barMax = paragonThreshold
						hasParagonReward = hasParagonRewardPending and 1 or 0
						repValue = paragonValue % paragonThreshold
						
						if hasParagonRewardPending then
							icon = [[Interface\ICONS\INV_Misc_Coin_01]]
							
							if not cache[id].notify then
								ArkInventory.Output( GREEN_FONT_COLOR_CODE, "ALERT> A paragon reward for ", cache[id].name, " is ready for collection" )
								cache[id].notify = true
							end
							
						end
						
					end
					
				end
				
				barMax = barMax - barMin
				barValue = repValue - barMin
				
				
				if cache[id].isCapped ~= isCapped then
					cache[id].isCapped = isCapped
					update = true
				end
				
				if cache[id].barValue ~= barValue then
					
					cache[id].repValue = repValue
					cache[id].standingText = standingText
					cache[id].barMin = barMin
					cache[id].barMax = barMax
					cache[id].barValue = barValue
					cache[id].paragonLevel = paragonLevel
					cache[id].hasParagonReward = paragonLevel > 0 and hasParagonReward
					
					cache[id].icon = icon or ""
					
					-- custom itemlink, not blizzard supported
					cache[id].link = string.format( "reputation:%s:%s:%s:%s:%s:%s:%s", id, standingText, barValue, barMax, isCapped, paragonLevel, hasParagonReward )
					
					update = true
					
				end
				
			end
			
		end
		
		list[index].active = active
		
		if isHeader then
			--ArkInventory.Output2( list[index] )
		end
		
		if YieldCount % ArkInventory.Const.YieldAfter == 0 then
			ArkInventory.ThreadYield_Scan( thread_id )
		end
		
	end
	
	ArkInventory.ThreadYield_Scan( thread_id )
	
	FilterActionRestore( )
	
	collection.numOwned = numOwned
	
	--ArkInventory.Output( "Reputation: End Scan @ ", time( ), " ( ", collection.numOwned, " of ", collection.numTotal, " ) update=", update )
	
	if not collection.isReady then
		collection.isReady = true
		ArkInventory:SendMessage( "EVENT_ARKINV_LDB_REPUTATION_UPDATE_BUCKET" )
	end
	
	if update then
		--ArkInventory.Output( "UPDATING" )
		ArkInventory.ScanLocation( loc_id )
	else
		--ArkInventory.Output( "IGNORED (NO UPDATES FOUND)" )
	end
	
end

local function Scan( )
	
	local thread_id = string.format( ArkInventory.Global.Thread.Format.Collection, "reputation" )
	
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

function ArkInventory:EVENT_ARKINV_COLLECTION_REPUTATION_UPDATE_BUCKET( events )
	
	--ArkInventory.Output( "REPUTATION BUCKET [", events, "]" )
	
	if not ArkInventory:IsEnabled( ) then
		--ArkInventory.Output( "IGNORED (MOD IS DISABLED)" )
		return
	end
	
	if not ArkInventory.isLocationMonitored( loc_id ) then
		--ArkInventory.Output( "IGNORED (REPUTATION NOT MONITORED)" )
		return
	end
	
	if ArkInventory.Global.Mode.Combat then
		-- set to scan when leaving combat
		--ArkInventory.Output( "IGNORED (YOU ARE IN COMBAT - WILL SCAN WHEN OUT OF COMBAT)" )
		ArkInventory.Global.LeaveCombatRun[loc_id] = true
		return
	end
	
	if ReputationFrame:IsVisible( ) then
		--ArkInventory.Output( "IGNORED (REPUTATION FRAME IS OPEN)" )
		return
	end
	
	if not collection.isScanning then
		collection.isScanning = true
		--ArkInventory.Output( "scan reputation" )
		Scan( )
		collection.isScanning = false
	else
		--ArkInventory.Output( "IGNORED (REPUTATION SCAN IN PROGRESS - WILL RESCAN WHEN FINISHED)" )
		ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_REPUTATION_UPDATE_BUCKET", "RESCAN" )
	end
	
end

function ArkInventory:EVENT_ARKINV_COLLECTION_REPUTATION_UPDATE( event, ... )
	
	--ArkInventory.Output( "REPUTATION UPDATE [", event, "]" )
	
	if event == "UPDATE_FACTION" then
		if ReputationFrame:IsVisible( ) then
			--ArkInventory.Output( "IGNORED (REPUTATION FRAME IS OPEN)" )
			return
		elseif collection.filter.ignore then
			--ArkInventory.Output( "IGNORED (FILTER CHANGED BY ME)" )
			return
		end
	end
	
	ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_REPUTATION_UPDATE_BUCKET", event )
	
end
