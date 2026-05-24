@tool
# [PT-BR] Plugin do editor responsável por registrar os autoloads centrais do multiplayer
# [EN] Editor plugin responsible for registering the core multiplayer autoloads
extends EditorPlugin

# [PT-BR] Registra os singletons globais usados pelo plugin quando ele entra na árvore do editor
# [EN] Registers the global singletons used by the plugin when it enters the editor tree
func _enter_tree():
	add_autoload_singleton("WebSocketClient", "res://addons/simplemultiplayer3d/websocket_client.gd")
	add_autoload_singleton("MultiplayerManager", "res://addons/simplemultiplayer3d/multiplayer_manager.gd")

# [PT-BR] Remove os autoloads registrados pelo plugin ao sair da árvore do editor
# [EN] Removes the autoloads registered by the plugin when it exits the editor tree
func _exit_tree():
	remove_autoload_singleton("WebSocketClient")
	remove_autoload_singleton("MultiplayerManager")
