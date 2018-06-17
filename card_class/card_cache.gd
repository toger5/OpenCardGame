extends Node

var cache = {}
func _ready():
	pass

func card(card_file_name):
	if not cache.has(card_file_name):
		cache[card_file_name] = load("res://cards/"+card_file_name+".gd")
		print("created cache entry: "+ card_file_name)
	return cache[card_file_name].new()

func card_by_id(id):
	print("not yet implemented")