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
onready var attack_phase_spacer = $right_area/attack_phase_spacer
onready var attack_overlay = $right_area/bf/attack_overlay
onready var attack_overlay_bg = $right_area/bf/attack_overlay/attack_overlay_bg
var BF_CARD_HEIGHT = 350
var DRAG_SIZE_HIGHT = 300

signal mana_changed(mana)
signal card_added(card)
signal turn_finished

var cast_wait_time = 0.5
var is_playing setget _turn_changed
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
	attack_overlay.get_font("font").size = Dpi.cm_to_pixel(0.6)
	for t in ManaType.list:
		mana_temp[t] = 0
		
func update_tableside():
	#set up of the bf and hand order for TOP or BOTTOM player_side
	var end_pos = $right_area.get_child_count() - 1
	match table_side:
		TableSide.TOP:
			#player on TOP side of table so order is: hand_node, bf_node, attack_phase_spacer (from top to bottmo)
			$right_area.move_child(hand_node, end_pos)
			$right_area.move_child(bf_node, end_pos)
			$right_area.move_child(attack_phase_spacer, end_pos)
			$left_area/Label.text = "Player2"
		TableSide.BOTTOM:
			#player on BOTTOM side of table so order is: attack_phase_spacer, bf_node, hand_node (from top to bottmo)
			$right_area.move_child(attack_phase_spacer, end_pos)
			$right_area.move_child(bf_node, end_pos)
			$right_area.move_child(hand_node, end_pos)
			$left_area/Label.text = "Player1"
	hand_node.rect_min_size.y = get_tree().get_root().size.y / 2 / 3
	
	
#MANA
func get_available_mana():
	var av_mana = {}
	for mt in ManaType.list:
		av_mana[mt] = 0
		
	for c in get_cards_mana_array():
		if not c.tapped:
			av_mana[c.mana_type] += 1
	return av_mana

func tap_mana(mana):
	var m = mana
	for c in get_cards_mana_array():
		if m[c.mana_type] > 0:
			c.tapped = true
			m[c.mana_type] -= 1
	emit_signal("mana_changed", get_available_mana())



#ATTACK ui-anim's
func show_attack_indicate_label(opacity_lbl, opcity_bg):
	Global.game_table.tw.interpolate_property(attack_overlay, "self_modulate:a",
		attack_overlay.self_modulate.a, opacity_lbl,
		0.2, Tween.EASE_IN, Tween.TRANS_LINEAR)
	Global.game_table.tw.interpolate_property(attack_overlay_bg, "self_modulate:a",
		attack_overlay_bg.self_modulate.a, opcity_bg, 
		0.2, Tween.EASE_IN, Tween.TRANS_LINEAR)


#DRAW CARD
func _on_deck_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT and is_playing:
			draw_card()

func draw_card():
	if not cardnames_deck.empty():
		add_card_to_hand(card_cache.card(cardnames_deck.pop_front()) )
	else:
		print("There are no cards left (in Deck)")

func add_card_to_hand(card):
	card.player = self
	card.opponent = get_parent().get_child(abs(get_index() - 1))
	cards_in_game.append(card)

	hand_h_box.add_child(card.holder_node)
	hand_h_box.move_child(card.holder_node, 0)
	card.location = CardLocation.HAND
	var initial_rect = Global.game_table.deck.get_global_rect()
	yield(hand_h_box, "sort_children")
#	emit_signal("card_added", card)
	card.texture_node.rect_global_position = initial_rect.position
	card.texture_node.rect_size = initial_rect.size
	card.holder_node.animate_to_holder()

	card.connect("location_changed", self, "_card_location_changed")
	card.holder_node.connect("dropped", self, "_card_dropped")

#Handle Card Actions
func _card_dropped(card):
	match card.location:
		CardLocation.HAND:
			#cast
			if TableLocation.mouse_over_cast_area() and card._can_cast() and can_cast_enough_mana(card):
				tap_mana(card.mana_cost)
				Global.game_table.queue_cast_card(card)
			else:
				card.holder_node.animate_to_holder()
		CardLocation.BATTLEFIELD:
			if TableLocation.mouse_pos() == TableLocation.opponent_bf(self):
				Global.game_table.start_attack_phase()
			else:
				indicate_attack_phase(false, 0) # #false: indicate with gap, false: for without label
			card.holder_node.animate_to_holder()

func can_cast_enough_mana(card):
	var mana = get_available_mana()
	for t in ManaType.list:
		if card.mana_cost[t] > mana[t]:
			return false
	return true

func indicate_attack_phase(indicate, label_stage = 0):
	if Global.game_table.attack_phase:
		return
	var attack_indicate_height = 20
	if not indicate:
		attack_indicate_height = 0
	for p in [get_opponent(), self]:
		var spacer = p.attack_phase_spacer
		var d = 0.17
		Global.game_table.tw.interpolate_property(spacer, "rect_min_size:y", spacer.rect_size.y, attack_indicate_height, d, Tween.TRANS_EXPO, Tween.EASE_OUT)

	var bg_opacity = 0
	var lbl_opacity = 0
	if indicate:
		match label_stage:
			1:
				lbl_opacity = 0.2
				bg_opacity = 0.3
			2:
				lbl_opacity = 0.6
				bg_opacity = 0.4
	get_opponent().show_attack_indicate_label(lbl_opacity, bg_opacity)
#Events
func _card_location_changed(card):
	if card.location == CardLocation.MANA:
		emit_signal("mana_changed", get_available_mana())

func _on_FinishTurnButton_pressed():
	emit_signal("turn_finished")

func _turn_changed(new_val):
	is_playing = new_val
	$left_area/FinishTurnButton.disabled = not is_playing
	
#Helper
func get_opponent():
	if Global.game_table.player == self:
		return Global.game_table.opponent
	else:
		return Global.game_table.player
#get cards from different locations
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
