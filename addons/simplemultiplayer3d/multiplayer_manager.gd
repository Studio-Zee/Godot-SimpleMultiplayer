extends Node

# [PT-BR] Gerenciador de instâncias de jogadores para cenas locais e de rede
# [EN] Player instance manager for local and network scenes

# [PT-BR] Cena utilizada para o jogador local controlado pelo cliente atual
# [EN] Scene used for the local player controlled by the current client
var player_scene = preload("res://exemplo/player/player_local.tscn")
# [PT-BR] Cena utilizada para representar jogadores remotos sincronizados pela rede
# [EN] Scene used to represent remote players synchronized over the network
var network_player_scene = preload("res://exemplo/player/player_rede.tscn")

# [PT-BR] Cache de nós instanciados na cena atual, indexado pelo UUID do jogador
# [EN] Cache of instantiated nodes in the current scene, indexed by player UUID
var player_nodes = {}
# [PT-BR] Lista segura dos jogadores conhecidos pelo sistema de rede e seus dados de spawn
# [EN] Safe list of players known by the network system and their spawn data
var connected_players = {}

# [PT-BR] Agenda a ligação com os sinais do autoload de rede depois que a árvore estiver pronta
# [EN] Defers the connection to network autoload signals until the tree is ready
func _ready():
	call_deferred("_connect_signals")

# [PT-BR] Define o container onde os jogadores devem ser adicionados quando a cena já estiver pronta
# [EN] Defines the container where players should be added when the scene is already ready
func set_player_container(container: Node):
	player_nodes.clear()
	# [PT-BR] Recria os jogadores já validados quando o container de destino é disponibilizado
	# [EN] Recreates the already validated players when the destination container becomes available
	for uuid in connected_players:
		var p_info = connected_players[uuid]
		_spawn_player_now(uuid, p_info.is_local, p_info.data, container)

# [PT-BR] Registra um jogador na lista segura e, se possível, cria sua instância na cena ativa
# [EN] Registers a player in the safe list and, when possible, creates its instance in the active scene
func spawn_player(uuid: String, is_local: bool, player_data: Dictionary = {}):
	if not player_scene or not network_player_scene:
		push_error("Cenas de jogador não configuradas no MultiplayerManager!")
		return
	
	# [PT-BR] Mantém o UUID como chave principal para reconciliar estado entre cenas e rede
	# [EN] Keeps the UUID as the primary key to reconcile state between scenes and network
	connected_players[uuid] = {"is_local": is_local, "data": player_data}
	
	var current_scene = get_tree().current_scene
	var player_container = null
	
	if current_scene != null:
		player_container = current_scene.get_node_or_null("PlayerContainer")
	
	if player_container != null:
		_spawn_player_now(uuid, is_local, player_data, player_container)

# [PT-BR] Instancia o scene tree correto para o jogador e aplica posição/rotação iniciais quando disponíveis
# [EN] Instantiates the correct scene tree for the player and applies initial position/rotation when available
func _spawn_player_now(uuid: String, is_local: bool, player_data: Dictionary, container: Node):
	if container.has_node(uuid):
		return
		
	var scene = player_scene if is_local else network_player_scene
	var player = scene.instantiate()
	player.name = uuid
	
	if player_data.has("x") and player_data.has("y") and player_data.has("z"):
		player.global_position = Vector3(player_data.x, player_data.y, player_data.z)
		if player_data.has("r_y"):
			player.rotation.y = player_data.r_y
	
	container.add_child(player)
	player_nodes[uuid] = player

# [PT-BR] Remove o jogador da lista segura e destrói a instância correspondente, se ela existir
# [EN] Removes the player from the safe list and destroys the corresponding instance, if it exists
func remove_player(uuid: String):
	# [PT-BR] Remove o registro interno antes de liberar o nó para manter o estado consistente
	# [EN] Removes the internal record before freeing the node to keep state consistent
	if connected_players.has(uuid):
		connected_players.erase(uuid)
		
	if player_nodes.has(uuid):
		if is_instance_valid(player_nodes[uuid]):
			player_nodes[uuid].queue_free()
		player_nodes.erase(uuid)

# [PT-BR] Atualiza a transform do jogador existente a partir dos dados recebidos da rede
# [EN] Updates the existing player's transform from network-received data
func update_player_position(uuid: String, new_position: Vector3, rot_y: float):
	if player_nodes.has(uuid):
		if is_instance_valid(player_nodes[uuid]):
			player_nodes[uuid].global_position = new_position
			player_nodes[uuid].rotation.y = rot_y
		else:
			player_nodes.erase(uuid)

# [PT-BR] Conecta os sinais do autoload WebSocketClient às rotinas que atualizam a cena
# [EN] Connects the WebSocketClient autoload signals to the routines that update the scene
func _connect_signals():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("spawn_local_player", Callable(self , "_on_spawn_local_player"))
		ws_client.connect("spawn_new_player", Callable(self , "_on_spawn_new_player"))
		ws_client.connect("spawn_network_players", Callable(self , "_on_spawn_network_players"))
		ws_client.connect("update_position", Callable(self , "_on_update_position"))
		ws_client.connect("player_disconnected", Callable(self , "_on_player_disconnected"))

# [PT-BR] Recebe o pacote do jogador local e o encaminha para o spawn controlado pelo UUID do cliente
# [EN] Receives the local player payload and forwards it to the UUID-controlled spawn path
func _on_spawn_local_player(player_data: Dictionary):
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		spawn_player(ws_client.uuid, true, player_data)

# [PT-BR] Spawna um jogador remoto recém-anunciado pelo servidor
# [EN] Spawns a newly announced remote player from the server
func _on_spawn_new_player(player_data: Dictionary):
	var player_uuid = player_data.get("uuid", "")
	if player_uuid:
		spawn_player(player_uuid, false, player_data)

# [PT-BR] Reconstrói a lista de jogadores remotos recebida em lote ao entrar na sala
# [EN] Rebuilds the batch of remote players received when joining the room
func _on_spawn_network_players(players_array: Array):
	for player_data in players_array:
		var player_uuid = player_data.get("uuid", "")
		if player_uuid:
			spawn_player(player_uuid, false, player_data)

# [PT-BR] Aplica uma atualização incremental de posição e rotação enviada pelo servidor
# [EN] Applies an incremental position and rotation update sent by the server
func _on_update_position(position_data: Dictionary):
	var uuid = position_data.get("uuid", "")
	var x = position_data.get("x", 0.0)
	var y = position_data.get("y", 0.0)
	var z = position_data.get("z", 0.0)
	var r_y = position_data.get("r_y", 0.0)
	
	if uuid:
		update_player_position(uuid, Vector3(x, y, z), r_y)

# [PT-BR] Remove da cena o jogador identificado como desconectado pelo servidor
# [EN] Removes from the scene the player identified as disconnected by the server
func _on_player_disconnected(content: Dictionary):
	var uuid = content.get("uuid", "")
	if uuid:
		remove_player(uuid)
