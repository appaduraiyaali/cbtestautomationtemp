public class NextInvEstimate{
            public Map<String,Object> resp{get;set;}
            public List<BaseEstLineItem> cnl{get;set;}
            public Double total{get;set;}
            public String curCode{get;set;}
            public NextInvEstimate(Integer tot,String curCode){
                cnl = new List<BaseEstLineItem>();
                long tt = (long)(tot);
                total=ChargebeeUtil.convertToHigherOrderCurrency(curCode,tt);
                this.curCode=curCode;      
            }
            public void addLineItems(String ua,String quan,String descrip,String amt){
                BaseEstLineItem temp = new BaseEstLineItem(ua,quan,descrip,amt,curCode);   
                cnl.add(temp);
            }
            public NextInvEstimate(Map<String,Object> res){
                resp = res;
            }

        }