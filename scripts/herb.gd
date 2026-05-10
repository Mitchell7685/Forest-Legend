extends Area2D

var player_in_range: bool = false
var collected: bool = false
var player_ref: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is Node and body.name == "hero":
		player_in_range = true
		player_ref = body
		$PromptLabel.visible = true

func _on_body_exited(body: Node) -> void:
	if body == player_ref:
		player_in_range = false
		player_ref = null
		$PromptLabel.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range and not collected:
		collect_herb()

func collect_herb() -> void:
	collected = true
	if is_instance_valid(player_ref):
		player_ref.set("has_herb", true)
	show_dialogue("You collected a healing herb.")
	queue_free()

func show_dialogue(text: String) -> void:
	var hud = get_tree().root.get_child(0).get_node("HUD")
	if hud.has_node("DialogueLabel"):
		hud.get_node("DialogueLabel").text = text
		await get_tree().create_timer(2.5).timeout
		if is_instance_valid(hud):
			hud.get_node("DialogueLabel").text = ""
