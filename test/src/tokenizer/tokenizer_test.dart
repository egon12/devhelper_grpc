import 'package:flutter_test/flutter_test.dart';
import 'package:devhelper_grpc/src/tokenizer/tokenizer.dart';
import 'package:devhelper_grpc/src/tokenizer/character_class.dart';

void main() {
	test('lookingAt and nextChar', () {
		var tokenizer = Tokenizer(input: ' something in here');
		var got = tokenizer.lookingAt(Whitespace());
		expect(true, got);
		tokenizer.nextChar();
		got = tokenizer.lookingAt(Letter());
		expect(true, got);
	});

	test('recordTo and stopRecording', () {
		var t = Tokenizer(input: 'recordThis and ignore this');
		var buf = StringBuffer();
		t.recordTo(buf);
		t.consumeOneOrMore(Letter(), "some error");
		t.stopRecording();
		expect(buf.toString(), "recordThis");
	});

	test('consumeString', () {
		var t = Tokenizer(input: '"You need\nto \\"record\\" this" but not this');
		t.nextChar();
		var buf = StringBuffer();
		t.recordTo(buf);
		t.consumeString('"');
		t.stopRecording();
		expect(buf.toString(), 'You need\nto \\"record\\" this"');
	});

	test('consumeLineComment', () {
		var tokenizer = Tokenizer(input: ' something in here');
		var buffer = StringBuffer();
		tokenizer.consumeLineComment(buffer);
		expect(buffer.toString(), "");
	}, skip: 'forever loop');
}

