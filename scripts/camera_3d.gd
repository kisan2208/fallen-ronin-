extends Camera3D

# =========================
# SETTINGS
# =========================
@export var target_path : NodePath
@export var follow_speed := 6.0
@export var look_ahead_distance := 2.5
@export var height := 2.5
@export var depth := 8.0   # distance from player (Z axis)

# =========================
# INTERNAL
# =========================
var target
var current_look_ahead := 0.0

# =========================
# READY
# =========================
func _ready():
	target = get_node(target_path)

# =========================
# PROCESS
# =========================
func _process(delta):

	if target == null:
		return

	# Get player movement direction
	var dir = 0
	if Input.is_action_pressed("move_right"):
		dir += 1
	if Input.is_action_pressed("move_left"):
		dir -= 1

	# Smooth look ahead
	var target_look = dir * look_ahead_distance
	current_look_ahead = lerp(current_look_ahead, target_look, 5 * delta)

	# Target position
	var target_pos = target.global_transform.origin
	target_pos.x += current_look_ahead
	target_pos.y += height
	target_pos.z += depth

	# Smooth follow
	global_transform.origin = global_transform.origin.lerp(target_pos, follow_speed * delta)
