local appdir = os.getenv("APPDIR")
if appdir then
    package.cpath = appdir .. "/usr/lib/conky/lib?.so;" .. package.cpath
end

local layout = require('lc.layout')
local cfg = require('config')

function conky_setup()
    layout.init(cfg.CONFIG)
end

function conky_content()
    local t = cfg.TEMPLATE() or {}
    return layout.render(t)
end

function conky_bg()
    layout.draw_bg()
end
