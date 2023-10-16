%{
import java.util.*;
import java.io.*;
%}

// All terminals:
%token Void
%token Main
%token Ident
%token IntegerLiteral
%token StringLiteral
%token If
%token Else
%token Public
%token Class
%token Extends
%token Static
%token Return
%token True
%token False
%token This
%token New
%token Boolean
%token String
%token Int
%token While
%token Continue
%token Length
%token SystemOutPrintln
%token Equals
%token Plus
%token Star
%token Semicolon
%token LCurlyB
%token RCurlyB
%token Dot
%token Comma
%token LPar
%token RPar
%token LSquareB
%token RSquareB
%token And
%token Less
%token Minus
%token FSlash
%token Exclamation

%left AND
%left LT
%left PLUS MINUS
%left TIMES

%start Goal

%%

Goal : Ident Plus Ident
     ;


%%

private MiniJavaLexer lexer;

private int yylex () {
    int yyl_return = -1;
    try {
      yyl_return = lexer.yylex();
    } catch (IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
}

public void yyerror(String error) {
	System.err.println("Error: " + error);
}

public Parser(Reader r) {
	lexer = new MiniJavaLexer(r, this);
}

static boolean interactive;

public static void main(String args[]) throws IOException {
  System.out.println("MiniJava Parser");

  Parser yyparser;
  if ( args.length > 0 ) {
    // parse a file
    yyparser = new Parser(new FileReader(args[0]));
  }
  else {
    // interactive mode
    System.out.println("[Quit with CTRL-D]");
    System.out.print("Expression: ");
    interactive = true;
      yyparser = new Parser(new InputStreamReader(System.in));
  }

  yyparser.yyparse();
  
  if (interactive) {
    System.out.println();
    System.out.println("Have a nice day");
  }
}
