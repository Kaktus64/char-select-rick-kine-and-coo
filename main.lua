-- name: [CS] Rick, Kine & Coo
-- description: ello mate

local TEXT_MOD_NAME = "[CS] Rick, Kine & Coo"

-- Stops mod from loading if Character Select isn't on
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_RICK_TH = smlua_model_util_get_id("rick_th_geo")

local E_MODEL_RICK_TH_ROCK = smlua_model_util_get_id("rick_th_rock_geo")

local E_MODEL_COO_TO = smlua_model_util_get_id("coo_to_geo")

local E_MODEL_KINE_TF = smlua_model_util_get_id("kine_tf_geo")

local RICK_TH_ICON = get_texture_info("rick_th_icon")

local TEX_RICK_TH_GRAFFITI = get_texture_info("RICK_TH_GRAFFITI")

local PALETTE_RICK_TH = {

    [PANTS]  = "FFFFFF", -- RICK'S WHITE COAT/COO'S WHITE COAT
    [SHIRT]  = "FF9731", -- RICK'S ORANGEISH COAT
    [GLOVES] = "DB9C70", -- COO'S FEET
    [SHOES]  = "FF89A1", -- RICK'S FEET
    [HAIR]   = "743F39", -- COO'S PURPLE COAT
    [SKIN]   = "FFFFFF", -- KINE'S SKIN
    [CAP]    = "FF9731", -- KINE'S FINS
	[EMBLEM] = "ff6993"  -- KINE'S MOUTH/COO'S BEAK
}

local PALETTE_RICK_AIR_RIDERS = {

    [PANTS]  = "ebe2c4",
    [SHIRT]  = "a17c66",
    [GLOVES] = "DB9C70",
    [SHOES]  = "d46d50",
    [HAIR]   = "743F39",
    [SKIN]   = "ebe2c4",
    [CAP]    = "a17c66",
	[EMBLEM] = "ff6993"
}

local PALETTE_PICK_TH = {

    [PANTS]  = "FFFFFF",
    [SHIRT]  = "f09088",
    [GLOVES] = "DB9C70",
    [SHOES]  = "e83030",
    [HAIR]   = "743F39",
    [SKIN]   = "FFFFFF",
    [CAP]    = "f09088",
	[EMBLEM] = "ff6993"
}

local PALETTE_KIRBY_RTH = {

    [PANTS]  = "fc96be",
    [SHIRT]  = "fc96be",
    [GLOVES] = "DB9C70",
    [SHOES]  = "e5200f",
    [HAIR]   = "743F39",
    [SKIN]   = "fc96be",
    [CAP]    = "fc96be",
	[EMBLEM] = "e5200f"
}

local PALETTE_RICK_DL2 = {

    [PANTS]  = "ffffff",
    [SHIRT]  = "f8c088",
    [GLOVES] = "DB9C70",
    [SHOES]  = "f8c088",
    [HAIR]   = "743F39",
    [SKIN]   = "ffffff",
    [CAP]    = "f8c088",
	[EMBLEM] = "e5200f"
}

local PALETTE_COO_TO = {

    [PANTS]  = "FFFFFF",
    [SHIRT]  = "FF9731",
    [GLOVES] = "DB9C70",
    [SHOES]  = "FFC000",
    [HAIR]   = "000000", 
    [SKIN]   = "FFFFFF", 
    [CAP]    = "805FAA", 
	[EMBLEM] = "ff6993"  
}

local PALETTE_COO_AIR_RIDERS = {

    [PANTS]  = "ebe2c4",
    [SHIRT]  = "a17c66",
    [GLOVES] = "DB9C70",
    [SHOES]  = "d46d50",
    [HAIR]   = "743F39",
    [SKIN]   = "ebe2c4",
    [CAP]    = "ac937d",
	[EMBLEM] = "ff6993"
}

local PALETTE_PICK_COO = {

    [PANTS]  = "FFFFFF",
    [SHIRT]  = "f09088",
    [GLOVES] = "DB9C70",
    [SHOES]  = "d11daa",
    [HAIR]   = "2b1927",
    [SKIN]   = "ffedfb",
    [CAP]    = "ffb8ef",
	[EMBLEM] = "ff6993"
}

local PALETTE_KIRBY_CTH = {

    [PANTS]  = "fc96be",
    [SHIRT]  = "fc96be",
    [GLOVES] = "DB9C70",
    [SHOES]  = "e5200f",
    [HAIR]   = "fc96be",
    [SKIN]   = "fc96be",
    [CAP]    = "fc96be",
	[EMBLEM] = "e5200f"
}

local PALETTE_COO_DL2 = {

    [PANTS]  = "ffffff",
    [SHIRT]  = "f8c088",
    [GLOVES] = "DB9C70",
    [SHOES]  = "ffe500",
    [HAIR]   = "000000",
    [SKIN]   = "ffffff",
    [CAP]    = "a9b1c1",
	[EMBLEM] = "e5200f"
}

local ANIMTABLE_RICK_TH = {
    [_G.charSelect.CS_ANIM_MENU] = "rick_th_menu_anim",
    [CHAR_ANIM_IDLE_HEAD_CENTER] = "rick_th_idle",
    [CHAR_ANIM_IDLE_HEAD_LEFT] = "rick_th_idle",
    [CHAR_ANIM_IDLE_HEAD_RIGHT] = "rick_th_idle",
}

local VOICETABLE_RICK_TH = {
nil
}

if _G.charSelectExists then
    CT_RICK_TH = _G.charSelect.character_add("Rick, Kine & Coo", {"Kirby's Dream Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_RICK_TH, CT_MARIO, RICK_TH_ICON, 1)
end

local function on_character_select_load()

    _G.charSelect.character_add_animations(E_MODEL_RICK_TH, ANIMTABLE_RICK_TH)
    _G.charSelect.character_add_voice(E_MODEL_RICK_TH, VOICETABLE_RICK_TH)
    _G.charSelect.character_add_voice(E_MODEL_RICK_TH_ROCK, VOICETABLE_RICK_TH)
    _G.charSelect.character_add_voice(E_MODEL_COO_TO, VOICETABLE_RICK_TH)
    _G.charSelect.character_add_voice(E_MODEL_KINE_TF, VOICETABLE_RICK_TH)
    _G.charSelect.character_add_graffiti(CT_RICK_TH, TEX_RICK_TH_GRAFFITI)

    -- PALETTES

    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH, PALETTE_RICK_TH, "Rick, Kine & Coo")
    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH, PALETTE_RICK_AIR_RIDERS, "Air Rider")
    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH, PALETTE_PICK_TH, "Significant Other")
    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH, PALETTE_KIRBY_RTH, "Mouthful")
    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH, PALETTE_RICK_DL2, "Dream")

    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH_ROCK, PALETTE_RICK_TH, "Rick, Kine & Coo")
    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH_ROCK, PALETTE_RICK_AIR_RIDERS, "Air Rider")
    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH_ROCK, PALETTE_PICK_TH, "Significant Other")
    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH_ROCK, PALETTE_KIRBY_RTH, "Mouthful")
    _G.charSelect.character_add_palette_preset(E_MODEL_RICK_TH_ROCK, PALETTE_RICK_DL2, "Dream")

    _G.charSelect.character_add_palette_preset(E_MODEL_COO_TO, PALETTE_COO_TO, "Rick, Kine & Coo")
    _G.charSelect.character_add_palette_preset(E_MODEL_COO_TO, PALETTE_COO_AIR_RIDERS, "Air Rider")
    _G.charSelect.character_add_palette_preset(E_MODEL_COO_TO, PALETTE_PICK_COO, "Significant Other")
    _G.charSelect.character_add_palette_preset(E_MODEL_COO_TO, PALETTE_KIRBY_CTH, "Mouthful")
    _G.charSelect.character_add_palette_preset(E_MODEL_COO_TO, PALETTE_COO_DL2, "Dream")


    CSloaded = true
end

function is_rick_th()
    return CT_RICK_TH == charSelect.character_get_current_number()
end


local function on_character_sound(m, sound)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_RICK_TH then return _G.charSelect.voice.sound(m, sound) end
end

local function on_character_snore(m)
    if not CSloaded then return end
    if _G.charSelect.character_get_voice(m) == VOICETABLE_RICK_TH then return _G.charSelect.voice.snore(m) end
end

hook_event(HOOK_ON_MODS_LOADED, on_character_select_load)
hook_event(HOOK_CHARACTER_SOUND, on_character_sound)
hook_event(HOOK_MARIO_UPDATE, on_character_snore)



