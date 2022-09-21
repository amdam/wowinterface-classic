local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table

ArkInventory = LibStub( "AceAddon-3.0" ):NewAddon( "ArkInventory", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceBucket-3.0" )

ArkInventory.Lib = { -- libraries live here
	
	Config = LibStub( "AceConfig-3.0" ),
	Dialog = LibStub( "AceConfigDialog-3.0" ),
	Serializer = LibStub( "AceSerializer-3.0" ),
	
	PeriodicTable = LibStub( "LibPeriodicTable-3.1" ),
	SharedMedia = LibStub( "LibSharedMedia-3.0" ),
	DataBroker = LibStub( "LibDataBroker-1.1" ),
	
	Dewdrop = LibStub( "ArkDewdrop" ),
	
	StaticDialog = LibStub( "LibDialog-1.0" ),
	
}

--[[
	https://develop.battle.net/documentation/api-reference/world-of-warcraft-game-data-api
	
	https://us.api.blizzard.com/wow/item/147250?locale=en_US&access_token=USC3iVMQ2zuMtrAB1jG4hjMH9cMSQZPoaD
	https://us.api.blizzard.com/wow/item/147250?locale=en_US&access_token=USC3iVMQ2zuMtrAB1jG4hjMH9cMSQZPoaD&bl=3
	
]]--

ArkInventory.Table = { } -- table functions live here, coded elsewhere

ArkInventory.Const = { -- constants
	
	Program = {
		Name = "ArkInventory",
		Version = nil, -- calculated at load
	},
	
	BLIZZARD = {
		
		TOC = select( 4, GetBuildInfo( ) ) or 0,
--		/dump ArkInventory.Const.BLIZZARD.TOC
		
		CLIENT = {
			ID = "",
			NAME = "",
			CODE = {
				RETAIL = "RETAIL",
				RETAIL_PTR = "RETAIL>PTR",
				RETAIL_BETA = "RETAIL>PTR>BETA",
				CLASSIC = "CLASSIC",
				CLASSIC_PTR = "CLASSIC>PTR",
				CLASSIC_BETA = "CLASSIC>PTR>BETA",
				TBC = "TBC",
				TBC_PTR = "TBC>PTR",
				TBC_BETA = "TBC>PTR>BETA",
				WRATH = "WRATH",
				WRATH_PTR = "WRATH>PTR",
				WRATH_BETA = "WRATH>PTR>BETA",
			},
		},
		
		GLOBAL = {
			TOOLTIP = {
				UPDATETIMER = 1, --TOOLTIP_UPDATE_TIME = 0.2
			},
			FONT = {
				COLOR = {
					ALREADYKNOWN = "fefe1f1f",
				},
			},
			ITEMQUALITY = {
				MISSING = -2,
				UNKNOWN = -1,
				POOR = ( Enum and Enum.ItemQuality.Poor ) or LE_ITEM_QUALITY_POOR or 0,
				COMMON = ( Enum and Enum.ItemQuality.Common ) or LE_ITEM_QUALITY_COMMON or 1,
				UNCOMMON = ( Enum and Enum.ItemQuality.Good )or LE_ITEM_QUALITY_UNCOMMON or 2,
				RARE = ( Enum and Enum.ItemQuality.Rare ) or LE_ITEM_QUALITY_RARE or 3,
				EPIC = ( Enum and Enum.ItemQuality.Epic ) or LE_ITEM_QUALITY_EPIC or 4,
				LEGENDARY = ( Enum and Enum.ItemQuality.Legendary ) or LE_ITEM_QUALITY_LEGENDARY or 5,
				ARTIFACT = ( Enum and Enum.ItemQuality.Artifact ) or LE_ITEM_QUALITY_ARTIFACT or 6,
				HEIRLOOM = ( Enum and Enum.ItemQuality.Heirloom ) or LE_ITEM_QUALITY_HEIRLOOM or 7,
				TOKEN = ( Enum and Enum.ItemQuality.WoWToken ) or LE_ITEM_QUALITY_WOWTOKEN or 8,
			},
			EXPANSION = {
				CURRENT = LE_EXPANSION_LEVEL_CURRENT or 0,
				CLASSIC = LE_EXPANSION_CLASSIC or 0,
				BC = LE_EXPANSION_BURNING_CRUSADE or 1,
				WRATH = LE_EXPANSION_WRATH_OF_THE_LICH_KING or 2,
				CATA = LE_EXPANSION_CATACLYSM or 3,
				PANDARIA = LE_EXPANSION_MISTS_OF_PANDARIA or 4,
				DRAENOR = LE_EXPANSION_WARLORDS_OF_DRAENOR or 5,
				LEGION = LE_EXPANSION_LEGION or 6,
				BFA = LE_EXPANSION_BATTLE_FOR_AZEROTH or 7,
				SHADOWLANDS = LE_EXPANSION_SHADOWLANDS or 8,
			},
			CONTAINER = {
				SLOTSIZE = 37,
				SLOTMAX = MAX_CONTAINER_ITEMS or 36,
				FILTER = {
					COUNT = NUM_LE_BAG_FILTER_FLAGS or 5,
					IGNORECLEANUP = LE_BAG_FILTER_FLAG_IGNORE_CLEANUP or 1,
					EQUIPMENT = LE_BAG_FILTER_FLAG_EQUIPMENT or 2,
					JUNK = LE_BAG_FILTER_FLAG_JUNK or 5,
				},
			},
			GUILDBANK = {
				WIDTH = NUM_GUILDBANK_COLUMNS or 14,
				HEIGHT = NUM_SLOTS_PER_GUILDBANK_GROUP or 7,
				SLOTS_PER_TAB = MAX_GUILDBANK_SLOTS_PER_TAB or 98,
				LOG_TIME_PREPEND = GUILD_BANK_LOG_TIME_PREPEND or "|cff009999  ",
			},
			VOIDSTORAGE = {
				SLOTMAX = VOID_STORAGE_MAX or 80,
				PAGES = VOID_STORAGE_PAGES or 2,
			},
			PET = {
				FILTER = {
					COLLECTED = LE_PET_JOURNAL_FILTER_COLLECTED or 1,
					NOTCOLLECTED = LE_PET_JOURNAL_FILTER_NOT_COLLECTED or 2,
				},
			},
			BATTLEPET = {
				ENEMY = LE_BATTLE_PET_ENEMY or 2,
			},
			MAILBOX = {
				MAXATTACHMENTS = ATTACHMENTS_MAX_RECEIVE,
			},
		},
		
		FUNCTION = {
			GETITEMINFO = {
				NAME = 1,
				LINK = 2,
				QUALITY = 3,
				ILVL_BASE = 4,
				USELEVEL = 5,
				TYPE = 6,
				SUBTYPE = 7,
				STACKSIZE = 8,
				EQUIP = 9,
				TEXTURE = 10,
				VENDORPRICE = 11,
				TYPEID = 12,
				SUBTYPEID = 13,
				BINDING = 14,
				EXPANSION = 15,
				SETID = 16,
				CRAFT = 17,
			},
			GETITEMINFOINSTANT = {
				ID = 1,
				TYPE = 2,
				SUBTYPE = 3,
				EQUIP = 4,
				TEXTURE = 5,
				TYPEID = 6,
				SUBTYPEID = 7,
			},
			GETSPELLINFO = {
				NAME = 1,
				TEXTURE = 3,
			}
		},
		
	},
	
	Frame = {
		Main = {
			Name = "ARKINV_Frame",
			MiniActionButtonSize = 12,
		},
		Title = {
			Name = "Title",
			Height = 20,
			MinHeight = 20,
		},
		Scroll = {
			Name = "Scroll",
			stepSize = 40,
		},
		Container = {
			Name = "ScrollContainer",
		},
		Log = {
			Name = "Log",
		},
		Info = {
			Name = "Info",
		},
		Changer = {
			Name = "Changer",
			Height = 58,
		},
		Status = {
			Name = "Status",
			Height = 10,
			MinHeight = 20,
		},
		Search = {
			Name = "Search",
			Height = 10,
			MinHeight = 20,
		},
		Scrolling = {
			List = "List",
			ScrollBar = "ScrollBar",
		},
		Config = {
			Internal = "ArkInventory",
			Blizzard = "ArkInventoryConfigBlizzard",
		},
		Cooldown = {
			Name = "Cooldown",
		},
	},
	
	Event = {
		BagUpdate = 1,
		--ObjectLock = 2,
		--PlayerMoney = 3,
		--GuildMoney = 4,
		--TabInfo = 5,
		--SkillUpdate = 6,
		--ItemUpdate = 7,
		--BagEmpty = 8,
	},
	
	Location = {
		Bag = 1,
		Keyring = 2,
		Bank = 3,
		Vault = 4,
		Mailbox = 5,
		Wearing = 6,
		Pet = 7,
		Mount = 8,
		Currency = 9,
		Auction = 10,
		--Spellbook = 11,
		Tradeskill = 12,
		Void = 13,
		Toybox = 14,
		Heirloom = 15,
		Reputation = 16,
		MountEquipment = 17,
	},
	
	Offset = {
		Vault = 1000,
		Mailbox = 2000,
		Wearing = 3000,
		Pet = 4000,
		Currency = 5000,
		Mount = 6000,
		Auction = 7000,
		--Spellbook = 8000,
		Tradeskill = 1400,
		Void = 1500,
		Toybox = 1200,
		Heirloom = 1300,
		Reputation = 1600,
		MountEquipment = 6100,
	},
	
	Bag = {
		Status = { -- these need to be negative values,  do not use -1
			Unknown = -2,
			Active = -3,
			Empty = -4,
			Purchase = -5,
			NoAccess = -6,
		},
	},
	
	Slot = {
		
		Type = { -- slot type numbers, do not change this order, just add new ones to the end of the list
			Unknown = 0,
			Bag = 1,
			Keyring = 3,
			Soulshard = 5,
			Herbalism = 6,
			Enchanting = 7,
			Engineering = 8,
			Jewelcrafting = 9,
			Mining = 10,
			Bullet = 11,
			Arrow = 12,
			Projectile = 12,
			Leatherworking = 13,
			Wearing = 14,
			Mailbox = 15,
			Inscription = 16,
			Critter = 17,
			Mount = 18,
			Currency = 19,
			Auction = 20,
			--Spellbook = 21,
			Tradeskill = 22,
			Fishing = 23,
			Void = 24,
			Cooking = 25,
			Toybox = 26,
			ReagentBank = 27,
			Heirloom = 28,
			Reputation = 29,
		},
		
		New = {
			No = false,
			Yes = 1,
			Inc = 2,
			Dec = 3,
		},
		
		Data = { },
		
		ItemLevel = {
			Min = 1,
			Max = 9999,
		},
		
		CharacterPaneOrder = {
			["INVTYPE_NON_EQUIP"] = 0,
			["INVTYPE_HEAD"] = 1,
			["INVTYPE_NECK"] = 2,
			["INVTYPE_SHOULDER"] = 3,
			["INVTYPE_CLOAK"] = 4,
			["INVTYPE_CHEST"] = 5,
			["INVTYPE_ROBE"] = 5,
			["INVTYPE_BODY"] = 6, -- shirt
			["INVTYPE_TABARD"] = 7,
			["INVTYPE_WRIST"] = 8,
			
			["INVTYPE_HAND"] = 9,
			["INVTYPE_WAIST"] = 10,
			["INVTYPE_LEGS"] = 11,
			["INVTYPE_FEET"] = 12,
			["INVTYPE_FINGER"] = 13,
			["INVTYPE_TRINKET"] = 15,
			
			["INVTYPE_WEAPON"] = 17,
			["INVTYPE_2HWEAPON"] = 17,
			["INVTYPE_WEAPONMAINHAND"] = 17,
			["INVTYPE_RANGED"] = 17,
			["INVTYPE_RANGEDRIGHT"] = 17,
			
			["INVTYPE_SHIELD"] = 18,
			["INVTYPE_WEAPONOFFHAND"] = 18,
			["INVTYPE_HOLDABLE"] = 18,
			
			["INVTYPE_THROWN"] = 20,
			["INVTYPE_RELIC"] = 20,
			["INVTYPE_AMMO"] = 20,
			
			["INVTYPE_BAG"] = 0,
			["INVTYPE_QUIVER"] = 0,
		},
		
	},
	
	Anchor = {
		Default = 0,
		BottomRight = 1,
		BottomLeft = 2,
		TopLeft = 3,
		TopRight = 4,
		Top = 5,
		Bottom = 6,
		Left = 7,
		Right = 8,
		Center = 9,
	},
	
	Direction = {
		Horizontal = 1,
		Vertical = 2,
	},
	
	Window = {
		
		Min = {
			Rows = 1,
			Columns = 6,
			Width = 400,
		},
		
		Draw = {
			Init = 0, -- intital state, only exists at load, never set to init
			Restart = 1, -- rebuild the entire window from scratch
			Recalculate = 2, -- calculate
			Resort = 3, -- sort
			Refresh = 4, -- item changes
			None = 5, -- nothing
		},
		
		Title = {
			SizeNormal = 1,
			SizeThin = 2,
		},
	},
	
	Font = {
		Face = "Arial Narrow",
		Height = 16,
		MinHeight = 4,
		MaxHeight = 72,
	},
	
	Fade = 0.6,
	GuildTag = "+",
	PlayerIDSep = " - ",
	
	ItemClass = {
		
		["UNKNOWN"] = -2,
		
		["EMPTY"] = -1,
		
		["CONSUMABLE"] = LE_ITEM_CLASS_CONSUMABLE,
		["CONSUMABLE_EXPLOSIVES_AND_DEVICES"] = 0,
		["CONSUMABLE_POTION"] = 1,
		["CONSUMABLE_ELIXIR"] = 2,
		["CONSUMABLE_FLASK"] = 3,
		["CONSUMABLE_SCROLL"] = 4,
		["CONSUMABLE_FOOD_AND_DRINK"] = 5,
		["CONSUMABLE_ITEM_ENHANCEMENT"] = 6,
		["CONSUMABLE_BANDAGE"] = 7,
		["CONSUMABLE_OTHER"] = 8,
		["CONSUMABLE_VANTUSRUNE"] = 9,
		
		["CONTAINER"] = LE_ITEM_CLASS_CONTAINER,
		["CONTAINER_BAG"] = 0,
		["CONTAINER_SOULSHARD"] = 1,
		["CONTAINER_HERBALISM"] = 2,
		["CONTAINER_ENCHANTING"] = 3,
		["CONTAINER_ENGINEERING"] = 4,
		["CONTAINER_JEWELCRAFTING"] = 5,
		["CONTAINER_MINING"] = 6,
		["CONTAINER_LEATHERWORKING"] = 7,
		["CONTAINER_INSCRIPTION"] = 8,
		["CONTAINER_FISHING"] = 9,
		["CONTAINER_COOKING"] = 10,
		
		["WEAPON"] = LE_ITEM_CLASS_WEAPON,
		["WEAPON_AXE1H"] = LE_ITEM_WEAPON_AXE1H,
		["WEAPON_AXE2H"] = LE_ITEM_WEAPON_AXE2H,
		["WEAPON_BOW"] = LE_ITEM_WEAPON_BOWS,
		["WEAPON_GUN"] = LE_ITEM_WEAPON_GUNS,
		["WEAPON_MACE1H"] = LE_ITEM_WEAPON_MACE1H,
		["WEAPON_MACE2H"] = LE_ITEM_WEAPON_MACE2H,
		["WEAPON_POLEARM"] = LE_ITEM_WEAPON_POLEARM,
		["WEAPON_SWORD1H"] = LE_ITEM_WEAPON_SWORD1H,
		["WEAPON_SWORD2H"] = LE_ITEM_WEAPON_SWORD2H,
		["WEAPON_WARGLAIVE"] = LE_ITEM_WEAPON_WARGLAIVE,
		["WEAPON_STAFF"] = LE_ITEM_WEAPON_STAFF,
		["WEAPON_EXOTIC1H"] = LE_ITEM_WEAPON_EXOTIC1H,
		["WEAPON_EXOTIC2H"] = LE_ITEM_WEAPON_EXOTIC2H,
		["WEAPON_FIST"] = LE_ITEM_WEAPON_UNARMED,
		["WEAPON_GENERIC"] = LE_ITEM_WEAPON_GENERIC,
		["WEAPON_DAGGER"] = LE_ITEM_WEAPON_DAGGER,
		["WEAPON_THROWN"] = LE_ITEM_WEAPON_THROWN,
		["WEAPON_SPEAR"] = LE_ITEM_WEAPON_SPEAR,
		["WEAPON_CROSSBOW"] = LE_ITEM_WEAPON_CROSSBOW,
		["WEAPON_WAND"] = LE_ITEM_WEAPON_WAND,
		["WEAPON_FISHING"] = LE_ITEM_WEAPON_FISHINGPOLE,
		
		["GEM"] = LE_ITEM_CLASS_GEM,
		["GEM_INTELLECT"] = LE_ITEM_GEM_INTELLECT,
		["GEM_STRENGTH"] = LE_ITEM_GEM_STRENGTH,
		["GEM_STAMINA"] = LE_ITEM_GEM_STAMINA,
		["GEM_SPIRIT"] = LE_ITEM_GEM_SPIRIT,
		["GEM_CRITICALSTRIKE"] = LE_ITEM_GEM_CRITICALSTRIKE,
		["GEM_MASTERY"] = LE_ITEM_GEM_MASTERY,
		["GEM_HASTE"] = LE_ITEM_GEM_HASTE,
		["GEM_VERSATILITY"] = LE_ITEM_GEM_VERSATILITY,
		["GEM_MULTIPLESTATS"] = LE_ITEM_GEM_MULTIPLESTATS,
		["GEM_ARTIFACTRELIC"] = LE_ITEM_GEM_ARTIFACTRELIC,
		
		["ARMOR"] = LE_ITEM_CLASS_ARMOR,
		["ARMOR_GENERIC"] = LE_ITEM_ARMOR_GENERIC,
		["ARMOR_CLOTH"] = LE_ITEM_ARMOR_CLOTH,
		["ARMOR_LEATHER"] = LE_ITEM_ARMOR_LEATHER,
		["ARMOR_MAIL"] = LE_ITEM_ARMOR_MAIL,
		["ARMOR_PLATE"] = LE_ITEM_ARMOR_PLATE,
		["ARMOR_COSMETIC"] = LE_ITEM_ARMOR_COSMETIC,
		--["ARMOR_BUCKLER"] = LE_ITEM_ARMOR_BUCKLER,
		["ARMOR_SHIELD"] = LE_ITEM_ARMOR_SHIELD,
		["ARMOR_LIBRAM"] = LE_ITEM_ARMOR_LIBRAM,
		["ARMOR_IDOL"] = LE_ITEM_ARMOR_IDOL,
		["ARMOR_TOTEM"] = LE_ITEM_ARMOR_TOTEM,
		["ARMOR_SIGIL"] = LE_ITEM_ARMOR_SIGIL,
		["ARMOR_RELIC"] = LE_ITEM_ARMOR_RELIC,
		
		["REAGENT"] = LE_ITEM_CLASS_REAGENT,
		["REAGENT_REAGENT"] = 0,
		["REAGENT_KEYSTONE"] = 1,
		
		["PROJECTILE"] = LE_ITEM_CLASS_PROJECTILE,
		["PROJECTILE_WAND"] = 0,
		["PROJECTILE_BOLT"] = 1,
		["PROJECTILE_ARROW"] = 2,
		["PROJECTILE_BULLET"] = 3,
		["PROJECTILE_THROWN"] = 4,
		
		["TRADEGOODS"] = LE_ITEM_CLASS_TRADEGOODS,
		["TRADEGOODS_TRADEGOODS"] = 0,
		["TRADEGOODS_PARTS"] = 1,
		["TRADEGOODS_EXPLOSIVES"] = 2,
		["TRADEGOODS_DEVICES"] = 3,
		["TRADEGOODS_JEWELCRAFTING"] = 4,
		["TRADEGOODS_CLOTH"] = 5,
		["TRADEGOODS_LEATHER"] = 6,
		["TRADEGOODS_METAL_AND_STONE"] = 7,
		["TRADEGOODS_COOKING"] = 8,
		["TRADEGOODS_HERBS"] = 9,
		["TRADEGOODS_ELEMENTAL"] = 10,
		["TRADEGOODS_OTHER"] = 11,
		["TRADEGOODS_ENCHANTING"] = 12,
		["TRADEGOODS_MATERIALS"] = 13,
		["TRADEGOODS_ITEM_ENCHANTMENT"] = 14,
		["TRADEGOODS_WEAPON_ENCHANTMENT"] = 15,
		["TRADEGOODS_INSCRIPTION"] = 16,
		["TRADEGOODS_EXPLOSIVES_AND_DEVICES"] = 17,
		
		["ITEM_ENHANCEMENT"] = LE_ITEM_CLASS_ITEM_ENHANCEMENT,
		
		["RECIPE"] = LE_ITEM_CLASS_RECIPE,
		["RECIPE_BOOK"] = LE_ITEM_RECIPE_BOOK,
		["RECIPE_LEATHERWORKING"] = LE_ITEM_RECIPE_LEATHERWORKING,
		["RECIPE_TAILORING"] = LE_ITEM_RECIPE_TAILORING,
		["RECIPE_ENGINEERING"] = LE_ITEM_RECIPE_ENGINEERING,
		["RECIPE_BLACKSMITHING"] = LE_ITEM_RECIPE_BLACKSMITHING,
		["RECIPE_COOKING"] = LE_ITEM_RECIPE_COOKING,
		["RECIPE_ALCHEMY"] = LE_ITEM_RECIPE_ALCHEMY,
		["RECIPE_FIRST_AID"] = LE_ITEM_RECIPE_FIRST_AID,
		["RECIPE_ENCHANTING"] = LE_ITEM_RECIPE_ENCHANTING,
		["RECIPE_FISHING"] = LE_ITEM_RECIPE_FISHING,
		["RECIPE_JEWELCRAFTING"] = LE_ITEM_RECIPE_JEWELCRAFTING,
		["RECIPE_INSCRIPTION"] = LE_ITEM_RECIPE_INSCRIPTION,
		
		["QUIVER"] = LE_ITEM_CLASS_QUIVER,
		["QUIVER_QUIVER"] = 0,  -- OBSOLETE
		["QUIVER_BOLT"] = 1, -- OBSOLETE
		["QUIVER_QUIVER"] = 2,
		["QUIVER_AMMO"] = 3,
		
		["QUEST"] = LE_ITEM_CLASS_QUESTITEM,
		["QUEST_QUEST"] = 0,
		
		["KEY"] = LE_ITEM_CLASS_KEY,
		["KEY_KEY"] = 0,
		["KEY_LOCKPICK"] = 1,
		
		["MISC"] = LE_ITEM_CLASS_MISCELLANEOUS,
		["MISC_JUNK"] = LE_ITEM_MISCELLANEOUS_JUNK,
		["MISC_REAGENT"] = LE_ITEM_MISCELLANEOUS_REAGENT,
		["MISC_PET"] = LE_ITEM_MISCELLANEOUS_COMPANION_PET,
		["MISC_HOLIDAY"] = LE_ITEM_MISCELLANEOUS_HOLIDAY,
		["MISC_OTHER"] = LE_ITEM_MISCELLANEOUS_OTHER,
		["MISC_MOUNT"] = LE_ITEM_MISCELLANEOUS_MOUNT,
		
		["GLYPH"] = LE_ITEM_CLASS_GLYPH,
		
		["BATTLEPET"] = LE_ITEM_CLASS_BATTLEPET,
--		"0 Humanoid", -- [163]
--		"1 Dragonkin", -- [164]
--		"2 Flying", -- [165]
--		"3 Undead", -- [166]
--		"4 Critter", -- [167]
--		"5 Magic", -- [168]
--		"6 Elemental", -- [169]
--		"7 Beast", -- [170]
--		"8 Aquatic", -- [171]
--		"9 Mechanical", -- [172]
		
		["WOW_TOKEN"] = ITEM_CLASS_WOW_TOKEN,
--		"0 WoW Token", -- [174]
		
	},
	
	Cursor = {
		Drag = [[Interface\CURSOR\Crosshairs]],
		UnableDrag = [[Interface\CURSOR\UnableCrosshairs]],
		--Driver Gunner Interact Item 
	},
	
	Texture = {
		
		Missing = [[Interface\Icons\Temp]],
		
		Empty = {
			Item = [[Interface\PaperDoll\UI-Backpack-EmptySlot]],
			Bag = [[Interface\PaperDoll\UI-PaperDoll-Slot-Bag]],
		},
		
		CategoryDamaged = [[Interface\Icons\Spell_Shadow_DeathCoil]],
		CategoryEnabled = [[Interface\RAIDFRAME\ReadyCheck-Ready]],
		CategoryDisabled = [[Interface\RAIDFRAME\ReadyCheck-NotReady]],
		
		BackgroundDefault = "Solid",
		
		BorderDefault = "Blizzard Tooltip",
		BorderNone = "None",
		
		Border = {
			["Blizzard Tooltip"] = {
				["size"] = 16,
				["offset"] = nil,
				["offsetdefault"] = {
					["slot"] = 4,
					["bar"] = 3,
					["window"] = 3,
				},
				["scale"] = 1,
			},
			["Blizzard Dialog"] = {
				["size"] = 32,
				["offset"] = nil,
				["offsetdefault"] = {
					["slot"] = 9,
					["bar"] = 6,
					["window"] = 6,
				},
			},
			["Blizzard Dialog Gold"] = {
				["size"] = 32,
				["offset"] = nil,
				["offsetdefault"] = {
					["slot"] = 9,
					["bar"] = 6,
					["window"] = 6,
				},
			},
			["ArkInventory Tooltip 1"] = {
				["size"] = 16,
				["offset"] = nil,
				["offsetdefault"] = {
					["slot"] = 3,
					["bar"] = 3,
					["window"] = 3,
				},
			},
			["ArkInventory Tooltip 2"] = {
				["size"] = 16,
				["offset"] = nil,
				["offsetdefault"] = {
					["slot"] = 4,
					["bar"] = 3,
					["window"] = 3,
				},
			},
			["ArkInventory Tooltip 3"] = {
				["size"] = 16,
				["offset"] = nil,
				["offsetdefault"] = {
					["slot"] = 5,
					["bar"] = 4,
					["window"] = 4,
				},
			},
			["ArkInventory Square 1"] = {
				["size"] = 16,
				["offset"] = nil,
				["offsetdefault"] = {
					["slot"] = 3,
					["bar"] = 3,
					["window"] = 3,
				},
			},
			["ArkInventory Square 2"] = {
				["size"] = 16,
				["offset"] = nil,
				["offsetdefault"] = {
					["slot"] = 4,
					["bar"] = 3,
					["window"] = 3,
				},
			},
			["ArkInventory Square 3"] = {
				["size"] = 16,
				["offset"] = nil,
				["offsetdefault"] = {
					["slot"] = 5,
					["bar"] = 4,
					["window"] = 4,
				},
			},
		},
		
		Junk = [[Interface\Icons\INV_Misc_Coin_02]],
		
		Yes = [[Interface\RAIDFRAME\ReadyCheck-Ready]],
		No = [[Interface\RAIDFRAME\ReadyCheck-NotReady]],
		
		Checked = [[Interface\RAIDFRAME\ReadyCheck-Ready]],
		atWar = [[Interface\RAIDFRAME\ReadyCheck-Ready]],
		
	},
	
	SortKeys = { -- true = keep, false = remove
		bagid = true,
		slotid = true,
		count = true,
		itemcount = false,
		category = true,
		location = true,
		itemuselevel = true,
		itemstatlevel = true,
		itemtype = true,
		quality = true,
		name = true,
		vendorprice = true,
		itemage = true,
		id = true,
		slottype = true,
		expansion = true,
	},
	
	DatabaseDefaults = { },
	
	MountTypes = {
		["l"] = 0x01, -- land
		["a"] = 0x02, -- air
--		["s"] = 0x04, -- water surface
		["u"] = 0x08, -- underwater
		["x"] = 0x00, -- ignored / unknown
	},
	
	booleantable = { true, false },
	
	Realm = { }, -- connected realm array
	
	SortWhen = {
		Instant = 1,
		Open = 2,
		Manual = 3,
	},
	
	ActionID = {
		MainMenu = 0,
		Close = 1,
		EditMode = 2,
		Rules = 3,
		Search = 4,
		SwitchCharacter = 5,
		SwitchLocation = 6,
		Restack = 7,
		Changer = 8,
		Refresh = 9,
	},
	
	Bind = { -- ITEM_BINDx
		Never = 0,
		Use = 1,
		Equip = 2,
		Pickup = 3,
		Account = 4,
	},
	
	Reputation = {
		Custom = {
			Default = 1,
			Custom = 2,
		},
		Style = {
			TooltipNormal = "*st**pv**pr* (*br*)", -- rep tooltip
			TooltipItemCount = "*st**pv**pr* (*br*)", -- itemcount tooltip
			TwoLines = "*st**pv**pr*\n*bc*", -- List view
			OneLine = "*st**pv**pr* *bc*", -- LDB tooltip
			OneLineWithName = "*nn*: *st**pv**pr* *bc*", -- LDB text
		},
	},
	
	Transmog = {
		State = {
			CanLearnMyself = 1,
			CanLearnMyselfSecondary = 2,
			CanLearnOther = 3,
			CanLearnOtherSecondary = 4,
		},
		StyleDefault = "Smiley Face",
		SharedMediaType = "arkinventory-icons-transmog",
	},
	
	Class = {
		Account = "ACCOUNT",
		Guild = "GUILD",
	},
	
	Move = {
		Bar = 1,
		Category = 2,
	},
	
	IDType = {
		Count = 1,
		Search = 2,
	},
	
	Tooltip = {
		-- used to convert tooltip:SetText into tooltip:SetHyperlink
		customHyperlinkFormat = "ArkInventory!!!%s",
		customHyperlinkMatch = "^ArkInventory!!!(.+)$",
		
		Search = {
			Full = 0, -- checks everything
			Base = 1, -- meant to skip around items in patterns/recipes
			Short = 2, -- stops at the first blank line
		},
	},
	
	CategoryTypes = { "SYSTEM", "CONSUMABLE", "TRADEGOODS", "SKILL", "CLASS", "EMPTY", "CUSTOM", "RULE", },
	
	--Tradeskill = { }, -- created elsewhere (needs localise which isnt available here)
	
	Flying = {
		Never = {
			Instance = {
				[1191] = true, -- Ashran (PvP)
				[1203] = true, -- Frostfire Finale
				[1265] = true, -- Tanaan Jungle Intro
				[1463] = true, -- Helheim Exterior Area
				[1669] = true, -- Argus
				
				[1107] = true, -- Warlock Order Hall - Dreadscar Rift
				[1469] = true, -- Shaman Order Hall - The Heart of Azeroth
				[1479] = true, -- Warrior Order Hall - Skyhold
				[1514] = true, -- Monk Order Hall - The Wandering Isle
				[1519] = true, -- Demon Hunter Order Hall - The Fel Hammer
				
				[1557] = true, -- Class Trial Boost
				
				[1750] = true, -- Exodar - Argus Intro
				[1760] = true, -- Battle for Lordaeron Scenario
				[1876] = true, -- Battle for Stormgarde
				
				-- bfa - island expeditions
				[1893] = true, -- dread chain
				[1897] = true, -- molten cay
				[1892] = true, -- rotting mire
				[1898] = true, -- skittering hollow
				[1813] = true, -- un'gol ruins
				[1882] = true, -- verdant isles
				[1883] = true, -- whispering reef
				
				-- extra races
				[1917] = true, -- Gorgrond - Mag'har scenario
				
				-- shadowlands
				[2364] = true, -- The Maw Intro
				[2363] = true, -- night fae - queens conservatory
				
				-- /dump GetInstanceInfo( )
			},
			Map = {
				[1543] = true, -- Shadowlands / The Maw
				[1670] = true, -- Shadowlands / Oribos Level 1
				[1671] = true, -- Shadowlands / Oribos Level 2
				[1961] = true, -- Shadowlands / Korthia
				
				-- /dump C_Map.GetBestMapForUnit( "player" )
			},
		},
		Achievement = {
--			[1116] = 10018 -- Draenor -- Draenor Pathfinder
--			[1464] = 10018 -- Tanaan Jungle
--			[1152] = 10018 -- Horde Garrison Level 1
--			[1330] = 10018 -- Horde Garrison Level 2
--			[1153] = 10018 -- Horde Garrison Level 3
--			[1154] = 10018 -- Horde Garrison Level 4
--			[1158] = 10018 -- Alliance Garrison Level 1
--			[1331] = 10018 -- Alliance Garrison Level 2
--			[1159] = 10018 -- Alliance Garrison Level 3
--			[1160] = 10018 -- Alliance Garrison Level 4
			
--			[1220] = 11446 -- Broken Isles -- Broken Isles Pathfinder Part 2
			
			[1642] = 13250, -- Zandalar / Battle for Azeroth Pathfinder Part 2
			[1643] = 13250, -- Kul Tiras / Battle for Azeroth Pathfinder Part 2
			[1718] = 13250, -- Nazjatar / Battle for Azeroth Pathfinder Part 2
--			[0000] = 13250, -- Rustbucket / Battle for Azeroth Pathfinder Part 2
			[2374] = 15514, -- Shadowlands / Zereth Mortis
		},
		Spell = {
		},
		Quest = {
			[2222] = 63893, -- Shadowlands Flying
		},
		Bug735 = {
			[0] = true, -- Eastern Kingdoms
			[1] = true, -- Kalimdor
--			[530] = true, -- Outland (appears to be working now)
			[571] = true, -- Northrend
			[730] = true, -- Maelstrom (Deepholm)
--			[870] = true, -- Pandaria (appears to be working now)
		},
	},
	
	YieldAfter = 25,
	
}

function ArkInventory.OutputSerialize( d )
	if d == nil then
		return "nil"
	elseif type( d ) == "number" then
		return tostring( d )
	elseif type( d ) == "string" then
		--return string.format( "%q", d )
		return d
	elseif type( d ) == "boolean" then
		if d then
			return "true"
		else
			return "false"
		end
	elseif type( d ) == "table" then
		local tmp = { }
		local c = 0
		for k, v in pairs( d ) do
			c = c + 1
			tmp[c] = string.format( "[%s]=%s", ArkInventory.OutputSerialize( k ), ArkInventory.OutputSerialize( v ) )
		end
		return string.format( "{ %s }", table.concat( tmp, ", " ) )
	else
		return string.format( "**%s**", type( d ) or ArkInventory.Localise["UNKNOWN"] )
	end
end

local ArkInventory_TempOutputTable = { }

function ArkInventory.Output( ... )
	
	if not DEFAULT_CHAT_FRAME then
		return
	end
	
	ArkInventory.Table.Wipe( ArkInventory_TempOutputTable )
	
	local n = select( '#', ... )
	
	if n == 0 then
		
		ArkInventory:Print( "nil" )
		
	else
		
		for i = 1, n do
			local v = select( i, ... )
			ArkInventory_TempOutputTable[i] = ArkInventory.OutputSerialize( v )
		end
		
		ArkInventory:Print( table.concat( ArkInventory_TempOutputTable ) )
		
	end
	
end

function ArkInventory.Output2( ... )
	if ArkInventory.Global.Debug2 then
		ArkInventory.Output( "|cff17ffc1", ... ) -- fffff99a
	end
end

function ArkInventory.OutputThread( ... )
	if ArkInventory.db.option.thread.debug then
		ArkInventory.Output( "|cffffff9aTHREAD> ", ... )
	end
end

function ArkInventory.OutputDebug( ... )
	if ArkInventory.Global.Debug then
		ArkInventory.Output( "|cffffff9aDEBUG> ", ... )
	end
end

function ArkInventory.OutputWarning( ... )
	ArkInventory.Output( "|cfffa8000WARNING> ", ... )
end

function ArkInventory.OutputError( ... )
	ArkInventory.Output( RED_FONT_COLOR_CODE, ERROR_CAPS, "> ", ... )
end

function ArkInventory.OutputDebugModeSet( value )
	
	if ArkInventory.Global.Debug ~= value then
		
		local state = ArkInventory.Localise["ENABLED"]
		if not value then
			state = ArkInventory.Localise["DISABLED"]
		end
		
		ArkInventory.Global.Debug = value
		
		ArkInventory.Output( "debug mode is now ", state )
		
	end
	
end


function ArkInventory.Table.Sum( src, fnc )
	local r = 0
	for k, v in pairs( src ) do
		r = r + ( fnc( v ) or 0 )
	end
	return r
end

function ArkInventory.Table.Max( src, fnc )
	local r = nil
	for k, v in pairs( src ) do
		if not r then
			r = ( fnc( v ) or 0 )
		else
			if ( fnc( v ) or 0 ) > r then
				r = ( fnc( v ) or 0 )
			end
		end
	end
	return r
end

function ArkInventory.Table.Elements( src )
	-- #table only returns the number of elements where the table keys are numeric and does not take into account missing values
	if src and type( src ) == "table" then
		local r = 0
		for k in pairs( src ) do
			r = r + 1
		end
		return r
	end
end

function ArkInventory.Table.IsEmpty( src )
	-- #table only returns the number of elements where the table keys are numeric and does not take into account missing values
	if src and type( src ) == "table" then
		for k in pairs( src ) do
			return false
		end
		return true
	end
end

function ArkInventory.Table.Clean( tbl, key, nilsubtables )
	
	-- tbl = table to be cleaned
	
	-- key = a specific key you want cleaned (nil for all keys)
	
	-- nilsubtables (true) = if a value is a table then nil it as well
	-- nilsubtables (false) = if a value is a table then leave the skeleton there
	
	if type( tbl ) ~= "table" then
		return
	end
	
	for k, v in pairs( tbl ) do
		
		if key == nil or key == k then
			
			if type( v ) == "table" then
				
				ArkInventory.Table.Clean( v, nil, nilsubtables )
				
				if nilsubtables then
					--ArkInventory.Output( "erasing subtable ", k )
					tbl[k] = nil
				end
				
			else
				
				--ArkInventory.Output( "erasing value ", k )
				tbl[k] = nil
				
			end
			
		end
		
	end
	
end

function ArkInventory.Table.Wipe( tbl )
	if type( tbl ) == "table" then
		table.wipe( tbl )
	end
end

function ArkInventory.Table.Copy( src )
	
	local cpy
	
	if type( src ) == "table" then
		
		cpy = { }
		
		for src_key, src_val in next, src, nil do
			cpy[ArkInventory.Table.Copy( src_key )] = ArkInventory.Table.Copy( src_val )
		end
		
		if getmetatable( src ) then
			setmetatable( cpy, ArkInventory.Table.Copy( getmetatable( src ) ) )
		end
		
	else
		
		cpy = src
		
	end
	
	return cpy
	
end

function ArkInventory.Table.Merge( src, dst )
	
	if type( src ) == "table" and type( dst ) == "table" then
		
		for key, val in next, src, nil do
			
			if type( val ) == "table" then
				if dst[key] == nil then
					dst[ArkInventory.Table.Copy( key )] = ArkInventory.Table.Copy( val )
				end
				ArkInventory.Table.Merge( src[key], dst[key] )
			else
				dst[ArkInventory.Table.Copy( key )] = ArkInventory.Table.Copy( val )
			end
			
		end
		
	end
	
end

function ArkInventory.Table.Subset( t1, t2 )
	
	-- t1 must be a subset of t2
	
	if type( t1 ) == "table" and type( t2 ) == "table" then
		
		for k, v in pairs( t1 ) do
			
			if type( v ) == "table" then
				if not ArkInventory.Table.Subset( v, t2[k] ) then
					return
				end
			elseif type( v ) == "number" or type( v ) == "string" then
				if v ~= t2[k] then
					return
				end
			end
			
		end
		
		return true
		
	end
	
end

function ArkInventory.Table.removeDefaults( tbl, def )
	
	if type( tbl ) ~= "table" then
		return
	end
	
	setmetatable( tbl, nil )
	
	for k, v in pairs( tbl ) do
		if type( v ) == "table" then
			if type( def ) == "table" then
				ArkInventory.Table.removeDefaults( v, def[k] )
			else	
				ArkInventory.Table.removeDefaults( v )
			end
			if ArkInventory.Table.IsEmpty( v ) then
				tbl[k] = nil
			end
		else
			if type( def ) == "table" and v == def[k] then
				tbl[k] = nil
			end
		end
	end
	
end

local function spairs_iter( a )
	a.idx = a.idx + 1
	local k = a[a.idx]
	if k ~= nil then
		return k, a.tbl[k]
	end
	--ArkInventory.Table.Wipe( a )
	a.tbl = nil
end

function ArkInventory.spairs( tbl, cf )
	
	if type( tbl ) ~= "table" then return end
	
	local a = { }
	local c = 0
	
	for k in pairs( tbl ) do
		c = c + 1
		a[c] = k
	end
	
	table.sort( a, cf )
	
	a.idx = 0
	a.tbl = tbl
	
	return spairs_iter, a
	
end

--[[
-- /dump GetItemClassInfo( ArkInventory.Const.ItemClass.ARMOR )
-- /dump GetItemSubClassInfo( ArkInventory.Const.ItemClass.ARMOR, ArkInventory.Const.ItemClass.ARMOR_LEATHER )

for x = 0, 50 do
	--local x = ArkInventory.Const.ItemClass.TRADEGOODS_HERBS
	local n = GetItemClassInfo( x )
	if n and n ~= "" then
		ArkInventory.Output( "----------" )
		ArkInventory.Output( x, " ", n )
	end
	for y = 0, 50 do
		n = GetItemSubClassInfo( x, y )
		if n and n ~= "" then
			ArkInventory.Output( y, " ", n )
		end
	end
end
]]--

--[[
local name
for x = 352170, 352180 do
--	if IsSpellKnown( x ) then
		name = GetSpellInfo( x )
--		if name and string.match( string.lower( name ), "flying" ) then
			ArkInventory.Output( x, " = ", name, " / ", IsSpellKnown( x ) )
--			GetSpellInfo( 352177 )
--			IsSpellKnown( 352177 )
--		end
--	end
end
]]--

-- item_openable = right click to open
--[[
local z = "while in combat"
ArkInventory.Output( "search=", z )
for k, v in pairs (_G) do
	if type( k ) == "string" and type( v ) == "string" then
		--if string.match( string.lower( k ), string.lower( z ) ) then -- found in key
		if string.match( string.lower( v ), string.lower( z ) ) then -- found in value
		--if string.lower( v ) == string.lower( z ) then -- exact match with value
			ArkInventory.Output( k, "=", v )
		end
	end
end
--]]
