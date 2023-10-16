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

Goal : MainClass ClassDeclList { System.out.println("Goal"); }
     ;

MainClass: Class Ident LCurlyB Public Static Void Main LPar String LSquareB RSquareB Ident RPar LCurlyB Statement RCurlyB RCurlyB
		 {
		 	System.out.println("MainClass");
		 }
		 ;

ClassDeclList: /*empty*/
			 | ClassDeclList ClassDeclaration
			 ;

ClassDeclaration: Class Ident LCurlyB VarDeclList MethodDeclList RCurlyB { System.out.println("ClassDeclaration"); }
				| Class Ident LCurlyB Extends Ident VarDeclList MethodDeclList RCurlyB { System.out.println("ClassDeclaration"); }
				;

VarDeclList: /*empty*/
		   | VarDeclList VarDeclaration
		   ;

MethodDeclList: /*empty*/
			  | MethodDeclList MethodDeclaration
			  ;

VarDeclaration: Type Ident Semicolon { System.out.println("VarDeclaration"); }
			  ;

MethodDeclaration: Public Type Ident LPar RPar LCurlyB VarDeclList StatementList Return Expression Semicolon RCurlyB
				 { System.out.println("MethodDeclaration"); }
				 | Public Type Ident LPar Type Ident Args RPar LCurlyB VarDeclList StatementList Return Expression Semicolon RCurlyB
				 { System.out.println("MethodDeclaration"); }
				 ;

Args: /*empty*/
	| Args Comma Type Ident
	;

StatementList: /*empty*/
			 | StatementList Statement
			 ;

Type: Int
	| Boolean { System.out.println("Type"); }
	| Int LSquareB RSquareB { System.out.println("Type"); }
	| Ident { System.out.println("Type"); }
	;

Statement: LCurlyB StatementList RCurlyB { System.out.println("Statement"); }
		 | If LPar Expression RPar Statement Else Statement { System.out.println("Statement"); }
		 | While LPar Expression RPar { System.out.println("Statement"); }
		 | SystemOutPrintln LPar Expression RPar Semicolon { System.out.println("Statement"); }
		 | Ident Equals Expression Semicolon { System.out.println("Statement"); }
		 | Ident LSquareB Expression RSquareB Equals Expression Semicolon { System.out.println("Statement"); }
		 ;

Expression: Expression And Expression { System.out.println("Expression"); }
		  | Expression Less Expression { System.out.println("Expression"); }
		  | Expression Plus Expression { System.out.println("Expression"); }
		  | Expression Minus Expression { System.out.println("Expression"); }
		  | Expression Star Expression { System.out.println("Expression"); }
		  | Expression LSquareB Expression RSquareB { System.out.println("Expression"); }
		  | Expression Dot Length { System.out.println("Expression"); }
		  | Expression Dot Ident LPar RPar { System.out.println("Expression"); }
		  | Expression Dot Ident LPar Expression CommaExpressionList RPar { System.out.println("Expression"); }
		  | IntegerLiteral { System.out.println("Expression"); }
		  | True { System.out.println("Expression"); }
		  | False { System.out.println("Expression"); }
		  | Ident { System.out.println("Expression"); }
		  | This { System.out.println("Expression"); }
		  | New Int LSquareB Expression RSquareB { System.out.println("Expression"); }
		  | New Ident LPar RPar { System.out.println("Expression"); }
		  | Exclamation Expression { System.out.println("Expression"); }
		  | LPar Expression RPar { System.out.println("Expression"); }
		  ;

CommaExpressionList: /*empty*/
				   | CommaExpressionList Comma Expression
				   ;
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
