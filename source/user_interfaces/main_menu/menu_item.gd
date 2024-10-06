extends Control

class_name MenuItem

signal close_menu
signal transition_menu(new_menu: Control)

@export var menu_name: String

# Dict[String, Control]
var menus = {
    MAIN_MENU = "main_menu",
    TITLE_SCREEN_MENU = "title_screen_menu",
    MULTIPLAYER_MENU = "multiplayer_menu"
}


static func get_menu(selected_menu_name: String, menu_options: Array[Control]):
    for menu in menu_options:
        if selected_menu_name == menu.get("menu_name"): 
            return menu