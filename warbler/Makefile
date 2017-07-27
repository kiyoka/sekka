
sekka-server.jar : ./bin/sekka-server.rb
	rm -rf ./lib
	mkdir -p ./lib
	cp -r ../lib/* ./lib
	bundle exec warble jar .

./bin/sekka-server.rb : ../bin/sekka-server
	cp -f ../bin/sekka-server ./bin/sekka-server.rb 

rackup:
	java -jar sekka-server.jar

bundle:
	bundle install --path vendor/bundle
