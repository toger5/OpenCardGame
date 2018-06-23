extends "res://card_class/card_creature.gd"

func _init():
	name = "A Big Monster"
	text = "the first and beautiful monster. It actually looks really fcking good"
	type = CardType.INSTANT
	
	mana_cost[ManaType.RED] = 1
	mana_cost[ManaType.BLUE] = 2
