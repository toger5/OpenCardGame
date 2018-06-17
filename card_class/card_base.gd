extends Object

enum CardType {INSTANT, CREATURE}
enum ManaType {RED, BLUE}
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

#environment variables
var texture_node

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
#events
func _casted():
	print("card got casted")
func _init():
	var im_p = get_script().resource_path.replace(".gd",".png")
	img_path = im_p