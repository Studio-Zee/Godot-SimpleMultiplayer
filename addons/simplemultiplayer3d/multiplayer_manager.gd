extends Node

# --- AQUI ESTÁ A CORREÇÃO: Puxamos as cenas direto dos arquivos! ---
var player_scene = preload("res://player/player_local.tscn") 
var network_player_scene = preload("res://player/player_rede.tscn")

var player_nodes = {}
var pending_spawns: Array = []

func _ready():
	call_deferred("_connect_signals")

func set_player_container(container: Node):
	var player_container = container
	for spawn_data in pending_spawns:
		_spawn_player_now(spawn_data.uuid, spawn_data.is_local, spawn_data.player_data)
	pending_spawns.clear()

func spawn_player(uuid: String, is_local: bool, player_data: Dictionary = {}):
	if not player_scene or not network_player_scene:
		push_error("Cenas de jogador não configuradas no MultiplayerManager!")
		return
	
	var player_container = get_tree().current_scene.get_node_or_null("PlayerContainer")
	if player_container:
		_spawn_player_now(uuid, is_local, player_data)
	else:
		pending_spawns.append({"uuid": uuid, "is_local": is_local, "player_data": player_data})

func _spawn_player_now(uuid: String, is_local: bool, player_data: Dictionary = {}):
	var scene = player_scene if is_local else network_player_scene
	var player = scene.instantiate()
	player.name = uuid
	
	# Puxa o X, Y, Z e Rotação enviados pelo servidor
	if player_data.has("x") and player_data.has("y") and player_data.has("z"):
		player.global_position = Vector3(player_data.x, player_data.y, player_data.z)
		if player_data.has("r_y"):
			player.rotation.y = player_data.r_y
	
	var player_container = get_tree().current_scene.get_node("PlayerContainer")
	player_container.add_child(player)
	player_nodes[uuid] = player

func remove_player(uuid: String):
	if player_nodes.has(uuid):
		player_nodes[uuid].queue_free()
		player_nodes.erase(uuid)

func update_player_position(uuid: String, new_position: Vector3, rot_y: float):
	if player_nodes.has(uuid):
		player_nodes[uuid].global_position = new_position
		player_nodes[uuid].rotation.y = rot_y

func _connect_signals():
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("spawn_local_player", Callable(self, "_on_spawn_local_player"))
		ws_client.connect("spawn_new_player", Callable(self, "_on_spawn_new_player"))
		ws_client.connect("spawn_network_players", Callable(self, "_on_spawn_network_players"))
		ws_client.connect("update_position", Callable(self, "_on_update_position"))
		ws_client.connect("player_disconnected", Callable(self, "_on_player_disconnected"))

func _on_spawn_local_player(player_data: Dictionary):
	var ws_client = get_node("/root/WebSocketClient")
	spawn_player(ws_client.uuid, true, player_data)

func _on_spawn_new_player(player_data: Dictionary):
	var player_uuid = player_data.get("uuid", "")
	if player_uuid:
		spawn_player(player_uuid, false, player_data)

func _on_spawn_network_players(players_data: Array):
	for player_data in players_data:
		var player_uuid = player_data.get("uuid", "")
		if player_uuid:
			spawn_player(player_uuid, false, player_data)

func _on_update_position(position_data: Dictionary):
	var uuid = position_data.get("uuid", "")
	var x = position_data.get("x", 0.0)
	var y = position_data.get("y", 0.0)
	var z = position_data.get("z", 0.0)
	var r_y = position_data.get("r_y", 0.0)
	
	if uuid and player_nodes.has(uuid):
		update_player_position(uuid, Vector3(x, y, z), r_y)

func _on_player_disconnected(player_data: Dictionary):
	var uuid = player_data.get("uuid", "")
	if uuid and player_nodes.has(uuid):
		remove_player(uuid)
