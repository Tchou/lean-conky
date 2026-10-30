require("layout")
require("utils")

local function ifup(iface)
    return conky_parse("${if_up " .. iface .. "}x${endif}") == "x"
end

local function inline_icon(ico)
    return font_(RES.icon_font, RES.icon_size) .. ico
end
local function pad_right(s, len)
    local n = string.len(s)
    local d = len - n
    return s .. string.rep(" ", d)
end
function interface(iface)
    if not ifup(iface) then
        return ""
    end
    local name = iface
    local icon = ""
    local ssid = conky_parse("${wireless_essid " .. iface .. "}")
    if ssid ~= "" then
        name = ssid
        icon = ""
    end
    name = pad_right(name, 12)
    local res = label("1/2:1", icon, name .. inline_icon(""), "${downspeed " .. iface .. "}")
    res = res .. label("1/2:2", "", pad_right("", 12) .. inline_icon(""), "${upspeed " .. iface .. "}")
    return res
end

function interfaces(tab)
    local res = ""
    for i, iface in ipairs(tab) do
        if res ~= "" then
            res = res .. "\n"
        end
        res = res .. interface(iface)
    end
    return res
end
