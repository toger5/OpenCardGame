extends Object

enum CardType {INSTANT, SORCERY, CREATURE, LAND, ENCHANTMENT, ARTIFACT, PLANESWALKER}

signal casted(card)
signal location_changed(card)

var HolderClass = preload("res://card_class/holder.tscn")

#props
var name = "[Define Name]" setget update_tex
var text = "[Define text]"
var type = []
var img_path = "should get set in init to path of the gd script"
var mana_cost = {}#saved as a dict with keys of ManaType
var is_reaction = false

#staus
var location = null setget __location_changed#CardLocation 
var tapped = false setget _tapped_changed
var casted = false
var casting = false

#environment variables
var texture_node
var holder_node setget ,_holder_node_get
var player #is added in player_side.gd
var opponent
var table
var deck

#signals
signal tapped_changed

#hleper variables
var timer = Timer.new()

#events
func _init():
	img_path = get_script().resource_path.replace(".gd",".png")
	table = Global.game_table
	for t in ManaType.list:
		mana_cost[t] = 0

func _cast():
	casted = true
	print("card got casted")
	emit_signal("casted", self)
func _action_on_card(card):
	print("action on card: "+ str(card.name))
	pass
func _action_on_opponent():
	print("action on opponent with: "+ str(name))
	pass
func _location_changed():
	pass
func _can_cast():
	return true
func _tapped_changed(new_tap_status):
	if not new_tap_status == tapped:
		tapped = new_tap_status
		emit_signal("tapped_changed")
#internal events
func __location_changed(new_val):
	location = new_val
	emit_signal("location_changed", self)

#func _on_drop_to_cast():
	

#helper functions
func update_tex():
	texture_node.texture = card_renderer.get_card_texture(self)

func render_on(tex):
	tex = card_renderer.get_card_texture(self)

func _holder_node_get():
	if not holder_node:
		new_holder_node(player.hand_h_box.rect_size.y)
	return holder_node

func new_holder_node(height):
	if holder_node:
		return
	holder_node = HolderClass.instance()
	holder_node.card = self
	texture_node = holder_node.get_node("TextureRect")
	update_tex()
#	holder_node.connect("drag_start", self, "_on_drag")
#	holder_node.connect("dropped", self, "_on_drop")
	return holder_node


#TODO move to some global class
func hover_card_hand_size():
	var y = holder_node.get_tree().root.size.y
	var screen_factor = 0.4
	return Vector2(y*screen_factor*card_renderer.card_size.aspect(), y*screen_factor)
func hover_card_top_right_size():
	var screen_factor = 0.5
	var y = holder_node.get_tree().root.size.y
	return Vector2(y*screen_factor*card_renderer.card_size.aspect(), y*screen_factor)

# card methods
func start_cast_timer(wait_time):
	VisualServer.canvas_item_set_z_index(texture_node.get_canvas_item(),2)
	casting = true
	if not timer.get_parent():
		holder_node.add_child(timer)
	timer.wait_time = wait_time
	holder_node.timer = timer
	timer.start()
	yield(timer, "timeout")
	casting = false
	VisualServer.canvas_item_set_z_index(texture_node.get_canvas_item(),0)

func move_to(h_box):
	var tex_global_rect = texture_node.get_global_rect()
	holder_node.get_parent().remove_child(holder_node)
	h_box.add_child(holder_node)
	yield(h_box, "sort_children")
	texture_node.rect_global_position = tex_global_rect.position
	texture_node.rect_size = tex_global_rect.size
	holder_node.animate_to_holder()