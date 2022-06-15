import '../tokenizer/token.dart';
import '../tokenizer/token_type.dart';
import '../../proto/descriptor.pb.dart';

class Parser {
	List<Token> tokens = [];

	FileDescriptorSet fds = FileDescriptorSet();

	String filename = '';

	FileDescriptorProto file(String filename, Iterator<Token> it) {
		this.filename = filename;
		
		if (!it.moveNext()) {
			throw Exception("cannot process empty tokens");
		}
		
		// expect first to be start
		if (it.current.type != TokenType.start) {
			throw it.current.exception(filename, "expect start token");
		}

		var syntax = processSyntax(it);
		var package = processPackage(it);

		List<String> dependency = [];
		List<EnumDescriptorProto> enumType = [];
		List<DescriptorProto> messageType = [];
		List<ServiceDescriptorProto> service = [];
		FileOptions options = FileOptions();
		while (it.moveNext()) {
			switch (it.current.text) {
				case 'import':
					dependency.add(processImport(it));
					break;
				case 'enum':
					enumType.add(processEnum(it));
					break;
				case 'message':
					messageType.add(processMessage(it));
					break;
				case 'service':
					service.add(processService(it));
					break;
				case 'option':
					processOption(it, options);
					break;
				default:
					throw it.current.exception(filename, "unexpected identifer");
			}
		}

		return FileDescriptorProto(
				name: filename,
				package: package,
				dependency: dependency,
				messageType: messageType,
				enumType: enumType,
				service: service,
				extension: null,
				options: options,
				sourceCodeInfo: null,
				publicDependency: null,
				weakDependency: null,
				syntax: syntax,
		);
	}

	String processSyntax(Iterator<Token> it) {
		if (!it.moveNext() || it.current.text != 'syntax') {
			throw it.current.exception(filename, "expect syntax at top of file");
		}

		if (!it.moveNext() || it.current.text != '=') {
			throw it.current.exception(filename, "wrong syntax declaration");
		}

		if (!it.moveNext() || it.current.type != TokenType.string) {
			throw it.current.exception(filename, "wrong syntax declaration");
		}
		var syntax = it.current.text;

		if (!it.moveNext() || it.current.text != ';') {
			throw it.current.exception(filename, "expect ';'");
		}

		return syntax;
	}

	String processPackage(Iterator<Token> it) {
    // TODO process package with dot like org.mycompany.myapp.v1
		if (!it.moveNext() || it.current.text != 'package') {
			throw it.current.exception(filename, "expect package");
		}

		if (!it.moveNext() || it.current.type != TokenType.identifier) {
			throw it.current.exception(filename, "expect package name");
		}

		var package = it.current.text;
		if (!it.moveNext() || it.current.text != ';') {
			throw it.current.exception(filename, "expect ';'");
		}

		return package;
	}

	String processImport(Iterator<Token> it) {
		if (!it.moveNext()) {
			throw Exception("expect import name after 'import'");
		}

		var import = it.current.text;
		if (!it.moveNext() || it.current.text != ';') {
			throw Exception("expect ; after import declaration");
		}

		return import;
	}

	EnumDescriptorProto processEnum(Iterator<Token> it) {
		// TODO processEnum
		return EnumDescriptorProto();
	}

	DescriptorProto processMessage(Iterator<Token> it) {
		if (!it.moveNext()) {
			throw Exception("expect message name after 'message'");
		}

		var name = it.current.text;
		if (!it.moveNext() || it.current.text != '{') {
			throw Exception("expect { after opening message");
		}

		List<DescriptorProto> nestedType = [];
		List<EnumDescriptorProto> enumType = [];
		List<OneofDescriptorProto> oneofDecl = [];
		List<FieldDescriptorProto> field = [];
		
		while (it.moveNext() && it.current.text != '}') {
			switch (it.current.text) {
				case 'message':
					nestedType.add(processMessage(it));
					break;
				case 'enum':
					enumType.add(processEnum(it));
					break;
				case 'oneof':
					// TODO processOneof
					//oneof.add(processOneof(it));
					break;
				case 'option':
					// TODO processMessageOption
					//processMessageOption(it, options);
					break;
				default:
					field.add(processField(it));
			}
		}

		return DescriptorProto(
				name:name,
				field: field,
				nestedType: nestedType,
				enumType: enumType,
				oneofDecl: oneofDecl,
		);
	}

	ServiceDescriptorProto processService(Iterator<Token> it) {
		if (!it.moveNext()) {
			throw Exception("expect key name after 'service'");
		}
		var name = it.current.text;

		if (!it.moveNext() || it.current.text != '{') {
			throw Exception("expect { after opening service");
		}

		List<MethodDescriptorProto> method = [];
		ServiceOptions options = ServiceOptions();
		
		while (it.moveNext() && it.current.text != '}') {
			switch (it.current.text) {
				case 'rpc':
					method.add(processMethod(it));
					break;
				case 'option':
					//enumType.add(processEnum(it));
					break;
				default:
					throw Exception('service can only have rpc and option at:' + it.current.toString());
			}
		}

		return ServiceDescriptorProto(
				name:name,
				method: method,
				options: options,
		);
	}

	MethodDescriptorProto processMethod(Iterator<Token> it) {
		if (!it.moveNext()) {
			throw Exception("expect name after rpc");
		}
		var name = it.current.text;

		if (!it.moveNext() && it.current.text != '(' ) {
			throw Exception("expect ( rpc name");
		}

		if (!it.moveNext()) {
			throw Exception("expect identifier of input name");
		}

		var clientStreaming = false;
		if (it.current.text == 'stream') {
			clientStreaming = true;
			it.moveNext();
		}

		var inputType = it.current.text;
		if (!it.moveNext() && it.current.text != ')' ) {
			throw Exception("expect ) after inputType");
		}

		if (!it.moveNext() && it.current.text != 'returns' ) {
			throw Exception("expect returns for rpc");
		}

		if (!it.moveNext() && it.current.text != '(' ) {
			throw Exception("expect ( rpc name");
		}

		if (!it.moveNext() && it.current.type != TokenType.identifier ) {
			throw Exception("expect name of the outputType");
		}

		var serverStreaming = false;
		if (it.current.text == 'stream') {
			serverStreaming = true;
			it.moveNext();
		}

		var outputType = it.current.text;
		if (!it.moveNext() && it.current.text != ')' ) {
			throw Exception("expect ) after outputType");
		}

		if (!it.moveNext() && it.current.text != ';' ) {
			throw Exception("expect ; after for rpc");
		}
		// TODO try to support options in RPC

		return MethodDescriptorProto(
				name:name,
				inputType: inputType,
				outputType: outputType,
				clientStreaming: clientStreaming,
				serverStreaming: serverStreaming,
		);
	}

	FileOptions processOption(Iterator<Token> it, FileOptions opt) {
		if (!it.moveNext()) {
			throw Exception("expect key name after 'option'");
		}
		var key = it.current.text;

		if (!it.moveNext() || it.current.text != '=') {
			throw Exception("expect = after key options");
		}

		if (!it.moveNext()) {
			throw Exception("expect value for 'option'");
		}

		var value = it.current.text;
		if (!it.moveNext() || it.current.text != ';') {
			throw Exception("expect ; after import declaration");
		}

		switch(key) {
			case 'java_package':
				opt.javaPackage = value;
				break;
			case 'java_outer_classname':
				opt.javaOuterClassname = value;
				break;
			case 'java_multiple_files':
				opt.javaMultipleFiles = value == 'true';
				break;
			/* deprecated
			case 'java_generate_equals_and_hash':
				opt.javaGenerateEqualsAndHash = value == 'true';
				break;
			*/
			case 'java_string_check_utf8':
				opt.javaMultipleFiles = value == 'true';
				break;
			/* TODO need to parse enum
			case 'optimize_for':
			*/
			case 'go_package':
				opt.goPackage = value;
				break;
			case 'cc_generic_services':
				opt.ccGenericServices = value == 'true';
				break;
			case 'java_generic_services':
				opt.javaGenericServices = value == 'true';
				break;
			case 'py_generic_services':
				opt.pyGenericServices = value == 'true';
				break;

			case 'php_generic_services':
				opt.phpGenericServices = value == 'true';
				break;
			case 'deprecated':
				opt.deprecated = value == 'true';
				break;
			case 'cc_enable_arenas':
				opt.ccEnableArenas = value == 'true';
				break;
			case 'objc_class_prefix':
				opt.objcClassPrefix = value;
				break;
			case 'csharp_namespace':
				opt.csharpNamespace = value;
				break;
			case 'swift_prefix':
				opt.swiftPrefix = value;
				break;
			case 'php_class_prefix':
				opt.phpClassPrefix = value;
				break;
			case 'php_namespace':
				opt.phpNamespace = value;
				break;
			case 'php_metadata_namespace':
				opt.phpMetadataNamespace = value;
				break;
			case 'ruby_package':
				opt.rubyPackage = value;
				break;
			default:
		}

		return opt;
	}
	
	FieldDescriptorProto processField(Iterator<Token> it) {
		// how to token like this..
		// the last three should be 
		FieldDescriptorProto_Label? label;
		if (isModifier(it.current)) {
			label = processLabel(it.current);
			it.moveNext();
		}

		var typeName = it.current.text;
		var type = processType(it.current);
		if (!it.moveNext()) {
			throw Exception("expect name after typename");
		}

		var name = it.current.text;
		if (!it.moveNext() || it.current.text != '=') {
			throw Exception("expect = after field's name");
		}
		if (!it.moveNext()) {
			throw Exception("expect number for fields");
		}
		var number = int.parse(it.current.text);
		if (!it.moveNext() || it.current.text != ';') {
			throw Exception("expect ; after field declaration");
		}

		return FieldDescriptorProto(
				name: name, 
				number: number,
				type: type,
				typeName: typeName,
				label: label
		);
	}

	bool isModifier(Token token) {
		switch(token.text) {
			case 'optional':
			case 'required':
			case 'repeated':
				return true;
			default: 
				return false;
		}
	}

	FieldDescriptorProto_Label? processLabel(Token token) {
		switch(token.text) {
			case 'optional':
				return FieldDescriptorProto_Label.LABEL_OPTIONAL;
			case 'required':
				return FieldDescriptorProto_Label.LABEL_REQUIRED;
			case 'repeated':
				return FieldDescriptorProto_Label.LABEL_REPEATED;
			default: 
				return null;
		}

	}

	FieldDescriptorProto_Type processType(Token token) {
		switch(token.text) {
		case 'double':
			return FieldDescriptorProto_Type.TYPE_DOUBLE;
		case 'float':
			return FieldDescriptorProto_Type.TYPE_FLOAT;
		case 'int64':
			return FieldDescriptorProto_Type.TYPE_INT64;
		case 'uint64':
			return FieldDescriptorProto_Type.TYPE_UINT64;
		case 'int32':
			return FieldDescriptorProto_Type.TYPE_INT32;
		case 'fixed64':
			return FieldDescriptorProto_Type.TYPE_FIXED64;
		case 'fixed32':
			return FieldDescriptorProto_Type.TYPE_FIXED32;
		case 'bool':
			return FieldDescriptorProto_Type.TYPE_BOOL;
		case 'string':
			return FieldDescriptorProto_Type.TYPE_STRING;
		case 'group':
			return FieldDescriptorProto_Type.TYPE_GROUP;
		case 'bytes':
			return FieldDescriptorProto_Type.TYPE_BYTES;
		case 'uint32':
			return FieldDescriptorProto_Type.TYPE_UINT32;
		case 'sfixed32':
			return FieldDescriptorProto_Type.TYPE_SFIXED32;
		case 'sfixed64':
			return FieldDescriptorProto_Type.TYPE_SFIXED64;
		case 'sint32':
			return FieldDescriptorProto_Type.TYPE_SINT32;
		case 'sint64':
			return FieldDescriptorProto_Type.TYPE_SINT64;
		default:
			return FieldDescriptorProto_Type.TYPE_MESSAGE;
		}
		//return FieldDescriptorProto_Type.TYPE_ENUM;
	}
}
