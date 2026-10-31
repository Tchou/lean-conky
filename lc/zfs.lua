local utils = require("lc.utils")
local layout = require("lc.layout")
local M = {}

local function zfs_vol_info(mount_point)
    local cmdline = "zfs list -p -H -t filesystem  -o name,used,avail '" ..
        mount_point ..
        "' 2>/dev/null"
    local lines = utils.run_cached(120, cmdline, "\t")
    if #lines ~= 1 or #lines[1] ~= 3 then
        return "?", 0, 0
    else
        return lines[1][1], tonumber(lines[1][2]), tonumber(lines[1][3])
    end
end

local function norm_(n)
    if n ~= n or n == math.huge or -n == math.huge then
        return 0.0
    end
    return n
end

---The type of a table containing information about a zfs mount point
---@class ZfsInfo
---@field used number space used by the volume on its pool
---@field total number total space on the pool
---@field pool_name string name of the pool

---Return space usage information for a given zfs mount point
---If the mount_point is invalid, the pool_name is "?" and both sizes are 0
---@param mount_point string the mount point to query
---@return ZfsInfo
function M.info(mount_point)
    local name, used, _ = zfs_vol_info(mount_point)
    local pool = utils.split(name, "/")[1]
    local pool_name, pool_used, pool_avail = zfs_vol_info(pool)
    local total = pool_used + pool_avail
    return {
        used = used,
        total = total,
        pool_name = pool_name,
    }
end

---Print the usage of the given mount point
---@param mp string
---@param lab string
---@param icon string
---@return string
function M.usage(icon, lab, mp)
    local infos = M.info(mp)
    local ratio = norm_(math.floor(100 * infos.used / infos.total))

    local text = utils.format_bin(infos.used) .. "/" ..
        utils.format_bin(infos.total)
        .. " -" .. utils.format_perc(ratio) .. "%"

    local res = layout.label(icon, lab .. ":", text, "2/3:1")
    res = res .. layout.bar(ratio, "2/3:2")
    return res
end

return M
