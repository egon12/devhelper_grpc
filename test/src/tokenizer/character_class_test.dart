import 'package:test/test.dart';
import 'package:devhelper_grpc/src/tokenizer/character_class.dart';

void main() {
	test('Whitespace inClass', () {
		expect(Whitespace().inClass(' '), true);
	});

	test('WhitespaceNoNewLine inClass', () {
		expect(WhitespaceNoNewline().inClass('\n'), false);
		expect(WhitespaceNoNewline().inClass(' '), true);
	});

	test('Unprintable inClass', () {
		expect(Unprintable().inClass('\x01'), true);
		expect(Unprintable().inClass('a'), false);
	});

	test('Digit inClass', () {
		expect(Digit().inClass('1'), true);
		expect(Digit().inClass('2'), true);
		expect(Digit().inClass('9'), true);
		expect(Digit().inClass('a'), false);
		expect(Digit().inClass('A'), false);
	});

	test('OctalDigit inClass', () {
		expect(OctalDigit().inClass('1'), true);
		expect(OctalDigit().inClass('2'), true);
		expect(OctalDigit().inClass('8'), false);
		expect(OctalDigit().inClass('9'), false);
		expect(OctalDigit().inClass('a'), false);
		expect(OctalDigit().inClass('A'), false);
	});

	test('HexDigit inClass', () {
		expect(HexDigit().inClass('1'), true);
		expect(HexDigit().inClass('9'), true);
		expect(HexDigit().inClass('a'), true);
		expect(HexDigit().inClass('A'), true);
		expect(HexDigit().inClass('f'), true);
		expect(HexDigit().inClass('F'), true);
		expect(HexDigit().inClass('g'), false);
		expect(HexDigit().inClass('G'), false);
		expect(HexDigit().inClass('z'), false);
		expect(HexDigit().inClass('Z'), false);
	});

	test('Letter inClass', () {
		expect(Letter().inClass('1'), false);
		expect(Letter().inClass('9'), false);
		expect(Letter().inClass('a'), true);
		expect(Letter().inClass('A'), true);
		expect(Letter().inClass('f'), true);
		expect(Letter().inClass('F'), true);
		expect(Letter().inClass('g'), true);
		expect(Letter().inClass('G'), true);
		expect(Letter().inClass('z'), true);
		expect(Letter().inClass('Z'), true);
		expect(Letter().inClass('_'), true);
	});

	test('CharacterClass', () {
		var got = testGetFirstString(Whitespace(), ' hello');
		expect(got, true);
	});
}

bool testGetFirstString(CharacterClass cc, String str) {
	return cc.inClass(str[0]);
}
