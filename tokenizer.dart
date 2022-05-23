
enum TokenType {

	// Next() has not yet been called.
	TYPE_START,  

	// End of input reached.  "text" is empty.
	TYPE_END,    

	// A sequence of letters, digits, and underscores, not
	// starting with a digit.  It is an error for a number
	// to be followed by an identifier with no space in
	// between.
	TYPE_IDENTIFIER,  	

	// A sequence of digits representing an integer.  Normally
	// the digits are decimal, but a prefix of "0x" indicates
	// a hex number and a leading zero indicates octal, just
	// like with C numeric literals.  A leading negative sign
	// is NOT included in the token; it's up to the parser to
	// interpret the unary minus operator on its own.
	TYPE_INTEGER,	

	// A floating point literal, with a fractional part and/or
	// an exponent.  Always in decimal.  Again, never
	// negative.
	TYPE_FLOAT,       

	// A quoted sequence of escaped characters.  Either single
	// or double quotes can be used, but they must match.
	// A string literal cannot cross a line break.
	TYPE_STRING,

	// Any other printable character, like '!' or '+'.
	// Symbols are always a single character, so "!+$%" is
	// four tokens.
	TYPE_SYMBOL,

	// A sequence of whitespace.  This token type is only
	// produced if report_whitespace() is true.  It is not
	// reported for whitespace within comments or strings.
	TYPE_WHITESPACE,  

	// A newline (\n).  This token type is only
	// produced if report_whitespace() is true and
	// report_newlines() is true.  It is not reported for
	// newlines in comments or strings.
	TYPE_NEWLINE,
};

class Token {
	TokenType type;

	// The exact text of the token as it appeared in
	// the input.  e.g. tokens of TYPE_STRING will still
	// be escaped and in quotes.
	String text;  

	// "line" and "column" specify the position of the first character of
	// the token within the input stream.  They are zero-based.

	int line;
	ColumnNumber column;
	ColumnNumber end_column;
};


class Tokenizer {

	String content_;

	Token previous_;

	Token current_;
	int line

	Tokenizer

	void next() {

		previous_ = current_;

		while (!read_error_) {
			StartToken();
			bool report_token = TryConsumeWhitespace() || TryConsumeNewline();
			EndToken();
			if (report_token) {
				return true;
			}

			switch (TryConsumeCommentStart()) {
				case LINE_COMMENT:
					ConsumeLineComment(NULL);
					continue;
				case BLOCK_COMMENT:
					ConsumeBlockComment(NULL);
					continue;
				case SLASH_NOT_COMMENT:
					return true;
				case NO_COMMENT:
					break;
			}

			// Check for EOF before continuing.
			if (read_error_) break;

			if (LookingAt<Unprintable>() || current_char_ == '\0') {
				AddError("Invalid control characters encountered in text.");
				NextChar();
				// Skip more unprintable characters, too.  But, remember that '\0' is
				// also what current_char_ is set to after EOF / read error.  We have
				// to be careful not to go into an infinite loop of trying to consume
				// it, so make sure to check read_error_ explicitly before consuming
				// '\0'.
				while (TryConsumeOne<Unprintable>() ||
						(!read_error_ && TryConsume('\0'))) {
					// Ignore.
				}

			} else {
				// Reading some sort of token.
				StartToken();

				if (TryConsumeOne<Letter>()) {
					ConsumeZeroOrMore<Alphanumeric>();
					current_.type = TYPE_IDENTIFIER;
				} else if (TryConsume('0')) {
					current_.type = ConsumeNumber(true, false);
				} else if (TryConsume('.')) {
					// This could be the beginning of a floating-point number, or it could
					// just be a '.' symbol.

					if (TryConsumeOne<Digit>()) {
						// It's a floating-point number.
						if (previous_.type == TYPE_IDENTIFIER &&
								current_.line == previous_.line &&
								current_.column == previous_.end_column) {
							// We don't accept syntax like "blah.123".
							error_collector_->AddError(
									line_, column_ - 2,
									"Need space between identifier and decimal point.");
						}
						current_.type = ConsumeNumber(false, true);
					} else {
						current_.type = TYPE_SYMBOL;
					}
				} else if (TryConsumeOne<Digit>()) {
					current_.type = ConsumeNumber(false, false);
				} else if (TryConsume('\"')) {
					ConsumeString('\"');
					current_.type = TYPE_STRING;
				} else if (TryConsume('\'')) {
					ConsumeString('\'');
					current_.type = TYPE_STRING;
				} else {
					// Check if the high order bit is set.
					if (current_char_ & 0x80) {
						error_collector_->AddError(
								line_, column_,
								StringPrintf("Interpreting non ascii codepoint %d.",
										static_cast<unsigned char>(current_char_)));
					}
					NextChar();
					current_.type = TYPE_SYMBOL;
				}

				EndToken();
				return true;
			}
		}

		// EOF
		current_.type = TYPE_END;
		current_.text.clear();
		current_.line = line_;
		current_.column = column_;
		current_.end_column = column_;
		return false;


	}
}
