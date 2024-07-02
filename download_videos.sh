#!/usr/bin/env bash

# Download videos from youtube channel list (channels.txt)
# Inpsired by https://news.ycombinator.com/item?id=21509523

# Using https://github.com/yt-dlp/yt-dlp for downloads


# Gets the location of the script
pdir="$( cd "$(dirname "$0")" ; pwd -P )"

# This may not pull in the location of ffmpeg. Adjust as needed.
ffmpeg_location="$(which ffmpeg)"
#ffmpeg_location="/usr/bin/ffmpeg"
if [[ -z "${ffmpeg_location}" ]]; then
	echo "We use ffmpeg. Is ffmpeg installed? If so, please adjust the path to it in the file."
	exit 1
else
	echo "We think the location of ffmpeg is: ${ffmpeg_location}"
fi

# The main program this script is using to download from Youtube is: yt-dlp.
# It will be needing updates as Youtube changes things and the developers for yt-dlp will have to respond to keep the yt-dlp program working.
# Sometimes the turn around to get the yt-dlp working again afte a Youtube change is days.
# So this script will auto execute an update check to keep on top of things.
"${pdir}/yt-dlp" -U

# where to drop our downloaded/converted files
channels_path="/LeedyData/leedymedia/audio_from_youtube"
#channels_path="/sdcard/Podcasts/channels/"

# How many days back of content to download
content_age=1

# How many to download at the same time. By default, 2.
# I wish to make this number based on the download speed at the time we start the script divided in 2. Math to follow.
number_downloads_at_once=2

# make sure we have a channel list
if [[ ! -a "${pdir}/channels.txt" ]]; then
	echo "channels.txt not found. Exiting."
	echo " "
	echo "Please create a file with <name> <url> format to download videos from."
	echo "Comments are supported if started with a "#"."
	echo "Example:"
	echo "# Good stories from Ripe."
	echo "Ripe https://www.youtube.com/@RipeStories/videos"
	echo "MrRedder https://youtube.com/@MrRedderYT/videos"
	echo "Uncle_Jon https://youtube.com/@Uncle_Jon?si=7wLThdLfwQNRlINm"

	exit 1
else
	channels_file="${pdir}/channels.txt"
fi

# Go through the passed options.
while getopts 'r:t:h' opt; do
  case "${opt}" in
    r)
		# If OPTARG is a number, then remove all older days of that number
		if [[ ${OPTARG} == ?(-)+([[:digit:]]) ]]; then
			content_age="${OPTARG}"
			echo "Removing audio files older than ${content_age} days."

		elif [ ${OPTARG} = "all" ]; then
		# Else if OPTARG is 'all' then remove all audio files.
			echo "Removing ALL audio files!"
			remove_all_files=true
		fi
    ;;

    t)
		echo "Target directory is: ${OPTARG}"
		channels_path="${OPTARG}"

		# Sanity Check. The path should not be root and it should end with a slash.
		# if ...
    ;;

    ?|h)
		echo ""
		exit 0
    ;;
  esac
done
shift "$((${OPTIND} -1))"

# Read in the channels.txt data
while read line; do

	# If the line is not empty...
	#if [ ! -z "${line}" ]; then
	if [[ ! -z "${line}" && "${line}" != \#* ]]; then

	# Channel name and channel url are stored in channels.txt
	read -r channel url <<< $(echo ${line})

	chan_path="${channels_path}/${channel}"
	if [ ! -d "${chan_path}" ]; then
		mkdir -p "${chan_path}"
		touch "${chan_path}/dl_archive.txt"
	fi
	cd ${chan_path}

	#video_filters="--date now-"${content_age}"days"
	video_filters="--date today"

	# Sometimes it complains about not being able to remux (webm+mp4). It falls back to mkv...
	video_options="--extract-audio --audio-format mp3 --audio-quality 0 --write-thumbnail --embed-thumbnail --ffmpeg-location ${ffmpeg_location}"

	output_options="--download-archive dl_archive.txt --output %(upload_date)s%(fulltitle)s.%(ext)s"
	misc_options="--no-progress -N ${number_downloads_at_once} --abort-on-unavailable-fragments"

	options="${video_filters} ${video_options} ${output_options} ${misc_options}"

	# I wanted to keep yt-dlp out of here, but this seems like the best way to make this portable.
	#echo "${pdir}/yt-dlp"
	echo "Content Age: '${content_age}'"
	echo "Options: ${options}"
	echo "URL: '${url}'"
	"${pdir}"/yt-dlp ${options} "${url}"
	exit

	fi

#done <${channels_file}
done <"${pdir}/channels.txt"

cd "${pdir}"


# Deal with the files.
# Right now, removing any files beyond an age.
# -r is the age at which to start removing the files.
# -t is the target directory.
# These are preset in the script.
"${pdir}/sync_files.sh" -r ${content_age} -t "${channels_path}"
