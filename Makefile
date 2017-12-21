.PHONY: dist plugin-data backend-plugin-data frontend-plugin-data update-makefile-docs

dist: plugin-data update-makefile-docs
	rm -rf ./dist
	cd site && hugo --destination ../dist/html

plugin-data: backend-plugin-data frontend-plugin-data

backend-plugin-data:
	go get -u -v github.com/mattermost/mattermost-server/plugin
	mkdir -p site/data
	go run scripts/plugin-godocs.go > site/data/PluginGoDocs.json
	go run scripts/plugin-manifest-docs.go > site/data/PluginManifestDocs.json

frontend-plugin-data:
	rm -rf scripts/mattermost-webapp
	cd scripts && git clone https://github.com/mattermost/mattermost-webapp.git
	cd scripts && npm install
	mkdir -p site/data
	node scripts/plugin-jsdocs.js > site/data/PluginJSDocs.json

define download-makefile-help
	-mkdir -p tmp/build; \
	curl -s https://raw.githubusercontent.com/mattermost/$(1)/master/Makefile > tmp/Makefile; \
	curl -s https://raw.githubusercontent.com/mattermost/$(1)/master/build/release.mk > tmp/build/release.mk; \
	cd tmp; \
	make help > ./temp.txt; \
	cat temp.txt | sed 's/\[[0-9]*m//g' > help.txt; \
	cd ../; \
	mkdir -p site/data; \
	cp tmp/help.txt site/data/$(1)-make-help.txt; \
	rm -rf tmp/
endef

update-makefile-docs:
	$(call download-makefile-help,mattermost-server)
	$(call download-makefile-help,mattermost-webapp)
	$(call download-makefile-help,mattermost-mobile)