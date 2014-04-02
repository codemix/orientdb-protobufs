all: orientdb.proto
	@mkdir -p ./out/cpp
	@mkdir -p ./out/java
	@mkdir -p ./out/python
	@protoc --java_out=./out/java --cpp_out=./out/cpp --python_out=./out/python ./orientdb.proto

docs: orientdb.proto
	@npm install
	@./node_modules/docco/bin/docco -e .cpp orientdb.proto -o ./docs -l linear