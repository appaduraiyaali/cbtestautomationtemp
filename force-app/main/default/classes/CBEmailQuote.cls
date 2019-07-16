public with sharing class CBEmailQuote{
    public chargebeeapps__CB_Quote__c quote{get;set;}
    public CBURLUtil urlUtil{get;set;}
    public String pre_message{get;set;}
    public String post_message{get;set;}
    public String values{get;set;}
    public String subject{get;set;}
    public List<Attachment> attachments{get;set;}
    public Map<String,Boolean> attachmentsMap{get;set;}
    public Map<String,Attachment> attachmentsObjectMap{get;set;}
    //public List<Messaging.EmailFileAttachment> emailAttachments;
    public BaseError er{get;set;}
    
    public CBEmailQuote(){
        String quoteId = ApexPages.currentPage().getParameters().get('id');
        quote = [select Id,chargebeeapps__CB_Site__c,chargebeeapps__Status__c,chargebeeapps__CB_Quote_Id__c,chargebeeapps__CustomerID__r.Email,chargebeeapps__CustomerID__r.Name,chargebeeapps__CustomerID__c from chargebeeapps__CB_Quote__c where Id=:quoteId];
        urlUtil = new CBURLUtil(SiteUtil.getSiteName(quote.chargebeeapps__CB_Site__c));
        pre_message = 'Dear '+quote.chargebeeapps__CustomerID__r.Name+',Please use the secure link below (valid for 24 hours) to accept the quote:';
        post_message = '\n\nIf you run into any issues, please contact us. \n\nThank you.';
        subject = 'Quote Email';
        attachments = [select Id,Name,ParentId,Body from Attachment where ParentId=:quoteId];
        attachmentsObjectMap = new Map<String,Attachment>();
        for(Attachment a:attachments){
             attachmentsObjectMap.put(a.Id,a);   
        }
        attachmentsMap = new Map<String,Boolean>();
        //emailAttachments = new List<Messaging.EmailFileAttachment>();
    }
    
    public PageReference precheck(){
        String quoteId = ApexPages.currentPage().getParameters().get('id');
        
        if(!urlUtil.isQuotesEnabled()){
            return UIUtil.redirectToGeneralErrorPage('QUOTES_DISABLED',quoteId);
        }
        if(!SiteUtil.sendQuoteEmailWithoutApproval(quote.chargebeeapps__CB_Site__c)){
             if(quote.chargebeeapps__Status__c!='approved'){
                return UIUtil.redirectToGeneralErrorPage('NOT_APPROVED',quoteId);
            }
        }    
        return null;    
    }
    
    public PageReference add(){
        String attachmentId=values;
        attachmentsMap.put(attachmentId,true);
        return null;
    }
    
    public PageReference remove(){
        String attachmentId=values;
        attachmentsMap.put(attachmentId,false);
        return null;
    }
    
    public PageReference send() {
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        
        
        // Create the email attachment
        Messaging.EmailFileAttachment[] attachmentsArray = new Messaging.EmailFileAttachment[getAttachmentSize()];
        Integer j=0;
        System.debug('attachmentsObjectMap - '+attachmentsObjectMap);
        for(String aId:attachmentsMap.keySet()){
            if(attachmentsMap.get(aId)==true){
            System.debug('aId - '+aId);
                attachmentsArray[j]=getEmailAttachment(attachmentsObjectMap.get(aId));
                j++;
            }
        }
        
        
        //Get acceptance link from chargebee
        String url='';
        if(SiteUtil.sendQuoteAcceptanceLinkInEmail(quote.chargebeeapps__CB_Site__c)){
             Map<String,Object> resp = getAcceptanceLink();
             er = new BaseError(resp);
             if(er.isErr){
                 return null;
             }
             url = (String)((Map<String,Object>)resp.get('hosted_page')).get('url');
             
        }
        String body = pre_message.replace('\n','<br>')+url+'<br>'+post_message.replace('\n','<br>');
        // Sets the paramaters of the email
        email.setSubject(subject);
        email.setToAddresses(new String[]{quote.chargebeeapps__CustomerID__r.Email});
        email.setPlainTextBody(body);
        email.setFileAttachments(attachmentsArray);
        email.setWhatId(quote.Id);
        email.setTargetObjectId(quote.chargebeeapps__CustomerID__c);
        email.setSaveAsActivity(true);

        // Sends the email
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        System.debug('r---'+r);
        if(!r[0].isSuccess()){
            Messaging.SendEmailError[] errs = r[0].getErrors();
            String error='';
            for(Integer i=0;i<errs.size();i++){
                error+=errs[i].getStatusCode()+' - '+errs[i].getMessage();
                error+=' ';
            }
            er = new BaseError(error);
            return null;
        }       
        
        return new PageReference('/'+quote.Id);
        
    }
    
    public Messaging.EmailFileAttachment getEmailAttachment(Attachment a){
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(a.Name+'.pdf');
        efa.setBody(a.body);
        return efa;
    }
    
    public Integer getAttachmentSize(){
        Integer k=0;
        for(String aId:attachmentsMap.keySet()){
            if(attachmentsMap.get(aId)==true){
                k++;
            }
        }
        return k;
    }
    
    public Map<String,Object> getAcceptanceLink(){
         EndPoint ep = EndPointsIndex.accept_quote;
         ep.domainName(SiteUtil.getSiteName(quote.chargebeeapps__CB_Site__c));
         GenericURLBuilder br = new GenericURLBuilder(ep);
         br.ustring=CBURLUtil.buildURLString(br.ustring,'quote[id]',quote.chargebeeapps__CB_Quote_Id__c);
         GenericController ctr = new GenericController(br);
         return ctr.makeRequest();
    }


}