extends CharacterBody3D

# =========================
# SETTINGS
# =========================
@export var speed := 6.0
@export var jump_force := 8.0
@export var double_jump_force := 8.5
@export var max_jump := 2
@export var gravity := 20.0

@export var max_hp := 100
@export var sword_damage := 10

# MAGIC
@export var magic_scene : PackedScene
@export var magic_cooldown := 0.5

# =========================
# NODES
# =========================
@onready var sword = $SwordArea
@onready var anim = $playerAnimation/AnimationPlayer

# =========================
# STATE
# =========================
var current_hp := 0

var is_attacking := false
var is_casting := false
var can_cast := true
var is_dead := false

var hit_targets := []

var facing := 1
var current_anim := ""
var jump_count := 0

# =========================
# READY
# =========================
func _ready():

	current_hp = max_hp

	if sword:
		sword.monitoring = false
	else:
		push_error("SwordArea node not found under Player!")

	if anim:
		anim.animation_finished.connect(_on_animation_finished)
	else:
		push_error("AnimationPlayer node not found!")

# =========================
# PHYSICS
# =========================
func _physics_process(delta):

	if is_dead:
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Movement
	var direction = 0

	if Input.is_action_pressed("move_right"):
		direction += 1

	if Input.is_action_pressed("move_left"):
		direction -= 1

	# Face direction
	if direction != 0:

		facing = direction

		if facing > 0:
			rotation.y = 0
		else:
			rotation.y = PI

	velocity.x = direction * speed
	velocity.z = 0

	# =========================
	# JUMP
	# =========================

	# Reset jump count when player lands
	if is_on_floor():
		jump_count = 0

	# Jump / Double Jump
	if Input.is_action_just_pressed("jump"):

		if jump_count < max_jump:

			if jump_count == 0:
				velocity.y = jump_force
				play_anim("animaton/jump")

			else:
				velocity.y = double_jump_force
				play_anim("animaton/doublejump")

			jump_count += 1

	# Sword Attack
	if Input.is_action_just_pressed("attack") and !is_attacking and !is_casting:
		attack()

	# Magic
	if Input.is_action_just_pressed("magic") and can_cast and !is_attacking:
		cast_magic()

	move_and_slide()

	update_animation()

# =========================
# ANIMATION
# =========================
func play_anim(anim_name):

	if current_anim == anim_name:
		return

	current_anim = anim_name

	match anim_name:

		"animaton/Attack":
			anim.play(anim_name, -1, 1.8)

		"animaton/fireball":
			anim.play(anim_name, -1, 2.5)

		"animaton/dying":
			anim.play(anim_name, -1, 1.2)
			
		"animaton/doublejump":
			anim.play(anim_name, -1, 1.5)

		_:
			anim.play(anim_name)

func update_animation():

	if is_dead:
		return

	if is_attacking:
		return

	if is_casting:
		return

	if not is_on_floor():
		if current_anim != "animaton/doublejump":
			play_anim("animaton/jump")

	elif abs(velocity.x) > 0.1:
		play_anim("animaton/run")

	else:
		play_anim("animaton/idle")

# =========================
# ATTACK
# =========================
func attack():

	is_attacking = true

	hit_targets.clear()

	play_anim("animaton/Attack")

	sword.monitoring = false

	await get_tree().process_frame

	sword.monitoring = true

	await get_tree().create_timer(0.08).timeout

	var bodies = sword.get_overlapping_bodies()

	for body in bodies:

		if body == self:
			continue

		if body in hit_targets:
			continue

		hit_targets.append(body)

		if body.has_method("take_damage"):
			body.take_damage(sword_damage, global_position)

	await get_tree().create_timer(0.05).timeout

	sword.monitoring = false

# =========================
# MAGIC
# =========================
func cast_magic():

	if magic_scene == null:
		print("Assign magic.tscn to magic_scene!")
		return

	can_cast = false
	is_casting = true

	play_anim("animaton/fireball")

	await get_tree().create_timer(0.37).timeout

	var magic = magic_scene.instantiate()

	magic.caster = self

	get_parent().add_child(magic)

	magic.global_position = global_position + Vector3(facing * 1.0, 0.5, 0)

	magic.direction = Vector3(facing, 0, 0)

	await get_tree().create_timer(magic_cooldown).timeout

	can_cast = true

# =========================
# ANIMATION FINISHED
# =========================
func _on_animation_finished(anim_name):

	match anim_name:

		"animaton/Attack":
			is_attacking = false
			current_anim = ""

		"animaton/fireball":
			is_casting = false
			current_anim = ""

		"animaton/dying":
			queue_free()

# =========================
# DAMAGE
# =========================
func take_damage(amount, _hit_position = Vector3.ZERO):

	if is_dead:
		return

	current_hp -= amount

	print("Player HP:", current_hp)

	if current_hp <= 0:
		die()

# =========================
# DEATH
# =========================
func die():

	if is_dead:
		return

	is_dead = true

	velocity = Vector3.ZERO

	is_attacking = false
	is_casting = false
	can_cast = false

	sword.monitoring = false

	play_anim("animaton/dying")
