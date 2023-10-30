import java.util.Stack;

public class Scope {

    public Stack<TabSimb> symbols;

    public Scope() {
        this.symbols = new Stack<TabSimb>();
    }
}
