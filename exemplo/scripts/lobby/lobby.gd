extends Node3D

# [PT-BR] Cena de lobby que conecta a interface do terminal à camada de rede do plugin
# [EN] Lobby scene that connects the terminal UI to the plugin's network layer

# [PT-BR] Nós 3D e elementos de animação usados na transição entre tela e gameplay
# [EN] 3D nodes and animation elements used for the transition between terminal and gameplay
@onready var terminal_ui = $monitor/TelaViewport/TerminalUI
@onready var code_input = $monitor/TelaViewport/TerminalUI/Control/Panel/VBoxContainer/LineEdit
@onready var label_status = $monitor/TelaViewport/TerminalUI/Control/Panel/VBoxContainer/Label
@onready var posicao_tela = $monitor/PosicaoTela
@onready var player = $Player3D

# [PT-BR] Botões da interface expostos ao usuário para criar ou entrar em salas
# [EN] Interface buttons exposed to the user for creating or joining rooms
@onready var btn_criar = $monitor/TelaViewport/TerminalUI/Control/Panel/VBoxContainer/criar
@onready var btn_entrar = $monitor/TelaViewport/TerminalUI/Control/Panel/VBoxContainer/entrar

# [PT-BR] Câmera do jogador usada nas transições de interface
# [EN] Player camera used during interface transitions
var camera_player: Camera3D
# [PT-BR] Guarda a transform original da câmera para restaurar a visão após fechar o terminal
# [EN] Stores the camera's original transform to restore the view after closing the terminal
var transform_original_camera: Transform3D

# [PT-BR] Endereço padrão do servidor WebSocket usado quando o ProjectSettings não define outro valor
# [EN] Default WebSocket server address used when ProjectSettings does not define another value
const DEFAULT_SERVER_URL = "ws://localhost:9090"

# [PT-BR] Inicializa a tela de lobby, conecta sinais da interface e dispara a conexão de rede
# [EN] Initializes the lobby screen, connects UI signals, and triggers the network connection
func _ready():
	terminal_ui.hide()
	camera_player = player.get_node("Camera3D")
	
	# [PT-BR] A conexão por código evita duplicidade caso o editor já tenha definido os mesmos sinais
	# [EN] Connecting by code avoids duplicate callbacks if the editor already wired the same signals
	if not btn_criar.pressed.is_connected(_on_criar_pressed):
		btn_criar.pressed.connect(_on_criar_pressed)
	if not btn_entrar.pressed.is_connected(_on_entrar_pressed):
		btn_entrar.pressed.connect(_on_entrar_pressed)
	
	# [PT-BR] A conexão é iniciada com atraso para garantir que os autoloads já estejam disponíveis
	# [EN] The connection starts deferred to ensure autoloads are already available
	call_deferred("_conectar_servidor")

# [PT-BR] Resolve o autoload WebSocketClient, conecta callbacks e abre a conexão com o servidor
# [EN] Resolves the WebSocketClient autoload, wires callbacks, and opens the server connection
func _conectar_servidor():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		# [PT-BR] Cada sinal abaixo atualiza um ponto específico da interface ou do fluxo de cena
		# [EN] Each signal below updates a specific point of the interface or scene flow
		ws_client.connect("connection_succeeded", Callable(self , "_on_connection_succeeded"))
		ws_client.connect("connection_failed", Callable(self , "_on_connection_failed"))
		ws_client.connect("room_created", Callable(self , "_on_room_created"))
		ws_client.connect("room_joined", Callable(self , "_on_room_joined"))
		ws_client.connect("start_game", Callable(self , "_load_world_scene"))
		
		ws_client.connect("server_error", Callable(self , "_on_erro_servidor"))
		
		label_status.text = "Conectando ao servidor..."
		
		# [PT-BR] A URL pode ser personalizada pelo usuário do plugin sem alterar esta cena
		# [EN] The URL can be customized by the plugin user without changing this scene
		var server_url = ProjectSettings.get_setting("simple_multiplayer/server_url", DEFAULT_SERVER_URL)
		print("Conectando em: ", server_url)
		
		ws_client.connect_to_server(server_url)
	else:
		label_status.text = "Erro: WebSocketClient não disponível!"
		push_error("WebSocketClient Autoload não encontrado na raiz!")

# ==========================================
# ANIMAÇÕES DO TERMINAL 3D
# ==========================================
# [PT-BR] Detecta a entrada do jogador na área do terminal e executa a transição visual para a UI
# [EN] Detects when the player enters the terminal area and runs the visual transition into the UI
func _on_zona_terminal_body_entered(body: Node3D) -> void:
	if body.name == "Player3D":
		player.set_physics_process(false)
		player.set_process_input(false)
		transform_original_camera = camera_player.transform
		var tween = create_tween()
		tween.tween_property(camera_player, "global_transform", posicao_tela.global_transform, 0.5).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(abrir_interface)

# [PT-BR] Exibe a interface do terminal e libera o mouse para interação do usuário
# [EN] Shows the terminal interface and releases the mouse for user interaction
func abrir_interface():
	terminal_ui.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# [PT-BR] Fecha a interface, restaura o controle do jogador e volta a câmera para a posição original
# [EN] Closes the interface, restores player control, and returns the camera to its original position
func _on_sair_pressed() -> void:
	terminal_ui.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var tween = create_tween()
	tween.tween_property(camera_player, "transform", transform_original_camera, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		player.set_physics_process(true)
		player.set_process_input(true)
	)

# ==========================================
# LÓGICA DE REDE E BOTÕES
# ==========================================
# [PT-BR] Solicita ao servidor a criação de uma sala usando o autoload WebSocketClient
# [EN] Requests room creation from the server using the WebSocketClient autoload
func _on_criar_pressed():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		label_status.text = "Criando sala..."
		ws_client.send_message("create_room", {})

# [PT-BR] Solicita a entrada em uma sala usando o código digitado pelo usuário
# [EN] Requests room entry using the code typed by the user
func _on_entrar_pressed():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client and code_input.text != "":
		label_status.text = "Entrando na sala..."
		ws_client.send_message("join_room", {"code": code_input.text})

# [PT-BR] Atualiza a interface quando o servidor confirma a conexão inicial
# [EN] Updates the interface when the server confirms the initial connection
func _on_connection_succeeded() -> void:
	label_status.text = "Conectado! Crie ou entre."

# [PT-BR] Atualiza a interface quando a tentativa de conexão ao servidor falha
# [EN] Updates the interface when the server connection attempt fails
func _on_connection_failed() -> void:
	label_status.text = "Falha na conexão."

# [PT-BR] Troca a cena para a sala de espera após a criação da sala ser confirmada
# [EN] Changes the scene to the waiting room after room creation is confirmed
func _on_room_created(data: Dictionary):
	get_tree().change_scene_to_file("res://exemplo/cenas/sala_espera.tscn")

# [PT-BR] Troca a cena para a sala de espera após o cliente entrar em uma sala existente
# [EN] Changes the scene to the waiting room after the client joins an existing room
func _on_room_joined(data: Dictionary):
	get_tree().change_scene_to_file("res://cenas/sala_espera.tscn")

# [PT-BR] Carrega a cena principal do mundo quando o servidor autoriza o início da partida
# [EN] Loads the main world scene when the server authorizes the match start
func _load_world_scene():
	label_status.text = "Iniciando Partida!"
	var scene_path = "res://cenas/mundo_teste.tscn"
	var error = get_tree().change_scene_to_file(scene_path)
	
	if error != OK:
		push_error("ERRO ao carregar a cena do mundo!")
	else:
		print("Mundo carregado com sucesso!")
		
# [PT-BR] Exibe mensagens de erro vindas do servidor diretamente na interface do monitor
# [EN] Displays server error messages directly on the monitor interface
func _on_erro_servidor(data: Dictionary):
	var mensagem = data.get("msg", "Erro desconhecido")
	label_status.text = "ERRO: " + mensagem
