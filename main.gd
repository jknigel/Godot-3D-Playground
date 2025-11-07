extends Node

@export var mob_scene: PackedScene
@onready var player = $Player
@onready var name_input_panel = $UserInterface/NameInputPanel
@onready var name_edit = $UserInterface/NameInputPanel/VBoxContainer/NameInput
@onready var submit_button = $UserInterface/NameInputPanel/VBoxContainer/NameSubmitButton
var _pending_final_score = 0

func _ready():
	$UserInterface/Retry.hide()
	player.hit.connect(_on_player_hit)
	submit_button.pressed.connect(_on_submit_button_pressed)
	name_edit.text_submitted.connect(_on_name_edit_text_submitted)

func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	
	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)
	
	add_child(mob)
	
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())


func _on_player_hit() -> void:
	$MobTimer.stop()
	_pending_final_score = $UserInterface/ScoreLabel.score
	
	if HighScoreManager.is_high_score(_pending_final_score):
		name_input_panel.show()
		name_edit.grab_focus()
	else:
		$UserInterface/Retry.show()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
		
func _on_submit_button_pressed():
	var player_name = name_edit.text
	if player_name.is_empty():
		player_name = "NAMELESS"
	HighScoreManager.submit_score(player_name, _pending_final_score)
	
	name_input_panel.hide()
	$UserInterface/Retry.show()
	
func _on_name_edit_text_submitted(text_from_input):
	_on_submit_button_pressed()
