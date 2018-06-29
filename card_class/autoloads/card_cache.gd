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
	
func get_all_card_names():
	var d = Directory.new()
	var card_names = []
	if d.open("res://cards/") == OK:
		d.list_dir_begin()
		var dir_el_name = d.get_next()
		while dir_el_name != "":
			if dir_el_name.ends_with(".gd"):
				card_names.append(dir_el_name.split(".")[0])
			dir_el_name = d.get_next()
	return card_names