all: orientdb.proto
	@mkdir -p ./out/cpp
	@mkdir -p ./out/java
	@mkdir -p ./out/python
	@protoc --java_out=./target/java --cpp_out=./target/cpp --python_out=./target/python ./src/main/resources/orientdb.proto

docs: orientdb.proto
	@npm install
	@./node_modules/docco/bin/docco -e .cpp -o ./docs -l linear orientdb.proto
	@mv ./docs/orientdb.html ./docs/index.html


release: docs
	@git checkout gh-pages
	@git rm ./index.html
	@git rm ./docco.css
	@git rm -r ./public
	@mv docs/* .
	@git add ./index.html ./docco.css ./public
	@git commit -m "update documentation"
	@git push origin gh-pages
	@git checkout master
