-- lang.lua
_G.LANG = {
    current = "es", -- Idioma por defecto al iniciar por primera vez

    es = {
        -- Pestañas del menú
        tab_coords           = "Coords +",
        tab_colors           = "Color del HUD",
        tab_style            = "Estilo Del Menú",
        tab_lang             = "Idiomas",
        menu_back            = "[B] Atrás",
        menu_dashboard_title = "PANEL DE CONTROL",

        -- Items de Configuración
        xyz_name  = "Visualizar XYZ",
        xyz_desc  = "Muestra u oculta tu posición exacta en tiempo real.",
        spd_name  = "Visualizar Velocidad",
        spd_desc  = "Muestra u oculta los vectores de movimiento actuales.",
        anim_name = "Efectos Visuales (HUD)",
        anim_desc = "Activa animaciones fluidas de entrada y salida para el HUD.",

        -- Opciones de colores
        h_yel_name = "Amarillo Eléctrico", h_yel_desc = "Tono amarillo brillante y clásico al texto.",
        h_red_name = "Rojo Carmesí",      h_red_desc = "Cambia el texto a un tono rojo intenso y agresivo.",
        h_grn_name = "Verde Esmeralda",   h_grn_desc = "Color verde vibrante estilo retro.",
        h_blu_name = "Azul Zafiro",       h_blu_desc = "Color azul claro y limpio para la interfaz.",
        h_wht_name = "Blanco Puro",       h_wht_desc = "Color blanco minimalista y nítido para máxima lectura.",

        m_cyn_name = "\\#00ff00\\Coords+", m_cyn_desc = "Bordes y efectos a un tono cyan cibernético.",
        m_red_name = "Rojo Fuego",        m_red_desc = "Estética del menú con detalles en rojo vivo.",
        m_grn_name = "Verde Matrix",      m_grn_desc = "Estilo verde digital y limpio a los bordes.",
        m_pur_name = "Morado Premium",    m_pur_desc = "Aspecto exclusivo y elegante en tono violeta.",
        m_gld_name = "Dorado Midas",      m_gld_desc = "Acabado dorado digno de una edición premium.",

        -- Opciones de Idioma
        lang_es_name = "Español",           lang_es_desc = "Cambia el texto del menú e interfaz al Español.",
        lang_en_name = "Inglés (English)",  lang_en_desc = "Cambia el texto del menú e interfaz al Inglés.",
        lang_fr_name = "Francés (Français)",lang_fr_desc = "Cambia el texto del menú e interfaz al Francés.",

        -- Sistema y UI
        status_on  = "On",
        status_off = "Off",
        loading    = "Cargando",
        footer     = "D-PAD: Navegar  |  A: Elegir  |  B: Cerrar",
        
        -- Notificaciones y Errores
        err_cmd = "\\#ff3333\\Error: Comando incorrecto.",
        err_s = "\\#ff3333\\Error: Usa /s on, /s off o solo /s",
        err_c = "\\#ff3333\\Error: Usa /c on, /c off o solo /c",
        err_a = "\\#ff3333\\Error: Usa /a on, /a off o solo /a",
        err_rgb = "\\#ff3333\\Error: Usa /cc R G B (Ej: /cc 255 255 30)",
        err_lang = "\\#ff3333\\Error: Usa /lang es, /lang en o /lang fr",
        on_c = "Coords: \\#00ff00\\Sí",
        off_c = "Coords: \\#ff0000\\No",
        on_s = "Speed: \\#00ff00\\Sí",
        off_s = "Speed: \\#ff0000\\No",
        on_a = "Animaciones: \\#00ff00\\Sí",
        off_a = "Animaciones: \\#ff0000\\No",
        notify_color = "Color:",
        notify_menu = "Color Menú: ",
        notify_lang = "Idioma cambiado a: Español",
        
        -- Descripciones de Comandos
        a_cmd_desc = "\\#2BC3FF\\[on|off] \\#ffffff\\Activa las animaciones",
        c_cmd_desc = "\\#2BC3FF\\[on|off] \\#ffffff\\Activa las coordenadas",
        s_cmd_desc = "\\#2BC3FF\\[on|off] \\#ffffff\\Activa la velocidad",
        cpmenu_cmd_desc = "Abre el menú de \\#ffff1e\\Coords \\#00ff00\\+ \\#00ffff\\DX",
        lang_cmd_desc = "\\#2BC3FF\\[es|en|fr] \\#ffffff\\Cambia el idioma del Mod rápidamente",
        cc_cmd_desc = "\\#2BC3FF\\[R G B] \\#dcdcdc\\Cambia el color del texto del HUD dinámicamente",
        
        -- Hud
        spd_x = "Vel X: ",
        spd_y = "Vel Y: ",
        spd_z = "Vel Z: ",

        -- Etiquetas de nombre
        tag_author = "[Autor de CB+] ",
        tag_lead_dev = "[Desarrollador Principal]",
        tag_og_author = "[Autor del Flood Original, Testeador]",
        tag_fe_author = "[Autor de FE, Desarrollador]",
        tag_dev = "[Desarrollador]",
        tag_dev_short = "[Dev]",
        tag_flood_porter = "[Porter de Flood +]",
        tag_flood_porter_contributor_tester = "[Porter de Flood +, Contribuidor, Testeador]",
        tag_flood_porter_composer = "[Porter de Flood +, Compositor]",
        tag_porter = "[Porter]",
        tag_composer_tester = "[Compositor, Testeador]",
        tag_tester = "[Testeador]",
        tag_tester_special_thanks = "[Testeador, Gracias Especiales]",
        tag_contributor = "[Contribuidor]",
        tag_contributor_special_thanks = "[Contribuidor, Gracias Especiales]",
        tag_special_thanks = "[Gracias Especiales]",
        tag_normal = "[Normal]",
        tag_translator = "[Traductor]",

        -- Nuevos textos faltantes
        h_col_desc       = "Cambia el color global de los textos del HUD.",
        m_col_desc       = "Modifica los tonos y el estilo visual del menú.",
        menu_volume_name = "Volumen del Menú",
        menu_volume_desc = "Ajusta el volumen de los efectos de sonido del menú.",
        lang_desc        = "Selecciona tu idioma preferido para la interfaz.",
        notify_hud       = "Color HUD: "
    },

    en = {
        -- Menu Tabs
        tab_coords = "Coords +",
        tab_colors = "HUD Color",
        tab_style  = "Menu Style",
        tab_lang   = "Languages",

        -- Configuration Items
        xyz_name = "Show XYZ",
        xyz_desc = "Shows or hides your exact position in real time.",
        spd_name = "Show Speed",
        spd_desc = "Shows or hides the current movement vectors.",
        anim_name = "Visual Effects (HUD)",
        anim_desc = "Enables smooth fade-in and fade-out animations for the HUD.",

        -- Color options
        h_yel_name = "Electric Yellow",   h_yel_desc = "Bright and classic yellow tone for the text.",
        h_red_name = "Crimson Red",       h_red_desc = "Changes the text to an intense and aggressive red tone.",
        h_grn_name = "Emerald Green",     h_grn_desc = "Vibrant green color with a retro style.",
        h_blu_name = "Sapphire Blue",     h_blu_desc = "Clean and light blue color for the interface.",
        h_wht_name = "Pure White",        h_wht_desc = "Crisp and minimalist white color for maximum readability.",

        m_cyn_name = "\\#00ff00\\Coords+", m_cyn_desc = "Borders and effects in a cybernetic cyan tone.",
        m_red_name = "Fire Red",          m_red_desc = "Menu aesthetics with vivid red details.",
        m_grn_name = "Matrix Green",      m_grn_desc = "Clean digital green style for the borders.",
        m_pur_name = "Premium Purple",    m_pur_desc = "Exclusive and elegant look in a violet tone.",
        m_gld_name = "Midas Gold",        m_gld_desc = "Golden finish worthy of a premium edition.",

        -- Language Options
        lang_es_name = "Spanish (Español)",  lang_es_desc = "Changes the menu and interface text to Spanish.",
        lang_en_name = "English",            lang_en_desc = "Changes the menu and interface text to English.",
        lang_fr_name = "French (Français)",  lang_fr_desc = "Changes the menu and interface text to French.",

        -- System & UI
        status_on  = "On",
        status_off = "Off",
        loading    = "Loading",
        footer     = "D-PAD: Navigate  |  A: Choose  |  B: Close",
        
        -- Notifications & Errors
        err_cmd = "\\#ff3333\\Error: Incorrect command.",
        err_s = "\\#ff3333\\Error: Use /s on, /s off or just /s",
        err_c = "\\#ff3333\\Error: Use /c on, /c off or just /c",
        err_a = "\\#ff3333\\Error: Use /a on, /a off or just /a",
        err_rgb = "\\#ff3333\\Error: Use /cc R G B (Ex: /cc 255 255 30)",
        err_lang = "\\#ff3333\\Error: Use /lang es, /lang en or /lang fr",
        on_c = "Coords: \\#00ff00\\Yes",
        off_c = "Coords: \\#ff0000\\No",
        on_s = "Speed: \\#00ff00\\Yes",
        off_s = "Speed: \\#ff0000\\No",
        on_a = "Animations: \\#00ff00\\Yes",
        off_a = "Animations: \\#ff0000\\No",
        notify_color = "Color:",
        notify_menu = "Menu Color: ",
        notify_lang = "Language changed to: English",
        lib_warning = "\\#ffff1e\\[Coords +]\\#dcdcdc\\ Optional recommendation: Install '\\#ffa700\\Coords Library\\#dcdcdc\\' to use addons.",
        
        -- Commands Descriptions
        a_cmd_desc = "\\#2BC3FF\\[on|off] \\#dcdcdc\\Enables animations",
        c_cmd_desc = "\\#2BC3FF\\[on|off] \\#dcdcdc\\Enables coordinates",
        s_cmd_desc = "\\#2BC3FF\\[on|off] \\#dcdcdc\\Enables speed",
        cpmenu_cmd_desc = "Opens the \\#ffff1e\\Coords \\#00ff00\\+ \\#00ffff\\DX menu",
        lang_cmd_desc = "\\#2BC3FF\\[es|en|fr] \\#dcdcdc\\Quickly changes the Mod language",
        cc_cmd_desc = "\\#2BC3FF\\[R G B] \\#dcdcdc\\Dynamically changes the HUD text color",

        -- Hud
        spd_x = "Spd X: ",
        spd_y = "Spd Y: ",
        spd_z = "Spd Z: ",

        -- Name tags
        tag_author = "[CB+ Author] ",
        tag_lead_dev = "[Lead Developer]",
        tag_og_author = "[Original Flood Author, Tester]",
        tag_fe_author = "[FE Author, Developer]",
        tag_dev = "[Developer]",
        tag_dev_short = "[Dev]",
        tag_flood_porter = "[Flood + Porter]",
        tag_flood_porter_contributor_tester = "[Flood + Porter, Contributor, Tester]",
        tag_flood_porter_composer = "[Flood + Porter, Composer]",
        tag_porter = "[Porter]",
        tag_composer_tester = "[Composer, Tester]",
        tag_tester = "[Tester]",
        tag_tester_special_thanks = "[Tester, Special Thanks]",
        tag_contributor = "[Contributor]",
        tag_contributor_special_thanks = "[Contributor, Special Thanks]",
        tag_special_thanks = "[Special Thanks]",
        tag_normal = "[Normal]",
        tag_translator = "[Translator]"
    },
    
    fr = {
        -- Onglets du menu
        tab_coords = "Coords +",
        tab_colors = "Couleur du HUD",
        tab_style  = "Style de Menu",
        tab_lang   = "Langues",

        -- Éléments de Configuration
        xyz_name = "Afficher XYZ",
        xyz_desc = "Affiche ou masque votre position exacte en temps réel.",
        spd_name = "Afficher Vitesse",
        spd_desc = "Affiche ou masque les vecteurs de mouvement actuels.",
        anim_name = "Effets Visuels (HUD)",
        anim_desc = "Active les animations fluides d'entrée et de sortie pour le HUD.",

        -- Options de couleurs
        h_yel_name = "Jaune Électrique", h_yel_desc = "Ton jaune brillant et classique pour le texte.",
        h_red_name = "Rouge Cramoisi",    h_red_desc = "Change le texte en un ton rouge intense et agressif.",
        h_grn_name = "Vert Émeraude",     h_grn_desc = "Couleur verte vibrante au style rétro.",
        h_blu_name = "Bleu Saphir",       h_blu_desc = "Couleur bleu clair et propre pour l'interface.",
        h_wht_name = "Blanc Pur",         h_wht_desc = "Couleur blanche minimaliste et nette pour une lisibilité maximale.",

        m_cyn_name = "\\#00ff00\\Coords+", m_cyn_desc = "Bordures et effets dans un ton cyan cybernétique.",
        m_red_name = "Rouge Feu",         m_red_desc = "Esthétique du menu avec des détails rouge vif.",
        m_grn_name = "Vert Matrix",       m_grn_desc = "Style vert numérique et épuré pour les bordures.",
        m_pur_name = "Violet Premium",    m_pur_desc = "Aspect exclusif et élégant dans un ton violet.",
        m_gld_name = "Or Midas",          m_gld_desc = "Finition dorée digne d'une édition premium.",

        -- Options de Langue
        lang_es_name = "Espagnol (Español)", lang_es_desc = "Change le texte du menu et de l'interface en Espagnol.",
        lang_en_name = "Anglais (English)",  lang_en_desc = "Change le texte du menu et de l'interface en Anglais.",
        lang_fr_name = "Français",           lang_fr_desc = "Change le texte du menu et de l'interface en Français.",
        
        -- Système et UI
        status_on  = "On",
        status_off = "Off",
        loading    = "Chargement",
        footer     = "D-PAD: Naviguer  |  A: Choisir  |  B: Fermer",
        
        -- Notifications et Erreurs
        err_cmd = "\\#ff3333\\Erreur: Commande incorrecte.",
        err_s = "\\#ff3333\\Erreur: Utilisez /s on, /s off ou juste /s",
        err_c = "\\#ff3333\\Erreur: Utilisez /c on, /c off ou juste /c",
        err_a = "\\#ff3333\\Erreur: Utilisez /a on, /a off ou juste /a",
        err_rgb = "\\#ff3333\\Erreur: Utilisez /cc R G B (Ex: /cc 255 255 30)",
        err_lang = "\\#ff3333\\Erreur: Utilisez /lang es, /lang en ou /lang fr",
        on_c = "Coords: \\#00ff00\\Oui",
        off_c = "Coords: \\#ff0000\\Non",
        on_s = "Speed: \\#00ff00\\Oui",
        off_s = "Speed: \\#ff0000\\Non",
        on_a = "Animations: \\#00ff00\\Oui",
        off_a = "Animations: \\#ff0000\\Non",
        notify_color = "Couleur:",
        notify_menu = "Couleur Menu: ",
        notify_lang = "Langue changée en: Français",
        lib_warning = "\\#ffff1e\\[Coords +]\\#dcdcdc\\ Recommandation optionnelle: Installez '\\#ffa700\\Coords Library\\#dcdcdc\\' pour les addons.",
        
        -- Descriptions des Commandes
        a_cmd_desc = "\\#2BC3FF\\[on|off] \\#dcdcdc\\Active les animations",
        c_cmd_desc = "\\#2BC3FF\\[on|off] \\#dcdcdc\\Active les coordonnées",
        s_cmd_desc = "\\#2BC3FF\\[on|off] \\#dcdcdc\\Active la vitesse",
        cpmenu_cmd_desc = "Ouvre le menu de \\#ffff1e\\Coords \\#00ff00\\+ \\#00ffff\\DX",
        lang_cmd_desc = "\\#2BC3FF\\[es|en|fr] \\#dcdcdc\\Change rapidement la langue du Mod",
        cc_cmd_desc = "\\#2BC3FF\\[R G B] \\#dcdcdc\\Change dynamiquement la couleur du texte du HUD",

        -- Hud
        spd_x = "Vit X: ",
        spd_y = "Vit Y: ",
        spd_z = "Vit Z: ",

        -- Étiquettes de nom
        tag_author = "[Auteur de CB+] ",
        tag_lead_dev = "[Développeur Principal]",
        tag_og_author = "[Auteur Original de Flood, Testeur]",
        tag_fe_author = "[Auteur de FE, Développeur]",
        tag_dev = "[Développeur]",
        tag_dev_short = "[Dev]",
        tag_flood_porter = "[Porteur de Flood +]",
        tag_flood_porter_contributor_tester = "[Porteur de Flood +, Contributeur, Testeur]",
        tag_flood_porter_composer = "[Porteur de Flood +, Compositeur]",
        tag_porter = "[Porteur]",
        tag_composer_tester = "[Compositeur, Testeur]",
        tag_tester = "[Testeur]",
        tag_tester_special_thanks = "[Testeur, Remerciements Spéciaux]",
        tag_contributor = "[Contributeur]",
        tag_contributor_special_thanks = "[Contributeur, Remerciements Spéciaux]",
        tag_special_thanks = "[Remerciements Spéciaux]",
        tag_normal = "[Normal]",
        tag_translator = "[Traducteur]"
    }
}

function _T(key)
    if not _G.LANG then return key end
    local l = _G.LANG[_G.LANG.current]
    if l and l[key] then return l[key] end
    return key
end