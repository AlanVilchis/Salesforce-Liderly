trigger QuoteLineItemTrigger on QuoteLineItem (after update) {
	 Set<Id> quoteIds = new Set<Id>();
    
    // Collect all unique Quote IDs from the new Quote Line Items
    for (QuoteLineItem qli : Trigger.new) {
        if(qli.Approved__c && qli.No_Clone__c){
        	quoteIds.add(qli.QuoteId);
        }
    }

    // For each Quote ID, call the PDF generation method if conditions are met
    for (Id quoteId : quoteIds) {
        
        generateQuotePdfDocument.createSingleQuotePdf(quoteId);
        //EmailHelper.triggerEmail();
    }
}