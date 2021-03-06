#! /bin/sh
#?
#? File generated from %M% %I%
#?
#? NAME
#?      $0 - install script for O-Saft
#?
#? SYNOPSIS
#?      $0 [options] [installation directory]
#?
#? DESCRIPTION
#?      Some people want to have an installation script, in particular named
#?      INSTALL.sh, even O-Saft should work without a specific installation.
#?      Here we go.
#?
#?      This script does nothing except printing some messages unless called
#?      with an argument. The arguments are:
#?
#?          /absolute/path
#?                      - copy all necessary files into specified directory
#?          --check     - check current installation
#?          --clean     - move files not necessary to run O-Saft into subdir
#?                        ./release_information_only
#           This is the behaviour of the old  INSTALL-devel.sh  script.
#?
#? OPTIONS
#?      --h     got it
#?      --n     do not execute, just show
#?      --force install .o-saft.pl  and  .o-saft.tcl  in  $HOME,  overwrites
#?              existing ones
#?
#? EXAMPLES
#?      $0
#?      $0 --clean
#?      $0 --check
#?      $0 /opt/bin/
#?      $0 /opt/bin/ --force
#?
# HACKER's INFO
#       This file is generated from INSTALL-template.sh .
#       The generator (make) inserts some values for internal variables.  In
#       particular the list of source files to be installed.
#
#? VERSION
#?      @(#) INSTALL-template.sh 1.7 18/04/18 21:40:49
#?
#? AUTHOR
#?      16-sep-16 Achim Hoffmann
#?
# -----------------------------------------------------------------------------

# --------------------------------------------- internal variables; defaults
try=''
ich=${0##*/}
bas=${ich%%.*}
dir=${0%/*}
[ "$dir" = "$0" ] && dir="." # $0 found via $PATH in .
force=0
mode="";        # "", check, clean, dest
dest=""
clean=./release_information_only

text_miss="missing, try installing with ";	# 'cpan $m'"
text_dev="did you run »$0 --clean«?"
text_alt="file from previous installation, try running »$0 --clean« "
text_old="ancient module found, try installing newer version, at least "

files_contrib="
	contrib/.o-saft.tcl contrib/Cert-beautify.awk contrib/Cert-beautify.pl contrib/Dockerfile.alpine-3.6 contrib/HTML-simple.awk contrib/HTML-table.awk contrib/INSTALL-template.sh contrib/JSON-array.awk contrib/JSON-struct.awk contrib/XML-attribute.awk contrib/XML-value.awk contrib/bash_completion_o-saft contrib/bunt.pl contrib/bunt.sh contrib/cipher_check.sh contrib/critic.sh contrib/dash_completion_o-saft contrib/distribution_install.sh contrib/filter_examples contrib/fish_completion_o-saft contrib/gen_standalone.sh contrib/install_perl_modules.pl contrib/lazy_checks.awk contrib/o-saft.php contrib/tcsh_completion_o-saft contrib/usage_examples contrib/zap_config.sh contrib/zap_config.xml
		"

files_install="
	.o-saft.pl Dockerfile Net/SSLhello.pm Net/SSLinfo.pm OSaft/Ciphers.pm OSaft/Doc/Data.pm OSaft/Doc/coding.txt OSaft/Doc/glossary.txt OSaft/Doc/help.txt OSaft/Doc/links.txt OSaft/Doc/misc.txt OSaft/Doc/rfc.txt OSaft/Doc/tools.txt OSaft/_ciphers_iana.pm OSaft/_ciphers_openssl_all.pm OSaft/_ciphers_openssl_high.pm OSaft/_ciphers_openssl_low.pm OSaft/_ciphers_openssl_medium.pm OSaft/_ciphers_osaft.pm OSaft/error_handler.pm checkAllCiphers.pl o-saft o-saft-dbx.pm o-saft-docker o-saft-docker-dev o-saft-img.tcl o-saft-man.pm o-saft-usr.pm o-saft.pl o-saft.tcl osaft.pm
		"

files_not_installed="
		o-saft.cgi contrb/o-saft.php contrib/install_perl_modules.pl
		"

files_develop=".perlcriticrc o-saft_bench o-saft-docker-dev Dockerfile"

files_ancient="generate_ciphers_hash openssl_h-to-perl_hash o-saft-README INSTALL-devel.sh"

files_info="CHANGES README o-saft.tgz"

# --------------------------------------------- arguments and options
while [ $# -gt 0 ]; do
	case "$1" in
	 '-h' | '--h' | '--help')
		\sed -ne "s/\$0/$ich/g" -e '/^#?/s/#?//p' $0
		exit 0
		;;
	 '-n' | '--n')  try=echo;   ;;
	  '--check')    mode=check; ;;  # same as bare "check"
	  '--clean')    mode=clean; ;;  # same as bare "clean"
	  '--force')    force=1;    ;;
	  '--version')
		\sed -ne '/^#? VERSION/{' -e n -e 's/#?//' -e p -e '}' $0
		exit 0
		;;
	  '+VERSION')   echo 1.7 ; exit; ;; # for compatibility to o-saft.pl
	  *)            mode=dest; dest="$1";  ;;  # last one wins
	esac
	shift
done


# --------------------------------------------- main

# ------------------------- default mode --------- {
if [ -z "$mode" ]; then
	echo ""
	cat << EoT
# O-Saft does not need a specific installation.  It may be used from this
# directory right away.
#
# If you want to run O-Saft from this directory, then consider calling:

	$0 --clean

# If you want to install O-Saft in a different directory, then please call:

	$0 /path/to/installation/directoy
	$0 /path/to/installation/directoy --force

# To check if O-Saft will work, you may use:

	$0 --check

# In a Docker image, this script may only be called like:

	$0 --check

EoT
	exit 0
fi; # default mode }

if [ "$mode" != "check" ]; then
	if [ -n "$osaft_vm_build" ]; then
	    echo "**ERROR: found 'osaft_vm_build=$osaft_vm_build'"
	    echo "\033[1;31m**ERROR: inside docker only --check possible; exit\033[0m"
	    exit 6
	fi
fi

# ------------------------- clean mode ----------- {
if [ "$mode" = "clean" ]; then
	# do not move contrib/ as all examples expect contrib/ right here    
	for f in $files_info $files_ancient $files_develop ; do
		[ -e "$clean/$f" ] && $try \rm -f "$clean/$f"
		$try \mv "$f" "$clean"
	done
	exit 0
fi; # clean mode }

# ------------------------- install mode  -------- {
if [ "$mode" = "dest" ]; then
	[ ! -d "$dest" ] && echo "\033[1;31m**ERROR: $dest does not exist; exit\033[0m" && exit 2

	echo "# remove old files ..."
	# TODO: argh, hard-coded list of files ...
	for f in $files_install ; do
		f="$dest/$f"
		if [ -e "$f" ]; then
			$try \rm -f "$f" || exit 3
		fi
	done

	echo "# installing ..."
	$try \mkdir -p "$dest/Net"
	$try \mkdir -p "$dest/OSaft/Doc"
	for f in $files_install ; do
		$try \cp "$f" "$dest/$f"  || exit 4
	done

	if [ $force -eq 1 ]; then
		$try \cp .o-saft.pl  "$dest/" || echo "\033[1;31m .o-saft.pl  failed\033[0m"
		$try \cp contrib/.o-saft.tcl "$dest/" || echo "\033[1;31m .o-saft.tcl failed\033[0m"
	fi

	echo "# installation in $dest \033[1;32mcompleted.\033[0m"
	exit 0
fi; # install mode }

# ------------------------- check mode ----------- {
if [ "$mode" != "check" ]; then
	echo "\033[1;31m**ERROR: unknow mode  $dest; exit"
	exit 5
fi

# all following is check mode

err=0

echo ""
echo "# check installation"
echo "# (warnings are ok if git clone will be used for development)"
echo "#--------------------------------------------------------------"
# err=`expr $err + 1` ; # errors not counted here
files="openssl_h-to-perl_hash generate_ciphers_hash o-saft-README"
for f in $files ; do
	[ -e "$f" ] && echo "# found $f ... \t\033[1;33m$text_alt\033[0m"
done
files="$files_develop $files_info "
for f in $files ; do
	[ -e "$f" ] && echo "# found $f ... \t\033[1;33m$text_dev\033[0m"
done
echo "#--------------------------------------------------------------"

echo ""
echo "# check openssl executable"
echo "#--------------------------------------------------------------"
echo -n "# openssl:" && which openssl
echo -n "# openssl version\033[1;32m\t" && openssl version && echo -n "\033[0m"
# TODO: openssl older than 0x01000000 has no SNI
echo "#--------------------------------------------------------------"

echo ""
echo "# check for installed perl modules"
echo "#--------------------------------------------------------------"
modules="Net::DNS Net::SSLeay IO::Socket::SSL Net::SSLinfo Net::SSLhello osaft
OSaft::error_handler"
for m in $modules ; do
	echo -n "# testing for $m ..."
	v=`perl -M$m -le 'printf"\t%s",$'$m'::VERSION' 2>/dev/null`
	if [ -n "$v" ]; then
		case "$m" in
		  'IO::Socket::SSL') expect=1.90; ;; # 1.37 and newer work, somehow ...
		  'Net::SSLeay')     expect=1.49; ;; # 1.33 and newer may work
		  'Net::DNS')        expect=0.80; ;;
		esac
		case "$m" in
		  'Net::SSLinfo' | 'Net::SSLhello') c="green"; ;;
		  'OSaft::error_handler' | 'osaft') c="green"; ;;
		  'OSaft::Ciphers' )                c="green"; ;;
		  *) c=`perl -le "print (($expect > $v) ? 'red' : 'green')"`; ;;
		esac
		[ "$c" = "green" ] && echo "\033[1;32m\t$v\033[0m"
		[ "$c" = "red"   ] && echo "\033[1;31m\t$v , $text_old $expect\033[0m"
		[ "$c" = "red"   ] && err=`expr $err + 1`
	else 
		text_miss="$text_miss 'cpan $m'"
		echo "\033[1;31m $text_miss\033[0m"
		err=`expr $err + 1`
	fi
done
echo "#--------------------------------------------------------------"

echo ""
echo "# check for installed O-Saft"
echo "#--------------------------------------------------------------"
for o in o-saft.pl o-saft.tcl ; do
	for p in `echo $PATH|tr ':' ' '` ; do
		d="$p/$o"
		if [ -e "$d" ]; then
			v=`$p/$o +VERSION`
			echo "# O-Saft found ($v):\033[1;32m\t$d \033[0m"
		fi
	done
done
echo "#--------------------------------------------------------------"

echo ""
echo "# check for installed O-Saft resource files"
echo "#--------------------------------------------------------------"
# currently no version check
rc="$HOME/.o-saft.tcl"
if [ -e "$rc" ]; then
	v=`awk '/RCSID/{print $3}' $rc | tr -d '{};'`
	echo "# $rc found\033[1;32m\t$v \033[0m"
	echo "# $rc exists\t\033[1;33mconsider updating from contrib/.o-saft.tcl\033[0m"
else
	echo "# $rc missing\t\033[1;33mconsider copying  contrib/.o-saft.tcl into your HOME directory: $HOME\033[0m"
fi
rc="$HOME/.o-saft.pl"
if [ -e "$rc" ]; then
	echo "# $rc found\t\033[1;33m which will be used when started in $HOME only \033[0m"
	err=`expr $err + 1`
fi
echo "#--------------------------------------------------------------"

echo ""
echo "# check for contributed files"
echo "#--------------------------------------------------------------"
for c in $files_contrib ; do
	if [ -e "$c" ]; then
		echo "# found\t\033[1;32m\t$c \033[0m"
	else
		echo "# not found\t\033[1;33m\t$c \033[0m"
	fi
done
echo "#--------------------------------------------------------------"
echo ""
echo -n "# checks"
if [ $err -eq 0 ]; then
	echo "\033[1;32m\tpassed\033[0m"
else
	echo "\033[1;31m\tfailed , $err error(s) detected\033[0m"
fi

# check mode }

exit $err

