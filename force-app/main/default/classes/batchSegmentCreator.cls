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
global class batchSegmentCreator implements Database.Batchable<SObject>,Database.Stateful{
    global String query;
    global String email;
    global Id parentCampaignId;
    global List<Id> segmentCampaignIds;
    global List<Integer> segmentSizes;
    global List<Integer> membersAdded;
    global String errorTxt = '';
    global boolean keepOriginal;
    
    global database.querylocator start(Database.BatchableContext BC){
                return Database.getQueryLocator(query);}
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        //Old code from AppEx
        /*
        boolean thisBatchSuccess = memberAssignment.assignMembersNow(parentCampaignId,segmentCampaignIds,segmentSizes,membersAdded);
        if(!thisBatchSuccess){
            success = false;
        }
        */
        
        List<CampaignMember> newCampaignMembers = new List<CampaignMember>();
        
        for(sObject s : scope){
            
            CampaignMember oldCM = (CampaignMember)s;
            
            Boolean assigned = false;
            
            while(assigned == false){
                Integer assignedList = Math.floor(segmentCampaignIds.size() * Math.Random()).intValue();

                if((membersAdded[assignedList] < segmentSizes[assignedList])){          
                     newCampaignMembers.add(
                        new CampaignMember(
                            CampaignId = segmentCampaignIds[assignedList],
                            LeadId = oldCM.LeadId,
                            ContactId = oldCM.ContactId     
                        )
                     );
                     assigned = true;
                     
                     membersAdded[assignedList]++;
                     
                }
            }   
    
        }
        
        if(!newCampaignMembers.isEmpty()){
            Database.saveresult[] srList = database.insert(newCampaignMembers,false);
            
            List<CampaignMember> deleteMe = new List<CampaignMember>();
            for(Integer i = 0;i<srList.size();i++){
                Database.saveresult sr = srList[i];
                
                if(sr.isSuccess() && !keepOriginal){
                    deleteMe.add( (CampaignMember)scope[i] );
                }
                else{
                    for(Database.Error e : sr.getErrors()){
                        errorTxt = errorTxt + 'Original Record Id:' + scope[i].get('Id') + '\n' + 'Error:' + e.getMessage() + '\n\n';
                    }
                    
                }
            }
            
            if(!deleteMe.isEmpty()){
                delete deleteMe;
            }
        
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
        String hasErrors;
        String resultBody;
        if(errorTxt == ''){
            hasErrors = '';
            resultBody = ' has completed successfully.';
        } else {
            hasErrors = 'with Errors';
            resultBody = ' has complted with errors. \n\n' + errorTxt + '\n\n';
        }
        //query the parent and make a better body
        Campaign parentCampaign = [select id, name from Campaign where id=:parentCampaignId];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo(email);
        mail.setSenderDisplayName('Batch Processing of Campaigns');
        mail.setSubject('Campaign Segmentation Completed - ' + parentCampaign.name + ' ' + hasErrors);
        mail.setPlainTextBody('The segmentation of ' + parentCampaign.name + resultBody +' https://na1.salesforce.com/' + parentCampaign.Id);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}