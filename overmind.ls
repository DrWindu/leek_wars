/* You touch my mind, fumbling in ignorance, incapable of understanding. There
 * is a realm of existence so far beyond your own you cannot even imagine it.
 * I am beyond your comprehension. I am the Overmind. I am legion. I am Zerg.
 */

global debug_level = 3;
global info    = function (msg) { if (debug_level > 3) debugC("I:"+msg,getColor(128,128,128)); };
global notice  = function (msg) { if (debug_level > 2) debugC("N:"+msg,getColor(16,128,0)); };
global warning = function (msg) { if (debug_level > 1) debugC("W:"+msg,getColor(255,128,0)); };
global error   = function (msg) { if (debug_level > 0) debugC("E:"+msg,getColor(255,0,0)); };

global color = getColor;
global red    = color(255,  0,  0),
       green  = color(  0,128,  0),
       teal   = color(  0,128,128),
       purple = color(128,  0,128);

global ops = getOperations;

global push_all = pushAll;
global in_array = inArray;
global array_filter = arrayFilter;
global rand_int = randInt;

global _self = getLeek;         // 1-5
global name = getName;
global type = getType;
global life = getLife;
global max_life = getTotalLife;
global rush = moveToward;
global flee = moveAwayFrom;
global grab = setWeapon;
global shoot = useWeapon;
global cast = useChip;
global cell_x = getCellX;
global cell_y = getCellY;
global cell = getCell;
global xy2cell = getCellFromXY;
global los = lineOfSight;
global los_ignore = lineOfSight;
global nearest_ally = getNearestAlly;
global nearest_hostile = getNearestEnemy;
global nearest_ally_cell = getNearestAllyToCell;
global nearest_hostile_cell = getNearestEnemyToCell;
global weapon_min_range = getWeaponMinRange;
global weapon_max_range = getWeaponMaxRange;

global rush_cell = moveTowardCell;
global cell_distance = getCellDistance;

global weapon;                  // 7+
global shoot_cell;
global cast_cell;
global frequency;               // 8+
global is_inline_weapon;
global is_inline_chip;
global weapon_effects;          // 9+
global chip_effects;
global mp;                      // 10+
global ap; // *ACTION* points
global leek_cell;               // 11+
global level;                   // 13+
global is_ally;                 // 14+
global is_hostile;
global alive_allies;
global allies;                  // 16+
global hostiles;
global alive_hostiles;
global dead_hostiles;

global flee_cell;               // 19+

global cell_contents;           // 21+

global cell_shooting_cells_2;   // 31+

global path_length;             // 37+
global path_length_ignore;

global chip_victims;            // 39+

global weapons;                 // 57+
global chips;

global absolute_shield_0;
global absolute_shield_1;
global effects_0;
global effects_1;
global entity_turn_order_0;
global entity_turn_order_1;
global relative_shield_0;
global relative_shield_1;
global can_shoot_1;
global can_shoot_2;
global can_shoot_cell_1;
global can_shoot_cell_2;
global weapon_effective_area_1;
global weapon_effective_area_2;
global weapon_effective_area_3;
global can_chip_2;
global can_chip_cell_2;
global chip_effective_area_2;
global chip_effective_area_3;
global cooldown_1;
global cooldown_2;
global obstacles;
global path_2;
global path_3;
global cell_free_1;
global cell_leek_1;
global cell_wall_1;
global cell_casting_cell_2;
global cell_casting_cell_3;
global cell_casting_cells_2;
global cell_casting_cells_3;
global leek_casting_cells_2;
global leek_casting_cells_3;
global cell_shooting_cell_1;
global cell_shooting_cell_2;
global cell_shooting_cell_3;
global cell_shooting_cells_1;
global cell_shooting_cells_3;
global leek_shooting_cells_1;
global leek_shooting_cells_2;
global leek_shooting_cells_3;
global next_player_0;
global previous_player_0;
global weapon_victims_1;
global weapon_victims_2;
global flee_cells_1;
global flee_cells_2;
global flee_leeks_1;
global flee_leeks_2;
global flee_line_2;
global flee_line_3;
global rush_cells_1;
global rush_cells_2;
global rush_leeks_1;
global rush_leeks_2;
global rush_line_2;
global rush_line_3;
global delete_register_1;
global register_1;
global register_2;
global registers_0;
global author_1;
global message_params_1;
global message_type_1;
global messages_0;
global messages_1;
global send_team_1;
global send_2;

// Turn-obsolete cache.
global _hostiles = null;
global _allies = null;
global turn = -1;

_hostiles = null;
_allies = null;
turn++;

// Lasting cache.
global self;

// Substitute API.
function mind_meld ()
{
	weapon = getWeapon;
	shoot_cell = useWeaponOnCell;
	cast_cell = useChipOnCell;
	frequency = getFrequency;
	is_inline_weapon = isInlineWeapon;
	is_inline_chip = isInlineChip;
	weapon_effects = getWeaponEffects;
	chip_effects = getChipEffects;
	mp = getMP;
	ap = getTP;
	leek_cell = getLeekOnCell;
	level = getLevel;
	is_ally = isAlly;
	is_hostile = isEnemy;
	alive_allies = getAliveAllies;
	allies = getAllies;
	hostiles = getEnemies;
	alive_hostiles = getAliveEnemies;
	dead_hostiles = getDeadEnemies;
	
	flee_cell = moveAwayFromCell;
	
	cell_contents = getCellContent;
	
	cell_shooting_cells_2 = getCellsToUseWeaponOnCell;
	
	path_length = getPathLength;
	path_length_ignore = getPathLength;
	
	chip_victims = getChipTargets;
	
	weapons = getWeapons;
	chips = getChips;
	
	var lvl = level(self);
	warning("Melding with level "+lvl+".");
	
	if (lvl < 7) {
		weapon = function (l) {
			info("weapon: Assuming pistol.");
			return WEAPON_PISTOL;
		};
		
		shoot_cell = function (c) {
			info ("shoot_cell: Shooting leek on cell.");
			return shoot(leek_cell(c));
		};
		
		cast_cell = function (s,c) {
			info ("cast_cell: Casting on leek on cell.");
			return cast(leek_cell(c));
		};
	}
	
	if (lvl < 8) {
		frequency = function (l) {
			info ("frequency: Assuming 100.");
			return 100;
		};
		
		var _inline_weapons = [
			WEAPON_MACHINE_GUN,
			WEAPON_SHOTGUN,
			WEAPON_LASER,
			WEAPON_FLAME_THROWER,
			WEAPON_GAZOR,
			WEAPON_B_LASER,
			WEAPON_M_LASER
		];
		is_inline_weapon = function (w) {
			if (in_array(_inline_weapons,w)) {
				info ("is_inline_weapon: Yes.");
				return true;
			} else {
				info ("is_inline_weapon: No.");
				return false;
			}
		};
		
		var _inline_chips = [
			CHIP_FLASH,
			CHIP_LIGHTNING,
			CHIP_ICEBERG,
			CHIP_INVERSION
		];
		is_inline_chip = function (s) {
			if (in_array(_inline_chips,s)) {
				info ("is_inline_chip: Yes.");
				return true;
			} else {
				info ("is_inline_chip: No.");
				return false;
			}
		};
	}
	
	if (lvl < 9) {
		weapon_effects = function (w) {
			error ("weapon_effects: NOT IMPLEMENTED.");
		};
		
		chip_effects = function (s) {
			error ("chip_effects: NOT IMPLEMENTED.");
		};
	}
	
	if (lvl < 10) {
		mp = function(leek) {
			//TODO: Measure actual movement between each turn.
			info ("mp: Assuming 3.");
			return 3;
		};
		
		ap = function(leek) {
			info ("ap: Assuming 10.");
			return 10;
		};
	}
	
	if (lvl < 11) {
		leek_cell = function (c) {
			if (cell(self) === c) {
				info ("leek_cell: Found self.");
				return self;
			}
			
			var hl = hostiles();
			for (var h in hl)
				if (cell(h) === c) {
					info ("leek_cell: Found bad guy ("+name(h)+").");
					return h;
				}
			
			var al = allies();
			for (var a in al)
				if (cell(a) === c) {
					info ("leek_cell: Found mate ("+name(a)+").");
					return a;
				}
			
			info ("leek_cell: Nobody here.");
			return -1;
		};
	}
	
	if (lvl < 13) {
		var _weapon_levels = [];
		_weapon_levels[WEAPON_PISTOL          ] =   1;
		_weapon_levels[WEAPON_MACHINE_GUN     ] =   5;
		_weapon_levels[WEAPON_DOUBLE_GUN      ] =   9;
		_weapon_levels[WEAPON_SHOTGUN         ] =  17;
		_weapon_levels[WEAPON_MAGNUM          ] =  27;
		_weapon_levels[WEAPON_BROADSWORD      ] =  30;
		_weapon_levels[WEAPON_LASER           ] =  40;
		_weapon_levels[WEAPON_AXE             ] =  49;
		_weapon_levels[WEAPON_GRENADE_LAUNCHER] =  55;
		_weapon_levels[WEAPON_FLAME_THROWER   ] =  90;
		_weapon_levels[WEAPON_DESTROYER       ] = 109;
		_weapon_levels[WEAPON_GAZOR           ] = 135;
		_weapon_levels[WEAPON_B_LASER         ] = 170;
		_weapon_levels[WEAPON_KATANA          ] = 211;
		_weapon_levels[WEAPON_ELECTRISOR      ] = 257;
		_weapon_levels[WEAPON_M_LASER         ] = 300;
		
		level = function (l) {
			if (l === self) return getLevel();
			
			var r = _weapon_levels[weapon(l)];
			info ("level: Guessing "+r+" from current weapon.");
			return (r !== null)?r:0;
		};
	}
	
	if (lvl < 14) {
		is_ally = function (l) {
			return false;
		};
		
		is_hostile = function (l) {
			return true;
			
		};
		alive_allies = function () {
			return [];
		};
	}
	
	if (lvl < 16)
	{
		allies =  function () {
			if (_allies === null)
			{
				var a = [];
				for (var c = 0 ; c < 613 ; c++)
					push(a,nearest_ally_cell(c));
				a = remove_dupes(a);
				info ("allies: "+string(a)+".");
				_allies = a;
			}
			
			return _allies;
		};
		
		hostiles = function () {
			if (_hostiles === null)
			{
				var h = [];
				for (var c = 0 ; c < 613 ; c++)
					push(h,nearest_hostile_cell(c));
				h = remove_dupes(h);
				info ("hostiles: "+string(h)+".");
				_hostiles = h;
			}
			
			return _hostiles;
		};
		
		alive_hostiles = function () { return []; }; //TODO
		dead_hostiles = function () { return []; }; //TODO
		
		/* hostiles_count_0 = function () {
			var t = count(hostiles_0());
			info ("hostiles_count : Done (total "+t+").");
			return t;
		};*/
	}
	
	if (lvl < 19)
	{
		flee_cell = function (c,d) {
			info ("flee_cell: Fleeing from closest enemy to cell.");
			moveAwayFrom(nearest_hostile_cell(c),d);
		};
	}
	
	if (lvl < 21)
	{
		cell_contents = function (c) {
			var x = cell_x(c), y = cell_y(c);
			var nx = [x+1,x-1,x  ,x  ];
			var ny = [y  ,y  ,y+1,y-1];
			
			if (c === cell(self) || in_array(hostiles(),leek_cell(c)))
			{
				info ("cell_contents: Leek (someone is here).");
				return CELL_PLAYER;
			}
			
			for (var i = 0 ; i < 4 ; i++)
			{
				if (in_map(nx[i],ny[i]) && los(xy2cell(x,y),xy2cell(nx[i],ny[i])))
				{
					info ("cell_contents: Empty (path is clear from "+xy2cell(nx[i],ny[i])+" to "+c+").");
					return CELL_EMPTY;
				}
			}
			info ("cell_contents: Obstacle (path is obstructed around "+c+").");
			return CELL_OBSTACLE;
		};
	}
	
	if (lvl < 31)
	{
		cell_shooting_cells_2 = function (w,c) {
			error ("cell_shooting_cells: NOT IMPLEMENTED.");
		};
	}
	
	if (lvl < 37)
	{
		path_length = function (c1,c2) {
			error ("path_length: NOT IMPLEMENTED.");
		};
		
		path_length_ignore = function (c1,c2,ic) {
			error ("path_length_ignore: NOT IMPLEMENTED.");
		};
	}
	
	if (lvl < 39)
	{
		chip_victims = function (s,c) {
			error("chip_victims: NOT IMPLEMENTED.");
			return [self];
		};
	}
	
	if (lvl < 57)
	{
		//TODO: Improve with Hive Mind memory.
		weapons = function (l) {
			//FIXME
			if (l === self) return getWeapons();
			info ("weapons : Listing current weapon.");
			return [weapon(l)];
		};
		
		chips = function (l) {
			//FIXME
			if (l === self) return getChips();
			info ("weapons : Listing no chips.");
			return [];
		};
	}
}

function rtd (n) { return rand_int(0,n) === 0; }

function pick (t) { return t[rand_int(0,count(t))]; }

function in_map (x,y) { return abs(x) + abs(y) < 18; }

//NOTE: Could be improved to n*log(n).
function remove_dupes (@a)
{
	var na = [];
	for (var i = 0 ; i < count(na) ; i++)
		if (!in_array(na,a[i]))
			push(na,a[i]);
	
	return na;
}

function deepen_knowledge ()
{
}
