extends "res://card_class/card_base.gd"

var max_lives = 0
var max_attack = 0

#events
func _can_attack():
	#trys to attack only if it returns true the attack can be executed
	return true

func _attack(target):
	#called
	pass
func _can_block(target):
	#TODO standart rules
	return true
func _block_target():
	pass

func _can_cast_tab_spell():
	return true
func _cast_tap_spell():
	print("tap_spell casted from: "+name)

# handler
func _action_on_card(card):
	_attack(card)