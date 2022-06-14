import '../tokenizer/token.dart';
import '../tokenizer/token_type.dart';
import '../../proto/descriptor.pb.dart';


class Parser {
	List<Token> tokens = [];

	FileDescriptorSet fds = FileDescriptorSet();

	DescriptorProto? currentMessage;

	FileDescriptorProto _file(String filename, Iterator<Token> it) {
		// expect first to be start
		if (it.current.type != TokenType.start) {
			throw Exception("expect start type token");
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
					throw Exception('unexpected ${it.current.text}');
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
			throw Exception("expect syntax at the top of file");
		}

		if (!it.moveNext() || it.current.text != '=') {
			throw Exception("expect syntax = 'proto3' at the top of file");
		}

		if (!it.moveNext() || it.current.type != TokenType.identifier) {
			throw Exception("expect syntax = 'proto3' at the top of file");
		}
		var syntax = it.current.text;

		if (!it.moveNext() || it.current.text != ';') {
			throw Exception("expect ; after syntax declaration");
		}

		return syntax;
	}

	String processPackage(Iterator<Token> it) {
		if (!it.moveNext() || it.current.text != 'package') {
			throw Exception("expect package at the top of file");
		}

		if (!it.moveNext()) {
			throw Exception("expect package name after 'package'");
		}

		var package = it.current.text;
		if (!it.moveNext() || it.current.text != ';') {
			throw Exception("expect ; after package declaration");
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
		// TODO process this one
		return EnumDescriptorProto();
	}

	DescriptorProto processMessage(Iterator<Token> it) {
		if (!it.moveNext()) {
			throw Exception("expect import name after 'import'");
		}

		var import = it.current.text;
		if (!it.moveNext() || it.current.text != ';') {
			throw Exception("expect ; after import declaration");
		}

		return import;

	}
	

	void processMessage(Iterator<Token> it) {
		currentMessage = DescriptorProto();

		// move next to get name
		it.moveNext();
		var name = it.current.text;

		// move next to get open curly bracket {
		it.moveNext();

		// TODO think should we process new line
		processInnerMessage(it);
	}

	void processInnerMessage(Iterator<Token> it) {
		var msg = currentMessage;
		if (msg == null) {
			return;
		}
		msg.field = [];
		msg.field.add(processField(it));
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
		it.moveNext();
		var name = it.current.text;
		it.moveNext(); // for symbol =
		it.moveNext(); // for number
		var number = int.parse(it.current.text);
		it.moveNext(); // for symbol ;

		return FieldDescriptorProto(
				name: name, 
				number: number,
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

}
