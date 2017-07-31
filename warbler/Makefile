
VERSION := $(shell ruby -I ../lib -rsekka/sekkaversion.rb -e 'puts SekkaVersion.version')

sekka-server.jar : ./app/sekka-server.rb bin/init.rb Makefile
	rm -rf ./lib
	mkdir -p ./lib
	cp -r ../lib/* ./lib
	bundle exec warble jar .
	/bin/cp sekka-server.jar sekka-server-${VERSION}.jar  

./app/sekka-server.rb : ../bin/sekka-server
	cp -f ../bin/sekka-server ./app/sekka-server.rb 

rackup:
	java -jar sekka-server.jar

bundle:
	bundle install --path vendor/bundle
