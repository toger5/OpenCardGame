tool
extends VBoxContainer
export var show_children = false setget _show_children
var tw = Tween.new()
onready var this_player = get_parent().get_parent()

func _ready():
	this_player.connect("mana_changed", self, "update")
	

func update(mana):
	var index = 0
	for t in ManaType.list:
		if mana.has(t):
			var lbl = get_child(index)
			lbl.text = str(mana[t])
			if not lbl.text == str(mana[t]):
				var sb = lbl.get_stylebox("normal")
				tw.interpolate_property(sb, "bg_color", Color(1,0,0), sb.bg_color, 1, Tween.TRANS_EXPO, Tween.EASE_OUT)
				tw.start()
		index += 1
func _show_children(new_val):
	var mtClass = load("res://Autoload/ManaType.gd")
	var ManaType = mtClass.new()
	show_children = new_val
	for c in get_children():
		remove_child(c)
	if show_children:
		for t in ManaType.list:
			var lbl = Label.new()
			lbl.align = ALIGN_CENTER
			lbl.valign = ALIGN_CENTER
			lbl.add_color_override("font_color", Color(1,1,1))
			lbl.rect_min_size = Vector2(80,80)
			var sb = StyleBoxFlat.new()
			sb.set_corner_radius_all(100)
			sb.bg_color = ManaType.color(t)
			lbl.add_stylebox_override("normal", sb)
			lbl.text = "0"
			add_child(lbl)
	add_child(tw)