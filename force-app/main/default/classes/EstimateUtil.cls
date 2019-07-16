public class EstimateUtil{

    public static String getTypeFromResponse(String resp){
    
        Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(resp);
        return (String)jsonMap.get('object');
    }
}