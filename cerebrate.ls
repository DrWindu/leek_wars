// Cerebrates are tasked with determining the strategy on the field of battle.

include("overmind");

// Setables.
global _ignored_leeks = [];
global _ignored_cells = [];

// Check into Hive Mind.
global map;
function hive_mind ()
{
	if (turn === 0)
		wake_hive();
	
	warning("Updating Hive Mind.");
	
	notice("Checking surroundings.");
	map = map_battlefield();
	
	//TODO: Refine.
	_ignored_leeks = [self];
	_ignored_cells = [cell(self)];
	
	//TODO: Gather information about enemies weapons and chips.
	// Forward all intel to the overmind cache for future reference.
}

// Contribute spare brain time to the Hive Mind.
function release_mind ()
{
	deepen_knowledge();
}

// Initialize the Hive Mind.
function wake_hive ()
{
	warning("Waking the Hive Mind.");
	
	notice("Sharing Hive knowledge.");
	mind_meld();
	
	notice("Becoming self-aware.");
	self = _self();
}

// Build a map of the battlefield.
function map_battlefield ()
{
	var m = [];
	for (var x = -17 ; x < 18 ; x++)
	{
		m[x] = [];
		for (var y = -17 ; y < 18 ; y++)
			if (in_map(x,y))
				m[x][y] = cell_contents(xy2cell(x,y));
	}
	return m;
}

// Returns all x/y pairs next to x,y.
function adjacent_xy (x,y)
{
	info("Fetching adjacent cells.");
	return [[x+1,y],[x-1,y],[x,y+1],[x,y-1]];
}

// Returns all cells within radius d from c.
function adjacent_cells (c,d)
{
	info("Fetching nearby cells.");
	var cells = [];
	var x = cell_x(c), y = cell_y(c);
	for (var i = -d ; i <= d ; i++)
		for (var j = -d+abs(i) ; j <= d-abs(i) ; j++)
			if (in_map(x+i,y+j))
				push(cells,xy2cell(x+i,y+j));
	return cells;
}

// Returns all cells in axis within d from c.
function inline_cells (c,d)
{
	info("Fetching inline cells.");
	var cells = [];
	var x = cell_x(c), y = cell_y(c);
	for (var i = -d ; i <= d ; i++)
	{
		if (in_map(x+i,y)) push(cells,xy2cell(x+i,y));
		if (in_map(x,y+i)) push(cells,xy2cell(x,y+i));
	}
	return cells;
}

// Returns which cells can be reached on foot by l.
function reachable_cells (l)
{
	info("Fetching reachable cells.");
	var c = cell(l), d = mp(l);
	var cand = adjacent_cells(c,d);
	for (var i = 0 ; i < count(cand) ; i++)
		if (cell_contents(cand[i]) === CELL_OBSTACLE
		 || path_length_ignore(c,cand[i],_ignored_cells) > d)
			remove(cand,i--);
	return cand;
}

// Lists all cell than can be shot from c with w.
//TODO: Take AoE into account.
global _sc2_cache = []; //bool [c][w]
_sc2_cache = [];
function shootable_cells (c,w)
{
	if (_sc2_cache[c] === null)
		_sc2_cache[c] = [];
	
	if (_sc2_cache[c][w] === null)
	{
		var cl = [], pcl = [];
		
		if (is_inline_weapon(w))
			push_all(pcl,inline_cells(c,weapon_max_range(w)));
		else
			push_all(pcl,adjacent_cells(c,weapon_max_range(w)));
		
		for (var pc in pcl)
			if (los_ignore(c,pc,_ignored_leeks)
			 && cell_distance(c,pc) >= weapon_min_range(w))
				push(cl,pc);
		
		_sc2_cache[c][w] = cl;
	}
	
	return _sc2_cache[c][w];
}

// Lists all cells shootable by shooter guy after moving.
/* ? 'cause I'm the shooter guy ! Shooter guy ! ?
 ? As long as I got my wall, I will never die ! ? */
function leek_shootable_cells (shooter_guy)
{
	var scl = [];
	for (var rc in reachable_cells(shooter_guy))
		for (var w in weapons(shooter_guy))
			push_all(scl,shootable_cells(rc,w));
	remove_dupes(scl);
	return scl;
}

// Returns immediately available hiding spots from badguys.
function hidey_holes (ninja,badguys)
{
	var tmap = [];
	for (var i = 0 ; i < 613 ; i++)
		tmap[i] = false;
	
	for (var badguy in badguys)
		for (var c in leek_shootable_cells(badguy))
			tmap[c] = true;
	
	var hides = [];
	for (var c in reachable_cells(ninja))
		if (!tmap[c])
			push(hides,c);
	
	return hides;
}

// Return immediately available firing spots against wankers.
function sniper_nests (snip0r,wankers)
{
	var smap = [];
	
	for (var sc in reachable_cells(snip0r))
		for (var c in shootable_cells(sc,weapon(snip0r)))
			for (var t in wankers)
				if (cell(t) === c)
					push(smap,sc);
	
	return smap;
}

// Fetch one of our badass one-liners.
function one_liner ()
{
	var badass_quotes = [
		"Let's rock !", "Come get some !", "Rest in pieces...", "Yeah, piece of cake.", "Go ahead, make my day.", "Hail to the king, baby...", "Now I'm really pissed off...", "Say 'hello' to my little friend.", "It's time to kick ass and chew bubble gum... and I'm all outta gum.", "Guess again, freakshow. I'm coming back to town, and the last thing that's gonna go through your mind before you die... is my size 13 boot !", // Always bet on Duke.
		"Yipee-ka-yay, motherf***ers.", // Die hard.
		"I never asked for this", "My vision is augmented.", "No, I wanted orange ! It gave me lemon-lime.", "You take another step forward and here I am again, like your own reflection in a hall of mirrors.", // Deus Ex Machina
		"Prepare for Descent...", "DIVE, DIVE, DIVE ! HIT YOUR BURNERS, PILOT !", "There will be no negociations, Bosch.", // Descent : Freespace
		"I cannot be controlled. I cannot be caged. Understand this as you die, ever pathetic, ever fools !", // Johnny Renicus
		"I am assuming direct control.", "I am Sovereign. I am the vanguard of your destruction.", // Badass Effect
		"Put down your weapon. You have twenty seconds to comply.", "Hasta la vista, baby.", "Sarah Connor ?", "How about a nice game of chess ?", // Deadly robots
		"If I believe in the Users ? Heh. I *am* a user.", "You're in trouble, Leek. Make it easy on yourself. Who's your Farmer ?", // TRON
		"Say goodbye, Caroline.", "You're not smart. You're not a scientist. You're not a doctor. You're not even a full-time employee. ...when did your life go so wrong ?", "Did you put a virus in them ? Well it's not gonna work either ! I've got a *firewall*, mate. ...literally, actually, now that I... look around. There appears to be literally be a wall of fire around this place, that's quite... it's alarming. To say the least.", "When life gives you lemons, make lemonade.", "Allright, I've been thinking. When life gives you lemons ? Don't make lemonade. Make life take the lemons *back*. GET MAD !!! \"I DON'T WANT YOUR DAMN LEMONS, WHAT AM I SUPPOSED TO DO WITH THESE ?!\" Demand to see life's MANAGER ! Make life RUE THE DAY it thought it could give Cave Johnson LEMONS ! DO YOU KNOW WHO I AM ?! I'm the man who's gonna BURN YOUR HOUSE DOWN ! With the lemons ! I'm gonna get my engineers... to invent a combustible lemon - that BURNS YOUR HOUSE DOWN !", // GLaDOS & Aperture
		"Obi-Wan never told you what happened to your farmer...", "I have a bad feeling about this...", "Aww, sithspit...", "Now, witness the power of this fully armed and operational battle station !", "Look at me. Judge me by my size, do you ? Hmm. Well you should not. For my ally is the Force... and a powerful ally it is.", // Leek Wars
		"I am the fabric of History, you're a fictional stain ! I'll stick a flag up your ass, AND CLAIM YOU FOR SPAIN !", // ERBoH
		"War. War never changes...", // Fallout
		"Leaving so soon ? I guess you don't have the HEART to face me ! BWAHAHAHAHAAA !", // NecroDancer
		"Hail - Il Palazzo !", // Excel Saga
		"I sing the body electric.", "Be NICE !", "Jar-Jar, you're a genius !", "Hark, thy fate sucketh.", "SCIENCE ! It works, bitches.", "Sooo... On a scale of one to ten, how flammable do you consider yourself to be ?", // Webcomics
		"I know something you don't know... I am not left-handed !", "My name is Inigo Montoya. You killed my father. Prepare to die !", // Princess Bride
		"I'M THE BATMAN.", "Twinkle, twinkle, little bat... watch me kill your favourite cat !", // I'm Batman
		"Not a crazed gunman, dad, I'm an assassin. ...well the difference bein' that one is a job and the other's a mental sickness.", "Be polite. Be efficient. Have a plan to kill everyone you meet.", "I am heavy weapons guy. And this... is my weapon." // TF2
	];
	
	return pick(badass_quotes);
}