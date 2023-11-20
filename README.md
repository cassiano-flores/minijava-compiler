## Integrantes:

-   Cassiano Luis Flores Michel – 20204012-7
-   José Eduardo Rodrigues Serpa – 20200311-7
-   Leonardo Gibrowski Faé – 20280524-8

## Instruções de uso:

### Para Linux:

-   `./build` para compilar o parser
-   `java Parser [NOME-ARQUIVO]` para testar

### IMPORTANTE:

**O programa `TreeVisitor.java` não funciona porque não implementamos herança.**

Para testar os erros, modifique os programas de exemplo **E REDIRECIONE STDOUT**:

`java Parser [NOME-ARQUIVO] > /dev/null`

Imprimimos todos os erros para stderr. Assim, será possível de ver apenas os erros gerados.

Normalmente, imprimimos muito mais do que os erros para stdout, para ser mais fácil de testar,
e também para mostrar para o Professor como o programa está funcionando. Entretanto, isso tem a 
consequência de poluir a saída quando apenas se quer ver os erros gerados.
