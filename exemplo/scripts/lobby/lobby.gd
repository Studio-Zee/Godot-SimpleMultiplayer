extends Node3D

# [PT-BR] Cena de lobby que conecta a interface do terminal à camada de rede do plugin
# [EN] Lobby scene that connects the terminal UI to the plugin's network layer

# [PT-BR] Nós da Interface 2D (CanvasLayer)
# [EN] 2D Interface Nodes (CanvasLayer)
@onready var terminal_ui = $CanvasLayer/TerminalUI
@onready var code_input = $CanvasLayer/TerminalUI/Control/Panel/VBoxContainer/LineEdit
@onready var label_status = $CanvasLayer/TerminalUI/Control/Panel/VBoxContainer/Label

# [PT-BR] Botões da interface expostos ao usuário
# [EN] Interface buttons exposed to the user
@onready var btn_criar = $CanvasLayer/TerminalUI/Control/Panel/VBoxContainer/criar
@onready var btn_entrar = $CanvasLayer/TerminalUI/Control/Panel/VBoxContainer/entrar

@onready var player = $Player3D

# [PT-BR] Endereço padrão do servidor WebSocket
# [EN] Default WebSocket server address
const DEFAULT_SERVER_URL = "ws://localhost:9090"

func _ready():
	terminal_ui.hide()
	
	if not btn_criar.pressed.is_connected(_on_criar_pressed):
		btn_criar.pressed.connect(_on_criar_pressed)
	if not btn_entrar.pressed.is_connected(_on_entrar_pressed):
		btn_entrar.pressed.connect(_on_entrar_pressed)
	
	call_deferred("_conectar_servidor")

func _conectar_servidor():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
		ws_client.connect("connection_failed", Callable(self, "_on_connection_failed"))
		ws_client.connect("room_created", Callable(self, "_on_room_created"))
		ws_client.connect("room_joined", Callable(self, "_on_room_joined"))
		ws_client.connect("start_game", Callable(self, "_load_world_scene"))
		ws_client.connect("server_error", Callable(self, "_on_erro_servidor"))
		
		label_status.text = "Conectando ao servidor..."
		
		var server_url = ProjectSettings.get_setting("simple_multiplayer/server_url", DEFAULT_SERVER_URL)
		print("Conectando em: ", server_url)
		
		ws_client.connect_to_server(server_url)
	else:
		label_status.text = "Erro: WebSocketClient não disponível!"

# ==========================================
# GATILHO DO TERMINAL (INTERFACE 2D DIRETA)
# ==========================================
func _on_zona_terminal_body_entered(body: Node3D) -> void:
	if body.name == "Player3D":
		# Congela o player no lugar
		player.set_physics_process(false)
		player.set_process_input(false)
		
		# Mostra a UI 2D e solta o cursor
		terminal_ui.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_sair_pressed() -> void:
	# Esconde a UI
	terminal_ui.hide()
	
	# Prende o cursor e devolve os controles
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.set_physics_process(true)
	player.set_process_input(true)

# ==========================================
# LÓGICA DE REDE E BOTÕES
# ==========================================
func _on_criar_pressed():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		label_status.text = "Criando sala..."
		ws_client.send_message("create_room", {"max_players": 10})

func _on_entrar_pressed():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client and code_input.text != "":
		label_status.text = "Entrando na sala..."
		ws_client.send_message("join_room", {"code": code_input.text})

func _on_connection_succeeded() -> void:
	label_status.text = "Conectado! Crie ou entre."

func _on_connection_failed() -> void:
	label_status.text = "Falha na conexão."

func _on_room_created(data: Dictionary):
	get_tree().change_scene_to_file("res://exemplo/cenas/sala_espera.tscn")

func _on_room_joined(data: Dictionary):
	get_tree().change_scene_to_file("res://exemplo/cenas/sala_espera.tscn")

func _load_world_scene():
	label_status.text = "Iniciando Partida!"
	var error = get_tree().change_scene_to_file("res://exemplo/cenas/mundo_teste.tscn")
	if error != OK:
		push_error("ERRO ao carregar a cena do mundo!")

func _on_erro_servidor(data: Dictionary):
	var mensagem = data.get("msg", "Erro desconhecido")
	label_status.text = "ERRO: " + mensagem
