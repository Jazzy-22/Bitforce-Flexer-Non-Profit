@isTest
public with sharing class unsubscribeTest {
    @isTest
    static void testUnsubscribe() {

        // Create a new email and envelope object
           Messaging.InboundEmail email = new Messaging.InboundEmail() ;
           Messaging.InboundEnvelope env 	= new Messaging.InboundEnvelope();
        
        // Create a new test Lead and insert it in the Test Method        
           Lead l = new lead(firstName='Rasmus', 
                       lastName='Mencke',
                       Company='Salesforce', 
                       Email='rmencke@salesforce.com', 
                       HasOptedOutOfEmail=false);
           insert l;
        
        // Create a new test Contact and insert it in the Test Method  
           Contact c = new Contact(firstName='Rasmus', 
                           lastName='Mencke', 
                           Email='rmencke@salesforce.com', 
                           HasOptedOutOfEmail=false);
           insert c;
           
           // test with subject that matches the unsubscribe statement
           email.subject = 'test unsubscribe test';
           env.fromAddress = 'rmencke@salesforce.com';
           
           // call the class and test it with the data in the testMethod
           unsubscribe unsubscribeObj = new unsubscribe();
           unsubscribeObj.handleInboundEmail(email, env );
                                
           }
        @isTest
        static void testUnsubscribe2() {
        
        // Create a new email and envelope object
           Messaging.InboundEmail email = new Messaging.InboundEmail();
           Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Create a new test Lead and insert it in the Test Method        
           Lead l = new lead(firstName='Rasmus', 
                       lastName='Mencke',
                       Company='Salesforce', 
                       Email='rmencke@salesforce.com', 
                       HasOptedOutOfEmail=false);
           insert l;
        
        // Create a new test Contact and insert it in the Test Method    
           Contact c = new Contact(firstName='Rasmus', 
                           lastName='Mencke', 
                           Email='rmencke@salesforce.com', 
                           HasOptedOutOfEmail=false);
           insert c;
           
           // Test with a subject that does Not contain unsubscribe
           email.subject = 'test';
           env.fromAddress = 'rmencke@salesforce.com';
        
           // call the class and test it with the data in the testMethod
           unsubscribe unsubscribeObj = new unsubscribe();
           unsubscribeObj.handleInboundEmail(email, env );						
           }    
}