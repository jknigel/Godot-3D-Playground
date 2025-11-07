extends CharacterBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed = 10
# Maximum speed of the mob in meters per second.
@export var max_speed = 18


func _physics_process(_delta):
	move_and_slide()
	
func initialize(start_position, player_position):
	look_at_from_position(start_position, player_position, Vector3.UP)
	rotate_y(randf_range(-PI/4, PI/4))
	
	var random_speed = randi_range(min_speed, max_speed)
	
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
