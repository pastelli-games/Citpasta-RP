// TODO: ZCOPY / ZMIMIC @Zandario

SUBSYSTEM_DEF(openspace)
	name = "Open Space"
	runlevels = RUNLEVEL_GAME | RUNLEVEL_LOBBY | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_OPENSPACE
	wait = 10

	var/static/list/turfs_to_process = list()		// List of turfs queued for update.

/datum/controller/subsystem/openspace/Initialize()
	initialize_open_space()
	return ..()

/datum/controller/subsystem/openspace/fire(resumed)
	var/i = 0
	for(i in 1 to length(turfs_to_process))
		var/turf/T = turfs_to_process[i]
		update_turf(T)
		if(MC_TICK_CHECK)
			break
	if(!i)
		return
	turfs_to_process.Cut(1, i)

/datum/controller/subsystem/openspace/proc/update_turf(var/turf/T)
	for(var/atom/movable/A in T)
		A.fall()
	T.update_icon()

/datum/controller/subsystem/openspace/proc/add_turf(var/turf/T, var/recursive = 0)
	ASSERT(isturf(T))
	turfs_to_process += T
	if(recursive > 0)
		var/turf/above = GetAbove(T)
		if(above && isopenturf(above))
			add_turf(above, recursive)

// Do the initial updates of open space turfs when the game starts. This will lag!
/datum/controller/subsystem/openspace/proc/initialize_open_space()
	set waitfor = FALSE
	// Do initial setup from bottom to top.
	for(var/zlevel = 1 to world.maxz)
		for(var/turf/simulated/open/T in block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel)))
			update_turf(T)
			T.smoothing_flags &= ~SMOOTH_QUEUED
	turfs_to_process.Cut()
