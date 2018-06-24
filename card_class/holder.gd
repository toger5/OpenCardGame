extends Control

onready var progress = $TextureRect/ProgressBar
var timer setget set_timer
var card
var drag_offset = Vector2()
var drag_offset_factor = 1

var process_for_drag = false
var process_for_progressbar = false
onready var tex_node = $TextureRect
onready var tween = $Tween

signal dropped

func _ready():
	set_process(false)
	connect("mouse_entered", self, "_mouse_entered")
	connect("mouse_exited", self, "_mouse_exited")

func _process(delta):
	print("process of card_node aka: the all mighty \"holder\"...")
	if timer:
		progress.value = 1 - timer.time_left / timer.wait_time
	if card.interaction_state == card.CardInteractionState.DRAG:
		drag_offset_factor = max(0,(drag_offset_factor * 0.8) - delta)
		tex_node.rect_global_position = (get_global_mouse_position() - tex_node.rect_size/2) + drag_offset * drag_offset_factor

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
		if event.pressed and event.button_index == BUTTON_LEFT:
			card.interaction_state = card.CardInteractionState.DRAG
			process_for_drag = true
			update_set_process()
			VisualServer.canvas_item_set_z_index(tex_node.get_canvas_item(),2)
			drag_offset = tex_node.rect_global_position - (get_global_mouse_position() - (tex_node.rect_size /2))
			drag_offset_factor = 1
			tween.stop(tex_node)
			tween.interpolate_property(tex_node, "rect_size", tex_node.rect_size, Vector2(tex_node.texture.get_width(), tex_node.texture.get_height())*card.player.DRAG_SIZE_HIGHT/tex_node.texture.get_height(), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == BUTTON_LEFT:
			if card.interaction_state == card.CardInteractionState.DRAG:
				process_for_drag = false
				update_set_process()
				emit_signal("dropped")

func _mouse_entered():
	card.interaction_state = card.CardInteractionState.HOVER
	if card.location == CardLocation.HAND and not card.casting: 
		animate_card_big()
	if card.location == CardLocation.BATTLEFIELD:
		card.player.get_parent().show_card_preview(card)

func _mouse_exited():
	card.interaction_state = card.CardInteractionState.NONE
	if not card.casting:
		animate_to_holder()
		card.player.get_parent().hide_card_preview(card)

func animate_card_big():
	var t_trans = Tween.TRANS_EXPO
	var t_ease = Tween.EASE_OUT
	var d = 2
	
	var ct = tex_node
	VisualServer.canvas_item_set_z_index(ct.get_canvas_item(), 4)
	tween.stop_all()
	var si = card.hover_card_hand_size()
	tween.interpolate_property(ct, "margin_top",0, -si.y + rect_size.y/2 , d,t_trans,t_ease)
	tween.interpolate_property(ct, "margin_left",0, -(si.x +rect_size.x)/2, d,t_trans,t_ease)
	tween.interpolate_property(ct, "margin_right",0, (si.x +rect_size.x)/2, d,t_trans,t_ease)
	tween.interpolate_property(ct, "margin_bottom",0, rect_size.y/2 -rect_size.y, d,t_trans,t_ease)
	tween.start()

func animate_to_holder():
	var ct = tex_node
	VisualServer.canvas_item_set_z_index(ct.get_canvas_item(),4)
	tween.stop_all()
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
		rect_min_size.x = get_parent_control().rect_size.y * card_renderer.card_size.aspect()

func update_set_process():
	set_process(process_for_drag or process_for_progressbar)
