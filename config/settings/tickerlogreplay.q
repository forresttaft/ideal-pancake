// default configuration for the tickerplant replay

\d .replay

// Variables
firstmessage:0		// the first message to execute
lastmessage:0W		// the last message to replay
messagechunks:0W	// the number of messages to replay at once
schemafile:`$getenv[`KDBCODE],"/tick/tick/database.q"   	// the schema file to load data in to
tablelist:enlist `all	// the tables to replay into (to allow subsets of tp logs to be replayed).  `all means all
hdbdir:`$getenv[`KDBHOME],"/hdb/database"		// the hdb directory to write to
tplogfile:`		// the tp log file to replay.  Only this or tplogdir should be used (not both)
tplogdir:`		// the tp log directory to read the log files from.  Only this or tplogfile should be used (not both)
partitiontype:`date	// the partitioning of the database.  Can be date, month or year (int would have to be handled bespokely)
emptytables:1b		// whether to overwrite any tables at start up
sortafterreplay:1b	// whether to re-sort the data at the end of the replay.  Sort order is determined by the result of sortandpart[`tablename]
partafterreplay:1b	// whether to apply the parted attribute after the replay.  Parted column is determined by result of first sortandpart[`tablename]
basicmode:0b		// do a basic replay, which replays everything in, then saves it down with .Q.hdpf[`::;d;p;`sym]
exitwhencomplete:1b	// exit when the replay is complete
gc:1b			// garbage collect at appropriate points (after each table save and after the full log replay)

.replay.postreplay:{[d;p]
	.lg.o[`postreplay;"Calling the postreplay function"];
	/ - get the sym file and set it globally
	symfile: @[get;` sv (d:hsym d),`sym;{[e] .lg.e[`postreplay;"Couldn't pull the sym file from disk. Error returned : ",e;'e]}];
	.lg.o[`postreplay;"Setting activeDates for date: ",strd:string p];
	/ - get a distinct list of the marketids (sym) from the quote table
	marketids: exec sym from distinct select value sym from .Q.par[d;p;`quote];
	/ - save down the marketids to activeDates table
	.[` sv d,`activeDates;();,; ([date: enlist p] marketids: enlist marketids)];
	.lg.o[`postreplay;"Removing duplicate metadata rows for date: ",strd];
        / - select the first row by sym and selectionId
        mdata:delete date from select from (mdDir:.Q.par[d;p;`metadata]) where i=(first;i) fby ([] sym;selectionId);
        / - save the meta data to disk
        (` sv mdDir,`) set mdata;
        .lg.o[`postreplay;"Post replay complete"]}

// turn off some of the standard stuff 
\d .proc
loadhandlers:0b
logroll:0b
