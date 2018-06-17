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
	time_debug.text = str(OS.get_datetime()["hour"]) + ":"+ str(OS.get_datetime()["minute"])+":"+str(OS.get_datetime()["second"])
