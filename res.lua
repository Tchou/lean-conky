-- Resources

function init_resources(config)
    local s = config.scale_factor or 1
    RES = {
        font = config["font"] or "monospace",
        size = tonumber(config["size"]) * 2 or 16,
        color = config["color"] or "#ffffff",
        icon_color = config["icon_color"] or "#ff0000",

        hr_width = tonumber(config["hr_width"]) or 2,
        bar_height = tonumber(config["bar_height"]) or 10,
        line_offset = tonumber(config["line_offset"]) or 0
    }
end
