extends Node

enum {BOTTOM_BF, BOTTOM_HAND, GRAVEYARD, DECK, TOP_HAND, TOP_BF}

func mouse_pos():
	var mo
	var mp = Global.game_table.get_global_mouse_position()
	if Global.game_table.player.hand_node.get_global_rect().has_point(mp):
		mo = TableLocation.BOTTOM_HAND
	elif Global.game_table.player.bf_node.get_global_rect().has_point(mp):
		mo = TableLocation.BOTTOM_BF
	elif Global.game_table.opponent.hand_node.get_global_rect().has_point(mp):
		mo = TableLocation.TOP_HAND
	elif Global.game_table.opponent.bf_node.get_global_rect().has_point(mp):
		mo = TableLocation.TOP_BF
	return mo

func mouse_over_cast_area():
	var mo = mouse_pos()
	return mo == TOP_BF or mo == BOTTOM_BF

func opponent_bf(player):
	if player.table_side == player.TableSide.TOP:
		return TableLocation.BOTTOM_BF
	else:
		return TableLocation.TOP_BF