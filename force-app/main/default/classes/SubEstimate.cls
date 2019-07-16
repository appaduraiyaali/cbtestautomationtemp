public class SubEstimate{
    public Map<String,Object> resp{get;set;}
    public List<BaseLineItem> lts{get;set;}
    
    public SubEstimate(Map<String,Object> res){
        resp = res;
        lts= new List<BaseLineItem>();
    }

}