#!/bin/bash

## Arguments
# Remove audio files older than 8 days|or remove all.
# By default it uses the preset variable in code of 8 days: $0 -r 8
# $0 -r all

# Default preset for the target directory to remove files. You can preset this in the variable below.
# $0 -t "/sdcard/Podcasts/channels/"
# $0 -t "/LeedyData/leedymedia/audio_from_youtube"
##

## Default presets
# Preset target directory if not passed as argument.
#preset_target_dir="/sdcard/Podcasts/channels/"
preset_target_dir="/LeedyData/leedymedia/audio_from_youtube"

# How old in Days should it be to remove?
file_age=3
remove_all_files=false
##

# Gets the location of the script
pdir_syncs="$( cd "$(dirname "$0")" ; pwd -P )"

# What file type is it we looking to remove?
# I am using .mp3 at the moment.
file_type="*.mp3"

# Go through the passed options.
while getopts 'r:t:h' opt; do
  case "$opt" in
    r)
	# If OPTARG is a number, then remove all older days of that number
	if [[ $OPTARG == ?(-)+([[:digit:]]) ]]; then
		file_age="$OPTARG"
		echo "Removing audio files older than $file_age days."
	elif [ $OPTARG = "all" ]; then
	# Else if OPTARG is 'all' then remove all audio files.
		echo "Removing ALL audio files!"
		remove_all_files=true
	fi
      ;;

    t)
	echo "Target directory is: $OPTARG"
	preset_target_dir="$OPTARG"

	# Sanity Check. The path should not be root and it should end with a slash.
	# if ...
      ;;

    ?|h)
      	echo ""
	echo "Usage: $(basename $0) [-r 8|all] [-t \"/path/\"]"
	echo ""
	echo "[Removing older files]"
	echo "Remove audio files older than set days|or remove all."
	echo "Default preset variable in the code is set to $file_age days."
	echo ""
	echo "Set with '$0 -r $file_age'"
	echo "To remove all audio files."
	echo "$0 -r all"
	echo ""
	echo "[Change the target directory for storing files]"
	echo "Default preset variable for the target directory to remove files is $preset_target_dir"
	echo "It can be changed with."
	echo "$0 -t $preset_target_dir"
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

# Remove all or by age.
if $remove_all_files; then
	# Sanity check. Not / (root) or something else.
	# if ...
	echo "Removing files..."
	#echo $preset_target_dir*/*.mp3
	rm -rf $preset_target_dir*/*.mp3
else

	# Remove all *.mp3 files that are beyond an age, so all old ones are removed and do not fill our storage up.
	#find "$preset_target_dir" -name "$file_type" -type f -mtime +$file_age
	find "$preset_target_dir" -name "$file_type" -type f -mtime +$file_age -delete
fi

# Sometimes the script borks and leaves partial files behind. Let's remove those.
# *.part
# *.ytdl
find "$preset_target_dir" -name "*.part" -type f -delete
find "$preset_target_dir" -name "*.ytdl" -type f -delete
