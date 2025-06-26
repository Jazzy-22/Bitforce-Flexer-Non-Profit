@isTest
public with sharing class segmentsControllerTest {
    @isTest
    static void segmentation() {
        
        String stringSegments = '3';
        Integer segments = 3;
        Integer contacts = 10;
        //create a campaign
        Campaign parentCampaign = new Campaign(
            name='Parent for test',
            IsActive=true
        );
        
        insert parentCampaign;
        
        List<Contact> newContacts = new List<Contact>();
        
        
        //create 10 contacts
        for (Integer contactNumber=0; contactNumber<contacts;contactNumber++){
            Contact thisContact = new Contact(
                LastName='test' + contactNumber
            );
            newContacts.add(thisContact);
        }
        insert newContacts;
        
        List<CampaignMember> myCampaignMembers = new List<CampaignMember>();
        
        //add them to campaign
        for(contact thisContact : newContacts){
            CampaignMember thisCM = new CampaignMember(
                CampaignId=parentCampaign.Id,
                ContactId = thisContact.Id
            );
            myCampaignMembers.add(thisCM);
                    
        }
        
        insert myCampaignMembers;
        
         Test.setCurrentPageReference(new PageReference('Page.segments'));
         
         ApexPages.StandardController sc = new ApexPages.standardController(parentCampaign);
        //pass the controller into the extension
        segmentsController ext = new segmentsController(sc); 
        ext.stringSegments = stringSegments;
        ext.setSegments();
        
        ext.listOfSegments[0].targetMemberCount = 1;
        ext.listOfSegments[1].targetMemberCount = 2;
        ext.listOfSegments[2].targetMemberCount = 7;
        ext.keepOriginal = false;
        Test.startTest();
        ext.runSegments();
        Test.stopTest();
        List<Campaign> createdCampaigns = [select id,NumberOfContacts from Campaign where ParentId = :parentCampaign.id order by Name];
        Campaign parentCampaignAfter = [select NumberOfContacts from Campaign where Id=:parentCampaign.Id];
        
        System.assertEquals(segments,createdCampaigns.size());
        System.assert(createdCampaigns[0].NumberOfContacts==1);
        System.assert(createdCampaigns[1].NumberOfContacts==2);
        System.assert(createdCampaigns[2].NumberOfContacts==7);
        System.assertEquals(contacts,createdCampaigns[0].NumberOfContacts + createdCampaigns[1].NumberOfContacts + createdCampaigns[2].NumberOfContacts);
        System.assertEquals(0,parentCampaignAfter.NumberOfContacts);
        
    }
    
    @isTest
    static void BIGsegmentation() {
        
        String stringSegments = '3';
        Integer segments = 3;
        Integer contacts = 200;
        //create a campaign
        Campaign parentCampaign = new Campaign(
            name='Parent for test',
            IsActive=true
        );
        
        insert parentCampaign;
        
        List<Contact> newContacts = new List<Contact>();
        
        
        //create contacts
        for (Integer contactNumber=0; contactNumber<contacts;contactNumber++){
            Contact thisContact = new Contact(
                LastName='test' + contactNumber
            );
            newContacts.add(thisContact);
        }
        insert newContacts;
        
        List<CampaignMember> myCampaignMembers = new List<CampaignMember>();
        
        //add them to campaign
        for(contact thisContact : newContacts){
            CampaignMember thisCM = new CampaignMember(
                CampaignId=parentCampaign.Id,
                ContactId = thisContact.Id
            );
            myCampaignMembers.add(thisCM);
                    
        }
        
        insert myCampaignMembers;
        
         Test.setCurrentPageReference(new PageReference('Page.segments'));
         
         ApexPages.StandardController sc = new ApexPages.standardController(parentCampaign);
        //pass the controller into the extension
        segmentsController ext = new segmentsController(sc); 
        ext.stringSegments = stringSegments;
        ext.MAX_SYNCHRONOUS_MEMBERS = 200;
        ext.setSegments();
        ext.keepOriginal = false;
        
        ext.listOfSegments[0].targetMemberCount = 20;
        ext.listOfSegments[1].targetMemberCount = 100;
        ext.listOfSegments[2].targetMemberCount = 80;
        Test.startTest();
        ext.runSegments();
        Test.stopTest();
        List<Campaign> createdCampaigns = [select id,NumberOfContacts from Campaign where ParentId = :parentCampaign.id order by Name];
        Campaign parentCampaignAfter = [select NumberOfContacts from Campaign where Id=:parentCampaign.Id];
        
        System.assertEquals(segments,createdCampaigns.size());
        System.assert(createdCampaigns[0].NumberOfContacts==20);
        System.assert(createdCampaigns[1].NumberOfContacts==100);
        System.assert(createdCampaigns[2].NumberOfContacts==80);
        System.assertEquals(contacts,createdCampaigns[0].NumberOfContacts + createdCampaigns[1].NumberOfContacts + createdCampaigns[2].NumberOfContacts);
        System.assertEquals(0,parentCampaignAfter.NumberOfContacts);
        
    }
    @isTest
    static void noMembers() {
        
        //create a campaign
        Campaign parentCampaign = new Campaign(
            name='Parent for test',
            IsActive=true
        );
        
        insert parentCampaign;
        
         Test.setCurrentPageReference(new PageReference('Page.segments'));
         
         ApexPages.StandardController sc = new ApexPages.standardController(parentCampaign);
        //pass the controller into the extension
        segmentsController ext = new segmentsController(sc); 
        
        
        System.assertEquals(false,ext.showSegmentsPicker);
        System.assertEquals(false,ext.showSegmentCreator);
        
        
    }

    @isTest
    static void tooManySegments() {
        String stringSegments = '300';
        Integer segments = 300;
        Integer contacts = 10;
        //create a campaign
        Campaign parentCampaign = new Campaign(
            name='Parent for test',
            IsActive=true
        );
        
        insert parentCampaign;
        
        List<Contact> newContacts = new List<Contact>();
        
        
        //create 10 contacts
        for (Integer contactNumber=0; contactNumber<contacts;contactNumber++){
            Contact thisContact = new Contact(
                LastName='test' + contactNumber
            );
            newContacts.add(thisContact);
        }
        insert newContacts;
        
        List<CampaignMember> myCampaignMembers = new List<CampaignMember>();
        
        //add them to campaign
        for(contact thisContact : newContacts){
            CampaignMember thisCM = new CampaignMember(
                CampaignId=parentCampaign.Id,
                ContactId = thisContact.Id
            );
            myCampaignMembers.add(thisCM);
                    
        }
        
        insert myCampaignMembers;
        
         Test.setCurrentPageReference(new PageReference('Page.segments'));
         
         ApexPages.StandardController sc = new ApexPages.standardController(parentCampaign);
        //pass the controller into the extension
        segmentsController ext = new segmentsController(sc); 
        ext.stringSegments = stringSegments;
        ext.setSegments();
        
        system.assertEquals(0,ext.listOfSegments.size());       
    }
    
    @isTest
    static void memberStatusCloning() {
        String stringSegments = '3';
        Integer segments = 3;
        Integer contacts = 10;
        //create a campaign
        Campaign parentCampaign = new Campaign(
            name='Parent for test',
            IsActive=true
        );
        
        insert parentCampaign;
        
        insert new CampaignMemberStatus(CampaignId = parentCampaign.Id,Label = 'NewStatus', HasResponded=true,SortOrder=10);
                
        List<Contact> newContacts = new List<Contact>();
        
        
        //create 10 contacts
        for (Integer contactNumber=0; contactNumber<contacts;contactNumber++){
            Contact thisContact = new Contact(
                LastName='test' + contactNumber
            );
            newContacts.add(thisContact);
        }
        insert newContacts;
        
        List<CampaignMember> myCampaignMembers = new List<CampaignMember>();
        
        //add them to campaign
        for(contact thisContact : newContacts){
            CampaignMember thisCM = new CampaignMember(
                CampaignId=parentCampaign.Id,
                ContactId = thisContact.Id
            );
            myCampaignMembers.add(thisCM);
                    
        }
        
        insert myCampaignMembers;
        
         Test.setCurrentPageReference(new PageReference('Page.segments'));
         
         ApexPages.StandardController sc = new ApexPages.standardController(parentCampaign);
        //pass the controller into the extension
        segmentsController ext = new segmentsController(sc); 
        ext.stringSegments = stringSegments;
        ext.setSegments();
        
        ext.listOfSegments[0].targetMemberCount = 1;
        ext.listOfSegments[1].targetMemberCount = 2;
        ext.listOfSegments[2].targetMemberCount = 7;
        
        ext.runSegments();
        List<Campaign> createdCampaigns = [select id,NumberOfContacts from Campaign where ParentId = :parentCampaign.id order by Name];
        Campaign parentCampaignAfter = [select NumberOfContacts from Campaign where Id=:parentCampaign.Id];
        
        List<CampaignMemberStatus> statusesOnParent = [SELECT Id, CampaignId, HasResponded, Label, IsDefault,SortOrder from CampaignMemberStatus WHERE CampaignId = :parentCampaign.id];
        
        List<CampaignMemberStatus> statusesOnChildren = [SELECT Id, CampaignId, HasResponded, Label, IsDefault,SortOrder from CampaignMemberStatus WHERE CampaignId IN (select id from Campaign where ParentId = :parentCampaign.id)];
        
        System.assertEquals(3,statusesOnParent.size());
        System.assertEquals(9,statusesOnChildren.size());
        
    }
    
    @isTest
    static void UICalcs() {
        String stringSegments = '3';
        Integer segments = 3;
        Integer contacts = 10;
        //create a campaign
        Campaign parentCampaign = new Campaign(
            name='Parent for test',
            IsActive=true
        );
        
        insert parentCampaign;
        
        List<Contact> newContacts = new List<Contact>();
        
        
        //create 10 contacts
        for (Integer contactNumber=0; contactNumber<contacts;contactNumber++){
            Contact thisContact = new Contact(
                LastName='test' + contactNumber
            );
            newContacts.add(thisContact);
        }
        insert newContacts;
        
        List<CampaignMember> myCampaignMembers = new List<CampaignMember>();
        
        //add them to campaign
        for(contact thisContact : newContacts){
            CampaignMember thisCM = new CampaignMember(
                CampaignId=parentCampaign.Id,
                ContactId = thisContact.Id
            );
            myCampaignMembers.add(thisCM);
                    
        }
        
        insert myCampaignMembers;
        
         Test.setCurrentPageReference(new PageReference('Page.segments'));
         
         ApexPages.StandardController sc = new ApexPages.standardController(parentCampaign);
        //pass the controller into the extension
        segmentsController ext = new segmentsController(sc); 
        ext.stringSegments = stringSegments;
        ext.setSegments();
        ext.resetSegments();
        ext.stringSegments = stringSegments;
        ext.setSegments();
        system.assertEquals(3,ext.listOfSegments.size());   
        ext.listOfSegments[0].targetMemberCount = 1;
        ext.listOfSegments[1].targetMemberCount = 2;
        ext.listOfSegments[2].targetMemberCount = 7;
        
        ext.cancel();

    }

}