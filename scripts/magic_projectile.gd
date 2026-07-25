extends Area3D

@export var speed := 10.0
@export var damage := 20

var direction := Vector3.ZERO
var caster = null

func _ready():

	body_entered.connect(_on_body_entered)

	await get_tree().create_timer(3.0).timeout

	if is_inside_tree():
		queue_free()

func _physics_process(delta):

	global_position += direction * speed * delta

func _on_body_entered(body):

	if body == caster:
		return

	print("Fireball hit:", body.name)

	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)

	queue_free()
