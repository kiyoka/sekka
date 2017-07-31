
sekka-server.jar : ./app/sekka-server.rb bin/init.rb
	rm -rf ./lib
	mkdir -p ./lib
	cp -r ../lib/* ./lib
	bundle exec warble jar .

./app/sekka-server.rb : ../bin/sekka-server
	cp -f ../bin/sekka-server ./app/sekka-server.rb 

rackup:
	java -jar sekka-server.jar

bundle:
	bundle install --path vendor/bundle
