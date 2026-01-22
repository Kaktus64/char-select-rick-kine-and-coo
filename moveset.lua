local E_MODEL_RICK_TH = smlua_model_util_get_id("rick_th_geo")

local E_MODEL_RICK_TH_ROCK = smlua_model_util_get_id("rick_th_rock_geo")

local E_MODEL_COO_TO = smlua_model_util_get_id("coo_to_geo")

local E_MODEL_COO_TO_PARA = smlua_model_util_get_id("coo_topara_geo")

local E_MODEL_KINE_TF = smlua_model_util_get_id("kine_tf_geo")

local E_MODEL_KINE_TF_ROCK = smlua_model_util_get_id("kine_tf_rock_geo")

function is_rick_th()
    return CT_RICK_TH == charSelect.character_get_current_number()
end

---@diagnostic disable: undefined-global
if not _G.charSelectExists then return end

local gStateExtras = {}
for i = 0, MAX_PLAYERS - 1 do
    gStateExtras[i] = {}
    local m = gMarioStates[i]
    local e = gStateExtras[i]
    e.rotAngle = 0
    e.charArg = 0
    e.cooFlyCountCount = 0
    e.hasCooSpun = false
end

local function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

local cooFlyActions = {
    [ACT_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_FREEFALL] = true,
    [ACT_LONG_JUMP] = true,
    [ACT_SIDE_FLIP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_WALL_KICK_AIR] = true,
    [ACT_TOP_OF_POLE_JUMP] = true,
    [ACT_JUMP_KICK] = true,
}

local returnToRickActions = {
    [ACT_IDLE] = true,
    [ACT_WALKING] = true,
    [ACT_FREEFALL_LAND] = true,
    [ACT_WATER_ACTION_END] = true,
    [ACT_BACKWARD_AIR_KB] = true,
    [ACT_METAL_WATER_FALLING] = true,
    [ACT_GRAB_POLE_SLOW] = true,
    [ACT_GRAB_POLE_FAST] = true,
    [ACT_LEDGE_GRAB] = true,
    [ACT_FORWARD_ROLLOUT] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_JUMP] = true,
    [ACT_STEEP_JUMP] = true,
    [ACT_JUMP_LAND] = true,
    [ACT_DIVE_SLIDE] = true,
    [ACT_BUTT_SLIDE] = true,
    [ACT_BUTT_SLIDE_STOP] = true,
    [ACT_TRIPLE_JUMP_LAND] = true,
    [ACT_STAR_DANCE_EXIT] = true,
    [ACT_STAR_DANCE_NO_EXIT] = true,
}
local returnToKineActions = {
    [ACT_SWIMMING_END] = true,
    [ACT_WATER_ACTION_END] = true,
    [ACT_WATER_IDLE] = true,
    [ACT_WATER_PLUNGE] = true,
    [ACT_STAR_DANCE_WATER] = true,
}

local rickSlipperySurfaces = {
    [SURFACE_CLASS_SLIPPERY] = true,
    [SURFACE_SLIPPERY] = true,
    [SURFACE_ICE] = true,
    [SURFACE_VERY_SLIPPERY] = true,
    [SURFACE_HARD_SLIPPERY] = true,
    [SURFACE_NOISE_SLIPPERY] = true,
    [SURFACE_NO_CAM_COL_SLIPPERY] = true,
    [SURFACE_HARD_VERY_SLIPPERY] = true,
    [SURFACE_CLASS_VERY_SLIPPERY] = true,
    [SURFACE_NO_CAM_COL_VERY_SLIPPERY] = true,
    [SURFACE_NOISE_VERY_SLIPPERY_73] = true,
    [SURFACE_NOISE_VERY_SLIPPERY_74] = true,
}

ACT_RICK_ROLL_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_RICK_ROLL = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_ATTACKING | ACT_FLAG_MOVING)
ACT_COO_FLY = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING)
ACT_COO_SPIN = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)
ACT_KINE_SWIM_IDLE = allocate_mario_action(ACT_GROUP_SUBMERGED | ACT_FLAG_SWIMMING | ACT_FLAG_MOVING)
ACT_KINE_SWIM_MOVE = allocate_mario_action(ACT_GROUP_SUBMERGED | ACT_FLAG_SWIMMING | ACT_FLAG_MOVING)

function act_rick_roll(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = perform_ground_step(m)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x250, 0x250)
    smlua_anim_util_set_animation(m.marioObj, "rick_th_roll_quick")
    apply_slope_accel(m)
    m.forwardVel = m.forwardVel - 0.1
    if stepResult == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_RICK_ROLL_AIR, 0)
    end
    if stepResult == GROUND_STEP_HIT_WALL then
        set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
        set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
        play_sound(SOUND_ACTION_HIT, m.marioObj.header.gfx.cameraToObject)
    end
    --if m.actionTimer > 11 then
        --set_mario_action(m, ACT_WALKING, 0)
    --end
    if m.forwardVel > 110
    then m.forwardVel = 110
    end
    if m.forwardVel < 15 then
        set_mario_action(m, ACT_DIVE_SLIDE, 0)
    end
    if m.input & INPUT_A_PRESSED ~= 0 then
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        set_anim_to_frame(m, 0)
    end
    if m.input & INPUT_B_PRESSED ~= 0 and m.actionTimer > 1 then
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        set_anim_to_frame(m, 0)
    end
    if m.actionTimer % 5 == 0 then
        play_sound(SOUND_ENV_METAL_BOX_PUSH, m.marioObj.header.gfx.cameraToObject)
    end
    apply_slope_accel(m)
    apply_slope_decel(m, 0.08)
    m.actionTimer = m.actionTimer + 1
end
hook_mario_action(ACT_RICK_ROLL, act_rick_roll)

function act_rick_roll_air(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_RICK_ROLL, CHAR_ANIM_RUNNING_UNUSED, AIR_STEP_NONE)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x150, 0x150)
    m.forwardVel = m.forwardVel + 0.5
    m.peakHeight = m.pos.y
    smlua_anim_util_set_animation(m.marioObj, "rick_th_roll_quick")
    if m.actionTimer < 1 then
        m.vel.y = 20
        m.forwardVel = 50
    end
    m.actionTimer = m.actionTimer + 1
end
hook_mario_action(ACT_RICK_ROLL_AIR, act_rick_roll_air)

function act_coo_fly(m)
 local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, CHAR_ANIM_RUNNING_UNUSED, AIR_STEP_NONE)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x300, 0x300)
    smlua_anim_util_set_animation(m.marioObj, "coo_fly")
    if m.playerIndex == 0 then 
    charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
        "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
        "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_COO_TO, CT_MARIO, RICK_TH_ICON, 1)
    end
    m.peakHeight = m.pos.y -- no fall sound
    if m.vel.y < -30 then
        m.vel.y = -30
    end
    m.vel.y = m.vel.y + 3
    if m.forwardVel > 30 then
        m.forwardVel = m.forwardVel - 2
    end
        if m.controller.buttonPressed & A_BUTTON ~= 0 and e.cooFlyCount ~= 3 then
            set_anim_to_frame(m, 0)
            e.cooFlyCount = e.cooFlyCount + 1
            play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
            m.vel.y = 14
            set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
            set_mario_action(m, ACT_COO_FLY, 0)
        end
    if stepResult == AIR_STEP_LANDED then
        return set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end
    if stepResult == AIR_STEP_HIT_WALL then
        mario_bonk_reflection(m, 0)
        return set_mario_action(m, ACT_COO_FLY, 0)
    end
    if m.input & INPUT_Z_PRESSED ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0)
    end
    if m.input & INPUT_B_PRESSED ~= 0 and e.hasCooSpun == false then
        return set_mario_action(m, ACT_COO_SPIN, 0)
    end
end
hook_mario_action(ACT_COO_FLY, act_coo_fly)
function act_coo_spin(m)
 local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, CHAR_ANIM_RUNNING_UNUSED, AIR_STEP_NONE)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x300, 0x300)
    smlua_anim_util_set_animation(m.marioObj, "coo_fly_spin")
    if m.playerIndex == 0 then 
    charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
        "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
        "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_COO_TO_PARA, CT_MARIO, RICK_TH_ICON, 1)
    end
    m.peakHeight = m.pos.y -- no fall sound
    e.hasCooSpun = true
    m.vel.y = m.vel.y + 5
    if m.vel.y > 10 then
        m.vel.y = 10
    end
    if m.actionTimer == 0 then
        m.marioObj.header.gfx.animInfo.animFrame = 0
    end
    if m.forwardVel > 30 then
        m.forwardVel = m.forwardVel - 2
    end
    if m.actionTimer > 30 then
        set_mario_action(m, ACT_COO_FLY, 0)
    end
    if stepResult == AIR_STEP_LANDED then
        return set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end
    if stepResult == AIR_STEP_HIT_WALL then
        mario_bonk_reflection(m, 0)
        return set_mario_action(m, ACT_COO_FLY, 0)
    end
    if m.input & INPUT_Z_PRESSED ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0)
    end
    m.actionTimer = m.actionTimer + 1
end
hook_mario_action(ACT_COO_SPIN, act_coo_spin)

local function act_kine_swim_idle(m)
 local e = gStateExtras[m.playerIndex]
    perform_water_step(m)
    m.vel.x = 0
    m.vel.z = 0
    if (m.input & INPUT_A_DOWN) ~= 0 then
        m.vel.y = 10
    end
    if (m.input & INPUT_A_DOWN) == 0 then
        m.vel.y = m.vel.y - 2
        if m.vel.y < 0 then m.vel.y = 0 end
    end
    if (m.input & INPUT_Z_DOWN) ~= 0 then
        m.vel.y = -10
    end
    if (m.input & INPUT_Z_DOWN) == 0  then
        m.vel.y = m.vel.y + 2
        if m.vel.y > 0 then m.vel.y = 0 end
    end
    if m.input & INPUT_NONZERO_ANALOG ~= 0 then
        set_mario_action(m, ACT_KINE_SWIM_MOVE, 0)
    end
    apply_water_current(m, m.vel)
end
hook_mario_action(ACT_KINE_SWIM_IDLE, act_kine_swim_idle)

local function act_kine_swim_move(m)
 local e = gStateExtras[m.playerIndex]
    perform_water_step(m)

    if m.input & INPUT_NONZERO_ANALOG ~= 0 then
    m.forwardVel = m.forwardVel + 2
    end
    if (m.input & INPUT_A_DOWN) ~= 0 then
        m.vel.y = 10
    end
    if (m.input & INPUT_A_DOWN) == 0 then
        m.vel.y = m.vel.y - 2
        if m.vel.y < 0 then m.vel.y = 0 end
    end
    if (m.input & INPUT_Z_DOWN) ~= 0 then
        m.vel.y = -10
    end
    if (m.input & INPUT_Z_DOWN) == 0 then
        m.vel.y = m.vel.y - 2
        if m.vel.y > 0 then m.vel.y = 0 end
    end
    m.vel.x = m.forwardVel * sins(m.faceAngle.y) * coss(m.faceAngle.x)
    m.vel.z = m.forwardVel * coss(m.faceAngle.y) * coss(m.faceAngle.x)
    m.faceAngle.x = 0
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x400, 0x400)
    if m.input & INPUT_NONZERO_ANALOG == 0 then
        m.forwardVel = m.forwardVel - 3
    end
    if m.forwardVel < 5 then
        set_mario_action(m, ACT_KINE_SWIM_IDLE, 0)
    end
    if m.forwardVel > 30 then
        m.forwardVel = 30
    end
    apply_water_current(m, m.vel)
    m.actionTimer = m.actionTimer + 1
end
hook_mario_action(ACT_KINE_SWIM_MOVE, act_kine_swim_move)

function rick_th_update(m)
    local e = gStateExtras[m.playerIndex]
    if m.action == ACT_WALKING then
        m.marioBodyState.torsoAngle.x = 0
        m.marioBodyState.torsoAngle.z = 0
    end
    if m.action == ACT_GROUND_POUND and (m.input & INPUT_B_PRESSED) ~= 0 and m.playerIndex == 0 then
        set_mario_action(m, ACT_DIVE, 0)
        m.faceAngle.y = m.intendedYaw
                    set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        m.vel.y = 30
        m.forwardVel = 39
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
        "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
        "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_KINE_TF, CT_MARIO, RICK_TH_ICON, 1)
    end
    if m.action == ACT_GROUND_POUND and m.playerIndex == 0 then 
        smlua_anim_util_set_animation(m.marioObj, "kine_pound")
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
        "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
        "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_KINE_TF_ROCK, CT_MARIO, RICK_TH_ICON, 1)
    end
    if cooFlyActions[m.action] and m.vel.y < 0 and m.input & INPUT_A_PRESSED ~= 0 and e.cooyFlyCount ~= 5 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        set_mario_action(m, ACT_COO_FLY, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        m.vel.y = 15
    end
    if cooFlyActions[m.action] and m.vel.y < 0 and m.input & INPUT_A_PRESSED ~= 0 and e.cooFlyCount == 5 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        set_mario_action(m, ACT_COO_FLY, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        m.vel.y = 0
    end

    if m.pos.y == m.floorHeight then
        e.cooFlyCount = 0
        e.hasCooSpun = false
    end
    -- no ice slipping because hampter
        if is_rick_th() and rickSlipperySurfaces[m.floor.type] == true then
        m.floor.type = SURFACE_CLASS_DEFAULT
    end
    if m.action == ACT_COO_FLY and m.playerIndex == 0 then
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_COO_TO, CT_MARIO, RICK_TH_ICON, 1)
    end
    if m.action == ACT_FLYING and m.playerIndex == 0 then
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_COO_TO, CT_MARIO, RICK_TH_ICON, 1)
    end
    if m.action == ACT_SHOT_FROM_CANNON and m.playerIndex == 0 then
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_COO_TO, CT_MARIO, RICK_TH_ICON, 1)
    end
    --rick rock transformation
    if m.action == ACT_RICK_ROLL and m.playerIndex == 0 then
        m.marioObj.header.gfx.scale.y = 1.1
        m.marioObj.header.gfx.scale.x = 1.1
        m.marioObj.header.gfx.scale.z = 1.1
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_RICK_TH_ROCK, CT_MARIO, RICK_TH_ICON, 1)
    end
    if m.action == ACT_RICK_ROLL_AIR and m.playerIndex == 0 then
        m.marioObj.header.gfx.scale.y = 1.1
        m.marioObj.header.gfx.scale.x = 1.1
        m.marioObj.header.gfx.scale.z = 1.1
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_RICK_TH_ROCK, CT_MARIO, RICK_TH_ICON, 1)
    end
    if m.prevAction == ACT_RICK_ROLL and m.action ~= ACT_RICK_ROLL and m.action ~= ACT_RICK_ROLL_AIR and m.playerIndex == 0 then
                charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_RICK_TH, CT_MARIO, RICK_TH_ICON, 1)
    end
    if m.prevAction == ACT_RICK_ROLL_AIR and m.action ~= ACT_RICK_ROLL_AIR and m.action ~= ACT_RICK_ROLL and m.playerIndex == 0 then
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_RICK_TH, CT_MARIO, RICK_TH_ICON, 1)
    end
    if returnToRickActions[m.action] == true and m.playerIndex == 0 then
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_RICK_TH, CT_MARIO, RICK_TH_ICON, 1)
    end
    if returnToKineActions[m.action] == true and m.playerIndex == 0 then
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_KINE_TF, CT_MARIO, RICK_TH_ICON, 1)
    end
    if _G.charSelect.is_menu_open() == true and m.pos.y == m.floorHeight and m.action ~= ACT_RICK_ROLL and m.playerIndex == 0 then
        charSelect.character_edit(CT_RICK_TH, "Rick, Kine & Coo", {"Kirby's Animal Friends! Rick is a hamster-like creature who's quick on his feet,",
    "and won't slip on ice. Kine is a creature who resembles a fish, and swims gracefully through water like... a fish. Coo is another creature who looks like an owl,",
    "and has great flying capabilities. Based on what you're doing, you'll switch between Rick, Kine & Coo automatically."}, "Kaktus64", {r = 255, g = 196, b = 0}, E_MODEL_RICK_TH, CT_MARIO, RICK_TH_ICON, 1)
    end
    --if m.action == ACT_WATER_IDLE then
        --set_mario_action(m, ACT_KINE_SWIM_IDLE, 0)
    --end

end

function rick_th_set_action(m)
    local e = gStateExtras[m.playerIndex]
    if m.action == ACT_RICK_ROLL and m.prevAction == ACT_RICK_ROLL_AIR then
        play_sound(SOUND_ACTION_TERRAIN_HEAVY_LANDING, m.marioObj.header.gfx.cameraToObject)
            set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
    end
    if m.action == ACT_SLIDE_KICK then
        set_mario_action(m, ACT_RICK_ROLL, 0)
    end
end

function rick_th_before_set_action(m, inc)
    local e = gStateExtras[m.playerIndex]
    local np = gNetworkPlayers[m.playerIndex]
    if inc == ACT_SLIDE_KICK then
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        m.forwardVel = 50
        return ACT_RICK_ROLL
    end
end

_G.charSelect.character_hook_moveset(CT_RICK_TH, HOOK_MARIO_UPDATE, rick_th_update)
_G.charSelect.character_hook_moveset(CT_RICK_TH, HOOK_ON_SET_MARIO_ACTION, rick_th_set_action)
_G.charSelect.character_hook_moveset(CT_RICK_TH, HOOK_BEFORE_SET_MARIO_ACTION, rick_th_before_set_action)
