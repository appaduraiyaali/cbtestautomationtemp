public class GenericURLBuilder extends URLBuilder{
    
    private static final String amp='&';
    
    public GenericURLBuilder(){
        super();
    }
    
    public GenericURLBuilder(EndPoint ep){
        super(ep);
    }

    public void param(String key, String value) {
        if(ustring!='') {
			ustring+=amp;
		}
        ustring+=key+'='+value;
    }
}