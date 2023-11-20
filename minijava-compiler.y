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

Goal : MainClass ClassDeclListOpt {
		 verifyDefferedClasses(); // check all functions that were used before being declared

		 if (nErrors > 0) {
		 	System.err.println("\n    !!!COMPILATION FAILED WITH " + nErrors + " ERRORS!!!");
		 } else {
		 	System.out.println("Success!!!");
		 }
	 }
     ;

MainClass: Class Ident LCurlyB {
		    // Como essa eh sempre a primeira coisa a ser declarada, nunca teremos um problema dos
			// identificadores jah existirem

			System.out.println("Inserindo classe '" + $2.sval + "' em: " + printScopes());
			TS_entry node = new TS_entry($2.sval, null, ClasseID.NomeClasse);
			scopes.peek().symbols.insert(node);
			System.out.println("Empilhando escopo: " + $2.sval);
			scopes.push(new Scope($2.sval, node));
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
					} else {
						System.out.println("Inserindo classe '" + $2.sval + "' em: " + printScopes());
						scopes.peek().symbols.insert(new TS_entry($2.sval, null, ClasseID.NomeClasse));
					}
					nodo = new TS_entry($2.sval, null, ClasseID.NomeClasse);
					System.out.println("Empilhando escopo: " + $2.sval);
					scopes.push(new Scope($2.sval, nodo));
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
					} else {
						TS_entry entry = new TS_entry($3.sval, (TS_entry)$2.obj);
						scopes.peek().symbols.insert(entry);
						System.out.println("Inserindo metodo '" + entry + "' em: " + printScopes());

						curMethod = entry;
						nearestClass().params_or_functions.add(entry);
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
		} else {
			TS_entry entry = new TS_entry($2.sval, (TS_entry)$1.obj,  ClasseID.NomeParam);
			scopes.peek().symbols.insert(entry);
			System.out.println("Inserindo parametro '" + entry + "' em: " + printScopes());
			curMethod.params_or_functions.add(entry);
		}
   }
   ;

VarOrStatement: /*empty*/
			  | Ident { varOrStatementIdent = $1; } NextVar
			  | Int Ident Semicolon {
			  		TS_entry nodo = findInScope($2.sval, ClasseID.NomeParam);
					if (nodo == null)
						nodo = findInScope($2.sval, ClasseID.VarLocal);

					if (nodo != null) {
						yyerror("identifier " + $2.sval + " was already declared");
					} else {
						TS_entry entry = new TS_entry($2.sval, Tp_INT,  ClasseID.VarLocal);
						scopes.peek().symbols.insert(entry);
						System.out.println("Inserindo variavel local '" + entry + "' em: " + printScopes());
					}
			  } VarOrStatement
			  | Int LSquareB RSquareB Ident Semicolon {
			  		TS_entry nodo = findInScope($4.sval, ClasseID.NomeParam);
					if (nodo == null)
						nodo = findInScope($4.sval, ClasseID.VarLocal);

					if (nodo != null) {
						yyerror("identifier " + $4.sval + " was already declared");
					} else {
						TS_entry entry = new TS_entry($2.sval, Tp_ARRAY,  ClasseID.VarLocal);
						scopes.peek().symbols.insert(entry);
						System.out.println("Inserindo variavel local '" + entry + "' em: " + printScopes());
					}
			  } VarOrStatement
			  | Boolean Ident Semicolon {
			  		TS_entry nodo = findInScope($2.sval, ClasseID.NomeParam);
					if (nodo == null)
						nodo = findInScope($2.sval, ClasseID.VarLocal);

					if (nodo != null) {
						yyerror("identifier " + $2.sval + " was already declared");
					} else {
						TS_entry entry = new TS_entry($2.sval, Tp_BOOL,  ClasseID.VarLocal);
						scopes.peek().symbols.insert(entry);
						System.out.println("Inserindo variavel local '" + entry + "' em: " + printScopes());
					}
			  } VarOrStatement
		 	  | If LPar Expression RPar Statement Else Statement StatementListOpt {
			  		typeCheck((TS_entry)$3.obj, Tp_BOOL);
			  }
		 	  | While LPar Expression RPar Statement StatementListOpt {
			  		typeCheck((TS_entry)$3.obj, Tp_BOOL);
				}
		 	  | SystemOutPrintln LPar Expression RPar Semicolon StatementListOpt {
			  		// println only prints ints in all example programs
			  		typeCheck((TS_entry)$3.obj, Tp_INT);
			  }
			  | LCurlyB StatementListOpt RCurlyB StatementListOpt
			  ;

NextVar: Ident Semicolon {
			TS_entry nodo = findInScope($1.sval, ClasseID.NomeParam);
			if (nodo == null)
				nodo = findInScope($1.sval, ClasseID.VarLocal);

			if (nodo != null) {
				yyerror("identifier " + $1.sval + " was already declared");
			} else {
				TS_entry classe = findInScope(varOrStatementIdent.sval, ClasseID.NomeClasse);
				if (classe == null) {
					classe = new TS_entry(varOrStatementIdent.sval, null, ClasseID.NomeClasse);
					defferedTypes.addClass(classe, lexer.line());
				}
				TS_entry entry = new TS_entry($1.sval, classe,  ClasseID.VarLocal);
				scopes.peek().symbols.insert(entry);
				System.out.println("Inserindo variavel local '" + entry + "' em: " + printScopes());
			}
	   } VarOrStatement
	   | Equals Expression Semicolon {
			TS_entry nodo = findInScope(varOrStatementIdent.sval, ClasseID.NomeParam);
			if (nodo == null)
				nodo = findInScope(varOrStatementIdent.sval, ClasseID.VarLocal);
			if (nodo == null)
				nodo = findInScope(varOrStatementIdent.sval, ClasseID.CampoClasse);

			if (nodo == null) {
				yyerror("identifier " + varOrStatementIdent.sval + " not found in scope!");
			} else {
				typeCheck((TS_entry)$2.obj, nodo.getTipo());
			}
	   } StatementListOpt
	   | LSquareB Expression RSquareB Equals Expression Semicolon StatementListOpt {
			TS_entry arr = findInScope(varOrStatementIdent.sval, ClasseID.NomeParam);
			if (arr == null)
				arr = findInScope(varOrStatementIdent.sval, ClasseID.VarLocal);
			if (arr == null)
				arr = findInScope(varOrStatementIdent.sval, ClasseID.CampoClasse);

			if (arr == null) {
				yyerror("identifier " + varOrStatementIdent.sval + " not found in scope!");
			} else if (typeCheck(arr.getTipo(), Tp_ARRAY)) {
				typeCheck((TS_entry)$2.obj, Tp_INT);
				typeCheck((TS_entry)$5.obj, Tp_INT);
			}
	   }
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
			nodo = new TS_entry($1.sval, null, ClasseID.NomeClasse);
			defferedTypes.addClass(nodo, lexer.line());
		}
		$$ = new ParserVal(nodo);
	}
	;

Statement: LCurlyB StatementListOpt RCurlyB
		 | If LPar Expression RPar Statement Else Statement {
			typeCheck((TS_entry)$3.obj, Tp_BOOL);
		 }
		 | While LPar Expression RPar Statement {
			typeCheck((TS_entry)$3.obj, Tp_BOOL);
		 }
		 | SystemOutPrintln LPar Expression RPar Semicolon {
			// println only prints ints in all example programs
			typeCheck((TS_entry)$3.obj, Tp_INT);
		 }
		 | Ident Equals Expression Semicolon {
			TS_entry nodo = findInScope($1.sval, ClasseID.NomeParam);
			if (nodo == null)
				nodo = findInScope($1.sval, ClasseID.VarLocal);
			if (nodo == null)
				nodo = findInScope($1.sval, ClasseID.CampoClasse);

			if (nodo == null) {
				yyerror("identifier " + $1.sval + " not found in scope!");
			} else {
				typeCheck((TS_entry)$3.obj, nodo.getTipo());
			}
		 }
		 | Ident LSquareB Expression RSquareB Equals Expression Semicolon {
			TS_entry arr = findInScope($1.sval, ClasseID.NomeParam);
			if (arr == null)
				arr = findInScope($1.sval, ClasseID.VarLocal);
			if (arr == null)
				arr = findInScope($1.sval, ClasseID.CampoClasse);

			if (arr == null) {
				yyerror("identifier " + $1.sval + " not found in scope!");
			} else if (typeCheck(arr.getTipo(), Tp_ARRAY)) {
				typeCheck((TS_entry)$3.obj, Tp_INT);
				typeCheck((TS_entry)$6.obj, Tp_INT);
			}
 }
		 ;

Expression: Expression And Expression {
		  		if (typeCheck((TS_entry)$1.obj, Tp_BOOL) && typeCheck((TS_entry)$3.obj, Tp_BOOL))
					$$ = new ParserVal(Tp_BOOL);
				else
					$$ = new ParserVal(Tp_ERRO);
			}
		  | Expression Less Expression {
		  		if (typeCheck((TS_entry)$1.obj, Tp_INT) && typeCheck((TS_entry)$3.obj, Tp_INT))
					$$ = new ParserVal(Tp_BOOL);
				else
					$$ = new ParserVal(Tp_ERRO);
			}
		  | Expression Plus Expression {
		  		if (typeCheck((TS_entry)$1.obj, Tp_INT) && typeCheck((TS_entry)$3.obj, Tp_INT))
					$$ = new ParserVal(Tp_INT);
				else
					$$ = new ParserVal(Tp_ERRO);
			}
		  | Expression Minus Expression {
		  		if (typeCheck((TS_entry)$1.obj, Tp_INT) && typeCheck((TS_entry)$3.obj, Tp_INT))
					$$ = new ParserVal(Tp_INT);
				else
					$$ = new ParserVal(Tp_ERRO);
			}
		  | Expression Star Expression {
		  		if (typeCheck((TS_entry)$1.obj, Tp_INT) && typeCheck((TS_entry)$3.obj, Tp_INT))
					$$ = new ParserVal(Tp_INT);
				else
					$$ = new ParserVal(Tp_ERRO);
			}
		  | Expression LSquareB Expression RSquareB {
		  		if (typeCheck((TS_entry)$1.obj, Tp_ARRAY) && typeCheck((TS_entry)$3.obj, Tp_INT))
					$$ = new ParserVal(Tp_INT);
				else
					$$ = new ParserVal(Tp_ERRO);
			}
		  | Expression Dot Length {
		  		if (typeCheck((TS_entry)$1.obj, Tp_ARRAY))
					$$ = new ParserVal(Tp_INT);
				else
					$$ = new ParserVal(Tp_ERRO);
		  }
		  | Expression Dot Ident LPar {
				TS_entry entry = ((TS_entry)$1.obj);
				if (entry.getClasse() != ClasseID.NomeClasse) {
					yyerror("type mismatch! Expected a class, found: " + ((TS_entry)$1.obj).getTipoStr());
					$$ = new ParserVal(Tp_ERRO);
				} else {
					entry = findInScope(entry.getId(), ClasseID.NomeClasse);
				    TS_entry found = null;
					for (int i = 0; i < entry.params_or_functions.size(); ++i) {
						if (entry.params_or_functions.get(i).getId().equals($3.sval)) {
							found = entry.params_or_functions.get(i);
						}
					}

					if (found == null) {
						// TODO: parameters
						found = new TS_entry($3.sval, Tp_ANY);
						defferedTypes.addFunctionToClass(entry, found, lexer.line());
					}
					// we use this to type check the paramenters
					methodCall.push(found);
					methodCallParam.push(0);
				}
		  } ExpressionListOpt RPar {
			methodCallParam.pop();
			$$ = new ParserVal(methodCall.pop().returnType);
		  }
		  | IntegerLiteral { $$ = new ParserVal(Tp_INT); }
		  | True { $$ = new ParserVal(Tp_BOOL); }
		  | False {  $$ = new ParserVal(Tp_BOOL); }
		  | Ident {
			TS_entry nodo = findInScope($1.sval, ClasseID.NomeParam);
			if (nodo == null)
				nodo = findInScope($1.sval, ClasseID.VarLocal);
			if (nodo == null)
				nodo = findInScope($1.sval, ClasseID.CampoClasse);

			if (nodo == null) {
				yyerror("identifier " + $1.sval + " not found in scope!");
				$$ = new ParserVal(Tp_ERRO);
			} else {
				$$ = new ParserVal(nodo.getTipo());
			}
		  }
		  | This {
			  $$ = new ParserVal(nearestClass());
			  System.out.println("this has type: " + nearestClass());
		  }
		  | New Int LSquareB Expression RSquareB {
			if (typeCheck((TS_entry)$4.obj, Tp_INT))
				$$ = new ParserVal(Tp_ARRAY);
			else
				$$ = new ParserVal(Tp_ERRO);
		  }
		  | New Ident LPar RPar {
				TS_entry nodo = findInScope($2.sval, ClasseID.NomeClasse);
				if (nodo == null) {
					nodo = new TS_entry($2.sval, null, ClasseID.NomeClasse);
					defferedTypes.addClass(nodo, lexer.line());
				}
				$$ = new ParserVal(nodo);
			}
		  | Exclamation Expression {
		  		if (typeCheck((TS_entry)$2.obj, Tp_BOOL))
					$$ = new ParserVal(Tp_BOOL);
				else 
					$$ = new ParserVal(Tp_ERRO);
			}
		  | LPar Expression RPar { $$ = $2; }
		  ;

ExpressionListOpt: /*empty*/
			  | ExpressionList
			  ;

ExpressionList: Expression {
				if (!methodCall.peek().returnType.equals(Tp_ANY)) {
					typeCheck((TS_entry)$1.obj, methodCall.peek().params_or_functions.get(methodCallParam.peek()).getTipo());
					methodCallParam.push(methodCallParam.pop() + 1);
				} else {
					methodCall.peek().params_or_functions.add((TS_entry)$1.obj);
				}
			  }
			  | ExpressionList Comma Expression {
				if (!methodCall.peek().returnType.equals(Tp_ANY)) {
					typeCheck((TS_entry)$3.obj, methodCall.peek().params_or_functions.get(methodCallParam.peek()).getTipo());
					methodCallParam.push(methodCallParam.pop() + 1);
				} else {
					methodCall.peek().params_or_functions.add((TS_entry)$3.obj);
				}
			  }
			  ;
%%

public static TS_entry Tp_INT =  new TS_entry("int", null, ClasseID.TipoBase);
public static TS_entry Tp_ARRAY =  new TS_entry("array", null, ClasseID.TipoBase);
public static TS_entry Tp_BOOL = new TS_entry("bool", null,  ClasseID.TipoBase);
public static TS_entry Tp_ERRO = new TS_entry("_erro_", null,  ClasseID.TipoBase);

// "ANY" é usado APENAS quando retornamos de funcoes ainda nao declaradas
public static TS_entry Tp_ANY = new TS_entry("ANY", null,  ClasseID.TipoBase);

// apenas para a main
// note que 'void' nao eh um tipo base; ninguem pode ser void, exceto a main()
public static TS_entry Tp_VOID = new TS_entry("void", null,  null);

private MiniJavaLexer lexer;
private int current_token;
private ClasseID currClass;
private Stack<Scope> scopes;

private ParserVal varOrStatementIdent;
private TS_entry curMethod;

private Stack<TS_entry> methodCall = new Stack<>();
private Stack<Integer> methodCallParam = new Stack<>();

private int nErrors = 0;

private DefferedTypes defferedTypes = new DefferedTypes();

private int yylex () {
    int yyl_return = -1;
    try {
      yyl_return = lexer.yylex();
	  current_token = yyl_return;
	  //System.out.println(intToTokenStr(current_token));
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
	System.err.println("ERROR: " + error + ", at line: " + lexer.line() + ", token: " + intToTokenStr(this.current_token));
	++nErrors;
}

private String printScopes() {
	return scopes.stream()
				.map(x -> {return x.desc;})
				.collect( Collectors.joining( "." ));
}

private TS_entry findInScope(String ident, ClasseID classId) {
	Stack<Scope> aux = new Stack<Scope>();
	TS_entry ret = null;
	while (!scopes.empty()) {
		Scope s = scopes.pop();
		aux.push(s);

		TS_entry symbol = s.symbols.pesquisa(ident);
		if (symbol != null && symbol.getClasse() == classId) {
			ret = symbol;
			break;
		}
	}

	while (!aux.empty())
		scopes.push(aux.pop());

	if (ret == null && classId == ClasseID.NomeClasse) {
		ArrayList<DefferedTypes.Class> classes = defferedTypes.getClasses();
		for (int i = 0; i < classes.size(); ++i) {
			if (classes.get(i).self.getId().equals(ident)) {
				ret = classes.get(i).self;
				break;
			}
		}
	} else if (ret == null && classId == ClasseID.NomeFuncao) {
		ArrayList<DefferedTypes.Function> functions = defferedTypes.getFunctions();
		for (int i = 0; i < functions.size(); ++i) {
			if (functions.get(i).self.getId().equals(ident)) {
				ret = functions.get(i).self;
				break;
			}
		}
	}

	return ret;
}

private TS_entry nearestClass() {
	Stack<Scope> aux = new Stack<Scope>();
	TS_entry ret = null;
	while (!scopes.empty()) {
		Scope s = scopes.pop();
		aux.push(s);

		if (s.classe != null) {
			ret = findInScope(s.classe.getId(), ClasseID.NomeClasse);
			break;
		}
	}

	while (!aux.empty())
		scopes.push(aux.pop());

	return ret;
}

private boolean typeCheck(TS_entry actual, TS_entry expected) {
	if (actual.equals(Tp_ANY)) {
		actual = expected;
		return true;
	}

	if (!actual.equals(expected)) {
		yyerror("type mismatch! Expected " + expected.getTipoStr() + ", found: " + actual.getTipoStr());
		return false;
	}

	return true;
}

private void defferedError(String error, int line) {
	System.err.println("ERROR: " + error + ", at line: " + line);
	++nErrors;
}

private void verifyDefferedClasses() {
	ArrayList<DefferedTypes.Class> classes = defferedTypes.getClasses();
	for (int i = 0; i < classes.size(); ++i) {
		DefferedTypes.Class expected = classes.get(i);

		TS_entry actual = findInScope(expected.self.getId(), ClasseID.NomeClasse);
		if (actual == null) {
			defferedError("class " + expected.self.getId() + " was never declared", expected.line);
		} else {
			verifyDefferedFunctions(expected.functions, actual);
		}
	}
}

private void verifyDefferedFunctions(ArrayList<DefferedTypes.Function> functions, TS_entry classe) {
	for (int i = 0; i < functions.size(); ++i) {
		DefferedTypes.Function expected = functions.get(i);
		
		TS_entry actual = null;
		for (int j = 0; j < classe.params_or_functions.size(); ++ j) {
			if (classe.params_or_functions.get(j).getId().equals(expected.self.getId())) {
				actual = classe.params_or_functions.get(j);
				break;
			}
		}

		if (actual == null) {
			defferedError("function " + expected.self.getId() + " for class " + classe.getId() + " was never declared", expected.line);
		} else {
			boolean correct_params = expected.self.params_or_functions.size() == actual.params_or_functions.size();
			if (correct_params) {
				for (int k = 0; k < actual.params_or_functions.size(); ++k) {
					correct_params = expected.self.params_or_functions.get(k).equals(actual.params_or_functions.get(k).getTipo());
				}
			}

			if (!correct_params) {
				String s = "function " + expected.self.getId() + " for class " + classe.getId() + " was expected to have parameters '";
				for (int k = 0; k < expected.self.params_or_functions.size(); ++k)
					s += expected.self.params_or_functions.get(k).getId() + " ";
				s += "', but it has '";
				for (int k = 0; k < actual.params_or_functions.size(); ++k)
					s += actual.params_or_functions.get(k).getId() + " ";
				s += "'";
				defferedError(s, expected.line);
			}
		}
	}
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
