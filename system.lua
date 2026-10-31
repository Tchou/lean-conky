require("layout")

function uname(icon)
    local res = label("1:1", icon,
        "${no_update $sysname $nodename $kernel $machine}",
        "")
    return res
end

function uptime()
    local res = label("1/2:1", "", "Uptime: ", "${uptime}")
    return res
end

function cpufreq(total)
    total = math.max(1, total or 1)
    local res = ""
    for i = 0, total - 1 do
        local b = i & 1
        local col = "1/2:1"
        local endl = ""
        if b == 1 then
            endl = "\n"
            col = "1/2:2"
        end
        res = res .. label(col, "", "Core " .. tostring(i) .. ":",
            "${freq " .. tostring(i + 1) .. "} MHz") .. endl
    end
    return res
end

function gen_usage(lab, prefix, icon, val)
    local res = label("2/3:1", icon, lab .. " usage: ", val)
        .. bar("2/3:2", prefix .. "bar")
    return res
end

function mem_usage(lab, prefix, icon)
    local t = "$" .. prefix .. "/" .. "$" .. prefix .. "max"
        .. " - $" .. prefix .. "perc%"
    return gen_usage(lab, prefix, icon, t)
end

function ram_usage()
    return mem_usage("Ram", "mem", "")
end

function swap_usage()
    return mem_usage("Swap", "swap", "")
end

function cpu_usage()
    return gen_usage("CPU", "cpu", "", "$cpu%")
end
