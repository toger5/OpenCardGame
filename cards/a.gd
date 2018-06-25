extends "res://card_class/card_base.gd"

func _init():
	name = "ANice instant"
	text = "the first and beautiful instant. It actually looks really fcking good"
	type = CardType.INSTANT
	
	mana_cost[ManaType.RED] = 1
	mana_cost[ManaType.BLUE] = 2
