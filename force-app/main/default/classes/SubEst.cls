public class SubEst{
    public String Id{get;set;}
    public String status{get;set;}
    public String cc{get;set;}
    
    public SubEst(String id,String status,String ccode){
        Id=id;
        this.status=status;
        cc=ccode;
    }
    
    public static String getStyleClass(String st,String s){
         if(st=='in_trial')
         {
            s+= ' cb-status--trial';
         }else if(st=='future'){
             s+= ' cb-status--future';
         }
         return s;
    }
}