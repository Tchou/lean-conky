function text_width(font, size, text)
	local w, h = cairo_text_hp_text_size("Some value with %", "Fira Code", 10)
  	print(w, h)
end