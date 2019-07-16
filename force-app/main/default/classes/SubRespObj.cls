public class SubRespObj{
    public Map<String,Object> resp{get;set;}
    
    
    public SubRespObj(Map<String,Object> res){
        resp = res;
        
    }
    
    public String getId(){
        return (String)resp.get('id');
    }
    
    public String getStatus(){
        return (String)resp.get('status');
    }
    
    public String getPlanId(){
        return (String)resp.get('plan_id');
    }
    
    public String getCouponId(){
        return (String)resp.get('coupon');
    }
    
    public Integer getPlanQuan(){
        return (Integer)resp.get('plan_quantity');
    }
    
    public Double getPlanUnitPrice(){
        return ChargebeeUtil.convertToHigherOrderCurrency(getCurCode(),(Long)resp.get('plan_unit_price'));
    }
    
    public List<Object> getAddons(){
        return (List<Object>)resp.get('addons');
    }
    
    public List<AddonResp> getAddonObj(){
        if(getAddons()!=null){
            return constructObjects(getAddons());
        }else{
            return null;
        }
    }
    
    private List<AddonResp> constructObjects(List<Object> ob){
        List<AddonResp> addobjs = new List<AddonResp>();
        String curCode = getCurCode();
        Integer i=0;
        for(Object o:ob){
            
            String s = (String)((Map<String,Object>)o).get('id');
            Integer q = (Integer)((Map<String,Object>)o).get('quantity');
            Long up = (Long)((Map<String,Object>)o).get('unit_price');
            AddonResp arsp = new AddonResp(s,q,up,true,1,i,curCode); 
            addobjs.add(arsp);
            i++;
        }
        return addobjs;
    }
    private Map<String,Object> convertObj(Object o){
        return (Map<String,Object>)o;
    }
    public String getCurCode(){
        return (String)resp.get('currency_code');
    }

}