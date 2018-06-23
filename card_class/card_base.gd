extends Object

enum CardType {INSTANT, CREATURE, MANA}
enum CardInteractionState {NONE, HOVER, DRAG} #TODO Renae to InteractionState

signal casted(card)
signal location_changed(card)

var HolderClass = preload("res://card_class/holder.tscn")

#props
var name = "[Define Name]" setget update_tex
var text = "[Define text]"
var type = []
var img_path = "should get set in init to path of the gd script"
var mana_cost #saved as a dict with keys of ManaType
var is_reaction = false

#staus
var location = null setget __location_changed#CardLocation 
var tapped = false
var casted = false
var casting = false
var interaction_state = CardInteractionState.NONE

#environment variables
var texture_node
var holder_node setget ,holder_node_get
var player
var opponent
var table
var deck

#hleper variables
var timer = Timer.new()

#events
func _init():
	var im_p = get_script().resource_path.replace(".gd",".png")
	img_path = im_p
	table = Global.game_table
	player = table.get_node("player")
	opponent = table.get_node("opp")
	timer.one_shot = true
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

#internal events
func __location_changed(new_val):
	location = new_val
	emit_signal("location_changed", self)

#helper functions
func update_tex():
	if (texture_node is Sprite) or (texture_node is TextureRect):
		texture_node.texture = card_renderer.get_card_texture(self)

func render_on(tex_obj):
	texture_node = tex_obj
	update_tex()

func holder_node_get():
	if not holder_node:
		new_holder_node(player.MIN_HAND_HIGHT)
	return holder_node

func new_holder_node(height):
	if holder_node:
		return
	holder_node = HolderClass.instance()
	holder_node.card = self
	texture_node = holder_node.get_node("TextureRect")
	update_tex()
	holder_node.rect_min_size.x = (height * card_renderer.card_size.aspect())
	holder_node.connect("mouse_entered", self, "_mouse_enter_card")
	holder_node.connect("mouse_exited", self, "_mouse_exit_card")
	return holder_node

func set_card_holder_height(height):
	holder_node.rect_min_size.x = 8 + (height * card_renderer.card_size.aspect())

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
func start_card_timer(wait_time):
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
	
func _mouse_enter_card():
	interaction_state = CardInteractionState.HOVER
	if location == CardLocation.HAND and not casting: 
		holder_node.animate_card_big()
	if location == CardLocation.BATTLEFIELD:
		player.get_parent().show_card_preview(self)

func _mouse_exit_card():
	holder_node.animate_to_holder()
	player.get_parent().hide_card_preview(self)
	interaction_state = CardInteractionState.NONE