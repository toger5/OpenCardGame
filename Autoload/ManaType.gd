extends Node

enum {WHITE, BLUE, BLACK, RED, GREEN, COLORLESS} #this order should always be used ex. in mana costs (its the original mtg order)

var list = [WHITE, BLUE, BLACK, RED, GREEN, COLORLESS]

func color(type):
	match(type):
		RED: return Color(0.8, 0.2, 0.2)
		BLUE: return Color(0.2, 0.2, 0.8)
		GREEN: return Color(0.2, 0.8, 0.2)
