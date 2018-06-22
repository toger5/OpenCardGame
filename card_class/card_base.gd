extends Object

enum CardType {INSTANT, SORCERY, CREATURE, PLANESWALKER, LAND, ENCHANTMENT, ARTIFACT}
enum ManaType {WHITE, BLUE, BLACK, RED, GREEN, COLORLESS}#this order should always be used ex. in mana costs (its the original mtg order)
enum LocationType {DECK, HAND, GRAVEYARD, BATTLEFIELD}

#props
var name = "[Define Name]" setget update_tex
var text = "[Define text]"
var type = []
var img_path = "should get set in init to path of the gd script"
var mana_cost #saved as a dict with keys of ManaType

#staus
var location = null #LocationType
var tapped = false
var casted = false
#environment variables
var texture_node
var holder_node setget holder_node_setget

func _init():
	var im_p = get_script().resource_path.replace(".gd",".png")
	img_path = im_p
#events
func _casted():
	casted = true
	print("card got casted")
func _action_on_card(card):
	print("action on card: "+ str(card.name))
	pass
func _action_on_opponent():
	print("action on opponent with: "+ str(name))
	pass
#helper functions
func update_tex():
	if (texture_node is Sprite) or (texture_node is TextureRect):
		texture_node.texture = card_renderer.get_card_texture(self)

func new_sprite():
	texture_node = Sprite.new()
	update_tex()
	return texture_node

func new_texture_rect():
	texture_node = TextureRect.new()
	texture_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_node.expand = true
	update_tex()
	return texture_node

func render_on(tex_obj):
	texture_node = tex_obj
	update_tex()

func holder_node_setget(new_val):
	if new_val:
		holder_node = new_val
	else:
		new_card_holder(100)
	return holder_node
func new_holder_node(height):
	if holder_node:
		return
	holder_node = Control.new()
	var new_card_tex = new_texture_rect()
	holder_node.rect_min_size.x = 8+(height * card_renderer.card_size.aspect())
	new_card_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder_node.add_child(new_card_tex)
	new_card_tex.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	return holder_node
#	hand_card_h_box.add_child(holder)
func set_card_holder_height(height):
	holder_node.rect_min_size.x = 8 + (height * card_renderer.card_size.aspect())