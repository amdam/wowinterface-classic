local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table



ArkInventory.Search = { }

function ArkInventory.Search.Frame_Hide( )
	
	local frame = ArkInventory.Search.frame
	
	if frame then
		frame:Hide( )
	end
	
end
	
function ArkInventory.Search.Frame_Show( )
	
	local frame = ArkInventory.Search.frame
	
	if frame then
		frame:Show( )
		ArkInventory.Frame_Main_Level( frame )
	end
	
end

function ArkInventory.Search.Frame_Toggle( )
	
	local frame = ArkInventory.Search.frame
	
	if frame then
		if frame:IsVisible( ) then
			ArkInventory.Search.Frame_Hide( )
		else
			ArkInventory.Search.Frame_Show( )
		end
	else
		ArkInventory.OutputWarning( ArkInventory.Localise["MISC_ALERT_SEARCH_NOT_LOADED"] )
	end
	
end


function ArkInventory.Search.CleanText( txt )
	
	local txt = string.lower( ArkInventory.TooltipCleanText( txt ) )
	
	--txt = string.gsub( txt, "%[ ", "%[" )
	--txt = string.gsub( txt, " %]", "%]" )
	--txt = string.gsub( txt, "%[%]", "" )
	txt = string.gsub( txt, "#", "" )
	
	txt = string.gsub( txt, "  ", " " )
	
	return txt
	
end


function ArkInventory.Search.GetContent( h )
	
	if not h or h == "" then
		return ""
	end
	
	local search_id = ArkInventory.ObjectIDSearch( h )
	local txt = ""
	
	if ArkInventory.Global.Cache.ItemSearchData[search_id] then
		
		txt = ArkInventory.Global.Cache.ItemSearchData[search_id]
		
	else
		
		local info = ArkInventory.GetObjectInfo( search_id )
		
		local q = info.q
		if type( q ) == "number" then
			q = _G[string.format( "ITEM_QUALITY%d_DESC", q )] or q
		end
		
		local tooltip = ArkInventory.Global.Tooltip.Scan
		local txt1, txt2
		
		if info.class == "item" or info.class == "keystone" then
			
			local s
			ArkInventory.TooltipSetHyperlink( tooltip, search_id )
			
			txt1, txt2 = ArkInventory.TooltipGetLine( tooltip, 1 )
			-- check for no response??
			
			for i = 2, ArkInventory.TooltipGetNumLines( tooltip ) do
				txt1, txt2 = ArkInventory.TooltipGetLine( tooltip, i, true )
				txt = string.format( "%s #%s# #%s#", txt, txt1, txt2 )
			end
			
			for z in pairs( ITEM_QUALITY_COLORS ) do
				s = string.format( "#%s#", _G[string.format( "ITEM_QUALITY%d_DESC", z )] or "" )
				txt = string.gsub( txt, s, "" )
			end
			
			for _, z in pairs( ArkInventory.Const.Bindings.All ) do
				s = string.format( "#%s#", z )
				txt = string.gsub( txt, s, "" )
			end
			
			s = string.format( "#%s#", ArkInventory.Localise["ALREADY_KNOWN"] )
			txt = string.gsub( txt, s, "" )
			
			local equiploc = info.equiploc
			if type( equiploc ) == "string" and equiploc ~= "" and _G[equiploc] then
				equiploc = _G[equiploc]
			end
			
			txt = string.format( "%s #%s# #%s# #%s#", txt, equiploc, info.itemtype, info.itemsubtype )
			
		elseif info.class == "battlepet" then
			
			if info.sd then
				txt = string.format( "#%s# #%s#", info.sd.sourceText or "", info.sd.description or "" )
			end
			
		elseif info.class == "currency" then
			
			--local object = ArkInventory.Collection.Currency.GetByID( info.osd[2] )
			--tooltip:SetCurrencyTokenByID( info.osd[2] )
			
			--txt1 = ArkInventory.TooltipGetLine( tooltip, 2 )
			--txt = string.format( "#%s#", info.description or "" )
			
		elseif info.class == "reputation" then
			
			--local object = ArkInventory.Collection.Reputation.GetByID( info.osd[2] )
			
			--txt = string.format( "#%s#", info.description or "" )
			
		end
		
		txt = string.format( "#%s# %s #%s#", info.name, txt, q )
		txt = ArkInventory.Search.CleanText( txt )
		
		if info.ready then
			ArkInventory.Global.Cache.ItemSearchData[search_id] = txt
		end
		
	end
	
	
	return txt
	
end
