extends Node

var game_table

#Tweens

#enum position_for_tween{current_position, current_rotation}#since the positions are passed by value, this serves as a bridge to gain the up to date position
var tween_array = []
	
	
func _ready():
	game_table = get_tree().get_root().get_node("Control/table")
	print(game_table)
	
	
#tween queue------------------------------------------------------------------------------------------------------------------
#This function is NOT used for every tween. It should be used for chains of tweens, but not for small single standing tween
#tween chains this is already used for: when attack phase starts, Maybe Todo: when card animates to holder and other tweens at the same time
func add_tween_to_queue(object, property, modification_type_for_values, value, duration = 1, trans_type = Tween.TRANS_LINEAR, ease_type = Tween.EASE_OUT, initial_val = null, final_val = null):
	var tween = Tween.new()
#	var argument_array = [object, property, modification_type_for_values, value, duration, trans_type, ease_type]
#	var i = 0
	var tween_dict = {
	"tween": tween,
	"object": object,
	"property": property,
	"modification_type_for_values": modification_type_for_values,
	"value": value,
	"duration": duration,
	"trans_type": trans_type,
	"ease_type": ease_type,
	"initial_val": initial_val,
	"final_val": final_val}
#	for k in tween_dict.keys():
#		tween_dict[k] = argument_array[i]
#		i += 1
	if tween_array.empty():
		tween_array.append(tween_dict)
		init_tween()
	else:
		tween_array.append(tween_dict)
	return(tween)
func init_tween():
	if tween_array.empty():
		return
	var tw = tween_array[0]
	modify_tween(tw)
	print("object:", tw["object"],"property:", tw["property"],"initial_val:", tw["initial_val"],"final_val:", tw["final_val"], "duration:", tw["duration"], "trans_type:", tw["trans_type"], "ease_type:", tw["ease_type"])
	tw["tween"].interpolate_property(tw["object"], tw["property"], tw["initial_val"], tw["final_val"], tw["duration"], tw["trans_type"], tw["ease_type"])
	tw["tween"].start()
	yield(tw["tween"], "tween_completed")
	tween_array.pop_front()
	init_tween()
func modify_tween(tw):
	if tw["modification_type_for_values"] != null:
		match tw["modification_type_for_values"]:
			"current_absolute": #from current value to an absolute value, value must be a variable of type: current_value
				tw["initial_val"] = tw["object"].get(tw["property"])
				tw["final_val"] = tw["value"]
				
			"relative": #from current_value to current_value + someValue, value must be a variable of type: current_value
				tw["initial_val"] = tw["object"].get(tw["property"])
				tw["final_val"] = tw["initial_val"] + tw["value"]
				
			"relative_with_new_object": #value must be an array with [object, property]
				tw["inital_val"] = tw["object"].get(tw["property"])
				tw["final_val"] = tw["value"][0].get(tw["value"][1])
				
			"different_properties": #In case that a different property of the node than "tw[property]" is used, value must be array of: [first_property (initial_val), second_property (final_val)]
				tw["initial_val"] = tw["object"].get(tw["value"][0])
				tw["final_val"] = tw["object"].get(tw["value"][1])
			
			"different_property_absolute":#doesnt use the property that will be changed, but another property's val and an abolute val, both given as array 
				tw["initial_val"] = tw["object"].get(tw["value"][0])
				tw["final_val"] = tw["value"][1]
#	if tw["initial_val"] == "current_position":
#		tw["initial_val"] = tw["object"].rect_global_position
#		tw["final_val"] += tw["object"].rect_global_position
#	elif tw["initial_val"] == "current_rotation":
#		tw["initial_val"] = tw["object"].rect_rotation
#		tw["final_val"] += tw["object"].rect_rotation


