if unsupported then return end

local function ease_out_cubic(t) return 1 - (1 - t)^3 end
local function ease_in_out_cubic(t) return t < 0.5 and 4 * t^3 or 1 - (-2 * t + 2)^3 / 2 end

local menu_corner_radius = 12
local s_lerp, a_lerp, fade_alpha, fake_loading_frame = 0, 0, 0, 0
local r_borders_lerp = 1
local loading_dots = ""
local t_c, s_off, a_scroll, menu_cooldown = 0, 0, 0, 0

local menu_level, sel_dash, sel_sub = 1, 1, 1
local a_dash_cursor_x, a_dash_cursor_y, a_dash_cursor_w, a_dash_cursor_h = 0, 0, 0, 0
local dash_alpha, sub_alpha, title_lerp, wave_intensity, a_item = 1, 0, 0, 1, 0
local dash_card_scales, dash_card_alphas = {}, {}
for i = 1, 10 do dash_card_scales[i] = 1; dash_card_alphas[i] = 1 end

local s_select = audio_sample_load("sound/select_menu.ogg")
local s_press  = audio_sample_load("sound/press_menu.ogg")
local s_open   = audio_sample_load("sound/open_menu.ogg")
menu_volume = menu_volume or 1.0
local was_menu_open = false
local tex_logo = get_texture_info("coords_better_logo")

if M.r_borders == nil then M.r_borders = true end

local parts = {}
for i = 1, 50 do parts[i] = { x = math.random(100), y = math.random(100), s = math.random(3, 8) * 0.1, z = math.random(2, 4) } end

local tabs = {
    { 
        n_key = "tab_coords", 
        items = { 
            { id = "xyz", n_key = "xyz_name", d_key = "xyz_desc", type = "toggle" }, 
            { id = "spd", n_key = "spd_name", d_key = "spd_desc", type = "toggle" }, 
            { id = "anim", n_key = "anim_name", d_key = "anim_desc", type = "toggle" } 
        } 
    },
    { 
        n_key = "tab_colors", 
        items = { 
            { id = "h_col", n_key = "tab_colors", d_key = "h_col_desc", type = "cycle", action = "hud_color", choices = _G.HudThemes, cur_idx = 1 } 
        } 
    },
    { 
        n_key = "tab_style", 
        items = { 
            { id = "m_col", n_key = "tab_style", d_key = "m_col_desc", type = "cycle", action = "menu_color", choices = _G.MenuThemes, cur_idx = 1 },
            { id = "r_borders", n_key = "menu_bord_name", d_key = "menu_bord_desc", type = "toggle" },
            { id = "m_vol", n_key = "menu_volume_name", d_key = "menu_volume_desc", type = "cycle", action = "volume", 
                choices = {
                    { n_key = "0%", val = 0.0 }, { n_key = "20%", val = 0.2 }, { n_key = "40%", val = 0.4 },
                    { n_key = "60%", val = 0.6 }, { n_key = "80%", val = 0.8 }, { n_key = "100%", val = 1.0 },
                    { n_key = "150%", val = 1.5 }, { n_key = "200%", val = 2.0 }
                }, 
                cur_idx = 6 
            } 
        } 
    },
    { 
        n_key = "tab_lang", 
        items = { 
            { id = "lang", n_key = "tab_lang", d_key = "lang_desc", type = "cycle", action = "lang", 
                choices = {
                    { n_key = "lang_es_name", lang_code = "es" }, 
                    { n_key = "lang_en_name", lang_code = "en" },
                    { n_key = "lang_fr_name", lang_code = "fr" },
                    { n_key = "lang_pt_name", lang_code = "pt-br" }
                }, 
                cur_idx = 1 
            } 
        } 
    }
}

local function play_menu_sound(snd)
    if snd then audio_sample_play(snd, gMarioStates[0].pos, menu_volume) end
end

local function sync_cycles()
    for _, tab in ipairs(tabs) do
        for _, item in ipairs(tab.items) do
            if item.type == "cycle" then
                if not item.choices then
                    if item.action == "hud_color" then item.choices = _G.HudThemes end
                    if item.action == "menu_color" then item.choices = _G.MenuThemes end
                end
                
                local choices = item.choices or {}
                
                for idx, choice in ipairs(choices) do
                    local a = item.action
                    if (a == "hud_color" and choice.color and tr == choice.color[1] and tg == choice.color[2] and tb == choice.color[3]) or
                       (a == "menu_color" and choice.color and tm_r == choice.color[1] and tm_g == choice.color[2] and tm_b == choice.color[3]) or
                       (a == "lang" and _G.LANG and _G.LANG.current == choice.lang_code) or
                       (a == "volume" and menu_volume == choice.val) then
                        item.cur_idx = idx
                    end
                end
            end
        end
    end
end

local function draw_rounded_rect(x, y, w, h, radius)
    radius = radius * r_borders_lerp

    local r = math.max(0, math.min(radius, w / 2, h / 2))

    if r <= 0.5 then djui_hud_render_rect(x, y, w, h); return end

    djui_hud_render_rect(x + r, y, w - r * 2, h)
    djui_hud_render_rect(x, y + r, r, h - r * 2)
    djui_hud_render_rect(x + w - r, y + r, r, h - r * 2)

    local r_int = math.ceil(r)
    for i = 0, r_int - 1 do
        local dy = r - i
        local dx = math.sqrt(math.max(0, r * r - dy * dy))
        local h_slice = (i == r_int - 1 and r_int > r) and (1 - (r_int - r)) or 1
        djui_hud_render_rect(x + r - dx, y + i, dx, h_slice)
        djui_hud_render_rect(x + w - r, y + i, dx, h_slice)
        djui_hud_render_rect(x + r - dx, y + h - i - h_slice, dx, h_slice)
        djui_hud_render_rect(x + w - r, y + h - i - h_slice, dx, h_slice)
    end
end

local function draw_shadow_text(text, x, y, scale, r, g, b, a)
    djui_hud_set_color(0, 0, 0, a * 0.4)
    djui_hud_print_text(text, x + (1.5 * scale), y + (1.5 * scale), scale)
    djui_hud_set_color(r, g, b, a)
    djui_hud_print_text(text, x, y, scale)
end

local function draw_wavy_text(text, start_x, start_y, scale, r, g, b, a, wave_amp)
    wave_amp = wave_amp or 1
    local current_x_sh, current_x = start_x + (1.5 * scale), start_x
    local j, i = 1, 1
    
    for char in text:gmatch(".[\128-\191]*") do
        local wave_y = math.sin(t_c * 4 + j * 0.4) * 2.5 * s_lerp * wave_amp
        djui_hud_set_color(0, 0, 0, a * 0.4)
        djui_hud_print_text(char, current_x_sh, start_y + wave_y + (1.5 * scale), scale)
        current_x_sh = current_x_sh + djui_hud_measure_text(char) * scale; j = j + 1
    end

    for char in text:gmatch(".[\128-\191]*") do
        local wave_y = math.sin(t_c * 4 + i * 0.4) * 2.5 * s_lerp * wave_amp
        djui_hud_set_color(r, g, b, a)
        djui_hud_print_text(char, current_x, start_y + wave_y, scale)
        current_x = current_x + djui_hud_measure_text(char) * scale; i = i + 1
    end
end

local function draw_wavy_marquee_text(text, start_x, start_y, scale, base_r, base_g, base_b, alpha, wave_amp, marquee_amp)
    wave_amp = wave_amp or 1; marquee_amp = marquee_amp or 1
    local current_x_sh, current_x = start_x + (1.5 * scale), start_x
    local j, k, len = 1, 1, 0
    
    for char in text:gmatch(".[\128-\191]*") do
        local wave_y = math.sin(t_c * 4 + j * 0.4) * 2.5 * s_lerp * wave_amp
        djui_hud_set_color(0, 0, 0, alpha * 0.4)
        djui_hud_print_text(char, current_x_sh, start_y + wave_y + (1.5 * scale), scale)
        current_x_sh = current_x_sh + djui_hud_measure_text(char) * scale; j = j + 1; len = len + 1
    end

    local current_cycle = t_c % ((len * 0.4) + 4.5)
    for char in text:gmatch(".[\128-\191]*") do
        local wave_y = math.sin(t_c * 4 + k * 0.4) * 2.5 * s_lerp * wave_amp
        local blend = math.max(0, 1 - (math.abs(current_cycle / 0.4 - k) / 1.5))
        
        djui_hud_set_color(base_r + (255 - base_r) * blend * marquee_amp, base_g + (255 - base_g) * blend * marquee_amp, base_b + (255 - base_b) * blend * marquee_amp, alpha)
        djui_hud_print_text(char, current_x, start_y + wave_y, scale)
        current_x = current_x + djui_hud_measure_text(char) * scale; k = k + 1
    end
end

local function get_item_status(item) return item.type == "toggle" and M[item.id] or false end

local function execute_item_action(item, choice)
    if item.type == "toggle" then
        M[item.id] = not M[item.id]
        if item.id == "xyz" then exiting_xyz = not M.xyz end
        if item.id == "spd" then exiting_spd = not M.spd end
        play_menu_sound(s_press)
        notify(_T(item.n_key) .. (M[item.id] and " ON" or " OFF"), M[item.id])
    elseif item.type == "cycle" then
        local a = item.action
        if a == "hud_color" and choice.color then 
            tr, tg, tb = choice.color[1], choice.color[2], choice.color[3]
            play_menu_sound(s_press)
            notify(_T("notify_hud") .. _T(choice.n_key), true)
        elseif a == "menu_color" and choice.color then 
            tm_r, tm_g, tm_b = choice.color[1], choice.color[2], choice.color[3]
            play_menu_sound(s_press)
            notify(_T("notify_menu") .. _T(choice.n_key), true)
        elseif a == "lang" and lang_fade_timer == 0 then 
            pending_lang_change = choice.lang_code; lang_fade_timer = 1; play_menu_sound(s_press)
        elseif a == "volume" then 
            menu_volume = choice.val; play_menu_sound(s_press) 
        end
    end
    save_config()
end

local function handle_menu_navigation(m, p)
    local c = m.controller
    local right = (c.stickX > 40) or ((p & R_JPAD) ~= 0)
    local left = (c.stickX < -40) or ((p & L_JPAD) ~= 0)
    local down = (c.stickY < -40) or ((p & D_JPAD) ~= 0)
    local up = (c.stickY > 40) or ((p & U_JPAD) ~= 0)

    if not (right or left or down or up) then menu_cooldown = 0 end

    if menu_cooldown > 0 then menu_cooldown = menu_cooldown - 1 else
        if menu_level == 1 then
            if right then sel_dash = math.min(sel_dash + 1, #tabs); play_menu_sound(s_select); menu_cooldown = 8
            elseif left then sel_dash = math.max(sel_dash - 1, 1); play_menu_sound(s_select); menu_cooldown = 8
            elseif down then sel_dash = math.min(sel_dash + 2, #tabs); play_menu_sound(s_select); menu_cooldown = 8
            elseif up then sel_dash = math.max(sel_dash - 2, 1); play_menu_sound(s_select); menu_cooldown = 8 end
            
            if (p & A_BUTTON) ~= 0 then menu_level, sel_sub, s_off = 2, 1, 0; play_menu_sound(s_open) end
        elseif menu_level == 2 then
            local max_i, itm = #tabs[sel_dash].items, tabs[sel_dash].items[sel_sub]

            if down and sel_sub < max_i then 
                sel_sub = sel_sub + 1; play_menu_sound(s_select) 
                if sel_sub > s_off + 4 then s_off = s_off + 1 end
                menu_cooldown = 8
            elseif up and sel_sub > 1 then 
                sel_sub = sel_sub - 1; play_menu_sound(s_select) 
                if sel_sub <= s_off then s_off = s_off - 1 end 
                menu_cooldown = 8
            end

            if itm.type == "cycle" then
                if right then itm.cur_idx = itm.cur_idx % #itm.choices + 1; execute_item_action(itm, itm.choices[itm.cur_idx]); menu_cooldown = 8
                elseif left then itm.cur_idx = (itm.cur_idx - 2) % #itm.choices + 1; execute_item_action(itm, itm.choices[itm.cur_idx]); menu_cooldown = 8 end
            end
            if (p & A_BUTTON) ~= 0 and itm.type == "toggle" then execute_item_action(itm) end
        end
    end

    if (p & B_BUTTON) ~= 0 then 
        if menu_level == 2 then menu_level = 1; play_menu_sound(s_select)
        else menu_state, menu_level = "closed", 1 end
    end
end

local function on_before_mario_update(m)
    if m.playerIndex ~= 0 then return end
    
    if menu_state == "closed" then 
        if was_menu_open then 
            seq_player_unlower_volume(0, 1)
            was_menu_open = false 
            if m.action == ACT_READING_NPC_DIALOG then
                set_mario_action(m, ACT_IDLE, 0)
            end
        end
        sync_cycles()
        return 
    end

    if not was_menu_open then 
        seq_player_lower_volume(0, 1, 50)
        was_menu_open = true 
    end
    
    if menu_state == "ready" then 
        handle_menu_navigation(m, m.controller.buttonPressed) 
    end
    
    if m.action ~= ACT_READING_NPC_DIALOG then
        set_mario_action(m, ACT_READING_NPC_DIALOG, 0)
    end
end

local function draw_menu_background(x, y, w, h)
    local bg_radius = menu_corner_radius * s_lerp
    djui_hud_set_color(11, 14, 26, 235 * a_lerp) 
    draw_rounded_rect(x, y, w, h, bg_radius)

    for _, p in ipairs(parts) do
        p.y = p.y - p.s 
        if p.y < 0 then p.y = 100; p.x = math.random(100) end
        djui_hud_set_color(m_r, m_g, m_b, (40 + 90 * ((math.sin(t_c * 1.5 + p.x) + 1) / 2)) * s_lerp * a_lerp * 0.5)
        djui_hud_render_rect(x + (p.x / 100) * w, y + (p.y / 100) * h, p.z * s_lerp, p.z * s_lerp)
    end

    djui_hud_set_color(m_r, m_g, m_b, (170 + 85 * ((math.sin(t_c * 2.5) + 1) / 2)) * a_lerp)
    draw_rounded_rect(x + bg_radius, y, w - (bg_radius * 2), 4 * s_lerp, 2 * s_lerp) 
    draw_rounded_rect(x + bg_radius, y + h - 4 * s_lerp, w - (bg_radius * 2), 4 * s_lerp, 2 * s_lerp)
end

local function draw_dashboard(x, y, w, h, f_a, d_alpha)
    local inner_radius = menu_corner_radius * 0.7 * s_lerp
    draw_shadow_text(_T("menu_dashboard_title"), x + (w / 2) - (djui_hud_measure_text(_T("menu_dashboard_title")) * 0.5 * s_lerp), y + 10 * s_lerp, 1 * s_lerp, 255, 255, 255, 255 * f_a * d_alpha)

    djui_hud_set_color(m_r, m_g, m_b, 100 * f_a * d_alpha) 
    draw_rounded_rect(x + 30 * s_lerp, y + 45 * s_lerp, w - 60 * s_lerp, 2 * s_lerp, 1 * s_lerp)

    local b_w, b_h = (w / 2) - 40 * s_lerp, (h / 2) - 50 * s_lerp
    local start_x, start_y = x + 25 * s_lerp, y + 60 * s_lerp
    local l_alpha = (lang_text_alpha and (lang_text_alpha / 255) or 1)

    for i, t in ipairs(tabs) do
        local card_f_a = f_a * (dash_card_alphas[i] or 1)
        if card_f_a >= 0.01 then
            local c_scale = dash_card_scales[i] or 1
            local cx, cy = start_x + ((i - 1) % 2) * (b_w + 30 * s_lerp) + b_w/2, start_y + math.floor((i - 1) / 2) * (b_h + 20 * s_lerp) + b_h/2
            local bw_scaled, bh_scaled = b_w * c_scale, b_h * c_scale
            local bx, by = cx - bw_scaled/2, cy - bh_scaled/2

            if i == sel_dash then
                if a_dash_cursor_w == 0 then a_dash_cursor_x, a_dash_cursor_y, a_dash_cursor_w, a_dash_cursor_h = bx, by, bw_scaled, bh_scaled end
                a_dash_cursor_x, a_dash_cursor_y, a_dash_cursor_w, a_dash_cursor_h = lerp(a_dash_cursor_x, bx, 0.18), lerp(a_dash_cursor_y, by, 0.18), lerp(a_dash_cursor_w, bw_scaled, 0.18), lerp(a_dash_cursor_h, bh_scaled, 0.18)
                djui_hud_set_color(m_r, m_g, m_b, (60 + 30 * ((math.sin(t_c * 3) + 1) / 2)) * card_f_a)
                draw_rounded_rect(a_dash_cursor_x, a_dash_cursor_y, a_dash_cursor_w, a_dash_cursor_h, inner_radius)
                djui_hud_set_color(m_r, m_g, m_b, 255 * card_f_a)
                draw_rounded_rect(a_dash_cursor_x, a_dash_cursor_y + inner_radius, 4 * s_lerp, a_dash_cursor_h - (inner_radius * 2), 2 * s_lerp)
            else
                djui_hud_set_color(m_r, m_g, m_b, 20 * card_f_a)
                draw_rounded_rect(bx, by, bw_scaled, bh_scaled, inner_radius)
                draw_shadow_text(_T(t.n_key), cx - (djui_hud_measure_text(_T(t.n_key)) * 0.4 * s_lerp * c_scale), cy - 10 * s_lerp * c_scale, 1 * s_lerp * c_scale, 255, 255, 255, 150 * card_f_a * l_alpha)
            end
        end
    end
end

local function draw_submenu(x, y, w, h, f_a)
    local itms = tabs[sel_dash].items
    local inner_radius, btn_radius = menu_corner_radius * 0.7 * s_lerp, menu_corner_radius * 0.5 * s_lerp
    local txt_alpha = f_a * (lang_text_alpha and (lang_text_alpha / 255) or 1)
    local slide_y = (1 - sub_alpha) * 40 * s_lerp
    
    djui_hud_set_color(m_r, m_g, m_b, 230 * f_a)
    draw_rounded_rect(x + 12 * s_lerp, y + 45 * s_lerp + slide_y, w - 24 * s_lerp, 3 * s_lerp, 1.5 * s_lerp)
    draw_shadow_text(_T("menu_back"), x + 15 * s_lerp, y + 15 * s_lerp - slide_y, 0.6 * s_lerp, 255, 255, 255, 255 * txt_alpha)

    a_scroll = lerp(a_scroll, s_off, 0.18)
    local i_st = y + 66 * s_lerp
    a_item = lerp(a_item, i_st + ((sel_sub - 1 - a_scroll) * 56 * s_lerp), 0.22)

    djui_hud_set_color(m_r, m_g, m_b, 35 * f_a) 
    draw_rounded_rect(x + 15 * s_lerp, a_item + slide_y, w - 30 * s_lerp, 50 * s_lerp, inner_radius)
    djui_hud_set_color(m_r, m_g, m_b, 240 * f_a) 
    draw_rounded_rect(x + 15 * s_lerp, a_item + inner_radius + slide_y, 4 * s_lerp, 50 * s_lerp - (inner_radius * 2), 2 * s_lerp)

    for i = 1, #itms do
        local r_i = i - a_scroll
        if r_i > 0 and r_i <= 5 then
            local iy = i_st + ((r_i - 1) * 56 * s_lerp) + slide_y
            if iy > i_st - 10 + slide_y and iy < y + h - 65 * s_lerp + slide_y then
                local r_val = (i == sel_sub) and 255 or 200
                if i == sel_sub then draw_wavy_text(_T(itms[i].n_key), x + 35 * s_lerp, iy + 6 * s_lerp, 0.8 * s_lerp, r_val, r_val, r_val, 255 * txt_alpha)
                else draw_shadow_text(_T(itms[i].n_key), x + 35 * s_lerp, iy + 6 * s_lerp, 0.8 * s_lerp, r_val, r_val, r_val, 255 * txt_alpha) end
                
                djui_hud_set_color(160, 185, 225, (i == sel_sub and 220 or 140) * txt_alpha)
                djui_hud_print_text(_T(itms[i].d_key), x + 35 * s_lerp, iy + 28 * s_lerp, 0.5 * s_lerp)

                if itms[i].type == "toggle" then
                    local status_on = get_item_status(itms[i])
                    local bx, by_btn, bw_btn, bh_btn = x + w - 95 * s_lerp, iy + 12 * s_lerp, 65 * s_lerp, 24 * s_lerp
                    djui_hud_set_color(status_on and 22 or 64, status_on and 64 or 24, status_on and 44 or 34, 180 * f_a)
                    draw_rounded_rect(bx, by_btn, bw_btn, bh_btn, btn_radius)
                    local txt_status = status_on and _T("status_on") or _T("status_off")
                    draw_shadow_text(txt_status, bx + (bw_btn / 2) - (djui_hud_measure_text(txt_status) * 0.35 * s_lerp), by_btn, 0.7 * s_lerp, status_on and 50 or 255, status_on and 255 or 50, status_on and 150 or 80, 240 * txt_alpha)
                elseif itms[i].type == "cycle" then
                    local txt_choice = "< " .. _T(itms[i].choices[itms[i].cur_idx].n_key) .. " >"
                    local ch_scale = 0.7 * s_lerp
                    draw_shadow_text(txt_choice, x + w - (djui_hud_measure_text(txt_choice) * ch_scale) - 40 * s_lerp, iy + 12 * s_lerp, ch_scale, i == sel_sub and 255 or 200, i == sel_sub and 255 or 200, i == sel_sub and 255 or 200, (i == sel_sub and 255 or 200) * txt_alpha)
                end
            end
        end
    end

    if #itms > 4 then
        local sb_h = (4 / #itms) * (h - 145 * s_lerp)
        djui_hud_set_color(24, 28, 48, 200 * f_a) 
        draw_rounded_rect(x + w - 14 * s_lerp, i_st + slide_y, 4 * s_lerp, h - 145 * s_lerp, 2 * s_lerp)
        djui_hud_set_color(m_r, m_g, m_b, 255 * f_a) 
        draw_rounded_rect(x + w - 14 * s_lerp, i_st + (a_scroll / (#itms - 4)) * (h - 145 * s_lerp - sb_h) + slide_y, 4 * s_lerp, sb_h, 2 * s_lerp)
    end
end

local function on_hud_render_menu()
    local m = gMarioStates[0]
    if not m or not m.marioObj then return end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_ALIASED)

    t_c = t_c + 0.04
    local sw, sh = djui_hud_get_screen_width(), djui_hud_get_screen_height()

    s_lerp, a_lerp = lerp(s_lerp, menu_state ~= "closed" and 1 or 0, 0.14), lerp(a_lerp, menu_state ~= "closed" and 1 or 0, 0.11)
    dash_alpha, sub_alpha = lerp(dash_alpha, menu_level == 1 and 1 or 0, 0.15), lerp(sub_alpha, menu_level == 2 and 1 or 0, 0.15)
    title_lerp, wave_intensity = lerp(title_lerp, menu_level == 2 and 1 or 0, 0.12), lerp(wave_intensity, menu_level == 1 and 1 or 0, 0.12)
    r_borders_lerp = lerp(r_borders_lerp, M.r_borders and 1 or 0, 0.15)

    for i = 1, #tabs do
        dash_card_scales[i] = lerp(dash_card_scales[i] or 1, menu_level == 1 and (i == sel_dash and 1.05 or 1.0) or (i == sel_dash and 1.15 or 0.8), 0.15)
        dash_card_alphas[i] = lerp(dash_card_alphas[i] or 1, menu_level == 1 and 1.0 or 0.0, 0.15)
    end

    if menu_state == "closed" then fade_alpha, fake_loading_frame = 0, 0
    elseif menu_state == "loading" then
        fake_loading_frame = fake_loading_frame + 1
        loading_dots = fake_loading_frame % 45 < 15 and "." or (fake_loading_frame % 45 < 30 and ".." or "...")
        if fake_loading_frame > 60 then menu_state, fake_loading_frame = "ready", 0 end
    elseif menu_state == "ready" then fade_alpha = lerp(fade_alpha, 1, 0.12) end

    if s_lerp < 0.01 then return end

    local s_animated = 1 - (1 - s_lerp)^3
    local w, h = 560 * s_animated, 400 * s_animated
    local x, y = (sw - w) / 2, (sh - h) / 2

    djui_hud_set_color(4, 6, 14, 130 * a_lerp) 
    djui_hud_render_rect(0, 0, sw, sh)
    
    draw_menu_background(x, y, w, h)

    local base_scale = 0.2 
    local tex_scale = base_scale * s_lerp
    local tex_w = 2048 * tex_scale
    local tex_h = 1024 * tex_scale
    local logo_float = math.sin(t_c * 2.5) * 8 * s_lerp
    
    local b_text = "Finally complete Coords Better menu!"
    local text_sc = 1 * s_lerp 
    local text_w = djui_hud_measure_text(b_text) * text_sc
    
    local line_w = math.max(tex_w, text_w + 40 * s_lerp)
    local right_margin = 45 * s_lerp
    local panel_center_x = x + w + right_margin + (line_w / 2)
    local panel_center_y = y + (h / 2)

    local logo_x = panel_center_x - (tex_w / 2)
    local logo_y = panel_center_y - (tex_h / 2) - 15 * s_lerp + logo_float
    local line_x = panel_center_x - (line_w / 2)
    local line_y = panel_center_y + (tex_h / 2) + 15 * s_lerp
    local text_x = panel_center_x - (text_w / 2)
    local text_y = line_y + 15 * s_lerp

    if tex_logo ~= nil then
        djui_hud_set_color(255, 255, 255, 255 * a_lerp)
        djui_hud_render_texture(tex_logo, logo_x, logo_y, tex_scale, tex_scale)
    end

    djui_hud_set_color(255, 255, 255, 200 * a_lerp)
    djui_hud_render_rect(line_x, line_y, line_w, 2 * s_lerp)

    draw_shadow_text(b_text, text_x, text_y, text_sc, 220, 235, 255, 255 * a_lerp)

    if menu_state == "loading" then
        draw_shadow_text(_T("loading") .. loading_dots, x + (w / 2) - (djui_hud_measure_text(_T("loading") .. loading_dots) * 0.7 * s_lerp), y + (h / 2) - 10 * s_lerp, 1.4 * s_lerp, 255, 255, 255, 255 * a_lerp)
    end

    local f_a = a_lerp * fade_alpha
    if f_a > 0.01 then
        draw_dashboard(x, y, w, h, f_a, dash_alpha)
        if sub_alpha > 0.01 then draw_submenu(x, y, w, h, f_a * sub_alpha) end
        
        if tabs[sel_dash] then
            local txt_tab = _T(tabs[sel_dash].n_key)
            local b_w, b_h = (w / 2) - 40 * s_lerp, (h / 2) - 50 * s_lerp
            local c_scale = dash_card_scales[sel_dash] or 1
            local cx = x + 25 * s_lerp + ((sel_dash - 1) % 2) * (b_w + 30 * s_lerp) + b_w/2
            local cy = y + 60 * s_lerp + math.floor((sel_dash - 1) / 2) * (b_h + 20 * s_lerp) + b_h/2
            local title_animated = title_lerp < 0.5 and 4 * title_lerp^3 or 1 - (-2 * title_lerp + 2)^3 / 2
            
            draw_wavy_marquee_text(txt_tab, lerp(cx - (djui_hud_measure_text(txt_tab) * 0.4 * s_lerp * c_scale), x + (w / 2) - (djui_hud_measure_text(txt_tab) * 0.5 * s_lerp), title_animated), lerp(cy - 10 * s_lerp * c_scale, y + 15 * s_lerp, title_animated), lerp(1 * s_lerp * c_scale, 1 * s_lerp, title_animated), lerp(m_r, 255, title_animated), lerp(m_g, 255, title_animated), lerp(m_b, 255, title_animated), 255 * f_a * (lang_text_alpha and (lang_text_alpha / 255) or 1), wave_intensity, 1 - title_animated)
        end

        draw_shadow_text(_T("footer"), x + (w / 2) - (djui_hud_measure_text(_T("footer")) * 0.25 * s_lerp), y + h - 20 * s_lerp, 0.5 * s_lerp, 140, 170, 210, 190 * f_a)
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render_menu)
hook_event(HOOK_MARIO_UPDATE, on_before_mario_update)