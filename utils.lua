function format_gib(n)
    local base = 1024 * 1024 * 1024
    local x = tonumber(n)
    local res = x / base
    if res < 10 then
        return string.format("%.2f", res) .. "GiB"
    else
        return tostring(math.floor(res)) .. "GiB"
    end
end

function format_perc(n)
    local x = tonumber(n)
    return string.format("% 3d", x)
end

function split(s, sep)
    local out = {}
    local start = 1
    while true do
        local i = string.find(s, sep, start, true) -- true = plain text search
        if i == nil then
            out[#out + 1] = string.sub(s, start)
            return out
        end
        out[#out + 1] = string.sub(s, start, i - 1)
        start = i + #sep
    end
end
