/**
 * Created by joaquin on 24/01/2020.
 */

 public with sharing class ContactosEncontradosCtrl {


    @AuraEnabled(Cacheable=true)
    public static Contact[] getContacts(Id RecordId) {
        //List<String> Ids = IdsParam.split(',');
        Donacion_entrante__c DE = [SELECT Id, DNI__c,Correo_electronico__c,First_Name__c,Last_Name__c,No_Contactar__c FROM Donacion_entrante__c WHERE ID = :RecordId];

        List<String> IdList = DonacionEntrante.FindDuplicate(DE);
        return [SELECT Id, FirstName, LastName, N_mero_de_identificaci_n__c, Email,Name,
                Es_donante_recurrente_activo__c, ES_DONANTE_NUEVO__c,No_Contactar__c from Contact WHERE Id in :IdList];
    }

@AuraEnabled
public static String createNewContact(Id RecordId){
    Donacion_entrante__c DE = [SELECT Id, DNI__c,Correo_electronico__c,First_Name__c,Last_Name__c,No_Contactar__c,Tipo_de_Documento__c,Telefono__c,Lugar_de_residencia__c FROM Donacion_entrante__c WHERE ID = :RecordId];
    List<String> IdList = DonacionEntrante.FindDuplicate(DE);
    if(IdList.size() == 0){
        Contact ct = new Contact(
                FirstName = DE.First_Name__c,
                LastName = DE.Last_Name__c,
                Sexo__c = 'Sin Informar',
                N_mero_de_identificaci_n__c = DE.DNI__c,
                npe01__HomeEmail__c = DE.Correo_electronico__c,
                Tipo_de_identificaci_n__c = DE.Tipo_de_Documento__c,
                HomePhone = DE.Telefono__c,
                npe01__PreferredPhone__c = 'Home',
                npe01__Preferred_Email__c = 'Personal',
                LeadSource = 'Web',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId()
        );
        if(DE.No_Contactar__c == 'false')
            ct.No_Contactar__c = 'Nunca';
        if (DE.Lugar_de_residencia__c == 'Otro Pais') {
            ct.MailingCountry = 'Otro Pais';
            ct.MailingState = 'Unica';
        } else {
            ct.MailingCountry = 'Argentina';
            ct.MailingState = DE.Lugar_de_residencia__c;
        }
        try{
            insert ct;
            return ct.Id;
        }
        catch(Exception e){
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

    }else{
        return 'Se han encontrado duplicados';
    }

}

}