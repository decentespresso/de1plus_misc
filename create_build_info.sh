#!/bin/sh

# Copyright (C) 2021 Jeff Kletsky, All Rights Reserved
# License granted under GPL-3.0-only
# SPDX-License-Identifier: GPL-3.0-only

: "${GIT_ROOT:=$(git rev-parse --show-toplevel)}"

if [ -z "$GIT_ROOT" ] ; then
    >&2 printf "Unable to locate git root. Exiting.\\n"
    exit 1
fi

: "${DE1PLUS:="${GIT_ROOT}/de1plus"}"

: "${BUILD_INFO:="${DE1PLUS}/build-info"}"
: "${VERSION_TCL:="${DE1PLUS}/version.tcl"}"

: "${BUILD_TIMESTAMP:=$(date +%s)}"

# As this might be envoked from within a submodule,
# confirm that we're talking about the proper repo

if ! cd $GIT_ROOT ; then
    >&2 printf "Unable to cd to git root. Exiting.\\n"
    exit 1
fi

git remote -v | fgrep -q 'https://github.com/decentespresso/de1app'
if [ $? -ne 0 ] ; then
    >&2 echo "No reference to offical repo in '$GIT_ROOT'"
    exit 2
fi





#
# Be able to capture the state of all the submodules
# https://git-scm.com/docs/git-submodule foreach
#   $name
#   --recursive
#
# Get commit timestamp
#   git show -s --format="%ct" HEAD
#
# Use ISO 8601 format
#


# git describe --dirty doesn't check for untracked files

git_untracked_suffix () {

    if ( git status --porcelain | grep -q '^\?\?' ) ; then
	printf -- "+"
    else
	printf ""
    fi
}


# For the main tree, only examine annotated tags

strict_git_describe () {

    retval=$(git describe --match "v*" --dirty 2> /dev/null)
    if [ $? = 0 ] ; then
	printf "%s%s" $retval $(git_untracked_suffix "$1")
    else
	>&2 printf "Unable to 'git describe' main repo based on annotated tags\\n"
	# an exit here won't exit the overall script as this is in a subshell
	printf ""
    fi
}


# For submodules, if there aren't any annotated tags
# provide fallbacks to lightweight tags, commit hash, or "unknown"

safe_git_describe () {

    # Try limiting to annotated tags first

    retval=$(git describe --match "v*" --dirty 2> /dev/null)
    if [ $? = 0 ] ; then
	printf "%s%s" $retval $(git_untracked_suffix "$1")
	return
    fi

    # Next the risky choice of "normal" tags that begin with "v"
    # (can pick up local tags unintentionally)

    retval=$(git describe --tags --match "v*" --dirty 2> /dev/null)
    if [ $? = 0 ] ; then
	printf "%s%s" $retval $(git_untracked_suffix "$1")
	return
    fi

    # No tags available, use commit hash

    retval=$(git rev-parse --short HEAD 2> /dev/null)
    if [ $? = 0 ] ; then
	printf "g%s%s" $retval $(git_untracked_suffix)
	return
    fi

    # Not much more to say

    printf "unknown"
}


last_commit_hash () {

    git show -s --format="%h" HEAD
}

last_commit_time () {

    git show -s --format="%ci" HEAD
}



this_version_string=$(strict_git_describe)

if [ -z "$this_version_string" ] ; then
    >&2 printf "Unable to set version string. Exiting\\n"
    exit 3
fi

printf "# DO NOT EDIT - Automatically generated\\n" > $BUILD_INFO

printf "version_string\\t%s\\n" "$this_version_string" >> $BUILD_INFO
printf "build_timestamp\\t%s\\n" "$BUILD_TIMESTAMP" >> $BUILD_INFO
printf "last_commit_hash\\t%s\\n" "$(last_commit_hash)" >> $BUILD_INFO
printf "last_commit_time\\t%s\\n" "$(last_commit_time)" >> $BUILD_INFO

#
# Write version.tcl as a valid Tcl version
# If version is "unknown" or otherwise unable to parse
# leave the existing version
#
# Using the number of commits since a tag should be monotonic
# as long as history isn't being rewritten on the branch
# Perhaps an "issue" for devs on local branches, but...
#

current_version=$(sed -E -ne 's/^.* ([0-9.]+) .*$/\1/p' $VERSION_TCL)

#
# Thank you https://sed.js.org/ !
#
# 1) Convert "Stable" to have a revision of zero
#    v1.35-12-gabc1234 ==> v1.35.0-12-gabc1234
# 2) Incorporate the number of commits as a build reference
#    v1.35.17-7-g1234567 ==> v1.35.17.7-g1234567
# 3) Remove the v and git hash, which should always match, and print
#    v1.35.17-7-g1234567 ==> 1.35.17.7
#

this_version=$(printf "%s" "$this_version_string" | \
		   sed -n -E -e 's/^v([0-9]+\.[0-9]+)(-[0-9])/v\1.0\2/' \
		       -e 's/^v([0-9.]+)(-([0-9]+))/v\1.\3/' \
		       -e 's/^v([0-9.]+)(.*)$/\1/p')

if [ -z "$this_version" ] ; then
    >&2 echo "ERROR: No valid version found from '$this_version_string'"
    exit 4
fi


if [ "$this_version" != "$current_version" ] ; then
    cvre=$(printf "%s" "$current_version" | sed -e 's/\./\\./g')
    tvre=$(printf "%s" "$this_version" | sed -e 's/\./\\./g')
    sed -i -e "s/$cvre/$tvre/g" $VERSION_TCL
    err=$?

    if [ $err != 0 ] ; then
	>&2 echo "ERROR: Error editing '${VERSION_TCL}' in place. Exiting."
	exit 5
    fi

    >&2 printf "NOTICE: Updated version to %s from %s\\n" \
	$this_version $current_version
    >&2 git diff -- $VERSION_TCL
fi

#
# Add submodule information
#


for sm_path in $(git submodule -q foreach --recursive 'echo $sm_path') ; do

    printf "#\\n" >> $BUILD_INFO
    printf "%s/_version_string\\t%s\\n" \
	   "$sm_path" "$(cd "$sm_path" ; safe_git_describe)" >> $BUILD_INFO
    printf "%s/_last_commit_hash\\t%s\\n" \
	   "$sm_path" "$(cd "$sm_path" ; last_commit_hash)" >> $BUILD_INFO
    printf "%s/_last_commit_time\\t%s\\n" \
	   "$sm_path" "$(cd "$sm_path" ; last_commit_time)" >> $BUILD_INFO

done

