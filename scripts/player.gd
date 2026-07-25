extends CharacterBody3D

# =========================
# SETTINGS
# =========================
@export var speed := 6.0
@export var jump_force := 8.0
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

var hit_targets := []

var facing := 1
var current_anim := ""

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
		push_error("playerAnimation/AnimationPlayer node not found under Player!")

# =========================
# PHYSICS
# =========================
func _physics_process(delta):

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
			rotation.y = 0.0
		else:
			rotation.y = PI

	velocity.x = direction * speed
	velocity.z = 0

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# Sword Attack
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_casting:
		attack()

	# Magic
	if Input.is_action_just_pressed("magic") and can_cast and not is_attacking:
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

	if anim_name == "animaton/Attack":
		anim.play(anim_name, -1, 1.8)
	
	elif anim_name == "animaton/fireball":
		anim.play(anim_name, -1, 2.5)
		
	else:
		anim.play(anim_name,-1, 1.0)

func update_animation():

	if is_attacking:
		return

	if is_casting:
		return

	if not is_on_floor():
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

	# Attack timing
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

	# Small cast delay
	await get_tree().create_timer(0.37).timeout

	var magic = magic_scene.instantiate()

	magic.caster = self

	get_parent().add_child(magic)

	# Spawn in front of player
	magic.global_position = global_position + Vector3(facing * 1.0, .5, 0)

	# Travel direction
	magic.direction = Vector3(facing, 0, 0)

	await get_tree().create_timer(magic_cooldown).timeout

	can_cast = true

# =========================
# ANIMATION FINISHED
# =========================
func _on_animation_finished(anim_name):

	if anim_name == "animaton/Attack":

		is_attacking = false

		current_anim = ""

	if anim_name == "animaton/fireball":

		is_casting = false

		current_anim = ""

# =========================
# DAMAGE
# =========================
func take_damage(amount, _hit_position = Vector3.ZERO):

	current_hp -= amount

	print("Player HP:", current_hp)

	if current_hp <= 0:
		die()

# =========================
# DEATH
# =========================
func die():

	print("PLAYER DIED")

	queue_free()
