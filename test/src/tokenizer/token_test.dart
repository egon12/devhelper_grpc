import 'package:flutter_test/flutter_test.dart';
import 'package:devhelper_grpc/src/tokenizer/token.dart';
import 'package:devhelper_grpc/src/tokenizer/record_target.dart';

void main() {
	test('test recordTarget', () {
		var t = Token();

		var f = FakeRecordTargetWriter();
		f.recordTo(t);
		f.write('hello');
		f.write(' world!');

		expect('hello world!', t.text);
	});
}

class FakeRecordTargetWriter {
	StringSink? _rt;

	void recordTo(StringSink? rt) {
		_rt = rt;
	}

	void write(String s) {
		_rt?.write(s);
	}
}
