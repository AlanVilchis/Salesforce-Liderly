@isTest
public class QuoteLineItemTriggerTest {

    @testSetup
    static void setupTestData() {
        // Create an Account
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Create an Opportunity
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = account.Id
        );
        insert opportunity;
        
        Id priceBookID = Test.getStandardPricebookId();

        // Create a Quote with an Email address
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opportunity.Id,
            Email = 'test@example.com',
            Status = 'Draft',
            Pricebook2Id = priceBookID
        );
        insert quote;
        
        // Create a Product2
		Product2 product = new Product2(
    		Name = 'Product A',
    		Description = 'This is a test product',
    		IsActive = true  // Set the product as active
		);
        
        insert product;
        
        
        // Create a PricebookEntry for the Standard Price Book
        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = priceBookID, // Use the standard PriceBookId
            Product2Id = product.Id,           // Link to the Product2
            UnitPrice = 100.00,                 // Standard price
            IsActive = true
        );
        insert standardPricebookEntry;

    }

    @isTest
    static void testQuoteLineItemTrigger() {
        // Retrieve the setup data
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        Product2 testProd = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry testBook = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        // Insert a QuoteLineItem with No_Clone__c set to true
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = testQuote.Id,
            Product2Id = testProd.Id,
            PricebookEntryId = testBook.Id,
            Quantity = 1,
            UnitPrice = 100,
            No_Clone__c = true,
            Forma_Pago__c = 'Contado'
        );
        insert qli;
        qli.Approved__c = true;
        Test.startTest();
        update qli; // This should fire the trigger and generate the PDF
        Test.stopTest();
        
        // Verify that a QuoteDocument was created for the test Quote
        List<QuoteDocument> quoteDocuments = [SELECT Id, QuoteId FROM QuoteDocument WHERE QuoteId = :testQuote.Id];
        System.assertEquals(3, quoteDocuments.size(), 'A QuoteDocument should be created due to the trigger');

        // Mock Verification of Email Creation by checking the message content or count
        //System.assert(EmailHelper.emailWasSent, 'The email logic should have been triggered.');

    }
}