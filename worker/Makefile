BLANK=\x1b[0m
GREEN=\x1b[32;01m
log = @echo "\n$(GREEN)=== $(1) ===\n$(BLANK)" >&2

# Preserve intermediate files
.SECONDARY:

all:

VERSION = $(shell ./lib/diarize_worker/version.rb full)
RESULTS_PATH = analysis
RESULTS_DIR = $(RESULTS_PREFIX)$(RESULTS_PATH)

%: $(RESULTS_DIR)/%/$(VERSION)/result.json
	$(call log,DONE!)

$(RESULTS_DIR)/%/$(VERSION)/result.json: $(RESULTS_DIR)/%/$(VERSION)/segments $(RESULTS_DIR)/%/$(VERSION)/transcription.json
	$(call log,Summarizing)

	./lib/results_summary.rb $* $(RESULTS_DIR)/$*/$(VERSION) > $@

$(RESULTS_DIR)/%/$(VERSION)/audio.sph: $(RESULTS_DIR)/%/$(VERSION)/audio.wav
	sox $< -r 16k -G $@

$(RESULTS_DIR)/%/$(VERSION)/audio.seg: $(RESULTS_DIR)/%/$(VERSION)/audio.sph
	$(call log,Diarizing)

	./lib/diarize.rb $< > $@

$(RESULTS_DIR)/%/$(VERSION)/audio.seg.json: $(RESULTS_DIR)/%/$(VERSION)/audio.seg
	./lib/parse_seg.rb $< > $@

$(RESULTS_DIR)/%/$(VERSION)/transcription.json: $(RESULTS_DIR)/%/$(VERSION)/segments_flac
	$(call log,Transcribing)

	find $</* | sort | xargs -n 1 ./lib/transcribe.rb | ./lib/join_json.rb > $@

$(RESULTS_DIR)/%/$(VERSION)/segments_flac: $(RESULTS_DIR)/%/$(VERSION)/audio.sph $(RESULTS_DIR)/%/$(VERSION)/audio.seg.json
	$(call log,Splitting)

	./lib/split.rb --outdir $(RESULTS_DIR)/$*/$(VERSION)/segments_flac $?


$(RESULTS_DIR)/%/$(VERSION)/segments_wav: $(RESULTS_DIR)/%/$(VERSION)/segments_flac
	$(call log,Converting to WAV)

	mkdir -p $@
	./lib/convert_folder_audio.rb $< flac $@ wav

$(RESULTS_DIR)/%/$(VERSION)/segments: $(RESULTS_DIR)/%/$(VERSION)/segments_flac
	$(call log,Converting to Mp3)

	mkdir -p $@
	./lib/convert_folder_audio.rb $< flac $@ mp3

clean:
	rm -rf $(RESULTS_DIR)
