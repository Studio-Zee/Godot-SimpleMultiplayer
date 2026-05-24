extends Node3D

# --- NÓS DO 3D E ANIMAÇÃO ---
@onready var terminal_ui = $monitor/TelaViewport/TerminalUI
@onready var code_input = $monitor/TelaViewport/TerminalUI/Control/Panel/VBoxContainer/LineEdit
@onready var label_status = $monitor/TelaViewport/TerminalUI/Control/Panel/VBoxContainer/Label
@onready var posicao_tela = $monitor/PosicaoTela
@onready var player = $Player3D

# --- BOTÕES DA INTERFACE ---
@onready var btn_criar = $monitor/TelaViewport/TerminalUI/Control/Panel/VBoxContainer/criar
@onready var btn_entrar = $monitor/TelaViewport/TerminalUI/Control/Panel/VBoxContainer/entrar

var camera_player : Camera3D
var transform_original_camera : Transform3D

const DEFAULT_SERVER_URL = "ws://localhost:9090"

func _ready():
	terminal_ui.hide()
	camera_player = player.get_node("Camera3D")
	
	# Conecta os botões via código (se já não estiverem conectados pelo editor para evitar cliques duplos)
	if not btn_criar.pressed.is_connected(_on_criar_pressed):
		btn_criar.pressed.connect(_on_criar_pressed)
	if not btn_entrar.pressed.is_connected(_on_entrar_pressed):
		btn_entrar.pressed.connect(_on_entrar_pressed)
	
	# Inicia a conexão de forma segura depois que o jogo carregar
	call_deferred("_conectar_servidor")

func _conectar_servidor():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		# Conecta todos os sinais do WebSocketClient
		ws_client.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
		ws_client.connect("connection_failed", Callable(self, "_on_connection_failed"))
		ws_client.connect("room_created", Callable(self, "_on_room_created"))
		ws_client.connect("room_joined", Callable(self, "_on_room_joined"))
		ws_client.connect("start_game", Callable(self, "_load_world_scene"))
		
		label_status.text = "Conectando ao servidor..."
		
		# Lê a URL configurada no ProjectSettings (ou usa a padrão localhost)
		var server_url = ProjectSettings.get_setting("simple_multiplayer/server_url", DEFAULT_SERVER_URL)
		print("Conectando em: ", server_url)
		
		ws_client.connect_to_server(server_url)
	else:
		label_status.text = "Erro: WebSocketClient não disponível!"
		push_error("WebSocketClient Autoload não encontrado na raiz!")

# ==========================================
# ANIMAÇÕES DO TERMINAL 3D
# ==========================================
func _on_zona_terminal_body_entered(body: Node3D) -> void:
	if body.name == "Player3D":
		player.set_physics_process(false) 
		player.set_process_input(false)
		transform_original_camera = camera_player.transform 
		var tween = create_tween()
		tween.tween_property(camera_player, "global_transform", posicao_tela.global_transform, 0.5).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(abrir_interface)

func abrir_interface():
	terminal_ui.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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
func _on_criar_pressed():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		label_status.text = "Criando sala..."
		ws_client.send_message("create_room", {})

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
	# Vai direto para a Ilha de Espera!
	get_tree().change_scene_to_file("res://cenas/sala_espera.tscn")

func _on_room_joined(data: Dictionary):
	# Vai direto para a Ilha de Espera!
	get_tree().change_scene_to_file("res://cenas/sala_espera.tscn")

func _load_world_scene():
	label_status.text = "Iniciando Partida!"
	var scene_path = "res://cenas/mundo_teste.tscn"
	var error = get_tree().change_scene_to_file(scene_path)
	
	if error != OK:
		push_error("ERRO ao carregar a cena do mundo!")
	else:
		print("Mundo carregado com sucesso!")
