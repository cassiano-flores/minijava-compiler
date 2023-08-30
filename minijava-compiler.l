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
}

MiniJavaLexer scanner;
private static Token latoken;

public static void verifica(Token expected) {
	if (expected == latoken)
		latoken = scanner.yylex();
	else {
		System.err.println("Expected token: " + expected + ", found: ", + latoken);
	}
}

public static void goal() {
	mainClass();
}

public static void mainClass() {

}

public static void classDeclaration() {

}

public static void varDeclaration() {

}

public static void methodDeclaration() {
	verifica(Token.Public);
	type();
	identifier();
	verifica(Token.LPar);
}

public static void type() {

}

public static void identifier() {

}

public static void statement() {

}

public static void expression() {

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
                System.err.println("ERROR!");
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
					System.err.println("ERROR!");
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
