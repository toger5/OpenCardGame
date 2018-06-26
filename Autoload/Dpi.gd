extends Node

var font_size_cm = 0.4
var screen_dpi = OS.get_screen_dpi(0)
func _ready():
	var theme = load("res://theme/table.theme")
	theme.default_font.size = cm_to_pixel(font_size_cm)

func cm_to_pixel(cm):
	return screen_dpi * cm/2.5


var screen_size setget ,_get_screen_size
var player_size setget ,_get_player_size
func _get_screen_size(): return get_tree().get_root().size
func _get_player_size(): return Vector2(_get_screen_size().x, _get_screen_size().y/2)


#SIZE CONSTANTS
var ATTACK_SPACER_HEIGHT setget ,_get_attack_spacer_height
func _get_attack_spacer_height(): return (_get_player_size().y) / 4 

var HAND_HEIGHT setget ,_get_hand_height
func _get_hand_height(): return _get_player_size().y / 3

var GAP_SIZE setget ,_get_gap_size
func _get_gap_size(): return cm_to_pixel(0.2)

