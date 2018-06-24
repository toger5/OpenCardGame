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

var BF_CARD_HEIGHT = 350
var DRAG_SIZE_HIGHT = 300

signal mana_changed(mana)
signal turn_finished

var cast_wait_time = 0.5
var is_playing setget turn_changed
var mana_temp = {}
var cardnames_deck = []
var cards_in_game = []

#var cards_hand = []  setget ,get_cards_hand
#var cards_mana_array = [] setget ,get_cards_mana_array
#var cards_graveyard = [] setget ,get_cards_graveyard
#var cards_battlefield = [] setget ,get_cards_battlefield

#var mana setget ,get_available_mana

func _ready():
	update_tableside()
	get_tree().get_root().connect("size_changed", self, "update_tableside")
	for t in ManaType.list:
		mana_temp[t] = 0
func get_available_mana():
	var av_mana = {}
	for mt in ManaType.list:
		av_mana[mt] = 0
	for c in get_cards_mana_array():
		if not c.tapped:
			av_mana[c.mana_type] += 1
	return av_mana
func tap_mana_for_temp(mana):
	for c in get_cards_mana_array():
		if mana[c.mana_type] > 0:
			c.tapped = true
			mana_temp[c.mana_type] += 1
			mana[c.mana_type] -= 1
	emit_signal("mana_changed", get_available_mana())
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
			$right_area.move_child(hand_node, 0)
			$left_area/Label.text = "Player2"
		TableSide.BOTTOM:
			$right_area.move_child(bf_node, 0)
			$left_area/Label.text = "Player1"
	hand_node.rect_min_size.y = get_tree().get_root().size.y / 2 / 3

func _on_deck_gui_input(event):
	#draw card
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT and is_playing:
			draw_card()
func draw_card():
	if not cardnames_deck.empty():
		add_card(card_cache.card(cardnames_deck.pop_front()) )
	else:
		print("There are no cards left (in Deck)")

func add_card(card):
	card.connect("location_changed", self, "_card_location_changed")
	card.player = self
	card.opponent = get_parent().get_child(abs(get_index() - 1))
	cards_in_game.append(card)
	get_parent().add_card_to_hand(card, self, $left_area/deck.get_global_rect())
	
func _card_location_changed(card):
	if card.location == CardLocation.MANA:
		emit_signal("mana_changed", get_available_mana())

func _on_FinishTurnButton_pressed():
	emit_signal("turn_finished")

func can_cast(card):
	print("trying to cast: ", card.name)
#	if
	return true
func turn_changed(new_val):
	is_playing = new_val
	$left_area/FinishTurnButton.disabled = not is_playing