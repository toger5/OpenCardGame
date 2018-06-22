extends Control

enum TableLocation {BF, HAND, GRAVEYARD, DECK, OPPONENT_HAND, OPPONENT_BF}

onready var player = $player
onready var opponent = $opp

onready var opp_hand_control = $opp/right_area/hand
onready var opp_bf_control = $opp/right_area/bf
onready var hand_control = $player/right_area/hand
onready var bf_control = $player/right_area/bf

onready var hand_card_h_box = hand_control.get_node("HBoxContainer")
onready var bf_card_h_box = bf_control.get_node("HBoxContainer")
onready var opp_hand_card_h_box = opp_hand_control.get_node("HBoxContainer")
onready var opp_bf_card_h_box = opp_bf_control.get_node("HBoxContainer")

onready var card_preview_tr = get_node("../TextureRect")
onready var deck = $player/left_area/deck

var tw = Tween.new()
var MIN_HAND_HIGHT = 240
var BF_CARD_HEIGHT = 350
var DRAG_SIZE_HIGHT = 240

var hand = []
var mana_cards = []

var dragged_card = null
var drag_offset = Vector2()
var drag_offset_factor = 1
var hovered_card = null

func _ready():
	add_child(tw)
	opp_hand_control.rect_min_size.y = MIN_HAND_HIGHT
	hand_control.rect_min_size.y = MIN_HAND_HIGHT
	setup_game()
	card_preview_tr.rect_size.y = card_preview_tr.rect_size.x / card_renderer.card_size.aspect()

func setup_game():
	hand = [card_cache.card("a"),
		card_cache.card("b"),
		card_cache.card("mana_red"),
		card_cache.card("mana_blue"),
		card_cache.card("mana_blue"),
		card_cache.card("flo"),
		card_cache.card("flosC")]
	for card in hand:
		add_card_to_hand(card)

func add_card(card):
	var holder = card.new_holder_node(MIN_HAND_HIGHT)
	holder.connect("mouse_entered",self,"mouse_entered_card_tex",[card])
	holder.connect("mouse_exited",self,"mouse_exited_card_tex",[card])
	return holder

func add_card_to_hand(card, initial_rect = null):
	var card_holder = add_card(card)
	hand_card_h_box.add_child(card_holder)
	hand_card_h_box.move_child(card_holder, 0)
	card.location = card.LocationType.HAND
	if not hand.has(card):
		hand.append(card)
	yield(hand_card_h_box, "sort_children")
	if initial_rect:
		card.texture_node.rect_global_position = initial_rect.position
		card.texture_node.rect_size = initial_rect.size
		mouse_exited_card_tex(card, true)

func add_card_to_bf(card):
	bf_card_h_box.add_child(add_card(card))
	card.location = card.LocationType.BATTLEFIELD

func move_card_to(card, table_location):
	var h_box
	match table_location:
		TableLocation.BF:
			h_box = bf_card_h_box
			if card.location == card.LocationType.HAND:
				card._casted()
				if card.type == card.CardType.MANA:
					h_box = null
					hand_card_h_box.remove_child(card.holder_node)
					mana_cards.append(card)
					card.location = card.LocationType.MANA
				elif card.type == card.CardType.CREATURE:
					card.location = card.LocationType.BATTLEFIELD
				
		TableLocation.HAND:
			#sollte eigentlich nicht gehen... vielleicht sollte player gechoosed werden...
#			h_box = hand_card_h_box
#			card.location = card.LocationType.HAND
			pass
		TableLocation.OPPONENT_BF:
			var target_card = card_under_mouse()
			if target_card and card.casted:
				card._action_on_card(target_card)
		TableLocation.OPPONENT_HAND:
			card._action_on_opponent()
	if h_box:
		var tex_global_rect = card.texture_node.get_global_rect()
		card.set_card_holder_height(h_box.rect_size.y)
		card.holder_node.get_parent().remove_child(card.holder_node)
		h_box.add_child(card.holder_node)
		yield(h_box, "sort_children")
		card.texture_node.rect_global_position = tex_global_rect.position
		card.texture_node.rect_size = tex_global_rect.size
	mouse_exited_card_tex(dragged_card)
	dragged_card = null

func mouse_entered_card_tex(card):
	if dragged_card: 
		return
	hovered_card = card
	if card.location == card.LocationType.BATTLEFIELD:
		card_preview_tr.texture = card_renderer.get_card_texture(card)
		tw.interpolate_property(card_preview_tr, "modulate:a", card_preview_tr.modulate.a, 1,0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	elif card.location == card.LocationType.HAND:
		var t_trans = Tween.TRANS_EXPO
		var t_ease = Tween.EASE_OUT
		var d = 2
		var ct = card.texture_node
		VisualServer.canvas_item_set_z_index(ct.get_canvas_item(),2)
		tw.stop(ct)
		tw.interpolate_property(ct, "margin_top",0, -800, d,t_trans,t_ease)
		tw.interpolate_property(ct, "margin_left",0, -200, d,t_trans,t_ease)
		tw.interpolate_property(ct, "margin_right",0, 200, d,t_trans,t_ease)
		tw.interpolate_property(ct, "margin_bottom",0, -MIN_HAND_HIGHT, d,t_trans,t_ease)
		tw.start()

func mouse_exited_card_tex(card, force = false):
	if force or (hovered_card and hovered_card == card):
		hovered_card = null
	else:
		return
#	if card.location == card.LocationType.BATTLEFIELD and card_preview_tr.modulate.a > 0:
#		card_preview_tr.texture = null
	tw.interpolate_property(card_preview_tr, "modulate:a",card_preview_tr.modulate.a, 0, 0.2,Tween.TRANS_LINEAR, Tween.EASE_OUT)
#	elif card.location == card.LocationType.HAND:
	var t_trans = Tween.TRANS_BOUNCE
	var t_ease = Tween.EASE_OUT
	var d = 0.6
	var ct = card.texture_node
	VisualServer.canvas_item_set_z_index(ct.get_canvas_item(),2)
	tw.stop(ct)
	tw.interpolate_property(ct, "margin_top"   , ct.margin_top   ,0, d,t_trans,t_ease)
	tw.interpolate_property(ct, "margin_left"  , ct.margin_left  ,0, d,t_trans,t_ease)
	tw.interpolate_property(ct, "margin_right" , ct.margin_right ,0, d,t_trans,t_ease)
	tw.interpolate_property(ct, "margin_bottom", ct.margin_bottom,0, d,t_trans,t_ease)
	tw.start()
	yield(tw, "tween_completed")
	VisualServer.canvas_item_set_z_index(ct.get_canvas_item(),0)

func _input(event):
		if event is InputEventKey:
			if event.scancode == KEY_W and event.pressed:
				add_card_to_hand(card_cache.card("a"))
			print(event.as_text())
		elif event is InputEventMouseButton:
			#Pressed
			if event.pressed and event.button_index == BUTTON_LEFT and hovered_card:
				dragged_card = hovered_card
				VisualServer.canvas_item_set_z_index(dragged_card.texture_node.get_canvas_item(),2)
				drag_offset = dragged_card.texture_node.rect_global_position - (get_global_mouse_position() - (dragged_card.texture_node.rect_size /2))
				drag_offset_factor = 1
				tw.stop(dragged_card.texture_node)
				tw.interpolate_property(dragged_card.texture_node, "rect_size", dragged_card.texture_node.rect_size, Vector2(dragged_card.texture_node.texture.get_width(), dragged_card.texture_node.texture.get_height())*DRAG_SIZE_HIGHT/dragged_card.texture_node.texture.get_height(), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
			#Released
			if not event.pressed and event.button_index == BUTTON_LEFT and dragged_card:
	#			if mouse_over() == TableLocation.BF:
				move_card_to(dragged_card, mouse_over())

func _process(delta):
	if dragged_card:
		drag_offset_factor = max(0,(drag_offset_factor * 0.8) - delta)
		var t = dragged_card.texture_node
		t.rect_global_position = (get_global_mouse_position() - t.rect_size/2) + drag_offset * drag_offset_factor

func mouse_over():
	var mo
	var mp = get_global_mouse_position()
	if hand_control.get_global_rect().has_point(mp):
		mo = TableLocation.HAND
	elif bf_control.get_global_rect().has_point(mp):
		mo = TableLocation.BF
	elif opp_hand_control.get_global_rect().has_point(mp):
		mo = TableLocation.OPPONENT_HAND
	elif opp_bf_control.get_global_rect().has_point(mp):
		mo = TableLocation.OPPONENT_BF
	return mo
	
func card_under_mouse():
	var mp = get_global_mouse_position()
	var over = null
	match mouse_over():
		TableLocation.HAND:
			for c in hand_card_h_box.get_children():
				if c.get_global_rect().has_point(mp):
					over = c
		TableLocation.BF:
			for c in hand_card_h_box.get_children():
				if c.get_global_rect().has_point(mp):
					over = c
		TableLocation.OPPONENT_BF:
			for c in opp_bf_card_h_box.get_children():
				if c.get_global_rect().has_point(mp):
					over = c
	return over