extends Node3D

func _ready():
	# Avisa o gerenciador que o mapa carregou e ele já pode liberar os bonecos na arena
	var mp_manager = get_node_or_null("/root/MultiplayerManager")
	if mp_manager:
		mp_manager.set_player_container($PlayerContainer)
