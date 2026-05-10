extends CharacterBody2D
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@export var speed: int = 60
@export var health: int = 1
enum directions {UP, DOWN, LEFT, RIGHT}
var direction = directions.LEFT

func _ready() -> void:
	show()
	_animation_player.play("idle")

func _physics_process(delta: float) -> void:
	match direction:
		directions.UP:
			velocity = Vector2(0, -speed)
		directions.DOWN:
			velocity = Vector2(0, speed)
		directions.LEFT:
			velocity = Vector2(-speed, 0)
		directions.RIGHT:
			velocity = Vector2(speed, 0)
	
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		var collider: Object = collision.get_collider()
		if collider.name == "hero":
			collider.take_damage()
		change_dir()

func change_dir() -> void:
	var valid_states: Array = directions.values()
	valid_states.erase(direction)
	direction = valid_states.pick_random()
	if direction == directions.LEFT:
		_sprite.flip_h = false
	if direction == directions.RIGHT:
		_sprite.flip_h = true

func attack(collider: CharacterBody2D) -> void:
	_animation_player.play("attack")
	collider.take_damage()

func take_damage(amount: int = 1) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	queue_free()
