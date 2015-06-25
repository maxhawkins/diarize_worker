worker.zip: worker worker/vendor
	zip -r $@ $<

worker/vendor: worker
	cd worker && bundle install --path vendor
