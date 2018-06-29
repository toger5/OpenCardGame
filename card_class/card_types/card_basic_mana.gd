extends "res://card_class/card_base.gd"

var mana_type

func _init():
	type = CardType.LAND

func _cast():
	print("mana_casted")
	._cast()