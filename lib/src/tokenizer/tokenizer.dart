import './character_class.dart';
import './token.dart';
import './token_type.dart';

const kTabWidth = 8;

class Tokenizer {

	final String input;
	final int _size;

	String _currentChar;
	int _pos;
	int _line;
	int _column;
	bool _readError;

	String _recordTarget;
	int _recordStart;
	bool _onRecord;

	Token? _current;
	//Token? _previous;

	Tokenizer({required this.input}): 
		_pos = 0, _line = 0, _column = 0, _currentChar = input[0], _size = input.length, _readError = false,
		_recordTarget = '', _onRecord = false, _recordStart = 0;




	void nextChar() {
		// Update our line and column counters based on the character being
		// consumed.
		if (_currentChar == '\n') {
			++_line;
			_column = 0;
		} else if (_currentChar == '\t') {
			_column += kTabWidth - _column % kTabWidth;
		} else {
			++_column;
		}

		// Advance to the next character.
		++_pos;
		if (_pos < _size) {
			_currentChar = input[_pos];
		} else {
			refresh();
		}
	}

	void refresh() {
		if (_readError) {
			_currentChar = '\0';
			return;
		}

		// If we're in a token, append the rest of the buffer to it.
		if (_onRecord && _recordStart < _size) {
			_recordTarget += input.substring(_recordStart);
			_recordStart = 0;
		}

		_pos = 0;
		_currentChar = input[_pos];
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


	void recordTo(String target) {
		_onRecord = true;
		_recordTarget = target;
		_recordStart = _pos;
	}


	void stopRecording() {
		// Note:  The if() is necessary because some STL implementations crash when
		//   you call string::append(NULL, 0), presumably because they are trying to
		//   be helpful by detecting the NULL pointer, even though there's nothing
		//   wrong with reading zero bytes from NULL.
		if (_pos != _recordStart) {
			_recordTarget += input.substring(_recordStart, _pos);
		}
		_onRecord = false;
		_recordTarget = '';
		_recordStart = -1;
	}

	void startToken() {
		_current = Token( line: _line, colStart: _column);
		recordTo(_current?.text ?? '');
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
			//AddError(error);
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
					if (!allow_multiline_strings_) {
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

	TokenType consumeNumber(bool started_with_zero, bool started_with_dot) {
		bool is_float = false;

		if (started_with_zero && (tryConsume('x') || tryConsume('X'))) {
			// A hex number (started with "0x").
			consumeOneOrMore<HexDigit>("\"0x\" must be followed by hex digits.");

		} else if (started_with_zero && LookingAt<Digit>()) {
			// An octal number (had a leading zero).
			consumeZeroOrMore(OctalDigit());
			if (lookingAt<Digit>()) {
				addError("Numbers starting with leading zero must be in octal.");
				consumeZeroOrMore<Digit>();
			}

		} else {
			// A decimal number.
			if (started_with_dot) {
				is_float = true;
				ConsumeZeroOrMore<Digit>();
			} else {
				ConsumeZeroOrMore<Digit>();

				if (TryConsume('.')) {
					is_float = true;
					ConsumeZeroOrMore<Digit>();
				}
			}

			if (TryConsume('e') || TryConsume('E')) {
				is_float = true;
				TryConsume('-') || TryConsume('+');
				ConsumeOneOrMore<Digit>("\"e\" must be followed by exponent.");
			}

			if (allow_f_after_float_ && (TryConsume('f') || TryConsume('F'))) {
				is_float = true;
			}
		}

		if (LookingAt<Letter>() && require_space_after_number_) {
			AddError("Need space between number and identifier.");
		} else if (current_char_ == '.') {
			if (is_float) {
				AddError(
						"Already saw decimal point or exponent; can't have another one.");
			} else {
				AddError("Hex and octal numbers must be integers.");
			}
		}

		return is_float ? TYPE_FLOAT : TYPE_INTEGER;
	}

	void Tokenizer::ConsumeLineComment(std::string* content) {
		if (content != NULL) RecordTo(content);

		while (current_char_ != '\0' && current_char_ != '\n') {
			NextChar();
		}
		TryConsume('\n');

		if (content != NULL) StopRecording();
	}

	void Tokenizer::ConsumeBlockComment(std::string* content) {
		int start_line = line_;
		int start_column = column_ - 2;

		if (content != NULL) RecordTo(content);

		while (true) {
			while (current_char_ != '\0' && current_char_ != '*' &&
					current_char_ != '/' && current_char_ != '\n') {
				NextChar();
			}

			if (TryConsume('\n')) {
				if (content != NULL) StopRecording();

				// Consume leading whitespace and asterisk;
				ConsumeZeroOrMore<WhitespaceNoNewline>();
				if (TryConsume('*')) {
					if (TryConsume('/')) {
						// End of comment.
						break;
					}
				}

				if (content != NULL) RecordTo(content);
			} else if (TryConsume('*') && TryConsume('/')) {
				// End of comment.
				if (content != NULL) {
					StopRecording();
					// Strip trailing "*/".
					content->erase(content->size() - 2);
				}
				break;
			} else if (TryConsume('/') && current_char_ == '*') {
				// Note:  We didn't consume the '*' because if there is a '/' after it
				//   we want to interpret that as the end of the comment.
				AddError(
						"\"/*\" inside block comment.  Block comments cannot be nested.");
			} else if (current_char_ == '\0') {
				AddError("End-of-file inside block comment.");
				error_collector_->AddError(start_line, start_column,
						"  Comment started here.");
				if (content != NULL) StopRecording();
				break;
			}
		}
	}

	Tokenizer::NextCommentStatus Tokenizer::TryConsumeCommentStart() {
		if (comment_style_ == CPP_COMMENT_STYLE && TryConsume('/')) {
			if (TryConsume('/')) {
				return LINE_COMMENT;
			} else if (TryConsume('*')) {
				return BLOCK_COMMENT;
			} else {
				// Oops, it was just a slash.  Return it.
				current_.type = TYPE_SYMBOL;
				current_.text = "/";
				current_.line = line_;
				current_.column = column_ - 1;
				current_.end_column = column_;
				return SLASH_NOT_COMMENT;
			}
		} else if (comment_style_ == SH_COMMENT_STYLE && TryConsume('#')) {
			return LINE_COMMENT;
		} else {
			return NO_COMMENT;
		}
	}

	bool Tokenizer::TryConsumeWhitespace() {
		if (report_newlines_) {
			if (TryConsumeOne<WhitespaceNoNewline>()) {
				ConsumeZeroOrMore<WhitespaceNoNewline>();
				current_.type = TYPE_WHITESPACE;
				return true;
			}
			return false;
		}
		if (TryConsumeOne<Whitespace>()) {
			ConsumeZeroOrMore<Whitespace>();
			current_.type = TYPE_WHITESPACE;
			return report_whitespace_;
		}
		return false;
	}

	bool Tokenizer::TryConsumeNewline() {
		if (!report_whitespace_ || !report_newlines_) {
			return false;
		}
		if (TryConsume('\n')) {
			current_.type = TYPE_NEWLINE;
			return true;
		}
		return false;
	}

	void addError(String error) {
		print(error);
	}


}
