extends Node

var card_scn = preload("res://card_class/card_creation/card.tscn")

var card_size = Vector2()# setget card_size_checked
var card_viewports = {}
func add_card_vp(card):
	var render_vp = Viewport.new()
	var card_node = card_scn.instance()
	card_viewports[card] = render_vp
	add_child(render_vp)
	render_vp.render_target_v_flip = true
	render_vp.transparent_bg = true
	render_vp.add_child(card_node)
	render_vp.render_target_update_mode = Viewport.UPDATE_ONCE
	render_vp.size = card_node.rect_size
	card_size = render_vp.size
	render_vp.usage = Viewport.USAGE_2D
	
	print("add_card_vp, there are "+str(card_viewports.size()) + " viewports")
	return render_vp

func remove_card_vp(card):
	var render_vp = card_viewports[card]
	card_viewports.erase(card)
	render_vp.queue_free()
	print("remove_card_vp, there are "+str(card_viewports.size()) + " viewports")
	return render_vp

func get_card_texture(card):
	var render_vp
	if not card_viewports.has(card):
		render_vp = add_card_vp(card)
	else:
		render_vp = card_viewports[card]
	
	var card_node = render_vp.get_children()[0]
	render_vp.render_target_update_mode = Viewport.UPDATE_ONCE
	card_node.populate_with(card)
	return card_viewports[card].get_texture()
