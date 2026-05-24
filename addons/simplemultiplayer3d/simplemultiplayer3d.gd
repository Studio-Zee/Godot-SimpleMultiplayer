@tool
# [PT-BR] Entrada principal do plugin para integração com o editor da Godot
# [EN] Main plugin entry point for Godot editor integration
extends EditorPlugin


# [PT-BR] Ponto de extensão para habilitar recursos adicionais do plugin no editor
# [EN] Extension point for enabling additional plugin features in the editor
func _enable_plugin() -> void:
	# [PT-BR] Este template mantém o ponto de ativação reservado para customizações futuras
	# [EN] This template keeps the activation point reserved for future customizations
	pass


# [PT-BR] Ponto de extensão para desabilitar recursos adicionais do plugin no editor
# [EN] Extension point for disabling additional plugin features in the editor
func _disable_plugin() -> void:
	# [PT-BR] Este template mantém o ponto de desativação reservado para customizações futuras
	# [EN] This template keeps the deactivation point reserved for future customizations
	pass


# [PT-BR] Executado quando o plugin é carregado na árvore do editor
# [EN] Runs when the plugin is loaded into the editor tree
func _enter_tree() -> void:
	# [PT-BR] Inicialização principal do plugin no editor fica concentrada neste ponto
	# [EN] The plugin's main editor initialization is concentrated at this point
	pass


# [PT-BR] Executado quando o plugin é removido da árvore do editor
# [EN] Runs when the plugin is removed from the editor tree
func _exit_tree() -> void:
	# [PT-BR] Limpeza principal do plugin no editor fica concentrada neste ponto
	# [EN] The plugin's main editor cleanup is concentrated at this point
	pass
