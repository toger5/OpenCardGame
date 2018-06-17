tool
extends EditorScript

func _run():
	print("I LIVE")
	var t = load("res://cards/flosC.png").get_data()
	var ratio = t.get_size().x / t.get_size().y
	print(t)
	t.resize(640,  640 / ratio)
	print(t.save_png("res://cards/flosC_small.png"))