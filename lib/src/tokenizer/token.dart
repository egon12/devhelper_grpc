import './token_type.dart';

class Token implements StringSink {
	final StringBuffer _buffer = StringBuffer();

	late TokenType type= TokenType.start;
	int line;
	int colStart;
	int colEnd;

	Token({
		this.type = TokenType.start ,
		this.line = 0,
		this.colStart = 0,
		this.colEnd = 0,
	});

	String get text {
		return _buffer.toString();
	}

	@override
	void write(Object? obj) {
		_buffer.write(obj);
	}

	@override
	void writeAll(Iterable objects, [String separator = ""]) {
		_buffer.writeAll(objects, separator);
		_buffer.writeCharCode(10);
	}

	@override
	void writeCharCode(int charCode) {
		_buffer.writeCharCode(charCode);
	}

	@override
	void writeln([Object? object = ""]) {
		_buffer.writeln(object);
	}

	@override
	String toString() {
		return "Token: $type [$line:$colStart-$colEnd] $text";
	}

	String toErrorString(String cause) {
		return "$line : $cause at $colStart-$colEnd ($text)";
	}

	Exception exception(String filename, String cause) {
		var err = toErrorString(cause);
		return Exception("$filename:$err");
	}
}
