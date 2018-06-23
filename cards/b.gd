extends "res://card_class/card_creature.gd"

func _init():
	name = "This is a different Monster"
	text = "Its just different... noone knows how."
	type = CardType.CREATURE
	max_lives = 1
	max_attack = 1
	mana_cost[ManaType.RED] = 2