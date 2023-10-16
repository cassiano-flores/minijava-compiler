import java.io.InputStreamReader;
%%


%public
%class MiniJavaLexer
%byaccj
%unicode
%line

%{

private Parser yyparser;

public MiniJavaLexer(java.io.Reader r, Parser yyparser) {
	this(r);
	this.yyparser = yyparser;
}

%}

DIGIT=        [0-9]
WHITESPACE=    [ \t]
LineTerminator = \r|\n|\r\n


%%
if                          {return Parser.If;}
else                        {return Parser.Else;}
public                      {return Parser.Public;}
class                       {return Parser.Class;}
extends                     {return Parser.Extends;}
static                      {return Parser.Static;}
return                      {return Parser.Return;}
true                        {return Parser.True;}
false                       {return Parser.False;}
this                        {return Parser.This;}
new                         {return Parser.New;}
boolean                     {return Parser.Boolean;}
String                      {return Parser.String;}
int                         {return Parser.Int;}
while                       {return Parser.While;}
continue                    {return Parser.Continue;}
length                      {return Parser.Length;}
"System.out.println"        {return Parser.SystemOutPrintln;}
void                        {return Parser.Void;}
main                        {return Parser.Main;}

[a-zA-Z]([a-zA-Z]|[0-9]|_)* {return Parser.Ident;}
{DIGIT}+                    {return Parser.IntegerLiteral;}

// Below: we need to first escape the '\', then the '"', so we end up with '\\\"'
\"(\\\"|[^\"])*\"           {return Parser.StringLiteral;}

"="                         {return Parser.Equals;}
"+"                         {return Parser.Plus;}
"*"                         {return Parser.Star;}
";"                         {return Parser.Semicolon;}
"{"                         {return Parser.LCurlyB;}
"}"                         {return Parser.RCurlyB;}
"."                         {return Parser.Dot;}
","                         {return Parser.Comma;}
"("                         {return Parser.LPar;}
")"                         {return Parser.RPar;}
"["                         {return Parser.LSquareB;}
"]"                         {return Parser.RSquareB;}
"&&"                        {return Parser.And;}
"<"                         {return Parser.Less;}
"-"                         {return Parser.Minus;}
"/"                         {return Parser.FSlash;}
"!"                         {return Parser.Exclamation;}

"//".*                      { /* Comments are ignored */ }
"/*"[^"*/"]*"*/"            { /* Comments are ignored */ }
{WHITESPACE}+               { }
{LineTerminator}            { }
.                           {System.err.println(yyline + 1 + ": INVALID CHARACTER: " + yytext());}
