const nspace = 32;
const n0 = 48; // for 0
const n7 = 55; // for 7
const n9 = 57; // for 9
const nA = 65; // for A
const nF = 70; // for F
const nZ = 90; // for F
const n_ = 95; // for _
const na = 97; // for a
const nf = 102; // for f
const nz = 122; // for z

class CharacterClass {
	bool inClass(String c) {
		return false;
	}
}

class Whitespace implements CharacterClass {
	Whitespace._privateConstructor();
	static final _instance = Whitespace._privateConstructor();
	factory Whitespace() => _instance;

	@override
	bool inClass(String c) {
		return (c == ' ' || c == '\n' || c == '\t' || c == '\r' ||
			c == '\v' || c == '\f');
	}
}

class WhitespaceNoNewline implements CharacterClass {
	WhitespaceNoNewline._privateConstructor();
	static final _instance = WhitespaceNoNewline._privateConstructor();
	factory WhitespaceNoNewline() => _instance;

	@override
	bool inClass(String c) {
		return c == ' ' || c == '\t' || c == '\r' || c == '\v' || c == '\f';
	}
}

class Unprintable implements CharacterClass { 
	Unprintable._privateConstructor();
	static final _instance = Unprintable._privateConstructor();
	factory Unprintable() => _instance;

	@override
	bool inClass(String c) {
		const space = 32; // for ' '
		var cc = c.codeUnitAt(0);
		return cc < 32 && cc > 0;
	}
}

class Digit implements CharacterClass {
	Digit._privateConstructor();
	static final _instance = Digit._privateConstructor();
	factory Digit() => _instance;

	@override
	bool inClass(String c) {
		var cc = c.codeUnitAt(0);
		return n0 <= cc && cc <= n9;
	}
}
class OctalDigit implements CharacterClass {
	OctalDigit._privateConstructor();
	static final _instance = OctalDigit._privateConstructor();
	factory OctalDigit() => _instance;

	@override
	bool inClass(String c) {
		var cc = c.codeUnitAt(0);
		return n0 <= cc && cc <= n7;
	}
}
class HexDigit implements CharacterClass {
	HexDigit._privateConstructor();
	static final _instance = HexDigit._privateConstructor();
	factory HexDigit() => _instance;

	@override
	bool inClass(String c) {
		var cc = c.codeUnitAt(0);
		return (n0 <= cc && cc <= n9) || 
				(na <= cc && cc <= nf ) ||
				(nA <= cc && cc <= nF);
	}
}


class Letter implements CharacterClass {
	Letter._privateConstructor();
	static final _instance = Letter._privateConstructor();
	factory Letter() => _instance;

	@override
	bool inClass(String c) {
		var cc = c.codeUnitAt(0);
		return (na <= cc && cc <= nz) || 
				(nA <= cc && cc <= nZ) || 
				(cc == n_);
	}
}

class Alphanumeric implements CharacterClass {
	Alphanumeric._privateConstructor();
	static final _instance = Alphanumeric._privateConstructor();
	factory Alphanumeric() => _instance;

	@override
	bool inClass(String c) {
		var cc = c.codeUnitAt(0);
		return (na <= cc && cc <= nz) || 
				(nA <= cc && cc <= nZ) || 
				(n0 <= cc && cc <= n9) ||
				(cc == n_);
	}
}

class Escape implements CharacterClass {
	Escape._privateConstructor();
	static final _instance = Escape._privateConstructor();
	factory Escape() => _instance;

	@override
	bool inClass(String c) {
		return c == 'a' || c == 'b' || c == 'f' || c == 'n' ||
				c == 'r' || c == 't' || c == 'v' || c == '\\' ||
				c == '?' || c == '\'' || c == '"';
	}
}
