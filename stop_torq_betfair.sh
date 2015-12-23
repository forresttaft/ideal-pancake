# load env script
. ./setenv.sh

#kill all torq procs
echo 'Shutting down Torq...'
q torq.q -load code/processes/kill.q -proctype kill -procname kill1 -.servers.CONNECTIONS feed rdb tickerplant hdb gateway housekeeping monitor discovery wdb sort reporter compression requestor </dev/null >$KDBLOG/torqkill.txt 2>&1 &
