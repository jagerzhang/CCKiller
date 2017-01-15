#!/bin/bash
# chkconfig: 35 10 90 
# description: CCKiller Service
EXEC_PATH=/usr/local/cckiller
EXEC=cckiller
DAEMON=$EXEC_PATH/$EXEC
PID_FILE=/var/run/$EXEC.pid  

test -f /etc/rc.d/init.d/functions && . /etc/rc.d/init.d/functions

if [ ! -f $DAEMON ] ; then  
       echo "ERROR: $DAEMON not found"  
       exit 1  
else
        chmod +x $DAEMON
fi

stop()  
{  
       echo -n "Shutting down $EXEC ..."  
       ps aux | grep "$DAEMON" | grep -v grep | kill -9 `awk '{print $2}'` >/dev/null 2>&1  
       rm -f $PID_FILE
       sleep 0.5  
       echo -e "                 [ \033[36mOK\033[0m ]"   
}

start()  
{  

	if [[ -f  $PID_FILE ]]
	then
        	echo "CCKiller is Already Running in Backend !"
        	exit 1
	fi

    echo -n "Starting $EXEC ..."  
    $DAEMON --process > /dev/null &  
    #pidof $EXEC > $PID_FILE
    PID=$(ps aux | grep "$DAEMON" | grep -v grep | awk '{print $2}')
    if [[ ! -z $PID ]]
    then
        sleep 0.5
        echo  $PID > $PID_FILE
        echo -e "                      [ \033[36mOK\033[0m ]"
    else
        echo "                      [ \033[31mFailed\033[0m ]"
	fi
}

restart()  
{  
    stop
    echo
    start
}  
echo
case "$1" in  
    start)
        start
        ;;  
    stop)  
        stop  
        ;;  
    restart)  
        restart  
        ;;  
    status)  
        $DAEMON --show
        status -p $PID_FILE $DAEMON
        ;; 
    *)  
        echo "Usage: service $EXEC {start|stop|restart|status}"  
        exit 1  
esac
echo
exit $?
