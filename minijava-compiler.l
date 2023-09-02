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

static MiniJavaLexer scanner;
private static Token latoken;

public static void error(String msg) {
    System.err.println("Invalid " + msg + " declaration");
}

public static void verify(Token expected) {
	if (expected == latoken)
		latoken = scanner.yylex();
	else {
		System.err.println("Expected token: " + expected + ", found: " + latoken);
	}
}

public static boolean verifyType(Token token) {
    return ((token == Token.Int)     ||
            (token == Token.Boolean) ||
            (token == Token.Ident));
}

public static boolean verifyStatement(Token token) {
    return ((token == Token.LCurlyB)          ||
            (token == Token.If)               ||
            (token == Token.While)            ||
            (token == Token.SystemOutPrintln) ||
            (token == Token.Ident));
}

public static boolean verifyExpression(Token token) {
    return ((token == Token.IntegerLiteral) ||
            (token == Token.True)           ||
            (token == Token.False)          ||
            (token == Token.Ident)          ||
            (token == Token.This)           ||
            (token == Token.New)            ||
            (token == Token.Exclamation)    ||
            (token == Token.LPar));
}

public static void goal() {
	mainClass();
    while (latoken == Token.Class) {
        classDeclaration();
    }
}

public static void mainClass() {
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
    verify(Token.Class);
    identifier();
    if (latoken == Token.Extends) {
        verify(Token.Extends);
        identifier();
    }
    verify(Token.LCurlyB);
    while (verifyType(latoken)) {
        varDeclaration();
    }
    while (latoken == Token.Public) {
        methodDeclaration();
    }
    verify(Token.RCurlyB);
}

public static void varDeclaration() {
    type();
    identifier();
    verify(Token.Semicolon);
}

public static void methodDeclaration() {
	verify(Token.Public);
	type();
	identifier();
	verify(Token.LPar);
    if (verifyType(latoken)) {
        type();
        identifier();
        while (latoken == Token.Comma) {
            type();
            identifier();
        }
    }
    verify(Token.RPar);
    verify(Token.LCurlyB);
    while (verifyType(latoken)) {
        varDeclaration();
    }
    while (verifyStatement(latoken)) {
        statement();
    }
    verify(Token.Return);
    expression();
    verify(Token.Semicolon);
    verify(Token.RCurlyB);
}

public static void type() {
    switch (latoken) {
        case Token.Int:
            verify(Token.Int);
            if (latoken == Token.LSquareB) {
                verify(Token.LSquareB);
                verify(Token.RSquareB);
            }
            break;
        case Token.Boolean:
            verify(Token.Boolean);
            break;
        case Token.Ident:
            identifier();
            break;
        default:
            error("type");
    }
}

public static void statement() {
    switch (latoken) {
        case Token.LCurlyB:
            verify(Token.LCurlyB);
            while (latoken != Token.RCurlyB) {
                statement();
            }
            verify(Token.RCurlyB);
            break;
        case Token.If:
            verify(Token.If);
            verify(Token.LPar);
            expression();
            verify(Token.RPar);
            statement();
            verify(Token.Else);
            statement();
            break;
        case Token.While:
            verify(Token.While);
            verify(Token.LPar);
            expression();
            verify(Token.RPar);
            statement();
            break;
        case Token.SystemOutPrintln:
            verify(Token.SystemOutPrintln);
            verify(Token.LPar);
            expression();
            verify(Token.RPar);
            verify(Token.Semicolon);
            break;
        case Token.Ident:
            identifier();
            if (latoken == Token.Equals) {
                verify(Token.Equals);
                expression();
                verify(Token.Semicolon);
            } else if (latoken == Token.LSquareB) {
                verify(Token.LSquareB);
                expression();
                verify(Token.RSquareB);
                verify(Token.Equals);
                expression();
                verify(Token.Semicolon);
            } else {
                error("identifier");
            }
            break;
        default:
           error("statement");
    }
}

public static void expression() {
    switch (latoken) {
        case Token.And:
        case Token.Less:
        case Token.Plus:
        case Token.Minus:
        case Token.Star:
            switch (latoken) {
                case Token.And:
                    verify(Token.And);
                    break;
                case Token.Less:
                    verify(Token.And);
                    break;
                case Token.Plus:
                    verify(Token.And);
                    break;
                case Token.Minus:
                    verify(Token.And);
                    break;
                case Token.Star:
                    verify(Token.And);
                    break;
                default:
                    error("binary operation");
            }
            expression();
            break;
        case Token.LSquareB:
            verify(Token.LSquareB);
            expression();
            verify(Token.RSquareB);
            break;
        case Token.Dot:
            verify(Token.Dot);
            if (latoken == Token.Length) {
                verify(Token.Length);
            } else if (latoken == Token.Ident) {
                identifier();
                verify(Token.LPar);
                if (verifyExpression(latoken)) {
                    expression();
                    while (latoken == Token.Comma) {
                        verify(Token.Comma);
                        expression();
                    }
                }
                verify(Token.RPar);
            } else {
                error("expression parameters");
            }
            break;
        case Token.IntegerLiteral:
            verify(Token.IntegerLiteral);
            break;
        case Token.True:
            verify(Token.True);
            break;
        case Token.False:
            verify(Token.False);
            break;
        case Token.Ident:
            identifier();
            break;
        case Token.This:
            verify(Token.This);
            break;
        case Token.New:
            verify(Token.New);
            if (latoken == Token.Int) {
                verify(Token.Int);
                verify(Token.LSquareB);
                expression();
                verify(Token.RSquareB);
            } else if (latoken == Token.Ident) {
                identifier();
                verify(Token.LPar);
                verify(Token.RPar);
            } else {
                error("new");
            }
            break;
        case Token.Exclamation:
            verify(Token.Exclamation);
            expression();
            break;
        case Token.LPar:
            verify(Token.LPar);
            expression();
            verify(Token.RPar);
            break;
        default:
            error("expression");
    }
}

public static void identifier() {
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
