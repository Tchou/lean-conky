local appdir = os.getenv("APPDIR")
if appdir then
    package.cpath = appdir .. "/usr/lib/conky/lib?.so;" .. package.cpath
end

require('res')
require('layout')
require('config')
require('utils')

function conky_setup()
    local cfg = CONFIG() or {}
    init_layout(
        tonumber(cfg.scale_factor) or 1,
        tonumber(cfg.column_sep) or 16)
    init_resources(cfg)
end

function conky_content()
    local t = TEMPLATE() or {}
    local res = table.concat(t, "")
    t = split(res, "\n")
    local vo = "${voffset " .. tostring(RES.line_offset) .. "}"

    for i = 1, #t do
        local line = t[i]
        t[i] = vo .. line
    end
    res = table.concat(t, "\n")
    return res
end
