extends Object

enum CardType {INSTANT, SORCERY, CREATURE, LAND, ENCHANTMENT, ARTIFACT, PLANESWALKER}
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
		new_holder_node(player.hand_h_box.rect_size.y)
	return holder_node

func new_holder_node(height):
	if holder_node:
		return
	holder_node = HolderClass.instance()
	holder_node.card = self
	texture_node = holder_node.get_node("TextureRect")
	update_tex()
	holder_node.rect_min_size.x = 10 + (height * card_renderer.card_size.aspect())
	holder_node.connect("dropped", self, "_on_drop_to_cast")

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

func _on_drop_to_cast():
	match location:
		CardLocation.HAND:
			if player.get_parent().mouse_over_cast_area() and player.can_cast(self):
				player.get_parent().queue_cast_card(self)
			else:
				animate_to_holder()
		CardLocation.BATTLEFIELD:
			animate_to_holder()
