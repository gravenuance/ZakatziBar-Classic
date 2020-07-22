local is_debugging

local spells_list
local player_spells_list
-- Tracks the specs of other players based on spec spells
local special_spells_list
local specs_by_guid_list
-- Track all or target/focus
local all

-- Number of buttons to spawn per bar
local total_icons_per_bar
-- How many active buttons?
local length_of_hostile_bar
local length_of_party_bar
local length_of_player_bar
-- Button bars
local hostile_bar
local party_bar
local player_bar

-- Delay for more accurate tracking
local count_delay_from_start

-- Size of side of square
local square_size

-- How often on_update runs
local update_interval
local total_time_elapsed

--Player identifier
local player_guid

--Bar locations
local player_bar_x
local player_bar_y
local party_bar_x
local party_bar_y
local hostile_bar_x
local hostile_bar_y

local is_disabled

local player_class


local function zb_initialize_variables()
    player_guid = UnitGUID("player")
    _, player_class = UnitClass("player")

    all = true
    
    player_bar_x = -225
    player_bar_y = -225
    party_bar_x = -225
    party_bar_y = -275
    hostile_bar_x = -225
    hostile_bar_y = -325
    square_size = 45

    is_disabled = false
    is_debugging = false
    
    count_delay_from_start = 0
    update_interval = 0.1
    total_time_elapsed = 0
    
    total_icons_per_bar = 15
    length_of_hostile_bar = 1
    length_of_party_bar = 1
    length_of_player_bar = 1

    spells_list = {}
    -- Spells
    -- Warrior
    spells_list[1719] = {duration = 1800, is_success = true} -- Recklessness
    spells_list[12809] = {duration = 45, is_success = true } -- Concussion Blow
    spells_list[20230] = {duration = 1800, is_success = true} -- Retaliation
    spells_list[72] = {duration = 12, is_success = true} -- Shield Bash
    spells_list[871] = {duration = 1800, is_success = true} -- Shield Wall
    spells_list[6552] = {duration = 10, is_success = true} -- Pummel
    spells_list[18499] = {duration=30, is_success=true} -- Berserker Rage
    spells_list[12328] = {duration=180, is_success=true} -- Death Wish
    -- Paladin
    spells_list[20066] = {duration=60, is_success=true} -- Repentance
    spells_list[498] = {duration=300, is_success=true} -- Divine Protection
    spells_list[853] = {duration=45, is_success=true} -- Hammer of Justice
    spells_list[1022] = {duration=180, is_success=true} -- Blessing of Protection
    spells_list[1044] = {duration=20, is_success=true} -- Blessing of Freedom
    -- Rogue
    spells_list[11286] = {duration=10, is_success=true} -- Gouge
    spells_list[1769] = {duration=10, is_success=true} -- Kick
    spells_list[408] = {duration=20, is_success=true} -- Kidney Shot
    spells_list[2983] = {duration=180, is_success=true} -- Sprint
    spells_list[13877] = {duration=120, is_success=true} -- Blade Flurry
    spells_list[14278] = {duration=20, is_success=true} -- Ghostly Strike
    spells_list[2094] = {duration=180, is_success=true} -- Blind
    spells_list[14183] = {duration=120, is_success=true} -- Premeditation
    spells_list[5277] = {duration=180, is_success=true} -- Evasion
    spells_list[13750] = {duration=300, is_success=true} -- Adrenaline Rush
    spells_list[14185] = {duration = 600, related = {13750, 5277, 14183, 2094, 14278, 11286, 1769, 408, 2983, 13877}, is_success = true} -- Preparation
    -- Priest
    spells_list[10060] = {duration=180, is_success=true} -- Power Infusion
    spells_list[15487] = {duration=45, is_success=true} -- Silence
    spells_list[8122] = {duration=26, is_success=true} -- Psychic Scream
    --Mage
    spells_list[543] = {duration=30, is_success=true} -- Fire Ward
    spells_list[11958] = {duration=300, is_success=true} -- Ice Block
    spells_list[122] = {duration=21, is_success=true} -- Frost Nova
    spells_list[6143] = {duration=30, is_success=true} -- Frost Ward
    spells_list[2139] = {duration=30, is_success=true} -- Counterspell
    spells_list[11426] = {duration=30, is_success=true} -- Ice Barrier
    spells_list[12042] = {duration=180, is_success=true} -- Arcane Power
    spells_list[12051] = {duration=420, is_success=true} -- Evocation
    spells_list[12472] = {duration = 600, related = {11958, 122, 6143, 11426}, is_success = true} -- COLD SNAP
    -- Warlock
    spells_list[6229] = {duration=30, is_success=true} -- Shadow Ward
    spells_list[6789] = {duration=102, is_success=true} -- Death Coil
    spells_list[5484] = {duration=40, is_success=true} -- Howl of Terror
    spells_list[19244] = {duration=30, is_success=true} -- Spell Lock
    -- Shaman
    spells_list[8042] = {duration=5, is_success=true} -- Earth Shock
    spells_list[8177] = {duration=13, is_success=true} -- Grounding Totem
    spells_list[16188] = {duration=180, is_success=true} -- Nature's Swiftness
    -- Druid
    spells_list[5211] = {duration=60, is_success=true} -- Bash
    spells_list[1850] = {duration=300, is_success=true} -- Dash
    spells_list[16979] = {duration=15, is_success=true} -- Feral Charge
    spells_list[29166] = {duration=360, is_success=true} -- Innervate
    spells_list[16689] = {duration=60, is_success=true} -- Nature's Grasp
    spells_list[22812] = {duration=60, is_success=true} -- Barkskin
    -- Hunter
    spells_list[19574] = {duration=120, is_success=true} -- Bestial Wrath
    spells_list[19503] = {duration=30, is_success=true} -- Scatter Shot
    spells_list[25999] = {duration=25, is_success=true} -- Boar Charge
    spells_list[3045] = {duration=180, is_success=true} -- Rapid Fire
    spells_list[19263] = {duration=300, is_success=true} -- Deterrence
    spells_list[19386] = {duration=120, is_success=true} -- Wyvern Sting
    spells_list[1499] = {duration=15, is_success=true} -- Freezing Trap
    -- End

    player_spells_list = {}
    --Player Spells
    --End

    specs_by_guid_list = {}
    special_spells_list = {}
end

local function zb_remove_icon(bar, length, id, is_aura, src_guid, dst_guid)
    if is_aura then
        local index = 1
        local found = false
        while index < length do
            if bar[index].id == id and src_guid == bar[index].src_guid then
                if dst_guid and dst_guid == bar[index].dst_guid or bar[index].dst_guid == nil then
                    id = index
                    found = true
                    break
                end
            end
            index = index + 1
        end
        if not found then
            return length
        end  
    end  
    length = length - 1
    local index = id
    while index < length do
        bar[index].id = bar[index+1].id
        bar[index].src_guid = bar[index+1].src_guid
        bar[index].dst_guid = bar[index+1].dst_guid
        bar[index].duration = bar[index+1].duration
        bar[index].start = bar[index+1].start
        bar[index].cooldown = bar[index+1].cooldown
        bar[index].texture:SetTexture(bar[index+1].texture:GetTexture())
        bar[index].text:SetText(bar[index+1].text:GetText())
        bar[index].cd:SetCooldown(bar[index].start,bar[index].duration)
        index = index + 1
    end
    bar[length]:Hide()
    bar[length].flasher:Stop()
    bar[length].is_playing = false
    bar[length].text:SetText("") 
    return length
end


local function zb_update_text(bar, index)
    if (bar[index].cooldown > 60) then
        bar[index].text:SetTextColor(1,1,0,1)
        bar[index].text:SetFont(STANDARD_TEXT_FONT,20,"OUTLINE")
        bar[index].text:SetText(string.format("%.0fm", floor(bar[index].cooldown/60)))
    elseif (bar[index].cooldown >= 10) then
        bar[index].text:SetTextColor(1,1,0,1)
        bar[index].text:SetFont(STANDARD_TEXT_FONT,20,"OUTLINE")
        bar[index].text:SetText(string.format(" %.0f", floor(bar[index].cooldown)))
    else
        bar[index].text:SetTextColor(1,0,0,1)
        bar[index].text:SetFont(STANDARD_TEXT_FONT,24,"OUTLINE")
        bar[index].text:SetText(string.format("  %.0f", floor(bar[index].cooldown)))
    end
end

local function zb_get_duration(list, id)
    if list[id].has_other_duration then
        if specs_by_guid_list[src_guid] then
            if (list[id].duration[specs_by_guid_list[src_guid]]) then
                duration = list[id].duration[specs_by_guid_list[src_guid]]
            end
        else
            return list[id].duration[1]
        end
    else
        return list[id].duration
    end
end

local function zb_update_cooldowns(bar, length, list)
    if length > 1 then
        local index = 1
        local get_time = GetTime()
        while index < length do
            bar[index].cooldown = bar[index].start + bar[index].duration - get_time
            if bar[index].cooldown <= 0 then
                if list[bar[index].id].has_charges and bar[index].has_charges < list[bar[index].id].has_charges then
                    bar[index].has_charges = bar[index].has_charges + 1
                    bar[index].start = get_time
                    bar[index].duration = zb_get_duration(list, bar[index].id)
                    bar[index].cooldown = bar[index].duration
                    bar[index].cd:SetCooldown(bar[index].start,bar[index].duration)
                    zb_update_text(bar, index)
                else
                    length = zb_remove_icon(bar, length, index, false)
                    index = index - 1
                end
            else 
                zb_update_text(bar, index)
                if get_time - bar[index].start >= 1.9 and bar[index].is_playing then
                    bar[index].is_playing = false
                    bar[index].flasher:Stop()
                end
            end
            index = index + 1
        end
    end
    return length
end

local function zb_on_update(self, elapsed)
    total_time_elapsed = total_time_elapsed + elapsed;
    if total_time_elapsed >= update_interval then
        if length_of_player_bar == 1 and length_of_hostile_bar == 1 and length_of_party_bar == 1 then
            zb_frame:SetScript("OnUpdate",nil)
            return
        end
        length_of_player_bar = zb_update_cooldowns(player_bar, length_of_player_bar, player_spells_list)
        length_of_hostile_bar = zb_update_cooldowns(hostile_bar, length_of_hostile_bar, spells_list)
        length_of_party_bar = zb_update_cooldowns(party_bar, length_of_party_bar, spells_list)
        total_time_elapsed = 0
    end
end

local function zb_add_icon(bar, length, id, list, src_guid, dst_guid)
    local get_time = GetTime()
    local index = 1
    while index < length do
        if bar[index].id == id and src_guid == bar[index].src_guid then
            if dst_guid and dst_guid == bar[index].dst_guid or bar[index].dst_guid == nil then
                if list[id].has_charges and bar[index].has_charges > 0 then
                    bar[index].has_charges = bar[index].has_charges - 1
                else
                    bar[index].start = get_time*2-count_delay_from_start
                    bar[index].duration = zb_get_duration(list, id)
                    bar[index].cooldown = bar[index].start + bar[index].duration - get_time
                    bar[index].cd:SetCooldown(bar[index].start,bar[index].duration)
                    zb_update_text(bar, index)
                end
                bar[index].flasher:Play()
                bar[index].is_playing = true
                return length
            end
        end
        index = index + 1
    end
    if length < total_icons_per_bar then
        if dst_guid then
            bar[length].dst_guid = dst_guid
        else
            bar[length].dst_guid = nil
        end
        if list[id].has_charges then
            bar[length].has_charges = list[id].has_charges - 1
        end
        bar[length].src_guid = src_guid
        bar[length].duration = zb_get_duration(list, id)

        bar[length].start = get_time*2-count_delay_from_start
        bar[length].cooldown = bar[length].start + bar[length].duration - get_time
        

        bar[length].id = id

        local _,_,icon = GetSpellInfo(id)
        bar[length].texture:SetTexture(icon)
        
        bar[length].cd:SetCooldown(bar[length].start,bar[length].duration)

        bar[length]:Show()
        bar[length].flasher:Play()
        bar[length].is_playing = true
        zb_update_text(bar, length)
        
        
        zb_frame:SetScript("OnUpdate", zb_on_update)
        return length + 1
    end
    return length
end

local function zb_event_type(combat_event, bar, length, id, line, src_guid, dst_guid)
    if line[id].is_aura then
        if combat_event == "SPELL_AURA_APPLIED" then
            return zb_add_icon(bar, length, id, line, src_guid, dst_guid)
        elseif combat_event == "SPELL_AURA_REMOVED" then
            return zb_remove_icon(bar, length, id, true, src_guid, dst_guid)
        elseif combat_event == "SPELL_AURA_REFRESH" then
            return zb_add_icon(bar, length, id, line, src_guid, dst_guid)
        end
    else
        if combat_event == "SPELL_DAMAGE" and line[id].isDamage then
            return zb_add_icon(bar, length, id, line, src_guid, dst_guid)
        elseif combat_event == "SPELL_CAST_SUCCESS" and line[id].is_success then
            return zb_add_icon(bar, length, id, line, src_guid, dst_guid)
        end
    end
    return length
end

local function zb_is_in_party(guid)
    local index = 1
    while index < 5 do
        if (UnitGUID("party" .. index) == guid) then
            return true
        end
        index = index + 1
    end
    return false
end

local function zb_combat_log(event, ...)
    local timestamp, combat_event, _, src_guid, src_name, src_flags, src_raid_flags, dst_guid, dst_name, dst_flags, dst_raid_flags = ...
    local spell_name = select(13, ...)
    local spell_id = select(7, GetSpellInfo(spell_name))
    count_delay_from_start = GetTime()
    if is_debugging and (src_guid == (player_guid or UnitGUID("target"))) then
        print(spell_id)
        print(spell_name)
        print(combat_event)
    end
    if is_disabled or (not all and src_guid == (player_guid or UnitGUID("target"))) then
        return
    end
    if special_spells_list[spell_id] then
        specs_by_guid_list[src_guid] = special_spells_list[spell_id]
    end
    if spell_id == 14185 or spell_id == 11958 then
        if bit.band(src_flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
            for related_id in pairs(spells_list[spell_id].related) do
                length_of_hostile_bar = zb_remove_icon(hostile_bar, length_of_hostile_bar, related_id, true, src_guid)
            end
        elseif zb_is_in_party(src_guid) then
            for related_id in pairs(spells_list[spell_id].related) do
                length_of_party_bar = zb_remove_icon(party_bar, length_of_party_bar, related_id, true, src_guid)
            end
        end
    end
    if bit.band(src_flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then
        if player_spells_list[spell_id] then 
            if zb_is_in_party(dst_guid) then
                length_of_party_bar = zb_event_type(combat_event, party_bar, length_of_party_bar, spell_id, player_spells_list, src_guid, dst_guid)
            else
                length_of_player_bar = zb_event_type(combat_event, player_bar, length_of_player_bar, spell_id, player_spells_list, src_guid)
            end
        elseif combat_event == "SWING_MISSED" then
            for id in pairs(player_spells_list) do
                if player_spells_list[id].is_swing and (player_spells_list[id].class == nil or player_spells_list[id].class == player_class) then
                    for swing_type in pairs(player_spells[id].swing_types) do
                        if swing_type == spell_id then
                            length_of_player_bar = zb_add_icon(bar, length, id, line, src_guid)
                            return
                        end
                    end 
                end
            end
        end
    elseif spells_list[spell_id] then  
        if bit.band(src_flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
            length_of_hostile_bar = zb_event_type(combat_event, hostile_bar, length_of_hostile_bar, spell_id, spells_list, src_guid)
        elseif zb_is_in_party(src_guid) then
            length_of_party_bar = zb_event_type(combat_event, party_bar, length_of_party_bar, spell_id, spells_list, src_guid)
        end
    end
end

local function zb_initialize_bar(bar, bar_x, bar_y, name)
    bar = CreateFrame("Frame",nil,UIParent)
    bar:SetWidth(square_size*4)
    bar:SetHeight(square_size)
    bar:SetClampedToScreen(true)
    bar:SetPoint("CENTER", UIParent, "CENTER", bar_x, bar_y)
    bar.name = name
    local location
    local icon
    local cooldown
    local texture
    local text
    local index = 1
    while index < total_icons_per_bar do
        
        location = square_size * index + 5 * index

        icon = CreateFrame("Frame",nil,bar)
        icon:SetWidth(square_size)
        icon:SetHeight(square_size)
        icon:SetPoint("CENTER",bar,"CENTER",location,0)
        icon:SetFrameStrata("LOW")
        
        texture = icon:CreateTexture(nil,"BACKGROUND")
        texture:SetAllPoints()
        texture:SetTexCoord(0.07,0.9,0.07,0.90) 


        cooldown = CreateFrame("Cooldown",nil, icon, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetFrameStrata("MEDIUM")
        cooldown.noomnicc = true
        cooldown.noCooldownCount = true
        
        -- 
        local hidden_text = cooldown:GetRegions()
        hidden_text:SetAlpha(0)
    
        text = cooldown:CreateFontString(nil,"ARTWORK")
        text:SetFont(STANDARD_TEXT_FONT,20,"OUTLINE")
        text:SetTextColor(1,1,0,1)
        text:SetPoint("LEFT",icon,"LEFT",2,0)
        --

        icon.texture = texture
        icon.cd = cooldown
        icon.text = text

        icon.flasher = icon:CreateAnimationGroup()

        local fade_out = icon.flasher:CreateAnimation("Alpha")
        fade_out:SetDuration(0.5)
        fade_out:SetFromAlpha(1)
        fade_out:SetToAlpha(0.4)
        fade_out:SetOrder(1)

        local fade_in = icon.flasher:CreateAnimation("Alpha")
        fade_in:SetDuration(0.5)
        fade_in:SetToAlpha(1)
        fade_in:SetFromAlpha(0.4)
        fade_in:SetOrder(2)

        icon.flasher:SetLooping("REPEAT")
        icon.is_playing = false

        icon:Hide()
        bar[index] = icon 
        index = index + 1
    end   
    return bar
end

local function zb_clear_spec_list()
    for character in pairs (specs_by_guid_list) do
        specs_by_guid_list[character] = nil
    end
end


local function zb_reset_all(bar, length)
    while length > 1 do
        length = zb_remove_icon(bar, length, 1, false)
    end        
    return length
end

local function zb_entering_world()
    length_of_player_bar = zb_reset_all(player_bar, length_of_player_bar)
    length_of_hostile_bar = zb_reset_all(hostile_bar, length_of_hostile_bar)
    length_of_party_bar = zb_reset_all(party_bar, length_of_party_bar)
end

local function zb_remove_ex_party_member_icons()
    local index = 1
    while index < length_of_party_bar do
        if (party_bar[index]["src_guid"]) then
            if zb_is_in_party(party_bar[index].src_guid) then
                length_of_party_bar = zb_remove_icon(party_bar, length_of_party_bar, index, false)
            end
        elseif (party_bar[index]["dst_guid"]) then
            if zb_is_in_party(party_bar[index].dst_guid) then
                length_of_party_bar = zb_remove_icon(party_bar, length_of_party_bar, index, false)
            end
        end
        index = index + 1
    end
end

local function zb_commands(sub_string)
    if sub_string == "debug" then
        is_debugging = not is_debugging
        if is_debugging then
            print("Debugging on.")
        else 
            print("Debugging off.")
        end
    elseif sub_string == "clear" then
        zb_entering_world()
        zb_clear_spec_list()
    elseif sub_string == "disable" then
        is_disabled = not is_disabled
    elseif sub_string == "all" then
        all = not all
    else
        print("Available commands: Debug, clear, disable, all.")
    end
end

local function zb_on_load(self)
        print("ZB loaded.")
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
        zb_initialize_variables()
        player_bar = zb_initialize_bar(player_bar, player_bar_x, player_bar_y, "zb_player")
        party_bar = zb_initialize_bar(party_bar, party_bar_x, party_bar_y, "zb_party")
        hostile_bar = zb_initialize_bar(hostile_bar, hostile_bar_x, hostile_bar_y, "zb_hostile")
        SlashCmdList["ZAKATZIBAR"] = zb_commands
        SLASH_ZAKATZIBAR1 = "/zb"
end

local event_handler = {
    ["PLAYER_LOGIN"] = function(self) zb_on_load(self) end,
    ["PLAYER_ENTERING_WORLD"] = function(self) zb_entering_world(self) end,
    ["COMBAT_LOG_EVENT_UNFILTERED"] = function(self, event) zb_combat_log(event, CombatLogGetCurrentEventInfo()) end,
    ["GROUP_ROSTER_UPDATE"] = function(self) zb_remove_ex_party_member_icons() end,
}

local function zb_on_event(self,event)
	event_handler[event](self, event)
end

if not zb_frame then 
    CreateFrame("Frame","zb_frame",UIParent)
end
zb_frame:SetScript("OnEvent",zb_on_event)
zb_frame:RegisterEvent("PLAYER_LOGIN")
