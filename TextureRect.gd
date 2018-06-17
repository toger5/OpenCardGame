extends TextureRect

var c = load("res://cards/a.gd").new()
func _ready():
	c.render_on(self)
	
func _on_Button_pressed():
	if texture:
		texture = null
	else:
		c.update_tex()
