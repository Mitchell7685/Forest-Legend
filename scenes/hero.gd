extends CharacterBody2D
signal attacked
signal died
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@export var speed: int = 75
enum states {IDLE, RUN, ATTACK, HURT, DEAD}
var state = states.IDLE
enum directions {UP, DOWN, LEFT, RIGHT}
var direction = directions.DOWN

func _ready() -> void:
	change_state(states.IDLE)

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	# put code to prevent the player from moving out of bounds
	# here when the map size is known

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
			attacked.emit(direction)
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
	
	# movement
	if up:
		velocity.y += speed
		direction = directions.UP
		_sprite.flip_h = false
	if down:
		velocity.y -= speed
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
	if attack:
		change_state(states.ATTACK)
	if ((state == states.RUN and velocity == Vector2.ZERO) or 
	(state == states.ATTACK and not attack)):
		change_state(states.IDLE)

func respawn(_position):
	position = _position
	show()
	direction = directions.DOWN
	change_state(states.IDLE)
