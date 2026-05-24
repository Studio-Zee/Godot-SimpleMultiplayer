@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("WebSocketClient", "res://addons/simplemultiplayer3d/websocket_client.gd")
	add_autoload_singleton("MultiplayerManager", "res://addons/simplemultiplayer3d/multiplayer_manager.gd")

func _exit_tree():
	remove_autoload_singleton("WebSocketClient")
	remove_autoload_singleton("MultiplayerManager")
