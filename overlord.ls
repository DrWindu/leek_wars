// Overlords coordinate the actions and tactics of individual creatures.

include("cerebrate");

global threats;
global targets;

function contact_hive ()
{
	hive_mind();
	
	threats = alive_hostiles();
	for (var i = 0 ; i < count(threats) ; i++)
	{
		var h = threats[i];
		if (type(h) === ENTITY_BULB || level(h) < 30)
			remove (threats,i--);
		else
			notice ("Threat : "+name(h));
	}
	
	targets = alive_hostiles();
	for (var i = 0 ; i < count(targets) ; i++)
	{
		var t = targets[i];
		if (type(t) === ENTITY_BULB)
			remove (targets,i--);
		else
			notice ("Target : "+name(t));
	}
}

//TODO
function best_next_steps (x,y)
{
	var t = [[x+1,y],[x-1,y],[x,y+1],[x,y-1]];
	shuffle(t);
	return t;
}

/*
EVERYONE STATUS REPORT !
- Zerg | Brood 
- playing ?
- life / maxlife
- abilities (dps,tank,buff,heal)
- distance to hostiles and friends

Goals :
- Friends should be ~5 cells apart
- One enemy should be ~7 cells away
- Other enemies should be further away
- Front-line zergs should be buffed
- Broods should be in front to provide cover

The overlord will influence greedy searches :
- Hurt and support leeks will try to move away from the enemy.
- Assault leeks will try to move towards the enemy.
- Packed friends will try to move away from each other.
- Faraway friends will try to move towards one another.

Trying to move towards (resp. away) means having more will to reduce (resp. increase) the x and y gaps.
All Zerg pathfinding functions consider their moves by order of willingness.
Zerg that don't need to be somewhere will freely roam by order of willingness.

The overlord also informs its minions of who (if any) needs healing and buffing.
*/