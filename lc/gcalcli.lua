local utils = require("lc.utils")
local layout = require("lc.layout")
local M = {}

local function mk_date(day_t, time_t)
    local res = {}
    res["year"] = tonumber(day_t[1])
    res["month"] = tonumber(day_t[2])
    res["day"] = tonumber(day_t[3])
    res["hour"] = tonumber(time_t[1]) or 0
    res["min"] = tonumber(time_t[2]) or 0
    res["sec"] = 0
    return res
end
---Returns a pretty printed version of the google calendars
---given as argument. The gcalcli command is only called every delay seconds
---@param delay string|number number of seconds to wait between calls to gcalcli
---@param calendars table<string,string> a table mapping each calendar name to a display color
---@return string[]|string
function M.get(delay, calendars)
    local ctime = os.time()
    local d = tonumber(delay) or 120

    local output = {}
    local cal_options = ""
    for cal, _ in pairs(calendars) do
        cal_options = cal_options .. "--calendar '" .. cal .. "' "
    end
    local cmdline = "gcalcli " .. cal_options .. " agenda now 'now + 7 days' --tsv --details calendar"
    local lines = utils.run_cached(d, cmdline, "\t")
    if #lines == 0 or lines[1][1] == "" then
        return layout.text("Loading calendars …", "c", "1:1")
    end
    local current_day = ""
    for i = 2, #lines do
        local line = lines[i]
        local day_start_t = utils.split(line[1], "-")
        local time_start_t = utils.split(line[2], ":")
        local day_end_t = utils.split(line[3], "-")
        local time_end_t = utils.split(line[4], ":")
        local desc = line[5]
        local cname = line[6]
        local color = calendars[cname]
        local date_start = mk_date(day_start_t, time_start_t)
        local date_end = mk_date(day_end_t, time_end_t)
        local ts_start = os.time(date_start)
        local ts_end = os.time(date_end)
        local display_day = os.date("%a %d %b", ts_start)

        if display_day ~= current_day then
            -- a new day
            table.insert(output, layout.label("\u{f073}", display_day, "", "1/3:1"))
            current_day = display_day
        end
        local time_str = ""
        if line[2] == "" then
            -- whole day event
            time_str = string.rep(" ", 5, "")
        else
            time_str = string.format("%2s:%02d", tostring(date_start["hour"]), date_start["min"])
        end
        local multi_day = " "
        local day_s = 24 * 3600
        local ev_d = ts_end - ts_start
        if ev_d >= 2 * day_s then
            multi_day = "\u{f1073}"
        elseif ev_d >= day_s then
            multi_day = "\u{f00ee}"
        end
        local ongoing = "    "
        if ctime >= ts_start and ctime <= ts_end then
            ongoing = "\u{f444}   "
        end
        local l = layout.text(ongoing .. time_str .. "  " .. multi_day .. "  " .. desc,
            "l", "1:1", color)
        table.insert(output, l)
    end
    return output
end

return M
