enum TokenType {

	// Next() has not yet been called.
	start,  

	// End of input reached.  "text" is empty.
	end,    

	// A sequence of letters, digits, and underscores, not
	// starting with a digit.  It is an error for a number
	// to be followed by an identifier with no space in
	// between.
	identifier,  	

	// A sequence of digits representing an integer.  Normally
	// the digits are decimal, but a prefix of "0x" indicates
	// a hex number and a leading zero indicates octal, just
	// like with C numeric literals.  A leading negative sign
	// is NOT included in the token; it's up to the parser to
	// interpret the unary minus operator on its own.
	integer,	

	// A floating point literal, with a fractional part and/or
	// an exponent.  Always in decimal.  Again, never
	// negative.
	float,       

	// A quoted sequence of escaped characters.  Either single
	// or double quotes can be used, but they must match.
	// A string literal cannot cross a line break.
	string,

	// Any other printable character, like '!' or '+'.
	// Symbols are always a single character, so "!+$%" is
	// four tokens.
	symbol,

	// A sequence of whitespace.  This token type is only
	// produced if report_whitespace() is true.  It is not
	// reported for whitespace within comments or strings.
	whitespace,  

	// A newline (\n).  This token type is only
	// produced if report_whitespace() is true and
	// report_newlines() is true.  It is not reported for
	// newlines in comments or strings.
	newline
}
