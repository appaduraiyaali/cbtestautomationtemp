public class CBSubscriptionUtil{

    public static String getEstimateEndPoint(CBURLUtil urlUtil, String contExtId){
        
        return urlUtil.getUrl()+'/api/v2/customers/'+contExtId+'/create_subscription_estimate?';
    }
    
    public static String getAddonURL(List<AddonObject> selList,String bodyData, Map<String,String> PlanExternalIdVsChargeModel, boolean canOverRide){
        
        for(Integer i=0,j=0;i<selList.size();i++)
        {
            AddonObject temp_add_obj = selList.get(i);
            System.debug('temp_add_obj addons--' + temp_add_obj);        
            if((temp_add_obj.status == 2 || temp_add_obj.status == 3) && !temp_add_obj.addon.equals('-1'))
            {
                bodyData = CBURLUtil.buildURLString(bodyData,'addons[id]['+j+']',temp_add_obj.addon);
                
                
                if(PlanExternalIdVsChargeModel != null && PlanExternalIdVsChargeModel.get(temp_add_obj.addon + '_CHARGE_MODEL') != null && PlanExternalIdVsChargeModel.get(temp_add_obj.addon + '_CHARGE_MODEL') != 'FLAT_FEE' && temp_add_obj.qty>0){
                    bodyData = CBURLUtil.buildURLString(bodyData,'addons[quantity]['+j+']',String.valueOf(temp_add_obj.qty));
                }
                
                if(canOverRide && temp_add_obj.price != null && !IsNewPricingModel(temp_add_obj.addon)){
                    bodyData = CBURLUtil.buildURLString(bodyData,'addons[unit_price]['+j+']',String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(temp_add_obj.addonCurrency, Double.valueOf(String.valueOf(temp_add_obj.price)))));
                }
                j++;
            }
        }
      return bodyData;
    }
    
    public static String getAddonURLWithOutMap(List<AddonObject> selList,String bodyData, boolean canOverRide){
        
        for(Integer i=0,j=0;i<selList.size();i++)
        {
            AddonObject temp_add_obj = selList.get(i);
            System.debug('temp_add_obj addons--' + temp_add_obj);        
            if((temp_add_obj.status == 2 || temp_add_obj.status == 3) && !temp_add_obj.addon.equals('-1'))
            {
                bodyData = CBURLUtil.buildURLString(bodyData,'addons[id]['+j+']',temp_add_obj.addon);
                
                
                if(!IsFlatFee(temp_add_obj.addon) && temp_add_obj.qty>0){
                    bodyData = CBURLUtil.buildURLString(bodyData,'addons[quantity]['+j+']',String.valueOf(temp_add_obj.qty));
                }
                
                if(canOverRide && temp_add_obj.price != null && !IsNewPricingModel(temp_add_obj.addon)){
                    bodyData = CBURLUtil.buildURLString(bodyData,'addons[unit_price]['+j+']',String.valueOf(ChargebeeUtil.convertToLowerOrderCurrency(temp_add_obj.addonCurrency, Double.valueOf(String.valueOf(temp_add_obj.price)))));
                }
                j++;
            }
        }
      return bodyData;
    }
    
    public static boolean IsNewPricingModel(String planId){
        if(planId != '-1'){
           
           Product2 selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,chargebeeapps__Addon_Type__c from Product2  where ExternalId =:planId];
           String plantype=selectedProduct.chargebeeapps__Addon_Type__c;
            return (plantype=='Tiered' || plantype=='Stairstep' || plantype=='Volume');
        }
        return false;
    }
    
    public static boolean IsFlatFee(String planId){
        if(planId != '-1'){
           
           Product2 selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,chargebeeapps__Addon_Type__c from Product2  where ExternalId =:planId];
           String plantype=selectedProduct.chargebeeapps__Addon_Type__c;
            return (plantype=='FLAT_FEE');
        }
        return false;
    }
    public static boolean isFlatPlan(String planId){
        if(planId != '-1'){
           
           Product2 selectedProduct = [Select Id,Product2.ExternalId,product2.chargebeeapps__Recurring_charge_model__c,chargebeeapps__Addon_Type__c from Product2  where ExternalId =:planId];
           String plantype=selectedProduct.chargebeeapps__Recurring_charge_model__c;
            return (plantype=='FLAT_FEE');
        }
        return false;
    }
    
    
    public static String getCreateSubscriptionEndPoint(CBURLUtil urlUtil, String contExtId){
        return urlUtil.getUrl()+'/api/v2/customers/'+contExtId+'/subscriptions';
    }
    
    public static String getListUnbilledChargesEndPoint(CBURLUtil urlUtil,string selectedSites ){
        urlUtil = new CBURLUtil(selectedSites);
        return urlUtil.getUrl()+'/api/v2/unbilled_charges';
    }
    public static String getListUnbilledChargesEndPoint(CBURLUtil urlUtil){
        urlUtil = new CBURLUtil();
        return urlUtil.getUrl()+'/api/v2/unbilled_charges';
    }
    
    public static String getUnbilledChargesEstimateEndPoint(CBURLUtil urlUtil,string selectedSites){
        urlUtil = new CBURLUtil(selectedSites);
        return urlUtil.getUrl()+'/api/v2/unbilled_charges/invoice_now_estimate';
    }
    public static String getUnbilledChargesEstimateEndPoint(CBURLUtil urlUtil){
        urlUtil = new CBURLUtil();
        return urlUtil.getUrl()+'/api/v2/unbilled_charges/invoice_now_estimate';
    }
    
    public static String getInvoiceUnbilledChargesEndPoint(CBURLUtil urlUtil){
        return urlUtil.getUrl()+'/api/v2/unbilled_charges/invoice_unbilled_charges';
    }
    
    public static String getCancelSubscriptionEndPoint(CBURLUtil urlUtil, String sub_id){
        return urlUtil.getUrl()+'/api/v2/subscriptions/'+EncodingUtil.urlEncode(sub_id,'UTF-8')+'/cancel';
    }
    
    public static String getUpdateTPEndPoint(CBURLUtil urlUtil){
        return urlUtil.getUrl()+'/api/v2/third_party_entity_mappings/update_entity';
    }
    
    public static String getSyncSubsEndPoint(CBURLUtil urlUtil){
        return urlUtil.getUrl()+'/salesfoce/api/sync_subscription';
    }
    
    public static String getImmediateChargeDisplayText(String curCode,Datetime sDate, Double tot){
        String immChargeStr = 'There will be no immediate charges.An invoice for '+curCode+' '+tot+' will be generated upon activation';
        immChargeStr += sDate!=null? ' on' +sDate : '';
        return immChargeStr;
    }
    
    public static String getInvDisplayText(String curCode,Double tot){
        return 'An invoice for '+curCode+' '+tot+' will be generated immediately.';
    }
    
    public static String getNoChargeDisplayText(){
        return 'There are no charges.';
    }
    
    public static String getNoChargeWithTotDisplayText(String curCode,Double tot){
        String noChargeStr = 'There are no charges. ';
        noChargeStr += tot!=null? 'An amount of '+curCode+' '+tot+' will be added to the upcoming invoice.' : '';
        return noChargeStr;
        //return 'There are no charges. An amount of '+curCode+' '+tot+' will be added to the upcoming invoice.';
    }
    
    public static DateTime getSubscriptionStartDate(String sDateStr){
        DateTime sDate;
        if(sDateStr!=null){
            sDateStr += ':00';
        }
        try{
        sDate = DateTime.newInstanceGmt(Integer.valueOf(sDateStr.subString(0,4)),
                    Integer.valueOf(sDateStr.subString(5,7)),Integer.valueOf(sDateStr.subString(8,10)),
                    Integer.valueOf(sDateStr.subString(11,13)),Integer.valueOf(sDateStr.subString(14,16)),
                    Integer.valueOf(sDateStr.subString(17,19)));
        
        }catch(exception e){
            sDate = system.now();
        }
        return sDate;
    }
    
    public static String getDataForTpSync(String opp_id, String bodyData,String stat){        
        return getDataForTpSyncForEntity(opp_id, bodyData, stat, 'subscription');
    }

    private static String getDataForTpSyncForEntity(String opp_id, String bodyData,String stat, String entityType){
        bodyData = CBURLUtil.buildURLString(bodyData,'entity_type',entityType);
        bodyData = CBURLUtil.buildURLString(bodyData,'integration_name','salesforce');
        bodyData = CBURLUtil.buildURLString(bodyData,'status',stat);
        bodyData = CBURLUtil.buildURLString(bodyData,'error_message','sync not started its done by SF');
        if(opp_id!=null && opp_id!='-1'){
            bodyData = CBURLUtil.buildURLString(bodyData,'mapping_meta','{"opp_id":"'+opp_id+'"}');
        }                
        return bodyData;
    }

    public static String getDataForTpSyncQuotes(String opp_id, String bodyData,String stat){
        return getDataForTpSyncForEntity(opp_id, bodyData, stat, 'quote');
    }
    
    public static String getCheckoutURL(CBURLUtil urlUtil,string selectedSites){
        urlUtil = new CBURLUtil(selectedSites);
        return urlUtil.getUrl()+'/api/v2/hosted_pages/checkout_new';
    }
    public static String getCheckoutURL(CBURLUtil urlUtil){
        urlUtil = new CBURLUtil();
        return urlUtil.getUrl()+'/api/v2/hosted_pages/checkout_new';
    }
    
    public static List<SelectOption> sortSelectOptions(List<SelectOption> sortingList) {
    for (Integer i =0; i < sortingList.size(); i++) {
        for (Integer j = i; j > 0; j--) {
            if (sortingList[j-1].getLabel() > sortingList[j].getLabel() && sortingList[j].getLabel() != 'Select' && sortingList[j-1].getLabel() != 'Select'){
                SelectOption temp = sortingList[j];
                sortingList[j] = sortingList[j-1];
                sortingList[j-1] = temp;
            }
        }
    }
    System.debug('after sort--' + sortingList);
    return sortingList;
    }
    
    public static List<SelectOption> getProductSelectOptions(String productType,String siteId,String currencyCode){
        System.debug('siteId - '+siteId+','+productType);
        Long benchMark=System.currentTimeMillis();
        List<PricebookEntry> prodList = new List<PricebookEntry>();
        System.debug('currencyCode - '+currencyCode);
        System.debug('siteId - '+siteId);
        if(currencyCode!=null){
            prodList = Database.query('Select id,Product2.ExternalId,product2.name From PricebookEntry  where Pricebook2.chargebeeapps__CB_Site__c =:siteId and product2.chargebeeapps__Status__c=\'ACTIVE\' and product2.chargebeeapps__Product_Type__c=:productType and PricebookEntry.CurrencyIsoCode=:currencyCode order by product2.name limit 999');
        }else{
            prodList = [Select id,Product2.ExternalId,product2.name From PricebookEntry  where Pricebook2.chargebeeapps__CB_Site__c=:siteId and product2.chargebeeapps__Status__c='ACTIVE' and product2.chargebeeapps__Product_Type__c=:productType order by product2.name limit 999];
        }
        
        System.debug('prodList size - '+prodList.size());
        List<SelectOption> options3 = new List<SelectOption>();
        options3.add(new SelectOption('-1','Select'));
        for(PricebookEntry temp : prodList){
            if(temp.Product2.ExternalId!= null){
                options3.add(new SelectOption(temp.Product2.ExternalId,temp.Product2.name));
            }
        }
        system.debug('get'+productType+'SelectOptions:'+(system.currentTimeMillis()-benchMark));
        return options3;
    }
}