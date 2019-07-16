@IsTest public class QuoteObjTest {
    
    public QuoteObjTest() {

    }

    @IsTest public static void testQuoteObj() {
        Map<String,Object> quoteMap = new Map<String, Object>();
        quoteMap.put('currency_code', 'USD');
        quoteMap.put('id','1');
        quoteMap.put('status', 'OPEN');
        quoteMap.put('operation_type', 'CREATE_SUBSCRIPTION_FOR_CUSTOMER');
        quoteMap.put('price_type', 'TAX_EXCLUSIVE');
        quoteMap.put('total', 300);
        quoteMap.put('sub_total', 200);
        quoteMap.put('amount_due', 100);
        quoteMap.put('valid_till', 1559819881L);
        quoteMap.put('vat_number', 'test');

        Map<String, Object> quoteLineItem = new Map<String, Object>();
        quoteLineItem.put('id', 'lineItemId1');
        quoteLineItem.put('unit_amount', 100);
        quoteLineItem.put('tax_amount', 100);
        quoteLineItem.put('quantity', 2);
        quoteLineItem.put('amount', 300);
        quoteLineItem.put('entity_type', 'plan');
        quoteLineItem.put('entity_id', 'planid');
        quoteLineItem.put('discount_amount', 100);
        quoteLineItem.put('item_level_discount_amount', 100);
        quoteLineItem.put('tax_exempt_reason', 'tax_exempt_reason');

        List<Map<String, Object>> quoteLineItems = new List<Map<String,Object>>();
        quoteLineItems.add(quoteLineItem);
        quoteMap.put('line_items', quoteLineItems);

        QuoteObj quoteObj = new QuoteObj(quoteMap);

        System.assertEquals(quoteObj.getCurCode(),'USD');
        System.assertEquals(quoteObj.getId(), '1');
        System.assertEquals(quoteObj.getStatus(), 'OPEN');
        System.assertEquals(quoteObj.getOperationType(), 'CREATE_SUBSCRIPTION_FOR_CUSTOMER');
        System.assertEquals(quoteObj.getPriceType(), 'TAX_EXCLUSIVE');
        System.assertEquals(quoteObj.getTotal(), 3);
        System.assertEquals(quoteObj.getSubTotal(), 2);
        System.assertEquals(quoteObj.getAmountDue(), 1);
        System.assertEquals(quoteObj.getValidTill(), 1559819881L);
        System.assertEquals(quoteObj.getVATNumber(), 'test');

        List<chargebeeapps.QuoteLineItemObj> lineItemObjs = quoteObj.getLineItems();
        System.assertEquals(lineItemObjs.size(), 1);

        System.assertEquals(lineItemObjs.get(0).getId(), 'lineItemId1');
        System.assertEquals(lineItemObjs.get(0).getUnitAmount(), 1);
        System.assertEquals(lineItemObjs.get(0).getTaxAmount(), 1);
        System.assertEquals(lineItemObjs.get(0).getQuantity(), 2);
        System.assertEquals(lineItemObjs.get(0).getAmount(), 3);
        System.assertEquals(lineItemObjs.get(0).getEntityType(), 'plan');
        System.assertEquals(lineItemObjs.get(0).getEntityId(), 'planid');
        System.assertEquals(lineItemObjs.get(0).getDiscountAmount(), 1);
        System.assertEquals(lineItemObjs.get(0).getItemLevelDiscountAmount(), 1);
        System.assertEquals(lineItemObjs.get(0).getTaxExemptReason(), 'tax_exempt_reason');
    }
}

