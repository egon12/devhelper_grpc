import 'package:flutter_test/flutter_test.dart';
import 'package:devhelper_grpc/src/tokenizer/tokenizer.dart';
import 'package:devhelper_grpc/src/tokenizer/token.dart';
import 'package:devhelper_grpc/src/tokenizer/token_type.dart';
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
    var tokenizer = Tokenizer(input: ' something in here\nand not this');
    var buffer = StringBuffer();
    tokenizer.consumeLineComment(buffer);
    expect(buffer.toString(), ' something in here\n');
  });

  test('consumeLineComment eof', () {
    var tokenizer = Tokenizer(input: ' something in here');
    var buffer = StringBuffer();
    tokenizer.consumeLineComment(buffer);
    expect(buffer.toString(), ' something in here');
  }, skip: 'double write in nextChar and stopRecording()');

  test('consumeBlockComment', () {
    var tokenizer = Tokenizer(
        input: '/* something \nin \nhere\n*/ this should be not consumed');
    var buffer = StringBuffer();
    tokenizer.consumeBlockComment(buffer);
    expect(buffer.toString(), '/* something \nin \nhere\n');
  });

  test('complete', () {
    var tokenizer = Tokenizer(input: completeInput2);
    tokenizer.reportNewlines = false;
    List<Token> tokens = tokenizer.toList();

    expect(tokens[1].text, 'syntax');
    expect(tokens[1].type, TokenType.identifier);

    expect(tokens[5].text, 'package');
    expect(tokens[5].type, TokenType.identifier);

    expect(tokens[6].text, 'org');
    expect(tokens[6].type, TokenType.identifier);

    expect(tokens[7].text, '.');
    expect(tokens[7].type, TokenType.symbol);
  });
}

const completeInput1 = '''
optional int32 foo = 1;  // Comment attached to foo.
// Comment attached to bar.
optional int32 bar = 2;

optional string baz = 3;
// Comment attached to baz.
// Another line attached to baz.

// Comment attached to qux.
//
// Another line attached to qux.
optional double qux = 4;

// Detached comment.  This is not attached to qux or corge
// because there are blank lines separating it from both.

optional string corge = 5;
/* Block comment attached
 * to corge.  Leading asterisks
 * will be removed. */
/* Block comment attached to
 * grault. */
optional int32 grault = 6;
''';

const completeInput2 = '''
/**
  Some comment in the file
*/
syntax = "proto3";

package org.mypackage.test;

message Empty {}

service Hello {
	rpc hello(Empty) returns Empty;
}
''';
