#!/bin/sh
###################################################################
#  CCKiller version 1.0.2 Author: Jager <ge@zhangge.net>          #
#  For more information please visit https://zhangge.net/5066.html#
#-----------------------------------------------------------------#
#  Copyright ©2015 zhangge.net. All rights reserved.              #
###################################################################
conf_env()
{
    export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    export DKName=CCKiller
    export Base_Dir=/usr/local/cckiller
    export Version=1.0.2
    clear
}

check_env()
{
    #wget -V || yum install -y wget
    which sendmail || yum install -y sendmail
    mailx -V || yum install -y mailx
    
}

header()
{
printf "
###################################################################
#  $DKName version $DKVer Author: Jager <ge@zhangge.net>               #
#  For more information please visit https://zhangge.net/5066.html#
#-----------------------------------------------------------------#
#  Copyright @2015 zhangge.net. All rights reserved.              #
###################################################################

"
}

showhelp()
{
    conf_env
	header
	echo 'Usage: configure.sh [OPTIONS]'
	echo
	echo 'OPTIONS:'
	echo "-h | --help : Show help of $DKName"
	echo "-u | --update : update Check for $DKName"
	echo "-c | --config : Edit The configure of $DKName again"
	echo "-i | --install : install $DKName version $DKVer to This System"
	echo "-U | --uninstall : Uninstall cckiller from This System"
	echo
}

get_char()
{
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}

Check_U()
{
    userid=$(id | awk '{print $1}' | sed -e 's/=/ /' -e 's/(/ /' -e 's/)/ /'|awk '{print $2}')
    if [[ $userid -ne 0 ]]
    then
        echo "No root permissions,Please run with root user..."
        exit
    fi
}

Wget()
{
    wget --no-check-certificate -q -O $1 $2
}

Update()
{
    conf_env
    Wget $Base_Dir/version.txt https://zhangge.net/wp-content/uploads/files/cckiller/version.txt
    Configure=$(awk -F":" '/configure/ {print $2}' $Base_Dir/version.txt)
    
    FINAL_VER=$(awk -F":" '/version/ {print $2}' $Base_Dir/version.txt)
    
    if [[ -f $Base_Dir/ck.conf ]]
    then
        source $Base_Dir/ck.conf
    else
        echo "Error: Not Found $Base_Dir/ck.conf, Please install CCkiller Again."
        exit 1
    fi
    
    if [[ $DKVer != $FINAL_VER ]]
    then
        echo =============================================================================
        echo "Local Version: $DKVer"
        echo
        echo "Remote information:"
        echo
        cat $Base_Dir/version.txt
        echo
        echo =============================================================================
        read -p "New Version Found, Do You Want Update Now? (y/n, default y): " CHOICE
        if [[ $CHOICE == 'y' ]] || [[ $CHOICE == 'Y' ]] || [[ $CHOICE == "" ]]
        then
            clear
            Version=$FINAL_VER
            install update
        else
            echo "It‘s Skiped."
        fi
    else
        echo "Good, Already have the latest versions."
    fi
}

Configure()
{
    if [[ "$1" == "config" ]] && [[ ! -d "$Base_Dir" ]]
    then
	    echo; echo; echo "Warn: CCkiller not found, Please used -i install first"
	    echo
	    exit 0
    fi
    if [[ "$1" == "default" ]]
    then
        SLEEP_TIME=20
        BAN_PERIOD=600
        EMAIL_TO=root@localhost
        NO_OF_CONNECTIONS=100
        IGNORE_PORT=
        echo
        echo "You choice the default configuration:"
        echo 'Configure info,Please Review:'
        echo "======================================="
	    echo "  The Time interval : $SLEEP_TIME s"
	    echo
	    echo "  The Forbidden Time: $BAN_PERIOD s"
	    echo
	    echo "  Adminstrator Email: $EMAIL_TO"
	    echo
        echo "  Connections  Allow: $NO_OF_CONNECTIONS"
        echo 
        echo "  Ignore Port: Null                    "
        echo "========================================"
        echo "Press any key to continue..."
    else
        echo
        read -p "Please Input The Time interval of CCkiller Check(default: 20s): " SLEEP_TIME
        if [[ -z $SLEEP_TIME ]];then
            echo "The Time interval of CCkiller Check will set default 20s"
            SLEEP_TIME=20
        fi
        echo
        read -p "Please Input the Forbidden Time of banned IP(default: 600s): " BAN_PERIOD
        if [[ -z $BAN_PERIOD ]];then
    	    echo "The Forbidden Time will set default 600s"
    	    BAN_PERIOD=600
        fi
        echo
        read -p "Please Input the E-mail of Adminstrator(default: root@localhost): " EMAIL_TO
        if [[ -z $EMAIL_TO ]];then
    	    echo "The Adminstrator E-mail will set default root@localhost"
    	    EMAIL_TO=root@localhost
        fi
        echo
        read -p "Please Input the Maximum number of connections allowed(default 100): " NO_OF_CONNECTIONS
        if [[ -z $NO_OF_CONNECTIONS ]];then
        	echo "The Max number for connections Allowed will set default 100"
        	NO_OF_CONNECTIONS=100
        fi
        echo
        read -p "Please Input the ignore Ports of check like 21,8080,1080(default null): " IGNORE_PORT
        if [[ -z $IGNORE_PORT ]];then
        	echo "The ignore Ports of check will set default null"
        	IGNORE_PORT=
        fi
        clear
        echo
        echo 'Configure info,Please Review:'
        echo "======================================="
    	echo "  The Time interval : $SLEEP_TIME s"
    	echo
    	echo "  The Forbidden Time: $BAN_PERIOD s"
    	echo
    	echo "  Adminstrator Email: $EMAIL_TO"
    	echo
        echo "  Connections  Allow: $NO_OF_CONNECTIONS"
        echo 
        echo "  Ignore Port: $IGNORE_PORT"
        echo "========================================"
        echo "Press any key to continue..."
    fi
    char=`get_char`
    mkdir -p $Base_Dir/log

cat << EOF >$Base_Dir/ck.conf
##### Paths of the script and other files
PROGDIR="$Base_Dir"
LOGDIR="$Base_Dir/log"
PROG="$Base_Dir/cckiller"
IGNORE_IP_LIST="$Base_Dir/ignore.ip.list"
IPT="/sbin/iptables"
DKName=$DKName
DKVer=$Version

##### SLEEP_TIMEuency in minutes for running the script in proccess mode(default 20s)
SLEEP_TIME=$SLEEP_TIME

##### How many connections define a bad IP? Indicate that below.
NO_OF_CONNECTIONS=$NO_OF_CONNECTIONS

##### An email is sent to the following address when an IP is banned.
EMAIL_TO="$EMAIL_TO"

#####  The Forbidden seconds of banned IP(default:600s).
BAN_PERIOD=$BAN_PERIOD

##### The ignore Ports like 21,2121,8000 (default null)
IGNORE_PORT=$IGNORE_PORT
EOF
    echo
    test -f /etc/init.d/cckiller && /etc/init.d/cckiller restart
    echo
    echo "Configure Completed."
}

install()
{
    if [[ -d "$Base_Dir" ]] && [[ -z $1 ]]; then
	    echo; echo; echo "Warn: cckiller is already installed, Please used -U uninstall first"
	    echo
	    exit 0
    fi
    read -p 'Do you want to use the default configuration? (y/n): ' CHOICE
    if [[ $CHOICE == "n" ]]
    then
        Configure
    else
        Configure default
    fi
    clear
    echo; echo "Installing $DKName version $DKVer by zhangge.net"; echo
    echo; echo -n 'Downloading source files...'
    check_env >/dev/null 2>&1
    echo -n '.'
    Wget $Base_Dir/cckiller https://zhangge.net/wp-content/uploads/files/cckiller/cckiller.sh?ver=$(date +%M|md5sum|awk '{print $1}')
    
    test -d /etc/init.d || mkdir -p /etc/init.d
    Wget /etc/init.d/cckiller https://zhangge.net/wp-content/uploads/files/cckiller/cckiller_service.sh?ver=$(date +%M|md5sum|awk '{print $1}')
    chmod 0755 $Base_Dir/cckiller
    
    chmod 0755 /etc/init.d/cckiller
    
    test -f /etc/rc.d/rc.local && echo "/etc/init.d/cckiller start" >>/etc/rc.d/rc.local
        
    ln -sf $Base_Dir/cckiller /bin/cckiller
    
    cp -f $0 $Base_Dir/
    
    #ifconfig |awk -F '[ :]+' '/inet addr/{print $4}' > /usr/local/cckiller/ignore.ip.list
    if [[ -z $1 ]]
    then
        ip addr | awk -F '[ /]+' '/inet / {print $3}' | grep -v '127.0.' > /usr/local/cckiller/ignore.ip.list
    fi
    echo "...done"
    echo
    echo
    if [[ -z $1 ]]
    then
        /etc/init.d/cckiller start
        echo "Installation has completed."
        echo
        echo "Config file is at $Base_Dir/ck.conf"
    else
        /etc/init.d/cckiller restart
        echo "Update success."
    fi
    
    echo
    echo 'Your can post comments or suggestions on https://zhangge.net/5066.html'
    echo
}

function uninstall()
{
    echo "Uninstalling cckiller..."
    echo;
    test -f /etc/init.d/cckiller && /etc/init.d/cckiller stop
    echo; echo; echo -n "Deleting script files....."
    if [ -e "$Base_Dir/cckiller" ]; then
        rm -f $Base_Dir/cckiller
        echo -n ".."
    fi
    if [ -d "$Base_Dir" ]; then
        rm -rf $Base_Dir
        echo -n ".."
    fi
    echo "done"
    echo; echo -n "Deleting system service....."
    if [ -e '/etc/init.d/cckiller' ]; then
        rm -f /etc/init.d/cckiller
        echo -n ".."
    fi
    echo "done"
    echo; echo "Uninstall Complete"; echo
}

conf_env

if [[ -z $1 ]];then
    showhelp
    exit
fi

header
Check_U
while [ $1 ]; do
	case $1 in
		'-h' | '--help' | '?' )
			showhelp
			exit
			;;
		'--install' | '-i' )
			install
			exit
			;;
		'--uninstall' | '-U' )
			uninstall
			exit
			;;
		'--update' | '-u' )
			Update
			exit
			;;	
		'--config' | '-c' )
			Configure config
			exit
			;;	
		* )
			showhelp
			exit
			;;
	esac
	shift
done
