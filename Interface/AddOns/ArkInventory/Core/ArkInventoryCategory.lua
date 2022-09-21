local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table


local CategoryRebuildQueue = { }
local scanning = false

ArkInventory.Const.Category = {
	
	Min = 1000,
	Max = 8999,
	
	Type = {
		Default = 0,
		System = 1,
		Custom = 2,
		Rule = 3,
	},
	
	Code = {
		System = { -- do NOT change the indicies - if you have to then see the DatabaseUpgradePostLoad( ) function to remap it
			[401] = {
				id = "SYSTEM_DEFAULT",
				text = ArkInventory.Localise["DEFAULT"],
			},
			[402] = {
				id = "SYSTEM_JUNK",
				text = ArkInventory.Localise["JUNK"],
			},
			[403] = {
				id = "SYSTEM_BOUND",
				text = ArkInventory.Localise["BOUND"],
			},
			[405] = {
				id = "SYSTEM_CONTAINER",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_CONTAINER"],
			},
			[406] = {
				id = "SYSTEM_KEY",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_KEY"],
			},
			[407] = {
				id = "SYSTEM_MISC",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_MISC"],
			},
			[408] = {
				id = "SYSTEM_REAGENT",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_REAGENT"],
			},
			[409] = {
				id = "SYSTEM_RECIPE",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_RECIPE"],
			},
			[411] = {
				id = "SYSTEM_QUEST",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_QUEST"],
			},
			[414] = {
				id = "SYSTEM_EQUIPMENT",
				text = ArkInventory.Localise["EQUIPMENT"],
			},
			[416] = {
				id = "SYSTEM_EQUIPMENT_SOULBOUND",
				text = string.format( "%s (%s)", ArkInventory.Localise["EQUIPMENT"], ArkInventory.Localise["ITEM_BIND3"] ),
			},
			[456] = {
				id = "SYSTEM_EQUIPMENT_COSMETIC",
				text = string.format( "%s (%s)", ArkInventory.Localise["EQUIPMENT"], ArkInventory.Localise["COSMETIC"] ),
			},
			[444] = {
				id = "SYSTEM_EQUIPMENT_ACCOUNTBOUND",
				text = string.format( "%s (%s)", ArkInventory.Localise["EQUIPMENT"], ArkInventory.Localise["ITEM_BIND4"] ),
			},
			[415] = {
				id = "SYSTEM_MOUNT_BOUND",
				text = string.format( "%s (%s)", ArkInventory.Localise["MOUNT"], ArkInventory.Localise["BOUND"] ),
			},
			[453] = {
				id = "SYSTEM_MOUNT_TRADE",
				text = ArkInventory.Localise["MOUNT"],
			},
			[421] = {
				proj = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SYSTEM_PROJECTILE",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_PROJECTILE"],
			},
--			[421] = { SYSTEM_PROJECTILE_ARROW }
--			[422] = { SYSTEM_PROJECTILE_BULLET }
			[443] = {
				id = "SYSTEM_PET_COMPANION_TRADE",
				text = ArkInventory.Localise["PET"],
			},
			[423] = {
				id = "SYSTEM_PET_COMPANION_BOUND",
				text = string.format( "%s (%s)", ArkInventory.Localise["PET"], ArkInventory.Localise["BOUND"] ),
			},
			[441] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SYSTEM_PET_BATTLE_TRADE",
				text = ArkInventory.Localise["BATTLEPET"],
			},
			[442] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SYSTEM_PET_BATTLE_BOUND",
				text = string.format( "%s (%s)", ArkInventory.Localise["BATTLEPET"], ArkInventory.Localise["BOUND"] ),
			},
			[429] = {
				id = "SYSTEM_UNKNOWN",
				text = ArkInventory.Localise["UNKNOWN"],
			},
			[438] = {
				id = "SYSTEM_CURRENCY",
				text = ArkInventory.Localise["CURRENCY"],
			},
			[445] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SYSTEM_TOY",
				text = ArkInventory.Localise["TOY"],
			},
			[446] = {
				id = "SYSTEM_NEW",
				text = ArkInventory.Localise["CONFIG_DESIGN_ITEM_OVERRIDE_NEW"],
			},
			[447] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SYSTEM_HEIRLOOM",
				text = ArkInventory.Localise["HEIRLOOM"],
			},
--			[448] = {
--				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
--				id = "SYSTEM_ARTIFACT_RELIC",
--				text = ArkInventory.Localise["WOW_ITEM_CLASS_GEM_ARTIFACTRELIC"],
--			},
			[451] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SYSTEM_MYTHIC_KEYSTONE",
				text = ArkInventory.Localise["CATEGORY_SYSTEM_MYTHIC_KEYSTONE"],
			},
			[452] = {
				id = "SYSTEM_CRAFTING_REAGENT",
				text = ArkInventory.Localise["CRAFTING_REAGENT"],
			},
			[457] = {
				id = "SYSTEM_ITEM_BIND_PARTYLOOT",
				text = string.format( "%s (%s)", ArkInventory.Localise["EQUIPMENT"], ArkInventory.Localise["ITEM_BIND_PARTYLOOT"] ),
			},
			[458] = {
				id = "SYSTEM_ITEM_BIND_REFUNDABLE",
				text = string.format( "%s (%s)", ArkInventory.Localise["EQUIPMENT"], ArkInventory.Localise["ITEM_BIND_REFUNDABLE"] ),
			},
		},
		Consumable = {
			[404] = {
				id = "CONSUMABLE_OTHER",
				text = ArkInventory.Localise["OTHER"],
			},
			[417] = {
				id = "CONSUMABLE_FOOD",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_FOOD"],
			},
			[418] = {
				id = "CONSUMABLE_DRINK",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_DRINK"],
			},
			[419] = {
				id = "CONSUMABLE_POTION_MANA",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_POTION_MANA"],
			},
			[420] = {
				id = "CONSUMABLE_POTION_HEAL",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_POTION_HEAL"],
			},
			[424] = {
				id = "CONSUMABLE_POTION",
				text = function( )
					if not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
						return "potion category (to be fixed)"
					else
						return ArkInventory.Localise["WOW_ITEM_CLASS_CONSUMABLE_POTION"]
					end
				end,
			},
			[426] = {
				id = "CONSUMABLE_EXPLOSIVES_AND_DEVICES",
				text = function( )
					if not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
						return string.format( "%s & %s", ArkInventory.Localise["WOW_ITEM_CLASS_TRADEGOODS_EXPLOSIVES"], ArkInventory.Localise["WOW_ITEM_CLASS_TRADEGOODS_DEVICES"] )
					else
						return ArkInventory.Localise["WOW_ITEM_CLASS_CONSUMABLE_EXPLOSIVES_AND_DEVICES"]
					end
				end,
			},
			[430] = {
				id = "CONSUMABLE_ELIXIR",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_CONSUMABLE_ELIXIR"],
			},
			[431] = {
				id = "CONSUMABLE_FLASK",
				text = function( )
					if not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
						return ArkInventory.Localise["CATEGORY_CONSUMABLE_FLASK"]
					else
						return ArkInventory.Localise["WOW_ITEM_CLASS_CONSUMABLE_FLASK"]
					end
				end,
			},
			[432] = {
				id = "CONSUMABLE_BANDAGE",
				text = function( )
					if not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
						return ArkInventory.Localise["CATEGORY_CONSUMABLE_BANDAGE"]
					else
						return ArkInventory.Localise["WOW_ITEM_CLASS_CONSUMABLE_BANDAGE"]
					end
				end,
			},
			[433] = {
				proj = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CONSUMABLE_SCROLL",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_SCROLL"],
			},
			[435] = {
				id = "CONSUMABLE_ELIXIR_BATTLE",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_ELIXIR_BATTLE"],
			},
			[436] = {
				id = "CONSUMABLE_ELIXIR_GUARDIAN",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_ELIXIR_GUARDIAN"],
			},
			[437] = {
				id = "CONSUMABLE_FOOD_AND_DRINK",
				text = function( )
					if not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
						return string.format( "%s & %s", ArkInventory.Localise["CATEGORY_CONSUMABLE_FOOD"], ArkInventory.Localise["CATEGORY_CONSUMABLE_DRINK"] )
					else
						return ArkInventory.Localise["WOW_ITEM_CLASS_CONSUMABLE_FOOD_AND_DRINK"]
					end
				end,
			},
			[449] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CONSUMABLE_VANTUSRUNE",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_CONSUMABLE_VANTUSRUNE"],
			},
			[450] = {
				id = "CONSUMABLE_POWER_SYSTEM_OLD",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_POWER_SYSTEM_OLD"],
				--id = "CONSUMABLE_POWER_LEGION_ARTIFACT",
				--text = ArkInventory.Localise["ARTIFACT_POWER"],
			},
			[461] = {
				id = "CONSUMABLE_ABILITIES_AND_ACTIONS",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_ABILITIES_AND_ACTIONS"],
			},
			[902] = {
				proj = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CONSUMABLE_FOOD_PET",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_FOOD_PET"],
			},
			[428] = {
				id = "SYSTEM_REPUTATION",
				text = ArkInventory.Localise["REPUTATION"],
			},
			[439] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SYSTEM_GLYPH",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_GLYPH"],
			},
			[440] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SYSTEM_ITEM_ENHANCEMENT",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_ITEM_ENHANCEMENT"],
			},
			[454] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CONSUMABLE_CHAMPION_EQUIPMENT",
				text = ArkInventory.Localise["CATEGORY_CONSUMABLE_CHAMPION_EQUIPMENT"],
			},
			[455] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CONSUMABLE_POWER_SHADOWLANDS_ANIMA",
				text = string.format( "%s - %s", ArkInventory.Localise["COVENANT"], ArkInventory.Localise["ANIMA"] ),
			},
			[459] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CONSUMABLE_POWER_SHADOWLANDS_CONDUIT",
				text = string.format( "%s - %s", ArkInventory.Localise["COVENANT"], ArkInventory.Localise["CONDUITS"] ),
			},
			[460] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CONSUMABLE_POWER_SHADOWLANDS",
				text = string.format( "%s - %s", ArkInventory.Localise["COVENANT"], ArkInventory.Localise["OTHER"] ),
			},
			
		},
		Trade = {
			[412] = {
				id = "TRADEGOODS_OTHER",
				text = ArkInventory.Localise["OTHER"],
			},
--			[425] = TRADEGOODS_DEVICES
			[427] = {
				id = "TRADEGOODS_PARTS",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_TRADEGOODS_PARTS"],
			},
			[434] = {
				-- cut gems only (which dont exist in classic)
				proj = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC ),
				id = "TRADEGOODS_GEMS",
				text = ArkInventory.Localise["GEMS"],
			},
			[501] = {
				id = "TRADEGOODS_HERBS",
				text = ArkInventory.Localise["WOW_SKILL_HERBALISM"],
			},
			[502] = {
				id = "TRADEGOODS_CLOTH",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_ARMOR_CLOTH"],
			},
			[503] = {
				id = "TRADEGOODS_ELEMENTAL",
				text = function( )
					if not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
						return ArkInventory.Localise["ELEMENTAL"]
					else
						return ArkInventory.Localise["WOW_ITEM_CLASS_TRADEGOODS_ELEMENTAL"]
					end
				end,
			},
			[504] = {
				id = "TRADEGOODS_LEATHER",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_ARMOR_LEATHER"],
			},
			[505] = {
				id = "TRADEGOODS_COOKING",
				text = ArkInventory.Localise["WOW_SKILL_COOKING"],
			},
			[506] = {
				id = "TRADEGOODS_METAL_AND_STONE",
				text = function( )
					if not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
						return ArkInventory.Localise["CATEGORY_TRADEGOODS_METAL_AND_STONE"]
					else
						return ArkInventory.Localise["WOW_ITEM_CLASS_TRADEGOODS_METAL_AND_STONE"]
					end
				end,
			},
--			[507] = TRADEGOODS_MATERIALS
--			[510] = TRADEGOODS_ENCHANTMENT > [440] SYSTEM_ITEM_ENHANCEMENT
			[512] = {
				id = "TRADEGOODS_ENCHANTING",
				text = ArkInventory.Localise["WOW_SKILL_ENCHANTING"],
			},
			[513] = {
				-- uncut gems only
				id = "TRADEGOODS_JEWELCRAFTING",
				text = function( )
					if ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC ) then
						return ArkInventory.Localise["GEMS"]
					else
						return ArkInventory.Localise["WOW_ITEM_CLASS_TRADEGOODS_JEWELCRAFTING"]
					end
				end,
			},
			[514] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "TRADEGOODS_INSCRIPTION",
				text = ArkInventory.Localise["WOW_SKILL_INSCRIPTION"],
			},
		},
		Skill = { -- do NOT change the indicies
			[101] = {
				id = "SKILL_ALCHEMY",
				text = ArkInventory.Localise["WOW_SKILL_ALCHEMY"],
			},
			[102] = {
				id = "SKILL_BLACKSMITHING",
				text = ArkInventory.Localise["WOW_SKILL_BLACKSMITHING"],
			},
			[103] = {
				id = "SKILL_COOKING",
				text = ArkInventory.Localise["WOW_SKILL_COOKING"],
			},
			[104] = {
				id = "SKILL_ENGINEERING",
				text = ArkInventory.Localise["WOW_SKILL_ENGINEERING"],
			},
			[105] = {
				id = "SKILL_ENCHANTING",
				text = ArkInventory.Localise["WOW_SKILL_ENCHANTING"],
			},
			[106] = {
				id = "SKILL_FIRST_AID",
				text = ArkInventory.Localise["WOW_SKILL_FIRSTAID"],
			},
			[107] = {
				id = "SKILL_FISHING",
				text = ArkInventory.Localise["WOW_SKILL_FISHING"],
			},
			[108] = {
				id = "SKILL_HERBALISM",
				text = ArkInventory.Localise["WOW_SKILL_HERBALISM"],
			},
			[109] = {
				proj = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC ),
				id = "SKILL_JEWELCRAFTING",
				text = ArkInventory.Localise["WOW_SKILL_JEWELCRAFTING"],
			},
			[110] = {
				id = "SKILL_LEATHERWORKING",
				text = ArkInventory.Localise["WOW_SKILL_LEATHERWORKING"],
			},
			[111] = {
				id = "SKILL_MINING",
				text = ArkInventory.Localise["WOW_SKILL_MINING"],
			},
			[112] = {
				id = "SKILL_SKINNING",
				text = ArkInventory.Localise["WOW_SKILL_SKINNING"],
			},
			[113] = {
				id = "SKILL_TAILORING",
				text = ArkInventory.Localise["WOW_SKILL_TAILORING"],
			},
			[115] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SKILL_INSCRIPTION",
				text = ArkInventory.Localise["WOW_SKILL_INSCRIPTION"],
			},
			[116] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "SKILL_ARCHAEOLOGY",
				text = ArkInventory.Localise["WOW_SKILL_ARCHAEOLOGY"],
			},
		},
		Class = {
			[201] = {
				id = "CLASS_DRUID",
				text = ArkInventory.Localise["WOW_CLASS_DRUID"],
			},
			[202] = {
				id = "CLASS_HUNTER",
				text = ArkInventory.Localise["WOW_CLASS_HUNTER"],
			},
			[203] = {
				id = "CLASS_MAGE",
				text = ArkInventory.Localise["WOW_CLASS_MAGE"],
			},
			[204] = {
				id = "CLASS_PALADIN",
				text = ArkInventory.Localise["WOW_CLASS_PALADIN"],
			},
			[205] = {
				id = "CLASS_PRIEST",
				text = ArkInventory.Localise["WOW_CLASS_PRIEST"],
			},
			[206] = {
				id = "CLASS_ROGUE",
				text = ArkInventory.Localise["WOW_CLASS_ROGUE"],
			},
			[207] = {
				id = "CLASS_SHAMAN",
				text = ArkInventory.Localise["WOW_CLASS_SHAMAN"],
			},
			[208] = {
				id = "CLASS_WARLOCK",
				text = ArkInventory.Localise["WOW_CLASS_WARLOCK"],
			},
			[209] = {
				id = "CLASS_WARRIOR",
				text = ArkInventory.Localise["WOW_CLASS_WARRIOR"],
			},
			[210] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CLASS_DEATHKNIGHT",
				text = ArkInventory.Localise["WOW_CLASS_DEATHKNIGHT"],
			},
			[211] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CLASS_MONK",
				text = ArkInventory.Localise["WOW_CLASS_MONK"],
			},
			[212] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "CLASS_DEMONHUNTER",
				text = ArkInventory.Localise["WOW_CLASS_DEMONHUNTER"],
			},
		},
		Empty = {
			[300] = {
				id = "EMPTY_UNKNOWN",
				text = ArkInventory.Localise["UNKNOWN"],
			},
			[301] = {
				id = "EMPTY",
				text = ArkInventory.Localise["CATEGORY_EMPTY"],
			},
			[302] = {
				id = "EMPTY_BAG",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_CONTAINER_BAG"],
			},
			[303] = {
				proj = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_KEYRING",
				text = ArkInventory.Localise["KEYRING"],
			},
			[304] = {
				proj = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_SOULSHARD",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_CONTAINER_SOULSHARD"],
			},
			[305] = {
				id = "EMPTY_HERBALISM",
				text = ArkInventory.Localise["WOW_SKILL_HERBALISM"],
			},
			[306] = {
				id = "EMPTY_ENCHANTING",
				text = ArkInventory.Localise["WOW_SKILL_ENCHANTING"],
			},
			[307] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_ENGINEERING",
				text = ArkInventory.Localise["WOW_SKILL_ENGINEERING"],
			},
			[308] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_JEWELCRAFTING",
				text = ArkInventory.Localise["WOW_SKILL_JEWELCRAFTING"],
			},
			[309] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_MINING",
				text = ArkInventory.Localise["WOW_SKILL_MINING"],
			},
			[310] = {
				proj = not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_QUIVER",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_QUIVER"],
			},
			[312] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_LEATHERWORKING",
				text = ArkInventory.Localise["WOW_ITEM_CLASS_CONTAINER_LEATHERWORKING"],
			},
			[313] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_INSCRIPTION",
				text = ArkInventory.Localise["WOW_SKILL_INSCRIPTION"],
			},
			[314] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_FISHING",
				text = ArkInventory.Localise["WOW_SKILL_FISHING"],
			},
			[315] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_VOID",
				text = ArkInventory.Localise["VOIDSTORAGE"],
			},
			[316] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_COOKING",
				text = ArkInventory.Localise["WOW_SKILL_COOKING"],
			},
			[317] = {
				proj = ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ),
				id = "EMPTY_REAGENTBANK",
				text = ArkInventory.Localise["REAGENTBANK"],
			},
		},
		Other = { -- do NOT change the indicies - if you have to then see the DatabaseUpgradePostLoad( ) function to remap it
			[901] = {
				id = "SYSTEM_CORE_MATS",
				text = ArkInventory.Localise["CATEGORY_SYSTEM_CORE_MATS"],
			},
		},
	},
	
}

function ArkInventory.ObjectIDCategory( i, isRule )
	
	-- if you change these values then you need to upgrade the savedvariable data as well
	
	local soulbound = ArkInventory.Const.Bind.Never
	if ArkInventory.IsBound( i.sb ) then
		soulbound = 1
	end
	
	local info = ArkInventory.GetObjectInfo( i.h )
	local osd = info.osd
	local r
	
	if osd.class == "item" then
		r = string.format( "%s:%i:%i", osd.class, osd.id, soulbound )
		if isRule and info.equiploc ~= "" then
			-- equipable items get an expanded rule id
			r = string.format( "%s:%s", r, osd.exrid )
		end
	elseif osd.class == "empty" then
		local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( i.loc_id, i.bag_id )
		soulbound = ArkInventory.BagType( blizzard_id ) -- allows for unique codes per bag type
		r = string.format( "%s:%i:%i", osd.class, osd.id, soulbound )
	elseif osd.class == "spell" or osd.class == "currency" or osd.class == "copper" or osd.class == "reputation" or osd.class == "enchant" then
		r = string.format( "%s:%i", osd.class, osd.id )
	elseif osd.class == "battlepet" then
		r = string.format( "%s:%i:%i", osd.class, osd.id, soulbound )
	elseif osd.class == "keystone" then
		r = string.format( "%s:%i:%i", osd.class, osd.instance, soulbound )
	else
		ArkInventory.OutputWarning( "uncoded object class [", i.h, "] = [", osd.class, "]" )
		r = string.format( "%s:%i", osd.class, osd.id )
	end
	
	local codex = ArkInventory.GetLocationCodex( i.loc_id )
	local cr = string.format( "%i:%s", codex.catset_id, r )
	
	return cr, r, codex
	
end

function ArkInventory.ObjectIDRule( i )
	-- not saved, cached only, can be changed at any time
	local id, ignore, codex = ArkInventory.ObjectIDCategory( i, true )
	local rid = string.format( "%i:%i:%i:%i:%s", i.loc_id or 0, i.bag_id or 0, i.slot_id or 0, i.sb or ArkInventory.Const.Bind.Never, id )
	return rid, id, codex
end


function ArkInventory.ItemCategoryGetDefaultActual( i )
	
	-- local debuginfo = { ["m"]=gcinfo( ), ["t"]=GetTime( ) }
	
	-- collection - pet
	if i.loc_id == ArkInventory.Const.Location.Pet then
		
		if i.bp then
			if ArkInventory.IsBound( i.sb ) then
				return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_BATTLE_BOUND" )
			else
				return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_BATTLE_TRADE" )
			end
		else
			if ArkInventory.IsBound( i.sb ) then
				return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_COMPANION_BOUND" )
			else
				return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_COMPANION_TRADE" )
			end
		end
		
	end
	
	-- collection - currency 
	if i.loc_id == ArkInventory.Const.Location.Currency then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_CURRENCY" )
	end
	
	-- collection - mount
	if i.loc_id == ArkInventory.Const.Location.Mount then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_MOUNT_BOUND" )
	end
	
	-- collection - toybox
	if i.loc_id == ArkInventory.Const.Location.Toybox then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_TOY" )
	end
	
	-- collection - heirloom
	if i.loc_id == ArkInventory.Const.Location.Heirloom then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_HEIRLOOM" )
	end
	
	-- collection - reputation
	if i.loc_id == ArkInventory.Const.Location.Reputation then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_REPUTATION" )
	end
	
	
	-- everything else needs the info table
	local info = ArkInventory.GetObjectInfo( i.h, i )
	
	if not info.ready then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_UNKNOWN" )
	end
	
	-- mythic keystone
	if info.class == "keystone" then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_MYTHIC_KEYSTONE" )
	end
	
	-- caged battle pets
	if info.class == "battlepet" then
		if ArkInventory.IsBound( i.sb ) then
			return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_BATTLE_BOUND" )
		else
			return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_BATTLE_TRADE" )
		end
	end
	
	--ArkInventory.Output( "bag[", i.bag_id, "], slot[", i.slot_id, "] = ", info.itemtype, " [", info.itemtypeid, "] ", info.itemsubtype, "[", info.itemsubtypeid, "]" )
	-- ArkInventory.Output( i.h, " = ", info.itemtype, " [", info.itemtypeid, "] ", info.itemsubtype, "[", info.itemsubtypeid, "]" )
	
	-- items only from here on
	if info.class ~= "item" then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_UNKNOWN" )
	end
	
	-- reputation items that can be other types
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.XREF.Reputation" ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_REPUTATION" )
	end
	
	
	
	-- setup tooltip for scanning.  it will be ready as we've already checked
	ArkInventory.TooltipSetItem( ArkInventory.Global.Tooltip.Scan, i.loc_id, i.bag_id, i.slot_id, i.h, i )
	
	-- if enabled - already known soulbound items are junk (tooltip)
	if ArkInventory.db.option.junk.soulbound.known then --and not ArkInventory.Global.Location[i.loc_id].isOffline
		if ArkInventory.IsBound( i.sb ) then
			if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["ALREADY_KNOWN"], false, true, false, ArkInventory.Const.Tooltip.Search.Base ) then
				--ArkInventory.Output( i.h, " is junk?" )
				return ArkInventory.CategoryGetSystemID( "SYSTEM_JUNK" )
			end
		end
	end
	
	-- toy (tooltip)
	if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ITEM_TOY_ONUSE"], false, true, false, ArkInventory.Const.Tooltip.Search.Short ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_TOY" )
	end
	
	
	
	
	-- currencies and power
	if ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
		
		-- legion
		if info.expansion == ArkInventory.Const.BLIZZARD.GLOBAL.EXPANSION.LEGION then
			
			-- artifact power (tooltip)
			if ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ARTIFACT_POWER"], false, true, false, 0, ArkInventory.Const.Tooltip.Search.Short ) then
				return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POWER_SYSTEM_OLD" )
			end
			
			-- ancient mana (tooltip)
			if ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ANCIENT_MANA"], false, true, false, 0, ArkInventory.Const.Tooltip.Search.Short ) then
				return ArkInventory.CategoryGetSystemID( "SYSTEM_CURRENCY" )
			end
			
		end
		
		-- bfa used azerite which acted more like a currency you earnt than an item you collected
		
		-- shadowlands
		if info.expansion == ArkInventory.Const.BLIZZARD.GLOBAL.EXPANSION.SHADOWLANDS then
			
			if ArkInventory.CrossClient.IsAnimaItemByID( info.id ) then
				return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POWER_SHADOWLANDS_ANIMA" )
			end
			
			-- conduits (tooltip)
			if ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_CONDUIT_POTENCY"], false, true, false, 0, ArkInventory.Const.Tooltip.Search.Short ) then
				return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POWER_SHADOWLANDS_CONDUIT" )
			end
			
			if ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_CONDUIT_FINESSE"], false, true, false, 0, ArkInventory.Const.Tooltip.Search.Short ) then
				return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POWER_SHADOWLANDS_CONDUIT" )
			end
			
			if ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_CONDUIT_ENDURANCE"], false, true, false, 0, ArkInventory.Const.Tooltip.Search.Short ) then
				return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POWER_SHADOWLANDS_CONDUIT" )
			end
			
			-- covenant (other)
			if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Power.Shadowlands" ) then
				return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POWER_SHADOWLANDS" )
			end
			
		end
		
	end
	
	-- old power systems (current power system items should have already been categorised)
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Power" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POWER_SYSTEM_OLD" )
	end
	
	-- currency items
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.XREF.Currency" ) then
		-- currency items
		return ArkInventory.CategoryGetSystemID( "SYSTEM_CURRENCY" )
	end
	
	-- quest items (some are grey)
	if info.itemtypeid == ArkInventory.Const.ItemClass.QUEST or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Quest" ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_QUEST" )
	end
	
	-- cosmetic items (tooltip check is further down)
	if ( info.itemtypeid == ArkInventory.Const.ItemClass.ARMOR and info.itemsubtypeid == ArkInventory.Const.ItemClass.ARMOR_COSMETIC ) or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Equipment.Cosmetic" ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_EQUIPMENT_COSMETIC" )
	end
	
	-- junk
	if info.q == ArkInventory.Const.BLIZZARD.GLOBAL.ITEMQUALITY.POOR or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Junk" ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_JUNK" )
	end
	
	-- projectiles
	if info.itemtypeid == ArkInventory.Const.ItemClass.PROJECTILE then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_PROJECTILE" )
	end
	
	-- bags / containers
	if info.itemtypeid == ArkInventory.Const.ItemClass.CONTAINER then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_CONTAINER" )
	end
	
	-- equipable items (tooltip)
	if info.equiploc ~= "" or info.itemtypeid == ArkInventory.Const.ItemClass.WEAPON or info.itemtypeid == ArkInventory.Const.ItemClass.ARMOR or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Armor Token" ) then
		if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_ITEM_COSMETIC"], false, true, false, ArkInventory.Const.Tooltip.Search.Short ) then
			return ArkInventory.CategoryGetSystemID( "SYSTEM_EQUIPMENT_COSMETIC" )
		elseif i.sb == ArkInventory.Const.Bind.Account then
			return ArkInventory.CategoryGetSystemID( "SYSTEM_EQUIPMENT_ACCOUNTBOUND" )
		elseif i.sb == ArkInventory.Const.Bind.Pickup then
			if ArkInventory.db.option.junk.soulbound.equipment then
				if not ArkInventory.TooltipCanUse( ArkInventory.Global.Tooltip.Scan, ArkInventory.db.option.junk.soulbound.known, ArkInventory.db.option.junk.soulbound.itemlevel ) then
					--ArkInventory.Output( i.h, " is junk" )
					return ArkInventory.CategoryGetSystemID( "SYSTEM_JUNK" )
				end
			end
			return ArkInventory.CategoryGetSystemID( "SYSTEM_EQUIPMENT_SOULBOUND" )
		else
			return ArkInventory.CategoryGetSystemID( "SYSTEM_EQUIPMENT" )
		end
	end
	
	-- keys
	if info.itemtypeid == ArkInventory.Const.ItemClass.KEY or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Key" ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_KEY" )
	end
	
	-- glyphs
	if info.itemtypeid == ArkInventory.Const.ItemClass.GLYPH then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_GLYPH" )
	end
	
	-- battle pet as an item
	if info.itemtypeid == ArkInventory.Const.ItemClass.BATTLEPET then
		if ArkInventory.IsBound( i.sb ) then
			return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_BATTLE_BOUND" )
		else
			return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_BATTLE_TRADE" )
		end
	end
	
	-- misc (pets)
	if ( info.itemtypeid == ArkInventory.Const.ItemClass.MISC and info.itemsubtypeid == ArkInventory.Const.ItemClass.MISC_PET ) or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Pet" ) then
		if ArkInventory.IsBound( i.sb ) then
			return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_COMPANION_BOUND" )
		else
			return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_COMPANION_TRADE" )
		end
	end
	
	-- misc (mount)
	if ( info.itemtypeid == ArkInventory.Const.ItemClass.MISC and info.itemsubtypeid == ArkInventory.Const.ItemClass.MISC_MOUNT ) or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Mount" ) then
		if ArkInventory.IsBound( i.sb ) then
			return ArkInventory.CategoryGetSystemID( "SYSTEM_MOUNT_BOUND" )
		else
			return ArkInventory.CategoryGetSystemID( "SYSTEM_MOUNT_TRADE" )
		end
	end
	
	-- PT toy
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Toy" ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_TOY" )
	end
	
	
	-- gems
	if info.itemtypeid == ArkInventory.Const.ItemClass.GEM or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Gems" ) then
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.GEM_ARTIFACTRELIC or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Gems.Artifact Relic" ) then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POWER_SYSTEM_OLD" )
		elseif ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC ) then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_GEMS" )
		else
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_JEWELCRAFTING" )
		end
	end
	
	if ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
		-- artifact power.  tooltip check is lower down
		if ArkInventory.CrossClient.IsArtifactPowerItem( info.id ) or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Artifact Power" ) then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POWER_SYSTEM_OLD" )
		end
	end
	
	-- item enhancements
	if info.itemtypeid == ArkInventory.Const.ItemClass.ITEM_ENHANCEMENT or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Item Enhancement" ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_ITEM_ENHANCEMENT" )
	end
	
	-- consumables
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Explosives and Devices" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_EXPLOSIVES_AND_DEVICES" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Bandage" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_BANDAGE" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Food" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_FOOD" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Drink" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_DRINK" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Heal" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POTION_HEAL" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Mana" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POTION_MANA" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Potion" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POTION" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Elixir.Battle" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_ELIXIR_BATTLE" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Elixir.Guardian" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_ELIXIR_GUARDIAN" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Flask" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_FLASK" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Scroll" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_SCROLL" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Champion" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_CHAMPION_EQUIPMENT" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Abilities" ) or ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Actions" ) then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_ABILITIES_AND_ACTIONS" )
	end
	
	
	
	if info.itemtypeid == ArkInventory.Const.ItemClass.CONSUMABLE and not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC ) then
		
		-- classic has no subcategories
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.CONSUMABLE_EXPLOSIVES_AND_DEVICES then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_EXPLOSIVES_AND_DEVICES" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.CONSUMABLE_POTION then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POTION" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.CONSUMABLE_ELIXIR then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_ELIXIR" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.CONSUMABLE_FLASK then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_FLASK" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.CONSUMABLE_FOOD_AND_DRINK then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_FOOD_AND_DRINK" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.CONSUMABLE_BANDAGE then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_BANDAGE" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.CONSUMABLE_VANTUSRUNE then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_VANTUSRUNE" )
		end
		
	end
	
	if info.itemtypeid == ArkInventory.Const.ItemClass.TRADEGOODS and not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC ) then
	
		-- old subcategories still exist but are hidden
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_EXPLOSIVES_AND_DEVICES then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_EXPLOSIVES_AND_DEVICES" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_EXPLOSIVES then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_EXPLOSIVES_AND_DEVICES" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_DEVICES then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_EXPLOSIVES_AND_DEVICES" )
		end
		
	end
	
	
	
	
	
	local codex = ArkInventory.GetLocationCodex( i.loc_id )
	
	-- categorise based off characters primary professions
	if codex.player.data.tradeskill and codex.player.data.tradeskill.priority > 0 then
		
		local ignore, ignore, req = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_REQUIRES_SKILL"], false, true, false, 0, ArkInventory.Const.Tooltip.Search.Short )
		
		-- priority profession
		for x = 1, ArkInventory.Const.Tradeskill.numPrimary do
			
			if codex.player.data.info.tradeskill[x] then
				
				local skill = ArkInventory.Const.Tradeskill.Data[codex.player.data.info.tradeskill[x]]
				if skill and codex.player.data.tradeskill.priority == x then
					
					if ArkInventory.PT_ItemInSets( i.h, skill.pt ) then
						return ArkInventory.CategoryGetSystemID( skill.id )
					end
					
					if req and string.find( req, tostring( skill.text ) ) then
						return ArkInventory.CategoryGetSystemID( skill.id )
					end
					
				end
				
			end
			
		end
		
		-- other profession
		for x = 1, ArkInventory.Const.Tradeskill.numPrimary do
			
			if codex.player.data.info.tradeskill[x] then
				
				local skill = ArkInventory.Const.Tradeskill.Data[codex.player.data.info.tradeskill[x]]
				if skill and codex.player.data.tradeskill.priority ~= x then
					
					if ArkInventory.PT_ItemInSets( i.h, skill.pt ) then
						return ArkInventory.CategoryGetSystemID( skill.id )
					end
					
					if req and string.find( req, tostring( skill.text ) ) then
						return ArkInventory.CategoryGetSystemID( skill.id )
					end
					
				end
				
			end
			
		end
		
	end
	
	
	
	-- tradegoods
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Cloth" ) then
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_CLOTH" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Leather" ) then
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_LEATHER" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Metal and Stone" ) then
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_METAL_AND_STONE" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Herbalism" ) then
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_HERBS" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Enchanting" ) then
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_ENCHANTING" )
	end
	
	if ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.RETAIL ) then
		
		if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Inscription" ) then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_INSCRIPTION" )
		end
	
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Parts" ) then
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_PARTS" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Elemental" ) then
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_ELEMENTAL" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Jewelcrafting" ) then
		-- uncut gems (in classic this will display as gems)
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_JEWELCRAFTING" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Tradegoods.Cooking" ) then
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_COOKING" )
	end
	
	if info.itemtypeid == ArkInventory.Const.ItemClass.TRADEGOODS and not ArkInventory.ClientCheck( ArkInventory.Const.BLIZZARD.CLIENT.CODE.CLASSIC ) then
		
		-- classic has no itemsubtypes
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_CLOTH then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_CLOTH" )
		end
	
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_LEATHER then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_LEATHER" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_METAL_AND_STONE then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_METAL_AND_STONE" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_COOKING then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_COOKING" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_HERBS then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_HERBS" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_ENCHANTING then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_ENCHANTING" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_INSCRIPTION then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_INSCRIPTION" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_JEWELCRAFTING then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_JEWELCRAFTING" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_PARTS then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_PARTS" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.TRADEGOODS_ELEMENTAL then
			return ArkInventory.CategoryGetSystemID( "TRADEGOODS_ELEMENTAL" )
		end
		
	end
	
	
	
	-- class reagents - only check these if its the player (not the account)
	if codex.player.data.info.isplayer then
		
		-- class requirement (via PT)
		if ArkInventory.PT_ItemInSets( i.h, string.format( "ArkInventory.Class.%s", codex.player.data.info.class ) ) then
			return ArkInventory.CategoryGetSystemID( string.format( "CLASS_%s", codex.player.data.info.class ) )
		end
		
		-- class requirement (via tooltip)
		local ignore, ignore, req = ArkInventory.TooltipFind( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_TOOLTIP_REQUIRES_CLASS"], false, true, true, 0, ArkInventory.Const.Tooltip.Search.Short )
		if req and string.find( req, codex.player.data.info.class_local ) then
			return ArkInventory.CategoryGetSystemID( string.format( "CLASS_%s", codex.player.data.info.class ) )
		end
		
	end
	
	
	-- consumable (tooltip)
	if info.itemtypeid == ArkInventory.Const.ItemClass.CONSUMABLE then
		
		-- food
		if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_ITEM_TOOLTIP_FOOD"], false, true, true, ArkInventory.Const.Tooltip.Search.Short ) then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_FOOD" )
		end
		
		-- drink
		if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_ITEM_TOOLTIP_DRINK"], false, true, true, ArkInventory.Const.Tooltip.Search.Short ) then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_DRINK" )
		end
		
		-- potions
		if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_ITEM_TOOLTIP_POTION_HEAL"], false, true, true, ArkInventory.Const.Tooltip.Search.Short ) then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POTION_HEAL" )
		end
		
		if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_ITEM_TOOLTIP_POTION_MANA"], false, true, true, ArkInventory.Const.Tooltip.Search.Short ) then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_POTION_MANA" )
		end
		
		-- elixir
		if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_ITEM_TOOLTIP_ELIXIR_BATTLE"], false, true, true, ArkInventory.Const.Tooltip.Search.Short ) then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_ELIXIR_BATTLE" )
		end
		
		if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["WOW_ITEM_TOOLTIP_ELIXIR_GUARDIAN"], false, true, true, ArkInventory.Const.Tooltip.Search.Short ) then
			return ArkInventory.CategoryGetSystemID( "CONSUMABLE_ELIXIR_GUARDIAN" )
		end
		
	end
	
	-- recipe (after professions so only the leftovers are categorised)
	if info.itemtypeid == ArkInventory.Const.ItemClass.RECIPE then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_RECIPE" )
	end
	
	-- reagent
	if info.itemtypeid == ArkInventory.Const.ItemClass.REAGENT then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_REAGENT" )
	end
	
	-- all reputations
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Consumable.Reputation" ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_REPUTATION" )
	end
	
	-- secondary professions
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Skill.Fishing" ) then
		return ArkInventory.CategoryGetSystemID( "SKILL_FISHING" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Skill.Cooking" ) then
		return ArkInventory.CategoryGetSystemID( "SKILL_COOKING" )
	end
	
	if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.Skill.Archaeology" ) then
		return ArkInventory.CategoryGetSystemID( "SKILL_ARCHAEOLOGY" )
	end
	
	-- misc
	if info.itemtypeid == ArkInventory.Const.ItemClass.MISC then
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.MISC_REAGENT then
			return ArkInventory.CategoryGetSystemID( "SYSTEM_REAGENT" )
		end
		
		if info.itemsubtypeid == ArkInventory.Const.ItemClass.MISC_OTHER then
			
			if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ArkInventory.Localise["BATTLEPET"], false, true, false, ArkInventory.Const.Tooltip.Search.Short ) then
				if ArkInventory.IsBound( i.sb ) then
					return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_COMPANION_BOUND" )
				else
					return ArkInventory.CategoryGetSystemID( "SYSTEM_PET_COMPANION_TRADE" )
				end
			end
			
		end
		
	end
	
	-- quest items (via tooltip)
	if ArkInventory.TooltipContains( ArkInventory.Global.Tooltip.Scan, ITEM_BIND_QUEST, false, true, false, ArkInventory.Const.Tooltip.Search.Short ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_QUEST" )
	end
	
	
	
	-- left overs
	
	-- crafting reagents (after professions so only the leftovers are categorised)
	if info.craft then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_CRAFTING_REAGENT" )
	end
	
	-- heirlooms
	if info.q == ArkInventory.Const.BLIZZARD.GLOBAL.ITEMQUALITY.HEIRLOOM then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_HEIRLOOM" )
	end
	
	if ArkInventory.IsBound( i.sb ) then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_BOUND" )
	end
	
	if info.itemtypeid == ArkInventory.Const.ItemClass.TRADEGOODS then
		return ArkInventory.CategoryGetSystemID( "TRADEGOODS_OTHER" )
	end
	
	if info.itemtypeid == ArkInventory.Const.ItemClass.CONSUMABLE then
		return ArkInventory.CategoryGetSystemID( "CONSUMABLE_OTHER" )
	end
	
	if info.itemtypeid == ArkInventory.Const.ItemClass.MISC then
		return ArkInventory.CategoryGetSystemID( "SYSTEM_MISC" )
	end
	
	
	return ArkInventory.CategoryGetSystemID( "SYSTEM_DEFAULT" )
	
end

function ArkInventory.ItemCategoryGetDefaultEmpty( loc_id, bag_id )
	
	local codex = ArkInventory.GetLocationCodex( loc_id )
	local clump = codex.style.slot.empty.clump
	
	local blizzard_id = ArkInventory.InternalIdToBlizzardBagId( loc_id, bag_id )
	local bt = ArkInventory.BagType( blizzard_id )
	
	--ArkInventory.Output( "loc[", loc_id, "] bag[", bag_id, " / ", blizzard_id, "] type[", bt, "]" )
	
	if bt == ArkInventory.Const.Slot.Type.Bag then
		if clump then
			return ArkInventory.CategoryGetSystemID( "EMPTY" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_BAG" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.Enchanting then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SKILL_ENCHANTING" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_ENCHANTING" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.Engineering then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SKILL_ENGINEERING" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_ENGINEERING" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.Jewelcrafting then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SKILL_JEWELCRAFTING" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_JEWELCRAFTING" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.Herbalism then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SKILL_HERBALISM" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_HERBALISM" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.Inscription then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SKILL_INSCRIPTION" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_INSCRIPTION" )
		end
	end

	if bt == ArkInventory.Const.Slot.Type.Leatherworking then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SKILL_LEATHERWORKING" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_LEATHERWORKING" )
		end
	end

	if bt == ArkInventory.Const.Slot.Type.Mining then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SKILL_MINING" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_MINING" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.Fishing then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SKILL_FISHING" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_FISHING" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.Cooking then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SKILL_COOKING" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_COOKING" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.ReagentBank then
		if clump then
			return ArkInventory.CategoryGetSystemID( "EMPTY" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_REAGENTBANK" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.Projectile then
		if clump then
			return ArkInventory.CategoryGetSystemID( "SYSTEM_PROJECTILE" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_QUIVER" )
		end
	end
	
	if bt == ArkInventory.Const.Slot.Type.Soulshard then
		if clump then
			return ArkInventory.CategoryGetSystemID( "CLASS_WARLOCK" )
		else
			return ArkInventory.CategoryGetSystemID( "EMPTY_SOULSHARD" )
		end
	end
	
	return ArkInventory.CategoryGetSystemID( "EMPTY_UNKNOWN" ) 
	
end

function ArkInventory.ItemCategoryGetDefault( i )
	
	local cid = ArkInventory.ObjectIDCategory( i )
	if ArkInventory.db.cache.default[cid] then
		-- if the value has been cached then use it
		return ArkInventory.db.cache.default[cid]
	end
	
	
--	if ArkInventory.TranslationsLoaded then
		
		if i.h then
			local cat = ArkInventory.ItemCategoryGetDefaultActual( i )
			ArkInventory.db.cache.default[cid] = cat
			return ArkInventory.db.cache.default[cid]
		else
			local cat = ArkInventory.ItemCategoryGetDefaultEmpty( i.loc_id, i.bag_id )
			ArkInventory.db.cache.default[cid] = cat
			return ArkInventory.db.cache.default[cid]
		end
		
--	else
		
--		return ArkInventory.CategoryGetSystemID( "SYSTEM_UNKNOWN" )
		
--	end
	
end

function ArkInventory.ItemCategoryGetPrimary( i )
	
	if i.h then -- only items can have a category, empty slots can only be used by rules
		
		-- items category cache id
		local cid, id, codex = ArkInventory.ObjectIDCategory( i )
		
		local cat_id = codex.catset.category.assign[id]
		if cat_id then
			-- manually assigned item to a category?
			local cat_type, cat_num = ArkInventory.CategoryIdSplit( cat_id )
			if cat_type == 1 then
				return cat_id
			elseif codex.catset.category.active[cat_type][cat_num] then -- category is active in this categoryset?
				if ArkInventory.db.option.category[cat_type].data[cat_num].used == "Y" then -- category is enabled?
					return cat_id
				end
			end
		end
		
	end
	
	if ArkInventory.Global.Rules.Enabled then
		
		-- items rule cache id
		local cid = ArkInventory.ObjectIDRule( i )
		
		-- if the value has already been cached then use it
		if ArkInventory.db.cache.rule[cid] == nil then
			-- check for any rule that applies to the item, cache the result, use false for no match (default), true for match, nil to try again later
			ArkInventory.db.cache.rule[cid] = ArkInventoryRules.AppliesToItem( i )
			--ArkInventory.Output( cid, " = ", ArkInventory.db.cache.rule[cid] )
		end
		
		return ArkInventory.db.cache.rule[cid]
		
	end
	
	return false
	
end

function ArkInventory.ItemCategoryGet( i )
	
	local unknown = ArkInventory.CategoryGetSystemID( "SYSTEM_UNKNOWN" )
	
	local default = ArkInventory.CategoryGetSystemID( "SYSTEM_DEFAULT" )
	default = ( i and ArkInventory.ItemCategoryGetDefault( i ) ) or default
	
	local cat = ArkInventory.ItemCategoryGetPrimary( i )
	
	return cat or default or unknown, cat, default or unknown
	
end


function ArkInventory.CategoryRebuildQueueAdd( i )
	
	if not i then return end
	
	--ArkInventory.Output2( "adding ", i )
	table.insert( CategoryRebuildQueue, i )
	
	ArkInventory:SendMessage( "EVENT_ARKINV_CATEGORY_REBUILD_QUEUE_UPDATE_BUCKET", "START" )
	
end

local function Scan_Threaded( thread_id )
	
	--ArkInventory.Output2( "rebuilding ", ArkInventory.Table.Elements( CategoryRebuildQueue ) )
	
	for k, i in pairs( CategoryRebuildQueue ) do
		
		--ArkInventory.Output2( "rebuilding ", search_id )
		
		
		-- get category here
		
		
		
		
		ArkInventory.ThreadYield( thread_id )
		
		CategoryRebuildQueue[k] = nil
		
	end
	
end

local function Scan( )
	
	local thread_id = ArkInventory.Global.Thread.Format.Category
	
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

function ArkInventory:EVENT_ARKINV_CATEGORY_REBUILD_QUEUE_UPDATE_BUCKET( events )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if ArkInventory.Global.Mode.Combat then
		return
	end
	
	if not scanning then
		scanning = true
		Scan( )
		scanning = false
	else
		ArkInventory:SendMessage( "EVENT_ARKINV_CATEGORY_REBUILD_QUEUE_UPDATE_BUCKET", "RESCAN" )
	end
	
end
