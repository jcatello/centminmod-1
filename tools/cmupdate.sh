#!/bin/bash
######################################################
# cmupdate
# written by George Liu (eva2000) centminmod.com
######################################################
# variables
MAINDIR='/etc/centminmod'
CM_INSTALLDIR='/usr/local/src/centminmod'
#############
# variables
#############
cmupdate_branchname=123.09beta01
cmupdate_branchname_new=$cmupdate_branchname
DT=$(date +"%d%m%y-%H%M%S")
######################################################
# functions
#############
# set locale temporarily to english
# due to some non-english locale issues
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

if [ -f "${MAINDIR}/custom_config.inc" ]; then
    # default is at /etc/centminmod/custom_config.inc
    source "${MAINDIR}/custom_config.inc"
fi

fupdate() {
  branch_opt=$1
  if [[ "$branch_opt" = 'beta' ]]; then
    cmupdate_branchname=130.00beta01
    cmupdate_branchname_new=$cmupdate_branchname
  elif [[ "$branch_opt" = 'stable' ]]; then
    cmupdate_branchname=124.00stable
    cmupdate_branchname_new=$cmupdate_branchname
  fi

  CMUPDATE_GITCURLSTATUS=$(curl -sI https://raw.githubusercontent.com/centminmod/centminmod/${cmupdate_branchname}/gitclean.txt | grep 'HTTP\/' | awk '/200/ {print $2}')
    if [[ "$CMUPDATE_GITCURLSTATUS" = '200' ]]; then
      CHECK_GITCLEAN=$(curl -${ipv_forceopt}sLk https://raw.githubusercontent.com/centminmod/centminmod/${cmupdate_branchname}/gitclean.txt)
    else
      echo
      echo "Error: unable to connect to Github.com repo right now"
      echo "try again later"
      echo
      echo "if issue persists, report it on official Centmin Mod community"
      echo "https://community.centminmod.com/forums/install-upgrades-or-pre-install-questions.8/"
      exit 1
    fi
  if [[ -d "${CM_INSTALLDIR}/.git" ]]; then
    if [[ "$CHECK_GITCLEAN" = 'no' ]] || [[ "$branch_opt" != 'beta' || "$branch_opt" != 'stable' ]]; then
      cd "${CM_INSTALLDIR}"
      git stash
      git pull
    else
      echo
      if [[ "$branch_opt" = 'beta' || "$branch_opt" = 'stable' ]]; then
        echo "Switching local code branch to $cmupdate_branchname_new"
      else
        echo "Detected Centmin Mod Github Remote Repo Changes"
        echo "setting up fresh ${CM_INSTALLDIR} code base to match"
      fi
      echo
      cd /usr/local/src
      mv centminmod centminmod-automoved-cmupdate
      git clone -b ${cmupdate_branchname_new} --depth=1 https://github.com/centminmod/centminmod.git centminmod
      if [[ "$?" -eq '0' ]]; then
        rm -rf centminmod-automoved-cmupdate
        echo
        echo "Completed. Fresh ${CM_INSTALLDIR} code base in place"
        echo "To run centmin.sh again, you need to change into directory: ${CM_INSTALLDIR}"
        echo "cd ${CM_INSTALLDIR}"
        echo
      else
        mv centminmod-automoved-cmupdate centminmod
        echo
        echo "Error: wasn't able to successfully update ${CM_INSTALLDIR} code base"
        echo "       restoring previous copy of ${CM_INSTALLDIR} code base"
      fi
    fi
  fi
}

######################################################
fupdate

case "$1" in
  update )
    fupdate
    ;;
  update-stable )
    fupdate stable
    ;;
  update-beta )
    fupdate beta
    ;;
  * )
    fupdate
    ;;
esac

exit