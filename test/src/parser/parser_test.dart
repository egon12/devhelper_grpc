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

    while (tokenizer.next()) {
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

    expect(fdp.service[0].writeToJson(),
        '{"1":"Hello","2":[{"1":"Hello","2":"Request","3":"Response","5":false,"6":false}],"3":{}}');
  });

  test('test package with dot', () {
    var filepath = './lib/proto/nested.proto';

    var input = File(filepath).readAsStringSync();
    var tokenizer = Tokenizer(input: input);
    tokenizer.reportNewlines = false;
    List<Token> tokens = [];

    tokens.add(tokenizer.current()!);

    while (tokenizer.next()) {
      tokens.add(tokenizer.current()!);
    }

    var parser = Parser();
    Iterator<Token> it = tokens.iterator;
    var fdp = parser.file("nested.proto", it);

    expect(fdp.package, 'org.egon12.proto');
  });

  test('parse enum', () {
    var filepath = './lib/proto/nested.proto';

    var input = File(filepath).readAsStringSync();
    var tokenizer = Tokenizer(input: input);
    tokenizer.reportNewlines = false;
    List<Token> tokens = [];

    tokens.add(tokenizer.current()!);

    while (tokenizer.next()) {
      tokens.add(tokenizer.current()!);
    }

    var parser = Parser();
    Iterator<Token> it = tokens.iterator;
    var fdp = parser.file("nested.proto", it);

    expect(fdp.enumType[0].name, 'Color');
    expect(fdp.enumType[0].value[0].name, 'RED');
    expect(fdp.enumType[0].value[0].number, 0);

    expect(fdp.enumType[0].value[1].name, 'GREEN');
    expect(fdp.enumType[0].value[1].number, 1);

    expect(fdp.enumType[0].value[2].name, 'BLUE');
    expect(fdp.enumType[0].value[2].number, 2);
  });

  test('parse nested enum', () {
    var filepath = './lib/proto/nested.proto';

    var input = File(filepath).readAsStringSync();
    var tokenizer = Tokenizer(input: input);
    tokenizer.reportNewlines = false;
    List<Token> tokens = [];

    tokens.add(tokenizer.current()!);

    while (tokenizer.next()) {
      tokens.add(tokenizer.current()!);
    }

    var parser = Parser();
    Iterator<Token> it = tokens.iterator;
    var fdp = parser.file("nested.proto", it);

    expect(fdp.messageType[3].enumType[0].name, 'Live');
    expect(fdp.messageType[3].enumType[0].value[0].name, 'ALIVE');
    expect(fdp.messageType[3].enumType[0].value[1].name, 'DEAD');
  });
}
