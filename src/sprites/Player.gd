extends KinematicBody2D

var targetDeg = null
var speed = 500
var gravity = 300
var gravityChangeSpeed = 0.1
var up = 0.0
var frames = 0
var delta = 0.0

var snaps = [0, 45, 90, 135, 180, 225, 270, 315, 360]

var velocity = Vector2()
var newVel = Vector2()
var gravityDir = Vector2()

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
		print(number," ",diff," ",least_diff," ",best_match)
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
	$compassNeedle.rotation_degrees = up
	gravityDir.x = sin(deg2rad(up))
	gravityDir.y = cos(deg2rad(up))

func no_gravity_change():
	if up in snaps:
		targetDeg = null
		return
	if targetDeg == null:
		targetDeg = find_closest(up, snaps)
	else:
		if targetDeg > up:
			change_gravity(1)
		elif targetDeg < up:
			change_gravity(0)

func get_input():
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_accept"):
		velocity.y = -20
	velocity = velocity.normalized() * speed
	if Input.is_action_pressed("gravity_left"):
		change_gravity(0)
		targetDeg = null
	elif Input.is_action_pressed("gravity_right"):
		change_gravity(1)
		targetDeg = null
	elif frames % 2 == 0:
		no_gravity_change()

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

	velocity.y += gravity
	
	check_direction()

	newVel = Vector2()
	newVel.x = velocity.x*sin(deg2rad(up+90)) - velocity.y*sin(deg2rad(up+180))
	newVel.y = velocity.x*cos(deg2rad(up+90)) - velocity.y*cos(deg2rad(up+180))

	move_and_slide(newVel,gravityDir)
