import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:devhelper_grpc/src/tokenizer/tokenizer.dart';
import 'package:devhelper_grpc/src/tokenizer/token.dart';

void main() {
	test('test the parser', () {
		var filepath = './lib/proto/reflection.proto';

		var input = File(filepath).readAsStringSync();
		var tokenizer = Tokenizer(input: input);
		List<Token> tokens = [];

		//tokens.add(tokenizer.current()!);

		while(tokenizer.next()) {
			tokens.add(tokenizer.current()!);
		}
		
		print(tokens);
	});
}
