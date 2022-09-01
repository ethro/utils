#!/bin/bash
# --------------------------------------------------------------------------------
# gen_rsa.sh
# $$ Created: 2015-02-07 $$
# $$ Modified: 2015-02-07 $$
# 
# PURPOSE: To generate an ssh key pair and add host information intended for the
# new ssh key pair to the .ssh/config file and attempt to transfer the public
# key to the intended host
# --------------------------------------------------------------------------------
HOST_ALIAS=
HOST_USERNAME=
HOST_ADDRESS=
ATTEMPT_TX=0
SSH_BASE=~/.ssh

usage()
{
cat<<EOF

  usage: $0 options

  This script will generate a rsa key pair, add the intended host name, username,
  address, and location of the private key to your .ssh/config file.  Upon
  successful generation, an attempt can be made to transfer the public key to the
  host.

  REQUIRED:
  -a  Host alias
  -u  Username on host
  -H  Host address

  OPTIONS:
  -h  Show this message
  -t  Attempt to transfer public key

EOF
}

generate_keys()
{
  mkdir -p $IDENTITY_PATH
  ssh-keygen -t rsa -f $IDENTITY_PATH/id_rsa -N ""
}

echo_host_info()
{
  echo "Host $HOST_ALIAS" >> $CONFIG_PATH
  echo "  User $HOST_USERNAME" >> $CONFIG_PATH
  echo "  HostName $HOST_ADDRESS" >> $CONFIG_PATH
  echo "  IdentityFile $PRIVATE_KEY" >> $CONFIG_PATH
}

add_to_config()
{
  if [ -e $CONFIG_PATH ] ; then
    HOST_CONFIG_EXIST=`grep "Host $HOST_ALIAS" $CONFIG_PATH | wc -l`
    if [ $HOST_CONFIG_EXIST -eq 0 ] ; then
      echo_host_info
    fi
  else
    touch $CONFIG_PATH
    echo "Host *" >> $CONFIG_PATH
    echo "  PreferredAuthentications publickey,keyboard-interactive,password" >> $CONFIG_PATH
    echo_host_info
  fi
}

tx_to_host()
{
  if [ -e $PUBLIC_KEY ] && [ $ATTEMPT_TX -eq 1 ]; then
    cat $PUBLIC_KEY | ssh -e none $HOST_ALIAS 'cat >> .ssh/authorized_keys'
  fi
}

EXIT=0

while getopts "hta:u:H:" OPTION
do
  case $OPTION in
    h)
      usage
      EXIT=1
      ;;
    t)
      ATTEMPT_TX=1
      ;;
    a)
      HOST_ALIAS=$OPTARG
      ;;
    u)
      HOST_USERNAME=$OPTARG
      ;;
    H)
      HOST_ADDRESS=$OPTARG
      ;;
  esac
done
if [[ -z $HOST_ALIAS ]] || [[ -z $HOST_USERNAME ]] || [[ -z $HOST_ADDRESS ]]
then
  usage
  EXIT=1
fi

if [ $EXIT -eq 0 ] ; then
  CONFIG_PATH=$SSH_BASE/config
  IDENTITY_PATH=$SSH_BASE/$HOST_ALIAS
  PRIVATE_KEY=$IDENTITY_PATH/id_rsa
  PUBLIC_KEY=$IDENTITY_PATH/id_rsa.pub

generate_keys
add_to_config
tx_to_host
fi
