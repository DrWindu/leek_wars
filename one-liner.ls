var foo = (getWeapon() != WEAPON_PISTOL)?
	setWeapon(WEAPON_PISTOL):
	(moveToward(getNearestEnemy()) < 4)?
		useWeapon(getNearestEnemy()):
		"???";