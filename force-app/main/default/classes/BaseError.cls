public virtual class BaseError{
    public String err_msg{get;set;}
    public boolean isErr{get;set;}
    
    public BaseError(){
        err_msg='';
        isErr=false;
    }
    
    public BaseError(String jstr){
        try{
            Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(jstr);
            
            if(jsonMap.get('error_msg')!=null){
                isErr=true;
                err_msg=(String)jsonMap.get('error_msg');
            }
        
        }catch(Exception e){
            isErr=true;
            err_msg=jstr;
            system.debug('catch err msg '+err_msg);
        }
        
    }
    
    public BaseError(Map<String,Object> jsonMap){
            this();
        system.debug('resp '+jsonMap);
            if(jsonMap.get('error_msg')!=null){
                system.debug('resp '+jsonMap);
                isErr=true;
                err_msg=(String)jsonMap.get('error_msg');
            }
    }
    
    public boolean hasError(){
        return isErr;
    }
    
    public void setAsEmpty(){
        err_msg='';
        isErr=false;
    }
    
    public void setError(String emsg){
        isErr=true;
        err_msg=emsg;
    }
    
    public String getError(){
        return err_msg;
    }

}