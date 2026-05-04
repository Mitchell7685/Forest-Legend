extends CharacterBody2D
signal attacked

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@export var speed: int = 60
@export var health: int = 1
enum directions {UP, DOWN, LEFT, RIGHT}
var direction = directions.LEFT

func _ready() -> void:
	show()

func _physics_process(delta: float) -> void:
	# put code to prevent insects from moving out of bounds
	# here when the map size is known
	_animation_player.play("move")
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
		if collider.name == "hero" and facing_collider(collider):
			attack()
		if collision.get_normal().x != 0 or collision.get_normal().y != 0:
			velocity.x = 0
			velocity.y = 0
			change_dir()
		if (collider.is_in_group("enemies") or collider.is_in_group("npc")) and facing_collider(collider):
			velocity.x = 0
			velocity.y = 0
			change_dir()

func facing_collider(collider: CharacterBody2D) -> bool:
	var is_facing_collider: bool = false
	if collider.position.x > position.x and direction == directions.RIGHT:
		is_facing_collider = true
	elif collider.position.x < position.x and direction == directions.LEFT:
		is_facing_collider = true
	elif collider.position.y > position.y and direction == directions.DOWN:
		is_facing_collider = true
	elif collider.position.y < position.y and direction == directions.UP:
		is_facing_collider = true
	return is_facing_collider

func change_dir() -> void:
	var valid_states: Array = directions.values()
	valid_states.erase(direction)
	direction = valid_states.pick_random()
	if direction == directions.LEFT:
		_sprite.flip_h = false
	if direction == directions.RIGHT:
		_sprite.flip_h = true

func attack() -> void:
	_animation_player.play("attack")
	attacked.emit()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	queue_free()
