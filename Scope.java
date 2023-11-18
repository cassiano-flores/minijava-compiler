public class Scope {

  public TabSimb symbols;
  public final String desc; // descricao do scopo atual
  public final TS_entry classe; // classe, caso o escopo seja dentro de uma classe

  public Scope(String desc) {
    this.symbols = new TabSimb();
	this.desc = desc;
	this.classe = null;
  }

  public Scope(String desc, TS_entry classe) {
    this.symbols = new TabSimb();
	this.desc = desc;
	this.classe = classe;
  }
}
