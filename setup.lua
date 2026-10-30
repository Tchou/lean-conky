local appdir = os.getenv("APPDIR")
if appdir then
    package.cpath = appdir .. "/usr/lib/conky/lib?.so;" .. package.cpath
end

require('res')
require('layout')
require('config')

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
    return res .. "${voffset 0}" -- ensures the window grows ?
end
