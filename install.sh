#!/bin/sh
###################################################################
#  CCKiller version 1.0.8 Author: Jager <ge@zhang.ge>          #
#  For more information please visit https://zhang.ge/5066.html#
#-----------------------------------------------------------------#
#  Copyright ©2015-2019 zhang.ge. All rights reserved.              #
###################################################################
conf_env()
{
    export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    export DKName=CCKiller
    export Base_Dir=/usr/local/cckiller
    export DKVer=1.0.8
    clear
}

check_env()
{
    which sendmail || yum install -y sendmail
    mailx -V || yum install -y mailx
    test -x $0 || chmod +x $0
    #Centos 7 install iptables
    if [ -n "`grep 'Aliyun Linux release' /etc/issue`" -o -e /etc/redhat-release ];then
        which iptables >/dev/null
        if [ -n "`grep ' 7\.' /etc/redhat-release`" -a $? -ne 0 ] ; then
            yum -y install iptables-services
            systemctl mask firewalld.service
            systemctl enable iptables.service
        fi
    fi
    /etc/init.d/iptables start > /dev/null 2>&1
}

header()
{
printf "
###################################################################
#  $DKName version $DKVer Author: Jager <ge@zhang.ge>               #
#  For more information please visit https://zhang.ge/5066.html#
#-----------------------------------------------------------------#
#  Copyright @2015-2019 zhang.ge. All rights reserved.              #
###################################################################

"
}

showhelp()
{
    conf_env
	header
	echo 'Usage: cckiller [OPTIONS]'
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

Update()
{
    conf_env
    curl -ko $Base_Dir/log/version.txt --connect-timeout 300 --retry 5 --retry-delay 3 https://zhang.ge/wp-content/uploads/files/cckiller/version.txt
    CONF_FILE=$(awk -F":" '/configure/ {print $2}' $Base_Dir/log/version.txt)
    
    FINAL_VER=$(awk -F":" '/version/ {print $2}' $Base_Dir/log/version.txt)
    
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
        cat $Base_Dir/log/version.txt
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
        echo "Good, It's the latest versions."
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
        LOG_LEVEL=INFO
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
        echo "  Ignore Port: Null                     "
        echo
        echo "  Log   Level:        $LOG_LEVEL        "
        echo "========================================"
        echo "Press any key to continue..."
    else
        echo
        read -p "Please Input The Rate(seconds) of CCkiller Check(default: 20): " SLEEP_TIME
        if [[ -z $SLEEP_TIME ]] || [[ 0 -eq $SLEEP_TIME ]] ;then
            echo "The Time interval of CCkiller Check will set default 20s"
            SLEEP_TIME=20
        fi
        echo
        read -p "Please Input the Forbidden Time(seconds) of banned IP(default: 600, if set 0 ip will banned until Restart System or iptables ): " BAN_PERIOD
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
        echo
        read -p "Please Input the level of log like INFO,DEBUG,WARNING,OFF (default INFO): " LOG_LEVEL
        if [[ -z LOG_LEVEL ]];then
        	echo "The ignore Ports of check will set default INFO"
        	LOG_LEVEL=INFO
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
        echo
        echo "  Log Level  : $LOG_LEVEL"
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
IPT=$(which iptables | awk '{print $1}')
IPT_SVR="/etc/init.d/iptables"
DKName=$DKName
DKVer=$DKVer

##### Rate of running the script in proccess mode(default 20s)
SLEEP_TIME=$SLEEP_TIME

##### How many connections define a bad IP? Indicate that below.
NO_OF_CONNECTIONS=$NO_OF_CONNECTIONS

##### An email is sent to the following address when an IP is banned.
EMAIL_TO="$EMAIL_TO"

#####  The Forbidden seconds of banned IP(default:600 if set 0 ip will banned forever).
BAN_PERIOD=$BAN_PERIOD

##### The ignore Ports like 21,2121,8000 (default null)
IGNORE_PORT=$IGNORE_PORT

##### The level of log like INFO,DEBUG,WARNING,OFF (default INFO)
LOG_LEVEL=$LOG_LEVEL
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
    if [[ $CONF_FILE == 'updated' ]] || [[ -z $CONF_FILE ]];then
        read -p 'Do you want to use the default configuration? (y/n): ' CHOICE
        if [[ $CHOICE == "n" ]]
        then
            Configure
        else
            Configure default
        fi
    fi
    source $Base_Dir/ck.conf
    clear
    echo; echo "Installing $DKName version ${FINAL_VER:-$DKVer} by zhang.ge"; echo
    echo; echo "Checking the operating environment..."
    check_env >/dev/null 2>&1
    echo; echo "Downloading source files..."
    curl -ko $Base_Dir/cckiller --connect-timeout 300 --retry 5 --retry-delay 3 https://zhang.ge/wp-content/uploads/files/cckiller/cckiller?ver=${FINAL_VER:-$DKVer}
    
    test -d /etc/init.d || mkdir -p /etc/init.d
    curl -ko /etc/init.d/cckiller --connect-timeout 300 --retry 5 --retry-delay 3 https://zhang.ge/wp-content/uploads/files/cckiller/cckiller_servicefile?ver${FINAL_VER:-$DKVer}
    chmod 0755 $Base_Dir/cckiller
    
    chmod 0755 /etc/init.d/cckiller
        
    chkconfig cckiller on 2>/dev/null || \
    
    test -f /etc/rc.d/rc.local && \
    echo "/etc/init.d/cckiller start" >>/etc/rc.d/rc.local
        
    ln -sf $Base_Dir/cckiller /bin/cckiller
    
    cp -f $0 $Base_Dir/ >/dev/null 2>&1
    
    if [[ -z $1 ]]
    then
        ip addr | awk -F '[ /]+' '/inet / {print $3}' | grep -v '127.0.' > $Base_Dir/ignore.ip.list
    fi
    echo "...done"
    echo
    echo
    if [[ -z $1 ]]
    then
        /etc/init.d/cckiller start
        echo
        echo "Installation has completed."
        echo
        echo "Config file is at $Base_Dir/ck.conf"
    else
        /etc/init.d/cckiller restart
        echo
        echo "Update success."
    fi
    
    echo
    echo 'Your can post comments or suggestions on https://zhang.ge/5066.html'
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
	rm -f /bin/cckiller
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
