# devhelper_grpc

Try to make mobile app that can call GRPC endpoint

## What we done so far?

To create GRPC call, we need the contract. 
The contract can be obtained by using a file, maybe like some upload
from device, or using server reflection. And download the Descriptor.

# TODO
- [ ] using https://pub.dev/packages/protobuf_google
- [ ] test dart using grpc.reflection.v1alpha.ServerReflection



### Some main class..

To get the schema, we are using DescriptorProto class. This class is
generated from descriptor.proto. descriptor.proto is like some AST for
\*.proto file. 

Ok, Lets see how we will connect some of object.

In the UI we have 

- CallViewObject: this to view the object
- DynamicMessage: this is to be called into server
- ClientChannel : this one that will used the DynamicMessage

- DescriptorProto -> toCreate DynamicMessage
- ServiceDescriptorProto -> toCreate Call

If we want to have Call object or call abstraction

abstract class Executor {
	Response call(pkg, service, method, request)
}

abstact class ExecutorFactory {
	factory forHost(host, port) Executor {}
}

class Call {
	CallStore callStore
	ExecutorFactor executorFactory

	Response call() {
		var executor = executorFactory.forHost(callStore.host, callStore.port)

		var request = DynamicMessage.fromDescriptor(callStore.reqProto, callStore.pkg)
		request.fill(callStore.req)

		executor.call(
			callStore.pkg,
			callStore.service,
			callStore.method,
			request
		);
	}
}

// to show to view
class CallView {
	String name
	int groupID 

	String host,
	int port,

	String pkg,
	String service,
	String method,

	Request req -> serialize to json
	Response? res -> serialize to json
}

// to store it
class CallStore {
	uuid uuid;
	String name
	int groupID 

	String host,
	int port,

	String pkg,
	String service,
	String method,

	DescriptorProto reqProto -> serialize to protobuf
	DescriptorProto resProto -> serialize to protobuf

	Request req -> serialize to json
	Response? res -> serialize to json
}


As User I can create new Call, and save it. And execute it immediately and execute it latter..

OK, we are need server first..
But how we will do that?
This is something that we will need something else..


First maybe we need server..

Where will we get the resource..
List of server

List of server

So we will have server list..

hostname