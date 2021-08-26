extends KinematicBody2D

var targetDeg = null
var speed = 250
var gravity = 300
var rootMovement = 1
var gravityChangeSpeed = 0.1
var up = 0.0
var frames = 0
var delta = 0.0

var snaps = [0, 45, 90, 135, 180, 225, 270, 315, 360]

var velocity = Vector2()
var newVel = Vector2()
var gravityDir = Vector2(0,-1)

func debug_stuff():
	if Input.is_action_pressed("DEBUG_pause_grav"):
		velocity.y = 1
	if Input.is_action_pressed("DEBUG_disable_snapping"):
		targetDeg = up
	if Input.is_action_just_released("DEBUG_disable_snapping"):
		targetDeg = null

func find_closest(num, array):
	var best_match = null
	var least_diff = null
	for number in array:
		var diff = num - number
		if diff < 0:
			diff = -diff
		if least_diff == null:
			best_match = number
			least_diff = diff
		if(diff < least_diff):
			best_match = number
			least_diff = diff
	return best_match

func change_gravity(direction):
	if direction == 0: #LEFT
		up -= 1
		if up < 0: # -1 == 359 (0 == 360)
			up = 359
	else:
		up += 1
		if up > 360: # 361 == 1
			up = 1
	rotation_degrees = -up
	$compassBase/compassNeedle.rotation_degrees = up
	gravityDir.x = -sin(deg2rad(up))
	gravityDir.y = -cos(deg2rad(up))

func no_gravity_change():
	if up in snaps:
		targetDeg = null
		return
	if targetDeg == null:
		targetDeg = find_closest(up, snaps)
	elif targetDeg > up:
		change_gravity(1)
	elif targetDeg < up:
		change_gravity(0)

func get_input():
	if Input.is_action_pressed("reset"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if is_on_floor():
		velocity = velocity.normalized() * speed
	else:
		velocity = velocity.normalized() * speed / 3
	if Input.is_action_pressed("gravity_left"):
		change_gravity(0)
		targetDeg = null
	elif Input.is_action_pressed("gravity_right"):
		change_gravity(1)
		targetDeg = null
	else:
		no_gravity_change()

func do_gravity():
	if $Hand.get_overlapping_areas() and not Input.is_action_pressed("down"):
		velocity.y += rootMovement
	else:
		velocity.y += gravity

func check_direction():
	if velocity.x > 0:
		$AnimatedSprite.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite.flip_h = true

func _physics_process(delta0):
	frames += 1
	delta = delta0
	velocity = Vector2()
	
	get_input()

	do_gravity()
	
	check_direction()

	if $KillBox.get_overlapping_bodies():
		get_tree().reload_current_scene()
		return

	if OS.is_debug_build():
		debug_stuff()

	newVel = Vector2()
	newVel.x = velocity.x*sin(deg2rad(up+90)) - velocity.y*sin(deg2rad(up+180))
	newVel.y = velocity.x*cos(deg2rad(up+90)) - velocity.y*cos(deg2rad(up+180))

	move_and_slide(newVel,gravityDir)
