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
