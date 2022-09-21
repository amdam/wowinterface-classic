local L = LibStub( "AceLocale-3.0" ):NewLocale( "ArkInventory", "enUS", true, false )
if not L then return end

local function FormatForPattern( text )
	local text = text
	text = string.gsub( text, "%.", "%%%." ) -- replace . with %.
	text = string.gsub( text, "%*", "%%%*" ) -- replace * with %*
	text = string.gsub( text, "%+", "%%%+" ) -- replace + with %+
	text = string.gsub( text, "%-", "%%%-" ) -- replace - with %-
	text = string.gsub( text, "%?", "%%%?" ) -- replace ? with %?
	text = string.gsub( text, "%(", "%%%(" ) -- replace ( with %(
	text = string.gsub( text, "%)", "%%%)" ) -- replace ) with %)
	return text
end

local function FormatForCapture( text )
	
	if not text then
		--print( RED_FONT_COLOR_CODE .. "ArkInventory: code failure - FormatForCapture was passed a nil value, blizzard have changed something." )
		--assert( false, "code failure" )
		return
	end
	
	if string.find( text, "|" ) then
		print( RED_FONT_COLOR_CODE .. "ArkInventory: code error - FormatForCapture( " .. text .. ") contains || character.  check blizzard vlaues." )
		return
	end
	
	local text = FormatForPattern( text )
	text = string.gsub( text, "%d%$", "" ) -- remove 1$ / 2$
	text = string.gsub( text, "%%s", "(.+)" ) -- replace %s with (.+)
	text = string.gsub( text, "%%d", "%(%%d+%)" ) -- replace %d with (%d+)
	--text = string.gsub( text, "|4(.-):(.-);", "%(%1%)?%(%2%)?" )
	
	return string.format( "^%s$", text )
	
end

local function helper_GetCurrencyName( currencyID )
	local info = ArkInventory.CrossClient.GetCurrencyInfo( currencyID )
	return info and info.name
end

-- game client based localisations and internal stuff
L["TOC_FAIL"] = "*****  This is a Legion Beta version, it will not work on the live servers, please downgrade to 3.05.12  *****"

-- class names
L["WOW_CLASS_DRUID"] = LOCALIZED_CLASS_NAMES_MALE["DRUID"] or true
L["WOW_CLASS_HUNTER"] = LOCALIZED_CLASS_NAMES_MALE["HUNTER"] or true
L["WOW_CLASS_MAGE"] = LOCALIZED_CLASS_NAMES_MALE["MAGE"] or true
L["WOW_CLASS_PALADIN"] = LOCALIZED_CLASS_NAMES_MALE["PALADIN"] or true
L["WOW_CLASS_PRIEST"] = LOCALIZED_CLASS_NAMES_MALE["PRIEST"] or true
L["WOW_CLASS_ROGUE"] = LOCALIZED_CLASS_NAMES_MALE["ROGUE"] or true
L["WOW_CLASS_SHAMAN"] = LOCALIZED_CLASS_NAMES_MALE["SHAMAN"] or true
L["WOW_CLASS_WARLOCK"] = LOCALIZED_CLASS_NAMES_MALE["WARLOCK"] or true
L["WOW_CLASS_WARRIOR"] = LOCALIZED_CLASS_NAMES_MALE["WARRIOR"] or true
L["WOW_CLASS_DEATHKNIGHT"] = LOCALIZED_CLASS_NAMES_MALE["DEATHKNIGHT"] or true
L["WOW_CLASS_MONK"] = LOCALIZED_CLASS_NAMES_MALE["MONK"] or true
L["WOW_CLASS_DEMONHUNTER"] = LOCALIZED_CLASS_NAMES_MALE["DEMONHUNTER"] or true


-- skills that we dont need to lookup
L["WOW_SKILL_ARCHAEOLOGY"] = PROFESSIONS_ARCHAEOLOGY or true
L["WOW_SKILL_COOKING"] = PROFESSIONS_COOKING or true
L["WOW_SKILL_FIRSTAID"] = PROFESSIONS_FIRST_AID or true
L["WOW_SKILL_FISHING"] = PROFESSIONS_FISHING or true
L["WOW_SKILL_HERBALISM"] = string.match( UNIT_SKINNABLE_HERB, FormatForCapture( ITEM_REQ_SKILL ) ) or true
L["WOW_SKILL_INSCRIPTION"] = INSCRIPTION or true
L["WOW_SKILL_MINING"] = string.match( UNIT_SKINNABLE_ROCK, FormatForCapture( ITEM_REQ_SKILL ) ) or true
--L["WOW_SKILL_ENGINEERING"] = string.match( UNIT_SKINNABLE_BOLTS, FormatForCapture( ITEM_REQ_SKILL ) ) or true


-- category descriptions
L["CATEGORY_SYSTEM"] = CHAT_MSG_SYSTEM or true
L["CATEGORY_CONSUMABLE"] = AUCTION_CATEGORY_CONSUMABLES or true
L["CATEGORY_TRADEGOODS"] = AUCTION_CATEGORY_TRADE_GOODS or true
L["CATEGORY_ITEM_ENHANCEMENTS"] = AUCTION_CATEGORY_ITEM_ENHANCEMENTS or true
--L["CATEGORY_REAGENT"] = AUCTION_CATEGORY_REAGENT or true -- only exists in classic
L["CATEGORY_SKILL"] = SKILL or true
L["CATEGORY_CLASS"] = CLASS or true
L["CATEGORY_CUSTOM"] = CUSTOM or true
L["CATEGORY_EMPTY"] = EMPTY or true

L["CATEGORY_CONSUMABLE_FOOD"] = TUTORIAL_TITLE11 or true
L["CATEGORY_CONSUMABLE_DRINK"] = TUTORIAL_TITLE12 or true


-- ldb
L["LDB_MOUNTS_TYPE_A"] = BATTLE_PET_NAME_3 or true
L["LDB_MOUNTS_FLYING_DISMOUNT"] = AUTO_DISMOUNT_FLYING_TEXT or true
L["LDB_MOUNTS_FAIL_NOT_ALLOWED"] = SPELL_FAILED_NO_MOUNTS_ALLOWED or true
L["LDB_MOUNTS_FAIL_PACIFIED"] = SPELL_FAILED_PACIFIED or true


L["WOW_ITEM_TOOLTIP_10P3T"] = FIRST_NUMBER
L["WOW_ITEM_TOOLTIP_10P3S"] = FIRST_NUMBER_CAP_NO_SPACE
L["WOW_ITEM_TOOLTIP_10P6T"] = SECOND_NUMBER
L["WOW_ITEM_TOOLTIP_10P6S"] = SECOND_NUMBER_CAP_NO_SPACE
L["WOW_ITEM_TOOLTIP_10P9T"] = THIRD_NUMBER
--L["WOW_ITEM_TOOLTIP_10P9S"] = "B"
L["WOW_ITEM_TOOLTIP_10P12T"] = FOURTH_NUMBER
--L["WOW_ITEM_TOOLTIP_10P12S"] = "T"


-- generic words & passthru
L["ACCEPT"] = ACCEPT or true
L["ACTIVATE"] = ACTIVATE or true
L["ACTIVE"] = ACTIVE_PETS or true
L["ADD"] = ADD or true
L["ADVANCED"] = ADVANCED_LABEL or true
L["ALL"] = ALL or true
L["ALREADY_KNOWN"] = ITEM_SPELL_KNOWN or true
L["ALWAYS"] = ALWAYS or true
L["AMMO"] = INVTYPE_AMMO or true
L["ANIMA"] = POWER_TYPE_ANIMA or true
L["APPEARANCE"] = APPEARANCE_LABEL or true
L["ARTIFACT_POWER"] = ARTIFACT_POWER or true
L["ASSIGN"] = COMBAT_ALLY_START_MISSION or true
L["AT_WAR"] = AT_WAR or true
L["AUCTIONS"] = AUCTIONS or true
L["BACKPACK"] = BACKPACK_TOOLTIP or true
L["BAG"] = INVTYPE_BAG or true
L["BANK"] = BANK or true
L["BLIZZARD"] = "Blizzard"
L["AQUATIC"] = BATTLE_PET_NAME_9 or true
L["BACKGROUND"] = EMBLEM_BACKGROUND or true
L["BATTLEPET"] = TOOLTIP_BATTLE_PET or true
L["BONUS_REPUTATION_TITLE"] = BONUS_REPUTATION_TITLE or true
L["BONUS_REPUTATION_TOOLTIP"] = BONUS_REPUTATION_TOOLTIP or true
L["BORDER"] = EMBLEM_BORDER or true
L["CANCEL"] = CANCEL or true
L["CANNOT_UNEQUIP_ARENA"] = CANNOT_UNEQUIP_ARENA or true
L["CANNOT_UNEQUIP_COMBAT"] = CANNOT_UNEQUIP_COMBAT or true
L["CANNOT_UNEQUIP_MYTHIC_PLUS"] = CANNOT_UNEQUIP_MYTHIC_PLUS or true
L["CANNOT_UNEQUIP_TORGHAST"] = CANNOT_UNEQUIP_TORGHAST or true
L["CATEGORIES"] = CATEGORIES or true
L["CATEGORY"] = CATEGORY or true
L["CHARACTER"] = CHARACTER or true
L["CLASS_COLOURS"] = CLASS_COLORS or true
L["CLEANUP"] = BAG_FILTER_CLEANUP or true
L["CLEAR"] = KEY_NUMLOCK_MAC or true
L["CLOSE"] = CLOSE or true
L["COLOUR"] = COLOR or true
L["COLLECTED"] = COLLECTED or true
L["COMBAT"] = COMBAT or true
L["COMPANIONS"] = COMPANIONS or true
L["COMPLETE"] = COMPLETE or true
L["CONTROLS"] = CONTROLS_LABEL or true
L["COSMETIC"] = ITEM_COSMETIC or true
L["CURRENCY"] = CURRENCY or true
L["CURRENT"] = REFORGE_CURRENT or true
L["CUSTOM"] = CUSTOM or true
L["CRAFTING_REAGENT"] = PROFESSIONS_USED_IN_COOKING or true
L["DEFAULT"] = DEFAULT or true
L["DEFAULTS"] = DEFAULTS or true
L["DEBUG"] = BINDING_HEADER_DEBUG or true
L["DEFAULT"] = DEFAULT or true
L["DELETE"] = DELETE or true
L["DESCRIPTION"] = QUEST_DESCRIPTION or true
L["DISABLE"] = DISABLE or true
L["DISABLED"] = VIDEO_OPTIONS_DISABLED or true
L["DISPLAY"] = DISPLAY or true
L["DURABILITY"] = DURABILITY or true
L["DURATION"] = AUCTION_DURATION or true
L["EDIT"] = EDIT or true
L["ELEMENTAL"] = BATTLE_PET_NAME_7 or true
L["EMPTY"] = EMPTY or true
L["ENABLE"] = ENABLE or true
L["ENABLED"] = VIDEO_OPTIONS_ENABLED or true
L["EQUIP"] = EQUIPSET_EQUIP or true
L["EQUIPMENT"] = BAG_FILTER_EQUIPMENT or WORLD_QUEST_REWARD_FILTERS_EQUIPMENT or true
L["EXPANSION"] = EXPANSION_FILTER_TEXT or true
L["FACTION_INACTIVE"] = FACTION_INACTIVE or true
L["FILTER"] = FILTER or true
L["FONT_SIZE"] = FONT_SIZE or true
L["FULL"] = LOC_TYPE_FULL or true
L["GENERAL"] = GENERAL or true
L["GEMS"] = AUCTION_CATEGORY_GEMS or true
L["HEART_OF_AZEROTH_INACTIVE"] = HEART_OF_AZEROTH_INACTIVE or true
L["HEIRLOOM"] = ITEM_QUALITY7_DESC or true
L["HIDE"] = HIDE or true
L["HIGH"] = HIGH or true
L["ICON"] = EMBLEM_SYMBOL or true
L["IGNORE"] = IGNORE or true
L["INACTIVE"] = FACTION_INACTIVE or true
L["INFO"] = INFO or true
L["INSTANT"] = SPELL_CAST_TIME_INSTANT or true
L["INTERFACE"] = UIOPTIONS_MENU or true
L["ITEM"] = HELPFRAME_ITEM_TITLE or true
L["ITEM_BIND0"] = NEVER or true
L["ITEM_BIND1"] = ITEM_BIND_ON_USE or true
L["ITEM_BIND2"] = ITEM_BIND_ON_EQUIP or true
L["ITEM_BIND3"] = ITEM_SOULBOUND or true
L["ITEM_BIND4"] = ITEM_ACCOUNTBOUND or true
L["ITEM_CANNOT_DISENCHANT"] = ITEM_DISENCHANT_NOT_DISENCHANTABLE or true
L["ITEM_CANNOT_OBLITERATE"] = ITEM_OBLITERATEABLE_NOT or true
L["ITEM_CANNOT_SCRAP"] = ITEM_SCRAPABLE_NOT or true
L["ITEM_LEVEL"] = STAT_AVERAGE_ITEM_LEVEL or true
L["ITEMS"] = ITEMS or true
L["JUNK"] = BAG_FILTER_JUNK or true
L["KEYRING"] = KEYRING or true
L["LEARN"] = LEARN or true
L["LEARNED"] = TRADE_SKILLS_LEARNED_TAB or true
L["LOCK"] = LOCK or true
L["LOCKED"] = LOCKED or true
L["LOW"] = LOW or true
L["MAIL"] = MAIL_LABEL or true
L["MAILBOX"] = MINIMAP_TRACKING_MAILBOX or true
L["MAXIMUM"] = MAXIMUM or true
L["MEDIUM"] = TIME_LEFT_MEDIUM or true
L["MERCHANT"] = MERCHANT or true
L["MINIMUM"] = MINIMUM or true
L["MISCELLANEOUS"] = MISCELLANEOUS or true
L["MOUNT"] = MOUNT or true
L["MOUNTS"] = MOUNTS or true
L["MODE"] = MODE or true
L["MONEY"] = MONEY or true
L["MOVE"] = NPE_MOVE or true
L["MOVE_DOWN"] = TRACKER_SORT_MANUAL_DOWN or true
L["MOVE_TO_INACTIVE"] = MOVE_TO_INACTIVE or true
L["MOVE_UP"] = TRACKER_SORT_MANUAL_UP or true
L["NAME"] = NAME or true
L["NEW"] = NEW or true
L["NO"] = NO or true
L["NONE"] = NONE or true
L["NOT_COLLECTED"] = NOT_COLLECTED or true
L["NOT_BOUND"] = NOT_BOUND or true
L["OFFLINE"] = PLAYER_OFFLINE or true
L["OKAY"] = OKAY or true
L["ONLINE"] = FRIENDS_LIST_ONLINE or true
L["OPEN"] = OPEN or true
L["OPTION_TOOLTIP_REVERSE_NEW_LOOT"] = OPTION_TOOLTIP_REVERSE_NEW_LOOT or true
L["OPTIONS"] = GAMEOPTIONS_MENU or true
L["OTHER"] = OTHER or true
L["PET"] = PET or true
L["PETS"] = PETS or true
L["POWER"] = POWER_TYPE_POWER or true
L["PREVIOUS_RANK_UNKNOWN"] = TOOLTIP_SUPERCEDING_SPELL_NOT_KNOWN or true
L["QUALITY"] = QUALITY or true
L["QUEST"] = BATTLE_PET_SOURCE_2 or true
L["QUIVER"] = INVTYPE_QUIVER or true
L["RANGED"] = INVTYPE_RANGED or true
L["REAGENTBANK"] = REAGENT_BANK or true
L["REFRESH"] = REFRESH or true
L["REMOVE"] = REMOVE or true
L["RENAME"] = PET_RENAME or true
L["REPUTATION"] = REPUTATION or true
L["REPUTATION_AT_WAR_DESCRIPTION"] = REPUTATION_AT_WAR_DESCRIPTION or true
L["REPUTATION_MOVE_TO_INACTIVE"] = REPUTATION_MOVE_TO_INACTIVE or true
L["REPUTATION_SHOW_AS_XP"] = REPUTATION_SHOW_AS_XP or true
L["RESET"] = RESET or true
L["REVERSE_NEW_LOOT_TEXT"] = REVERSE_NEW_LOOT_TEXT or true
L["RULES"] = BRAWL_TOOLTIP_RULES or true
L["SAVE"] = SAVE or true
L["SANCTUM_SPECIAL_AREA_NIGHTFAE"] = GARDENWEALD_STATUS_HEADER or true
L["SEARCH"] = SEARCH or true
L["SECONDARY_SKILLS"] = SECONDARY_SKILLS or true
L["SETTINGS"] = SETTINGS or true
L["SHORT"] = SHORT or true
L["SHOW"] = SHOW or true
L["SHOW_FACTION_ON_MAINSCREEN"] = SHOW_FACTION_ON_MAINSCREEN or true
L["SHOW_ON_BACKPACK"] = SHOW_ON_BACKPACK or true
L["SORT_BY"] = RAID_FRAME_SORT_LABEL or true
L["SOULBOUND"] = ITEM_SOULBOUND or true
L["SPECIAL"] = SPECIAL or true
L["START"] = START or true
L["STATUS"] = STATUS or true
L["SUMMON"] = SUMMON or true
L["TEXT"] = LOCALE_TEXT_LABEL or true
L["TOKEN_MOVE_TO_UNUSED"] = TOKEN_MOVE_TO_UNUSED or true
L["TOP"] = TRACK_QUEST_TOP_SORTING or true
L["TOTAL"] = TOTAL or true
L["TOY"] = TOY or true
L["TOYBOX"] = TOY_BOX or true
L["TRACKING"] = TRACKING or true
L["TRACK"] = TRACK_QUEST_ABBREV or true
L["TRADE"] = TRADE or true
L["TRADESKILL"] = BATTLE_PET_SOURCE_4 or true
L["TRADESKILLS"] = TRADE_SKILLS or true
L["TRANSMOGRIFY"] = TRANSMOGRIFY or true
L["TYPE"] = TYPE or true
L["UNAVAILABLE"] = UNAVAILABLE or true
L["UNKNOWN"] = UNKNOWN or true
L["UNLEARNED"] = TRADE_SKILLS_UNLEARNED_TAB or true
L["UNTRACK"] = UNTRACK_QUEST_ABBREV or true
L["UNUSED"] = UNUSED or true
L["UPGRADE"] = UPGRADE or true
L["VAULT"] = GUILD_BANK or true
L["VOIDSTORAGE"] = VOID_STORAGE or true
L["VIEW"] = VIEW or true
L["WEEKLY"] = WEEKLY or true
L["YES"] = YES or true

-- calculated

L["WOW_TOOLTIP_ITEM_BIND_ON_USE"] = FormatForCapture( ITEM_BIND_ON_USE ) or true
L["WOW_TOOLTIP_ITEM_BIND_ON_EQUIP"] = FormatForCapture( ITEM_BIND_ON_EQUIP ) or true
L["WOW_TOOLTIP_ITEM_SOULBOUND"] = FormatForCapture( ITEM_SOULBOUND ) or true
L["WOW_TOOLTIP_ITEM_BIND_ON_PICKUP"] = FormatForCapture( ITEM_BIND_ON_PICKUP ) or true
L["WOW_TOOLTIP_ITEM_ACCOUNTBOUND"] = FormatForCapture( ITEM_ACCOUNTBOUND ) or true
L["WOW_TOOLTIP_ITEM_BIND_TO_ACCOUNT"] = FormatForCapture( ITEM_BIND_TO_ACCOUNT ) or true
L["WOW_TOOLTIP_ITEM_BIND_TO_BNETACCOUNT"] = FormatForCapture( ITEM_BIND_TO_BNETACCOUNT ) or true
L["WOW_TOOLTIP_ITEM_BNETACCOUNTBOUND"] = FormatForCapture( ITEM_BNETACCOUNTBOUND ) or true
L["WOW_TOOLTIP_ITEM_TOY_ONUSE"] = FormatForCapture( ITEM_TOY_ONUSE ) or true
L["WOW_TOOLTIP_ITEM_COSMETIC"] = FormatForCapture( ITEM_COSMETIC ) or true

L["WOW_TOOLTIP_REQUIRES_SKILL"] = FormatForCapture( ITEM_MIN_SKILL ) or true
L["WOW_TOOLTIP_REQUIRES_LEVEL"] = FormatForCapture( ITEM_MIN_LEVEL ) or true
L["WOW_TOOLTIP_REQUIRES_CLASS"] = FormatForCapture( ITEM_CLASSES_ALLOWED ) or true
L["WOW_TOOLTIP_REQUIRES"] = FormatForCapture( ITEM_REQ_SKILL ) or true
L["WOW_TOOLTIP_ITEMUPGRADELEVEL"] = FormatForCapture( ITEM_UPGRADE_TOOLTIP_FORMAT ) or true
L["WOW_TOOLTIP_ITEM_LEVEL"] = FormatForCapture( ITEM_LEVEL ) or true
L["WOW_TOOLTIP_ANCIENT_MANA"] = helper_GetCurrencyName( 1155 ) or true
L["WOW_TOOLTIP_ARTIFACT_POWER"] = FormatForCapture( ARTIFACT_POWER ) or true
L["WOW_TOOLTIP_ARTIFACT_POWER_AMOUNT"] = "^.-([%d,.]+)%s(.+)"
if POWER_TYPE_ANIMA then
	L["WOW_TOOLTIP_ANIMA"] = FormatForCapture( POWER_TYPE_ANIMA ) or true
end
L["WOW_TOOLTIP_CONDUIT_POTENCY"] = CONDUIT_TYPE_POTENCY or true
L["WOW_TOOLTIP_CONDUIT_FINESSE"] = CONDUIT_TYPE_FINESSE or true
L["WOW_TOOLTIP_CONDUIT_ENDURANCE"] = CONDUIT_TYPE_ENDURANCE or true
L["WOW_TOOLTIP_RETRIEVING_ITEM_INFO"] = RETRIEVING_ITEM_INFO or true
L["WOW_TOOLTIP_RELIC_LEVEL"] = FormatForCapture( RELIC_TOOLTIP_ILVL_INCREASE ) or true
L["WOW_TOOLTIP_DURABLITY"] = FormatForCapture( DURABILITY_TEMPLATE ) or true

L["WOW_TOOLTIP_BIND_PARTYLOOT"] = FormatForCapture( BIND_TRADE_TIME_REMAINING ) or true
L["WOW_TOOLTIP_BIND_REFUNDABLE"] = FormatForCapture( REFUND_TIME_REMAINING ) or true

L["WOW_TOOLTIP_DAMAGE"] = string.format( " %s$", DAMAGE )

L["DATA_NOT_READY"] = string.format( GARRISON_TEMPORARY_CATEGORY_FORMAT, RETRIEVING_DATA )

L["PET_CANNOT_BATTLE"] = string.gsub( BATTLE_PET_CANNOT_BATTLE, "\n", " " )

L["MINUTES"] = string.match( D_MINUTES, ":(.-);$" ) or true
L["SECONDS"] = string.match( D_SECONDS, ":(.-);$" ) or true

L["SPELL_DRUID_TRAVEL_FORM"] = ( GetSpellInfo( 783 ) ) or true

L["UNKNOWN_OBJECT"] = "Unknown Object [%s]"



-- generated from item class table

local itemClassTable = {
	
	{ "WOW_ITEM_CLASS_WEAPON", ArkInventory.Const.ItemClass.WEAPON },
	
	{ "WOW_ITEM_CLASS_ARMOR", ArkInventory.Const.ItemClass.ARMOR },
	{ "WOW_ITEM_CLASS_ARMOR_CLOTH", ArkInventory.Const.ItemClass.ARMOR, ArkInventory.Const.ItemClass.ARMOR_CLOTH },
	{ "WOW_ITEM_CLASS_ARMOR_LEATHER", ArkInventory.Const.ItemClass.ARMOR, ArkInventory.Const.ItemClass.ARMOR_LEATHER },
	
	{ "WOW_ITEM_CLASS_CONTAINER", ArkInventory.Const.ItemClass.CONTAINER },
	{ "WOW_ITEM_CLASS_CONTAINER_BAG", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_BAG },
	{ "WOW_ITEM_CLASS_CONTAINER_COOKING", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_COOKING },
	{ "WOW_ITEM_CLASS_CONTAINER_ENCHANTING", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_ENCHANTING },
	{ "WOW_ITEM_CLASS_CONTAINER_ENGINEERING", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_ENGINEERING },
	{ "WOW_ITEM_CLASS_CONTAINER_FISHING", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_FISHING },
	{ "WOW_ITEM_CLASS_CONTAINER_HERBALISM", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_HERB },
	{ "WOW_ITEM_CLASS_CONTAINER_INSCRIPTION", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_INSCRIPTION },
	{ "WOW_ITEM_CLASS_CONTAINER_JEWELCRAFTING", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_JEWELCRAFTING },
	{ "WOW_ITEM_CLASS_CONTAINER_LEATHERWORKING", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_LEATHERWORKING },
	{ "WOW_ITEM_CLASS_CONTAINER_MINING", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_MINING },
	{ "WOW_ITEM_CLASS_CONTAINER_SOULSHARD", ArkInventory.Const.ItemClass.CONTAINER, ArkInventory.Const.ItemClass.CONTAINER_SOULSHARD },
	
	{ "WOW_ITEM_CLASS_QUIVER", ArkInventory.Const.ItemClass.QUIVER },
	{ "WOW_ITEM_CLASS_QUIVER_ARROW", ArkInventory.Const.ItemClass.QUIVER, ArkInventory.Const.ItemClass.QUIVER_ARROW },
	{ "WOW_ITEM_CLASS_QUIVER_BULLET", ArkInventory.Const.ItemClass.QUIVER, ArkInventory.Const.ItemClass.QUIVER_BULLET },
	
	{ "WOW_ITEM_CLASS_PROJECTILE", ArkInventory.Const.ItemClass.PROJECTILE },
	{ "WOW_ITEM_CLASS_PROJECTILE_ARROW", ArkInventory.Const.ItemClass.PROJECTILE, ArkInventory.Const.ItemClass.PROJECTILE_ARROW },
	{ "WOW_ITEM_CLASS_PROJECTILE_BULLET", ArkInventory.Const.ItemClass.PROJECTILE, ArkInventory.Const.ItemClass.PROJECTILE_BULLET },
	
	{ "WOW_ITEM_CLASS_CONSUMABLE", ArkInventory.Const.ItemClass.CONSUMABLE },
	{ "WOW_ITEM_CLASS_CONSUMABLE_EXPLOSIVES_AND_DEVICES", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_EXPLOSIVES_AND_DEVICES },
	{ "WOW_ITEM_CLASS_CONSUMABLE_POTION", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_POTION },
	{ "WOW_ITEM_CLASS_CONSUMABLE_ELIXIR", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_ELIXIR },
	{ "WOW_ITEM_CLASS_CONSUMABLE_FLASK", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_FLASK },
	{ "WOW_ITEM_CLASS_CONSUMABLE_SCROLL", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_SCROLL },
	{ "WOW_ITEM_CLASS_CONSUMABLE_FOOD_AND_DRINK", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_FOOD_AND_DRINK },
	{ "WOW_ITEM_CLASS_CONSUMABLE_ITEM_ENHANCEMENT", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_ITEM_ENHANCEMENT },
	{ "WOW_ITEM_CLASS_CONSUMABLE_BANDAGE", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_BANDAGE },
	{ "WOW_ITEM_CLASS_CONSUMABLE_OTHER", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_OTHER },
	{ "WOW_ITEM_CLASS_CONSUMABLE_VANTUSRUNE", ArkInventory.Const.ItemClass.CONSUMABLE, ArkInventory.Const.ItemClass.CONSUMABLE_VANTUSRUNE },
	
	{ "WOW_ITEM_CLASS_GLYPH", ArkInventory.Const.ItemClass.GLYPH },
	
	{ "WOW_ITEM_CLASS_TRADEGOODS", ArkInventory.Const.ItemClass.TRADEGOODS },
	{ "WOW_ITEM_CLASS_TRADEGOODS_PARTS", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_PARTS },
	{ "WOW_ITEM_CLASS_TRADEGOODS_EXPLOSIVES", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_EXPLOSIVES },
	{ "WOW_ITEM_CLASS_TRADEGOODS_DEVICES", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_DEVICES },
	{ "WOW_ITEM_CLASS_TRADEGOODS_JEWELCRAFTING", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_JEWELCRAFTING },
	{ "WOW_ITEM_CLASS_TRADEGOODS_CLOTH", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_CLOTH },
	{ "WOW_ITEM_CLASS_TRADEGOODS_LEATHER", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_LEATHER },
	{ "WOW_ITEM_CLASS_TRADEGOODS_METAL_AND_STONE", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_METAL_AND_STONE },
	{ "WOW_ITEM_CLASS_TRADEGOODS_COOKING", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_COOKING },
	{ "WOW_ITEM_CLASS_TRADEGOODS_HERBS", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_HERBS },
	{ "WOW_ITEM_CLASS_TRADEGOODS_ELEMENTAL", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_ELEMENTAL },
	{ "WOW_ITEM_CLASS_TRADEGOODS_OTHER", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_OTHER },
	{ "WOW_ITEM_CLASS_TRADEGOODS_ENCHANTING", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_ENCHANTING },
	{ "WOW_ITEM_CLASS_TRADEGOODS_INSCRIPTION", ArkInventory.Const.ItemClass.TRADEGOODS, ArkInventory.Const.ItemClass.TRADEGOODS_INSCRIPTION },
	
	{ "WOW_ITEM_CLASS_RECIPE", ArkInventory.Const.ItemClass.RECIPE },
	{ "WOW_ITEM_CLASS_RECIPE_LEATHERWORKING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_LEATHERWORKING },
	{ "WOW_ITEM_CLASS_RECIPE_TAILORING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_TAILORING },
	{ "WOW_ITEM_CLASS_RECIPE_ENGINEERING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_ENGINEERING },
	{ "WOW_ITEM_CLASS_RECIPE_BLACKSMITHING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_BLACKSMITHING },
	{ "WOW_ITEM_CLASS_RECIPE_COOKING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_COOKING },
	{ "WOW_ITEM_CLASS_RECIPE_ALCHEMY", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_ALCHEMY },
	{ "WOW_ITEM_CLASS_RECIPE_FIRST_AID", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_FIRST_AID },
	{ "WOW_ITEM_CLASS_RECIPE_ENCHANTING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_ENCHANTING },
	{ "WOW_ITEM_CLASS_RECIPE_FISHING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_FISHING },
	{ "WOW_ITEM_CLASS_RECIPE_JEWELCRAFTING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_JEWELCRAFTING },
	{ "WOW_ITEM_CLASS_RECIPE_INSCRIPTION", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_INSCRIPTION },
	
	{ "WOW_ITEM_CLASS_GEM", ArkInventory.Const.ItemClass.GEM },
--	{ "WOW_ITEM_CLASS_GEM_ARTIFACTRELIC", ArkInventory.Const.ItemClass.GEM, ArkInventory.Const.ItemClass.GEM_ARTIFACTRELIC },
	
	{ "WOW_ITEM_CLASS_ITEM_ENHANCEMENT", ArkInventory.Const.ItemClass.ITEM_ENHANCEMENT },
	
	{ "WOW_ITEM_CLASS_REAGENT", ArkInventory.Const.ItemClass.REAGENT },
	
	{ "WOW_ITEM_CLASS_PET", ArkInventory.Const.ItemClass.BATTLEPET },
	
	{ "WOW_ITEM_CLASS_KEY", ArkInventory.Const.ItemClass.KEY },
	
	{ "WOW_ITEM_CLASS_MISC", ArkInventory.Const.ItemClass.MISC },
	{ "WOW_ITEM_CLASS_MISC_JUNK", ArkInventory.Const.ItemClass.MISC, 0 },
	{ "WOW_ITEM_CLASS_MISC_REAGENT", ArkInventory.Const.ItemClass.MISC, ArkInventory.Const.ItemClass.MISC_REAGENT },
	{ "WOW_ITEM_CLASS_MISC_PET", ArkInventory.Const.ItemClass.MISC, ArkInventory.Const.ItemClass.MISC_PET },
	{ "WOW_ITEM_CLASS_MISC_HOLIDAY", ArkInventory.Const.ItemClass.MISC, ArkInventory.Const.ItemClass.MISC_HOLIDAY },
	{ "WOW_ITEM_CLASS_MISC_OTHER", ArkInventory.Const.ItemClass.MISC, ArkInventory.Const.ItemClass.MISC_OTHER },
	{ "WOW_ITEM_CLASS_MISC_MOUNT", ArkInventory.Const.ItemClass.MISC, ArkInventory.Const.ItemClass.MISC_MOUNT },
	
	{ "WOW_ITEM_CLASS_QUEST", ArkInventory.Const.ItemClass.QUEST },
	
	-- skills that dont have a hardcoded
	{ "WOW_SKILL_ALCHEMY", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_ALCHEMY },
	{ "WOW_SKILL_BLACKSMITHING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_BLACKSMITHING },
	{ "WOW_SKILL_ENCHANTING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_ENCHANTING },
	{ "WOW_SKILL_ENGINEERING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_ENGINEERING },
--	{ "WOW_SKILL_INSCRIPTION", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_INSCRIPTION },
	{ "WOW_SKILL_JEWELCRAFTING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_JEWELCRAFTING },
	{ "WOW_SKILL_LEATHERWORKING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_LEATHERWORKING },
	{ "WOW_SKILL_TAILORING", ArkInventory.Const.ItemClass.RECIPE, ArkInventory.Const.ItemClass.RECIPE_TAILORING },
	
}

for _, v in ipairs( itemClassTable ) do
	
	local key, i1, i2 = v[1], v[2], v[3]
	
	if key then
		
		local text = nil
		
		if i1 and i2 then
			text = GetItemSubClassInfo( i1, i2 )
		elseif i1 then
			text = GetItemClassInfo( i1 )
		end
		
		if text then
			L[key] = text
			--print( string.format( "%s (%s-%s) = %s", key, i1, i2 or 0, text or "nil" ) )
		end
		
		
	end
	
end

ArkInventory.Table.Wipe( itemClassTable )
itemClassTable = nil


-- set all to true so that they exist and can be over-ridden by the translation update code, wont get over-ridden here because the api wont allow it

L["WOW_ITEM_CLASS_KEY"] = true

L["WOW_ITEM_CLASS_WEAPON"] = true

L["WOW_ITEM_CLASS_ARMOR"] = true
L["WOW_ITEM_CLASS_ARMOR_CLOTH"] = true
L["WOW_ITEM_CLASS_ARMOR_LEATHER"] = true

L["WOW_ITEM_CLASS_CONSUMABLE"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_EXPLOSIVES_AND_DEVICES"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_POTION"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_ELIXIR"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_FLASK"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_SCROLL"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_FOOD_AND_DRINK"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_ITEM_ENHANCEMENT"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_BANDAGE"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_OTHER"] = true
L["WOW_ITEM_CLASS_CONSUMABLE_VANTUSRUNE"] = true

L["WOW_ITEM_CLASS_CONTAINER"] = true
L["WOW_ITEM_CLASS_CONTAINER_BAG"] = true
L["WOW_ITEM_CLASS_CONTAINER_COOKING"] = true
L["WOW_ITEM_CLASS_CONTAINER_ENCHANTING"] = true
L["WOW_ITEM_CLASS_CONTAINER_ENGINEERING"] = true
L["WOW_ITEM_CLASS_CONTAINER_FISHING"] = true
L["WOW_ITEM_CLASS_CONTAINER_JEWELCRAFTING"] = true
L["WOW_ITEM_CLASS_CONTAINER_HERBALISM"] = true
L["WOW_ITEM_CLASS_CONTAINER_INSCRIPTION"] = true
L["WOW_ITEM_CLASS_CONTAINER_LEATHERWORKING"] = true
L["WOW_ITEM_CLASS_CONTAINER_MINING"] = true
L["WOW_ITEM_CLASS_CONTAINER_SOULSHARD"] = true

L["WOW_ITEM_CLASS_QUIVER"] = true
L["WOW_ITEM_CLASS_QUIVER_ARROW"] = true
L["WOW_ITEM_CLASS_QUIVER_BULLET"] = true

L["WOW_ITEM_CLASS_PROJECTILE"] = true
L["WOW_ITEM_CLASS_PROJECTILE_ARROW"] = true
L["WOW_ITEM_CLASS_PROJECTILE_BULLET"] = true

L["WOW_ITEM_CLASS_GEM"] = true
--L["WOW_ITEM_CLASS_GEM_ARTIFACTRELIC"] = true

L["WOW_ITEM_CLASS_ITEM_ENHANCEMENT"] = true

L["WOW_ITEM_CLASS_REAGENT"] = true

L["WOW_ITEM_CLASS_GLYPH"] = true

L["WOW_ITEM_CLASS_MISC"] = true
L["WOW_ITEM_CLASS_MISC_MOUNT"] = true
L["WOW_ITEM_CLASS_PET"] = true
L["WOW_ITEM_CLASS_MISC_REAGENT"] = true
L["WOW_ITEM_CLASS_MISC_JUNK"] = true

L["WOW_ITEM_CLASS_QUEST"] = true

L["WOW_ITEM_CLASS_SOULSHARD"] = true

L["WOW_ITEM_CLASS_TRADEGOODS"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_ELEMENTAL"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_CLOTH"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_LEATHER"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_METAL_AND_STONE"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_COOKING"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_HERBS"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_ENCHANTING"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_JEWELCRAFTING"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_PARTS"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_EXPLOSIVES"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_DEVICES"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_OTHER"] = true
L["WOW_ITEM_CLASS_TRADEGOODS_INSCRIPTION"] = true

L["WOW_ITEM_CLASS_RECIPE"] = true
L["WOW_ITEM_CLASS_RECIPE_ALCHEMY"] = true
L["WOW_ITEM_CLASS_RECIPE_BLACKSMITHING"] = true
L["WOW_ITEM_CLASS_RECIPE_COOKING"] = true
L["WOW_ITEM_CLASS_RECIPE_ENCHANTING"] = true
L["WOW_ITEM_CLASS_RECIPE_ENGINEERING"] = true
L["WOW_ITEM_CLASS_RECIPE_FIRST_AID"] = true
L["WOW_ITEM_CLASS_RECIPE_FISHING"] = true
L["WOW_ITEM_CLASS_RECIPE_INSCRIPTION"] = true
L["WOW_ITEM_CLASS_RECIPE_JEWELCRAFTING"] = true
L["WOW_ITEM_CLASS_RECIPE_LEATHERWORKING"] = true
L["WOW_ITEM_CLASS_RECIPE_TAILORING"] = true

L["WOW_SKILL_ALCHEMY"] = true
L["WOW_SKILL_BLACKSMITHING"] = true
L["WOW_SKILL_ENCHANTING"] = true
L["WOW_SKILL_ENGINEERING"] = true
L["WOW_SKILL_HERBALISM"] = true
L["WOW_SKILL_INSCRIPTION"] = true
L["WOW_SKILL_JEWELCRAFTING"] = true
L["WOW_SKILL_LEATHERWORKING"] = true
L["WOW_SKILL_MINING"] = true
L["WOW_SKILL_SKINNING"] = true
L["WOW_SKILL_TAILORING"] = true

L["WOW_ITEM_SOULSHARD"] = true
L["WOW_ITEM_PROJECTILE_ARROW"] = true
L["WOW_ITEM_PROJECTILE_BULLET"] = true
