extends CharacterBody2D
signal hurt
signal died
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@export var speed: int = 75
enum states {IDLE, RUN, ATTACK, HURT, DEAD}
var state = states.IDLE
enum directions {UP, DOWN, LEFT, RIGHT}
var direction = directions.DOWN
var last_direction = directions.DOWN
var has_herb: bool = false
var health: int = 3

func _ready() -> void:
	change_state(states.IDLE)

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if state == states.ATTACK and collider.is_in_group("enemies") and facing_collider(collider):
			collider.take_damage()

func change_state(new_state) -> void:
	state = new_state
	match state:
		states.IDLE:
			match direction:
				directions.UP:
					_animation_player.play("idle_back")
				directions.DOWN:
					_animation_player.play("idle")
				directions.LEFT, directions.RIGHT:
					_animation_player.play("idle_side")
		states.RUN:
			match direction:
				directions.UP:
					_animation_player.play("walk_back")
				directions.DOWN:
					_animation_player.play("walk_front")
				directions.LEFT, directions.RIGHT:
					_animation_player.play("walk_side")
		states.ATTACK:
			match direction:
				directions.UP:
					_animation_player.play("attack_back")
				directions.DOWN:
					_animation_player.play("attack_front")
				directions.LEFT, directions.RIGHT:
					_animation_player.play("attack_side")
		states.HURT:
			pass
		states.DEAD:
			hide()
			died.emit()

func get_input() -> void:
	var up: bool = Input.is_action_pressed("up")
	var down: bool = Input.is_action_pressed("down")
	var left: bool = Input.is_action_pressed("left")
	var right: bool = Input.is_action_pressed("right")
	var attack: bool = Input.is_action_just_pressed("attack")
	velocity.x = 0
	velocity.y = 0
	last_direction = direction
	
	# movement
	if up:
		velocity.y -= speed
		direction = directions.UP
		_sprite.flip_h = false
	if down:
		velocity.y += speed
		direction = directions.DOWN
		_sprite.flip_h = false
	if left:
		velocity.x -= speed
		direction = directions.LEFT
		_sprite.flip_h = true
	if right:
		velocity.x += speed
		direction = directions.RIGHT
		_sprite.flip_h = false
	
	# change states
	if state == states.IDLE and velocity != Vector2.ZERO:
		change_state(states.RUN)
	elif state == states.RUN and direction != last_direction:
		change_state(states.RUN)
	if attack and state != states.ATTACK:
		change_state(states.ATTACK)
	if state == states.RUN and velocity == Vector2.ZERO:
		change_state(states.IDLE)

func facing_collider(collider: Object) -> bool:
	var is_facing_collider: bool = false
	if collider.position.y > position.y and direction == directions.DOWN:
		is_facing_collider = true
	if collider.position.y < position.y and direction == directions.UP:
		is_facing_collider = true
	if collider.position.x > position.x and direction == directions.RIGHT:
		is_facing_collider = true
	if collider.position.x < position.x and direction == directions.LEFT:
		is_facing_collider = true
	return is_facing_collider

func respawn(_position):
	position = _position
	show()
	direction = directions.DOWN
	change_state(states.IDLE)

func take_damage(amount: int = 1) -> void:
	if state == states.HURT:
		return
	health -= amount
	change_state(states.HURT)
	hurt.emit(health)
	if health <= 0:
		change_state(states.DEAD)
	else:
		await get_tree().create_timer(2).timeout
		change_state(states.IDLE)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if state == states.ATTACK:
		if anim_name.begins_with("attack"):
			change_state(states.IDLE)
