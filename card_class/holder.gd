extends Control

enum InteractionState {NONE, HOVER, DRAG}

onready var progress = $TextureRect/ProgressBar
onready var tex_node = $TextureRect
onready var tween = $Tween

var timer setget set_timer
var card
var drag_offset = Vector2()
var drag_offset_factor = 1

#state and helper vars
var interaction_state = InteractionState.NONE
var is_indication_label_shown = false
var process_for_drag = false
var process_for_progressbar = false
signal dropped(card)
signal drag_start(card)

func _ready():
	set_process(false)
	connect("mouse_entered", self, "_mouse_entered")
	connect("mouse_exited", self, "_mouse_exited")
	card.connect("tapped_changed", self, "animate_tapping")

func _process(delta):
#	if not (process_for_drag or process_for_progressbar):
#		return
	print("process of card_node aka: the all mighty \"holder\"...  this print is there so we can see if process is runnign although it hsouldnt")
	if timer:
		progress.value = 1 - timer.time_left / timer.wait_time
	if interaction_state == InteractionState.DRAG:
		drag_offset_factor = max(0,(drag_offset_factor * 0.8) - delta)
		tex_node.rect_global_position = (get_global_mouse_position() - tex_node.rect_size/2) + drag_offset * drag_offset_factor
		
		if card.location == CardLocation.BATTLEFIELD:
			#check if over opponent area
			var current_table_loc = TableLocation.mouse_pos()
			
			var OPPONENT_BF = TableLocation.opponent_bf(card.player)
			
			if current_table_loc == OPPONENT_BF and not is_indication_label_shown:
				card.player.indicate_attack_phase(true, 2) #true: indicate with gap, 2: with high contrast label
				is_indication_label_shown = true
			elif current_table_loc != OPPONENT_BF and is_indication_label_shown:
				card.player.indicate_attack_phase(true, 1) #true: indicate with gap, 1: for low contrast lable
				is_indication_label_shown = false

func _enter_tree():
	get_parent().connect("resized", self, "update_holder_size")
	update_holder_size()
func _exit_tree():
	get_parent().disconnect("resized", self, "update_holder_size")

func set_timer(new_val):
	timer = new_val
	progress.visible = true
	set_process(true)
	process_for_progressbar = true
	update_set_process()
	if not timer.is_connected("timeout", self, "_timeout"):
		timer.connect("timeout", self, "_timeout")

func _timeout():
	set_process(false)
	process_for_progressbar = false
	update_set_process()
	progress.visible = false

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_RIGHT:
			if card.location == CardLocation.BATTLEFIELD:
				card.tapped = not card.tapped
				return
		if event.pressed and event.button_index == BUTTON_LEFT:
			interaction_state = InteractionState.DRAG
			process_for_drag = true
			update_set_process()
			VisualServer.canvas_item_set_z_index(tex_node.get_canvas_item(),2)
			drag_offset = tex_node.rect_global_position - (get_global_mouse_position() - (tex_node.rect_size /2))
			drag_offset_factor = 1
			tween.stop(tex_node)
			tween.interpolate_property(tex_node, "rect_size", tex_node.rect_size, Vector2(tex_node.texture.get_width(), tex_node.texture.get_height())*card.player.DRAG_SIZE_HIGHT/tex_node.texture.get_height(), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
			if card.location == CardLocation.BATTLEFIELD:
				card.player.indicate_attack_phase(true, 1)
func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == BUTTON_LEFT:
			if interaction_state == InteractionState.DRAG:
				process_for_drag = false
				interaction_state == InteractionState.NONE
				update_set_process()
				emit_signal("dropped", card)

func _mouse_entered():
	interaction_state = InteractionState.HOVER
	if card.location == CardLocation.HAND and not card.casting: 
		animate_card_big()
	if card.location == CardLocation.BATTLEFIELD:
		card.player.get_parent().show_card_preview(card)

func _mouse_exited():
	interaction_state = InteractionState.NONE
	if card.location == CardLocation.HAND and not card.casting: 
		animate_to_holder()
	if card.location == CardLocation.BATTLEFIELD:
		card.player.get_parent().hide_card_preview(card)

func animate_card_big():
	var t_trans = Tween.TRANS_EXPO
	var t_ease = Tween.EASE_OUT
	var d = 2
	var ct = tex_node
	VisualServer.canvas_item_set_z_index(ct.get_canvas_item(), 4)
	tween.stop_all()
	var si = card.hover_card_hand_size()
	for p in card.player.get_property_list():
		print(p["name"])
	var m_top = rect_size.y/2 - si.y
	var m_bottom = -rect_size.y/2
	if card.player.table_side == card.player.TableSide.TOP:
		var margin_temp = m_top
		m_top = -m_bottom
		m_bottom = -margin_temp
	
	tween.interpolate_property(ct, "margin_top", 0, m_top , d,t_trans,t_ease)
	tween.interpolate_property(ct, "margin_bottom", 0, m_bottom, d,t_trans,t_ease)
	tween.interpolate_property(ct, "margin_left", 0, -(si.x +rect_size.x)/2, d,t_trans,t_ease)
	tween.interpolate_property(ct, "margin_right", 0, (si.x +rect_size.x)/2, d,t_trans,t_ease)
	tween.start()

func animate_to_holder():
	var ct = tex_node
	VisualServer.canvas_item_set_z_index(ct.get_canvas_item(),3)
	tween.stop_all()
#	tween.resume(self, "update_tap_status")
	var t_trans = Tween.TRANS_BOUNCE
	var t_ease = Tween.EASE_OUT
	var d = 0.6
	tween.interpolate_property(ct, "margin_top"   , ct.margin_top   ,0, d,t_trans,t_ease)
	tween.interpolate_property(ct, "margin_left"  , ct.margin_left  ,0, d,t_trans,t_ease)
	tween.interpolate_property(ct, "margin_right" , ct.margin_right ,0, d,t_trans,t_ease)
	tween.interpolate_property(ct, "margin_bottom", ct.margin_bottom,0, d,t_trans,t_ease)
	tween.start()
#	yield(player.get_tree().create_timer(d*2), "timeout")
	yield(tween, "tween_completed")
	VisualServer.canvas_item_set_z_index(ct.get_canvas_item(),0)
	
func update_holder_size():
	if get_parent() is HBoxContainer:
		if card.tapped:
			rect_min_size.x = get_parent_control().rect_size.y
		else:
			rect_min_size.x = get_parent_control().rect_size.y * card_renderer.card_size.aspect()

func animate_tapping():
#	rect_min_size.x += 10
	if card.location == CardLocation.BATTLEFIELD:
		var t = 0.5
		if card.tapped:
			tween.interpolate_property(self, "rect_min_size:x", rect_min_size.x, tex_node.rect_size.y, t, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
			yield(tween, "tween_completed")
			tex_node.set_pivot_offset(rect_size/2)
			tween.interpolate_property(tex_node, "rect_rotation", 0, 90, t, Tween.TRANS_EXPO, Tween.EASE_OUT)
		if not card.tapped:
			tween.interpolate_property(tex_node, "rect_rotation", 90, 0, t, Tween.TRANS_EXPO, Tween.EASE_OUT)
			yield(tween, "tween_completed")
			var old_x = rect_size.x
			update_holder_size()
			tween.interpolate_property(self, "rect_min_size:x", rect_size.x, rect_min_size.x, t, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		tween.start()

func update_set_process():
	set_process(process_for_drag or process_for_progressbar)
