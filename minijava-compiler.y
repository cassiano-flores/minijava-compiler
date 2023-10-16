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

/* Goal : MainClass ( ClassDeclaration )* <EOF> */
Goal : MainClass ClassDeclList
     ;

/* MainClass : CLASS IDENTIFIER '{' PUBLIC STATIC VOID MAIN '(' STRING '[' ']' IDENTIFIER ')' '{' Statement '}' '}' */
MainClass: Class Ident LCurlyB Public Static Void Main LPar String LSquareB RSquareB Ident RPar LCurlyB Statement RCurlyB RCurlyB
		 ;

ClassDeclList: /*empty*/
			 | ClassDeclList ClassDeclaration
			 ;

/*ClassDeclaration : CLASS IDENTIFIER ( EXTENDS IDENTIFIER )? '{' ( VarDeclaration )* ( MethodDeclaration )* '}'*/
ClassDeclaration: Class Ident LCurlyB VarDeclList MethodDeclList RCurlyB
				| Class Ident LCurlyB Extends Ident VarDeclList MethodDeclList RCurlyB
				;

VarDeclList: /*empty*/
		   | VarDeclList VarDeclaration
		   ;

MethodDeclList: /*empty*/
			  | MethodDeclList MethodDeclaration
			  ;

/*VarDeclaration : Type IDENTIFIER ';'*/
VarDeclaration: Type Ident Semicolon
			  ;

/*MethodDeclaration : PUBLIC Type IDENTIFIER '(' ( Type IDENTIFIER ( ',' Type IDENTIFIER )* )? ')' '{' ( VarDeclaration )* ( Statement )* RETURN Expression ';' '}'*/
MethodDeclaration: Public Type Ident LPar RPar LCurlyB VarDeclList StatementList Return Expression Semicolon RCurlyB
				 | Public Type Ident LPar Type Ident Args RPar LCurlyB VarDeclList StatementList Return Expression Semicolon RCurlyB
				 ;

Args: /*empty*/
	| Args Comma Type Ident
	;

StatementList: /*empty*/
			 | StatementList Statement

/* Type : INT '[' ']' | BOOLEAN | INT | IDENTIFIER */
Type: Int
	| Boolean
	| Int LSquareB RSquareB
	| Ident
	;

/*Statement : '{' ( Statement )* '}'
            | IF '(' Expression ')' Statement ELSE Statement
			| WHILE '(' Expression ')' Statement
			| SystemOutPrintln '(' Expression ')' ';'
			| IDENTIFIER '=' EXPRESSION ';'
			| IDENTIFIER '[' EXPRESSION ']' '=' EXPRESSION ';'
			*/
Statement: LCurlyB StatementList RCurlyB
		 | If LPar Expression RPar Statement Else Statement
		 | While LPar Expression RPar
		 | SystemOutPrintln LPar Expression RPar Semicolon
		 | Ident Equals Expression Semicolon
		 | Ident LSquareB Expression RSquareB Equals Expression Semicolon
		 ;

/*Expression : Expression AND Expression
			 | Expression LT Expression
			 | Expression PLUS Expression
			 | Expression MINUS Expression
             | Expression TIMES Expression
			 | Expression '[' Expression ']'
			 | Expression '.' LENGTH
			 | Expression '.' IDENTIFIER '(' ( Expression ( ',' Expression )* )? ')'
             | INTEGER_LITERAL
			 | TRUE
			 | FALSE
			 | IDENTIFIER
			 | THIS
			 | NEW INT '[' Expression ']'
			 | NEW IDENTIFIER '(' ')'
			 | '!' Expression
			 | '(' Expression ')'
			 */
Expression: Expression And Expression
		  | Expression Less Expression
		  | Expression Plus Expression
		  | Expression Minus Expression
		  | Expression Star Expression
		  | Expression LSquareB Expression RSquareB
		  | Expression Dot Length
		  | Expression Dot Ident LPar RPar
		  | Expression Dot Ident LPar Expression CommaExpressionList RPar
		  | IntegerLiteral
		  | True
		  | False
		  | Ident
		  | This
		  | New Int LSquareB Expression RSquareB
		  | New Ident LPar RPar
		  | Exclamation Expression
		  | LPar Expression RPar
		  ;

CommaExpressionList: /*empty*/
				   | CommaExpressionList Comma Expression

%%

private MiniJavaLexer lexer;
private int current_token;

private int yylex () {
    int yyl_return = -1;
    try {
      yyl_return = lexer.yylex();
	  current_token = yyl_return;
    } catch (IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
}

private String intToTokenStr(int i) {
	switch (i) {
		case Void: return "Void";
		case Main: return "Main";
		case Ident: return "Ident";
		case IntegerLiteral: return "IntegerLiteral";
		case StringLiteral: return "StringLiteral";
		case If: return "If";
		case Else: return "Else";
		case Public: return "Public";
		case Class: return "Class";
		case Extends: return "Extends";
		case Static: return "Static";
		case Return: return "Return";
		case True: return "True";
		case False: return "False";
		case This: return "This";
		case New: return "New";
		case Boolean: return "Boolean";
		case String: return "String";
		case Int: return "Int";
		case While: return "While";
		case Continue: return "Continue";
		case Length: return "Length";
		case SystemOutPrintln: return "SystemOutPrintln";
		case Equals: return "Equals";
		case Plus: return "Plus";
		case Star: return "Star";
		case Semicolon: return "Semicolon";
		case LCurlyB: return "LCurlyB";
		case RCurlyB: return "RCurlyB";
		case Dot: return "Dot";
		case Comma: return "Comma";
		case LPar: return "LPar";
		case RPar: return "RPar";
		case LSquareB: return "LSquareB";
		case RSquareB: return "RSquareB";
		case And: return "And";
		case Less: return "Less";
		case Minus: return "Minus";
		case FSlash: return "FSlash";
		case Exclamation: return "Exclamation";
	}
	return "?";
}

public void yyerror(String error) {
	System.err.println("Error: " + error + ", at line: " + lexer.line() + ", token: " + intToTokenStr(this.current_token));
}

public Parser(Reader r) {
	lexer = new MiniJavaLexer(r, this);
	current_token = -1;
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
