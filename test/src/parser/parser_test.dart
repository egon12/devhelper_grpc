import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:devhelper_grpc/src/tokenizer/tokenizer.dart';
import 'package:devhelper_grpc/src/tokenizer/token.dart';
import 'package:devhelper_grpc/src/parser/parser.dart';

void main() {
	test('test the parser', () {
		var filepath = './lib/proto/hello.proto';

		var input = File(filepath).readAsStringSync();
		var tokenizer = Tokenizer(input: input);
		tokenizer.reportNewlines = false;
		List<Token> tokens = [];

		tokens.add(tokenizer.current()!);

		while(tokenizer.next()) {
			tokens.add(tokenizer.current()!);
		}

		var parser = Parser();
		Iterator<Token> it = tokens.iterator;
		var fdp = parser.file("hello.proto", it);

		expect(fdp.package, 'myhello');

		expect(
				fdp.messageType[1].writeToJson(),
				'{"1":"Response","2":[{"1":"message","3":1,"5":9,"6":"string"},{"1":"count","3":2,"5":3,"6":"int64"}]}',
		);

		expect(
				fdp.service[0].writeToJson(),
				'{"1":"Hello","2":[{"1":"Hello","2":"Request","3":"Response","5":false,"6":false}],"3":{}}'
		);
	});
}
