#!/usr/bin/liquidsoap

# Include some sensitive configuration variables for icecast
%include "var.liq"

# Logging configuration to stdout and to the file
set("log.file.path","/tmp/<script>.log")
set("log.stdout", true)

# Icecast setting from included variables
output.icecast = output.icecast(
		description = descr,
		url         = url,
		host        = icehost,
		port        = iceport,
		password    = icepass,
		mount       = icemount)

# Import of samples and playlists.
# We need to convert all our files to stereo (audio_to_stereo)
# for proper functioning because this demo based on cheap mono files.
# It is the dirty demo and files have a different level, compression and acoustic pressure.
# So we quick amplified or reduced all our files to same volume using "amplify" function.

# The on_fail will be played if we got an error with the music.
on_fail   = amplify(1.0, audio_to_stereo(single("~/radio/examples/fallback.mp3")))

# This file have a bear roar that we will use as jingle for background.
sfx       = amplify(0.4, audio_to_stereo(single("~/radio/examples/rowr.mp3")))

# There are 4 playlist that we will use as music
digits_m  = amplify(2.1, audio_to_stereo(playlist(mode="normal","~/radio/playlists/digits-male.m3u",reload_mode="watch")))
digits_f  = amplify(4.0, audio_to_stereo(playlist(mode="normal","~/radio/playlists/digits-female.m3u",reload_mode="watch")))
desusex   = amplify(0.3, audio_to_stereo(playlist(mode="normal","~/radio/playlists/desusex.m3u",reload_mode="watch")))
piano     = amplify(3.5, audio_to_stereo(playlist(mode="normal","~/radio/playlists/piano.m3u",reload_mode="watch")))

# There are 2 playlist that we will use as jingles
modem     = amplify(0.5, audio_to_stereo(playlist(mode="normal","~/radio/playlists/modem.m3u",reload_mode="watch")))
shots     = amplify(0.4, audio_to_stereo(playlist(mode="normal","~/radio/playlists/shots.m3u",reload_mode="watch")))

# Jingles setting.
# This one will be played every 13 seconds after timeout
jingle_t  = delay(13.,modem)

# This jingle will be played randomly
jingle_r  = shots

# This jingle will be played in background with music every 30 seconds
jingle_bg = delay(30.,sfx)

# It is example for hard music schedule.
# Every first 5 minutes from every 20 minutes will be playing male's digits.
# Every second 5 minutes will be playing female's digits.
# Every third 5 minutes will be playing quotes from Desus Ex.
# Every last 5 minutes will be playing piano notes.
music     = switch([    ({  0m-5m or 20m-25m or 40m-45m}, digits_m),
	                    ({ 5m-10m or 25m-30m or 45m-50m}, digits_f),
	                    ({10m-15m or 30m-35m or 50m-55m}, desusex ),
	                    ({15m-20m or 35m-40m or 55m-60m}, piano   ) ])

# If we got any errors for music files let play the on_fail
music     = fallback(track_sensitive = false, [music, on_fail])

# Stream construction.
# Add jingle (bear roar) in background to music. Music will be twice louder then jingle.
radio     = add([jingle_bg, music], weights=[1,2])

# Randomly play jingle (gun's shots) after each track. The music will be twenty times more often than jingle.
radio     = random(weights = [1, 20],[jingle_r, radio])

# Every 13 seconds after the current track we need to play jingle (modem sounds).
radio     = fallback([jingle_t, radio])

# Let's play stream!
output.icecast(%vorbis, radio)
