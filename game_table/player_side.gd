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
onready var attack_h_box = $right_area/bf/attack_h_box
onready var attack_overlay = $right_area/bf/attack_overlay
onready var attack_overlay_bg = $right_area/bf/attack_overlay/attack_overlay_bg
var BF_CARD_HEIGHT = 350
var DRAG_SIZE_HIGHT = 300

signal mana_changed(mana)
signal card_added(card)
signal turn_finished
signal cast_finished
signal attack_anim_complete

export var cast_wait_time = 0.5
var is_playing setget _turn_changed
var mana_temp = {}
var cardnames_deck = []
var cards_in_game = []
var cast_queue = []


func _ready():
	update_tableside()
	get_tree().get_root().connect("size_changed", self, "update_tableside")
	attack_overlay.get_font("font").size = Dpi.cm_to_pixel(0.6)
	for t in ManaType.list:
		mana_temp[t] = 0
#Mana
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
			attack_h_box.set_anchors_and_margins_preset(Control.PRESET_BOTTOM_WIDE)
		TableSide.BOTTOM:
			#player on BOTTOM side of table so order is: attack_phase_spacer, bf_node, hand_node (from top to bottmo)
			$right_area.move_child(attack_phase_spacer, end_pos)
			$right_area.move_child(bf_node, end_pos)
			$right_area.move_child(hand_node, end_pos)
			$left_area/Label.text = "Player1"
			attack_h_box.set_anchors_and_margins_preset(Control.PRESET_TOP_WIDE)
	attack_h_box.margin_top = -Dpi.ATTACK_SPACER_HEIGHT
	attack_h_box.margin_bottom = Dpi.ATTACK_SPACER_HEIGHT / 3
	VisualServer.canvas_item_set_z_index(attack_h_box.get_canvas_item(),10)
	hand_node.rect_min_size.y = get_tree().get_root().size.y / 2 / 3
	

#DRAW CARD
func _on_deck_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT and is_playing:
			draw_card()
			
#drawing a card
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
	card.texture_node.rect_global_position = initial_rect.position
	card.texture_node.rect_size = initial_rect.size
#	card.move_to(hand_h_box, CardLocation.HAND)

#	emit_signal("card_added", card)

	card.holder_node.animate_to_holder()

	card.connect("location_changed", self, "_card_location_changed")
	card.holder_node.connect("dropped", self, "_card_dropped")

##ATTACK ui-anim's
func animate_attack(to_attack):
		var d = 0.2
		var attack_spacer_height = Dpi.ATTACK_SPACER_HEIGHT
		if not to_attack:
			attack_spacer_height = 0
#		Global.add_tween_to_queue(attack_phase_spacer, "rect_min_size:y", "different_property_absolute", ["rect_size.y", attack_spacer_height], d, Tween.TRANS_EXPO, Tween.EASE_IN)
		Global.game_table.tw.interpolate_property(attack_phase_spacer, "rect_min_size:y", attack_phase_spacer.rect_size.y, attack_spacer_height, d, 
			Tween.TRANS_EXPO, Tween.EASE_IN)
		yield(Global.game_table.tw, "tween_completed")
		emit_signal("attack_anim_complete")
			
func show_attack_indicate_label(opacity_lbl, opcity_bg):
	Global.game_table.tw.interpolate_property(attack_overlay, "self_modulate:a",
		attack_overlay.self_modulate.a, opacity_lbl,
		0.2, Tween.EASE_IN, Tween.TRANS_LINEAR)
	Global.game_table.tw.interpolate_property(attack_overlay_bg, "self_modulate:a",
		attack_overlay_bg.self_modulate.a, opcity_bg, 
		0.2, Tween.EASE_IN, Tween.TRANS_LINEAR)
		
		
#Handle Card Actions
func _card_dropped(card):
	match card.location:
		CardLocation.HAND:
			#cast
#			if (Global.game_table.is_casting() and can_cast_phase(card)) or is_playing: #you can always cast a card to react to another one
			if can_cast_phase(card) or is_playing: #you can always cast a card to react to another one
				if TableLocation.mouse_over_cast_area() and card.can_cast() and can_cast_enough_mana(card):
					tap_mana(card.mana_cost)
					queue_cast_card(card)
				else:
					card.holder_node.animate_to_holder()
			else:
				card.holder_node.animate_to_holder()
				
		CardLocation.ATTACK:
			if TableLocation.mouse_pos() == TableLocation.ATTACK_SPACE:
				card.move_to(attack_h_box, CardLocation.ATTACK) #This does not really do anything. Right now, when dropping here, the indication is shown again which should not be the case
			else:
				card.move_to(bf_h_box, CardLocation.BATTLEFIELD)
				yield(card, "location_changed")
				Global.game_table.end_attack_phase()
				yield(Global.game_table, "attack_phase_ended")
				card.tapped = false
		CardLocation.BATTLEFIELD:
			if is_playing:
				if TableLocation.mouse_pos() == TableLocation.opponent_bf(self):
					card.move_to(attack_h_box, CardLocation.ATTACK)
					yield(card, "location_changed")
					Global.game_table.start_attack_phase()
					yield(Global.game_table, "attack_phase_started")
					card.tapped = true
				else:
					card.holder_node.animate_to_holder()
					Global.game_table.indicate_attack_phase(false, 0) # #false: indicate with gap, false: for without label
			else: #deafault phase but not playing
				card.holder_node.animate_to_holder()

func can_cast_enough_mana(card):
	var mana = get_available_mana()
	for t in ManaType.list:
		if card.mana_cost[t] > mana[t]:
			return false
	return true
func can_cast_phase(card):
	if card.type == card.CardType.INSTANT: #TODO maybe we need to add more types here?
		return true
	return false
func queue_cast_card(card):
	if cast_queue.empty() or card.type == card.CardType.INSTANT:
		pass
	else:
		return
	if not cast_queue.empty():
		cast_queue.front().timer.paused = true
		
	cast_queue.push_front(card)
	card.start_cast_timer(cast_wait_time)
	yield(card.timer, "timeout")
	
	card.cast()
	cast_queue.pop_front()
	if not cast_queue.empty():
		cast_queue.front().timer.paused = false
	else:
		card.holder_node.animate_to_holder()
		emit_signal("cast_finished")

	match card.type:
		card.CardType.LAND:
			hand_h_box.remove_child(card.holder_node)
			card.location = CardLocation.MANA
		card.CardType.CREATURE:
			card.move_to(bf_h_box, CardLocation.BATTLEFIELD)
		card.CardType.INSTANT:
			hand_h_box.remove_child(card.holder_node)
			card.location = CardLocation.GRAVEYARD
#	if move_to_h_box:
#		var tex_global_rect = card.texture_node.get_global_rect()
#		card.holder_node.get_parent().remove_child(card.holder_node)
#		bf_h_box.add_child(card.holder_node)
#		yield(bf_h_box, "sort_children")
#		card.texture_node.rect_global_position = tex_global_rect.position
#		card.texture_node.rect_size = tex_global_rect.size
#		card.holder_node.animate_to_holder()

#Events
func _card_location_changed(card):
	if card.location == CardLocation.MANA:
		print("mana added")
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
