public class UpdateSubEstResponse{
    public Map<String,Object> resp{get;set;}
    public UpdateSubEstResponse(Map<String,Object> res){
        resp = res;
    }
    
    public List<CBProd> getSubEstimate(String curCode,String siteId){
        List<CBProd> cbp = new List<CBProd>();
        Map<String,Object> order = (Map<String,Object>)resp.get('order');
        Map<String,Object> lt = (Map<String,Object>)order.get('plan');
        String unitAmount = String.valueOf(((Map<String, Object>)lt).get('unit_amount'));
        String quantity =   String.valueOf(((Map<String, Object>)lt).get('quantity'));
        String amt = String.valueOf(((Map<String, Object>)lt).get('amount'));
        String descrip = String.valueOf(((Map<String, Object>)lt).get('id'));
        Product2 p=[select Id,Name,ProductCode from Product2 where ProductCode=:descrip];
        cbp.add(new CBProd(unitAmount,quantity,p.Name,amt,curCode,'Plan',''));
        List<Object> addns = (List<Object>)order.get('addons');
        if(addns!=null){
            for(Object lte:addns){
                String uniAmount = String.valueOf(((Map<String, Object>)lte).get('unit_amount'));
                String quan =   String.valueOf(((Map<String, Object>)lte).get('quantity'));
                String am = String.valueOf(((Map<String, Object>)lte).get('amount'));
                String de = String.valueOf(((Map<String, Object>)lte).get('id'));
                String ct = String.valueOf(((Map<String, Object>)lte).get('charge_type'));
                Product2 pt=[select Id,Name,ProductCode from Product2 where ProductCode=:de];            
                cbp.add(new CBProd(uniAmount,quan,pt.Name,am,curCode,'Addon',ct));
            }
        }
        List<Object> cpns = (List<Object>)order.get('coupons');
        if(cpns!=null){
            for(Object c:cpns){
                String de = String.valueOf(((Map<String, Object>)c).get('id'));          
                chargebeeapps__Coupon__c pt=[select Id,Name,chargebeeapps__CB_Coupon_Id__c from chargebeeapps__Coupon__c where chargebeeapps__CB_Coupon_Id__c=:de and chargebeeapps__CB_Site__c=:siteId];            
                cbp.add(new CBProd('0','coupon',pt.Name,'0',curCode,'Coupon',''));
            }
        }
        //List<Object> addns = (List<Object>)order.get('coupons');
        
        
        
        return cbp;
    }
    
    public InvEstimate getNextInvEst(String key){
        if(resp.get(key)!=null){
            
            Map<String,Object> iest=null;
            if(key=='immediate_invoice_estimate'){
                 if(((Map<String,Object>)resp.get(key)).isEmpty()){
                     return null;
                 }
                 iest=(Map<String,Object>)resp.get(key);
                    
            }else{
                if(((List<Object>)resp.get(key)).isEmpty()){
                     return null;
                 }
                List<Object> lst = (List<Object>)resp.get(key);
                iest = (Map<String,Object>)lst[0];
            }
            InvEstBuilder b=InvEstimate.builder();
            b.currency(String.valueOf(iest.get('currency_code'))).recur(Boolean.valueOf(iest.get('recurring'))).subTot((Long)iest.get('sub_total')).tot((Long)iest.get('total')).credApp((Long)iest.get('credits_applied')).amountDue((Long)iest.get('amount_due')).amountPaid((Long)iest.get('amount_paid'));
            
            InvEstimate ie = b.build();
            List<Object> lineItems = new List<Object>();
            lineItems = (List<Object>)iest.get('line_items');
            for(Object lt:lineItems){
                    String unitAmount = String.valueOf(((Map<String, Object>)lt).get('unit_amount'));
                    String quantity =   String.valueOf(((Map<String, Object>)lt).get('quantity'));
                    String amt = String.valueOf(((Map<String, Object>)lt).get('amount'));
                    String descrip = String.valueOf(((Map<String, Object>)lt).get('description'));
                    String et = String.valueOf(((Map<String, Object>)lt).get('entity_type'));
                    String e_id = String.valueOf(((Map<String, Object>)lt).get('entity_id'));
                    String disc_amt = String.valueOf(((Map<String, Object>)lt).get('discount_amount'));
                    String dfrom = String.valueOf(((Map<String, Object>)lt).get('date_from'));
                    String dto = String.valueOf(((Map<String, Object>)lt).get('date_to'));
                    ie.addLte(unitAmount,quantity,descrip,amt,disc_amt,dfrom,dto,et,e_id);
            }
            List<Object> discs = (List<Object>)iest.get('discounts');
                if(discs!=null && !discs.equals('[]')){
                    for(Object lt:discs){   
                        String amt = String.valueOf(((Map<String, Object>)lt).get('amount'));
                        String descrip = String.valueOf(((Map<String, Object>)lt).get('description'));
                        ie.addDisc(descrip,amt);
                    }         
                }
            ie.setDisc();        
            return ie;              
        }else{
            return null;
        }
    }
    
    public List<CreditNoteEstimate> getCreditEst(){
        
        if(resp.get('credit_note_estimates')!=null && !((List<Object>)resp.get('credit_note_estimates')).isEmpty()){
            
            List<CreditNoteEstimate> cne = new List<CreditNoteEstimate>();
            List<Object> lst = (List<Object>)resp.get('credit_note_estimates');
            for(Object o:lst){
                Map<String,Object> iest = (Map<String,Object>)o;
                CreditNoteEstBuilder b=CreditNoteEstimate.builder();
                b.currency(String.valueOf(iest.get('currency_code'))).refId(String.valueOf(iest.get('reference_invoice_id'))).type((String)iest.get('type')).tot((Long)iest.get('total')).subTot((Long)iest.get('sub_total')).amtAlloc((Long)iest.get('amount_allocated'));
                
                CreditNoteEstimate ie = b.build();
                List<Object> lineItems = new List<Object>();
                lineItems = (List<Object>)iest.get('line_items');
                for(Object lt:lineItems){
                        String unitAmount = String.valueOf(((Map<String, Object>)lt).get('unit_amount'));
                        String quantity =   String.valueOf(((Map<String, Object>)lt).get('quantity'));
                        String amt = String.valueOf(((Map<String, Object>)lt).get('amount'));
                        String descrip = String.valueOf(((Map<String, Object>)lt).get('description'));
                        String et = String.valueOf(((Map<String, Object>)lt).get('entity_type'));
                        String e_id = String.valueOf(((Map<String, Object>)lt).get('entity_id'));
                        String disc_amt = String.valueOf(((Map<String, Object>)lt).get('discount_amount'));
                        String dfrom = String.valueOf(((Map<String, Object>)lt).get('date_from'));
                        String dto = String.valueOf(((Map<String, Object>)lt).get('date_to'));
                        ie.addLte(unitAmount,quantity,descrip,amt,disc_amt,dfrom,dto,et,e_id);
                }
                List<Object> discs = (List<Object>)iest.get('discounts');
                if(discs!=null && !discs.equals('[]')){
                    for(Object lt:discs){   
                        String amt = String.valueOf(((Map<String, Object>)lt).get('amount'));
                        String descrip = String.valueOf(((Map<String, Object>)lt).get('description'));
                        ie.addDisc(descrip,amt);
                    }         
                }
                ie.setDisc();  
                cne.add(ie);
            }
            
            return cne;              
        }else{
            return null;
        }
    }
    
    public List<UnbilledEstimate> getUnbilledEst(){
        Map<String, Object> res = (Map<String, Object>)resp.get('estimate');
        if(res!=null){
            if(res.get('unbilled_charge_estimates')!=null && !((List<Object>)res.get('unbilled_charge_estimates')).isEmpty()){
                
                List<UnbilledEstimate> cne = new List<UnbilledEstimate>();
                List<Object> lst = (List<Object>)res.get('unbilled_charge_estimates');
                for(Object o:lst){
                    Map<String,Object> lt = (Map<String,Object>)o;
    
                    
                            String unitAmount = String.valueOf(((Map<String, Object>)lt).get('unit_amount'));
                            String quantity =   String.valueOf(((Map<String, Object>)lt).get('quantity'));
                            String amt = String.valueOf(((Map<String, Object>)lt).get('amount'));
                            String descrip = String.valueOf(((Map<String, Object>)lt).get('description'));
                            String et = String.valueOf(((Map<String, Object>)lt).get('entity_type'));
                            String e_id = String.valueOf(((Map<String, Object>)lt).get('entity_id'));
                            String disc_amt = String.valueOf(((Map<String, Object>)lt).get('discount_amount'));
                            String dfrom = String.valueOf(((Map<String, Object>)lt).get('date_from'));
                            String dto = String.valueOf(((Map<String, Object>)lt).get('date_to'));
                            String cCode = String.valueOf(((Map<String, Object>)lt).get('currency_code'));
                            Boolean isv = Boolean.valueOf(((Map<String, Object>)lt).get('is_voided'));
                            Boolean del = Boolean.valueOf(((Map<String, Object>)lt).get('deleted'));
                            cne.add(new UnbilledEstimate(unitAmount,quantity,descrip,amt,disc_amt,cCode,dfrom,dto,et,e_id,isv,del));
                     
                    
                }
                
                return cne;              
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    
    public String getNewStatus(){
        Map<String, Object> res = (Map<String, Object>)resp.get('estimate');
        if(res!=null){
            Map<String, Object> subres = (Map<String, Object>)res.get('subscription_estimate');
            if(subres!=null){
                return (String)subres.get('status');
            }else{
                return null;
            }    
        }else{
            return null;
        }
    
    }

}