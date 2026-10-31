local layout = require("lc.layout")
local M = {}

local function is_up(iface)
    return conky_parse("${if_up " .. iface .. "}x${endif}") == "x"
end

local function pad_right(s, len)
    local n = string.len(s)
    local d = len - n
    return s .. string.rep(" ", d)
end

local function interface(iface)
    if not is_up(iface) then
        return nil
    end
    local name = iface
    local icon = "\u{f0200}"
    local ssid = conky_parse("${wireless_essid " .. iface .. "}")
    if ssid ~= "" then
        name = ssid
        icon = "\u{f1eb}"
    end
    name = pad_right(name, 12)
    local res =
        layout.row(
            layout.label(icon, name .. "\u{f0ed}", "${downspeed " .. iface .. "}", "1/2:1"),
            layout.label("", pad_right("", 12) .. "\u{f0ee}", "${upspeed " .. iface .. "}", "1/2:2"))
    return res
end

---Returns display interfaces that are up from the given list
---If the resulting output is not empty, prepend the init string
---@param tab string[] a list of interface names (such as "eth0")
---@param init string a string to prepend if the output is not empty
---@return string[]
function M.interfaces(tab, init)
    local t = {}
    for _, iface in ipairs(tab) do
        local ires = interface(iface)
        if ires ~= nil then
            table.insert(t, ires)
        end
    end
    if #t ~= 0 then
        table.insert(t, 1, init)
    end
    return t
end

return M
