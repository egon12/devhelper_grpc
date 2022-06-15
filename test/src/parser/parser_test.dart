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

		print(fdp.messageType);
		print(fdp.service);
		
	});
}
