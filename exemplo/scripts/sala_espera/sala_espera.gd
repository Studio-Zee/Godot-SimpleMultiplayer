extends Node3D

# [PT-BR] Cena de espera que mostra o código da sala e libera o início da partida para o host
# [EN] Waiting scene that shows the room code and lets the host start the match

# [PT-BR] Botão usado pelo host para disparar o início da partida
# [EN] Button used by the host to trigger the match start
@onready var btn_iniciar = $CanvasLayer/BtnIniciar
# [PT-BR] Exibe a quantidade de jogadores conhecidos pelo gerenciador de rede
# [EN] Displays the number of players known by the network manager
@onready var label_contador = $CanvasLayer/LabelContador
# [PT-BR] Exibe o código da sala recebido do autoload WebSocketClient
# [EN] Displays the room code received from the WebSocketClient autoload
@onready var label_codigo = $CanvasLayer/LabelCodigo

# [PT-BR] Conecta os sinais da sala, atualiza a UI com o código e prepara o container de jogadores
# [EN] Connects room signals, updates the UI with the code, and prepares the player container
func _ready():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("start_game", Callable(self , "_ir_para_arena"))
		
		# [PT-BR] O código da sala é mantido no autoload para que a interface possa reutilizá-lo após a troca de cena
		# [EN] The room code is kept in the autoload so the interface can reuse it after the scene change
		if label_codigo:
			label_codigo.text = "CÓDIGO: " + ws_client.room_code
		
		if ws_client.is_host:
			btn_iniciar.show()
		else:
			btn_iniciar.hide()
			
		btn_iniciar.pressed.connect(_on_btn_iniciar_pressed)

	# [PT-BR] O gerenciador precisa saber qual container usar para instanciar jogadores nessa cena
	# [EN] The manager needs to know which container to use to instantiate players in this scene
	var mp_manager = get_node_or_null("/root/MultiplayerManager")
	if mp_manager:
		mp_manager.set_player_container($PlayerContainer)

# [PT-BR] Atualiza em tempo real o contador visual de jogadores presentes na sala
# [EN] Updates the visual counter of players present in the room in real time
func _process(_delta):
	var mp_manager = get_node_or_null("/root/MultiplayerManager")
	if mp_manager and label_contador:
		# [PT-BR] O contador usa a lista confiável de UUIDs mantida pela rede, não apenas nós visuais da cena
		# [EN] The counter uses the network's trusted UUID list, not only the scene's visual nodes
		var qtd_jogadores = mp_manager.connected_players.size()
		label_contador.text = "Jogadores na Sala: " + str(qtd_jogadores)

# [PT-BR] Solicita ao servidor que inicie a partida, mas apenas se este cliente for o host
# [EN] Requests the server to start the match, but only if this client is the host
func _on_btn_iniciar_pressed():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client and ws_client.is_host:
		ws_client.send_message("start_game", {})

# [PT-BR] Troca a cena de espera para a arena principal quando o servidor libera a partida
# [EN] Switches from the waiting scene to the main arena when the server releases the match
func _ir_para_arena():
	print("Partida iniciada! Carregando a Arena...")
	get_tree().change_scene_to_file("res://cenas/mundo_teste.tscn")
