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

%left And
%left Less
%left Plus Minus
%left Star

%start Goal

%%

Goal : Ident Plus Ident
     ;


%%

/*
Goal : MainClass ( ClassDeclaration )* <EOF>
     ;

MainClass : CLASS IDENTIFIER '{' PUBLIC STATIC VOID MAIN '(' STRING '[' ']' IDENTIFIER ')' '{' Statement '}' '}'
          ;

ClassDeclaration : CLASS IDENTIFIER ( EXTENDS IDENTIFIER )? '{' ( VarDeclaration )* ( MethodDeclaration )* '}'
                 ;

VarDeclaration : Type IDENTIFIER ';'
               ;

MethodDeclaration : PUBLIC Type IDENTIFIER '(' ( Type IDENTIFIER ( ',' Type IDENTIFIER )* )? ')' '{' ( VarDeclaration )* ( Statement )* RETURN Expression ';' '}'
                  ;

Type : INT '[' ']' | BOOLEAN | INT | IDENTIFIER
     ;

Statement : '{' ( Statement )* '}' | IF '(' Expression ')' Statement ELSE Statement | WHILE '(' Expression ')' Statement
          | PRINTLN '(' Expression ')' ';' | IDENTIFIER '=' Expression ';' | IDENTIFIER '[' Expression ']' '=' Expression ';'
          ;

Expression : Expression AND Expression | Expression LT Expression | Expression PLUS Expression | Expression MINUS Expression
           | Expression TIMES Expression | Expression '[' Expression ']' | Expression '.' LENGTH | Expression '.' IDENTIFIER '(' ( Expression ( ',' Expression )* )? ')'
           | INTEGER_LITERAL | TRUE | FALSE | IDENTIFIER | THIS | NEW INT '[' Expression ']' | NEW IDENTIFIER '(' ')' | '!' Expression | '(' Expression ')'
           ;

*/

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
