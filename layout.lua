require('cairo_text_helper')
local SCALE_FACTOR = 1

local function text_width(font, size, text)
    local w, _ = cairo_text_hp_text_size(text, font, size)
    return math.floor(w / SCALE_FACTOR)
end

function init_layout(scale, col_sep)
    SCALE_FACTOR = scale
    local width = math.floor(conky_window["text_width"] / scale)
    local x0 = math.floor(conky_window["text_start_x"] / scale)

    local hcol_sep = math.floor(col_sep / 2)

    local h = math.floor(width / 2) - hcol_sep
    local t1 = math.floor(width / 3) - hcol_sep
    local t2 = width - (t1 + col_sep)
    COLUMNS = {
        ["1:1"]   = { x = x0, w = width },
        ["1/2:1"] = { x = x0, w = h },
        ["1/2:2"] = { x = x0 + h + col_sep, w = h },
        ["1/3:1"] = { x = x0, w = t1 },
        ["1/3:2"] = { x = x0 + t1 + col_sep, w = t2 },
        ["2/3:1"] = { x = x0, w = t2 },
        ["2/3:2"] = { x = x0 + t2 + col_sep, w = t1 },
    }
end

local function col_infos(column)
    return assert(COLUMNS[column], "unknown column type: " .. column)
end
function goto_(n)
    return "${goto " .. tostring(n) .. "}"
end

function color_(n)
    return "${color " .. n .. "}"
end

function font_(n, s)
    return "${font " .. n .. ":pixelsize=" .. tostring(s) .. "}"
end

function gen_text(align, column, color, font, size, text)
    local cols = col_infos(column)
    local x = cols["x"]
    local col_w = cols["w"]
    local text_w = 0
    local trimmed = false
    while true do
        text_w = text_width(font, size, conky_parse(text))
        if text_w < col_w then break end
        text = string.sub(text, 0, string.len(text) - 1)
        trimmed = true
    end
    if trimmed then text = text .. "…" end
    local text_x = 0
    if align == "l" then
        text_x = x
    elseif align == "r" then
        text_x = math.floor((x + col_w - text_w))
    elseif align == "c" then
        text_x = x + math.floor((col_w / 2) - (text_w / 2))
    else
        error("Unknown alignment: " .. align)
    end


    local res = goto_(text_x) .. font_(font, size) .. color_(color) .. text
    return res
end

function text(align, column, text)
    return gen_text(align, column, RES.color, RES.font, RES.size, text)
end

function conky_default_bar(n)
    return n
end

function gen_bar(column, color, height, percent)
    local cols = col_infos(column)
    local x = cols["x"]
    local col_w = cols["w"]
    local res = goto_(x) .. color_(color) ..
        "${lua_bar " .. tostring(height) .. "," .. tostring(col_w) ..
        " default_bar " .. tostring(percent) .. "}"
    return res
end

function custom_bar(column, percent)
    local res = gen_bar(column, RES.color, RES.bar_height, percent)
    return res
end

function bar(column, name)
    local cols = col_infos(column)
    local res = goto_(cols["x"]) ..
        color_(RES.color) ..
        "${" .. name .. " " .. tostring(RES.bar_height) .. "," .. tostring(cols["w"]) .. "}"
    return res
end

function gen_label(column,
                   icon_color, icon_font, icon_size, icon,
                   label,
                   color, font, size, text)
    local cols = col_infos(column)
    local x = cols["x"]
    local col_w = cols["w"]
    local icon_w = text_width(icon_font, icon_size, icon)
    local x_w = text_width(font, size, "x") + 0.5
    x_w = math.floor(x_w * (math.floor(icon_w / x_w) + 1.5))
    text = conky_parse(text)
    label = label
    local x_text = col_w - text_width(font, size, text)
    local res = goto_(x) .. font_(icon_font, icon_size) .. color_(icon_color) .. icon ..
        goto_(x + x_w) .. font_(font, size) .. label ..
        goto_(x + x_text) .. font_(font, size) .. color_(color) .. text
    return res
end

function label(column, icon, label, text)
    return gen_label(column, RES.icon_color, RES.icon_font, RES.icon_size,
        icon, label, RES.color, RES.font, RES.size, text)
end

function gen_line(column, color, dash, height)
    local hr = ""
    local cols = col_infos(column)

    if dash ~= nil and dash > 0 then
        hr = "${stippled_hr " .. tostring(dash) .. " "
    else
        hr = "${hr "
    end
    if height == nil then
        height = 2
    end
    return goto_(cols["x"]) ..
        color_(color) .. hr .. tostring(height) .. " " ..
        tostring(cols["w"]) .. "}"
end

function hr(d)
    return "\n" ..
        gen_line("1:1", RES.icon_color, d, RES.hr_width) .. "\n"
end

