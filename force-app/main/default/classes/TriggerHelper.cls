public class TriggerHelper
{
        public Set<String> ids;
        public Map<String,Integer> submap ;
        public List<chargebeeapps__CB_Subscription__c> subs;
        public List<chargebeeapps__CB_Invoice__c> invs ;

        public TriggerHelper(){
            System.debug('jjkdjkjkdsjdskjsdjkdsjksdjkdsjksd');
            ids = new Set<String>();
            submap = new Map<String,Integer>();
            subs=new List<chargebeeapps__CB_Subscription__c>();
            invs = new List<chargebeeapps__CB_Invoice__c>();
        }
        
        public void action(List<chargebeeapps__CB_Invoice__c> invoices){
            for(chargebeeapps__CB_Invoice__c inv : invoices){
                String t = inv.chargebeeapps__SubscriptionId__c;
                if(!ids.contains(t)){
                    ids.add(t);
                }
            }
            subs = [select Id, chargebeeapps__Due_Invoices_Count__c from chargebeeapps__CB_Subscription__c where Id IN : ids];
            invs = [select Id,chargebeeapps__SubscriptionId__c ,chargebeeapps__Status__c from chargebeeapps__CB_Invoice__c where chargebeeapps__SubscriptionId__c IN:ids];
            for(chargebeeapps__CB_Invoice__c i : invs){
                System.debug('i.chargebeeapps__Status__c---' + i.chargebeeapps__Status__c);
                if(i.chargebeeapps__Status__c=='PAYMENT_DUE'){
                    if(submap.containsKey(i.chargebeeapps__SubscriptionId__c)){
                        Integer j=submap.get(i.chargebeeapps__SubscriptionId__c)+1;
                        submap.put(i.chargebeeapps__SubscriptionId__c,j);
                    }
                    else{
                        submap.put(i.chargebeeapps__SubscriptionId__c,1);
                    }
                }    
            }
            for(chargebeeapps__CB_Subscription__c s:subs){
                Integer k = submap.get(s.Id);
                s.chargebeeapps__Due_Invoices_Count__c=k;
            }
            update subs;        
        }

}