#######
#   SCRIPT PLAYER TRAVELLER
#   ADAPTADO POR LAMECK SILVA FERNANDES
#	MODELOS https://github.com/godotengine/godot-demo-projects
#######

extends KinematicBody2D

##
const GRAVITY = 1100.0 # Pixels/second

const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 5 #10
const WALK_MAX_SPEED = 200 #300
const STOP_FORCE = 1300
const JUMP_SPEED = 450 #700
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false

var prev_jump_pressed = false



## Nodes Traveller -----------------------------------------------
onready var traveller_walking = get_node("walk")
onready var traveller_idle = get_node("idle")
onready var traveller_duck = get_node("duck")
onready var traveller_jump = get_node("jump")

var walk_direction
var block_jump = false
var jump_air = false

# Node CAM
onready var cam = get_node("cam")
var contPressCamZoom = 0
var auxCam

# Função de iniciação de leitura do script _ready()
func _ready():
	set_physics_process(true)
	
	
func _physics_process(delta):
	# Create forces
	var force = Vector2(0, GRAVITY)
	
	# TRAVELLER ----------------------------------------
	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var move_down = Input.is_action_pressed("move_down")
	var jump = Input.is_action_pressed("jump")
	
	# CAM TRAVELLER -------------------------------------
	
	
	
	var stop = true

	if walk_left:
		if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
			force.x -= WALK_FORCE
			stop = false
		setTravellerWalkingLeft()
	elif walk_right:
		if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
			force.x += WALK_FORCE
			stop = false
		setTravellerWalkingRight()
	
	if stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
				
		vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
			setTravellerIdle()
		
		velocity.x = vlen * vsign
	
		
	# Integrate forces to velocity
	velocity += force * delta	
	# Integrate velocity into motion and move
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor():
		on_air_time = 0
		if int(on_air_time*100) == 0:
			getTravellerJump_A()
			block_jump = false
		
		
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
		
	
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true
		setTravellerJump_A()
	
	on_air_time += delta
	prev_jump_pressed = jump
	
	if int(on_air_time*100) > 50:
		traveller_jump.frame = 3
	
	if block_jump: #Bloqueio a chamada dos sprites walk
		_walking_visible(false)
	

	
## ---------------------------------------------------------------------
## Funções Traveller Movimento
func setTravellerWalkingLeft():
	if !block_jump:
		traveller_idle.visible = false
		_walking_visible(true)
		_walking_flip(true)
	walk_direction = true
func setTravellerWalkingRight():
	if !block_jump:
		traveller_idle.visible = false
		_walking_visible(true)
		_walking_flip(false)
	walk_direction = false
func setTravellerIdle():
	if !block_jump:
		_idle_visible(true)
		_walking_visible(false)
		if walk_direction:
			_idle_flip(true)
		else:
			_idle_flip(false)
func setTravellerJump_A():
	_idle_visible(false)
	_jump(true)
	traveller_jump.frame = 0
	velocity.y = -JUMP_SPEED
	if walk_direction:
		_jump_flip(true)
	else:
		_jump_flip(false)
	block_jump = true
func getTravellerJump_A():
	if block_jump:
		_idle_visible(true)
		_jump(false)
func _idle_visible(value):
	traveller_idle.visible = value
func _idle_flip(value):
	traveller_idle.flip_h = value
func _walking_visible(value):
	traveller_walking.visible = value
func _walking_flip(value):
	traveller_walking.flip_h = value
func _jump(value):
	traveller_jump.visible = value
func _jump_flip(value):
	traveller_jump.flip_h = value



