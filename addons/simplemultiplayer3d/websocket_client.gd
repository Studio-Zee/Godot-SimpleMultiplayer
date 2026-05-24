extends Node

# [PT-BR] Central de comunicação WebSocket do cliente multiplayer
# [EN] Multiplayer client WebSocket communication hub

# [PT-BR] Sinais consumidos pela interface para refletir estado de conexão, salas e erros de servidor
# [EN] Signals consumed by the interface to reflect connection state, rooms, and server errors
signal connection_succeeded
signal connection_failed
signal connection_closed
signal room_created(data)
signal room_joined(data)
signal server_error(data)
signal start_game

# [PT-BR] Sinais emitidos para sincronizar o gameplay 3D com os eventos do servidor
# [EN] Signals emitted to synchronize 3D gameplay with server events
signal spawn_local_player(player_data)
signal spawn_new_player(player_data)
signal spawn_network_players(players_data)
signal update_position(position_data)
signal player_disconnected(player_data)

# [PT-BR] Indica se a instância atual atua como host da sala
# [EN] Indicates whether the current instance acts as the room host
var is_host: bool = false

# [PT-BR] Código da sala recebido do servidor para exibição e compartilhamento com jogadores
# [EN] Room code received from the server for display and player sharing
var room_code: String = ""

# [PT-BR] UUID atribuído pelo servidor após a conexão inicial
# [EN] UUID assigned by the server after the initial connection
var uuid: String = ""
# [PT-BR] Peer WebSocket responsável pelo transporte de mensagens do cliente
# [EN] WebSocket peer responsible for the client's message transport
var _peer := WebSocketPeer.new()
# [PT-BR] Estado interno de conexão usado para controlar polling e envio de pacotes
# [EN] Internal connection state used to control polling and packet sending
var _is_connected := false

# [PT-BR] Faz o polling do WebSocket e despacha os pacotes recebidos a cada frame
# [EN] Polls the WebSocket and dispatches received packets every frame
func _process(_delta):
	if not _is_connected:
		return
		
	_peer.poll()
	var state = _peer.get_ready_state()
	if state == WebSocketPeer.STATE_CLOSED or state == WebSocketPeer.STATE_CLOSING:
		if _is_connected:
			_is_connected = false
			emit_signal("connection_closed")

	# [PT-BR] Processa cada pacote disponível em sequência para manter a sincronização de rede em tempo real
	# [EN] Processes each available packet sequentially to keep real-time network synchronization
	while _is_connected and _peer.get_available_packet_count() > 0:
		var packet = _peer.get_packet().get_string_from_utf8()
		var data = JSON.parse_string(packet)
		if data is Dictionary:
			handle_incoming_data(data)

# [PT-BR] Inicia a conexão com o servidor WebSocket usando a URL informada pelo plugin ou pela cena
# [EN] Starts the WebSocket server connection using the URL provided by the plugin or scene
func connect_to_server(url: String):
	if _peer.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		return
	var err = _peer.connect_to_url(url)
	if err != OK:
		emit_signal("connection_failed")
	else:
		_is_connected = true

# [PT-BR] Envia um comando estruturado ao servidor apenas quando a conexão já estiver aberta
# [EN] Sends a structured command to the server only when the connection is already open
func send_message(command: String, content: Dictionary):
	if not _is_connected or _peer.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	_peer.send_text(JSON.stringify({"cmd": command, "content": content}))

# [PT-BR] Interpreta comandos recebidos do servidor e redistribui para a interface e o gameplay
# [EN] Interprets commands received from the server and redistributes them to the UI and gameplay
func handle_incoming_data(data: Dictionary):
	var cmd = data.get("cmd", "")
	var content = data.get("content", {})
	
	# [PT-BR] Cada caso abaixo espelha um evento do servidor para o fluxo local da cena
	# [EN] Each case below mirrors a server event into the local scene flow
	match cmd:
		"joined_server":
			uuid = content.get("uuid", "")
			emit_signal("connection_succeeded")
		"room_created":
			is_host = content.get("is_host", false)
			# [PT-BR] Armazena o código da sala para exibição na interface e uso em cenas dependentes
			# [EN] Stores the room code for display in the interface and use by dependent scenes
			room_code = content.get("code", "")
			emit_signal("room_created", content)
		"room_joined":
			is_host = content.get("is_host", false)
			# [PT-BR] Mantém o mesmo código da sala após a entrada do cliente para consistência visual
			# [EN] Keeps the same room code after the client joins to preserve visual consistency
			room_code = content.get("code", "")
			emit_signal("room_joined", content)
		"start_game":
			emit_signal("start_game")
		"spawn_local_player":
			# [PT-BR] O servidor envia os dados do avatar local para spawn determinístico na cena
			# [EN] The server sends the local avatar data for deterministic spawning in the scene
			emit_signal("spawn_local_player", content.get("player", {}))
		"spawn_new_player":
			# [PT-BR] Um novo jogador remoto foi anunciado pelo servidor e deve ser instanciado localmente
			# [EN] A new remote player was announced by the server and must be instantiated locally
			emit_signal("spawn_new_player", content.get("player", {}))
		"spawn_network_players":
			# [PT-BR] Lista inicial de jogadores remotos para reconstruir o estado ao entrar na sala
			# [EN] Initial list of remote players to rebuild state when joining the room
			emit_signal("spawn_network_players", content.get("players", []))
		"update_position":
			# [PT-BR] Atualização de posição recebida do servidor para manter a replicação em tempo real
			# [EN] Position update received from the server to keep real-time replication in sync
			emit_signal("update_position", content)
		"player_disconnected":
			# [PT-BR] Notifica a camada de jogo para remover o avatar do jogador desconectado
			# [EN] Notifies the gameplay layer to remove the disconnected player's avatar
			emit_signal("player_disconnected", content)
		"error":
			# [PT-BR] Erros de servidor são repassados para permitir tratamento visual na interface
			# [EN] Server errors are forwarded so the UI can handle them visually
			emit_signal("server_error", content)
