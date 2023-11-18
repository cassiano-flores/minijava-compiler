import java.util.ArrayList;

/**
 * Write a description of class Paciente here.
 * 
 * @author (your name)
 * @version (a version number or a date)
 */
public class TS_entry {

  private String id;
  private ClasseID classe;
  private TS_entry tipo;

  // usado em classes e funcoes
  public ArrayList<TS_entry> params_or_functions;

  // apenas para funcoes
  public TS_entry returnType;

  public TS_entry(String umId, TS_entry umTipo, ClasseID umaClasse) {
    this.id = umId;
    this.tipo = umTipo;
    this.classe = umaClasse;
	this.returnType = null;
	this.params_or_functions = new ArrayList<TS_entry>();
  }

  // construtor para funcoes
  public TS_entry(String umId, TS_entry returnType) {
    this.id = umId;
    this.tipo = null;
    this.classe = ClasseID.NomeFuncao;
	this.params_or_functions = new ArrayList<TS_entry>();
	this.returnType = returnType;
  }

  public String getId() {
    return id;
  }

  public TS_entry getTipo() {
    return tipo;
  }

  public ClasseID getClasse() {
    return classe;
  }

  public String toString() {
    StringBuilder aux = new StringBuilder("");

    aux.append("Id: ");
    aux.append(id);

    aux.append(", Classe: ");
    aux.append(classe);
    aux.append(", Tipo: ");
    aux.append(tipo2str(this.tipo));

    return aux.toString();
  }

  public String getTipoStr() {
    return tipo2str(this);
  }

  public String tipo2str(TS_entry tipo) {
    if (tipo == null) {
		if (classe == ClasseID.NomeClasse)
			return "class";
		else if (classe == ClasseID.NomeFuncao)
			return "function";
		else
			return "null";
	} else if (tipo == Parser.Tp_INT)
      return "int";
    else if (tipo == Parser.Tp_BOOL)
      return "boolean";
    else if (tipo == Parser.Tp_ERRO)
      return "_erro_";
    else {
	  if (tipo.classe == ClasseID.NomeClasse) {
			return "class " + tipo.id;
	  } else if (tipo.classe == ClasseID.NomeFuncao) {
			return "function " + tipo.id;
	  } else {
			return "erro/tp";
	  }
	}
  }
}
