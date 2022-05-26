import 'package:flutter_test/flutter_test.dart';
import 'package:devhelper_grpc/src/tokenizer/tokenizer.dart';
import 'package:devhelper_grpc/src/tokenizer/character_class.dart';

void main() {
	test('test lookingAt and nextChar', () {
		var tokenizer = Tokenizer(input: ' something in here');
		var got = tokenizer.lookingAt(Whitespace());
		expect(true, got);
		tokenizer.nextChar();
		got = tokenizer.lookingAt(Letter());
		expect(true, got);
	});

	test('try to concat string first', () {
		var word = "hello";

		var hello=  "hello world!";

		word += hello.substring(5);
		expect('hello world!', word);
	});
}

