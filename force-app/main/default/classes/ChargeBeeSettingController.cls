public with sharing class ChargeBeeSettingController {

 public CustomSettingProxy setting{get; set;}
 public String overRideAllowed{get;set;}
 public String autoCollection{get;set;} 
 public List<SelectOption> autoCollOptions{get;set;}
 public String hostedPageVersion{get;set;} 
 public List<SelectOption> hostedPages{get;set;}
 public boolean isMultiSite{get;set;}
 
 public Boolean displaySettingData{get;set;}
 public string selectedSite{get;set;}
 public string selectedValue{get;set;}
 public String errorMessage{get;set;}
    public ChargeBeeSettingController() 
    {
     
         autoCollOptions = new List<SelectOption>();
         autoCollOptions.add(new SelectOption('OFF','OFF'));
         autoCollOptions.add(new SelectOption('ON','ON'));
         
         hostedPages = new List<SelectOption>();
         hostedPages.add(new SelectOption('V3','V3 Hostedpage'));
         hostedPages.add(new SelectOption('V2','V2 HostedPage'));       
         isMultiSite=CBURLUtil.isMultiSite();
         if(isMultiSite == false){            
            loadDefaultSetting();
         }
         
         
    }
    public PageReference ToError()
    {
           PageReference pageRef = new PageReference('/apex/error');
           pageRef.setRedirect(true);
           return pageRef; 
    }
public String getHostedPageVersion(){
     String temp = setting.siteSetting;
     if(temp != null){
         Map<String, String> b = (Map<String,String>) JSON.deserialize(temp, Map<String,String>.class);
         System.debug(b);
         if(b.get('useV3UpdatePayment') != null && b.get('useV3UpdatePayment').equals('V3')){
             hostedPageVersion = 'V3';
         }
         else{
             hostedPageVersion = 'V2';
         }
     }
     return hostedPageVersion;
 }
     
public String isOverRideAllowed(){
     String temp = setting.siteSetting;
     if(temp != null){
         Map<String, String> b = (Map<String,String>) JSON.deserialize(temp, Map<String,String>.class);
         System.debug(b);
         if(b.get('isOverRide') != null && b.get('isOverRide').equals('true')){
             overRideAllowed = 'Enabled';
         }
         else{
             overRideAllowed = 'Disabled';
         }
     }
     return overRideAllowed;
 }
    public String autoCollection(){
     String temp = setting.siteSetting;
     if(temp != null){
         Map<String, String> b = (Map<String,String>) JSON.deserialize(temp, Map<String,String>.class);
         System.debug(b);
         if(b.get('autoCollectionFlag') != null){
             autoCollection = b.get('autoCollectionFlag');
         }
         else{
             autoCollection = 'ON';
         }
     }
     return autoCollection;
 }
    
 public List<selectOption> getSiteDetails()
 {
     
     List<selectOption> multiSites = new List<selectOption>();
     Map<String, chargebeeapps__CB_Settings__c > sitedetails=CBURLUtil.getAllSiteDetails();
     for(CB_Settings__c siteName:sitedetails.values())
     {
         string domain = siteName.Name;
         multiSites.add(new SelectOption(domain,domain));
         system.debug('SiteName:'+multiSites);
     }
     return multiSites;
 }   
 
 
 
    public PageReference showRelatedData()
    {   
        displaySettingData=true;       
        system.debug('selected value:'+selectedSite ); 
        
        if(selectedSite == 'None'){
            system.debug('none');
             errorMessage=' Please select a domain to get the domain details';
             displaySettingData=false;
             system.debug(errorMessage);
        }
        
        else{
            errorMessage ='';
            setting = new CustomSettingProxy(selectedSite);
            
            overRideAllowed = isOverRideAllowed();
            autoCollection = autoCollection();
            hostedPageVersion = getHostedPageVersion();  
        } 
        
        
        return null;
        
    }
    
    public void loadDefaultSetting()
    {
        
        setting = new CustomSettingProxy();
        displaySettingData=true;       
        overRideAllowed = isOverRideAllowed();
        autoCollection = autoCollection();
        hostedPageVersion = getHostedPageVersion();
    }   
    
    

public class CustomSettingProxy {
        public String apikey {get;set;}
        public String chargebeeurl {get;set;}
        public String username {get;set;}
        public String siteSetting {get;set;}
        chargebeeapps__CB_Settings__c mhc{get;set;}
        CBURLUtil urlutil;
        
        public CustomSettingProxy(String domainName) {
            try{
                urlutil = new CBURLUtil(domainName);                
            }catch(Exception e){
                System.debug('-err---' + e);
            }
            System.debug('--->>' + mhc);
            initializeSetting();
        }
    
        public CustomSettingProxy() {
            try{
                urlutil = new CBURLUtil();                
            }catch(Exception e){
                System.debug('-err---' + e);
            }
            System.debug('--->>' + mhc);            
            initializeSetting();
        }
        
        private void initializeSetting()
        {
            if(urlutil!=null)
            {
            
                this.apikey= urlutil.getApiKey();
                if(this.apikey!=null){	
                    string secretApiKey=this.apikey.substring(0,10);	
                    for(integer i=0;i<this.apikey.length()-10;i++){	
                        secretApiKey+='*';	
                    }	
                    this.apikey=secretApiKey;	
                }
                this.username = urlutil.getUserName();
                this.chargebeeurl = urlutil.getUrl();
                this.siteSetting = urlutil.getSiteSettingJSON(); 
            } 
            else{
                this.apikey= '';
                this.username = '';
                this.chargebeeurl = '';
                this.siteSetting = null; 
            }          
        }
    
        public PageReference redirectToError()
        {
            system.debug('Error');
           PageReference pageRef = new PageReference('/apex/error');
           pageRef.setRedirect(true);
           return pageRef; 
        }

    }

   
   }