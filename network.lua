require("layout")
require("utils")
require("res")

local function ifup(iface)
    return conky_parse("${if_up " .. iface .. "}x${endif}") == "x"
end

local function inline_icon(ico)
    return font_(RES.font, RES.size) .. color_(RES.icon_color) .. ico
end
local function pad_right(s, len)
    local n = string.len(s)
    local d = len - n
    return s .. string.rep(" ", d)
end
function interface(iface)
    if not ifup(iface) then
        return nil
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

function interfaces(tab, init)
    local t = {}
    for i, iface in ipairs(tab) do
        local ires = interface(iface)
        if ires ~= nil then
            table.insert(t, ires)
        end
    end
    local res = table.concat(t, "\n")
    if res ~= "" then
        res = init .. res
    end
    return res
end
