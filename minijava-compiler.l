import java.io.InputStreamReader;
%%


%public
%class MiniJavaLexer
%type Token
%unicode
%line

%{

public enum Token {
    Ident,
    Num,
    If,
    Else,
    Public,
    Private,
    Class,
    DoubleEquals,
    Equals,
    Plus,
    Star,
    SemiCollon,
    LBracket,
    RBracket,
    Dot,
    Comma,
    LPar,
    RPar,
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
    MiniJavaLexer scanner;
    if (argv.length == 0) {
        try {
            // scanner = new MiniJavaLexer( System.in );
            scanner = new MiniJavaLexer( new InputStreamReader(System.in) );
            while ( !scanner.zzAtEOF )
                System.out.printf("TOKEN: %-16s <%s>\n", scanner.yylex(), scanner.yytext());
          }
          catch (Exception e) {
            System.out.println("Unexpected exception:");
            e.printStackTrace();
          }
    }
    else {
        for (int i = 0; i < argv.length; i++) {
            scanner = null;
            try {
                scanner = new MiniJavaLexer( new java.io.FileReader(argv[i]) );
                while ( !scanner.zzAtEOF )
                    System.out.printf("TOKEN: %-16s <%s>\n", scanner.yylex(), scanner.yytext());
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
LETTER=        [a-zA-Z]
WHITESPACE=    [ \t]
LineTerminator = \r|\n|\r\n


%%

if                          {return Token.If;}
else                        {return Token.Else;}
public                      {return Token.Public;}
private                     {return Token.Private;}
class                       {return Token.Class;}

{LETTER}({LETTER}|{DIGIT})* {return Token.Ident;}
{DIGIT}+                    {return Token.Num;}

"="                         {return Token.Equals;}
"+"                         {return Token.Plus;}
"*"                         {return Token.Star;}
";"                         {return Token.SemiCollon;}
"{"                         {return Token.LBracket;}
"}"                         {return Token.RBracket;}
"."                         {return Token.Dot;}
","                         {return Token.Comma;}
"("                         {return Token.LPar;}
")"                         {return Token.RPar;}
"=="                        {return Token.DoubleEquals;}
{WHITESPACE}+               { }
{LineTerminator}            { }
.                           {System.out.println(yyline + 1 + ": INVALID CHARACTER: " + yytext());}
