import './character_class.dart';
import './token.dart';
import './token_type.dart';

const kTabWidth = 8;

class Tokenizer {

	final String input;
	final int _size;

	final bool _allowMultilineStrings = true;
	final bool _allowFAfterFloat = false;
	final bool _requireSpaceAfterNumber = true;
	

	String _currentChar;
	int _pos;
	int _line;
	int _column;
	bool _readError;

	StringSink? _recordTarget;
	int _recordStart;

	Token? _current;
	//Token? _previous;

	Tokenizer({required this.input}): 
		_pos = 0, _line = 0, _column = 0, _currentChar = input[0], _size = input.length, _readError = false,
		_recordTarget = null,  _recordStart = 0;


	void nextChar() {
		// Update our line and column counters based on the character being
		// consumed.
		if (_currentChar == '\n') {
			_line += 1;
			_column = 0;
		} else if (_currentChar == '\t') {
			_column += kTabWidth - _column % kTabWidth;
		} else {
			_column += 1;
		}

		// Advance to the next character.
		_pos += 1;
		if (_pos < _size) {
			_currentChar = input[_pos];
		} else {
			refresh();
		}
	}

	void refresh() {
		if (_readError) {
			_currentChar = '\x00';
			return;
		}

		// If we're in a token, append the rest of the buffer to it.
		if (_recordTarget != null && _recordStart < _size) {
			_recordTarget!.write(input.substring(_recordStart));
			_recordStart = 0;
		}

		//_pos = 0;
		//_currentChar = input[_pos];
		/*
		   const void* data = NULL;
		   buffer_ = NULL;
		   buffer_pos_ = 0;
		   do {
		   if (!input_->Next(&data, &buffer_size_)) {
		// end of stream (or read error)
		buffer_size_ = 0;
		read_error_ = true;
		_currentChar = '\0';
		return;
		}
		} while (buffer_size_ == 0);

		buffer_ = static_cast<const char*>(data);

		_currentChar = buffer_[0];
		*/
	}


	void recordTo(StringSink? target) {
		_recordTarget = target;
		_recordStart = _pos;
	}


	void stopRecording() {
		// Note:  The if() is necessary because some STL implementations crash when
		//   you call string::append(NULL, 0), presumably because they are trying to
		//   be helpful by detecting the NULL pointer, even though there's nothing
		//   wrong with reading zero bytes from NULL.
		if (_pos != _recordStart) {
			_recordTarget?.write(input.substring(_recordStart, _pos));
		}
		_recordTarget = null;
		_recordStart = -1;
	}

	void startToken() {
		_current = Token( line: _line, colStart: _column);
		recordTo(_current);
	}

	void endToken() {
		stopRecording();
		_current?.colEnd = _column;
	}

	// =================================
	// charclass function

	bool lookingAt(CharacterClass c) {
		return c.inClass(_currentChar); 
	}


	bool tryConsumeOne(CharacterClass c) {
		if (c.inClass(_currentChar)) {
			nextChar();
			return true;
		} else {
			return false;
		}
	}

	bool tryConsume(String c) {
		if (_currentChar == c) {
			nextChar();
			return true;
		} else {
			return false;
		}
	}

	void consumeZeroOrMore(CharacterClass c) {
		while (c.inClass(_currentChar)) {
			nextChar();
		}
	}

	void consumeOneOrMore(CharacterClass c, String error) {
		if (!c.inClass(_currentChar)) {
			addError(error);
		} else {
			do {
				nextChar();
			} while (c.inClass(_currentChar));
		}
	}

	// ==========
	// consume more larger than life


	void consumeString(String delimiter) {
		while (true) {
			switch (_currentChar) {
				case '\x00':
					addError("Unexpected end of string.");
					return;

				case '\n': {
					if (!_allowMultilineStrings) {
						addError("String literals cannot cross line boundaries.");
						return;
					}
					nextChar();
					break;
				}

				case '\\': {
					// An escape sequence.
					nextChar();
					if (tryConsumeOne(Escape())) {
						// Valid escape sequence.
					} else if (tryConsumeOne(OctalDigit())) {
						// Possibly followed by two more octal digits, but these will
						// just be consumed by the main loop anyway so we don't need
						// to do so explicitly here.
					} else if (tryConsume('x')) {
						if (!tryConsumeOne(HexDigit())) {
							addError("Expected hex digits for escape sequence.");
						}
						// Possibly followed by another hex digit, but again we don't care.
					} else if (tryConsume('u')) {
						if (!tryConsumeOne(HexDigit()) || !tryConsumeOne(HexDigit()) ||
								!tryConsumeOne(HexDigit()) || !tryConsumeOne(HexDigit())) {
							addError("Expected four hex digits for \\u escape sequence.");
						}
					} else if (tryConsume('U')) {
						// We expect 8 hex digits; but only the range up to 0x10ffff is
						// legal.
						if (!tryConsume('0') || !tryConsume('0') ||
								!(tryConsume('0') || tryConsume('1')) ||
								!tryConsumeOne(HexDigit()) || !tryConsumeOne(HexDigit()) ||
								!tryConsumeOne(HexDigit()) || !tryConsumeOne(HexDigit()) ||
								!tryConsumeOne(HexDigit())) {
							addError(
									"Expected eight hex digits up to 10ffff for \\U escape "
									"sequence");
						}
					} else {
						addError("Invalid escape sequence in string literal.");
					}
					break;
				}

				default: {
					if (_currentChar == delimiter) {
						nextChar();
						return;
					}
					nextChar();
					break;
				}
			}
		}
	}

	TokenType consumeNumber(bool startedWithZero, bool startedWithDot) {
		bool is_float = false;

		if (startedWithZero && (tryConsume('x') || tryConsume('X'))) {
			// A hex number (started with "0x").
			consumeOneOrMore(HexDigit(), "\"0x\" must be followed by hex digits.");
		} else if (startedWithZero && lookingAt(Digit())) {
			// An octal number (had a leading zero).
			consumeZeroOrMore(OctalDigit());
			if (lookingAt(Digit())) {
				addError("Numbers starting with leading zero must be in octal.");
				consumeZeroOrMore(Digit());
			}

		} else {
			// A decimal number.
			if (startedWithDot) {
				is_float = true;
				consumeZeroOrMore(Digit());
			} else {
				consumeZeroOrMore(Digit());

				if (tryConsume('.')) {
					is_float = true;
					consumeZeroOrMore(Digit());
				}
			}

			if (tryConsume('e') || tryConsume('E')) {
				is_float = true;
				tryConsume('-') || tryConsume('+');
				consumeOneOrMore(Digit(), "\"e\" must be followed by exponent.");
			}

			if (_allowFAfterFloat && (tryConsume('f') || tryConsume('F'))) {
				is_float = true;
			}
		}

		if (lookingAt(Letter()) && _requireSpaceAfterNumber) {
			addError("Need space between number and identifier.");
		} else if (_currentChar == '.') {
			if (is_float) {
				addError(
						"Already saw decimal point or exponent; can't have another one.");
			} else {
				addError("Hex and octal numbers must be integers.");
			}
		}

		return is_float ? TokenType.TYPE_FLOAT : TokenType.TYPE_INTEGER;
	}

	void consumeLineComment(StringSink? content) {
		if (content != null) recordTo(content);

		while (_currentChar != '\x00' && _currentChar != '\n') {
			nextChar();
		}
		tryConsume('\n');

		if (content != null) stopRecording();
	}

	void addError(String error) {
		print(error);
	}



}
