extends "res://card_class/card_base.gd"

#enum CardType = {INSTANT, CREATURE}
#enum ManaType = {RED, BLUE}
#enum CardLocation = {DECK, HAND, GRAVEYARD, BATTLEFIELD}

#props
var name = "[Define Name]"
var text = "[Define text]"
var type = null
var img_path = "empty" #automtically searches for the a file with same name than .gd
var mana_cost #saved as a dict with keys of ManaType

var max_lives
var max_attack

#events

#func _init():
	
#func _cast():
#	._cast()

#func _can_attack():

#func _attack(target):
	
#func _can_block(target): #-> bool
	
#func _block_target():

#func _can_cast_tab_spell(): #-> bool

#func _cast_tab_spell():
