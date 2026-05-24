extends Node3D

@onready var btn_iniciar = $CanvasLayer/BtnIniciar
@onready var label_contador = $CanvasLayer/LabelContador
@onready var label_codigo = $CanvasLayer/LabelCodigo

func _ready():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("start_game", Callable(self, "_ir_para_arena"))
		
		# Puxa o código guardado no Autoload e estampa na tela
		if label_codigo:
			label_codigo.text = "CÓDIGO: " + ws_client.room_code
		
		if ws_client.is_host:
			btn_iniciar.show()
		else:
			btn_iniciar.hide()
			
		btn_iniciar.pressed.connect(_on_btn_iniciar_pressed)

	# Avisa o gerenciador para liberar os bonecos
	var mp_manager = get_node_or_null("/root/MultiplayerManager")
	if mp_manager:
		mp_manager.set_player_container($PlayerContainer)

func _process(_delta):
	var mp_manager = get_node_or_null("/root/MultiplayerManager")
	if mp_manager and label_contador:
		# O JEITO INFALÍVEL: Em vez de contar os nós da cena, ele conta 
		# quantos IDs reais existem na lista de conectados do servidor!
		var qtd_jogadores = mp_manager.connected_players.size()
		label_contador.text = "Jogadores na Sala: " + str(qtd_jogadores)

func _on_btn_iniciar_pressed():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client and ws_client.is_host:
		ws_client.send_message("start_game", {})

func _ir_para_arena():
	print("Partida iniciada! Carregando a Arena...")
	get_tree().change_scene_to_file("res://cenas/mundo_teste.tscn")
