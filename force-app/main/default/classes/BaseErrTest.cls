@IsTest public with sharing class BaseErrTest 
{
    @IsTest public static void noArg() 
     {
         BaseError b = new BaseError();
         system.assertEquals(b.err_msg,'');
     }
     
     @IsTest public static void oneArg() 
     {
         BaseError b = new BaseError('{"order":{"addons":[{"amount":"300","charge_type":"recurring/non-recurring","tiers":[{"starting_quantity":"1","amount":"30","ending_quantity":"10","quantity_in_use":"3","unit_amount":"10"}],"quantity":"5","pricing_model":"flat_fee","added_type":"auto/manual","id":"chrismas","unit_amount":"100"}],"coupons":[{"id":"COUP1"}],"plan":{"amount":"300","tiers":[{"starting_quantity":"1","amount":"30","ending_quantity":"10","quantity_in_use":"3","unit_amount":"10"}],"quantity":"5","pricing_model":"flat_fee","id":"chrismas","unit_amount":"100","free_quantity":"2"}}}');
         system.assertEquals(b.err_msg, null);
     }
     
     @IsTest public static void oneStrArg() 
     {
         BaseError b = new BaseError('No Id present');
         b.setAsEmpty();
         b.setError('fdas sdf');
         system.assertEquals(b.err_msg,'fdas sdf');
     }
     
     @IsTest public static void oneObjArg() 
     {
         Map<String, Object> mp = CBURLUtil.convertMap('{"error_msg":"Not found"}');
         BaseError b = new BaseError(mp);
         b.hasError();
         b.getError();
         //system.assertEquals(b.isErr, true);
         system.assertEquals(b.err_msg, 'Not found');
     }
     
}