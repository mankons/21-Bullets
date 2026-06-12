extends Node3D
@export var card_scene: PackedScene 
@onready var turn_label = $UI/TurnLabel
@onready var hit_button = $UI/HBoxContainer/HitButton
@onready var stand_button = $UI/HBoxContainer/StandButton
var deck: Array = []
var player_score: int = 0
var bot_score: int = 0
var is_player_turn: bool = true
var player_card_spawn_pos = Vector3(-0.2, 0.9, 0.3)
var bot_card_spawn_pos = Vector3(-0.2, 0.9, -0.3)
func _ready():
	generate_deck()
	start_game()
func generate_deck():
	deck.clear()
	var base_cards = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11]
	for i in range(4):
		deck.append_array(base_cards)
	deck.shuffle() 
func start_game():
	set_ui_interaction(false)
	turn_label.text = "Роздача перших карт..."
	await deal_card_to_player(true)
	await deal_card_to_bot(true)
	start_player_turn()
func start_player_turn():
	is_player_turn = true
	turn_label.text = "ВАШ ХІД (Очки: " + str(player_score) + ")"
	set_ui_interaction(true)
func start_bot_turn():
	is_player_turn = false
	set_ui_interaction(false)
	turn_label.text = "Хід противника..."
	await get_tree().create_timer(1.5).timeout
	while bot_score < 17:
		turn_label.text = "Противник бере карту..."
		await deal_card_to_bot(true) 
		await get_tree().create_timer(1.5).timeout
	turn_label.text = "Противник пасує."
	await get_tree().create_timer(1.0).timeout
	check_winner()
func deal_card_to_player(should_flip: bool):
	if deck.size() == 0: return
	var val = deck.pop_front()
	player_score += val
	var new_card = card_scene.instantiate()
	add_child(new_card)
	new_card.global_position = player_card_spawn_pos
	new_card.set_value(val)
	player_card_spawn_pos.x += 0.15
	if should_flip:
		await new_card.flip()
func deal_card_to_bot(should_flip: bool):
	if deck.size() == 0: return
	var val = deck.pop_front()
	bot_score += val
	var new_card = card_scene.instantiate()
	add_child(new_card)
	new_card.global_position = bot_card_spawn_pos
	new_card.set_value(val)
	bot_card_spawn_pos.x += 0.15
	if should_flip:
		await new_card.flip()
func set_ui_interaction(enabled: bool):
	hit_button.disabled = !enabled
	stand_button.disabled = !enabled
func _on_hit_button_pressed():
	set_ui_interaction(false) 
	await deal_card_to_player(true)
	if player_score > 21:
		turn_label.text = "ПЕРЕБІР! Ви програли! (Очки: " + str(player_score) + ")"
		await get_tree().create_timer(2.0).timeout
		restart_game()
	else:
		set_ui_interaction(true)
func _on_stand_button_pressed():
	start_bot_turn()
func check_winner():
	var result_text = ""
	if bot_score > 21:
		result_text = "Противник перебрав! Ви виграли!"
	elif player_score > bot_score:
		result_text = "Ви виграли!"
	elif player_score < bot_score:
		result_text = "Ви програли!"
	else:
		result_text = "Нічия!"
	turn_label.text = result_text + " (Ви: " + str(player_score) + " vs Бот: " + str(bot_score) + ")"
	await get_tree().create_timer(3.0).timeout
	restart_game()
func restart_game():
	get_tree().reload_current_scene()
