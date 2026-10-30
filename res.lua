-- Resources

function init_resources(config)
    local s = config.scale_factor or 1
    RES = {
        font = config["font"] or "monospace",
        size = tonumber(config["size"])*2 or 16,
        color = config["color"] or "#ffffff",

        icon_font = config["icon_font"] or "monospace",
        icon_size = tonumber(config["icon_size"])*2 or 16,
        icon_color = config["icon_color"] or "#ff0000",

        brand_font = config["brand_font"] or "monoapce",
        brand_size = tonumber(config["brand_size"])*2 or 16,

        hr_width = tonumber(config["hr_width"]) or 2,
        bar_height = tonumber(config["bar_height"]) or 10
    }
end
