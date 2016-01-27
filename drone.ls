// Hear the Hive.
include("cerebrate");

// Get ready...
if (weapon() !== WEAPON_PISTOL)
{
	grab(WEAPON_PISTOL);
	say(one_liner());
}

// Charge !
var target = nearest_hostile();
rush(target,3);

// KILL !
while (shoot(target) === USE_SUCCESS);