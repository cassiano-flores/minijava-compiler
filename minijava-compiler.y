%{
import java.util.*;
import java.io.*;
import java.util.stream.Collectors;
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

%right Exclamation
%left And
%left Less
%left Plus Minus
%left Star
%left Dot
%right Equals
%left LSquareB LPar

%start Goal

%%

Goal : MainClass ClassDeclListOpt { System.out.println("\tGoal"); }
     ;

MainClass: Class Ident LCurlyB {
		    // Como essa eh sempre a primeira coisa a ser declarada, nunca teremos um problema dos
			// identificadores jah existirem

			System.out.println("Inserindo classe '" + $2.sval + "' em: " + printScopes());
			scopes.peek().symbols.insert(new TS_entry($2.sval, null, ClasseID.NomeClasse));
			System.out.println("Empilhando escopo: " + $2.sval);
			scopes.push(new Scope($2.sval));
		 } Public Static Void Main LPar String LSquareB RSquareB Ident RPar LCurlyB {
			TS_entry entry = new TS_entry("main", Tp_VOID);
			scopes.peek().symbols.insert(entry);
			System.out.println("Inserindo metodo '" + entry + "' em: " + printScopes());

			System.out.println("Empilhando escopo: main");
			scopes.push(new Scope("main"));

			entry = new TS_entry($13.sval, new TS_entry("String[]", null, null),  ClasseID.NomeParam);
			scopes.peek().symbols.insert(entry);
			// imprime manualmente porque String[] eh especial
			System.out.println("Inserindo parametro 'Id: " + $13.sval + ", Tipo: String[]" + "' em: " + printScopes());
		 } Statement RCurlyB {
			System.out.println("Desempilhando escopo: " + scopes.pop().desc);
		 } RCurlyB {
			System.out.println("Desempilhando escopo: " + scopes.pop().desc);
		 }
		 ;

ClassDeclListOpt: /*empty*/
				| ClassDeclList
				;

ClassDeclList: ClassDeclaration
			 | ClassDeclList ClassDeclaration
			 ;

ClassDeclaration: Class Ident ExtendOpt LCurlyB {
					TS_entry nodo = scopes.peek().symbols.pesquisa($2.sval);
					if (nodo != null) {
						yyerror("variable " + $2.sval + " was already declared");
						// TODO: error in the end
					} else {
						System.out.println("Inserindo classe '" + $2.sval + "' em: " + printScopes());
						scopes.peek().symbols.insert(new TS_entry($2.sval, null, ClasseID.NomeClasse));
					}
					System.out.println("Empilhando escopo: " + $2.sval);
					scopes.push(new Scope($2.sval));
				}
				FieldDeclListOpt MethodDeclListOpt RCurlyB {
					System.out.println("Desempilhando escopo: " + scopes.pop().desc);
				}
				;

ExtendOpt: /*empty*/
		 | Extends Ident
		 ;

FieldDeclListOpt: /*empty*/
			  | FieldDeclList
			  ;

FieldDeclList: FieldDeclaration
		   | FieldDeclList FieldDeclaration
		   ;

MethodDeclListOpt: /*empty*/
			  | MethodDeclList
			  ;

MethodDeclList: MethodDeclaration
			  | MethodDeclList MethodDeclaration
			  ;

FieldDeclaration: Type Ident Semicolon {
				TS_entry nodo = scopes.peek().symbols.pesquisa($2.sval);
				if (nodo != null) {
					yyerror("field " + $2.sval + " was already declared");
					// TODO: error in the end
				} else {
					TS_entry entry = new TS_entry($2.sval, (TS_entry)$1.obj,  ClasseID.CampoClasse);
					scopes.peek().symbols.insert(entry);
					System.out.println("Inserindo campo '" + entry + "' em: " + printScopes());
				}
			  }
			  ;

MethodDeclaration: Public Type Ident {
					TS_entry nodo = scopes.peek().symbols.pesquisa($3.sval);
					if (nodo != null) {
						yyerror("identifier " + $3.sval + " is already in use");
						// TODO: error in the end
					} else {
						TS_entry entry = new TS_entry($3.sval, (TS_entry)$2.obj);
						scopes.peek().symbols.insert(entry);
						System.out.println("Inserindo metodo '" + entry + "' em: " + printScopes());
					}
					System.out.println("Empilhando escopo: " + $3.sval);
					scopes.push(new Scope($3.sval));
				} LPar Args RPar LCurlyB VarOrStatement Return Expression Semicolon RCurlyB {
					System.out.println("Desempilhando escopo: " + scopes.pop().desc);
				}
				;

Args: /*empty*/
	| ArgList
	;

ArgList: Arg
	| ArgList Comma Arg
	;

Arg: Type Ident {
		TS_entry nodo = findInScope($2.sval, ClasseID.NomeParam);
		if (nodo != null) {
			yyerror("parameter " + $2.sval + " was already declared");
			// TODO: error in the end
		} else {
			TS_entry entry = new TS_entry($2.sval, (TS_entry)$1.obj,  ClasseID.NomeParam);
			scopes.peek().symbols.insert(entry);
			System.out.println("Inserindo parametro '" + entry + "' em: " + printScopes());
		}
   }
   ;

VarOrStatement: /*empty*/
			  | Ident NextVar
			  | Int Ident Semicolon VarOrStatement { System.out.println("\tVarDeclaration"); }
			  | Int LSquareB RSquareB Ident Semicolon VarOrStatement { System.out.println("\tVarDeclaration"); }
			  | Boolean Ident Semicolon VarOrStatement { System.out.println("\tVarDeclaration"); }
		 	  | If LPar Expression RPar Statement Else Statement StatementListOpt { System.out.println("\tStatement"); }
		 	  | While LPar Expression RPar Statement StatementListOpt { System.out.println("\tStatement"); }
		 	  | SystemOutPrintln LPar Expression RPar Semicolon StatementListOpt { System.out.println("\tStatement"); }
			  | LCurlyB StatementListOpt RCurlyB StatementListOpt { System.out.println("\tStatement"); }
			  ;

NextVar: Ident Semicolon VarOrStatement { System.out.println("\tVarDeclaration"); }
	   | Equals Expression Semicolon StatementListOpt { System.out.println("\tStatement"); }
	   | LSquareB Expression RSquareB Equals Expression Semicolon StatementListOpt { System.out.println("\tStatement"); }
	   ;

StatementListOpt: /*empty*/
			 | StatementList

StatementList: Statement
			 | StatementList Statement
			 ;

Type: Int { $$ = new ParserVal(Tp_INT); }
	| Boolean { $$ = new ParserVal(Tp_BOOL); }
	| Int LSquareB RSquareB { $$ = new ParserVal(Tp_ARRAY); }
	| Ident { 
		TS_entry nodo = findInScope($1.sval, ClasseID.NomeClasse);
		if (nodo == null) {
			yyerror("variable " + $1.sval + " was already declared");
			$$ = new ParserVal(Tp_ERRO);
		} else {
			$$ = new ParserVal(nodo);
		}
	}
	;

Statement: LCurlyB StatementListOpt RCurlyB { System.out.println("\tStatement"); }
		 | If LPar Expression RPar Statement Else Statement { System.out.println("\tStatement"); }
		 | While LPar Expression RPar Statement { System.out.println("\tStatement"); }
		 | SystemOutPrintln LPar Expression RPar Semicolon { System.out.println("\tStatement"); }
		 | Ident Equals Expression Semicolon { System.out.println("\tStatement"); }
		 | Ident LSquareB Expression RSquareB Equals Expression Semicolon { System.out.println("\tStatement"); }
		 ;

Expression: Expression And Expression { System.out.println("\tExpression"); }
		  | Expression Less Expression { System.out.println("\tExpression"); }
		  | Expression Plus Expression { System.out.println("\tExpression"); }
		  | Expression Minus Expression { System.out.println("\tExpression"); }
		  | Expression Star Expression { System.out.println("\tExpression"); }
		  | Expression LSquareB Expression RSquareB { System.out.println("\tExpression"); }
		  | Expression Dot Length { System.out.println("\tExpression"); }
		  | Expression Dot Ident LPar ExpressionListOpt RPar { System.out.println("\tExpression"); }
		  | IntegerLiteral { System.out.println("\tExpression"); }
		  | True { System.out.println("\tExpression"); }
		  | False { System.out.println("\tExpression"); }
		  | Ident { System.out.println("\tExpression"); }
		  | This { System.out.println("\tExpression"); }
		  | New Int LSquareB Expression RSquareB { System.out.println("\tExpression"); }
		  | New Ident LPar RPar { System.out.println("\tExpression"); }
		  | Exclamation Expression { System.out.println("\tExpression"); }
		  | LPar Expression RPar { System.out.println("\tExpression"); }
		  ;

ExpressionListOpt: /*empty*/
			  | ExpressionList
			  ;

ExpressionList: Expression
			  | ExpressionList Comma Expression
			  ;
%%

public static TS_entry Tp_INT =  new TS_entry("int", null, ClasseID.TipoBase);
public static TS_entry Tp_ARRAY =  new TS_entry("array", null, ClasseID.TipoBase);
public static TS_entry Tp_BOOL = new TS_entry("bool", null,  ClasseID.TipoBase);
public static TS_entry Tp_ERRO = new TS_entry("_erro_", null,  ClasseID.TipoBase);

// apenas para a main
// note que 'void' nao eh um tipo base; ninguem pode ser void, exceto a main()
public static TS_entry Tp_VOID = new TS_entry("void", null,  null);

private MiniJavaLexer lexer;
private int current_token;
private ClasseID currClass;
private Stack<Scope> scopes;

private int yylex () {
    int yyl_return = -1;
    try {
      yyl_return = lexer.yylex();
	  current_token = yyl_return;
	  System.out.println(intToTokenStr(current_token));
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
		case 0: return "EOF";
	}
	return "?";
}

public void yyerror(String error) {
	System.err.println("Error: " + error + ", at line: " + lexer.line() + ", token: " + intToTokenStr(this.current_token));
}

private String printScopes() {
	return scopes.stream()
				.map(x -> {return x.desc;})
				.collect( Collectors.joining( "." ));
}

private TS_entry findInScope(String ident, ClasseID classId) {
	Scope s = scopes.stream()
					.filter(scope -> {
						return scope.symbols.pesquisa(ident) != null &&
							   scope.symbols.pesquisa(ident).getClasse() == classId;
						}
					)
					.findAny()
					.orElse(null);

    if (s == null)
		return null;
	
	return s.symbols.pesquisa(ident);
  }

public Parser(Reader r) {
	lexer = new MiniJavaLexer(r, this);
	current_token = -1;
	scopes = new Stack<Scope>();
	scopes.push(new Scope("TopLevel"));
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
