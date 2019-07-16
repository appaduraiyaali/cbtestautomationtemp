public class QuoteObj{
    private Map<String,Object> response{get;set;}
    private String currencyCode{get;set;} 
    
    public QuoteObj(Map<String,Object> res){
        response = res;
        this.currencyCode = (String)response.get('currency_code');
    }
    
    public String getId(){
        return (String)response.get('id');
    }
    
    public String getStatus(){
        return (String)response.get('status');
    }
    
    public String getOperationType(){
        return (String)response.get('operation_type');
    }

    public String getPriceType() {
        return (String)response.get('price_type');
    }

    public Double getTotal(){
        return ChargebeeUtil.convertToHigherOrderCurrency(currencyCode,(Long)response.get('total'));
    }

    public Double getSubTotal() {
        return ChargebeeUtil.convertToHigherOrderCurrency(currencyCode,(Long)response.get('sub_total'));
    }

    public Double getAmountDue() {
        return ChargebeeUtil.convertToHigherOrderCurrency(currencyCode,(Long)response.get('amount_due'));
    }

    public String getCurCode(){
        return (String)response.get('currency_code');
    }

    public Long getValidTill() {
        return (Long)response.get('valid_till');
    }

    public String getVATNumber() {
        return (String)response.get('vat_number');
    }

    public List<QuoteLineItemObj> getLineItems() {

        List<QuoteLineItemObj> quoteLineItems = new List<QuoteLineItemObj>();
        for( Object o: (List<Object>)response.get('line_items')) {
            Map<String, Object> lineItemCBObj = (Map<String, Object>)o;
            QuoteLineItemObj quoteLineItem = new QuoteLineItemObj(currencyCode, lineItemCBObj);
            quoteLineItems.add(quoteLineItem);
        }
        return quoteLineItems;
    }
    
}