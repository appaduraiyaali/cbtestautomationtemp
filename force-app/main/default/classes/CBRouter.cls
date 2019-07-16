public with sharing class CBRouter
{
    
    public String acc_id {get;set;}
    public String con_id {get;set;}
    public String opp_id {get;set;}
    
    public List<SelectOption> options3 {get;set;}
    public String action {get;set;}
    public String from_page {get;set;}
    public String id {get;set;}
    public CBURLUtil util{get;set;}
    public String err_msg{get;set;}
    public Boolean empty{get;set;}
    public boolean isMultiSite{get;set;}
    public boolean disableSubscription{get;set;}
    public boolean disableCreateCon{get;set;}
    public String selectedSites{get;set;}
    public string domain{get;set;}
    public List<contact> conList{get;set;}
    public List<chargebeeapps__Contact_Associate_Site__c > existingConSite{get;set;} 
    public boolean isMultiple{get;set;}
    public List<selectOption> SiteDetails{get;set;}
    public String contact_site{get;set;}
    public String noContactError{get;set;}
    public String accountName{get;set;}

    public List<selectOption> fetchAllSites(){
        List<selectOption> multiSites = new List<selectOption>();
         Map<String,chargebeeapps__CB_Settings__c > sitedetails=CBURLUtil.getAllSiteDetails();
         for(chargebeeapps__CB_Settings__c  siteName:sitedetails.values())
         {
             string domain = siteName.Name;
             multiSites.add(new SelectOption(domain,domain));
             system.debug('SiteName:'+multiSites);
         }
         return multiSites;
    }
    public PageReference createSubscription()   
    {
        if(action == 'create_subscription'){
            String url;
            if(isAlreadySynched(con_id)){
                system.debug('update');
                //redirect to create subscription
                url = FlsUtil.getUrlMap().get('create_subscription_con');
                url = url +'?con_id='+con_id+'&domain='+selectedSites;
                
            }
            else
            {
                system.debug('Create');
                url = '/apex/CBNewCustomer?id='+con_id+'&action=create_sub&con_id='+con_id+'&domain='+selectedSites;
                if(opp_id!=null){url=url+'&opp_id='+opp_id;}
            }
            url = FlsUtil.safeUrl(url);
            PageReference pageRef = new PageReference('/'+url);  
            if(opp_id!=null)
            {
                pageRef.getParameters().put('opp_id',opp_id);
            }
            pageRef.setRedirect(true);
            return pageRef;
            return pageRef;
        }
        else{
            return null;
        }
    }

    public PageReference createQuote() {
        if(action == 'create_quote'){
            String url;
            if(isAlreadySynched(con_id)){
                system.debug('update');
                //redirect to create quote
                url = FlsUtil.getUrlMap().get('create_quote');
                url = url +'?con_id='+con_id+'&domain='+selectedSites;  
            }
            else
            {
                system.debug('Create');
                url = '/apex/CBNewCustomer?id='+con_id+'&action=create_quote&con_id='+con_id+'&domain='+selectedSites;
                if(opp_id!=null){url=url+'&opp_id='+opp_id;}
            }
            url = FlsUtil.safeUrl(url);
            PageReference pageRef = new PageReference('/'+url);  
            if(opp_id!=null)
            {
                pageRef.getParameters().put('opp_id',opp_id);
            }
            pageRef.setRedirect(true);
            return pageRef;
        }
        else{
            return null;
        }
    }
    public PageReference redirectContact()
    {
        
               //createSub = True;
               system.debug('test');
               String url = FlsUtil.getUrlMap().get('create_contact');
                url = url +acc_id+'&accid='+acc_id;
                system.debug('URL:'+url);
                url = FlsUtil.safeUrl(url);
               system.debug('URL:'+url);
               //string redirectPage = '/apex/CBNewCustomer?id='+con_id+'&action=create_sub&con_id='+con_id;
                PageReference pageRef = new PageReference('/'+url);
               return pageRef;
           
    }
    
    public CBRouter()
    {
        noContactError=null;
        //createSub = False;
        from_page = ApexPages.currentPage().getParameters().get('from');
        id = ApexPages.currentPage().getParameters().get('id');       
        util = new CBURLUtil();
        //Yaali: added start
        empty=false;
        isMultiSite=CBURLUtil.isMultiSite();
        SiteDetails = fetchAllSites();
        isMultiple=true;  
        
        //disableSub = true;
        //End
    }
    public PageReference redirectToError(String err)
    {
           PageReference pageRef = new PageReference('/apex/error');
           pageRef.getParameters().put('err',err);
           pageRef.setRedirect(true);
           return pageRef; 
    }   
    
    public PageReference route()
    {
         action = ApexPages.currentPage().getParameters().get('action');
        //actionName = action;
        if(action.equals('update_payment_method')){
            
            con_id = id;
            contact con = [SELECT id,Name FROM Contact WHERE id=:con_id];
            existingConSite = [SELECT Id,chargebeeapps__Contact__c ,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c  FROM chargebeeapps__Contact_Associate_Site__c WHERE chargebeeapps__Contact__c =: con_id ];
            String now = ApexPages.currentPage().getParameters().get('immediate');    
                String url='';
                if(existingConSite.size() == chargebeeapps__CB_Settings__c.getAll().size()||existingConSite.size()>0) // From Contact
                {
                    system.debug('existingConSite.size()');
                   url = FlsUtil.getUrlMap().get('update_payment_method');
                url = url +'?id='+con_id;
                if(now!=null){
                        url = url+'&immediate='+now;
                }
                url = FlsUtil.safeUrl(url);
                PageReference pageRef = new PageReference('/'+url);
                    
                pageRef.setRedirect(true);
                return pageRef;    
                }
            else if(existingConSite.size() == 0){
                err_msg='This customer is not present in chargebee.';   
                empty = true;
                  
            }
            else{
                return null;
                
            }
        }
        else if(action.equals('create_subscription') || action.equals('create_quote'))
        {
            if(from_page.equals('opp'))
            {
                
                   if(id == null)
                   {
                       id = ApexPages.currentPage().getParameters().get('opp_id');
                       system.debug('Opp id:'+id);
                       opp_id=id;
                   }
                   else
                   {
                       opp_id=id;
                   }
                
                    opp_id = String.escapeSingleQuotes(opp_id);
                    String que = 'select AccountId,Account.Name,Pricebook2Id from Opportunity where id=\''+opp_id+'\'';
                    Opportunity opp = Database.query(que); 
                    acc_id = opp.AccountId;
                    if(opp.AccountId==null){
                        empty=true;
                        return null;
                    }
                if(opp.Pricebook2Id!=null){
                    Pricebook2 pb=[select PriceBook2.chargebeeapps__CB_Site__r.Id, PriceBook2.chargebeeapps__CB_Site__r.Name from PriceBook2 where Id=:opp.Pricebook2Id];
                    selectedSites=pb.chargebeeapps__CB_Site__r.Name;
                    string pbSiteId = pb.chargebeeapps__CB_Site__r.Id;
                    system.debug('pbSiteId--'+pbSiteId);
                    contact_site='and id IN (select chargebeeapps__Contact__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__CB_Site__c=:pbSiteId)';
                    conList =[SELECT Id,AccountId FROM Contact WHERE AccountId =:acc_id and Id IN (select chargebeeapps__Contact__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__CB_Site__c=:pb.chargebeeapps__CB_Site__r.Id)];
                    isMultiple=false;
                    accountName=opp.Account.Name;
                }
                else{
                    conList =[SELECT Id,AccountId FROM Contact WHERE AccountId =:acc_id];
                }
                system.debug(conList);
                if(conList.size() == 0)
                {
                    disableCreateCon = true;
                    disableSubscription = true && action.equals('create_subscription');
                }
                else
                {
                    disableCreateCon = false;
                    disableSubscription = false;
                }
                List<String> fields1 = new List<String> {'AccountId'};
                if(!FlsUtil.isPermitable(fields1,'opportunity'))
                {
                    String fs = FlsUtil.getNotAccessibleFields(fields1,'opportunity','access');
                    redirectToError(fs);
                }   
            }
            else if(from_page.equals('acc'))
            {
                acc_id = id;
                
                conList =[SELECT Id,AccountId FROM Contact WHERE AccountId =:acc_id];
                system.debug(conList);
                if(conList.size() == 0)
                {
                    disableCreateCon = true;
                    disableSubscription = true;
                }
                else
                {
                    disableCreateCon = false;
                    disableSubscription = false;
                }
                
            }
            else if(from_page.equals('con'))
            {
                con_id = id;
                system.debug('contact:'+con_id);
                contact con = [SELECT id,Name FROM Contact WHERE id=:con_id];
                List<String> fields1 = new List<String> {'id','Name','chargebeeapps__External_Id__c'};
                if(!FlsUtil.isPermitable(fields1,'contact'))
                {
                    String fs = FlsUtil.getNotAccessibleFields(fields1,'contact','access');
                    redirectToError(fs);
                }
                List<String> fields2 = new List<String> {'chargebeeapps__Contact__c','chargebeeapps__External_Id__c','chargebeeapps__CB_Site__c'};
                    if(!FlsUtil.isPermitable(fields2,'chargebeeapps__Contact_Associate_Site__c'))
                {
                    String fs = FlsUtil.getNotAccessibleFields(fields2,'chargebeeapps__Contact_Associate_Site__c','access');
                    PageReference redirecterr = redirectToError(fs);
                    return redirecterr;
                }
                String url='';
                if(isAlreadySynched(con_id)){
                    //redirect to create subscription
                    url = FlsUtil.getUrlMap().get('create_subscription_con');
                    url = url +'?con_id='+con_id;
                    if(opp_id != null){
                        url=url+'&opp_id='+opp_id;
                    }
                }else{
                    url = '/apex/CBNewCustomer?id='+con_id+'&action=create_sub';
                    System.debug('from_page.equals con-----' + url);
                }
                url = FlsUtil.safeUrl(url);
                PageReference pageRef = new PageReference('/'+url);
                pageRef.setRedirect(true);
                return pageRef;       
            }
            if(con_id == null)
            {
                options3 = new List<SelectOption>();
                List<String> fields1 = new List<String> {'id','Name', 'AccountId'};
                if(!FlsUtil.isPermitable(fields1,'contact'))
                {
                    String fs = FlsUtil.getNotAccessibleFields(fields1,'contact','access');
                    redirectToError(fs);
                }
                List<String> fields2 = new List<String> {'chargebeeapps__Contact__c','chargebeeapps__External_Id__c','chargebeeapps__CB_Site__c'};
                    if(!FlsUtil.isPermitable(fields2,'chargebeeapps__Contact_Associate_Site__c'))
                {
                    String fs = FlsUtil.getNotAccessibleFields(fields2,'chargebeeapps__Contact_Associate_Site__c','access');
                    redirectToError(fs);
                }
                acc_id = String.escapeSingleQuotes(acc_id);
                system.debug('Accid:'+acc_id);
                String que = 'select id,Name from Contact where AccountId=\''+acc_id+'\'';
                if(contact_site!=null){
                    que=que+' '+contact_site;
                }
                //List<Contact> cons_list = [ select id,Name from Contact where AccountId=:acc_id];
                List<Contact> cons_list = Database.query(que);
                system.debug('cons_list-- '+cons_list);
                if(cons_list.size()<1 && contact_site!=null && opp_id!=null){
                    noContactError='yes';
                    options3.add(new SelectOption('-1','No contacts found'));
                }
                if(cons_list.size()==1)
                {
                    con_id = cons_list.get(0).id;
                    System.debug('Id:'+id + 'conId:'+con_id);
                    String url;
                    
                    if(isAlreadySynched(con_id)){
                        //redirect to create subscription
                        if(action.equals('create_subscription')) {
                            url = FlsUtil.getUrlMap().get('create_subscription_con');
                        } else {
                            url = FlsUtil.getUrlMap().get('create_quote');
                        }
                    }else{
                        if(action.equals('create_subscription')) {
                            url = '/apex/CBNewCustomer?id='+con_id+'&action=create_sub';
                        } else {
                            url = '/apex/CBNewCustomer?id='+con_id+'&action=create_quote';
                        }
                    }
                    url = url +'?con_id='+con_id;
                    if(opp_id!=null){
                        url=url+'&opp_id='+opp_id;
                    }
                    if(contact_site!=null){
                        url=url+'&domain='+selectedSites;
                    }
                    url = FlsUtil.safeUrl(url);
                    PageReference pageRef = new PageReference('/'+url);
                    pageRef.setRedirect(true);
                    return pageRef;
                }
                for(Integer i=0;i<cons_list.size();i++)
                {
                    List<String> sts = getSites(cons_list.get(i).id);
                    String addstr = sts.size()>0?'('+String.join(sts,',')+')':'';
                    options3.add(new SelectOption(cons_list.get(i).id+'',cons_list.get(i).Name+addstr));
                }
            }
            
        }else if(action.equals('add_charge')){
            String subPk = ApexPages.currentPage().getParameters().get('sub_id');
            String url = '/apex/Add_Charge?sub_id='+EncodingUtil.urlEncode(id,'UTF-8')+'&pk=' + subPk;
            url = FlsUtil.safeUrl(url);
            PageReference pageRef = new PageReference('/'+url);
            return pageRef;
        }else if(action.equals('change_renewal_date')){
            String subPk = ApexPages.currentPage().getParameters().get('sub_id');
            String url = '/apex/ChangeNextRenewalDate?sub_id='+EncodingUtil.urlEncode(id,'UTF-8')+'&pk=' + subPk;
            url = FlsUtil.safeUrl(url);
            PageReference pageRef = new PageReference('/'+url);
            return pageRef;
        }else if(action.equals('cancel_sub')){
            String subPk = ApexPages.currentPage().getParameters().get('sub_id');
            String url = '/apex/Cancel_subscription?sub_id='+id+'&pk=' + subPk;
            url = FlsUtil.safeUrl(url);
            PageReference pageRef = new PageReference('/'+url);
            return pageRef;
        }        
        return null;
    
    }
    public PageReference syncInvCount()
    {
            chargebeeapps__CB_Subscription__c sub = [select Id, chargebeeapps__CB_Subscription_Id__c,chargebeeapps__Due_Invoices_Count__c,chargebeeapps__CB_Site__c from chargebeeapps__CB_Subscription__c where Id =: id];
            util = new CBURLUtil(SiteUtil.getSiteName(sub.chargebeeapps__CB_Site__c));
            String endpoint = util.getUrl()+'/api/v2/subscriptions/'+EncodingUtil.urlEncode(sub.chargebeeapps__CB_Subscription_Id__c,'UTF-8');
            System.debug('-------'+endpoint);
            String res= CBURLUtil.sendRequest(endpoint,null,util,true,'GET');
            System.debug('-------'+res);
            Map<String, Object> responseMap = CBURLUtil.convertMap(res);
            try{
                Map<String, Object> s = (Map<String, Object>)responseMap.get('subscription');
                Integer count = (Integer)s.get('due_invoices_count');
                System.debug('------'+count);
                if(Schema.sObjectType.chargebeeapps__CB_Subscription__c.fields.chargebeeapps__Due_Invoices_Count__c.isUpdateable()){
                    sub.chargebeeapps__Due_Invoices_Count__c=count;
                    
                }
                update sub;
            }
            catch(Exception e)
            {
                System.debug('------'+res);
            }
            PageReference pageRef = new PageReference('/'+id);
            pageRef.setRedirect(true);
            return pageRef;
    }
    public PageReference backToContact(){
        return new PageReference('/'+con_id);
        
    }
    public List<String> getSites(String contact_id){
        List<chargebeeapps__Contact_Associate_Site__c> syncedSites = [SELECT Id,chargebeeapps__Contact__c ,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c  FROM chargebeeapps__Contact_Associate_Site__c WHERE chargebeeapps__Contact__c =: contact_id ];
        List<String> sites = new List<String>();
        for(chargebeeapps__Contact_Associate_Site__c  site:syncedSites)
         {
             string domain = SiteUtil.getSiteName(site.chargebeeapps__CB_Site__c);
             sites.add(domain);
         }
         return sites;
    }
    
    public PageReference handleContact(){
        List<chargebeeapps__Contact_Associate_Site__c> syncedSites = [SELECT Id,chargebeeapps__Contact__c ,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c  FROM chargebeeapps__Contact_Associate_Site__c WHERE chargebeeapps__Contact__c =: con_id ];       
        if(syncedSites.size()==1 || contact_site!=null){
            isMultiple=false;
        }else if(syncedSites.size()>1){
            isMultiple=true;
            SiteDetails = getSelectList(syncedSites);
        }else{
            isMultiple=true;
            SiteDetails=fetchAllSites();
        }
        
        return null;
    
    }
    
    public List<selectOption> getSelectList(List<chargebeeapps__Contact_Associate_Site__c> sites){
        List<selectOption> multiSites = new List<selectOption>();
         
         for(chargebeeapps__Contact_Associate_Site__c  site:sites)
         {
             string domain = SiteUtil.getSiteName(site.chargebeeapps__CB_Site__c);
             multiSites.add(new SelectOption(domain,domain));
             
         }
         return multiSites;
    }
    
    public PageReference ToCreateSub(String contId){
            String url = FlsUtil.getUrlMap().get('create_subscription_con');
            url = url +'?con_id='+contId;
            if(opp_id!=null){
                url=url+'&opp_id='+opp_id;
            }
            url = FlsUtil.safeUrl(url);
            PageReference pageRef = new PageReference('/'+url);
            pageRef.setRedirect(true);
            return pageRef;
    }
    
    
    private boolean isAlreadySynched(String contactId){
        
        List<String> fields1 = new List<String> {'Id','Name'};
        if(!FlsUtil.isPermitable(fields1,'contact'))
        {
            String fs = FlsUtil.getNotAccessibleFields(fields1,'contact','access');
            redirectToError(fs);   
        }
        
        List<String> fields2 = new List<String> {'chargebeeapps__Contact__c','chargebeeapps__External_Id__c','chargebeeapps__CB_Site__c'};
        if(!FlsUtil.isPermitable(fields2,'chargebeeapps__Contact_Associate_Site__c'))
        {
           String fs = FlsUtil.getNotAccessibleFields(fields2,'chargebeeapps__Contact_Associate_Site__c','access');
           redirectToError(fs);
        }
        
        //query for CB Contact Sites
        contactId = String.escapeSingleQuotes(contactId);
        String que = 'select Id,chargebeeapps__Contact__c,chargebeeapps__External_Id__c,chargebeeapps__CB_Site__c from chargebeeapps__Contact_Associate_Site__c where chargebeeapps__Contact__c=\''+contactId+'\'';
        List<chargebeeapps__Contact_Associate_Site__c> presentSites = Database.query(que);
       
        return presentSites.size()>0;
    }


}