extends CanvasLayer
@onready var heart_box = $HeartBox.get_children()

func update_lives(amount: int) -> void:
	for heart in heart_box.size():
		heart_box[heart].visible = amount > heart
