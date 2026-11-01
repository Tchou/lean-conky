local M = {}

---Format a number of bytes to its binary system representation, up to PiB
---@param x number|string
---@return string
function M.format_bin(x)
    local n = tonumber(x)
    local suffixes = { "", "KiB", "MiB", "GiB", "TiB" }
    local b = 1
    local fmt = "%.0f%s"
    for _, s in ipairs(suffixes) do
        if n < b * 1024 then
            return fmt:format(n / b, s)
        end
        b = b * 1024
    end
    return fmt:format(n / b, "PiB")
end

---Format a number as an integer percentage, left padded with spaces 0 1 or 2
--spaces
---@param n number|string
---@return string
function M.format_perc(n)
    local p = tonumber(n)
    return string.format("% 3.0f", p)
end

---Split a string along along using separator sep
---@param s string
---@sep string
---@return string[]
function M.split(s, sep)
    local out = {}
    local start = 1
    while true do
        local i = string.find(s, sep, start, true)
        if i == nil then
            out[#out + 1] = string.sub(s, start)
            return out
        end
        out[#out + 1] = string.sub(s, start, i - 1)
        start = i + #sep
    end
end

---Runs a command line with conkys' texeci with the given delay
---The output is returned as an array of string, split allong the given
---separator. The call returns immediatly and returns a cached value
---of the output (initially {}). When the command terminates in the background,
---it updates the cached value
---@param delay number
---@param cmdline string
---@param sep string
---@returns string[]
function M.run_cached(delay, cmdline, sep)
    local d = math.max(1, tonumber(delay))
    local out = conky_parse("${texeci " .. d .. " " .. cmdline .. "}")
    if out:sub(-1) == "\n" then
        out = out:sub(1, -2)
    end
    local res = {}
    for _, line in ipairs(M.split(out, "\n")) do
        table.insert(res, M.split(line, sep))
    end
    return res
end

---Shallow copy of the given table
---@param t table
---@return table
function M.copy_table(t)
    local r = {}
    for k, v in pairs(t) do r[k] = v end
    return r
end

local function esc(v)
    if type(v) == "string" then
        return "'" .. v .. "'"
    else
        return tostring(v)
    end
end
---Recursively print a value to standard output
---@param v any
function M.debug(v, indent)
    indent = indent or 0
    local m = string.rep(" ", indent)
    if type(v) ~= "table" then
        print(m .. esc(v))
        return
    end
    print(m .. "{")
    for k, v in pairs(v) do
        if type(v) ~= "table" then
            print("  " .. m .. esc(k) .. " = " .. esc(v) .. ",")
        else
            print("  " .. m .. esc(k) .. " = ")
            M.debug(v, indent + 6)
        end
    end
    print(m .. "}")
end

return M
