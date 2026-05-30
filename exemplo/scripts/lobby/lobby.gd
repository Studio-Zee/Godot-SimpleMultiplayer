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
	# [PT-BR] Inicializa a interface do lobby: esconde o terminal, conecta os sinais dos botões
	# [EN] Initializes the lobby UI: hides the terminal and connects the button signals
	terminal_ui.hide()
	
	if not btn_criar.pressed.is_connected(_on_criar_pressed):
		btn_criar.pressed.connect(_on_criar_pressed)
	if not btn_entrar.pressed.is_connected(_on_entrar_pressed):
		btn_entrar.pressed.connect(_on_entrar_pressed)
	
	call_deferred("_conectar_servidor")

func _conectar_servidor():
	# [PT-BR] Busca o nó `WebSocketClient` na árvore, conecta sinais de rede e tenta conectar ao servidor
	# [EN] Looks up the `WebSocketClient` node, connects network signals and attempts to connect to the server
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("connection_succeeded", Callable(self , "_on_connection_succeeded"))
		ws_client.connect("connection_failed", Callable(self , "_on_connection_failed"))
		ws_client.connect("room_created", Callable(self , "_on_room_created"))
		ws_client.connect("room_joined", Callable(self , "_on_room_joined"))
		ws_client.connect("start_game", Callable(self , "_load_world_scene"))
		ws_client.connect("server_error", Callable(self , "_on_erro_servidor"))
		
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
	# [PT-BR] Envia ao servidor a requisição para criar uma nova sala (com parâmetros como máximo de jogadores)
	# [EN] Sends a request to the server to create a new room (with parameters like max players)
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		label_status.text = "Criando sala..."
		ws_client.send_message("create_room", {"max_players": 10})

func _on_entrar_pressed():
	# [PT-BR] Envia ao servidor a solicitação para entrar em uma sala usando o código fornecido pelo usuário
	# [EN] Sends to the server a request to join a room using the code provided by the user
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client and code_input.text != "":
		label_status.text = "Entrando na sala..."
		ws_client.send_message("join_room", {"code": code_input.text})

func _on_connection_succeeded() -> void:
	# [PT-BR] Manipulador chamado quando a conexão com o servidor foi estabelecida com sucesso
	# [EN] Handler called when the connection to the server has been successfully established
	label_status.text = "Conectado! Crie ou entre."

func _on_connection_failed() -> void:
	# [PT-BR] Manipulador chamado quando a tentativa de conexão ao servidor falha
	# [EN] Handler called when the attempt to connect to the server fails
	label_status.text = "Falha na conexão."

func _on_room_created(data: Dictionary):
	# [PT-BR] Recebe confirmação da criação da sala e troca para a cena de sala de espera
	# [EN] Receives confirmation of room creation and changes to the waiting room scene
	get_tree().change_scene_to_file("res://exemplo/cenas/sala_espera.tscn")

func _on_room_joined(data: Dictionary):
	# [PT-BR] Recebe confirmação de entrada na sala e troca para a cena de sala de espera
	# [EN] Receives confirmation of joining the room and changes to the waiting room scene
	get_tree().change_scene_to_file("res://exemplo/cenas/sala_espera.tscn")

func _load_world_scene():
	# [PT-BR] Inicia a partida: atualiza o status e tenta carregar a cena do mundo principal, com verificação de erro
	# [EN] Starts the game: updates status and attempts to load the main world scene, with error checking
	label_status.text = "Iniciando Partida!"
	var error = get_tree().change_scene_to_file("res://exemplo/cenas/mundo_teste.tscn")
	if error != OK:
		push_error("ERRO ao carregar a cena do mundo!")

func _on_erro_servidor(data: Dictionary):
	# [PT-BR] Exibe mensagens de erro recebidas do servidor na interface do terminal
	# [EN] Displays error messages received from the server in the terminal UI
	var mensagem = data.get("msg", "Erro desconhecido")
	label_status.text = "ERRO: " + mensagem
