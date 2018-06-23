extends Node

enum {WHITE, BLUE, BLACK, RED, GREEN, COLORLESS}#this order should always be used ex. in mana costs (its the original mtg order)

func color(color):
	match color:
		RED:
			return(Color(150.0/255, 20.0/255, 20.0/255))
			
		BLUE:
			return(Color(20.0/255,20.0/255,150.0/255))