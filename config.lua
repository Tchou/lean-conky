require('layout')
require('system')
require('zfs')
require('network')
require('gcalcli')

function CONFIG()
    return {
        font = "HackNerdFontMono",
        size = 15,
        color = "#ffffff",
        -- icons
        icon_font = "Font Awesome 6 Free Solid:style=Regular",
        icon_size = 15,
        icon_color = "#EB6536",
        -- brands
        brand_font = "Font Awesome 6 Brands Regular:style=Regular",
        brand_size = 15,
        -- misc
        scale_factor = 2, -- if running under Xwayland + Gnome Wayland
        column_sep = 20,
        hr_width = 1,
        bar_height = 8
    }
end

function TEMPLATE()
    return {
        uname(""),
        hr(2),
        uptime(), "\n",
        cpufreq(8),
        ram_usage(), "\n",
        swap_usage(), "\n",
        cpu_usage(), "\n",
        label("1/2:1", "", "Processes:", "$processes"),
        label("1/2:2", "", "Running:", "$running_processes"),
        hr(2),
        zfs_usage("", "~", "/home/kim"), "\n",
        zfs_usage("", "Private", "/home/kim/Private"), "\n",
        zfs_usage("", "/", "/"), "\n",
        zfs_usage("", "Total", "rpool"), "\n",
        interfaces({ "eth0", "wlp2s0" }),
        hr(2),
        label("1/2:1", "", "Package ID 0:", "+${hwmon coretemp temp 1}°C"), "\n",
        label("1/2:1", "", "Core 0:", "+${hwmon coretemp temp 2}°C"),
        label("1/2:2", "", "Core 1:", "+${hwmon coretemp temp 3}°C"), "\n",
        label("1/2:1", "", "Core 2:", "+${hwmon coretemp temp 4}°C"),
        label("1/2:2", "", "Core 3:", "+${hwmon coretemp temp 5}°C"), "\n",
        label("1/2:1", "", "Fan 1:", "${hwmon dell_smm fan 1} RPM"),
        label("1/2:2", "", "Fan 2:", "${hwmon dell_smm fan 2} RPM"),
        hr(2),
        gcalcli(300, {
            ["kim@nguyen.vg"] = "#baffc9",
            ["LMF (public)"] = "#bae1ff",
            ["Office 365 Sync"] = "#ffffba",
        }
        )
    }
end
