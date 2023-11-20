import java.util.ArrayList;

// Helper class for dealing with functions and classes that are used
// before they are declared
//
// IMPORTANT: in here, classes CAN be declared twice. We will simply
// verify them both times in the end
public class DefferedTypes {
	public class Class {
	    public TS_entry self;
	    public int line; // line this class was used
	    public ArrayList<Function> functions;
	
	    public Class(TS_entry self, int line) {
			this.self = self;
			this.line = line;
			this.functions = new ArrayList<Function>();
	    }
	}
	
	public class Function {
	    public TS_entry self;
	    public int line; // line this function was used

	    public Function(TS_entry self, int line) {
	  	  this.self = self;
	  	  this.line = line;
	    }
	}
	
	// All classes used before they were declared
	private ArrayList<Class> classes;
	
	// Functions used before they were declared IN CURRENT SCOPE
	private ArrayList<Function> functions;
	
	public void addClass(TS_entry c, int line) {
	    this.classes.add(new Class(c, line));
	}
	
	public void addFunction(TS_entry function, int line) {
	    this.functions.add(new Function(function, line));
	}

	public void addFunctionToClass(TS_entry c, TS_entry function, int line) {
	    boolean found = false;
	    for (int i = 0; i < this.classes.size(); ++i) {
	  	  if (this.classes.get(i).self.getId().equals(c.getId())) {
	  		  this.classes.get(i).functions.add(new Function(function, line));
	  		  found = true;
	  	  }
	    }
	
	    if (!found) {
	  	  Class newClass = new Class(c, line);
	  	  newClass.functions.add(new Function(function, line));
	  	  this.classes.add(newClass);
	    }
	}

	public ArrayList<Function> getFunctions() {
		return this.functions;
	}

	public void clearFuntions() {
		this.functions.clear();
	}

	public ArrayList<Class> getClasses() {
		return this.classes;
	}
}
