@IsTest public with sharing class ApiErrTest 
{
   
    @IsTest public static void noArg() 
     {
         APIError b = new APIError('hello');
         system.assertEquals(b.isErr, true);
     }
     
     
     
}