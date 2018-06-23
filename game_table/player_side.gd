extends HBoxContainer

enum TableSide {TOP, BOTTOM}
#export (bool) onready var is_player
export (TableSide) var table_side = TableSide.TOP
onready var bf_node = $right_area/bf
onready var hand_node = $right_area/hand
onready var bf_h_box = $right_area/bf/HBoxContainer
onready var hand_h_box = $right_area/hand/HBoxContainer
onready var v_box = $right_area
onready var name_label = $left_area/Label

var MIN_HAND_HIGHT = 240
var BF_CARD_HEIGHT = 350
var DRAG_SIZE_HIGHT = 240

signal mana_changed(mana)
signal turn_finished

var is_playing setget turn_changed
var mana_temp = {
	ManaType.RED : 0,
	ManaType.BLUE : 0
}
var cardnames_deck = []
var cards_in_game = []

#var cards_hand = []  setget ,get_cards_hand
#var cards_mana_array = [] setget ,get_cards_mana_array
#var cards_graveyard = [] setget ,get_cards_graveyard
#var cards_battlefield = [] setget ,get_cards_battlefield

var mana setget ,get_available_mana

func _ready():
	hand_h_box.rect_min_size.y = MIN_HAND_HIGHT + 100
	update_tableside()

func get_available_mana():
	var av_mana = {}
	for mt in ManaType.list:
		av_mana[mt] = 0
	for c in get_cards_mana_array():
		if not c.tapped:
			av_mana[c.mana_type] += 1
	return av_mana

func get_cards_hand():
	return get_cards_in(CardLocation.HAND)
	
func get_cards_mana_array():
	return get_cards_in(CardLocation.MANA)
	
func get_cards_graveyard():
	return get_cards_in(CardLocation.GRAVEYARD)
	
func get_cards_battlefield():
	return get_cards_in(CardLocation.BATTLEFIELD)
	
func get_cards_in(location):
	var cards_found = []
	for c in cards_in_game:
		if c.location == location:
			cards_found.append(c)
	return cards_found

func update_tableside():
	print(table_side)
	match table_side:
		TableSide.TOP:
			$right_area.move_child($right_area/hand, 0)
			$left_area/Label.text = "Player2"
		TableSide.BOTTOM:
			$right_area.move_child($right_area/bf, 0)
			$left_area/Label.text = "Player1"

func _on_deck_gui_input(event):
	#draw card
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT and is_playing:
			if not cardnames_deck.empty():
				add_card(card_cache.card(cardnames_deck.pop_front()) )
			else:
				print("There are no cards left (in Deck)")
func add_card(card):
	card.connect("location_changed", self, "_card_location_changed")
	cards_in_game.append(card)
	get_parent().add_card_to_hand(card, self, $left_area/deck.get_global_rect())
	
func _card_location_changed(card):
	if card.location == CardLocation.MANA:
		emit_signal("mana_changed", self.mana)

func _on_FinishTurnButton_pressed():
	emit_signal("turn_finished")

func turn_changed(new_val):
	is_playing = new_val
	$left_area/FinishTurnButton.disabled = not is_playing