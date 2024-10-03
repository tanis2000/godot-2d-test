extends CharacterBody2D

@onready var Bullet = preload("res://src/element/bullet/bullet.tscn")

var shooting = 0.0
var moving = 0.0
var fireRate := 1.0
var multiShot := 0.0
var shootTimer := 0.0
var max_speed = 200.0
var knockbackVel := Vector2.ZERO
var hitTimer := 0.0

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
