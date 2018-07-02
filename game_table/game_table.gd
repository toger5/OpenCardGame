extends Control

signal cast_finished
enum location {BOTTOM_BF, BOTTOM_HAND, GRAVEYARD, DECK, TOP_HAND, TOP_BF}

onready var player = $player
onready var opponent = $opp

onready var card_preview_tr = get_node("../TextureRect")
onready var deck = $player/left_area/deck

var tw = Tween.new()

#var dragged_card = null
var drag_offset = Vector2()
var drag_offset_factor = 1
#var hovered_card = null

var cast_queue = []
func is_casting(): return not cast_queue.empty()
enum GamePhase {DEFAULT, DEFALT, ATTACK, DEFEND, NO_INTERACTION} #NO_INTERACTION is used for mana reload phase + attack execute phase (they should still be short and with fast animations)
var phase = GamePhase.DEFAULT
var attack_phase = false

func _ready():
	add_child(tw)
	setup_game()
	for p in [player, opponent]:
		p.connect("turn_finished", self, "_turn_finished")
		p.connect("card_added", self, "_card_added")
	
	player.is_playing = true
	opponent.is_playing = false
	card_preview_tr.rect_size.y = card_preview_tr.rect_size.x / card_renderer.card_size.aspect()


#Temporary, for game testing
func setup_game():
	player.cardnames_deck = ["a", "b", "mana_red", "mana_blue", "mana_blue", "flo"]
	opponent.cardnames_deck = [ "mana_blue", "flo","a", "b", "mana_red", "mana_blue"]

func show_card_preview(card):
	card_preview_tr.texture = card.texture_node.texture
	tw.interpolate_property(card_preview_tr, "modulate:a", card_preview_tr.modulate.a, 1,0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tw.start()

func hide_card_preview(card):
	tw.interpolate_property(card_preview_tr, "modulate:a",card_preview_tr.modulate.a, 0, 0.2,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tw.start()

#Attack Phase
func indicate_attack_phase(indicate, label_stage = 0):
	if attack_phase:
		return
	var attack_indicate_height = 20
	if not indicate:
		attack_indicate_height = 0
	for p in [opponent, player]:
		var spacer = p.attack_phase_spacer
		var d = 0.17
		tw.interpolate_property(spacer, "rect_min_size:y", spacer.rect_size.y, attack_indicate_height, d, Tween.TRANS_EXPO, Tween.EASE_OUT)

	var bg_opacity = 0
	var lbl_opacity = 0
	if indicate:
		match label_stage:
			1:
				lbl_opacity = 0.2
				bg_opacity = 0.3
			2:
				lbl_opacity = 0.6
				bg_opacity = 0.4
	inactive_player().show_attack_indicate_label(lbl_opacity, bg_opacity)
func start_attack_phase():
	var attack_phase_height = 50
	if phase == GamePhase.ATTACK:
		return
	active_player().indicate_attack_phase(false,0)
	phase = GamePhase.ATTACK
	for p in [opponent, player]:
		p.animate_attack(true)

		var d = 0.2
		tw.interpolate_property(p.attack_phase_spacer, "rect_min_size:y", p.attack_phase_spacer.rect_size.y, attack_phase_height, d, Tween.TRANS_EXPO, Tween.EASE_IN)
func end_attack_phase():
	if phase != GamePhase.ATTACK: #and phase != GamePhase.NO_INTERACTION: #(I think this is not needed)
		return
	phase = GamePhase.DEFAULT
	active_player().indicate_attack_phase(false,0)
	for p in [opponent, player]:
		animate_attack(false)

#functions to control turns
func _turn_finished():
	opponent.is_playing = not opponent.is_playing
	player.is_playing = not player.is_playing
func active_player():
	if opponent.is_playing:
		return opponent
	elif player.is_playing:
		return player
func inactive_player():
	if opponent.is_playing:
		return player
	elif player.is_playing:
		return opponent
	
#this is only debugging
func _input(event):
		if event is InputEventKey:
			var card_to_add = card_cache.card(card_cache.get_all_card_names()[randi() % card_cache.get_all_card_names().size()])
			if event.scancode == KEY_F and event.pressed:
				player.add_card_to_hand(card_cache.card("flo"))
			if event.scancode == KEY_W and event.pressed:
				player.add_card_to_hand(card_to_add)
			if event.scancode == KEY_Q and event.pressed:
				opponent.add_card_to_hand(card_to_add)
			if event.scancode == KEY_R and event.pressed:
				tw.interpolate_property(player.bf_h_box, "margin_bottom", 0, -100, 4,Tween.TRANS_LINEAR,Tween.EASE_OUT)
				
