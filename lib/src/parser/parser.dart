import '../tokenizer/token.dart';
import '../tokenizer/token_type.dart';
import '../../proto/descriptor.pb.dart';


class Parser {
	List<Token> tokens = [];

	FileDescriptorSet fds = FileDescriptorSet();

	DescriptorProto? currentMessage;

	

	void process() {
		var it = tokens.iterator;

		bool isMoreThanZero = it.moveNext();
		if (!isMoreThanZero) {
			// TODO empty file;
			return;
		}

		while (it.moveNext()) {
			var token = it.current;
			if (token.type != TokenType.identifier) {
				continue;
			}

			if (token.text == 'message') {
				processMessage(it);
			}
		}
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
