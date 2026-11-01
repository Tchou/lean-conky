local layout = require('lc.layout')
local row = layout.row
local hr = layout.hr
local M = {}

-- Import what is needed for the main template

local sys = require('lc.system')
local zfs = require('lc.zfs')
local net = require('lc.network')
local gcalcli = require('lc.gcalcli')

M.CONFIG = {
    font = "UbuntuMonoNerdFont:style=Regular",
    size = 18,
    color = "#ffffff",
    icon_color = "#EB6536",
    window_color = '#cd170026',
    -- misc
    scale_factor = 2, -- if running under Xwayland + Gnome Wayland
    column_sep = 20,
    hr_width = 1,
    bar_height = 8,
    line_offset = 0
}


function M.TEMPLATE()
    return {
        sys.uname(),
        hr(),
        sys.uptime(),
        sys.cpufreq(8),
        sys.ram_usage(),
        sys.swap_usage(),
        sys.cpu_usage(),
        sys.ps(),
        hr(),
        zfs.usage("\u{f02dc}", "~", "/home/kim"),
        zfs.usage("\u{f023}", "Vault", "/home/kim/Private"),
        zfs.usage("\u{f0a0}", "/", "/"),
        zfs.usage("\u{f200}", "Total", "rpool"),
        zfs.usage("\u{f140b}", "Boot", "/boot"),
        net.interfaces({ "eth0", "wlp2s0" }, hr()),
        hr(),
        sys.hwmon("1/2:1", "Package ID 0:", "temp", "coretemp", 1),
        row(sys.hwmon("1/2:1", "Core 0:", "temp", "coretemp", 2),
            sys.hwmon("1/2:2", "Core 1:", "temp", "coretemp", 3)),
        row(sys.hwmon("1/2:1", "Core 2:", "temp", "coretemp", 4),
            sys.hwmon("1/2:2", "Core 3:", "temp", "coretemp", 5)),
        row(sys.hwmon("1/2:1", "Fan 1:", "fan", "dell_smm", 1),
            sys.hwmon("1/2:2", "Fan 2:", "fan", "dell_smm", 2)),
        hr(),
        gcalcli.get(300, {
            ["kim@nguyen.vg"] = "#baffc9",
            ["LMF (public)"] = "#bae1ff",
            ["Office 365 Sync"] = "#ffffba",
        })
    }
end

return M
