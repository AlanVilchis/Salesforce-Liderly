public class generateQuotePdfDocument {

    @InvocableMethod   
    public static void CreateQuote(List<Id> quoteIds) { 
        createQuoteFutureMethod(quoteIds);
    }
    
    @future(callout=true)
    public static void createQuoteFutureMethod(List<Id> quoteIds) {
        // Initialize the quote URL
        String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?';
        String quoteTemplateId = '0EHbm000007FODN';
        List<QuoteDocument> lstQuoteDoc = new List<QuoteDocument>();
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();


        if (!quoteIds.isEmpty()) {
            for (Id quoteId : quoteIds) {
                String currentQuoteUrl = quoteUrl + 'id=' + quoteId +
                    '&headerHeight=197&footerHeight=10' +
                    '&summlid=' + quoteTemplateId;

                PageReference pageRef = new PageReference(currentQuoteUrl);
                Blob quoteBlob;

                if (Test.isRunningTest()) {
                    quoteBlob = Blob.valueOf('Generate Pdf');
                } else {
                    quoteBlob = pageRef.getContentAsPDF();
                }

                QuoteDocument quoteDoc = new QuoteDocument();
                quoteDoc.Document = quoteBlob;
                quoteDoc.QuoteId = quoteId;
                lstQuoteDoc.add(quoteDoc);
                
                // Query the Quote to get the email address
                Quote quoteRecord = [SELECT Email FROM Quote WHERE Id = :quoteId LIMIT 1];

                // Create an email message and attach the PDF
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{quoteRecord.Email});
                email.setSubject('Your Payments PDF');
                email.setPlainTextBody('Please find attached the PDF for your payment details.');
                
                // Add the PDF as an attachment
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Quote_' + quoteId + '.pdf');
                attachment.setBody(quoteBlob);
                attachment.setContentType('application/pdf');
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});

                emails.add(email);
            }
        }

        if (!lstQuoteDoc.isEmpty()) {
            Database.insert(lstQuoteDoc);
        }
        
        // Send the emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
        
    }

    // Helper method to allow triggering PDF generation for a single Quote ID
    public static void createSingleQuotePdf(Id quoteId) {
        createQuoteFutureMethod(new List<Id> { quoteId });
    }
}