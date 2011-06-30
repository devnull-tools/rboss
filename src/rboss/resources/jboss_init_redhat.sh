#!/bin/sh
#
# $Id: jboss_init_redhat.sh 99350 2010-01-13 17:05:27Z bshim $
#
# chkconfig: 345 90 10
# description: Initializes service jboss
#
# JBoss Control Script
#
# To use this script run it as root - it will switch to the specified user
#
# Here is a little (and extremely primitive) startup/shutdown script
# for RedHat systems. It assumes that JBoss lives in /usr/local/jboss,
# it's run by user 'jboss' and JDK binaries are in /usr/local/jdk/bin.
# All this can be changed in the script itself. 
#
# Either modify this script for your requirements or just ensure that
# the following variables are set correctly before calling the script.
JBOSS_ADMIN_USER="[JMX_USER]"
JBOSS_ADMIN_PWD="[JMX_PASSWORD]"
#1099
JBOSS_JNP_PORT="[JNP_PORT]"

#define where jboss is - this is the directory containing directories log, bin, conf etc
#/opt/jboss
JBOSS_HOME=${JBOSS_HOME:-"[JBOSS_HOME]"}

#define the user under which jboss will run, or use 'RUNASIS' to run as the current user
JBOSS_USER=${JBOSS_USER:-"[JBOSS_USER]"}

#make sure java is in your path
#/usr/java/default
JAVAPTH=${JAVAPTH:-"[JAVA_PATH]"}

#configuration to use, usually one of 'minimal', 'default', 'all', 'production'
JBOSS_CONF=${JBOSS_CONF:-"[CONFIGURATION]"}

#if JBOSS_HOST specified, use -b to bind jboss services to that address
JBOSS_BIND_ADDR=${JBOSS_HOST:-"[BIND_ADDRESS]"}

#define the script to use to start jboss
JBOSSSH=${JBOSSSH:-"$JBOSS_HOME/bin/run.sh -c $JBOSS_CONF -b $JBOSS_BIND_ADDR"}

if [ "$JBOSS_USER" = "RUNASIS" ]; then
  SUBIT=""
else
  SUBIT="su - $JBOSS_USER -c "
fi

if [ -n "$JBOSS_CONSOLE" -a ! -d "$JBOSS_CONSOLE" ]; then
  # ensure the file exists
  touch $JBOSS_CONSOLE
  if [ ! -z "$SUBIT" ]; then
    chown $JBOSS_USER $JBOSS_CONSOLE
  fi 
fi

if [ -n "$JBOSS_CONSOLE" -a ! -f "$JBOSS_CONSOLE" ]; then
  echo "WARNING: location for saving console log invalid: $JBOSS_CONSOLE"
  echo "WARNING: ignoring it and using /dev/null"
  JBOSS_CONSOLE="/dev/null"
fi

#define what will be done with the console log
JBOSS_CONSOLE=${JBOSS_CONSOLE:-"/dev/null"}

JBOSS_CMD_START="cd $JBOSS_HOME/bin; $JBOSSSH"

JBOSS_CMD_STOP=${JBOSS_CMD_STOP:-"$JBOSS_HOME/bin/shutdown.sh -s jnp://$JBOSS_BIND_ADDR:$JBOSS_JNP_PORT -u $JBOSS_ADMIN_USER -p '$JBOSS_ADMIN_PWD'"}


if [ -z "`echo $PATH | grep $JAVAPTH`" ]; then
  export PATH=$PATH:$JAVAPTH
fi

if [ ! -d "$JBOSS_HOME" ]; then
  echo JBOSS_HOME does not exist as a valid directory : $JBOSS_HOME
  exit 1
fi

function jbossPID()
{
    # try get the JVM PID
    local jbossPID="x"
    jbossPID=$(ps -eo pid,cmd | grep "org.jboss.Main" | grep "${JBOSS_BIND_ADDR} " | grep "${JBOSS_CONF}" | grep -v grep | cut -c1-6)

    echo "$jbossPID"
}

stop() {
    echo "stop JBoss (instance $JBOSS_CONF at $JBOSS_BIND_ADDR)..."

    if [ -z "$SUBIT" ]; then
        $JBOSS_CMD_STOP
    else
        echo "JBOSS_CMD_STOP = $JBOSS_CMD_STOP"
        $SUBIT "$JBOSS_CMD_STOP"
    fi 

    sleep 20

    # try get the JVM PID
    PID=$(jbossPID)
    if [ "x$PID" = "x" ]
    then
       echo "JBoss (instance $JBOSS_CONF at $JBOSS_BIND_ADDR) stopped!"
    else
       echo "process still running..."
       echo "killing JBoss (JVM process) [PID $PID]"
       kill -9 $PID
    fi
}

case "$1" in
start)

    echo "Cleaning work and tmp..."
    rm -rf $JBOSS_HOME/server/[CONFIGURATION]/work/*
    rm -rf $JBOSS_HOME/server/[CONFIGURATION]/tmp/*

    echo "JBOSS_CMD_START = $JBOSS_CMD_START"
    
    cd $JBOSS_HOME/bin
    if [ -z "$SUBIT" ]; then
        eval $JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &
    else
        $SUBIT "$JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &" 
    fi
    ;;
stop)
    stop
    ;;
restart)
    $0 stop
    $0 start
    ;;
*)
    echo "usage: $0 (start|stop|restart|help)"
esac

