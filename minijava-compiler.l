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
    IntegerLiteral,
    FloatLiteral,
    StringLiteral,
    If,
    Else,
    Public,
    Class,
    Extends,
    Static,
    Return,
    Null,
    True,
    False,
    This,
    New,
    Boolean,
    String,
    Float,
    Int,
    While,
    Break,
    Continue,
    Switch,
    Case,
    Default,
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
    Colon,
    Ampersand,
    Pipe,
    Less,
    Minus,
    Solidus,
    Exclamation,
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
class                       {return Token.Class;}
extends                     {return Token.Extends;}
static                      {return Token.Static;}
return                      {return Token.Return;}
null                        {return Token.Null;}
true                        {return Token.True;}
false                       {return Token.False;}
this                        {return Token.This;}
new                         {return Token.New;}
boolean                     {return Token.Boolean;}
String                      {return Token.String;}
float                       {return Token.Float;}
int                         {return Token.Int;}
while                       {return Token.While;}
break                       {return Token.Break;}
continue                    {return Token.Continue;}
switch                      {return Token.Switch;}
case                        {return Token.Case;}
default                     {return Token.Default;}
length                      {return Token.Length;}
System.out.println          {return Token.SystemOutPrintln;}

{LETTER}({LETTER}|{DIGIT})* {return Token.Ident;}
{DIGIT}+                    {return Token.IntegerLiteral;}
{DIGIT}+\.\{DIGIT}+         {return Token.FloatLiteral;}
{LETTER}+                   {return Token.StringLiteral}

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
":"                         {return Token.Colon;}
"&"                         {return Token.Ampersand;}
"|"                         {return Token.Pipe;}
"<"                         {return Token.Less;}
"-"                         {return Token.Minus;}
"/"                         {return Token.Solidus;}
"!"                         {return Token.Exclamation;}
{WHITESPACE}+               { }
{LineTerminator}            { }
.                           {System.out.println(yyline + 1 + ": INVALID CHARACTER: " + yytext());}
