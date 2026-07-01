if unsupported then return end

-------------------------
--- VARIABLES & SETUP ---
-------------------------

local menu_corner_radius = 12

local s_lerp = 0
local a_lerp = 0
local fade_alpha = 0
local fake_loading_frame = 0
local loading_dots = ""

local t_c = 0
local s_off = 0
local a_scroll = 0
local menu_cooldown = 0 
local parts = {}

local menu_level = 1
local sel_dash = 1
local sel_sub = 1
local a_dash_cursor_x = 0
local a_dash_cursor_y = 0
local a_item = 0
local dash_alpha = 1
local sub_alpha = 0

-- Variables de Sonidos Personalizados
local s_select = audio_sample_load("sound/select_menu.ogg")
local s_press  = audio_sample_load("sound/press_menu.ogg")
local s_open   = audio_sample_load("sound/open_menu.ogg")
local menu_volume = 1.0 -- Volumen global del menú (0.0 a 1.0)

for i = 1, 50 do 
    parts[i] = { x = math.random(100), y = math.random(100), s = math.random(3, 8) * 0.1, z = math.random(2, 4) } 
end

local tabs = {
    { 
        n_key = "tab_coords", 
        items = {
            {id = "xyz",  n_key = "xyz_name",  d_key = "xyz_desc", type = "toggle"}, 
            {id = "spd",  n_key = "spd_name",  d_key = "spd_desc", type = "toggle"}, 
            {id = "anim", n_key = "anim_name", d_key = "anim_desc", type = "toggle"}
        } 
    },
    { 
        n_key = "tab_colors", 
        items = {
            {id = "h_col", n_key = "tab_colors", d_key = "h_col_desc", type = "cycle", action = "hud_color",
             choices = {
                {n_key = "h_yel_name", color = {255, 255, 30}}, 
                {n_key = "h_red_name", color = {255, 50,  50}}, 
                {n_key = "h_grn_name", color = {50,  255, 50}}, 
                {n_key = "h_blu_name", color = {50,  150, 255}}, 
                {n_key = "h_wht_name", color = {255, 255, 255}}
             }, cur_idx = 1
            }
        } 
    },
    { 
        n_key = "tab_style", 
        items = {
            {id = "m_col", n_key = "tab_style", d_key = "m_col_desc", type = "cycle", action = "menu_color",
             choices = {
                {n_key = "m_cyn_name", color = {0,   255, 255}}, 
                {n_key = "m_red_name", color = {255, 50,  50}}, 
                {n_key = "m_grn_name", color = {50,  255, 50}}, 
                {n_key = "m_pur_name", color = {200, 50,  255}}, 
                {n_key = "m_gld_name", color = {255, 200, 0}}
             }, cur_idx = 1
            },
            {id = "m_vol", n_key = "menu_volume_name", d_key = "menu_volume_desc", type = "cycle", action = "volume",
             choices = {
                {n_key = "0%", val = 0.0},
                {n_key = "20%", val = 0.2},
                {n_key = "40%", val = 0.4},
                {n_key = "60%", val = 0.6},
                {n_key = "80%", val = 0.8},
                {n_key = "100%", val = 1.0},
                {n_key = "150%", val = 1.5},
                {n_key = "200%", val = 2.0}
             }, cur_idx = 6
            }
        } 
    },
    { 
        n_key = "tab_lang", 
        items = {
            {id = "lang", n_key = "tab_lang", d_key = "lang_desc", type = "cycle", action = "lang",
             choices = {
                {n_key = "lang_es_name", lang_code = "es"}, 
                {n_key = "lang_en_name", lang_code = "en"},
                {n_key = "lang_fr_name", lang_code = "fr"}
             }, cur_idx = 1
            }
        } 
    }
}

-----------------
--- FUNCIONES ---
-----------------

local function play_menu_sound(snd)
    if snd then
        -- Reproduce el sample de sonido en la posición del jugador local
        audio_sample_play(snd, gMarioStates[0].pos, menu_volume)
    end
end

local function sync_cycles()
    for _, tab in ipairs(tabs) do
        for _, item in ipairs(tab.items) do
            if item.type == "cycle" then
                for idx, choice in ipairs(item.choices) do
                    if item.action == "hud_color" and tr == choice.color[1] and tg == choice.color[2] and tb == choice.color[3] then
                        item.cur_idx = idx
                    elseif item.action == "menu_color" and tm_r == choice.color[1] and tm_g == choice.color[2] and tm_b == choice.color[3] then
                        item.cur_idx = idx
                    elseif item.action == "lang" and _G.LANG and _G.LANG.current == choice.lang_code then
                        item.cur_idx = idx
                    elseif item.action == "volume" and menu_volume == choice.val then
                        item.cur_idx = idx
                    end
                end
            end
        end
    end
end

local function draw_rounded_rect(x, y, w, h, radius)
    local r = math.max(0, math.min(radius, w / 2, h / 2))
    if r <= 0 then
        djui_hud_render_rect(x, y, w, h)
        return
    end

    djui_hud_render_rect(x + r, y, w - r * 2, h)
    djui_hud_render_rect(x, y + r, r, h - r * 2)
    djui_hud_render_rect(x + w - r, y + r, r, h - r * 2)

    local r_int = math.ceil(r)
    for i = 0, r_int - 1 do
        local dy = r - i
        local dx = math.sqrt(math.max(0, r * r - dy * dy))
        local h_slice = 1
        if i == r_int - 1 and r_int > r then
            h_slice = 1 - (r_int - r)
        end
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

local function draw_wavy_text(text, start_x, start_y, scale, r, g, b, a)
    local current_x_sh = start_x + (1.5 * scale)
    local j = 1
    for char in text:gmatch(".[\128-\191]*") do
        local wave_y = math.sin(t_c * 4 + j * 0.4) * 2.5 * s_lerp
        djui_hud_set_color(0, 0, 0, a * 0.4)
        djui_hud_print_text(char, current_x_sh, start_y + wave_y + (1.5 * scale), scale)
        current_x_sh = current_x_sh + djui_hud_measure_text(char) * scale
        j = j + 1
    end

    local current_x = start_x
    local i = 1
    for char in text:gmatch(".[\128-\191]*") do
        local wave_y = math.sin(t_c * 4 + i * 0.4) * 2.5 * s_lerp
        djui_hud_set_color(r, g, b, a)
        djui_hud_print_text(char, current_x, start_y + wave_y, scale)
        current_x = current_x + djui_hud_measure_text(char) * scale
        i = i + 1
    end
end

local function draw_wavy_marquee_text(text, start_x, start_y, scale, base_r, base_g, base_b, alpha)
    local current_x_sh = start_x + (1.5 * scale)
    local j = 1
    for char in text:gmatch(".[\128-\191]*") do
        local wave_y = math.sin(t_c * 4 + j * 0.4) * 2.5 * s_lerp
        djui_hud_set_color(0, 0, 0, alpha * 0.4)
        djui_hud_print_text(char, current_x_sh, start_y + wave_y + (1.5 * scale), scale)
        current_x_sh = current_x_sh + djui_hud_measure_text(char) * scale
        j = j + 1
    end

    local len = 0
    for _ in text:gmatch(".[\128-\191]*") do len = len + 1 end
    
    local total_cycle = (len * 0.4) + 4.5 
    local current_cycle = t_c % total_cycle
    
    local current_x = start_x
    local k = 1
    for char in text:gmatch(".[\128-\191]*") do
        local wave_y = math.sin(t_c * 4 + k * 0.4) * 2.5 * s_lerp
        local highlight_idx = current_cycle / 0.4
        local dist = math.abs(highlight_idx - k)
        local blend = math.max(0, 1 - (dist / 1.5))
        
        local r = base_r + (255 - base_r) * blend
        local g = base_g + (255 - base_g) * blend
        local b = base_b + (255 - base_b) * blend
        
        djui_hud_set_color(r, g, b, alpha)
        djui_hud_print_text(char, current_x, start_y + wave_y, scale)
        
        current_x = current_x + djui_hud_measure_text(char) * scale
        k = k + 1
    end
end

local function get_item_status(item)
    if item.type == "toggle" then 
        return M[item.id]
    end
    return false
end

local function execute_item_action(item, choice)
    if item.type == "toggle" then
        local id = item.id
        M[id] = not M[id]
        if id == "xyz" then exiting_xyz = not M.xyz end
        if id == "spd" then exiting_spd = not M.spd end
        play_menu_sound(s_press)
        notify(_T(item.n_key) .. (M[id] and " ON" or " OFF"), M[id])
    elseif item.type == "cycle" then
        if item.action == "hud_color" then
            tr, tg, tb = choice.color[1], choice.color[2], choice.color[3]
            play_menu_sound(s_press)
            notify(_T("notify_hud") .. _T(choice.n_key), true)
        elseif item.action == "menu_color" then
            tm_r, tm_g, tm_b = choice.color[1], choice.color[2], choice.color[3]
            play_menu_sound(s_press)
            notify(_T("notify_menu") .. _T(choice.n_key), true)
        elseif item.action == "lang" then
            if lang_fade_timer == 0 then
                pending_lang_change = choice.lang_code
                lang_fade_timer = 1
                play_menu_sound(s_press)
            end
        elseif item.action == "volume" then
            menu_volume = choice.val
            play_menu_sound(s_press)
        end
    end
    save_config()
end

local function handle_menu_navigation(m, p)
    local stickX = m.controller.stickX
    local stickY = m.controller.stickY

    local rightPressed = (stickX > 40) or ((p & R_JPAD) ~= 0)
    local leftPressed = (stickX < -40) or ((p & L_JPAD) ~= 0)
    local downPressed = (stickY < -40) or ((p & D_JPAD) ~= 0)
    local upPressed = (stickY > 40) or ((p & U_JPAD) ~= 0)

    if not (rightPressed or leftPressed or downPressed or upPressed) then
        menu_cooldown = 0
    end

    if menu_cooldown > 0 then
        menu_cooldown = menu_cooldown - 1
    else
        if menu_level == 1 then
            if rightPressed then 
                sel_dash = math.min(sel_dash + 1, #tabs); play_menu_sound(s_select); menu_cooldown = 8
            elseif leftPressed then 
                sel_dash = math.max(sel_dash - 1, 1); play_menu_sound(s_select); menu_cooldown = 8
            elseif downPressed then
                sel_dash = math.min(sel_dash + 2, #tabs); play_menu_sound(s_select); menu_cooldown = 8
            elseif upPressed then
                sel_dash = math.max(sel_dash - 2, 1); play_menu_sound(s_select); menu_cooldown = 8
            end
            
            if (p & A_BUTTON) ~= 0 then
                menu_level = 2
                sel_sub = 1
                s_off = 0
                play_menu_sound(s_open)
            end

        elseif menu_level == 2 then
            local max_i = #tabs[sel_dash].items
            local current_item = tabs[sel_dash].items[sel_sub]

            if downPressed and sel_sub < max_i then 
                sel_sub = sel_sub + 1; play_menu_sound(s_select) 
                if sel_sub > s_off + 4 then s_off = s_off + 1 end
                menu_cooldown = 8
            elseif upPressed and sel_sub > 1 then 
                sel_sub = sel_sub - 1; play_menu_sound(s_select) 
                if sel_sub <= s_off then s_off = s_off - 1 end 
                menu_cooldown = 8
            end

            if current_item.type == "cycle" then
                if rightPressed then
                    current_item.cur_idx = current_item.cur_idx + 1
                    if current_item.cur_idx > #current_item.choices then current_item.cur_idx = 1 end
                    execute_item_action(current_item, current_item.choices[current_item.cur_idx])
                    menu_cooldown = 8
                elseif leftPressed then
                    current_item.cur_idx = current_item.cur_idx - 1
                    if current_item.cur_idx < 1 then current_item.cur_idx = #current_item.choices end
                    execute_item_action(current_item, current_item.choices[current_item.cur_idx])
                    menu_cooldown = 8
                end
            end

            if (p & A_BUTTON) ~= 0 then
                if current_item.type == "toggle" then
                    execute_item_action(current_item)
                end
            end
        end
    end

    if (p & B_BUTTON) ~= 0 then 
        if menu_level == 2 then
            menu_level = 1
            play_menu_sound(s_select)
        else
            menu_state = "closed"
            menu_level = 1
        end
    end
end

local function on_mario_update_menu(m)
    if m.playerIndex ~= 0 then return end
    
    if menu_state == "closed" then 
        if m.action == ACT_WAITING_FOR_DIALOG then set_mario_action(m, ACT_IDLE, 0) end 
        sync_cycles()
        return 
    end

    if m.action ~= ACT_WAITING_FOR_DIALOG then set_mario_action(m, ACT_WAITING_FOR_DIALOG, 0) end
    local p = m.controller.buttonPressed
    
    if menu_state ~= "ready" then return end
    handle_menu_navigation(m, p)
end

-------------------------
--- RENDER DEL MENÚ   ---
-------------------------

local function draw_menu_background(x, y, w, h)
    local bg_radius = menu_corner_radius * s_lerp

    djui_hud_set_color(11, 14, 26, 235 * a_lerp) 
    draw_rounded_rect(x, y, w, h, bg_radius)

    for _, p in ipairs(parts) do
        p.y = p.y - p.s 
        if p.y < 0 then p.y = 100; p.x = math.random(100) end
        local p_alpha = (40 + 90 * ((math.sin(t_c * 1.5 + p.x) + 1) / 2)) * s_lerp * a_lerp
        djui_hud_set_color(m_r, m_g, m_b, p_alpha * 0.5)
        djui_hud_render_rect(x + (p.x / 100) * w, y + (p.y / 100) * h, p.z * s_lerp, p.z * s_lerp)
    end

    djui_hud_set_color(m_r, m_g, m_b, 25 * a_lerp)
    local wave_segments = 20
    local wave_w = w - (bg_radius * 2)
    local segment_w = wave_w / wave_segments
    for i = 0, wave_segments - 1 do
        local wave_h = 18 * math.sin(t_c * 2 + i * 0.6) * s_lerp
        djui_hud_render_rect(x + bg_radius + (i * segment_w), y + h - (35 * s_lerp) + wave_h, segment_w + 1.2, 35 * s_lerp - wave_h)
    end

    local p_g = (math.sin(t_c * 2.5) + 1) / 2
    djui_hud_set_color(m_r, m_g, m_b, (170 + 85 * p_g) * a_lerp)
    draw_rounded_rect(x + bg_radius, y, w - (bg_radius * 2), 4 * s_lerp, 2 * s_lerp) 
    draw_rounded_rect(x + bg_radius, y + h - 4 * s_lerp, w - (bg_radius * 2), 4 * s_lerp, 2 * s_lerp)
end

local function draw_dashboard(x, y, w, h, f_a)
    local d_title = _T("menu_dashboard_title")
    local inner_radius = menu_corner_radius * 0.7 * s_lerp

    local title_x = x + (w / 2) - (djui_hud_measure_text(d_title) * 0.5 * s_lerp)
    draw_shadow_text(d_title, title_x, y + 10 * s_lerp, 1 * s_lerp, 255, 255, 255, 255 * f_a)

    djui_hud_set_color(m_r, m_g, m_b, 100 * f_a) 
    draw_rounded_rect(x + 30 * s_lerp, y + 45 * s_lerp, w - 60 * s_lerp, 2 * s_lerp, 1 * s_lerp)

    local b_w, b_h = (w / 2) - 40 * s_lerp, (h / 2) - 50 * s_lerp
    local start_x, start_y = x + 25 * s_lerp, y + 60 * s_lerp

    for i, t in ipairs(tabs) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local bx = start_x + col * (b_w + 30 * s_lerp)
        local by = start_y + row * (b_h + 20 * s_lerp)

        if i == sel_dash then
            a_dash_cursor_x = lerp(a_dash_cursor_x, bx, 0.2)
            a_dash_cursor_y = lerp(a_dash_cursor_y, by, 0.2)
            
            local pulse = (math.sin(t_c * 3) + 1) / 2
            djui_hud_set_color(m_r, m_g, m_b, (60 + 30 * pulse) * f_a)
            draw_rounded_rect(a_dash_cursor_x, a_dash_cursor_y, b_w, b_h, inner_radius)
            djui_hud_set_color(m_r, m_g, m_b, 255 * f_a)
            draw_rounded_rect(a_dash_cursor_x, a_dash_cursor_y + inner_radius, 4 * s_lerp, b_h - (inner_radius * 2), 2 * s_lerp)
        else
            djui_hud_set_color(m_r, m_g, m_b, 20 * f_a)
            draw_rounded_rect(bx, by, b_w, b_h, inner_radius)
        end

        local txt_tab = _T(t.n_key)
        local text_x = bx + (b_w / 2) - (djui_hud_measure_text(txt_tab) * 0.4 * s_lerp)
        local text_y = by + (b_h / 2) - 10 * s_lerp
        
        if i == sel_dash then
            draw_wavy_marquee_text(txt_tab, text_x, text_y, 1 * s_lerp, m_r, m_g, m_b, 255 * f_a * (lang_text_alpha / 255))
        else
            draw_shadow_text(txt_tab, text_x, text_y, 1 * s_lerp, 255, 255, 255, 150 * f_a * (lang_text_alpha / 255))
        end
    end
end

local function draw_submenu(x, y, w, h, f_a)
    local current_tab = tabs[sel_dash]
    local itms = current_tab.items
    local inner_radius = menu_corner_radius * 0.7 * s_lerp
    local btn_radius = menu_corner_radius * 0.5 * s_lerp
    local txt_alpha = f_a * (lang_text_alpha / 255)
    
    djui_hud_set_color(m_r, m_g, m_b, 230 * f_a)
    draw_rounded_rect(x + 12 * s_lerp, y + 45 * s_lerp, w - 24 * s_lerp, 3 * s_lerp, 1.5 * s_lerp)
    
    local txt_back = _T("menu_back")
    draw_shadow_text(txt_back, x + 15 * s_lerp, y + 15 * s_lerp, 0.6 * s_lerp, 255, 255, 255, 255 * txt_alpha)
    
    local txt_title = _T(current_tab.n_key)
    local title_w = djui_hud_measure_text(txt_title) * 0.5 * s_lerp
    draw_shadow_text(txt_title, x + (w / 2) - title_w, y + 15 * s_lerp, 1 * s_lerp, 255, 255, 255, 255 * txt_alpha)

    a_scroll = lerp(a_scroll, s_off, 0.18)
    local i_st = y + 66 * s_lerp
    a_item = lerp(a_item, i_st + ((sel_sub - 1 - a_scroll) * 56 * s_lerp), 0.22)

    djui_hud_set_color(m_r, m_g, m_b, 35 * f_a) 
    draw_rounded_rect(x + 15 * s_lerp, a_item, w - 30 * s_lerp, 50 * s_lerp, inner_radius)
    djui_hud_set_color(m_r, m_g, m_b, 240 * f_a) 
    draw_rounded_rect(x + 15 * s_lerp, a_item + inner_radius, 4 * s_lerp, 50 * s_lerp - (inner_radius * 2), 2 * s_lerp)

    for i = 1, #itms do
        local r_i = i - a_scroll
        if r_i > 0 and r_i <= 5 then
            local iy = i_st + ((r_i - 1) * 56 * s_lerp)
            if iy > i_st - 10 and iy < y + h - 65 * s_lerp then
                local txt_item_name = _T(itms[i].n_key)
                local text_x = x + 35 * s_lerp
                local text_y = iy + 6 * s_lerp
                local r_val = (i == sel_sub) and 255 or 200
                
                -- El título del item SÍ lleva efecto Wavy cuando se selecciona
                if i == sel_sub then
                    draw_wavy_text(txt_item_name, text_x, text_y, 0.8 * s_lerp, r_val, r_val, r_val, 255 * txt_alpha)
                else
                    draw_shadow_text(txt_item_name, text_x, text_y, 0.8 * s_lerp, r_val, r_val, r_val, 255 * txt_alpha)
                end
                
                djui_hud_set_color(160, 185, 225, (i == sel_sub and 220 or 140) * txt_alpha)
                djui_hud_print_text(_T(itms[i].d_key), x + 35 * s_lerp, iy + 28 * s_lerp, 0.5 * s_lerp)

                if itms[i].type == "toggle" then
                    local status_on = get_item_status(itms[i])
                    local bx = x + w - 95 * s_lerp
                    local by_btn = iy + 12 * s_lerp
                    local bw_btn = 65 * s_lerp
                    local bh_btn = 24 * s_lerp
                    local txt_status = status_on and _T("status_on") or _T("status_off")

                    if status_on then 
                        djui_hud_set_color(22, 64, 44, 180 * f_a)
                        draw_rounded_rect(bx, by_btn, bw_btn, bh_btn, btn_radius)
                        draw_shadow_text(txt_status, bx + (bw_btn / 2) - (djui_hud_measure_text(txt_status) * 0.35 * s_lerp), by_btn + 0 * s_lerp, 0.7 * s_lerp, 50, 255, 150, 240 * txt_alpha)
                    else 
                        djui_hud_set_color(64, 24, 34, 180 * f_a)
                        draw_rounded_rect(bx, by_btn, bw_btn, bh_btn, btn_radius)
                        draw_shadow_text(txt_status, bx + (bw_btn / 2) - (djui_hud_measure_text(txt_status) * 0.35 * s_lerp), by_btn + 0 * s_lerp, 0.7 * s_lerp, 255, 50, 80, 240 * txt_alpha)
                    end
                elseif itms[i].type == "cycle" then
                    local choice = itms[i].choices[itms[i].cur_idx]
                    local txt_choice = "< " .. _T(choice.n_key) .. " >"
                    local ch_scale = 0.7 * s_lerp
                    local ch_w = djui_hud_measure_text(txt_choice) * ch_scale
                    local bx = x + w - ch_w - 40 * s_lerp
                    local by = iy + 12 * s_lerp
                    
                    -- El selector lateral NO lleva Wavy, se dibuja plano con sombra para soportar códigos de color nativos
                    if i == sel_sub then
                        draw_shadow_text(txt_choice, bx, by, ch_scale, 255, 255, 255, 255 * txt_alpha)
                    else
                        draw_shadow_text(txt_choice, bx, by, ch_scale, 200, 200, 200, 200 * txt_alpha)
                    end
                end
            end
        end
    end

    if #itms > 4 then
        local sb_h = (4 / #itms) * (h - 145 * s_lerp)
        djui_hud_set_color(24, 28, 48, 200 * f_a) 
        draw_rounded_rect(x + w - 14 * s_lerp, i_st, 4 * s_lerp, h - 145 * s_lerp, 2 * s_lerp)
        djui_hud_set_color(m_r, m_g, m_b, 255 * f_a) 
        draw_rounded_rect(x + w - 14 * s_lerp, i_st + (a_scroll / (#itms - 4)) * (h - 145 * s_lerp - sb_h), 4 * s_lerp, sb_h, 2 * s_lerp)
    end
end

local function on_hud_render_menu()
    local m = gMarioStates[0]
    if not m or not m.marioObj then return end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_ALIASED)

    t_c = t_c + 0.04
    local sw = djui_hud_get_screen_width()
    local sh = djui_hud_get_screen_height()

    s_lerp = lerp(s_lerp, (menu_state ~= "closed") and 1 or 0, 0.14)
    a_lerp = lerp(a_lerp, (menu_state ~= "closed") and 1 or 0, 0.11)

    dash_alpha = lerp(dash_alpha, (menu_level == 1) and 1 or 0, 0.15)
    sub_alpha = lerp(sub_alpha, (menu_level == 2) and 1 or 0, 0.15)

    if menu_state == "closed" then
        fade_alpha = 0
        fake_loading_frame = 0
    elseif menu_state == "loading" then
        fake_loading_frame = fake_loading_frame + 1
        if fake_loading_frame % 45 < 15 then loading_dots = "."
        elseif fake_loading_frame % 45 < 30 then loading_dots = ".."
        else loading_dots = "..." end
        if fake_loading_frame > 60 then 
            menu_state = "ready"
            fake_loading_frame = 0 
        end
    elseif menu_state == "ready" then
        fade_alpha = lerp(fade_alpha, 1, 0.12)
    end

    if s_lerp < 0.01 then return end

    local w, h = 560 * s_lerp, 400 * s_lerp
    local x, y = (sw - w) / 2, (sh - h) / 2

    djui_hud_set_color(4, 6, 14, 130 * a_lerp) 
    djui_hud_render_rect(0, 0, sw, sh)
    
    draw_menu_background(x, y, w, h)

    if menu_state == "loading" then
        local txt_load = _T("loading") .. loading_dots
        draw_shadow_text(txt_load, x + (w / 2) - (djui_hud_measure_text(txt_load) * 0.7 * s_lerp), y + (h / 2) - 10 * s_lerp, 1.4 * s_lerp, 255, 255, 255, 255 * a_lerp)
    end

    local f_a = a_lerp * fade_alpha
    if f_a > 0.01 then
        if dash_alpha > 0.01 then
            draw_dashboard(x, y, w, h, f_a * dash_alpha)
        end
        
        if sub_alpha > 0.01 then
            draw_submenu(x, y, w, h, f_a * sub_alpha)
        end

        local txt_footer = _T("footer")
        draw_shadow_text(txt_footer, x + (w / 2) - (djui_hud_measure_text(txt_footer) * 0.25 * s_lerp), y + h - 20 * s_lerp, 0.5 * s_lerp, 140, 170, 210, 190 * f_a)
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render_menu)
hook_event(HOOK_MARIO_UPDATE, on_mario_update_menu)
