public class QuoteLineItemObj {
    private Map<String,Object> response{get;set;}
    private String currencyCode{get;set;}
    
    public QuoteLineItemObj(String currencyCode, Map<String,Object> res){
        this.currencyCode = currencyCode;
        this.response = res;
    }

    public String getId(){
        return (String)response.get('id');
    }

    public Double getUnitAmount(){
        return ChargebeeUtil.convertToHigherOrderCurrency(currencyCode,(Long)response.get('unit_amount'));
    }

    public Double getTaxAmount(){
        return ChargebeeUtil.convertToHigherOrderCurrency(currencyCode,(Long)response.get('tax_amount'));
    }

    public Integer getQuantity(){
        return (Integer)response.get('quantity');
    }

    public Double getAmount(){
        return ChargebeeUtil.convertToHigherOrderCurrency(currencyCode,(Long)response.get('amount'));
    }

    public String getEntityType(){
        return (String)response.get('entity_type');
    }

    public String getEntityId(){
        return (String)response.get('entity_id');
    }

    public Double getDiscountAmount(){
        return ChargebeeUtil.convertToHigherOrderCurrency(currencyCode,(Long)response.get('discount_amount'));
    }

    public Double getItemLevelDiscountAmount(){
        return ChargebeeUtil.convertToHigherOrderCurrency(currencyCode,(Long)response.get('item_level_discount_amount'));
    }

    public String getTaxExemptReason(){
        return (String)response.get('tax_exempt_reason');
    }

}
