extends Control

onready var name_lbl = $"Panel/VBoxContainer/Name"
onready var texture_rect = $"Panel/VBoxContainer/TextureRect"
onready var text_rtl = $"Panel/VBoxContainer/Label"
onready var time_debug = $"Panel/VBoxContainer/Label2"

var t = 0
func populate_with(card):
	texture_rect.texture = load(card.img_path)
	name_lbl.text = card.name
	text_rtl.text = card.text
	var text_color = null
	match card.type:
		card.CardType.INSTANT:
			text_color = Color(0.1,0.4,0.6)
		card.CardType.CREATURE:
			text_color = Color(0.7,0.2,0.1)
	if text_color:
		text_rtl.add_stylebox_override("normal", text_rtl.get_stylebox("normal").duplicate())
		text_rtl.get_stylebox("normal").bg_color = text_color
	time_debug.text = str(OS.get_datetime()["hour"]) + ":"+ str(OS.get_datetime()["minute"])+":"+str(OS.get_datetime()["second"])
