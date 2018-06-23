extends Control

onready var name_lbl = $"Panel/VBoxContainer/Name"
onready var texture_rect = $"Panel/VBoxContainer/TextureRect"
onready var text_rtl = $"Panel/VBoxContainer/rich_text_label"
onready var type = $"Panel/VBoxContainer/Type"
onready var attack_and_lives = $"Panel/VBoxContainer/rich_text_label/AttackAndHealth"
onready var time_debug = $"Panel/VBoxContainer/Label2"
onready var mana_lbl = $"Panel/VBoxContainer/Name/HBoxContainer"


var t = 0
func populate_with(card):
	texture_rect.texture = load(card.img_path)
	name_lbl.text = card.name
	text_rtl.text = card.text
	var text_color = null
	
	mana_cost(card)
	
	match card.type:
		card.CardType.INSTANT:
			text_color = Color(0.1,0.4,0.6)
			attack_and_lives.hide()
		card.CardType.CREATURE:
			text_color = Color(0.7,0.2,0.1)
			attack_and_lives.text = str(card.max_attack) + "/" + str(card.max_lives)
	if text_color:
		text_rtl.add_stylebox_override("normal", text_rtl.get_stylebox("normal").duplicate())
		text_rtl.get_stylebox("normal").bg_color = text_color
	time_debug.text = str(OS.get_datetime()["hour"]) + ":"+ str(OS.get_datetime()["minute"])+":"+str(OS.get_datetime()["second"])

func mana_cost(card):
	for mana in ManaType.list:
		for i in range(card.mana_cost[mana]):
			var tr = TextureRect.new()
			tr.texture = load("res://resources/GreenMana.png")
			tr.modulate = ManaType.color(mana)
			mana_lbl.add_child(tr)