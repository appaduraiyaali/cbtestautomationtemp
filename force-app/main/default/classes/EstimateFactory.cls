public class EstimateFactory{

    public static BaseEstimateResponse constructResponseObject(String response,String type){
        
        BaseEstimateResponse baseObj;
        switch on type
            {
                when 'unbilled_estimate'
                {
                     baseObj = new InvoiceUnbilledEstimate(response);
                     return baseObj;   
                }
                when 'updatesub_estimate'
                {
                     baseObj = new UpdateSubEstimate(response);
                     return baseObj;   
                }
                when else
                { 
                    return null;
                }
            } 
    }
}