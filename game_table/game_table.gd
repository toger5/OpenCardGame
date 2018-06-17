extends Control

onready var opp_hand_control = $"VBoxContainer/opp_hand"
onready var opp_bf_control = $"VBoxContainer/opp_bf"
onready var hand_control = $"VBoxContainer/hand"
onready var bf_control = $"VBoxContainer/bf"
var tw = Tween.new()
onready var hand_card_h_box = hand_control.get_node("HBoxContainer")
onready var bf_card_h_box = bf_control.get_node("HBoxContainer")
var MIN_HAND_HIGHT = 150
var DRAG_SIZE_HIGHT = 240

var hand = [card_cache.card("a"),
		card_cache.card("b"),
		card_cache.card("flosC"),
		card_cache.card("flosC"),
		card_cache.card("b")]

enum MouseOver {BF, HAND, GRAVEYARD, DECK, OPPONENT}
var dragged_card = null
var drag_offset = Vector2()
var drag_offset_factor = 1
var hovered_card = null

func _ready():
	add_child(tw)
	opp_hand_control.rect_min_size.y = MIN_HAND_HIGHT
	hand_control.rect_min_size.y = MIN_HAND_HIGHT
	setup_game()

func setup_game():
	hand[0].name = "just test name"
	for card in hand:
		add_card_to_hand(card)
		
func add_card_to_hand(card):
	var holder = Control.new()
	var new_card_tex = card.new_texture_rect()
	holder.rect_min_size.x = 8+(card_renderer.card_size * (MIN_HAND_HIGHT/card_renderer.card_size.y)).x
	hand_card_h_box.add_child(holder)
	new_card_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(new_card_tex)
	print("holder filder"+ str(holder.mouse_filter))
	holder.connect("mouse_entered",self,"mouse_entered_card_tex",[new_card_tex])
	holder.connect("mouse_exited",self,"mouse_exited_card_tex",[new_card_tex])
	new_card_tex.set_anchors_and_margins_preset(Control.PRESET_WIDE)
func add_card_to_bf(card):
	var holder = Control.new()
	var new_card_tex = card.new_texture_rect()
	holder.rect_min_size.x = 8+(card_renderer.card_size * (bf_card_h_box.rect_size.y/card_renderer.card_size.y)).x
	bf_card_h_box.add_child(holder)
	new_card_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(new_card_tex)
	print("holder filder"+ str(holder.mouse_filter))
	holder.connect("mouse_entered",self,"mouse_entered_card_tex",[new_card_tex])
	holder.connect("mouse_exited",self,"mouse_exited_card_tex",[new_card_tex])
	new_card_tex.set_anchors_and_margins_preset(Control.PRESET_WIDE)
func move_card_to_bf(holder):
	holder.rect_min_size.x = 8+(card_renderer.card_size * (bf_card_h_box.rect_size.y/card_renderer.card_size.y)).x
	holder.get_parent().remove_child(holder)
	bf_card_h_box.add_child(holder)
func mouse_entered_card_tex(card_tex):
	if dragged_card: 
		return
	tw.stop(card_tex)
	var t_trans = Tween.TRANS_EXPO
	var t_ease = Tween.EASE_OUT
	var d = 2
	for c in hand:
		if c.texture_node == card_tex:
			hovered_card = c
	tw.interpolate_property(card_tex, "margin_top",0, -800, d,t_trans,t_ease)
	tw.interpolate_property(card_tex, "margin_left",0, -200, d,t_trans,t_ease)
	tw.interpolate_property(card_tex, "margin_right",0, 200, d,t_trans,t_ease)
	tw.interpolate_property(card_tex, "margin_bottom",0, -MIN_HAND_HIGHT, d,t_trans,t_ease)
	tw.start()

func mouse_exited_card_tex(card_tex):
	if hovered_card and hovered_card.texture_node == card_tex:
		hovered_card = null
	else:
		return
	tw.stop(card_tex)
	var t_trans = Tween.TRANS_EXPO
	var t_ease = Tween.EASE_OUT
	var d = 2
	tw.interpolate_property(card_tex, "margin_top",card_tex.margin_top,0, d,t_trans,t_ease)
	tw.interpolate_property(card_tex, "margin_left",card_tex.margin_left,0, d,t_trans,t_ease)
	tw.interpolate_property(card_tex, "margin_right",card_tex.margin_right,0, d,t_trans,t_ease)
	tw.interpolate_property(card_tex, "margin_bottom", card_tex.margin_bottom,0, d,t_trans,t_ease)
	tw.start()

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_W and event.pressed:
			add_card_to_hand(card_cache.card("a"))
	if event is InputEventMouseButton:
		#Pressed
		if event.pressed and event.button_index == BUTTON_LEFT and hovered_card:
			dragged_card = hovered_card
			drag_offset = dragged_card.texture_node.rect_global_position - (get_global_mouse_position() - (dragged_card.texture_node.rect_size /2))
			drag_offset_factor = 1
#			dragged_card.texture_node.set_as_toplevel(true)
			tw.stop(dragged_card.texture_node)
			tw.interpolate_property(dragged_card.texture_node, "rect_size", dragged_card.texture_node.rect_size, Vector2(dragged_card.texture_node.texture.get_width(), dragged_card.texture_node.texture.get_height())*DRAG_SIZE_HIGHT/dragged_card.texture_node.texture.get_height(), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
		#Released
		if not event.pressed and event.button_index == BUTTON_LEFT and dragged_card:
			if mouse_over() == MouseOver.BF:
				move_card_to_bf(dragged_card.texture_node.get_parent())
#				dragged_card._attack()#TODO: need to add release checks and based on where it is released call the appropriate events
				
			mouse_exited_card_tex(dragged_card.texture_node)
			dragged_card = null

func _process(delta):
	if dragged_card:
		drag_offset_factor = max(0,(drag_offset_factor * 0.9) - (delta))
		var t = dragged_card.texture_node
		print(drag_offset_factor)
		t.rect_global_position = (get_global_mouse_position() - t.rect_size/2) + drag_offset * drag_offset_factor
#		var tex_pos = t.rect_global_position
#		var tar_pos = get_global_mouse_position() - (t.rect_size)
#		var new_pos = Vector2()
#		var length = (tex_pos - tar_pos).length()
#		if length < 20:
#			print("else")
#			new_pos = tar_pos
#		else:
#			var dir = (tar_pos - tex_pos).normalized()
#			var dir_move = dir * delta * length
#			new_pos = tex_pos + dir_move
#		t.rect_global_position = new_pos

func mouse_over():
	var mo
	var mp = get_global_mouse_position()
	if hand_control.get_global_rect().has_point(mp):
		mo = MouseOver.HAND
	elif bf_control.get_global_rect().has_point(mp):
		mo = MouseOver.BF
	elif opp_hand_control.get_global_rect().has_point(mp):
		mo = MouseOver.OPPONENT
	return mo
	
func card_under_mouse():
	var mo = mouse_over()
	var mp = get_global_mouse_position()
	var over = null
	if mo == MouseOver.HAND:
		for c in hand_card_h_box:
			if c.get_global_rect().has_point(mp):
				over = c
	elif mo == MouseOver.BF:
		for c in hand_card_h_box:
			if c.get_global_rect().has_point(mp):
				over = c
	return over



