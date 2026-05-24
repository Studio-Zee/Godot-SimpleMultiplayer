extends Node3D

# [PT-BR] Cena de mundo principal que entrega o container de jogadores ao gerenciador de rede
# [EN] Main world scene that hands the player container to the network manager

# [PT-BR] Notifica o gerenciador de multiplayer que a arena já está pronta para receber jogadores
# [EN] Notifies the multiplayer manager that the arena is ready to receive players
func _ready():
	# [PT-BR] A liberação dos jogadores depende do container existir na cena carregada
	# [EN] Player spawning depends on the container existing in the loaded scene
	var mp_manager = get_node_or_null("/root/MultiplayerManager")
	if mp_manager:
		mp_manager.set_player_container($PlayerContainer)
