extends Control

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
var attack_phase = false
func _ready():
	add_child(tw)
	setup_game()
	for p in [player, opponent]:
		p.connect("turn_finished", self, "_turn_finished")
		p.connect("card_added", self, "_card_added")
	
	player.is_playing = true
	opponent.is_playing = false
	card_preview_tr.rect_size.y = card_preview_tr.rect_size.x / card_renderer.card_size.aspect()

func setup_game():
	player.cardnames_deck = ["a", "b", "mana_red", "mana_blue", "mana_blue", "flo"]
	opponent.cardnames_deck = [ "mana_blue", "flo","a", "b", "mana_red", "mana_blue"]

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
	card.start_cast_timer(active_player().cast_wait_time)

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
	if card.type == card.CardType.LAND:
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
		card.holder_node.get_parent().remove_child(card.holder_node)
		move_to_h_box.add_child(card.holder_node)
		yield(move_to_h_box, "sort_children")
		card.texture_node.rect_global_position = tex_global_rect.position
		card.texture_node.rect_size = tex_global_rect.size
		card.holder_node.animate_to_holder()

func show_card_preview(card):
	card_preview_tr.texture = card.texture_node.texture
	tw.interpolate_property(card_preview_tr, "modulate:a", card_preview_tr.modulate.a, 1,0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tw.start()

func hide_card_preview(card):
	tw.interpolate_property(card_preview_tr, "modulate:a",card_preview_tr.modulate.a, 0, 0.2,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tw.start()

func _turn_finished():
	opponent.is_playing = player.is_playing
	player.is_playing = not player.is_playing

#Attack Phase

func start_attack_phase():
	if attack_phase:
		return
	attack_phase = true
	var attack_phase_height = Dpi.screen_size.y/10
	inactive_player().show_attack_indicate_label(0,0)
	for p in [opponent, player]:
		var d = 0.2
		tw.interpolate_property(p.attack_phase_spacer, "rect_min_size:y", p.attack_phase_spacer.rect_size.y, attack_phase_height, d, Tween.TRANS_EXPO, Tween.EASE_IN)

func end_attack_phase():
	if not attack_phase:
		return
	attack_phase = false
	inactive_player().hide_attack_indicate_label()
	for p in [opponent, player]:
		var d = 0.2
		tw.interpolate_property(p.attack_phase_spacer, "rect_min_size:y", p.attack_phase_spacer.rect_size.y, 0, d, Tween.TRANS_EXPO, Tween.EASE_IN)

func active_player():
	if opponent.is_playing:
		return opponent
	elif player.is_playing:
		return player

func inactive_player():
	if opponent.is_playing:
		return player
	elif player.is_playing:
		return opponent

func _input(event):
		if event is InputEventKey:
			var card_to_add = card_cache.card(card_cache.get_all_card_names()[randi() % card_cache.get_all_card_names().size()])
			if event.scancode == KEY_F and event.pressed:
				player.add_card(card_cache.card("flo"))
			if event.scancode == KEY_W and event.pressed:
				player.add_card(card_to_add)
			if event.scancode == KEY_Q and event.pressed:
				opponent.add_card(card_to_add)
			if event.scancode == KEY_R and event.pressed:
				tw.interpolate_property(player.bf_h_box, "margin_bottom", 0, -100, 4,Tween.TRANS_LINEAR,Tween.EASE_OUT)

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