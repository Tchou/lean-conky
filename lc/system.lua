local layout = require("lc.layout")
local M = {}
-- Key is the NAME field in /etc/os-release, used by conky
local DIST_ICONS = {
    ["Ubuntu"] = "\u{f0548}",
    ["Debian GNU/Linux"] = "\u{ebc5}",
    ["Fedora Linux"] = "\u{e7d9}",
    ["Arch Linux"] = "\u{ea98}",
    ["Manjaro Linux"] = "\u{f312}",
    ["Linux Mint"] = "\u{e924}",
    ["Pop!_OS"] = "\u{ec28}",
    ["CentOS Stream"] = "\u{e78a}",
    ["Rocky Linux"] = "\u{e891}",
    ["AlmaLinux"] = "\u{e8f3}",
    ["Alpine Linux"] = "\u{e713}",
    ["Kali GNU/Linux"] = "\u{e91e}",
    ["NixOS"] = "\u{e843}",
    ["Gentoo"] = "\u{e7e6}",
    ["Linux"] = "\u{e712}"
}

--- System information
--- @param icon? string the text to use as icon
--- @return string
function M.uname(icon)
    if icon == nil then
        local d = conky_parse("${distribution}")
        icon = DIST_ICONS[d] or DIST_ICONS["Linux"]
    end
    local res = layout.label(icon,
        "${no_update $sysname $nodename $kernel $machine}",
        "", "1:1")
    return res
end

--- System uptime, on the first half of the line
--- @return string
function M.uptime()
    local res = layout.label("\u{f1da}", "Uptime: ", "${uptime}", "1/2:1")
    return res
end

--- Frequency of each CPU core, two cores per line (even cores on the left half, odd ones on the right)
--- @param total integer? number of cores to display (at least 1, default 1)
--- @return string[]
function M.cpufreq(total)
    total = (total == nil and 1) or tonumber(total)
    total = math.max(1, total or 1)

    local function cell(i, col)
        return layout.label("\u{f4bc}",
            "Core " .. tostring(i) .. ":",
            "${freq " .. tostring(i + 1) .. "} MHz", col)
    end

    local res = {}
    for i = 0, total - 1, 2 do
        if i + 1 < total then
            res[#res + 1] =
                layout.row(cell(i, "1/2:1"),
                    cell(i + 1, "1/2:2"))
        else
            res[#res + 1] = cell(i, "1/2:1")
        end
    end
    return res
end

local function gen_usage(lab, prefix, icon, val)
    local res = layout.label(icon, lab .. " usage: ", val, "2/3:1")
        .. layout.builtin_bar(prefix .. "bar", "2/3:2")
    return res
end

local function mem_usage(lab, prefix, icon)
    local t = "$" .. prefix .. "/" .. "$" .. prefix .. "max"
        .. " - $" .. prefix .. "perc%"
    return gen_usage(lab, prefix, icon, t)
end

--- RAM usage: label with used/max/percentage, followed by a bar
--- @return string
function M.ram_usage()
    return mem_usage("Ram", "mem", "\u{efc5}")
end

--- Swap usage: label with used/max/percentage, followed by a bar
--- @return string
function M.swap_usage()
    return mem_usage("Swap", "swap", "\u{f1c0}")
end

--- Total CPU usage: label with percentage, followed by a bar
--- @return string
function M.cpu_usage()
    return gen_usage("CPU", "cpu", "\u{f201}", "$cpu%")
end

--- Number of processes (left half) and running processes (right half)
--- @return string
function M.ps()
    return layout.label("\u{f292}", "Processes:", "$processes", "1/2:1") ..
        layout.label("\u{f0493}", "Running:", "$running_processes", "1/2:2")
end

local SENSOR_INFO = {
    temp = { icon = "\u{f2c7}", unit = "+%s°C" },
    fan = { icon = "\u{efa7}", unit = "%s RPM" },
    unknown = { icon = "?", unit = "%s" }
}

--- Reading of a hwmon sensor, with an icon chosen from the sensor kind
--- @param column string column key (e.g. "1/2:1")
--- @param lab string text label
--- @param kind "temp"|"fan" sensor kind as understood by conky's hwmon ("temp", "fan", ...)
--- @param dev string|integer hwmon device (name or index)
--- @param index integer sensor number
--- @return string
function M.hwmon(column, lab, kind, dev, index)
    local info = SENSOR_INFO[kind] or SENSOR_INFO.unknown
    local data = ("${hwmon %s %s %.0f}"):format(dev, kind, index)
    data = info.unit:format(data)
    return layout.label(info.icon, lab, data, column)
end

return M
