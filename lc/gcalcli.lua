local utils = require("lc.utils")
local layout = require("lc.layout")
local M = {}

---@class Event
---@field desc string
---@field start_time osdate
---@field end_time osdate
---@field calendar string
---@field multi 0|1|2
---@field color string


local function mk_date(day_t, time_t)
    local res = {}
    res.year = tonumber(day_t[1])
    res.month = tonumber(day_t[2])
    res.day = tonumber(day_t[3])
    res.hour = tonumber(time_t[1]) or 0
    res.min = tonumber(time_t[2]) or 0
    res.sec = 0
    res.isdst = nil
    return res
end

local function diff_day(d1, d2, i)
    d1 = utils.copy_table(d1)
    d2 = utils.copy_table(d2)
    for _, t in ipairs({ d1, d2 }) do
        t.hour = 0
        t.min = 0
        t.sec = 0
        t.isdst = nil
    end
    d1.day = d1.day + i
    return os.time(d1) == os.time(d2)
end

---Create an event
---@param cal string
---@param desc string
---@param start_day string
---@param start_time string
---@param end_day string
---@param end_time string
---@param color string
---@return Event
local function mk_event(cal, desc, color, start_day, start_time, end_day, end_time)
    local ev = {}
    ev.calendar = cal
    ev.desc = desc
    ev.color = color
    local sd = utils.split(start_day, "-")
    local st = start_time == "" and { 0, 0 } or utils.split(start_time, ":")
    local ed = utils.split(end_day, "-")
    local et = end_time == "" and { 0, 0 } or utils.split(end_day, ":")
    local dst = mk_date(sd, st)
    local det = mk_date(ed, et)
    ev.start_time = dst
    ev.end_time = det
    if diff_day(dst, det, 0) then
        ev.multi = 0
    elseif diff_day(dst, det, 1) and st[0] == 0 and
        st[1] == 0 and et[0] == 0 and et[1] == 0 then
        ev.multi = 1
    else
        ev.multi = 2
    end
    return ev
end

---comment
---@param delay number|string
---@param calendars table<string,string>
---@return Event[]?
local function fetch_and_fix(delay, calendars)
    local d = tonumber(delay) or 120

    local cal_options = ""
    for cal, _ in pairs(calendars) do
        cal_options = cal_options .. "--calendar '" .. cal .. "' "
    end
    local cmdline = "gcalcli " .. cal_options .. " agenda now 'now + 7 days' --tsv --details calendar"
    local lines = utils.run_cached(d, cmdline, "\t")
    if #lines == 0 or lines[1][1] == "" then
        return nil
    end
    ---@type Event[]
    local output = {}
    for i = 2, #lines do
        local line = lines[i]
        local cname = line[6]
        local ev = mk_event(cname, line[5], calendars[cname],
            line[1], line[2],
            line[3], line[4])
        table.insert(output, ev)
    end
    for _, ev in ipairs(output) do
        if ev.multi == 2 then
            local ds2 = utils.copy_table(ev.start_time)
            ds2.day = ds2.day + 1
            ds2.hour = 0
            ds2.min = 0
            ds2.sec = 0
            if os.time(ds2) < os.time(ev.end_time) then
                local ev2 = utils.copy_table(ev)
                ev2.start_time = ds2
                output[#output + 1] = ev2
            end
        end
    end
    table.sort(output, function(e1, e2)
        local ts1 = os.time(e1.start_time)
        local ts2 = os.time(e2.start_time)
        return ts1 < ts2
    end)
    return output
end

---Returns a pretty printed version of the google calendars
---given as argument. The gcalcli command is only called every delay seconds
---@param delay string|number number of seconds to wait between calls to gcalcli
---@param calendars table<string,string> a table mapping each calendar name to a display color
---@return string[]|string
function M.get(delay, calendars)
    local ctime = os.time()
    local events = fetch_and_fix(delay, calendars)
    if events == nil then
        return layout.text("Loading calendars …", "c", "1:1")
    end
    local current_day = ""
    local output = {}
    local fmt = "  %s  %s  %s  %s"
    for _, ev in ipairs(events) do
        local ts_start = os.time(ev.start_time)
        local display_day = os.date("%a %d %b", ts_start)
        if current_day ~= display_day then
            -- a new day
            table.insert(output, layout.label("\u{f073}", display_day, "", "1/3:1"))
            current_day = display_day
        end
        local ts_end = os.time(ev.end_time)
        local ongoing = " "
        if ctime >= ts_start and ctime <= ts_end then
            ongoing = "\u{f444}"
        end
        local time_str = string.format("%2s:%02d", ev.start_time.hour, ev.start_time.min)
        local multi = " "
        if ev.multi == 1 then
            multi = "\u{f00ee}"
        elseif ev.multi == 2 then
            multi = "\u{f1073}"
        end
        local text = fmt:format(ongoing, time_str, multi, ev.desc)
        table.insert(output, layout.text(text, "l", "1:1", ev.color))
    end
    return output
end

return M
