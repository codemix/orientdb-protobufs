all:
	@mkdir -p ./out/cpp
	@mkdir -p ./out/java
	@mkdir -p ./out/python
	@protoc --java_out=./out/java --cpp_out=./out/cpp --python_out=./out/python ./definitions.proto