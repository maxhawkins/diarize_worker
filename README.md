Diarize Worker
==============

A Makefile and some Ruby scripts I used in a voice transcription pipeline. a few years back I used a couple hundred of these workers to process a lot of audio files in parallel. The program isn't in production anymore, but I'm uploading it here in case it's helpful to others.

Here's what it did:

1. Pull from a redis queue of audio files
2. Diarize audio files with [LIUM SpkDiarization](http://www-lium.univ-lemans.fr/diarization/doku.php/welcome)
3. Upload to the now-defunct Google speech recognition API
4. Format the results as json

To run:

1. Put your audio file in "analysis/(id of your choice)/diarize_worker-0.0.2/audio.wav"
2. Run "make analysis/(id of your choice)/diarize_worker-0.0.2/results.json".
