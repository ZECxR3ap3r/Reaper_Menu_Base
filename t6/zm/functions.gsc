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

#include scripts\zm\main;

change_ui_color(color) {
	self setclientdvar("g_teamcolor_allies", "" + color[0] + " " + color[1] + " " + color[2] + " 1");
	
	self iprintln("^8Color Successfully Changed!");
}

give_points(score, which, minus) {
	if(isdefined(which)) {
		if(isdefined(minus)) {
			self.score -= int(score);
			self iprintln("^1" + score + " ^7Points Taken");
		}
		else {
			self.score += int(score);
			self iprintln("+^8" + score + " ^7Points Given");
		}
	}
	else {
		self.score = int(score);
		self iprintln("^8" + score + " ^7Points Given");
	}
}

god(v1, v2, v3) {
	if(isdefined(v3)) {
		if(v3.godmode == 0) {
			v3 EnableInvulnerability();
			v3.godmode = 1;
		}
		else {
			v3 DisableInvulnerability();
			v3.godmode = 0;
		}
	}
	else {
		if(self.godmode == 0) {
			self EnableInvulnerability();
			self.godmode = 1;
		}
		else {
			self DisableInvulnerability();
			self.godmode = 0;
		}
	}
}

sett_prints() {
	if(self.sett_print == 0)
		self.sett_print = 1;
	else
		self.sett_print = 0;
}

sett_background() {
	if(self.sett_background == 0)
		self.sett_background = 1;
	else
		self.sett_background = 0;
}

cnoclip() {
	if(self.noclip == 0) {
		self.noclip = 1;
		self thread startNoClip();
    }
    else {
        self.noclip = 0;
        self unlink();
        self notify("EndUFOMode");
	}
}

edit_score(score, mode) {
	if(mode == "add")
		self.score += int(score);
	else
		self.score -= int(score);
}

vector_scal(vec, scale) {
	return(vec[0] * scale, vec[1] * scale, vec[2] * scale);
}

startNoClip() {
	self endon("EndUFOMode");
	self.Fly = 0;
	
	model = spawn("script_model", self.origin);
	
	while(1) {
		if(self secondaryoffhandbuttonpressed()) {
			self playerLinkTo(model);
			self.Fly = 1;
		}
		else
			self.Fly = 0;
		
		if(self actionSlotTwoButtonPressed()&&self.fly == 0) {
			self unlink();
			self.Fly = 0;
			self.UFo delete();
		}
		if(self.Fly == 1) {
			Fly = self.origin+vector_scal(anglesToForward(self getPlayerAngles()),75);
			model moveTo(Fly,.03);
		}
		wait .05;
	}
}

