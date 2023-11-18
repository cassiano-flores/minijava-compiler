public class Scope {

  public TabSimb symbols;
  public final String desc; //descricao do scopo atual

  public Scope(String desc) {
    this.symbols = new TabSimb();
	this.desc = desc;
  }
}
