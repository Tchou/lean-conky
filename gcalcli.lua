require("utils")
require("layout")


function mk_date(day_t, time_t)
    local res = {}
    res["year"] = tonumber(day_t[1])
    res["month"] = tonumber(day_t[2])
    res["day"] = tonumber(day_t[3])
    res["hour"] = tonumber(time_t[1]) or 0
    res["min"] = tonumber(time_t[2]) or 0
    res["sec"] = 0
    return res
end

function gcalcli(delay, calendars)
    local ctime = os.time()
    delay = tonumber(delay)

    local output = {}
    local cal_options = ""
    for cal, _ in pairs(calendars) do
        cal_options = cal_options .. "--calendar '" .. cal .. "' "
    end
    local cmdline = "gcalcli " .. cal_options .. " agenda now 'now + 7 days' --tsv --details calendar"
    --        local file = io.popen(cmdline)
    local cmd_out = conky_parse("${texeci " .. delay .. " " .. cmdline .. "}")
    if cmd_out == "" then
        return text("c", "1:1", "Loading calendars …")
    end
    local lines = split(cmd_out, "\n")
    local current_day = ""
    for i = 2, #lines do
        local line = lines[i]
        local tline = split(line, "\t")
        local day_start_t = split(tline[1], "-")
        local time_start_t = split(tline[2], ":")
        local day_end_t = split(tline[3], "-")
        local time_end_t = split(tline[4], ":")
        local desc = tline[5]
        local cname = tline[6]
        local color = calendars[cname]
        local date_start = mk_date(day_start_t, time_start_t)
        local date_end = mk_date(day_end_t, time_end_t)
        local ts_start = os.time(date_start)
        local ts_end = os.time(date_end)
        local display_day = os.date("%a %d %b", ts_start)

        if display_day ~= current_day then
            -- a new day
            table.insert(output, label("1/3:1", "", display_day, ""))
            current_day = display_day
        end
        local time_str = ""
        local multi_day = "  "
        if tline[2] == "" then
            -- whole day event
            time_str = string.rep(" ", 5, "")
        else
            time_str = string.format("%2s:%02d", tostring(date_start["hour"]), date_start["min"])
        end
        if tline[1] ~= tline[3] then
            multi_day = " …"
        end
        local ongoing = "    "
        if ctime >= ts_start and ctime <= ts_end then
            ongoing = "󰜴   "
        end
        local l = gen_text("l", "1:1", color, RES.font, RES.size, ongoing .. time_str .. multi_day .. "   " .. desc)
        table.insert(output, l)
    end
    return table.concat(output, "\n")
end
