extends CharacterBody2D

@onready var Bullet = preload("res://src/element/bullet/bullet.tscn")

var shooting = 0.0
var moving = 0.0
var fireRate := 1.0
var multiShot := 0.0
var shootTimer := 0.0
var max_speed = 200.0

func _physics_process(delta):
	shooting -= 10.0 * delta
	var moveDir = Vector2.ZERO

	if Input.is_action_pressed("right"):
		moveDir.x += 1
	else:
		moveDir.x += Input.get_action_strength("ct_right")

	if Input.is_action_pressed("left"):
		moveDir.x -= 1
	else:
		moveDir.x -= Input.get_action_strength("ct_left")

	if moveDir.length() > 0.001:
		moving = 1.0

	if Input.is_action_pressed("ct_shoot"):
		shooting = 1.0

	shootTimer -= 1.0 * delta
	if shootTimer <= 0.0 and Input.is_action_pressed("ct_shoot"):
		shootTimer = 1.0 / (0.36 * fireRate - 1.0 * multiShot) + (1.0 / 0.4)

		var count := float(multiShot) + 1.0
		for i in count:
			Utils.spawn(Bullet, position, get_parent())

	moveDir = moveDir.limit_length(1.0)

	velocity = Utils.lexp(velocity, moveDir * max_speed, 20.0 * delta)
	move_and_slide()

