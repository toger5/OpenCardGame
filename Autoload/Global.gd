extends Node

var game_table
var tween = Tween.new()
func _ready():
	add_child(tween)
	game_table = get_tree().get_root().get_node("Control/table")
	print(game_table)