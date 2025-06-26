/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public with sharing class segmentsController {
    public String stringSegments {get; set;}
    Integer numberOfSegments {get; set;}
    
    public Boolean showSegmentsPicker {get; set;}
    public Boolean showSegmentCreator {get; set;}
    public Boolean showBatchInfo {get; set;}
    public Boolean keepOriginal {get; set;}
    
    public List<Segment> listOfSegments  {get; set;}
    public Integer MAX_SEGMENTS = 25;
    public Integer memberCount {get; set;}
    public Campaign parentCampaign {get; set;}
    public Integer MAX_SYNCHRONOUS_MEMBERS {get; set;}  
    public String batchEmailNotification {get; set;}
    
    List<Campaign> listOfCampaigns = new List<Campaign>();  
    List<Integer> targetMemberCount = new List<Integer>();
    List<Integer> membersAdded = new List<Integer>();   
    Id parentCampaignId;    
    Integer targetForEachCampaign; 
    Integer remainderMembers;
    Integer submittedMemberCount;
    Boolean success;
    Integer CONCURRENT_BATCH_LIMIT = 5;//at time of coding, there are at most 5 concurrent batch apex jobs in any org
        
    List<CampaignMember> newCampaignMembers = new List<CampaignMember>();
    
    
    public class segment{
        public Campaign campaign {get; set;}
        public Integer membercount;
        public Integer targetMemberCount {get; set;}
        public void setTargetMemberCount(Integer value){
            targetMemberCount = value;
            targetMemberPercentage = (value/memberCount)*100;
        }
        public Integer targetMemberPercentage {get; set;}
        public Integer membersAdded {get; set;}
    }
    
    
    public segmentsController(ApexPages.StandardController stdController){
        parentCampaign = (Campaign)stdController.getRecord();
        parentCampaign = [select id,name,NumberOfContacts, NumberOfLeads,type,status,startDate,endDate from campaign where id=:parentCampaign.id];
        memberCount = parentCampaign.NumberOfContacts + parentCampaign.NumberOfLeads;
        showSegmentsPicker = true;
        showBatchInfo = false;
        MAX_SYNCHRONOUS_MEMBERS = 4000;
        
        if(memberCount==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please add members to this Campaign before creating segments.'));
            showSegmentsPicker = false;
            showSegmentCreator = false;         
        }
    }
    
    public void setSegments(){

        if(pattern.matches('^[0-9]+$',stringSegments)){
            numberOfSegments = Integer.valueOf(stringSegments);
            targetForEachCampaign = Math.floor(memberCount/numberOfSegments).intValue();
            remainderMembers = memberCount - (targetForEachCampaign*numberOfSegments);
            
            listOfSegments = new List<Segment>();
            if(numberOfSegments>0 && numberOfSegments<= MAX_SEGMENTS){
                showSegmentsPicker = false;
                showSegmentCreator = true;
                //create the segments
                //create destination campaigns
            
                for(Integer segment=0; segment<numberOfSegments;segment++){
                    Segment newSegment = new Segment();
                    Campaign newSegmentCampaign = parentCampaign.clone(false,true);
                    newSegmentCampaign.Name = parentCampaign.Name + ' - segment ' + (segment+1);
                    newSegmentCampaign.ParentId = parentCampaign.Id;
                    newSegment.campaign = newSegmentCampaign;
                    newSegment.memberCount = memberCount;
                    if(segment<(numberOfSegments-1)){
                        newSegment.setTargetMemberCount(targetForEachCampaign);
                        
                    } else {
                        newSegment.setTargetMemberCount(targetForEachCampaign+remainderMembers);
                    }
                   
                    newSegment.membersAdded = 0;
                    listOfSegments.add(newSegment);
                }
                
                
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please pick a number larger than 0 and smaller than '+MAX_SEGMENTS+'.'));
                
            }

        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter a valid number'));
        }
    }
    
    public void resetSegments(){
        numberOfSegments=null;
        showSegmentsPicker=true;
        showSegmentCreator=false;
    }
    
    public PageReference runSegments(){
        
        submittedMemberCount = 0;
        
        List<Integer> segmentSizes = new List<Integer>();
        List<Integer> membersAdded = new List<Integer>();
        listOfCampaigns.clear();
        
        for(segment thisSegment : listOfSegments){
            listOfCampaigns.add(thisSegment.campaign);
            segmentSizes.add(thisSegment.targetMemberCount);
            submittedMemberCount += thisSegment.targetMemberCount;
            membersAdded.add(0);
        }
        
        //check to make sure user submitted count is right
        if(submittedMemberCount==memberCount){
            
            try {
                insert listOfCampaigns;
            } catch (exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error creating the segment Campaigns: ' + e.getMessage() ));
                return null;
            }
            
            //insert campaign statuses
            //assume sent and responded are there, as they will be created in the new campaigns
            List<CampaignMemberStatus> statuslist = [SELECT Id, CampaignId, HasResponded, Label, IsDefault,SortOrder from CampaignMemberStatus WHERE CampaignId = :parentCampaign.id and label <> 'Sent' and label <> 'Responded'];
            List<CampaignMemberStatus> newStatuses = new List<CampaignMemberStatus>();
            for(Campaign thisSegmentCampaign : listOfCampaigns){
                for(CampaignMemberStatus thisStatus : statuslist){
                    CampaignMemberStatus sclone = thisStatus.clone(false);
                    sclone.CampaignId = thisSegmentCampaign.Id;
                    newStatuses.add(sclone);
                }
            }
            try {
                insert newStatuses;
            } catch (exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error copying statuses: ' + e.getMessage() ));
                return null;
            }
            
            List<Id> newCampaignIds = new List<Id>();
            
            for(Campaign myCamp : listOfCampaigns){
                newCampaignIds.add(myCamp.Id);
            }
            
            //add chatter message to the parent campaign\
            /*
            try {
                FeedPost fpost = new FeedPost();
                fpost.ParentId = parentCampaign.id;
                fpost.Body = 'The Campaign Segmentation Wizard was run, creating ' + listOfSegments.size() + ' segments.';
                insert fpost;
            } catch (exception e) {
                system.debug('Chatter feeds aren\'t enabled on Campaigns. Enable Chatter feeds on Campaigns to automatically record when the Campaign Segementation Wizard is run.');
            }
            */
            success = false;
            if(membercount<=MAX_SYNCHRONOUS_MEMBERS){
                success = memberAssignment.assignMembersNow(parentCampaign.Id,newCampaignIds,segmentSizes,membersAdded,keepOriginal);
            } else {
                
                List<AsyncApexJob> numBatchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE Status = 'Queued' OR Status = 'Processing'];
                if((CONCURRENT_BATCH_LIMIT - numBatchJobs.size())>0){
                
                    User thisUser = [select email from User where id = :UserInfo.getUserId()];
                    batchEmailNotification = thisUser.email;
                    batchSegmentCreator batchSegments = new batchSegmentCreator();
                    batchSegments.query='select id,campaignId, leadId, contactid from campaignMember where CampaignId = \'' +  parentCampaign.Id + '\''; 
                    batchSegments.parentCampaignId = parentCampaign.Id;
                    batchSegments.segmentCampaignIds = newCampaignIds;
                    batchSegments.segmentSizes = segmentSizes;
                    batchSegments.membersAdded = membersAdded;
                    batchSegments.keepOriginal = keepOriginal;
                    batchSegments.email = batchEmailNotification;
                    ID batchprocessid = Database.executeBatch(batchSegments);
                    
                    showSegmentCreator = false;
                    showBatchInfo = true;
                    
                    return null;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There are currently ' + numBatchJobs.size() + ' Apex jobs scheduled. Try again later.'));
                    return null;
                }
            }
        
            PageReference pageRef = new PageReference('/' + parentCampaign.Id);
            pageRef.setRedirect(true);
            return pageRef;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please make sure your segment member counts add up to the total member count.'));
            return null;
        }
        
    }
    
    public PageReference cancel(){
            PageReference pageRef = new PageReference('/' + parentCampaign.Id);
            pageRef.setRedirect(true);
            return pageRef;
        }
    
}