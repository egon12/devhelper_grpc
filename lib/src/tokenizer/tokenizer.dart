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

	final ErrorCollector _errorCollector = ErrorCollector();

	final CommentStyle _commentStyle = CommentStyle.cpp;

	String _currentChar;
	int _pos;
	int _line;
	int _column;
	bool _readError;

	bool _reportWhitespace = false;
	
	bool _reportNewlines = true;

	StringSink? _recordTarget;
	int _recordStart;

	Token? _current;
	Token? _previous;

	Tokenizer({required this.input}): 
		_pos = 0, _line = 0, _column = 0, _currentChar = input[0], _size = input.length, _readError = false,
		_recordTarget = null,  _recordStart = 0;


	Token? current() { return _current; }
	Token? previous() { return _previous; }

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
			_currentChar = '\x00'; 
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

		return is_float ? TokenType.float : TokenType.integer;
	}

	void consumeLineComment(StringSink? content) {
		if (content != null) recordTo(content);

		while (_currentChar != '\x00' && _currentChar != '\n') {
			nextChar();
		}
		tryConsume('\n');

		if (content != null) stopRecording();
	}

	void consumeBlockComment(StringSink? content) {
		int startLine = _line;
		int startColumn = _column - 2;

		if (content != null) recordTo(content);

		while (true) {
			while (_currentChar != '\x00' && _currentChar != '*' &&
					_currentChar != '/' && _currentChar != '\n') {
				nextChar();
			}

			if (tryConsume('\n')) {
				if (content != null) stopRecording();

				// Consume leading whitespace and asterisk;
				consumeZeroOrMore(WhitespaceNoNewline());
				if (tryConsume('*')) {
					if (tryConsume('/')) {
						// End of comment.
						break;
					}
				}

				if (content != null) recordTo(content);
			} else if (tryConsume('*') && tryConsume('/')) {
				// End of comment.
				if (content != null) {
					stopRecording();
					// Strip trailing "*/".
					// TODO is it possible to delete from StringSink
					//content->erase(content->size() - 2);
				}
				break;
			} else if (tryConsume('/') && _currentChar == '*') {
				// Note:  We didn't consume the '*' because if there is a '/' after it
				//   we want to interpret that as the end of the comment.
				addError(
						"\"/*\" inside block comment.  Block comments cannot be nested.");
			} else if (_currentChar == '\x00') {
				addError("End-of-file inside block comment.");
				_errorCollector.addError(startLine, startColumn,
						"  Comment started here.");
				if (content != null) stopRecording();
				break;
			}
		}
	}

	// If we're at the start of a new comment, consume it and return what kind
	// of comment it is.
	NextCommentStatus tryConsumeCommentStart() {
		if (_commentStyle == CommentStyle.cpp && tryConsume('/')) {
			if (tryConsume('/')) {
				return NextCommentStatus.lineComment;
			} else if (tryConsume('*')) {
				return NextCommentStatus.blockComment;
			} else {
				// Oops, it was just a slash.  Return it.
				_current?.type = TokenType.symbol;
				_current?.write("/");
				_current?.line = _line;
				_current?.colStart = _column - 1;
				_current?.colEnd = _column;
				return NextCommentStatus.slashNotComment;
			}
		} else if (_commentStyle == CommentStyle.sh && tryConsume('#')) {
			return NextCommentStatus.lineComment;
		} else {
			return NextCommentStatus.noComment;
		}
	}

	bool tryConsumeWhitespace() {
		if (_reportNewlines) {
			if (tryConsumeOne(WhitespaceNoNewline())) {
				consumeZeroOrMore(WhitespaceNoNewline());
				_current?.type = TokenType.whitespace;
				return _reportWhitespace;
			}
			return false;
		}
		if (tryConsumeOne(Whitespace())) {
			consumeZeroOrMore(Whitespace());
			_current?.type = TokenType.whitespace;
			return _reportWhitespace;
		}
		return false;
	}

	bool tryConsumeNewline() {
		//if (!_reportWhitespace || !_reportNewlines) {
		//	return false;
		//}

		if (_reportNewlines && tryConsume('\n')) {
			_current?.type = TokenType.newline;
			return true;
		}

		return false;
	}

	bool next() {
		_previous = _current;

		while (!_readError) {
			startToken();
			bool reportToken = tryConsumeWhitespace() || tryConsumeNewline();
			endToken();
			if (reportToken) {
				print("reportWhitespaceToken: $reportToken"); 
				return true;
			}

			switch (tryConsumeCommentStart()) {
				case NextCommentStatus.lineComment:
					consumeLineComment(null);
					continue;
				case NextCommentStatus.blockComment:
					consumeBlockComment(null);
					continue;
				case NextCommentStatus.slashNotComment:
					return true;
				case NextCommentStatus.noComment:
					break;
			}

			// Check for EOF before continuing.
			if (_readError) break;

			if (lookingAt(Unprintable()) || _currentChar == '\x00') {
				addError("Invalid control characters encountered in text.");
				nextChar();
				// Skip more unprintable characters, too.  But, remember that '\0' is
				// also what current_char_ is set to after EOF / read error.  We have
				// to be careful not to go into an infinite loop of trying to consume
				// it, so make sure to check read_error_ explicitly before consuming
				// '\0'.
				while (tryConsumeOne(Unprintable()) ||
						(!_readError && tryConsume('\x00'))) {
					// Ignore.
				}

			} else {
				// Reading some sort of token.
				startToken();

				if (tryConsumeOne(Letter())) {
					consumeZeroOrMore(Alphanumeric());
					_current?.type = TokenType.identifier;
				} else if (tryConsume('0')) {
					_current?.type = consumeNumber(true, false);
				} else if (tryConsume('.')) {
					// This could be the beginning of a floating-point number, or it could
					// just be a '.' symbol.

					if (tryConsumeOne(Digit())) {
						// It's a floating-point number.
						if (_previous?.type == TokenType.identifier &&
								_current?.line == _previous?.line &&
								_current?.colStart == _previous?.colEnd) {
							// We don't accept syntax like "blah.123".
							_errorCollector.addError(
									_line, _column - 2,
									"Need space between identifier and decimal point.");
						}
						_current?.type = consumeNumber(false, true);
					} else {
						_current?.type = TokenType.symbol;
					}
				} else if (tryConsumeOne(Digit())) {
					_current?.type = consumeNumber(false, false);
				} else if (tryConsume('"')) {
					consumeString('"');
					_current?.type = TokenType.string;
				} else if (tryConsume('\'')) {
					consumeString('\'');
					_current?.type = TokenType.string;
				} else {
					// Check if the high order bit is set.
					// TODO try to understand this if block of code
					//if (_currentChar & 0x80) {
					//  error_collector_->AddError(
					//      line_, column_,
					//      StringPrintf("Interpreting non ascii codepoint %d.",
					//                      static_cast<unsigned char>(current_char_)));
					//}
					nextChar();
					_current?.type = TokenType.symbol;
				}

				endToken();
				return true;
			}
		}

		// EOF
		_current?.type = TokenType.end;
		// TODO try to find this clear type
		//_current?.text.clear();
		_current?.line = _line;
		_current?.colStart = _column;
		_current?.colEnd = _column;
		return false;
	}

	void addError(String error) {
		_errorCollector.addError(_line, _column, error);
	}
}

class TokenizeError {
	final int line;
	final int columnNumber;
	final String message;

	TokenizeError(this.line, this.columnNumber, this.message);
}

class ErrorCollector {
	List<TokenizeError> errors = [];
	List<TokenizeError> warnings = [];

	void addError(int line, int columnNumber, String message) {
		errors.add(TokenizeError(line, columnNumber, message));
	}

	void addWarning(int line, int columnNumber, String message) {
		warnings.add(TokenizeError(line, columnNumber, message));
	}
}

// Valid values for set_comment_style().
enum CommentStyle {
	// Line comments begin with "//", block comments are delimited by "/*" and
	// "*/".
	cpp,
	// Line comments begin with "#".  No way to write block comments.
	sh,
}

enum NextCommentStatus {
	// Started a line comment.
	lineComment,

	// Started a block comment.
	blockComment,

	// Consumed a slash, then realized it wasn't a comment.  current_ has
	// been filled in with a slash token.  The caller should return it.
	slashNotComment,

	// We do not appear to be starting a comment here.
	noComment
}
