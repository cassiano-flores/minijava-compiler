JFLEX_SRC := minijava-compiler.l
JFLEX_OUT := MiniJavaLexer
LEXER_JAVA := $(JFLEX_OUT).java
LEXER := $(JFLEX_OUT).class

$(LEXER): $(LEXER_JAVA)
	javac $(LEXER_JAVA)

$(LEXER_JAVA): $(JFLEX_SRC)
	java -jar jflex.jar $(JFLEX_SRC)

run: $(LEXER)
	java $(JFLEX_OUT)

clean:
	rm -rf $(JFLEX_OUT)*

.PHONY: run clean
