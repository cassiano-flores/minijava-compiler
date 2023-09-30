%{
import java.util.*;
%}

%token CLASS PUBLIC STATIC VOID MAIN STRING BOOLEAN INT IDENTIFIER INTEGER_LITERAL IF ELSE WHILE PRINTLN TRUE FALSE THIS NEW LENGTH

%left AND
%left LT PLUS MINUS
%left TIMES

%start Goal

%%

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

%%

class Parser {
    public static void main(String[] args) {
        System.out.println("MiniJava Parser");

        try {
            Parser parser = new Parser(System.in);
            parser.yyparse();
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    private Lexer lexer;

    private int yylex() throws IOException {
        return lexer.yylex();
    }

    public void yyerror(String error) {
        System.err.println("Error: " + error);
    }

    public Parser(InputStream input) {
        lexer = new Lexer(input);
    }
}
