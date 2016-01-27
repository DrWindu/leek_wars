/* Roach AI (levels 50+)
? Blah blah blah. They hide and they heal. And it sucks. ?

The roach tries to stay behind cover, and harass enemies. They stay fortified
and healed up at all times. As a last resort, they go all-in and try to pour
as much DPS as possible.

*/

/* At each turn :
- Evaluate your own life, weapon and spell DPS.
- Evaluate enemies armors and life.
- Evaluate cooldowns.
- If enemy shields exceed spell DPS : [NOSPELL].
- If enemy shields exceed weapon DPS : [NOWEAP]. (!)
- If life < maxlife-100 : [HURT].
- If elife < emaxlife/2 && ![HURT] : [WINNING].
- If elife < exDPS : [WINNING]. */

//TODO: Armor ?

include ("overlord");

contact_hive();

global covers;
global spots;

//FIXME
function check_melee()
{
	if (in_array(weapons(self),WEAPON_AXE))
		return WEAPON_AXE;
	return WEAPON_SHOTGUN;
}

function try_cast(s,t)
{
	if (in_array(chips(self),s))
		return cast(s,t);
	return USE_FAILED;
}

global melee_weapon = check_melee();
global cylen = in_array(chips(self),CHIP_ARMOR)?7:5;

if (turn === 0)
{
	say(one_liner());
	grab (WEAPON_LASER);
}

//TODO: If stuck in a losing melee, do the back/bulb/cover trick.
//TODO: Dis iz no bulb trick...
function bulb_trick ()
{
	var t = nearest_hostile();
	shoot(t);
	
	if (life() < 100 && weapon(t) === melee_weapon)
		cast(CHIP_CURE,self);
	
	buff_up();
	cast(CHIP_HELMET,self);
}

var mindist = function() {
	return cell_distance(cell(self),cell(nearest_hostile()));
};

if (mindist() > 15)
	rush(nearest_hostile(),mp(self));
else if (mindist() === 1)
{
	warning ("Hard-coded axe murderer subroutine.");
	if (weapon(self) !== melee_weapon)
		grab (melee_weapon);
	
	if (!agro())
	{
		bulb_trick();
		return; // goto fail;
	}
} else if (mindist() > 4 && weapon(self) === melee_weapon)
	grab (WEAPON_LASER);

covers = hidey_holes(self,threats);
spots = sniper_nests(self,targets);

mark (spots,purple);
mark (covers,teal);

combat_mode();

if (mindist() === 1)
	grab (melee_weapon);

error(ops());

global _hit_mp = 0;
function hit_and_run_rec (x,y,m,path,hit)
{
	var c = xy2cell(x,y);
	if (!hit && in_array(spots,c))
	{
		hit = true;
		_hit_mp = m;
	}
	path[count(path)] = c;
	
	if (hit && in_array(covers,c))
		return path;
	
	if (m === 0)
		return [];
	
	var npath = [];
	for (var xy in best_next_steps(x,y))
	{
		npath = hit_and_run_rec(xy[0],xy[1],m-1,path,hit);
		if (npath !== [])
			break;
	}
	
	return npath;
}

function hit_and_run ()
{
	var x = cell_x(cell(self)), y = cell_y(cell(self)), m = mp(self);
	return hit_and_run_rec(x,y,m,[],false);
}

function seek_and_destroy ()
{
	notice ("Sarah Connor ?");
	for (var t in targets)
	{
		notice ("PEW PEW !");
		try_cast(CHIP_STALACTITE,t);
		shoot(t);
	}
}

//TODO: Look for most vulnerable target.
function spam ()
{
	shoot (nearest_hostile()); // Just in case.
	while (try_cast(CHIP_SPARK,nearest_hostile()) === USE_SUCCESS);
}

function cower ()
{
	spam();
	notice ("Everyone bunker down !");
	var dest = pick(covers);
	if (dest === null)
		flee(nearest_hostile(),mp(self));
	else
		rush_cell(dest,mp(self));
}

function good_drip (c)
{
	info ("Checking IV...");
	if (c === null || cell_contents(c) === CELL_OBSTACLE)
		return false;
	
	var vl = chip_victims(CHIP_DRIP,c);
	for (var h in hostiles())
		if (in_array(vl,h))
			return false;
	
	return true;
}

function drip_up () {
	notice ("Trying IV.");
	var c = cell(self);
	var x = cell_x(c), y = cell_y(c);
	
	var aoe;
	
	aoe = xy2cell(x+2,y);
	if (good_drip(aoe)) useChipOnCell(CHIP_DRIP,aoe);
	
	aoe = xy2cell(x-2,y);
	if (good_drip(aoe)) useChipOnCell(CHIP_DRIP,aoe);
	
	aoe = xy2cell(x,y+2);
	if (good_drip(aoe)) useChipOnCell(CHIP_DRIP,aoe);
	
	aoe = xy2cell(x,y-2);
	if (good_drip(aoe)) useChipOnCell(CHIP_DRIP,aoe);
}

function buff_up ()
{
	notice ("Buffing self up (cycle : "+turn%cylen+").");
	if (turn % cylen === 0)
		try_cast(CHIP_SHIELD,self);
	else if (turn % cylen === 3)
	{
		try_cast(CHIP_ARMOR,self);
		try_cast(CHIP_HELMET,self);
	}
	
	if (life(self) + 120 < max_life(self))
		try_cast(CHIP_CURE,self);
		
	try_cast(CHIP_VACCINE,self);
	
	if (life(self) + 50 < max_life(self))
		try_cast(CHIP_BANDAGE,self);
	
	try_cast(CHIP_PROTEIN,self);
	
	if (life(self) + 60 < max_life(self) && in_array(chips(self),CHIP_DRIP))
		drip_up();
}

//TODO: Improve.
function agro ()
{
	return life(self) > max_life(self)/2;
}

//TODO: Ugh...
function license_to_kill (t)
{
	return agro() && (turn%cylen !== 3);
}

function combat_mode ()
{
	notice ("Entering fighting stance.");
	var snipes_run = hit_and_run();
	
	if (covers !== []) {
		notice ("Found cover.");
		if (snipes_run !== []) {
			notice ("Found Snipes run : "+snipes_run);
			for (var c in snipes_run) {
				rush_cell(c);
				if (mp(self) === _hit_mp)
					seek_and_destroy();
			}
			buff_up();
			spam();
		} else if (spots !== []) {
			notice ("Run ("+covers+") or shoot ("+spots+") ?");
			var done = false;
			for (var sc in spots)
			{
				for (var c in shootable_cells(sc,weapon(self)))
				{
					for (var t in targets)
					{
						if (cell(t) === c && license_to_kill(t))
						{
							rush_cell(sc);
							seek_and_destroy();
							done = true;
							break;
						}
						if (done) break;
					}
					if (done) break;
				}
				if (done) break;
			}
			buff_up();
			cower();
		} else {
			notice ("Nothing to do here.");
			buff_up();
			cower();
		}
	} else {
		notice ("Nowhere to run.");
		if (spots !== []) {
			for (var sc in spots)
				for (var c in shootable_cells(sc,weapon(self)))
					for (var t in targets)
						if (cell(t) === c && license_to_kill(t))
						{
							notice ("Attack attack attack !");
							rush_cell(sc);
							seek_and_destroy();
						}
			notice ("Bubblin' down.");
			buff_up();
			cower();
		} else {
			notice ("Nothing to do here.");
			buff_up();
			cower();
		}
	}
}

/* Support mode :
	ohai
	i can haz hurt || bare friend?
	within buff range, o rly ?
	-ya rly:
		wile hurt friend: heal
		wile bare briend: buff
		give hugz
	-no wai:
		find path to friend
		im in ur path to friend:
			shootable bad guy, o rly ? shoot his face !
		burnable bad guy, o rly ? burn his face !
	kthxbai
*/