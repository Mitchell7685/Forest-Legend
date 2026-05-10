extends Control


func _ready() -> void:
	$PlayAgainButton.pressed.connect(_on_play_again_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
