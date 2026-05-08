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
			velocity.y = -speed
		directions.DOWN:
			velocity.y = speed
		directions.LEFT:
			velocity.x = -speed
		directions.RIGHT:
			velocity.x = speed
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		var normal: Vector2 = collision.get_normal()
		var collision_dot_prod: float = velocity.normalized().dot(normal)
		if collider.name == "hero" and collision_dot_prod == -1:
			attack(collider)
		if collision_dot_prod == -1:
			velocity.x = 0
			velocity.y = 0
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
