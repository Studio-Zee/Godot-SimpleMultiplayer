extends Node

var player_scene = preload("res://exemplo/player/player_local.tscn") 
var network_player_scene = preload("res://exemplo/player/player_rede.tscn")

var player_nodes = {}
var connected_players = {} 

func _ready():
	call_deferred("_connect_signals")

func set_player_container(container: Node):
	player_nodes.clear()
	# Recria os jogadores legítimos salvos na lista segura
	for uuid in connected_players:
		var p_info = connected_players[uuid]
		_spawn_player_now(uuid, p_info.is_local, p_info.data, container)

func spawn_player(uuid: String, is_local: bool, player_data: Dictionary = {}):
	if not player_scene or not network_player_scene:
		push_error("Cenas de jogador não configuradas no MultiplayerManager!")
		return
	
	# Salva na lista usando o UUID limpo como chave mestre
	connected_players[uuid] = {"is_local": is_local, "data": player_data}
	
	var current_scene = get_tree().current_scene
	var player_container = null
	
	if current_scene != null:
		player_container = current_scene.get_node_or_null("PlayerContainer")
	
	if player_container != null:
		_spawn_player_now(uuid, is_local, player_data, player_container)

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

func remove_player(uuid: String):
	# Remove da lista de contagem com segurança
	if connected_players.has(uuid):
		connected_players.erase(uuid)
		
	if player_nodes.has(uuid):
		if is_instance_valid(player_nodes[uuid]):
			player_nodes[uuid].queue_free()
		player_nodes.erase(uuid)

func update_player_position(uuid: String, new_position: Vector3, rot_y: float):
	if player_nodes.has(uuid):
		if is_instance_valid(player_nodes[uuid]):
			player_nodes[uuid].global_position = new_position
			player_nodes[uuid].rotation.y = rot_y
		else:
			player_nodes.erase(uuid)

func _connect_signals():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("spawn_local_player", Callable(self, "_on_spawn_local_player"))
		ws_client.connect("spawn_new_player", Callable(self, "_on_spawn_new_player"))
		ws_client.connect("spawn_network_players", Callable(self, "_on_spawn_network_players"))
		ws_client.connect("update_position", Callable(self, "_on_update_position"))
		ws_client.connect("player_disconnected", Callable(self, "_on_player_disconnected"))

# --- AJUSTE DOS SINAIS COMPATÍVEIS COM O WEBSOCKETCLIENT ---

func _on_spawn_local_player(player_data: Dictionary):
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		spawn_player(ws_client.uuid, true, player_data)

func _on_spawn_new_player(player_data: Dictionary):
	var player_uuid = player_data.get("uuid", "")
	if player_uuid:
		spawn_player(player_uuid, false, player_data)

func _on_spawn_network_players(players_array: Array):
	for player_data in players_array:
		var player_uuid = player_data.get("uuid", "")
		if player_uuid:
			spawn_player(player_uuid, false, player_data)

func _on_update_position(position_data: Dictionary):
	var uuid = position_data.get("uuid", "")
	var x = position_data.get("x", 0.0)
	var y = position_data.get("y", 0.0)
	var z = position_data.get("z", 0.0)
	var r_y = position_data.get("r_y", 0.0)
	
	if uuid:
		update_player_position(uuid, Vector3(x, y, z), r_y)

func _on_player_disconnected(content: Dictionary):
	var uuid = content.get("uuid", "")
	if uuid:
		remove_player(uuid)
