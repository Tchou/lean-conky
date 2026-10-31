require("utils")
require("layout")

ZFS = { __ = 0 }

function zfs_vol_info(mount_point)
    local file =
        io.popen("zfs list -p -H -t filesystem  -o name,used,avail '" .. mount_point .. "' 2>/dev/null")
    io.input(file)
    local name = nil
    local used = nil
    local avail = nil
    while true do
        local line = io.read("l")
        if line == nil then
            break
        end
        name, used, avail = string.match(line, "^([^\t]*)\t([0-9]*)\t([0-9]*)$")
    end
    io.input()
    io.close(file)
    return name, used, avail
end

function zfs_info(mount_point)
    local ctime = os.time()
    local delay = 120
    if ZFS[mount_point] == nil or (ctime - delay) >= ZFS["__"] then
        local name, used, avail = zfs_vol_info(mount_point)
        if used ~= nil and avail ~= nil and name ~= nil then
            local pool = split(name, "/")[1]
            local pool_name, pool_used, pool_avail = zfs_vol_info(pool)
            local total = pool_used + pool_avail
            local infos = {}
            infos["used_gb"] = format_gib(used)
            infos["total_gb"] = format_gib(total)
            infos["pool_name"] = pool_name
            infos["ratio"] = math.floor(100 * used / total)
            ZFS[mount_point] = infos
        end
    end
    return ZFS[mount_point]
end

function zfs_total(mp)
    return (zfs_info(mp))["total_gb"]
end

function zfs_pool(mp)
    return (zfs_info(mp))["pool_name"]
end

function zfs_used(mp)
    return (zfs_info(mp))["used_gb"]
end

function zfs_percent(mp)
    return (zfs_info(mp))["ratio"]
end

function zfs_format(mp)
    local infos = zfs_info(mp)
    return infos["used_gb"] .. "/" .. infos["total_gb"]
    .. " -" .. format_perc(infos["ratio"]) .. "%"
end

function zfs_usage(icon, lab, mp)
    local res = label("2/3:1", icon, lab .. ":", zfs_format(mp))
    res = res .. custom_bar("2/3:2", zfs_percent(mp))
    return res
end
