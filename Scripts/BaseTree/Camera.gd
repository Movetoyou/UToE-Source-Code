extends CharacterBody2D

const Speed = 500
const ZoomStep = 0.1
const MinZoom = 0.75
const MaxZoom = 1.1

@onready var Camera: Camera2D = $Camera2D

func _physics_process(_delta):
	var Direction = Vector2(Input.get_action_strength("Right") - Input.get_action_strength("Left"), Input.get_action_strength("Down") - Input.get_action_strength("Up"))
	if Direction.length_squared() > 0: Direction = Direction.normalized(); velocity = Direction * Speed
	else: velocity = Vector2.ZERO
	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: ZoomCamera(ZoomStep)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: ZoomCamera(-ZoomStep)
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_PLUS, KEY_KP_ADD: ZoomCamera(-ZoomStep)
			KEY_MINUS, KEY_KP_SUBTRACT: ZoomCamera(ZoomStep)

func ZoomCamera(amount):
	var ZoomValue = Camera.zoom + Vector2.ONE * amount
	ZoomValue = ZoomValue.clamp(Vector2(MinZoom, MinZoom), Vector2(MaxZoom, MaxZoom))
	Camera.zoom = ZoomValue
