extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Variável para controlar a velocidade que a câmera gira
const MOUSE_SENSITIVITY = 0.003 

# Pega a referência da câmera (Certifique-se que o nome do nó da câmera é "Camera3D")
@onready var camera = $Camera3D

func _ready():
	# Esconde e prende o mouse no centro da tela quando o jogo começa
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Se apertar ESC, libera o mouse para podermos fechar o jogo
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# Só gira a câmera se o mouse estiver preso na tela
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# Gira o CORPO inteiro no eixo Y (olhar para esquerda/direita)
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			
			# Gira APENAS A CÂMERA no eixo X (olhar para cima/baixo)
			camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			
			# Limita a câmera para o jogador não dar uma "cambalhota" para trás
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
