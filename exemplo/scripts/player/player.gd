extends CharacterBody3D

# [PT-BR] Controla um player local com câmera em primeira pessoa e replica o movimento pela rede
# [EN] Controls a local player with first-person camera and replicates movement over the network

# [PT-BR] Velocidade base de deslocamento do personagem em unidades por segundo
# [EN] Base movement speed of the character in units per second
const SPEED = 5.0
# [PT-BR] Força aplicada ao pulo quando o personagem está no chão
# [EN] Jump impulse applied when the character is on the floor
const JUMP_VELOCITY = 4.5
# [PT-BR] Sensibilidade do mouse para rotação da câmera e do corpo
# [EN] Mouse sensitivity for camera and body rotation
const MOUSE_SENSITIVITY = 0.003

# [PT-BR] Referência à câmera usada para controlar a visão em primeira pessoa
# [EN] Reference to the camera used for first-person view control
@onready var camera = $Camera3D
# [PT-BR] Atalho para o autoload WebSocketClient, usado para enviar estado de movimento
# [EN] Shortcut to the WebSocketClient autoload, used to send movement state
var ws_client = null

# [PT-BR] Captura o mouse e localiza o cliente WebSocket assim que o jogador entra na cena
# [EN] Captures the mouse and locates the WebSocket client as soon as the player enters the scene
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# [PT-BR] O jogador depende do autoload para publicar sua posição na sessão multiplayer
	# [EN] The player depends on the autoload to publish its position into the multiplayer session
	ws_client = get_node_or_null("/root/WebSocketClient")

# [PT-BR] Trata entrada do usuário para liberar o mouse e rotacionar corpo/câmera em modo capturado
# [EN] Handles user input to release the mouse and rotate body/camera while captured
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

# [PT-BR] Atualiza gravidade, salto, deslocamento e replica o estado local para o servidor
# [EN] Updates gravity, jump, movement, and replicates the local state to the server
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# [PT-BR] A replicação de posição é feita por envio contínuo para manter outros clientes sincronizados
	# [EN] Position replication is done by continuous sending to keep other clients synchronized
	if ws_client and ws_client._is_connected:
		ws_client.send_message("position", {
			"x": global_position.x,
			"y": global_position.y,
			"z": global_position.z,
			"r_y": rotation.y
		})
