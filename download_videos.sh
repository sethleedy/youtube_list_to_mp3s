#!/usr/bin/env bash

# Download videos from youtube channel list (channels.txt)
# Inpsired by https://news.ycombinator.com/item?id=21509523

# Using https://github.com/yt-dlp/yt-dlp for downloads


# Gets the location of the script
pdir="$( cd "$(dirname "$0")" ; pwd -P )"
ffmpeg_location="$(which ffmpeg)"
# where to drop our downloaded/converted files
channels_path="/LeedyData/leedymedia/audio_from_youtube"
#channels_path="/sdcard/Podcasts/channels/"

# How many days back of content to download
content_age=1

# make sure we have a channel list
if [[ ! -a "${pdir}/channels.txt" ]]; then
	echo "channels.txt not found. Exiting."
else
	channels_file="${pdir}/channels.txt"
fi

# Prep the channel folders
#if [ ! -d "$pdir/channels" ]; then
if [ ! -d "${channels_path}" ]; then
	mkdir "${channels_path}"
fi

while read line; do

	# If the line is not empty...
	if [ ! -z "${line}" ]; then

	# Channel name and channel url are stored in channels.txt
	read -r channel url <<< $(echo ${line})

	chan_path="${channels_path}/${channel}"
	if [ ! -d "${chan_path}" ]; then
		mkdir "${chan_path}"
		touch "${chan_path}/dl_archive.txt"
	fi
	cd ${chan_path}

	video_filters="--dateafter now-"${content_age}"days --playlist-end 5"
	output_options="--download-archive dl_archive.txt -o %(upload_date)s%(fulltitle)s.%(ext)s"
	misc_options="--no-call-home --no-progress -N 2"

	# 1440p or less, best audio we can find.
	# Sometimes it complains about not being able to remux (webm+mp4). It falls back to mkv...
#	video_options="-f bestvideo[height<=1440]+bestaudio"
	video_options="-x --audio-format mp3"

	options="${video_filters} ${video_options} ${output_options} ${misc_options} --ffmpeg-location ${ffmpeg_location}"
	# I wanted to keep youtube-dl out of here, but this seems like the best way to make this portable.
	${pdir}/yt-dlp "$options" -- "${url}"

	fi

done <${channels_file}

cd "${pdir}"


# Deal with the files.
# Right now, removing any files beyond an age.
# -r is the age at which to start removing the files.
# -t is the target directory.
# These are preset in the script.
${pdir}/sync_files.sh -r ${content_age} -t "${channels_path}"
