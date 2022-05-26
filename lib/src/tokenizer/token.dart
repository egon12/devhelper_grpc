class Token {

	String text;
	int line;
	int colStart;
	int colEnd;

	Token({
		this.text = '',
		this.line = 0,
		this.colStart = 0,
		this.colEnd = 0
	});
}
