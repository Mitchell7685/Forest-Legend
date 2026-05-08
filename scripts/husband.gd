extends CharacterBody2D

var quest_started = false
var gate_unlocked = false
var quest_completed = false
var player_in_range = false
var player_ref: Node = null

func _ready() -> void:
	
	$InteractionArea.body_entered.connect(_on_interaction_area_entered)
	$InteractionArea.body_exited.connect(_on_interaction_area_exited)

func _on_interaction_area_entered(body: Node) -> void:

	if body is Node and body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		$InteractionArea/PromptLabel.visible = true

func _on_interaction_area_exited(body: Node) -> void:
	if body == player_ref:
		player_in_range = false
		player_ref = null
		$InteractionArea/PromptLabel.visible = false

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or not player_in_range:
		return

	if quest_completed:
		display_dialogue("Husband: Thank you again. My wife is already feeling better.")
		return

	if not quest_started:
		quest_started = true
		unlock_gate()
		if _player_has_herb():
			finish_quest()
		else:
			display_dialogue("Husband: My wife is very sick!\nPlease find a healing herb in the garden.")
		return

	if _player_has_herb():
		finish_quest()
	else:
		display_dialogue("Husband: Please hurry. We still need that healing herb.")

func display_dialogue(text: String) -> void:
	var hud = get_tree().root.get_child(0).get_node("HUD")
	if hud.has_node("DialogueLabel"):
		hud.get_node("DialogueLabel").text = text
		# Clear dialogue after 4 seconds
		await get_tree().create_timer(4.0).timeout
		hud.get_node("DialogueLabel").text = ""

func unlock_gate() -> void:
	if gate_unlocked:
		return

	gate_unlocked = true
	var main_scene = get_tree().root.get_child(0)
	if main_scene.has_node("gate"):
		var gate_layer = main_scene.get_node("gate")
		gate_layer.clear()

func finish_quest() -> void:
	quest_completed = true
	if is_instance_valid(player_ref):
		player_ref.set("has_herb", false)
	display_dialogue("Husband: You found it! Thank you for saving my wife.")

func _player_has_herb() -> bool:
	if not is_instance_valid(player_ref):
		return false
	return bool(player_ref.get("has_herb"))
