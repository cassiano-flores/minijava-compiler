import java.io.InputStreamReader;
%%


%public
%class MiniJavaLexer
%type Token
%unicode
%line

%{

public enum Token {
    Void,
	Main,
    Ident,
    IntegerLiteral,
    StringLiteral,
    If,
    Else,
    Public,
    Class,
    Extends,
    Static,
    Return,
    True,
    False,
    This,
    New,
    Boolean,
    String,
    Int,
    While,
    Continue,
    Length,
    SystemOutPrintln,
    Equals,
    Plus,
    Star,
    Semicolon,
    LCurlyB,
    RCurlyB,
    Dot,
    Comma,
    LPar,
    RPar,
    LSquareB,
    RSquareB,
    And,
    Less,
    Minus,
    FSlash,
    Exclamation,

	Cmd, // added to simplify the grammar
}

static MiniJavaLexer scanner;
private static Token latoken;

public static void verify(Token expected) {
	System.out.println("verifying " + expected);
	if (expected == latoken)
        try {
			latoken = scanner.yylex();
		} catch (Exception e) {
			System.err.println("Unexpected error: " + e);
		}
	else {
		System.err.println("Error at line: " + scanner.yyline + ": expected token: " + expected + ", found: " + latoken);
		System.exit(1);
	}
}

public static boolean nextIsType(Token token) {
    return ((token == Token.Int)     ||
            (token == Token.Boolean) ||
            (token == Token.Ident));
}

public static boolean nextIsCmd(Token token) {
	return (token == Token.Cmd);
}

public static void goal() {
	System.out.println("verifying Goal");
	mainClass();
    while (latoken == Token.Class) {
        classDeclaration();
    }
}

public static void mainClass() {
	System.out.println("verifying MainClass");
    verify(Token.Class);
    identifier();
    verify(Token.LCurlyB);
    verify(Token.Public);
    verify(Token.Static);
    verify(Token.Void);
    verify(Token.Main);
    verify(Token.LPar);
    verify(Token.String);
    verify(Token.LSquareB);
    verify(Token.RSquareB);
    identifier();
    verify(Token.RPar);
    verify(Token.LCurlyB);
    statement();
    verify(Token.RCurlyB);
    verify(Token.RCurlyB);
}

public static void classDeclaration() {
	System.out.println("verifying ClassDeclaration");
    verify(Token.Class);
    identifier();
    if (latoken == Token.Extends) {
        verify(Token.Extends);
        identifier();
    }
    verify(Token.LCurlyB);
    while (nextIsType(latoken)) {
        varDeclaration();
    }
    while (latoken == Token.Public) {
        methodDeclaration();
    }
    verify(Token.RCurlyB);
}

public static void varDeclaration() {
	System.out.println("verifying VarDeclaration");
    type();
    identifier();
    verify(Token.Semicolon);
}

public static void methodDeclaration() {
	System.out.println("verifying MethodDeclaration");
	verify(Token.Public);
	type();
	identifier();
	verify(Token.LPar);
    if (nextIsType(latoken)) {
        type();
        identifier();
        while (latoken == Token.Comma) {
            type();
            identifier();
        }
    }
    verify(Token.RPar);
    verify(Token.LCurlyB);
    while (nextIsType(latoken)) {
        varDeclaration();
    }
    while (nextIsCmd(latoken)) {
        statement();
    }
    verify(Token.Return);
    expression();
    verify(Token.Semicolon);
    verify(Token.RCurlyB);
}

public static void type() {
	System.out.println("verifying Type");
    switch (latoken) {
        case Int:
			verify(Token.Int);
			type_p();
            break;
        case Boolean:
            verify(Token.Boolean);
            break;
        case Ident:
            identifier();
            break;
        default:
		System.err.println("Error at line: " + scanner.yyline + ": expected one of: "
			+ Token.Int + ", " 
			+ Token.Boolean + ", " 
			+ Token.Ident
			+ ", found: " + latoken);
		System.exit(1);
    }
}

public static void type_p() {
	System.out.println("verifying type_p");
	if (latoken == Token.LSquareB) {
		verify(Token.LSquareB);
		verify(Token.RSquareB);
	}
}

public static void statement() {
	System.out.println("verifying Statement");
	verify(Token.Cmd);
}

public static void expression() {
	System.out.println("verifying Expression");
	verify(Token.Cmd);
}

public static void identifier() {
	System.out.println("verifying Identifier");
    verify(Token.Ident);
}

/**
* Runs the scanner on input files.
*
* This is a standalone scanner, it will print any unmatched
* text to System.out unchanged.
*
* @param argv   the command line, contains the filenames to run
*               the scanner on.
*/
public static void main(String argv[]) {
	scanner = null;
    if (argv.length == 0) {
        try {
            // scanner = new MiniJavaLexer( System.in );
            scanner = new MiniJavaLexer( new InputStreamReader(System.in) );

			latoken = scanner.yylex();
			goal();
            if ( !scanner.zzAtEOF )
                System.err.println("ERROR: GARBAGE AT THE END OF THE FILE");
          }
          catch (Exception e) {
            System.out.println("Unexpected exception:");
            e.printStackTrace();
          }
    }
    else {
        for (int i = 0; i < argv.length; i++) {
            try {
                scanner = new MiniJavaLexer( new java.io.FileReader(argv[i]) );
				latoken = scanner.yylex();
				goal();
				if ( !scanner.zzAtEOF )
					System.err.println("ERROR: GARBAGE AT THE END OF THE FILE");
            }
            catch (java.io.FileNotFoundException e) {
                System.out.println("File not found : \"" + argv[i] + "\"");
            }
            catch (java.io.IOException e) {
                System.out.println("IO error scanning file \"" + argv[i] + "\"");
                System.out.println(e);
            }
            catch (Exception e) {
                System.out.println("Unexpected exception:");
                e.printStackTrace();
            }
        }
    }
}


%}

DIGIT=        [0-9]
WHITESPACE=    [ \t]
LineTerminator = \r|\n|\r\n


%%
"cmd"|"CMD"                 {return Token.Cmd;} // this only exists to simplify the grammar


if                          {return Token.If;}
else                        {return Token.Else;}
public                      {return Token.Public;}
class                       {return Token.Class;}
extends                     {return Token.Extends;}
static                      {return Token.Static;}
return                      {return Token.Return;}
true                        {return Token.True;}
false                       {return Token.False;}
this                        {return Token.This;}
new                         {return Token.New;}
boolean                     {return Token.Boolean;}
String                      {return Token.String;}
int                         {return Token.Int;}
while                       {return Token.While;}
continue                    {return Token.Continue;}
length                      {return Token.Length;}
"System.out.println"        {return Token.SystemOutPrintln;}
void                        {return Token.Void;}
main                        {return Token.Main;}

[a-zA-Z]([a-zA-Z]|[0-9]|_)* {return Token.Ident;}
{DIGIT}+                    {return Token.IntegerLiteral;}

// Below: we need to first escape the '\', then the '"', so we end up with '\\\"'
\"(\\\"|[^\"])*\"           {return Token.StringLiteral;}

"="                         {return Token.Equals;}
"+"                         {return Token.Plus;}
"*"                         {return Token.Star;}
";"                         {return Token.Semicolon;}
"{"                         {return Token.LCurlyB;}
"}"                         {return Token.RCurlyB;}
"."                         {return Token.Dot;}
","                         {return Token.Comma;}
"("                         {return Token.LPar;}
")"                         {return Token.RPar;}
"["                         {return Token.LSquareB;}
"]"                         {return Token.RSquareB;}
"&&"                        {return Token.And;}
"<"                         {return Token.Less;}
"-"                         {return Token.Minus;}
"/"                         {return Token.FSlash;}
"!"                         {return Token.Exclamation;}

"//".*                      { /* Comments are ignored */ }
"/*"[^"*/"]*"*/"            { /* Comments are ignored */ }
{WHITESPACE}+               { }
{LineTerminator}            { }
.                           {System.err.println(yyline + 1 + ": INVALID CHARACTER: " + yytext());}
