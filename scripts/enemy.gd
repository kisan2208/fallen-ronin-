extends CharacterBody3D

# =========================
# SETTINGS
# =========================
@export var speed := 3.0
@export var gravity := 20.0
@export var max_hp := 40

@export var knockback_force := 8.0
@export var knockback_up := 4.0
@export var knockback_slowdown := 18.0

@export var patrol_distance := 4.0
@export var chase_distance := 6.0
@export var attack_distance := 1.5
@export var attack_cooldown := 1.0
@export var damage := 10

# =========================
# STATE
# =========================
var current_hp := 0
var is_hit := false
var is_dead := false
var can_attack := true

var hit_id := 0
var attack_id := 0

var start_position := Vector3.ZERO
var patrol_dir := 1
var player = null

# =========================
# READY
# =========================
func _ready():
	current_hp = max_hp
	start_position = global_position
	player = get_tree().get_first_node_in_group("player")

# =========================
# PHYSICS
# =========================
func _physics_process(delta):

	if is_dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

	# Knockback state
	if is_hit:
		velocity.x = move_toward(velocity.x, 0, knockback_slowdown * delta)
		move_and_slide()
		return

	# Refresh player if needed
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	# AI logic
	if player != null and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)

		if distance < attack_distance:
			velocity.x = 0
			attack_player()

		elif distance < chase_distance:
			chase_player()

		else:
			patrol()
	else:
		patrol()

	move_and_slide()

# =========================
# PATROL
# =========================
func patrol():

	var offset = global_position.x - start_position.x

	if abs(offset) > patrol_distance:
		patrol_dir *= -1
		start_position.x = global_position.x

	velocity.x = patrol_dir * speed

	if patrol_dir == 1:
		rotation.y = 0.0
	else:
		rotation.y = PI

# =========================
# CHASE
# =========================
func chase_player():

	if player == null or not is_instance_valid(player):
		return

	var dir = sign(player.global_position.x - global_position.x)

	if dir == 0:
		velocity.x = 0
		return

	velocity.x = dir * speed * 1.5
	patrol_dir = dir

	if dir == 1:
		rotation.y = 0.0
	else:
		rotation.y = PI

# =========================
# ATTACK
# =========================
func attack_player():

	if is_hit or is_dead:
		return

	if not can_attack:
		return

	if player == null or not is_instance_valid(player):
		return

	can_attack = false
	attack_id += 1
	var this_attack_id = attack_id

	print("Enemy ATTACK!")

	await get_tree().create_timer(0.1).timeout

	if is_dead or is_hit:
		return

	if this_attack_id != attack_id:
		return

	if player != null and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)

		if distance < attack_distance and player.has_method("take_damage"):
			player.take_damage(damage)

	await get_tree().create_timer(attack_cooldown).timeout

	if not is_dead:
		can_attack = true

# =========================
# DAMAGE + KNOCKBACK
# =========================
func take_damage(amount, hit_position):

	if is_dead:
		return

	current_hp -= amount
	print("Enemy HP:", current_hp)

	hit_id += 1
	attack_id += 1

	var this_hit_id = hit_id

	is_hit = true
	can_attack = true

	var direction = sign(global_position.x - hit_position.x)

	if direction == 0:
		direction = -patrol_dir

	velocity.x = direction * knockback_force
	velocity.y = knockback_up

	print("Enemy HIT!")

	if current_hp <= 0:
		die()
		return

	await get_tree().create_timer(0.35).timeout

	if not is_dead and this_hit_id == hit_id:
		is_hit = false

# =========================
# DEATH
# =========================
func die():

	if is_dead:
		return

	is_dead = true
	print("Enemy DIED")

	velocity = Vector3.ZERO

	await get_tree().create_timer(0.3).timeout
	queue_free()
