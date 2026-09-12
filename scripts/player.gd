extends CharacterBody3D

# =========================
# SETTINGS
# =========================
@export var speed : float = 6.0
@export var jump_force : float = 8.0
@export var double_jump_force : float = 8.5
@export var max_jump : int = 2
@export var gravity : float = 20.0

@export var max_hp : int = 100

# MAGIC
@export var magic_scene : PackedScene
@export var magic_cooldown : float = 0.5

# COMBO
@export var combo_window : float = 0.45
@export var attack_damages : Array[int] = [10, 15, 25]

# AIR ACTIONS
@export var ground_slam_damage : int = 35
@export var ground_slam_speed : float = 20.0
@export var air_strike_forward_speed : float = 5.0
@export var air_strike_hang_time : float = 0.4 # Time hovering before dropping down
@export var air_strike_anim_speed : float = 1.5 # Speed of the flip/wind-up animation

# HURT
@export var hurt_knockback : float = 4.0
@export var invincibility_time : float = 0.8

# COYOTE TIME
@export var coyote_time : float = 0.15

# =========================
# NODES
# =========================
@onready var sword : Area3D = $SwordArea
@onready var anim : AnimationPlayer = $playerAnimation/AnimationPlayer
@onready var player_model : Node3D = $playerAnimation

# =========================
# STATE
# =========================
var current_hp : int = 0

var is_attacking : bool = false
var is_air_attacking : bool = false
var is_ground_slamming : bool = false
var is_landing : bool = false
var is_casting : bool = false
var can_cast : bool = true
var is_dead : bool = false
var is_hurt : bool = false
var is_invincible : bool = false

var hit_targets : Array = []
var facing : int = 1
var air_strike_direction : int = 1
var current_anim : String = ""
var jump_count : int = 0
var coyote_timer : float = 0.0

# COMBO
var combo_step : int = 0
var combo_input_queued : bool = false
var combo_window_active : bool = false

# =========================
# READY
# =========================
func _ready() -> void:
	current_hp = max_hp

	var tree := get_node_or_null("playerAnimation/AnimationTree") as AnimationTree
	if tree:
		tree.active = false

	if sword:
		sword.monitoring = false
	else:
		push_error("SwordArea node not found!")

	if anim:
		anim.active = true
		anim.animation_finished.connect(_on_animation_finished)
	else:
		push_error("AnimationPlayer not found!")

# =========================
# SMOOTH ANIMATION
# =========================
func play_anim(anim_name : String, speed_scale : float = 1.0, blend : float = 0.15) -> void:
	if anim == null:
		return
	if not anim.has_animation(anim_name):
		push_error("Animation not found: " + anim_name)
		return
	if current_anim == anim_name:
		return

	current_anim = anim_name
	anim.play(anim_name, blend, speed_scale)

# =========================
# PHYSICS PROCESS
# =========================
func _physics_process(delta : float) -> void:
	if is_dead:
		move_and_slide()
		return

	# --- GRAVITY ---
	if not is_on_floor():
		if is_air_attacking and not is_ground_slamming:
			# HOVER: Temporarily disable gravity during the air strike wind-up animation
			velocity.y = 0.0
		else:
			velocity.y -= gravity * delta

	# --- INPUT DIRECTION ---
	var direction : int = 0
	if not is_hurt:
		if Input.is_action_pressed("move_right"):
			direction += 1
		if Input.is_action_pressed("move_left"):
			direction -= 1

	if direction != 0 and not is_ground_slamming and not is_air_attacking:
		facing = direction
		if facing > 0:
			rotation.y = 0.0
		else:
			rotation.y = PI

	# --- X VELOCITY ---
	if is_ground_slamming:
		# Plunging down diagonally (Slam Attack)
		velocity.x = float(air_strike_direction) * air_strike_forward_speed
		velocity.y = -ground_slam_speed
	elif is_air_attacking:
		# HOVER: Freeze horizontal movement while hanging in mid-air
		velocity.x = 0.0
	elif is_hurt:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 5.0)
	elif is_attacking:
		velocity.x = float(direction) * speed * 0.3
	else:
		velocity.x = float(direction) * speed

	velocity.z = 0.0

	# --- Coyote Time ---
	if is_on_floor():
		jump_count = 0
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# --- JUMP ---
	if Input.is_action_just_pressed("jump") and not is_hurt and not is_dead and not is_air_attacking and not is_ground_slamming:
		if coyote_timer > 0.0 and jump_count == 0:
			velocity.y = jump_force
			play_anim("animaton/jump", 1.0, 0.1)
			jump_count = 1
			coyote_timer = 0.0
		elif jump_count == 1 and max_jump >= 2:
			velocity.y = double_jump_force
			play_anim("animaton/doublejump", 1.5, 0.1)
			jump_count = 2

	# --- ATTACK ---
	if Input.is_action_just_pressed("attack") and not is_air_attacking and not is_ground_slamming and not is_hurt and not is_casting and not is_dead:
		if not is_on_floor() and jump_count == 1 and not is_attacking and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
			start_air_strike()
		elif is_on_floor() and not is_attacking:
			start_combo()
		elif is_on_floor() and combo_window_active and combo_step < 3:
			combo_input_queued = true

	if Input.is_action_just_pressed("magic") and can_cast and not is_attacking and not is_air_attacking and not is_ground_slamming and not is_hurt and not is_dead:
		cast_magic()

	move_and_slide()

	if is_ground_slamming and is_on_floor():
		ground_slam_land()

	update_animation()

# =========================
# ANIMATION UPDATE
# =========================
func update_animation() -> void:
	if is_dead or is_attacking or is_casting or is_hurt or is_air_attacking or is_ground_slamming or is_landing:
		return

	if not is_on_floor():
		if velocity.y > 0.0:
			if current_anim != "animaton/doublejump":
				play_anim("animaton/jump", 1.0, 0.1)
		else:
			play_anim("animaton/fall", 1.0, 0.15)
	elif abs(velocity.x) > 0.1:
		play_anim("animaton/run", 1.0, 0.15)
	else:
		play_anim("animaton/idle", 1.0, 0.15)

# =========================
# AIR STRIKE / GROUND SLAM
# =========================
func start_air_strike() -> void:
	if is_air_attacking or is_ground_slamming or is_attacking or is_dead or jump_count != 1:
		return

	var strike_dir : int = 0
	if Input.is_action_pressed("move_right"):
		strike_dir = 1
	elif Input.is_action_pressed("move_left"):
		strike_dir = -1

	if strike_dir == 0:
		strike_dir = facing

	air_strike_direction = strike_dir
	facing = air_strike_direction
	if air_strike_direction > 0:
		rotation.y = 0.0
	else:
		rotation.y = PI

	is_air_attacking = true
	jump_count = max_jump 
	hit_targets.clear()

	# 1. Stop mid-air to show the flip/wind-up animation
	velocity = Vector3.ZERO
	play_anim("animaton/air_strike", air_strike_anim_speed, 0.05)

	# 2. Wait for the hang time before plunging
	await get_tree().create_timer(air_strike_hang_time).timeout

	if not is_air_attacking or is_dead or is_hurt:
		return

	# 3. Plunge down to the ground
	is_ground_slamming = true

func ground_slam_land() -> void:
	is_ground_slamming = false
	is_air_attacking = false
	is_landing = true
	hit_targets.clear()

	play_anim("animaton/fall_to_land", 1.0, 0.05)

	sword.monitoring = true
	await get_tree().process_frame
	deal_sword_damage(ground_slam_damage)
	sword.monitoring = false

	await get_tree().create_timer(0.25).timeout
	is_landing = false
	current_anim = ""

func deal_sword_damage(damage : int) -> void:
	var bodies : Array[Node3D] = sword.get_overlapping_bodies()
	for body : Node3D in bodies:
		if body == self or body in hit_targets:
			continue
		hit_targets.append(body)
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)

# =========================
# COMBO ATTACK
# =========================
func start_combo() -> void:
	is_attacking = true
	combo_step = 1
	combo_input_queued = false
	combo_window_active = false
	hit_targets.clear()
	perform_attack("animaton/Attack", 1.8, 0)

func perform_attack(anim_name : String, anim_speed : float, damage_index : int) -> void:
	play_anim(anim_name, anim_speed, 0.05)
	hit_targets.clear()

	sword.monitoring = false
	await get_tree().process_frame
	sword.monitoring = true

	await get_tree().create_timer(0.1).timeout

	var damage : int = 10
	if damage_index < attack_damages.size():
		damage = attack_damages[damage_index]
	deal_sword_damage(damage)

	await get_tree().create_timer(0.05).timeout
	sword.monitoring = false

	combo_window_active = true
	await get_tree().create_timer(combo_window).timeout
	combo_window_active = false

	if combo_input_queued and combo_step < 3:
		combo_input_queued = false
		combo_step += 1
		match combo_step:
			2:
				perform_attack("animaton/attack2", 1.6, 1)
			3:
				perform_attack("animaton/attack3", 1.4, 2)
	else:
		end_combo()

func end_combo() -> void:
	is_attacking = false
	combo_step = 0
	combo_input_queued = false
	combo_window_active = false
	current_anim = ""

# =========================
# MAGIC
# =========================
func cast_magic() -> void:
	if magic_scene == null:
		return

	can_cast = false
	is_casting = true
	play_anim("animaton/fireball", 2.5, 0.05)
	await get_tree().create_timer(0.37).timeout

	var magic := magic_scene.instantiate() as Node3D
	if magic:
		magic.set("caster", self)
		get_parent().add_child(magic)
		magic.global_position = global_position + Vector3(float(facing) * 1.0, 0.5, 0.0)
		magic.set("direction", Vector3(float(facing), 0.0, 0.0))

	await get_tree().create_timer(magic_cooldown).timeout
	can_cast = true

# =========================
# HURT & DEATH
# =========================
func apply_hurt(hit_position : Vector3) -> void:
	if is_invincible or is_dead: return
	is_hurt = true
	is_invincible = true
	is_air_attacking = false
	is_ground_slamming = false
	is_landing = false
	is_casting = false
	end_combo()
	play_anim("animaton/hurt", 2.0, 0.05)

	var knockback_dir : float = sign(global_position.x - hit_position.x)
	if knockback_dir == 0.0: knockback_dir = float(-facing)
	velocity.x = knockback_dir * hurt_knockback
	velocity.y = hurt_knockback * 0.5

	await get_tree().create_timer(0.35).timeout
	is_hurt = false
	current_anim = ""
	invincibility_blink()
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false

func invincibility_blink() -> void:
	for i : int in 6:
		if not is_invincible: break
		if player_model: player_model.visible = false
		await get_tree().create_timer(0.07).timeout
		if player_model: player_model.visible = true
		await get_tree().create_timer(0.07).timeout

func _on_animation_finished(anim_name : String) -> void:
	match anim_name:
		"animaton/Attack", "animaton/attack2", "animaton/attack3":
			if combo_step > 0 and not combo_window_active: end_combo()
		"animaton/fireball":
			is_casting = false
			current_anim = ""
		"animaton/hurt":
			is_hurt = false
			current_anim = ""
		"animaton/dying":
			queue_free()

func take_damage(amount : int, hit_position : Vector3 = Vector3.ZERO) -> void:
	if is_dead or is_invincible: return
	current_hp -= amount
	if current_hp <= 0:
		die()
	else:
		apply_hurt(hit_position)

func die() -> void:
	if is_dead: return
	is_dead = true
	velocity = Vector3.ZERO
	is_attacking = false
	is_air_attacking = false
	is_ground_slamming = false
	is_landing = false
	is_casting = false
	is_hurt = false
	can_cast = false
	end_combo()
	sword.monitoring = false
	play_anim("animaton/dying", 1.2, 0.1)
