extends Node

var font_size_cm = 0.4
var screen_dpi = OS.get_screen_dpi(0)
var screen_size setget ,_get_screen_size
func _ready():
	var theme = load("res://theme/table.theme")
	theme.default_font.size = cm_to_pixel(font_size_cm)

func cm_to_pixel(cm):
	return screen_dpi * cm/2.5

func _get_screen_size():
	return get_tree().get_root().size