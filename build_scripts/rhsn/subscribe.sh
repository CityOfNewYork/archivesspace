#!/usr/bin/env bash
#  ____  _  _  ____  ____   ___  ____  __  ____  ____
# / ___)/ )( \(  _ \/ ___) / __)(  _ \(  )(  _ \(  __)
# \___ \) \/ ( ) _ (\___ \( (__  )   / )(  ) _ ( ) _)
# (____/\____/(____/(____/ \___)(__\_)(__)(____/(____).sh
#
#
# This script will:
# - Register the system with your Red Hat Developer account
# - Install the latest updates
#
# You will be prompted for your developer account credentials.
#
# If you are running this at DORIS, make sure your proxy is set.
# See /etc/profile.d/proxy.sh

# VARIABLES
RHEL_6="6."
RHEL_7="7."
rhsn_username=""
rhsn_password=""
rhsn_computer_name=""

usage() {
	cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -u, --username <username>         	Username for authenticating to RHSN 
  										(if not provided, will look for environment variable RHSN_USERNAME)
  -p, --password <password>         	Password for authenticating to RHSN
  										(if not provided, will look for environment variable RHSN_PASSWORD)
  -n, --name <name>                 	Computer name for RHSN
										(if not provided, will use hostname)
  --use_proxy							Should RHSN be configured to use a proxy					
  --proxy_hostname <proxy_hostname>		The host for the proxy (no protocol)
  --proxy_port <proxy_port>				The port for the proxy
  --proxy_user <proxy_user>				The user for an authenticated proxy (if required)
  --proxy_password <proxy_password>		The password for an authenticated proxy (if required)
  -h, ,-?, --help                   	Print out this help text
EOF
}

while :; do
	case $1 in
	-h | -\? | --help)
		usage # Display a usage synopsis.
		exit
		;;
	-u | --username) # Takes an option argument; ensure it has been specified.
		if [ "$2" ]; then
			rhsn_username=$2
			shift
		else
			die 'ERROR: "--username" requires a non-empty option argument.'
		fi
		;;
	--username=?*)
		rhsn_username=${1#*=} # Delete everything up to "=" and assign the remainder.
		;;
	--username=) # Handle the case of an empty --file=
		die 'ERROR: "--username" requires a non-empty option argument.'
		;;
	-p | --password) # Takes an option argument; ensure it has been specified.
		if [ "$2" ]; then
			rhsn_password=$2
			shift
		else
			die 'ERROR: "--password" requires a non-empty option argument.'
		fi
		;;
	--password=?*)
		rhsn_password=${1#*=} # Delete everything up to "=" and assign the remainder.
		;;
	--password=) # Handle the case of an empty --file=
		die 'ERROR: "--password" requires a non-empty option argument.'
		;;
	-n | --name) # Takes an option argument; ensure it has been specified.
		if [ "$2" ]; then
			rhsn_computer_name=$2
			shift
		else
			die 'ERROR: "--name" requires a non-empty option argument.'
		fi
		;;
	--name=?*)
		rhsn_computer_name=${1#*=} # Delete everything up to "=" and assign the remainder.
		;;
	--name=) # Handle the case of an empty --file=
		die 'ERROR: "--name" requires a non-empty option argument.'
		;;
	--use_proxy) # Takes an option argument; ensure it has been specified.
		use_proxy=true
		shift
		;;
	--use_proxy=?*)
		use_proxy=true
		;;
	--use_proxy=) # Handle the case of an empty --file=
		use_proxy=true
		;;
	--proxy_hostname) # Takes an option argument; ensure it has been specified.
		if [ "$2" ]; then
			proxy_hostname=$2
			shift
		else
			die 'ERROR: "--proxy_hostname" requires a non-empty option argument.'
		fi
		;;
	--proxy_hostname=?*)
		proxy_hostname=${1#*=} # Delete everything up to "=" and assign the remainder.
		;;
	--proxy_hostname=) # Handle the case of an empty --file=
		die 'ERROR: "--proxy_hostname" requires a non-empty option argument.'
		;;
	--proxy_port) # Takes an option argument; ensure it has been specified.
		if [ "$2" ]; then
			proxy_port=$2
			shift
		else
			die 'ERROR: "--proxy_port" requires a non-empty option argument.'
		fi
		;;
	--proxy_port=?*)
		proxy_port=${1#*=} # Delete everything up to "=" and assign the remainder.
		;;
	--proxy_port=) # Handle the case of an empty --file=
		die 'ERROR: "--proxy_port" requires a non-empty option argument.'
		;;
	--proxy_user) # Takes an option argument; ensure it has been specified.
		if [ "$2" ]; then
			proxy_user=$2
			shift
		else
			die 'ERROR: "--proxy_user" requires a non-empty option argument.'
		fi
		;;
	--proxy_user=?*)
		proxy_user=${1#*=} # Delete everything up to "=" and assign the remainder.
		;;
	--proxy_user=) # Handle the case of an empty --file=
		die 'ERROR: "--proxy_user" requires a non-empty option argument.'
		;;
	--proxy_password) # Takes an option argument; ensure it has been specified.
		if [ "$2" ]; then
			proxy_password=$2
			shift
		else
			die 'ERROR: "--proxy_password" requires a non-empty option argument.'
		fi
		;;
	--proxy_password=?*)
		proxy_password=${1#*=} # Delete everything up to "=" and assign the remainder.
		;;
	--proxy_password=) # Handle the case of an empty --file=
		die 'ERROR: "--proxy_password" requires a non-empty option argument.'
		;;
	--) # End of all options.
		shift
		break
		;;
	-?*)
		printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
		;;
	*) # Default case: No more options, so break out of the loop.
		break ;;
	esac

	shift
done

rhsn_username=${rhsn_username:-$RHSN_USERNAME}
rhsn_password=${rhsn_password:-$RHSN_PASSWORD}
rhsn_computer_name=${rhsn_computer_name:-$(hostname)}
use_proxy=${use_proxy:-false}

if [ -n "$rhsn_username" ]; then
	read -r -p "Please enter your RedHat Developer Username:" rhsn_username
fi

if [ -n "$rhsn_password" ]; then
	read -r -p -s "Please enter your RedHat Developer Password:" rhsn_username
fi

if [ -n "$rhsn_computer_name" ]; then
	rhsn_computer_name=$(date '+%m-%d-%Y_%H-%M')
fi

# ensure running as root
if [ "$(id -u)" != "0" ]; then
	exec sudo "$0" "$@"
fi

# This is checking to see if http_proxy is not null
if [ -n "$use_proxy" ]; then
	proxy_hostname=${proxy_hostname-""}
	proxy_port=${proxy_port-""}
	proxy_user=${proxy_user-""}
	proxy_password=${proxy_password-""}
	if grep -q $RHEL_7 /etc/redhat-release; then
		sudo subscription-manager config --server.proxy_hostname="$proxy_hostname" --server.proxy_port="$proxy_port" --server.proxy_user="$proxy_user" --server.proxy_password="$proxy_password"
	elif grep -q $RHEL_6 /etc/redhat-release; then
		sudo subscription-manager config --server.proxy_hostname="$proxy_hostname" --server.proxy_port="$proxy_port" --server.proxyuser="$proxy_user" --server.proxypassword="$proxy_password"
	fi
fi

subscription-manager register --username "$rhsn_username" --password "$rhsn_password" --name "$rhsn_computer_name" --auto-attach --force
subscription-manager attach

if grep -q $RHEL_7 /etc/redhat-release; then
	subscription-manager repos --enable rhel-server-rhscl-7-rpms
	subscription-manager repos --enable rhel-7-server-optional-rpms
elif grep -q $RHEL_6 /etc/redhat-release; then
	subscription-manager repos --enable rhel-server-rhscl-6-rpms
	subscription-manager repos --enable rhel-6-server-optional-rpms
fi

yum -y update
