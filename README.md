# Orientdb Protobufs Experiement

This is an experiment to see how the orientdb binary protocol could look if it used [protocol buffers](https://developers.google.com/protocol-buffers).

Check out [definitions.proto](./definitions.proto) for the data structures.

> Note: most but not all of the orientdb commands are currently implemented.


## Generating the definitions.

First, install protoc after downloading it from [the repo](https://code.google.com/p/protobuf/downloads/list).

Then run `make all` and have a look at the `out` directory.
