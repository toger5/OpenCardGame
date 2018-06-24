tool
extends VBoxContainer
export var show_children = false setget _show_children
var tw = Tween.new()
onready var this_player = get_parent().get_parent()

func _ready():
	if not Engine.editor_hint:
		this_player.connect("mana_changed", self, "mana_update")
		add_child(tw)

func mana_update(mana):
	var index = 0
	for t in ManaType.list:
		if mana.has(t):
			var lbl = get_child(index)
			if lbl.text != str(mana[t]):
				var sb = lbl.get_stylebox("normal")
				tw.interpolate_property(sb, "bg_color", Color(1,0,0), sb.bg_color, 2, Tween.TRANS_EXPO, Tween.EASE_OUT)
#				tw.interpolate_property(lbl, "modulate", sb.bg_color.lightened(0.4), Color(1,1,1), 2, Tween.TRANS_EXPO, Tween.EASE_OUT)
				tw.start()
			lbl.text = str(mana[t])
			if lbl.text != "0":
				lbl.visible = true
		index += 1
	
func _show_children(new_val):
	show_children = new_val
	for c in get_children():
		remove_child(c)

	if Engine.editor_hint:
		editor_mana_update()
		return

	if show_children:
		for t in ManaType.list:
			var lbl = Label.new()
			lbl.align = ALIGN_CENTER
			lbl.valign = ALIGN_CENTER
			lbl.add_color_override("font_color", Color(1,1,1))
			lbl.rect_min_size = Vector2(60,60)
			var sb = StyleBoxFlat.new()
			sb.set_corner_radius_all(100)
			sb.bg_color = ManaType.color(t)
			lbl.add_stylebox_override("normal", sb)
			lbl.text = "0"
			lbl.visible = false
			sb.connect("changed", lbl, "update")
			add_child(lbl)

#only editor
func editor_mana_update():
	var MTClass = load("res://Autoload/ManaType.gd")
	var MT = MTClass.new()
	if show_children:
		for t in MT.list:
			var lbl = Label.new()
			lbl.align = ALIGN_CENTER
			lbl.valign = ALIGN_CENTER
			lbl.add_color_override("font_color", Color(1,1,1))
			lbl.rect_min_size = Vector2(60,60)
			var sb = StyleBoxFlat.new()
			sb.set_corner_radius_all(100)
			sb.bg_color = MT.color(t)
			lbl.add_stylebox_override("normal", sb)
			lbl.text = "0"
			add_child(lbl)