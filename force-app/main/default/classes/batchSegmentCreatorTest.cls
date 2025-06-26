@isTest
public class batchSegmentCreatorTest {
    @isTest
    static void testBatch() {
        Integer segments = 2;
        Integer contacts = 200;
        Campaign parentCampaign = new Campaign(Name = 'Parent for test', IsActive = true);
        insert parentCampaign;
        List<Contact> newContacts = new List<Contact>();
        for (Integer contactNumber = 0; contactNumber < contacts; contactNumber++) {
            Contact thisContact = new Contact(LastName = 'test' + contactNumber);
            newContacts.add(thisContact);
        }
        insert newContacts;
        List<CampaignMember> myCampaignMembers = new List<CampaignMember>();
        for (Contact thisContact : newContacts) {
            CampaignMember thisCM = new CampaignMember(CampaignId = parentCampaign.Id, ContactId = thisContact.Id);
            myCampaignMembers.add(thisCM);
        }
        insert myCampaignMembers;
        List<Campaign> segmentCampaigns = new List<Campaign>();
        for (Integer segNum = 0; segNum < segments; segNum++) {
            Campaign thisCampaign = new Campaign(Name = 'Segment' + segNum, ParentId = parentCampaign.Id);
            segmentCampaigns.add(thisCampaign);
        }
        insert segmentCampaigns;
        List<Id> mySegmentIds = new List<Id>();
        for (Campaign myCamp : segmentCampaigns) {
            mySegmentIds.add(myCamp.Id);
        }
        List<Integer> sizes = new List<Integer>{100, 100};
        List<Integer> members = new List<Integer>{0, 0};
        Test.startTest();
        BatchSegmentCreator batch = new BatchSegmentCreator();
        batch.query = 'SELECT Id, CampaignId, LeadId, ContactId FROM CampaignMember WHERE CampaignId = \'' + parentCampaign.Id + '\'';
        batch.email = 'admin@acme.com';
        batch.parentCampaignId = parentCampaign.Id;
        batch.segmentCampaignIds = mySegmentIds;
        batch.segmentSizes = sizes;
        batch.membersAdded = members;
        batch.keepOriginal = false;
        ID batchprocessid = Database.executeBatch(batch);
        Test.stopTest();
        // Verificar que los CampaignMembers se han movido a las campañas de segmento
        System.assertEquals(Database.countQuery('SELECT count() FROM CampaignMember WHERE CampaignId = \'' + parentCampaign.Id + '\''), 0);
        System.assertEquals(Database.countQuery('SELECT count() FROM CampaignMember WHERE CampaignId = \'' + mySegmentIds[0] + '\''), 100);
        System.assertEquals(Database.countQuery('SELECT count() FROM CampaignMember WHERE CampaignId = \'' + mySegmentIds[0] + '\''), 100);
    }
}