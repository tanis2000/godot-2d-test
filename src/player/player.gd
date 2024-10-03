extends CharacterBody2D

@onready var Bullet = preload("res://src/element/bullet/bullet.tscn")

var shooting = 0.0
var moving = 0.0
var fireRate := 2.0
var shootTimer := 0.0
var max_speed = 200.0
var knockbackVel := Vector2.ZERO
var hitTimer := 0.0
var aimAngle := Vector2.ZERO

func _ready():
	Global.player = self

func _physics_process(delta):
	shooting -= 10.0 * delta
	hitTimer -= 1.0 * delta
	var moveDir = Vector2.ZERO

	if Input.is_action_pressed("right"):
		moveDir.x += 1
	else:
		moveDir.x += Input.get_action_strength("ct_right")

	if Input.is_action_pressed("left"):
		moveDir.x -= 1
	else:
		moveDir.x -= Input.get_action_strength("ct_left")

	if Input.is_action_pressed("up"):
		moveDir.y -= 1
	else:
		moveDir.y -= Input.get_action_strength("ct_up")

	if Input.is_action_pressed("down"):
		moveDir.y += 1
	else:
		moveDir.y += Input.get_action_strength("ct_down")

	if moveDir.length() > 0.001:
		moving = 1.0

	if Input.is_action_pressed("ct_shoot") or Input.is_action_pressed("shoot"):
		shooting = 1.0

	if Global.inputType == Global.InputType.INPUT_KEYBOARD:
		aimAngle = get_local_mouse_position().normalized()
	else:
		var vec = Input.get_vector("ct_aim_left", "ct_aim_right", "ct_aim_up", "ct_aim_down")
		if vec.length() > 0.1:
			aimAngle = vec.normalized()

	shootTimer -= 1.0 * delta
	if shootTimer <= 0.0 and (Input.is_action_pressed("ct_shoot") or Input.is_action_pressed("shoot")):
		shootTimer = 1.0 / fireRate
		Audio.play(preload("res://src/sfx/shoot.wav"))
		var angle = aimAngle
		Utils.spawn(Bullet, position, get_parent(), {angle = angle})
		Global.stats.total_bullets_fired +=1

	moveDir = moveDir.limit_length(1.0)

	velocity = Utils.lexp(velocity, moveDir * max_speed, 20.0 * delta)
	knockbackVel = Utils.lexp(knockbackVel, Vector2.ZERO, 20.0 * delta)
	velocity += knockbackVel
	move_and_slide()

func hit_enemy(enemy:Node2D):
	if "knockback" in enemy:
		enemy.knockback(position)
	knockback(enemy.position)

	if hitTimer <= 0.0:
		damage(1)
	else:
		Audio.play(preload("res://src/sfx/hit.wav"), 0.8, 1.2)

func knockback(from:Vector2, strength = 1.0):
	knockbackVel = strength * 500.0 * (global_position - from).normalized()

func damage(amount:float = 1.0):
	if hitTimer <= 0.0:
		Audio.play(preload("res://src/sfx/hit.wav"), 0.8, 1.2)
		Global.hud.flash_damage()
		for i in 3:
			Utils.spawn(preload("res://src/particle/enemy_pop/enemy_pop.tscn"), position, get_parent(), {color = Color(0.831, 0.11, 0.204)})
		Global.state.health -= amount
		if Global.state.health <= 0:
			#TODO: game over screen
			kill()
			return
		hitTimer = 0.3

func kill():
	var a = func():
		process_mode = Node.PROCESS_MODE_DISABLED
	a.call_deferred()
	visible = false
	Global.state.dead = true
	Global.main.game_over()
