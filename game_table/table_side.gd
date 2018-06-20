tool
extends HBoxContainer

export (bool) onready var is_player setget _is_player_changed
onready var bf_node = $right_area/bf
onready var hand_node = $right_area/hand
onready var v_box = $right_area
onready var name_label = $left_area/Label

func _ready():
	update_playerside()
func _is_player_changed(new_val):
	print(new_val)
	is_player = new_val
	if Engine.editor_hint:
		update_playerside()
func update_playerside():
	if is_player:
		$right_area.move_child($right_area/bf, 0)
		$left_area/Label.text = "Player"
		$left_area/deck.visible = true
	else:
		$right_area.move_child($right_area/hand, 0)
		$left_area/Label.text = "Opponent"
		$left_area/deck.visible = false

func _on_deck_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			var card_names = card_cache.get_all_card_names()
			card_names.shuffle()
			get_parent().add_card_to_hand(card_cache.card(card_names[0]), $left_area/deck.get_global_rect())
