// Hear the Hive.
include("cerebrate");

/* Prerequisites list :
Weapons : pistol
Chips :
*/

// Get ready...
global init = false;
if (turn === 0)
{
	hive_mind();
	
	grab(WEAPON_PISTOL);
	say(one_liner());
}

turn++;

// Pick target.
var target = nearest_hostile();
var dist = cell_distance(cell(self),cell(target));

// Kiting.
var sweet_spot = mp(target) + weapon_max_range(weapon(target)) + 1;

if (dist >= sweet_spot && turn < 60)
	rush(target, dist-sweet_spot);
else
	rush(target,mp(self));

// KILL !
while (shoot(target) === USE_SUCCESS);