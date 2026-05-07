extends CharacterBody2D

var quest_started = false
var gate_unlocked = false

func _ready() -> void:
	
	$InteractionArea.body_entered.connect(_on_interaction_area_entered)
	$InteractionArea.body_exited.connect(_on_interaction_area_exited)

func _on_interaction_area_entered(body: Node) -> void:

	if body is Node and body.is_in_group("player"):
		$InteractionArea/PromptLabel.visible = true

func _on_interaction_area_exited(body: Node) -> void:
	if body is Node and body.is_in_group("player"):
		$InteractionArea/PromptLabel.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if not quest_started:
			# First interaction - husband asks for herb
			quest_started = true
			display_dialogue("Husband: My wife is very sick!\n Please go into the garden and find a healing herb for her. I'll unlock the gate for you.")
		elif not gate_unlocked:
			# Second interaction - unlock the gate
			unlock_gate()

func display_dialogue(text: String) -> void:
	var hud = get_tree().root.get_child(0).get_node("HUD")
	if hud.has_node("DialogueLabel"):
		hud.get_node("DialogueLabel").text = text
		# Clear dialogue after 4 seconds
		await get_tree().create_timer(4.0).timeout
		hud.get_node("DialogueLabel").text = ""

func unlock_gate() -> void:
	gate_unlocked = true
	var main_scene = get_tree().root.get_child(0)
	if main_scene.has_node("gate"):
		var gate_layer = main_scene.get_node("gate")
		gate_layer.clear()
	display_dialogue("Husband: Thank you! The gate is now unlocked.")
