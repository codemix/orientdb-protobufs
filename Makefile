all: definitions.proto
	@mkdir -p ./out/cpp
	@mkdir -p ./out/java
	@mkdir -p ./out/python
	@protoc --java_out=./out/java --cpp_out=./out/cpp --python_out=./out/python ./definitions.proto

docs: definitions.proto
	@npm install
	@./node_modules/docco/bin/docco -e .cpp definitions.proto -o ./docs -l linear