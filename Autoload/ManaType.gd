extends Node

enum {RED, BLUE, GREEN}

var list = [RED, BLUE, GREEN]

func color(type):
	match(type):
		RED: return Color(0.8, 0.2, 0.2)
		BLUE: return Color(0.2, 0.2, 0.8)
		GREEN: return Color(0.2, 0.8, 0.2)