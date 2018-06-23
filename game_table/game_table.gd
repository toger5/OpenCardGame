extends Control

enum TableLocation {BF, HAND, GRAVEYARD, DECK, OPPONENT_HAND, OPPONENT_BF}

signal cast_finished

onready var player = $player
onready var opponent = $opp



onready var card_preview_tr = get_node("../TextureRect")
onready var deck = $player/left_area/deck

var tw = Tween.new()

#var dragged_card = null
var drag_offset = Vector2()
var drag_offset_factor = 1
#var hovered_card = null

var cast_queue = []

func _ready():
	add_child(tw)
	setup_game()
	player.connect("turn_finished", self, "_turn_finished")
	opponent.connect("turn_finished", self, "_turn_finished")
	player.is_playing = true
	opponent.is_playing = false
	card_preview_tr.rect_size.y = card_preview_tr.rect_size.x / card_renderer.card_size.aspect()

func setup_game():
	player.cardnames_deck = ["a", "b", "mana_red", "mana_blue", "mana_blue", "flo"]
	opponent.cardnames_deck = [ "mana_blue", "flo","a", "b", "mana_red", "mana_blue"]


func add_card_to_hand(card, to_player, initial_rect = null):
	var card_holder = card.holder_node
#	card_holder.connect("mouse_entered",self,"mouse_entered_card_tex",[card])
#	card_holder.connect("mouse_exited",self,"mouse_exited_card_tex",[card])
	to_player.hand_h_box.add_child(card_holder)
	to_player.hand_h_box.move_child(card_holder, 0)
	card.location = CardLocation.HAND
	yield(to_player.hand_h_box, "sort_children")
	if initial_rect:
		card.texture_node.rect_global_position = initial_rect.position
		card.texture_node.rect_size = initial_rect.size
		card.holder_node.animate_to_holder()
#		mouse_exited_card_tex(card, true)

#func add_card_to_bf(card):
#	bf_card_h_box.add_child(add_card(card))
#	card.location = CardLocation.BATTLEFIELD

#DEPRECATED
func move_card_to_bf(card):
	print("DEPRECATED location")
	if card.location == CardLocation.HAND:
#				hovered_card = null
			if cast_queue.empty() or card.type == card.CardType.INSTANT:
				queue_cast_card(card)
				yield(self, "cast_finished")
				print("yield of cast_finished")
			card.holder_node.animate_to_holder()
#			mouse_exited_card_tex(card, true)

#DEPRECATED
func move_card_to(card, table_location):
	print("DEPRECATED move_card_to")
	if TableLocation.BF or TableLocation.OPPONENT_BF:
		if card.location == CardLocation.HAND:
#				hovered_card = null
			if cast_queue.empty() or card.type == card.CardType.INSTANT:
				queue_cast_card(card)
				yield(self, "cast_finished")
				print("yield of cast_finished")
#		TableLocation.HAND:
			#sollte eigentlich nicht gehen... vielleicht sollte player gechoosed werden...
#			h_box = hand_card_h_box
#			card.location = CardLocation.HAND
#			pass
#		TableLocation.OPPONENT_BF:
#			var target_card = card_under_mouse()
#			if target_card and card.casted:
#				card._action_on_card(target_card)
#		TableLocation.OPPONENT_HAND:
#			card._action_on_opponent()
	

func queue_cast_card(card):
#	for c in cast_queue:
#		c.timer.pause()
	if cast_queue.empty() or card.type == card.CardType.INSTANT:
		pass
	else:
		return
	if not cast_queue.empty():
		cast_queue.front().timer.paused = true
	cast_queue.push_front(card)
	card.start_card_timer(2)

	yield(card.timer, "timeout")
	card._cast()
	cast_queue.pop_front()
	if not cast_queue.empty():
		cast_queue.front().timer.paused = false
	else:
		card.holder_node.animate_to_holder()
		emit_signal("cast_finished")
	
	var move_to_h_box = null
	var hand_h_box = card.player.hand_h_box
	var bf_h_box = card.player.bf_h_box
	if card.type == card.CardType.MANA:
		move_to_h_box = null
		hand_h_box.remove_child(card.holder_node)
		card.location = CardLocation.MANA
	elif card.type == card.CardType.CREATURE:
		card.location = CardLocation.BATTLEFIELD
		move_to_h_box = bf_h_box
	elif card.type == card.CardType.INSTANT:
		move_to_h_box = null
		card.location = CardLocation.GRAVEYARD
		card.holder_node.get_parent().remove_child(card.holder_node)
	if move_to_h_box:
		var tex_global_rect = card.texture_node.get_global_rect()
		card.set_card_holder_height(move_to_h_box.rect_size.y)
		card.holder_node.get_parent().remove_child(card.holder_node)
		move_to_h_box.add_child(card.holder_node)
		yield(move_to_h_box, "sort_children")
		card.texture_node.rect_global_position = tex_global_rect.position
		card.texture_node.rect_size = tex_global_rect.size
		card.holder_node.animate_to_holder()
#DEPRECATED
func mouse_entered_card_tex(card):
	print("DEPRECATED mouse_entered_card_tex")
#	hovered_card = card
#	if dragged_card: 
#		return
#	if card.location == CardLocation.BATTLEFIELD:
#		card_preview_tr.texture = card_renderer.get_card_texture(card)
#		tw.interpolate_property(card_preview_tr, "modulate:a", card_preview_tr.modulate.a, 1,0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)

func show_card_preview(card):
		card_preview_tr.texture = card.texture_node.texture
		tw.interpolate_property(card_preview_tr, "modulate:a", card_preview_tr.modulate.a, 1,0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)

func hide_card_preview(card):
	tw.interpolate_property(card_preview_tr, "modulate:a",card_preview_tr.modulate.a, 0, 0.2,Tween.TRANS_LINEAR, Tween.EASE_OUT)
#DEPRECATED
#func mouse_exited_card_tex(card, force = false):
#	hovered_card = null
#	if not cast_queue.empty() and card.casting:
#		return
#	if force or (hovered_card and hovered_card == card ):
#		pass
#	else:
#		return
#	card.animate_to_holder()
##	if card.location == CardLocation.BATTLEFIELD and card_preview_tr.modulate.a > 0:
##		card_preview_tr.texture = null
#	tw.interpolate_property(card_preview_tr, "modulate:a",card_preview_tr.modulate.a, 0, 0.2,Tween.TRANS_LINEAR, Tween.EASE_OUT)

func _turn_finished():
	opponent.is_playing = player.is_playing
	player.is_playing = not player.is_playing

func current_turn_player():
	if opponent.is_playing:
		return opponent
	elif player.is_playing:
		return player

func _input(event):
		if event is InputEventKey:
			var card_to_add = card_cache.card(card_cache.get_all_card_names()[randi() % card_cache.get_all_card_names().size()])
			if event.scancode == KEY_W and event.pressed:
				player.add_card(card_to_add)
			if event.scancode == KEY_Q and event.pressed:
				opponent.add_card(card_to_add)
#		elif event is InputEventMouseButton:
#			#Pressed
#			if event.pressed and event.button_index == BUTTON_LEFT and hovered_card:
#				dragged_card = hovered_card
#				VisualServer.canvas_item_set_z_index(dragged_card.texture_node.get_canvas_item(),2)
#				drag_offset = dragged_card.texture_node.rect_global_position - (get_global_mouse_position() - (dragged_card.texture_node.rect_size /2))
#				drag_offset_factor = 1
#				tw.stop(dragged_card.texture_node)
#				tw.interpolate_property(dragged_card.texture_node, "rect_size", dragged_card.texture_node.rect_size, Vector2(dragged_card.texture_node.texture.get_width(), dragged_card.texture_node.texture.get_height())*player.DRAG_SIZE_HIGHT/dragged_card.texture_node.texture.get_height(), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
#			#Released
#			if not event.pressed and event.button_index == BUTTON_LEFT and dragged_card:
#	#			if mouse_over() == TableLocation.BF:
#				move_card_to(dragged_card, mouse_over())
#				dragged_card = null

#func _process(delta):
#	if dragged_card:
#		drag_offset_factor = max(0,(drag_offset_factor * 0.8) - delta)
#		var t = dragged_card.texture_node
#		t.rect_global_position = (get_global_mouse_position() - t.rect_size/2) + drag_offset * drag_offset_factor

func mouse_over():
	var mo
	var mp = get_global_mouse_position()
	if player.hand_node.get_global_rect().has_point(mp):
		mo = TableLocation.HAND
	elif player.bf_node.get_global_rect().has_point(mp):
		mo = TableLocation.BF
	elif opponent.hand_node.get_global_rect().has_point(mp):
		mo = TableLocation.OPPONENT_HAND
	elif opponent.bf_node.get_global_rect().has_point(mp):
		mo = TableLocation.OPPONENT_BF
	return mo

func mouse_over_cast_area():
	var mo = mouse_over()
	return mo == BF or mo == OPPONENT_BF
#func card_under_mouse():
#	var mp = get_global_mouse_position()
#	var over = null
#	match mouse_over():
#		TableLocation.HAND:
#			for c in hand_card_h_box.get_children():
#				if c.get_global_rect().has_point(mp):
#					over = c
#		TableLocation.BF:
#			for c in hand_card_h_box.get_children():
#				if c.get_global_rect().has_point(mp):
#					over = c
#		TableLocation.OPPONENT_BF:
#			for c in opp_bf_card_h_box.get_children():
#				if c.get_global_rect().has_point(mp):
#					over = c
#	return over