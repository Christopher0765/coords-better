if unsupported then return end

local lang_list = "\\#2BC3FF\\[en|es|fr]\\#DCDCDC\\"

function trans(id, format1, format2)
    local text = _T and _T(id) or id
    return format1 and string.format(text, format1, format2) or text
end

constants = {
    CP_VERSION_MAJOR = CP_VERSION_MAJOR,
    CP_VERSION_MINOR = CP_VERSION_MINOR,
    CP_VERSION_PATCH = CP_VERSION_PATCH,
    CP_VERSION = CP_VERSION
}

CP_VERSION_MAJOR = 1
CP_VERSION_MINOR = 5
CP_VERSION_PATCH = 0
CP_VERSION = math.tointeger(string.format("%d%d%d", CP_VERSION_MAJOR, CP_VERSION_MINOR, CP_VERSION_PATCH))

hook_mod_menu_text(string.format("Version %d.%d.%d", CP_VERSION_MAJOR, CP_VERSION_MINOR, CP_VERSION_PATCH))
