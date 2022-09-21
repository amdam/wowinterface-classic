local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


local junk_addons = {"Scrap","SellJunk","ReagentRestocker"}
function ArkInventory.JunkProcessCheck( name )
	for _, a in pairs( junk_addons ) do
		--ArkInventory.Output( "checking ", a )
		if IsAddOnLoaded( a ) and _G[a] then
			ArkInventory.OutputWarning( string.format( ArkInventory.Localise["CONFIG_JUNK_PROCESSING_DISABLED_DESC"], a ) )
			return false, a
		end
	end
	return true
end

function ArkInventory.JunkCheck( i, codex )
	
	local isJunk = false
	local vendorPrice = -1
	
	if i and i.h then
		
		local info = i.info or ArkInventory.GetObjectInfo( i.h )
		
		if info.ready then
			
			if IsAddOnLoaded( "Scrap" ) and Scrap then
				
				if Scrap:IsJunk( info.id ) then
					isJunk = true
				end
				
			elseif IsAddOnLoaded( "SellJunk" ) and SellJunk then
				
				if ( info.q == 0 and not SellJunk:isException( i.h ) ) or ( info.q ~= 0 and SellJunk:isException( i.h ) ) then
					isJunk = true
				end
				
			elseif IsAddOnLoaded( "ReagentRestocker" ) and ReagentRestocker then
				
				if ReagentRestocker:isToBeSold( info.id ) then
					isJunk = true
				end
				
			elseif codex then
				
				if not isJunk then
					local cat_id = ArkInventory.ItemCategoryGet( i )
					local cat_type, cat_num = ArkInventory.CategoryIdSplit( cat_id )
					
					isJunk = i.q <= ArkInventory.db.option.junk.raritycutoff and codex.catset.category.junk[cat_type][cat_num] == true
--					if isJunk then
--						ArkInventory.Output( i.h, " = ", cat_type, "!", cat_num )
--					end
				end
				
			end
			
		end
		
		if isJunk then
			vendorPrice = info.vendorprice or vendorPrice
		end
		
	end
	
	return isJunk, vendorPrice
	
end

function ArkInventory.JunkIterate( )
	
	local loc_id = ArkInventory.Const.Location.Bag
	local codex = ArkInventory.GetLocationCodex( loc_id )
	
	local bag_id = 1
	local slot_id = 0
	
	local player = ArkInventory.GetPlayerStorage( nil, loc_id )
	local i
	
	local bags = ArkInventory.Global.Location[loc_id].Bags
	local blizzard_id = bags[bag_id]
	local numslots = GetContainerNumSlots( blizzard_id )
	
	local _, isJunk, isLocked, itemCount, itemLink, vendorPrice
	
	
	return function( )
		
		isJunk = false
		itemLink = nil
		itemCount = 0
		vendorPrice = -1
		
		while not isJunk do
			
			if slot_id < numslots then
				slot_id = slot_id + 1
			elseif bag_id < #bags then
				bag_id = bag_id + 1
				blizzard_id = bags[bag_id]
				numslots = GetContainerNumSlots( blizzard_id )
				slot_id = 1
			else
				blizzard_id = nil
				slot_id = nil
				itemCount = nil
				itemLink = nil
				vendorPrice = -1
				break
			end
			
			_, itemCount, isLocked, _, _, _, itemLink = GetContainerItemInfo( blizzard_id, slot_id )
			
			if itemCount and not isLocked and itemLink then
				isJunk, vendorPrice = ArkInventory.JunkCheck( player.data.location[loc_id].bag[bag_id].slot[slot_id], codex )
			end
			
		end
		
		--ArkInventory.Output( itemLink, " / ", itemCount, " / ", vendorPrice )
		return blizzard_id, slot_id, itemLink, itemCount, vendorPrice
		
	end
	
end

local function JunkDestroy( )
	
	ArkInventory.Global.Junk.destroyed = 0
	
	if not ArkInventory.db.option.junk.delete then
		return
	end
		
	for blizzard_id, slot_id, itemLink, itemCount, vendorPrice in ArkInventory.JunkIterate( ) do
		
		if vendorPrice == 0 then
			
			if ArkInventory.db.option.junk.list then
				if ArkInventory.Global.Junk.destroyed == 0 then
					ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_JUNK_LIST_DESTROY_DESC"], itemCount, itemLink ) )
				end
			end
			
			if not ArkInventory.db.option.junk.test then
				if ArkInventory.Global.Junk.destroyed == 0 then
					
					if not ArkInventory.db.option.junk.combat and InCombatLockdown( ) then
						ArkInventory.OutputWarning( ArkInventory.Localise["CONFIG_JUNK_SELL_BINDING"], " aborted, you are in combat" )
						break
					end
					
					PickupContainerItem( blizzard_id, slot_id )
					DeleteCursorItem( )
					-- protected after 9.0.2 so can no longer delete items automatically, using a keybinding instead, but only one item can be destroyed per keypress
					-- must also run non threaded or it will fail due to no longer being the same execution path that was launched from the keybinding
				end
			end
			
			ArkInventory.Global.Junk.destroyed = ArkInventory.Global.Junk.destroyed + 1
			
		end
		
	end
	
	if ArkInventory.Global.Junk.destroyed > 1 then
		ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, string.format( ArkInventory.Localise["CONFIG_JUNK_LIST_DESTROY_LIMIT"], ArkInventory.Global.Junk.destroyed - 1 ) )
	end
	
	if ArkInventory.db.option.junk.test then
		if ArkInventory.Global.Junk.destroyed > 0 then
			ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["CONFIG_JUNK_TESTMODE_ALERT_DESTROYED"] )
		end
	end
	
	ArkInventory.Global.Junk.destroyed = 0
	
end

local function JunkSell_Threaded( thread_id, manual )
	
	if not ArkInventory.Global.Mode.Merchant then
		--ArkInventory.Output( "ABORTED (NOT AT MERCHANT)" )
		return
	end
	
--	ArkInventory.Output( "start amount ", GetMoney( ) )
	ArkInventory.Global.Junk.money = GetMoney( )
	
	local limit = ( ArkInventory.db.option.junk.limit and BUYBACK_ITEMS_PER_PAGE ) or 0
	
	for blizzard_id, slot_id, itemLink, itemCount, vendorPrice in ArkInventory.JunkIterate( ) do
		
		if vendorPrice == 0 then
			
			ArkInventory.Global.Junk.destroyed = ArkInventory.Global.Junk.destroyed + 1
			
		elseif vendorPrice > 0 then
			
			ArkInventory.Global.Junk.sold = ArkInventory.Global.Junk.sold + 1
			
			if limit > 0 and ArkInventory.Global.Junk.sold > limit then
				-- limited to buyback page
				ArkInventory.Global.Junk.sold = limit
				ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, string.format( ArkInventory.Localise["CONFIG_JUNK_NOTIFY_LIMIT"], limit ) )
				return
			end
			
			if ArkInventory.db.option.junk.list then
				ArkInventory.Output( string.format( ArkInventory.Localise["CONFIG_JUNK_LIST_SELL_DESC"], itemCount, itemLink, ArkInventory.MoneyText( itemCount * vendorPrice, true ) ) )
			end
			
			if not ArkInventory.db.option.junk.test then
				if ArkInventory.Global.Mode.Merchant then
					
					if not ArkInventory.db.option.junk.combat and InCombatLockdown( ) then
						ArkInventory.OutputWarning( ArkInventory.Localise["CONFIG_JUNK_SELL_BINDING"], " aborted, you are in combat" )
						break
					end
					
					-- this will sometimes fail, without any notifcation, so you cant just add up the values as you go
					-- GetMoney doesnt update in real time so also cannot be used here
					-- next best thing, record how much money we had beforehand and how much we have at the next PLAYER_MONEY, then output it there
					UseContainerItem( blizzard_id, slot_id )
					ArkInventory.ThreadYield( thread_id )
					
				end
			end
			
		end
		
	end
	
	
	if ArkInventory.db.option.junk.test then
		if ArkInventory.Global.Junk.sold > 0 then
			ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["CONFIG_JUNK_TESTMODE_ALERT_SOLD"] )
		end
	end
	
	if not manual then
		if ArkInventory.Global.Junk.destroyed > 0 then
			ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, string.format( ArkInventory.Localise["CONFIG_JUNK_SELL_CANDESTROY"], ArkInventory.Global.Junk.destroyed ) )
		end
	end
	
	ArkInventory.Global.Junk.destroyed = 0
	
	
	
	--ArkInventory.Output( "tried to sell ", ArkInventory.Global.Junk.sold, " items" )
	
	-- notifcation is at EVENT_ARKINV_PLAYER_MONEY, call it in case it tripped before the final yield came back
--	ArkInventory:SendMessage( "EVENT_ARKINV_PLAYER_MONEY_BUCKET", "JUNK" )
	
end

function ArkInventory.JunkSell( manual )
	
	if not ArkInventory.Global.Junk.process then return end
	
	if not manual and not ArkInventory.db.option.junk.sell then
		return
	end
	
	if not ArkInventory.Global.Thread.Use then
		ArkInventory.OutputWarning( ArkInventory.Localise["CONFIG_JUNK_SELL_BINDING"], " aborted, as threads are currently disabled." )
		return
	end
	
	if manual then
		ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["CONFIG_JUNK_SELL_BINDING"], " ", ArkInventory.Localise["CONFIG_JUNK_SELL_BINDING_MANUAL"] )
	else
		if ArkInventory.Global.Junk.running then
			ArkInventory.OutputWarning( ArkInventory.Localise["CONFIG_JUNK_SELL_BINDING"], " is already running, please wait" )
			return
		else
			ArkInventory.Output( LIGHTYELLOW_FONT_COLOR_CODE, ArkInventory.Localise["CONFIG_JUNK_SELL_BINDING"], " ", ArkInventory.Localise["CONFIG_JUNK_SELL_BINDING_AUTO"] )
		end
	end
	
	if manual then
		JunkDestroy( )
	end
	
	ArkInventory.Global.Junk.sold = 0
	ArkInventory.Global.Junk.money = 0
	
	local thread_id = ArkInventory.Global.Thread.Format.JunkSell
	
	local tf = function ( )
		ArkInventory.Global.Junk.running = true
		JunkSell_Threaded( thread_id, manual )
		ArkInventory.Global.Junk.running = false
	end
	
	ArkInventory.ThreadStart( thread_id, tf )
	
end
