#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zm_alcatraz_traps;
#include maps\mp\gametypes_zm\_zm_gametype;

#include scripts\zm\functions;

// Menu Base by ZECxR3ap3r

init() {
	setdvar("g_ai", 0);
	
	level thread on_connect();
}

on_connect() {
    for(;;) {
        level waittill("connected", player);
        
        player thread on_spawned();
    }
}

on_spawned() {
	self.initial_spawn = 0;
	
	while(1) {
		self waittill("spawned_player");
		
		if(self.initial_spawn == 0) {
			self.initial_spawn = 1;
			
			flag_wait("initial_blackscreen_passed");
			
			self thread menu_menu_think();
			
			wait 1;
		}
	}
}

menu_menu_options_create() {
	self endon("disconnect");
	
	menu = self.menu[self.menu.size - 1].menu;
	
	switch(menu) {
		case "main":
			self add_menu_option("Player Options", ::new_menu, "self_menu", undefined, undefined, undefined, 1);
			self add_menu_option("Menu Options", ::new_menu, "menu_opt", undefined, undefined, undefined, 1);
			self add_menu_option("Client Options", ::new_menu, "client_opt", undefined, undefined, undefined, 1);
			break;
		case "self_menu":
			self add_menu_option("God Mode", ::god, "boolean", self.godmode);
			self add_menu_option("Noclip", ::cnoclip, "boolean", self.noclip);
			self add_menu_option("Score Options", ::new_menu, "self_score_menu", undefined, undefined, undefined, 1);
			break;
		case "self_score_menu":
			for(i = 500;i <= 1000000;i += (i * 3)) {
				self add_menu_option("+ " + int(i), ::edit_score, int(i), "add");
				self add_menu_option("- " + int(i), ::edit_score, int(i), "minus");
			}
			break;
		case "menu_opt":
			self add_menu_option("Change Color", ::new_menu, "menu_opt_color", undefined, undefined, undefined, 1);
			self add_menu_option("Settings", ::new_menu, "menu_opt_settings", undefined, undefined, undefined, 1);
			break;
		case "menu_opt_settings":
			self add_menu_option("Toggle Prints", ::sett_prints, "boolean", self.sett_print);
			self add_menu_option("Toggle Background", ::sett_background, "boolean", self.sett_background);
			break;
		case "menu_opt_color":
			self add_menu_option("Red", ::change_ui_color, (1,0,0));
			self add_menu_option("Green", ::change_ui_color, (0,1,0));
			self add_menu_option("Dark Blue", ::change_ui_color, (.1,.1,1));
			self add_menu_option("Cyan", ::change_ui_color, (0,1,1));
			self add_menu_option("Orange", ::change_ui_color, (1,.5,0));
			self add_menu_option("Yellow", ::change_ui_color, (1,1,0));
			self add_menu_option("Lime Green", ::change_ui_color, (.5,1,0));
			self add_menu_option("Light Blue", ::change_ui_color, (.5,.5,1));
			self add_menu_option("Purple", ::change_ui_color, (.5,0,1));
			self add_menu_option("Pink", ::change_ui_color, (1,0,1));
			self add_menu_option("Aqua Blue", ::change_ui_color, (0,.5,1));
			self add_menu_option("Dark Red", ::change_ui_color, (.5,0,0));
			self add_menu_option("Dark Green", ::change_ui_color, (0,.5,0));
			self add_menu_option("Black", ::change_ui_color, (0,0,0));
			break;
		case "client_opt":
			foreach(player in level.players)
				self add_menu_option(player.name, ::new_menu, "client_opt_" + player.name, undefined, undefined, undefined, 1);
			break;
	}
	
	if(issubstr(menu, "client_opt"))
		self thread client_menu(menu);
}

client_menu(menu) {
	foreach(player in level.players) {
		if(menu == "client_opt_" + player.name) {
			self add_menu_option("God Mode", ::god, "boolean", player.godmode, player);
			break;
		}
	}
}

new_menu(menu) {
	i = self.menu.size;
	
	self.menu[i] 				= spawnstruct();
	self.menu[i].menu			= menu;
	self.menu[i - 1].focused	= self.focused_option;
	
	self notify("menu_refresh");
	
	if(int(self.menu.size - 1) == 1)
		self.ui_elements["menu_options_2"].alpha = 1;
	else if(int(self.menu.size - 1) == 2)
		self.ui_elements["menu_options_3"].alpha = 1;
	else if(int(self.menu.size - 1) == 3)
		self.ui_elements["menu_options_4"].alpha = 1;
	else if(int(self.menu.size - 1) == 4)
		self.ui_elements["menu_options_5"].alpha = 1;
	else if(int(self.menu.size - 1) == 5)
		self.ui_elements["menu_options_6"].alpha = 1;
	
	self.menu_options = [];
	self thread menu_menu_options_create();
	self.focused_option = 0;
}

menu_menu_think() {
	self endon("disconnect");
	
	self.initial_spawn_menu 	= 0;
	self.menu 					= [];
	self.menu[0]				= spawnstruct();
	self.menu[0].menu			= "main";
	self.menu[0].y 				= 20;
	self.menu_open 				= undefined;
	self.focused_option			= 0;
	self.sett_print 			= true;
	self.sett_background		= true;
	
	self setclientdvar("g_teamcolor_allies", "0 1 0 1");
	
	if(!isdefined(self.ui_elements))
		self.ui_elements = [];
	
	if(!isdefined(self.ui_elements["menu_title"])) {
		self.ui_elements["menu_title"] = newclienthudelem(self);
		self.ui_elements["menu_title"].horzalign = "fullscreen";
		self.ui_elements["menu_title"].vertalign = "fullscreen";
		self.ui_elements["menu_title"].alignx = "left";
		self.ui_elements["menu_title"].aligny = "middle";
		self.ui_elements["menu_title"].x = 10;
		self.ui_elements["menu_title"].y = 21;
		self.ui_elements["menu_title"].fontscale = 1.25;
		self.ui_elements["menu_title"].alpha = 0;
		self.ui_elements["menu_title"] hud_settext("^8Reaper Menu v1.0.7\r_________________");
	}
	
	while(1) {
		wait .05;
		
		if(self actionslotonebuttonpressed()) {
			if(!isdefined(self.menu_open)) {
				self iprintln("Reaper Menu ^8Opened");
				self.menu_open = 1;
				self.ui_elements["menu_title"].alpha = 1;
				
				self thread menu_menu_load();
			}
			else {
				if(self.focused_option == 0)
					self.focused_option = self.menu_options.size - 1;
				else {
					self.focused_option -= 1;
					
					if(isdefined(self.menu_options[self.focused_option].seperator) && self.menu_options[self.focused_option].seperator == 1)
						self.focused_option -= 1;
				}
					
				self notify("menu_refresh");
			}
		}
		
		if(self actionslottwobuttonpressed()) {
			if(isdefined(self.menu_open)) {
				if((self.focused_option + 1) >= self.menu_options.size)
					self.focused_option = 0;
				else {
					self.focused_option += 1;
					
					if(isdefined(self.menu_options[self.focused_option].seperator) && self.menu_options[self.focused_option].seperator == 1)
						self.focused_option += 1;
				}
					
				self notify("menu_refresh");
				
				wait .05;
			}
		}
		
		if(self usebuttonpressed()) {
			if(isdefined(self.menu_open)) {
				if(isdefined(self.menu_options[self.focused_option].boolean)) {
					if(self.menu_options[self.focused_option].boolean == false) {
						self.menu_options[self.focused_option].boolean = true;
						if(self.sett_print == true)
							self iprintln(self.menu_options[self.focused_option].displayname + ": ^8ON");
					}
					else {
						self.menu_options[self.focused_option].boolean = false;
						if(self.sett_print == true)
							self iprintln(self.menu_options[self.focused_option].displayname + ": ^1OFF");
					}
				}
				
				if(!isdefined(self.menu_options[self.focused_option].kvp1))
					self thread [[self.menu_options[self.focused_option].function]]();
				else {
					if(isdefined(self.menu_options[self.focused_option].kvp1) && isdefined(self.menu_options[self.focused_option].kvp2) && isdefined(self.menu_options[self.focused_option].kvp3) && isdefined(self.menu_options[self.focused_option].kvp4))
						self thread [[self.menu_options[self.focused_option].function]](self.menu_options[self.focused_option].kvp1, self.menu_options[self.focused_option].kvp2, self.menu_options[self.focused_option].kvp3, self.menu_options[self.focused_option].kvp4);
					else if(isdefined(self.menu_options[self.focused_option].kvp1) && isdefined(self.menu_options[self.focused_option].kvp2) && isdefined(self.menu_options[self.focused_option].kvp3) && !isdefined(self.menu_options[self.focused_option].kvp4))
						self thread [[self.menu_options[self.focused_option].function]](self.menu_options[self.focused_option].kvp1, self.menu_options[self.focused_option].kvp2, self.menu_options[self.focused_option].kvp3);
					else if(isdefined(self.menu_options[self.focused_option].kvp1) && isdefined(self.menu_options[self.focused_option].kvp2) && !isdefined(self.menu_options[self.focused_option].kvp3) && !isdefined(self.menu_options[self.focused_option].kvp4))
						self thread [[self.menu_options[self.focused_option].function]](self.menu_options[self.focused_option].kvp1, self.menu_options[self.focused_option].kvp2);
					else if(isdefined(self.menu_options[self.focused_option].kvp1) && !isdefined(self.menu_options[self.focused_option].kvp2) && !isdefined(self.menu_options[self.focused_option].kvp3) && !isdefined(self.menu_options[self.focused_option].kvp4))
						self thread [[self.menu_options[self.focused_option].function]](self.menu_options[self.focused_option].kvp1);
				}
				
				self notify("menu_refresh");
			}
			
			wait .15;
		}
		
		if(self stanceButtonPressed()) {
			if(isdefined(self.menu_open)) {
				if(self.menu[self.menu.size - 1].menu == "main") {
					self iprintln("Reaper Menu ^1Closed");
					
					self notify("closed_menu");
					
					self.ui_elements["menu_title"].alpha = 0;
					self.ui_elements["menu_options_1"] destroy();
					self.ui_elements["menu_options_2"] destroy();
					self.ui_elements["menu_options_3"] destroy();
					self.ui_elements["menu_options_4"] destroy();
					self.ui_elements["menu_options_5"] destroy();
					self.ui_elements["menu_options_6"] destroy();
					self.ui_elements["menu_controls"] destroy();
					self.ui_elements["menu_options_count_curr"] destroy();
					self.ui_elements["menu_options_count_max"] destroy();
					self.ui_elements["menu_options_boolean"] destroy();
					if(isdefined(self.ui_elements["menu_background"]))
						self.ui_elements["menu_background"] destroy();
					
					self.menu_open = undefined;
				}
				else {
					self.menu[self.menu.size - 1] = undefined;
					
					if(int(self.menu.size) == 1)
						self.ui_elements["menu_options_2"].alpha = 0;
					else if(int(self.menu.size) == 2)
						self.ui_elements["menu_options_3"].alpha = 0;
					else if(int(self.menu.size) == 3)
						self.ui_elements["menu_options_4"].alpha = 0;
					else if(int(self.menu.size) == 4)
						self.ui_elements["menu_options_5"].alpha = 0;
					else if(int(self.menu.size) == 5)
						self.ui_elements["menu_options_6"].alpha = 0;
				
					self.menu_options 			= undefined;
					self.menu_options 			= [];
					self thread menu_menu_options_create();
					if(isdefined(self.menu[self.menu.size - 1].focused))
						self.focused_option 		= self.menu[self.menu.size - 1].focused;
					else
						self.focused_option 		= 0;
					
					self notify("menu_refresh");
				}
				
				wait .15;
			}
		}
	}
}

menu_menu_load() {
	self endon("disconnect");
	self endon("closed_menu");
	
	if(!isdefined(self.custom_input_y)) {
		y = 30;
		x = 10;
	}
	else {
		y = self.custom_input_y;
		x = self.custom_input_x;
	}
	
	if(!isdefined(self.ui_elements["menu_options_1"])) {
		self.ui_elements["menu_options_1"] = newclienthudelem(self);
		self.ui_elements["menu_options_1"].horzalign = "fullscreen";
		self.ui_elements["menu_options_1"].vertalign = "fullscreen";
		self.ui_elements["menu_options_1"].alignx = "left";
		self.ui_elements["menu_options_1"].aligny = "top";
		self.ui_elements["menu_options_1"].x = x;
		self.ui_elements["menu_options_1"].y = y;
		self.ui_elements["menu_options_1"].font = "small";
		self.ui_elements["menu_options_1"].fontscale = 1;
		self.ui_elements["menu_options_1"].alpha = 1;
	}
	
	if(!isdefined(self.ui_elements["menu_options_2"])) {
		self.ui_elements["menu_options_2"] = newclienthudelem(self);
		self.ui_elements["menu_options_2"].horzalign = "fullscreen";
		self.ui_elements["menu_options_2"].vertalign = "fullscreen";
		self.ui_elements["menu_options_2"].alignx = "left";
		self.ui_elements["menu_options_2"].aligny = "top";
		self.ui_elements["menu_options_2"].x = x + 60;
		self.ui_elements["menu_options_2"].y = y;
		self.ui_elements["menu_options_2"].font = "small";
		self.ui_elements["menu_options_2"].fontscale = 1;
		self.ui_elements["menu_options_2"].alpha = 1;
	}
	
	if(!isdefined(self.ui_elements["menu_options_3"])) {
		self.ui_elements["menu_options_3"] = newclienthudelem(self);
		self.ui_elements["menu_options_3"].horzalign = "fullscreen";
		self.ui_elements["menu_options_3"].vertalign = "fullscreen";
		self.ui_elements["menu_options_3"].alignx = "left";
		self.ui_elements["menu_options_3"].aligny = "top";
		self.ui_elements["menu_options_3"].x = x + 130;
		self.ui_elements["menu_options_3"].y = y;
		self.ui_elements["menu_options_3"].font = "small";
		self.ui_elements["menu_options_3"].fontscale = 1;
		self.ui_elements["menu_options_3"].alpha = 1;
	}
	
	if(!isdefined(self.ui_elements["menu_options_4"])) {
		self.ui_elements["menu_options_4"] = newclienthudelem(self);
		self.ui_elements["menu_options_4"].horzalign = "fullscreen";
		self.ui_elements["menu_options_4"].vertalign = "fullscreen";
		self.ui_elements["menu_options_4"].alignx = "left";
		self.ui_elements["menu_options_4"].aligny = "top";
		self.ui_elements["menu_options_4"].x = x + 220;
		self.ui_elements["menu_options_4"].y = y;
		self.ui_elements["menu_options_4"].font = "small";
		self.ui_elements["menu_options_4"].fontscale = 1;
		self.ui_elements["menu_options_4"].alpha = 1;
	}
	
	if(!isdefined(self.ui_elements["menu_options_5"])) {
		self.ui_elements["menu_options_5"] = newclienthudelem(self);
		self.ui_elements["menu_options_5"].horzalign = "fullscreen";
		self.ui_elements["menu_options_5"].vertalign = "fullscreen";
		self.ui_elements["menu_options_5"].alignx = "left";
		self.ui_elements["menu_options_5"].aligny = "top";
		self.ui_elements["menu_options_5"].x = x + 270;
		self.ui_elements["menu_options_5"].y = y;
		self.ui_elements["menu_options_5"].font = "small";
		self.ui_elements["menu_options_5"].fontscale = 1;
		self.ui_elements["menu_options_5"].alpha = 1;
	}
	
	if(!isdefined(self.ui_elements["menu_options_6"])) {
		self.ui_elements["menu_options_6"] = newclienthudelem(self);
		self.ui_elements["menu_options_6"].horzalign = "fullscreen";
		self.ui_elements["menu_options_6"].vertalign = "fullscreen";
		self.ui_elements["menu_options_6"].alignx = "left";
		self.ui_elements["menu_options_6"].aligny = "top";
		self.ui_elements["menu_options_6"].x = x + 320;
		self.ui_elements["menu_options_6"].y = y;
		self.ui_elements["menu_options_6"].font = "small";
		self.ui_elements["menu_options_6"].fontscale = 1;
		self.ui_elements["menu_options_6"].alpha = 1;
	}
	
	if(!isdefined(self.ui_elements["menu_options_count_curr"])) {
		self.ui_elements["menu_options_count_curr"] = newclienthudelem(self);
		self.ui_elements["menu_options_count_curr"].horzalign = "fullscreen";
		self.ui_elements["menu_options_count_curr"].vertalign = "fullscreen";
		self.ui_elements["menu_options_count_curr"].alignx = "right";
		self.ui_elements["menu_options_count_curr"].aligny = "top";
		self.ui_elements["menu_options_count_curr"].x = x;
		self.ui_elements["menu_options_count_curr"].y = y;
		self.ui_elements["menu_options_count_curr"].font = "small";
		self.ui_elements["menu_options_count_curr"].fontscale = 1.1;
		self.ui_elements["menu_options_count_curr"].alpha = 1;
		self.ui_elements["menu_options_count_curr"].label = &"^8";
	}
	
	if(!isdefined(self.ui_elements["menu_options_count_max"])) {
		self.ui_elements["menu_options_count_max"] = newclienthudelem(self);
		self.ui_elements["menu_options_count_max"].horzalign = "fullscreen";
		self.ui_elements["menu_options_count_max"].vertalign = "fullscreen";
		self.ui_elements["menu_options_count_max"].alignx = "left";
		self.ui_elements["menu_options_count_max"].aligny = "top";
		self.ui_elements["menu_options_count_max"].x = self.ui_elements["menu_options_count_curr"].x + 2;
		self.ui_elements["menu_options_count_max"].y = y;
		self.ui_elements["menu_options_count_max"].font = "small";
		self.ui_elements["menu_options_count_max"].fontscale = 1.1;
		self.ui_elements["menu_options_count_max"].alpha = 1;
		self.ui_elements["menu_options_count_max"].label = &" / ^8";
	}
	
	if(!isdefined(self.ui_elements["menu_controls"])) {
		self.ui_elements["menu_controls"] = newclienthudelem(self);
		self.ui_elements["menu_controls"].horzalign = "fullscreen";
		self.ui_elements["menu_controls"].vertalign = "fullscreen";
		self.ui_elements["menu_controls"].alignx = "left";
		self.ui_elements["menu_controls"].aligny = "bottom";
		self.ui_elements["menu_controls"].x = 10;
		self.ui_elements["menu_controls"].y = 470;
		self.ui_elements["menu_controls"].font = "small";
		self.ui_elements["menu_controls"].fontscale = 1.2;
		self.ui_elements["menu_controls"].alpha = 1;
	}
	
	if(!isdefined(self.ui_elements["menu_options_boolean"])) {
		self.ui_elements["menu_options_boolean"] = newclienthudelem(self);
		self.ui_elements["menu_options_boolean"].horzalign = "fullscreen";
		self.ui_elements["menu_options_boolean"].vertalign = "fullscreen";
		self.ui_elements["menu_options_boolean"].alignx = "left";
		self.ui_elements["menu_options_boolean"].aligny = "top";
		self.ui_elements["menu_options_boolean"].x = x;
		self.ui_elements["menu_options_boolean"].y = y;
		self.ui_elements["menu_options_boolean"].font = "small";
		self.ui_elements["menu_options_boolean"].fontscale = 1;
		self.ui_elements["menu_options_boolean"].alpha = 1;
	}
	
	if(isdefined(self.sett_background) && self.sett_background == 1) {
		if(!isdefined(self.ui_elements["menu_background"])) {
			self.ui_elements["menu_background"] = newclienthudelem(self);
			self.ui_elements["menu_background"].horzalign = "fullscreen";
			self.ui_elements["menu_background"].vertalign = "fullscreen";
			self.ui_elements["menu_background"].alignx = "left";
			self.ui_elements["menu_background"].aligny = "top";
			self.ui_elements["menu_background"].x = x - 4;
			self.ui_elements["menu_background"].y = y - 18;
			self.ui_elements["menu_background"].color = (0, 0, 0);
			self.ui_elements["menu_background"].alpha = .5;
			self.ui_elements["menu_background"].sort = -2;
		}
	}
	
	self.menu_options = [];
	self thread menu_menu_options_create();
	
	selected_color 		= 8;
	submenu_symbol 		= ">> ";
	
	self.ui_elements["menu_controls"] hud_settext("^"+selected_color+"[{+actionslot 1}] ^7 Scroll Up     ^"+selected_color+"[{+actionslot 2}] ^7 Scroll Down     ^"+selected_color+"[{+activate}] ^7 Select     ^"+selected_color+"[{+stance}] ^7 Close Menu");
	
	while(1) {
		str = "";
		boolean_str = "";
		
		if(self.focused_option == 0) {
			menu_calc_start  	= 0;
			menu_add_to 		= 3;
		}
		else if(self.focused_option == 1) {
			menu_calc_start 	= self.focused_option - 1;
			menu_add_to 		= 2;
		}
		else if(self.focused_option == 2) {
			menu_calc_start 	= self.focused_option - 2;
			menu_add_to 		= 1;
		}
		else {
			menu_calc_start = self.focused_option - 3;
			menu_add_to 		= 0;
			
			if(!isdefined(self.menu_options[self.focused_option + 4 + menu_add_to])) {
				if(!isdefined(self.menu_options[self.focused_option + 3 + menu_add_to])) {
					if(!isdefined(self.menu_options[self.focused_option + 2 + menu_add_to])) {
						if(!isdefined(self.menu_options[self.focused_option + 1 + menu_add_to]))
							menu_calc_start = self.focused_option - 6;
						else
							menu_calc_start = self.focused_option - 5;
					}
					else
						menu_calc_start = self.focused_option - 4;
				}
				else
					menu_calc_start = self.focused_option - 3;
			}
		}
		
		self.options_visible = 0;
		
		for(i = menu_calc_start;i < int(self.focused_option + 4 + menu_add_to);i++) {
			if(isdefined(self.menu_options[i])) {
				self.options_visible++;
				
				if(i == self.focused_option) {
					if(isdefined(self.menu_options[i].submenu) && self.menu_options[i].submenu == 1)
						str += "^" + selected_color + submenu_symbol + self.menu_options[i].displayname + "^7\n";
					else
						str += "^" + selected_color + self.menu_options[i].displayname + "^7\n";
				}
				else {
					if(isdefined(self.menu_options[i].submenu) && self.menu_options[i].submenu == 1)
						str += submenu_symbol + self.menu_options[i].displayname + "\n";
					else
						str += self.menu_options[i].displayname + "\n";
				}
				
				if(isdefined(self.menu_options[i].boolean)) {
					if(self.menu_options[i].boolean == true)
						boolean_str += "^8ON\n";
					else
						boolean_str += "^1OFF\n";
				}
				else
					boolean_str += "\n";
			}
		}
		
		self.ui_elements["menu_options_count_curr"].y 			= y + (self.options_visible * 12);
		self.ui_elements["menu_options_count_max"].y 			= y + (self.options_visible * 12);
		
		self.ui_elements["menu_options_count_curr"].x 			= self.ui_elements["menu_options_" + int(self.menu.size)].x + 3;
		self.ui_elements["menu_options_count_max"].x 			= self.ui_elements["menu_options_count_curr"].x + 2;
		self.ui_elements["menu_options_boolean"].x 				= self.ui_elements["menu_options_count_curr"].x + 50;
		self.ui_elements["menu_options_boolean"] 				hud_settext(boolean_str);
		
		self.ui_elements["menu_options_count_curr"] 			setvalue(self.focused_option + 1);
		self.ui_elements["menu_options_count_max"] 				setvalue(self.menu_options.size);
		
		self.ui_elements["menu_options_" + int(self.menu.size)] hud_settext(str);
		
		if(isdefined(self.ui_elements["menu_background"])) {
			longest = 0;
			
			for(i = 0;i < 6;i++) {
				if(isdefined(self.ui_elements["menu_options_" + i]) && self.ui_elements["menu_options_" + i].alpha == 1) {
					if(isdefined(self.ui_elements["menu_options_" + i].string)) {
						skips = strtok(self.ui_elements["menu_options_" + i].string, "\n");
						if(skips.size > longest)
							longest = skips.size;
					}
				}
			}
			
			self.ui_elements["menu_background"] setshader("white", int(self.ui_elements["menu_options_boolean"].x + 10), int(36 + longest * 12));
		}
		
		self waittill("menu_refresh");
	}
}

hud_settext(text) {
	if(!isdefined(level.current_strings))
		level.current_strings = 0;
		
	if(!isdefined(level.hud_elements))
		level.hud_elements = [];
		
	if(!isdefined(self.soecific_number))
		self.specific_number = level.hud_elements.size;
		
	if(!isdefined(level.hud_elements[self.specific_number]))
		level.hud_elements[self.specific_number] = self;
	
	if(isdefined(self)) {
		level.current_strings++;
		
		self settext(text);
		self.string = text;
	}
}

add_menu_option(displayname, function, k1, k2, k3, k4, submenu) {
	count = self.menu_options.size;
	
	self.menu_options[count] 				= spawnstruct();
	self.menu_options[count].displayname 	= displayname;
	self.menu_options[count].function 		= function;
	
	if(isdefined(k1))
		self.menu_options[count].kvp1 		= k1;
	if(isdefined(k2))
		self.menu_options[count].kvp2 		= k2;
	if(isdefined(k3))
		self.menu_options[count].kvp3 		= k3;
	if(isdefined(k4))
		self.menu_options[count].kvp4 		= k4;
	if(isdefined(submenu))
		self.menu_options[count].submenu 	= submenu;
	
	if(isdefined(k1) && isstring(k1) && k1 == "boolean") {
		if(!isdefined(k2))
			k2 = false;
		
		if(k2 == true)
			self.menu_options[count].boolean = true;
		else
			self.menu_options[count].boolean = false;
	}
}

add_menu_option_seperator() {
	count = self.menu_options.size;
	
	self.menu_options[count] 				= spawnstruct();
	self.menu_options[count].displayname 	= "";
	self.menu_options[count].seperator 	    = 1;
}

test() {
	self iprintln("^8Test");
}
