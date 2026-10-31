require('cairo_text_helper')
local M = {}

---Configuration all fields are optional. The font should be able to display
---text as well as icons.
---@class Config
---@field font? string fontconfig pattern, without size ("Name:style=Regular")
---@field size? integer font size in logical pixels (scaled by scale_factor)
---@field color? string text color, "#rrggbb"
---@field icon_color? string icon color, "#rrggbb"
---@field scale_factor? number display scale (2 under Xwayland on a 2x GNOME desktop)
---@field column_sep? integer horizontal gap between columns, in logical pixels
---@field hr_width? integer thickness of horizontal rules, in pixels
---@field bar_height? integer height of progress bars, in pixels
---@field line_offset? integer extra vertical offset per line, in pixels

---@type Config
local DEFAULTS = {
    font = "monospace",
    size = 16,
    color = "#ffffff",
    icon_color = "#ff0000",
    scale_factor = 1,
    column_sep = 16,
    hr_width = 2,
    bar_height = 10,
    line_offset = 0,
}

---@type Config
local RES


---Check a user config against DEFAULTS and fill in the missing fields
---@param cfg table
---@return Config
local function merge(cfg)
    for k in pairs(cfg) do
        if DEFAULTS[k] == nil then
            error("unknown config key: " .. tostring(k))
        end
    end
    local res = {}
    for k, default in pairs(DEFAULTS) do
        local v = cfg[k]
        if v == nil then
            res[k] = default
        elseif type(v) ~= type(default) then
            error(("config.%s: expected %s, got %s"):format(k, type(default), type(v)))
        else
            res[k] = v
        end
    end
    return res
end

local function text_width(text)
    local w, _ = cairo_text_hp_text_size(text, RES.font, RES.size)
    return math.floor(w / RES.scale_factor)
end

---@class ColumnInfo
---@field x number start horizontal position of the column
---@field w number width of the column in pixels

---@alias ColumnSpec
---| "1:1"     # full line
---| "1/2:1"   # left half
---| "1/2:2"   # right half
---| "1/3:1"   # left third
---| "1/3:2"   # right two-thirds
---| "2/3:1"   # left two-thirds
---| "2/3:2"   # right thirds

--- Mapping from column spec to coordinates
--- @type table<ColumnSpec,ColumnInfo>
local COLUMNS = {}

---Initializes the layout engine
---@param cfg Config
function M.init(cfg)
    RES = merge(cfg or {})
    local scale = RES.scale_factor
    RES.size = RES.size * scale
    local col_sep = RES.column_sep
    local width = math.floor(conky_window.text_width / scale)
    local x0 = math.floor(conky_window.text_start_x / scale)

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
    local r = COLUMNS[column]
    if r == nil then
        error(debug.traceback("Unknown column type: " .. column, 2), 0)
    end
    return r
end

local function goto_(n)
    return "${goto " .. tostring(n) .. "}"
end

local function color_(n)
    return "${color " .. n .. "}"
end

---Print the given text aligned in the given colon with the given color.
---@param text string
---@param align? "l"|"r"|'c'
---@param column? ColumnSpec
---@param color? string
---@return string
function M.text(text, align, column, color)
    align = align or "l"
    column = column or "1:1"
    color = color or RES.color
    local cols = col_infos(column)
    local x = cols["x"]
    local col_w = cols["w"]
    local text_w = text_width(text)
    if text_w > col_w then
        -- drop whole characters until the text plus "…" fits
        while #text > 0 do
            local last = utf8.offset(text, -1)
            text = text:sub(1, last - 1)
            text_w = text_width(text .. "…")
            if text_w <= col_w then break end
        end
        text = text .. "…"
    end
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

    local res = goto_(text_x) .. color_(color) .. text
    return res
end

function conky_default_bar(n)
    return n
end

---Print a bar for the given percentage with the given height in the
---provided column and with the given color
---@param percent number|string
---@param column? ColumnSpec
---@param height? number|string
---@param color? string
---@return string
function M.bar(percent, column, height, color)
    percent = tonumber(percent) or 0
    height = (height == nil and RES.bar_height) or tonumber(height)
    column = column or "1:1"
    color = color or RES.color

    local cols = col_infos(column)
    local x = cols["x"]
    local col_w = cols["w"]
    local res = goto_(x) .. color_(color) ..
        "${lua_bar " .. tostring(height) .. "," .. tostring(col_w) ..
        " default_bar " .. tostring(percent) .. "}"
    return res
end

---Print a conky bar (e.g. membar) within the given column
---@param name string
---@param column? ColumnSpec
---@param height? number|string
---@param color? string
---@return string
function M.builtin_bar(name, column, height, color)
    height = (height == nil and RES.bar_height) or tonumber(height)
    column = column or "1:1"
    color = color or RES.color
    local cols = col_infos(column)
    local res = goto_(cols["x"]) ..
        color_(RES.color) ..
        "${" .. name .. " " .. height .. "," .. cols["w"] .. "}"
    return res
end

---Print a labeled text in the given column with the given colors
---@param icon string
---@param label string
---@param text string
---@param column? ColumnSpec
---@param icon_color? string
---@param color? string
---@result string
function M.label(icon, label, text, column, icon_color, color)
    column = column or "1:1"
    icon_color = icon_color or RES.icon_color
    color = color or RES.color
    local cols = col_infos(column)
    local x = cols["x"]
    local col_w = cols["w"]
    local x_w = math.floor(text_width("x") * 2.5)
    text = conky_parse(text)
    local x_text = col_w - text_width(text)
    local res =
        goto_(x) .. color_(icon_color) .. icon ..
        goto_(x + x_w) .. color_(icon_color) .. label ..
        goto_(x + x_text) .. color_(color) .. text
    return res
end

---Print an horizontal line
---@param dash? number|string
---@param height? number|string
---@param column? ColumnSpec
---@param color? string
---@return string
function M.hr(dash, height, column, color)
    dash = (dash == nil and 0) or tonumber(dash)
    height = (height == nil and RES.hr_width) or tonumber(height)
    column = column or "1:1"
    color = color or RES.icon_color

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

local function flatten(t, out)
    out = out or {}
    if type(t) == "table" then
        for _, v in ipairs(t) do flatten(v, out) end
    else
        out[#out + 1] = t
    end
    return out
end

---@alias Lines string|Lines[]


---Join cells that share one line
---@param ... string
---@return string
function M.row(...)
    return table.concat({ ... })
end

---Renders the layout as a single string
---@param t Lines
---@return string
function M.render(t)
    local prefix = "${font " .. RES.font .. ":pixelsize=" .. RES.size .. "}"
    local nl = "\n"
    if RES.line_offset ~= 0 then
        nl = "${voffset " .. tostring(RES.line_offset) .. "}\n"
    end
    return prefix .. table.concat(flatten(t), nl)
end

return M
