/**
 * Created by joaquin on 20/01/2020.
 */

global without sharing class DonacionEntrante extends npsp.TDTM_Runnable {

    //Metodo obligatorio en el NPSP Trigger
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
            List<SObject> oldlist,
            npsp.TDTM_Runnable.Action triggerAction,
            Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Donacion_entrante__c> newDEList = (List<Donacion_entrante__c>) newlist;
        List<Donacion_entrante__c> oldDEList = (List<Donacion_entrante__c>) oldlist;
        List<npe03__Recurring_Donation__c> newDRs = new List<npe03__Recurring_Donation__c>();
        List<Opportunity> newOpps = new List<Opportunity>();


        if(triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert){
            FindContact(newDEList);
            //Cambiamos el status de acuerdo a FindContact
            for(Donacion_entrante__c DE : newDEList){
                if(DE.Contact__c != null && (DE.N_mero_de_Tarjeta__c != null || ( DE.Forma_de_Pago__c != null && !DE.Forma_de_Pago__c.contains('Tarjeta de')))){
                    DE.Status__c = 'Convertida';
                }else if(DE.N_mero_de_Tarjeta__c != null){
                    DE.Status__c = 'A revisar';
                }else{
                    DE.Status__c = 'Incompleta';
                }
            }
        }

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
//si en el insert de la DE el contacto y la tarjeta estan completos se crean las donaciones
            for (Donacion_entrante__c DE : newDEList) {
                if (DE.Contact__c != null && (DE.N_mero_de_Tarjeta__c != null || ( DE.Forma_de_Pago__c != null && !DE.Forma_de_Pago__c.contains('Tarjeta de')))) {
                    if(DE.Tipo_de_donaci_n__c == 'Monthly'){
                        newDRs.add(createRecurringDonation(DE));
                    }else{
                        newOpps.add(createOneTimeDonation(DE));
                    }

                }
            }
        }
//si en el update de la DE el contacto y la tarjeta estan completos se crean las donaciones

        else if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            for (Donacion_entrante__c DE : newDEList) {
                if ((DE.N_mero_de_Tarjeta__c != null || ( DE.Forma_de_Pago__c != null && !DE.Forma_de_Pago__c.contains('Tarjeta de'))) && DE.Contact__c != null &&
                        (oldDEList.get(newDEList.indexOf(DE)).Contact__c != DE.Contact__c ||
                                oldDEList.get(newDEList.indexOf(DE)).N_mero_de_Tarjeta__c != DE.N_mero_de_Tarjeta__c)) {
                    if(DE.Tipo_de_donaci_n__c == 'Monthly'){
                        newDRs.add(createRecurringDonation(DE));
                    }else{
                        newOpps.add(createOneTimeDonation(DE));
                    }
                }
            }
        }

        dmlWrapper.objectsToInsert.addAll((List<npe03__Recurring_Donation__c>)newDRs);
        dmlWrapper.objectsToInsert.addAll((List<Opportunity>)newOpps);
        return dmlWrapper;
    }

//Metodo que crea la DDRR
    private npe03__Recurring_Donation__c createRecurringDonation(Donacion_entrante__c DE){

        return new npe03__Recurring_Donation__c(
                Name = 'Donacion - ' + DE.Last_Name__c,
                npe03__Contact__c = DE.Contact__c,
                Categor_a__c = 'Aporte',
                npe03__Installment_Period__c = 'Monthly',
                Moneda__c = 'Pesos',
                npe03__Amount__c = DE.Monto__c,
                Forma_de_pago__c = DE.Forma_de_Pago__c,
                npe03__Open_Ended_Status__c = 'Open',
                Tipo_de_compromiso__c = 'Primer Compromiso',
                Destino_de_los_fondos__c = DE.Destino_de_fondos__c,
                Origen__c = DE.Origen__c,
                Canal__c = DE.Canal__c,
                Subcanal__c = DE.Sub_Canal__c,
                Tipo_de_tarjeta__c = DE.Tipo_de_Tarjeta__c,
                N_mero_en_Tarjeta__c = DE.N_mero_de_Tarjeta__c,
                Fecha_de_vencimiento_mm_aaaa__c = DE.Fecha_de_vencimiento__c,
                npe03__Recurring_Donation_Campaign__c = DE.Campana__c,
                Evento_de_origen__c = DE.Evento__c,
                Donaci_n_entrante__c = DE.Id,
                Fecha_de_compromiso__c = DE.Fecha_de_Compromiso__c,
                RecordTypeId = Schema.SObjectType.npe03__Recurring_Donation__c.getRecordTypeInfosByName().get('Abierta').getRecordTypeId()
        );
    }
//Metodo que crea la Opportuntity
    private Opportunity createOneTimeDonation(Donacion_entrante__c DE){

        return new Opportunity(
                Name = 'Donacion - ' + DE.Last_Name__c,
                npsp__Primary_Contact__c = DE.Contact__c,
                CloseDate = DE.Fecha_de_Cierre__c,
                Categor_a__c = 'Aporte',
                Moneda__c = 'Pesos',
                Amount = DE.Monto__c,
                Forma_de_pago__c = DE.Forma_de_Pago__c,
                StageName = 'Esperando respuesta',
                Destino_de_Fondos__c = DE.Destino_de_fondos__c,
                Origen_de_la_oportunidad__c = DE.Origen__c,
                Canal__c = DE.Canal__c,
                Subcanal__c = DE.Sub_Canal__c,
                Tipo_de_tarjeta__c = DE.Tipo_de_Tarjeta__c,
                Nro_de_tarjeta__c = DE.N_mero_de_Tarjeta__c,
                FechaVencTj__c = DE.Fecha_de_vencimiento__c,
                CampaignId = DE.Campana__c,
                Evento__c = DE.Evento__c,
                Donaci_n_entrante__c = DE.Id,
                Fecha_de_compromiso__c = DE.Fecha_de_Compromiso__c,
                Cuenta_Contable_Tango__c = '11102001 Banco Frances c/c',
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Única vez - Individuos').getRecordTypeId()

        );
    }

    global void FindContact(List<Donacion_entrante__c> DEs) {
//Este metodo busca si existe el candidato como lead o contacto y lo crea o actualiza la DE
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        Map<String, Donacion_entrante__c> DNIDeMap = new Map<String, Donacion_entrante__c>();
        Map<String, Donacion_entrante__c> EmailDeMap = new Map<String, Donacion_entrante__c>();
        List<Donacion_entrante__c> DEset = new List<Donacion_entrante__c>();
        Boolean CTFound = false;

        for (Donacion_entrante__c DE : Des) {
            //ponemos el status en incompleto primero
            DE.Status__c = 'Incompleta';
            DEset.add(DE);
            DNIDeMap.put(DE.DNI__c, DE);
            EmailDeMap.put(DE.Correo_electronico__c, DE);
        }

        //Se busca primero dentro de leads
//        List<Lead> leads = [
//                SELECT Id, Email, N_mero_de_identificaci_n__c
//                FROM Lead
//                WHERE IsConverted = FALSE AND
//                (N_mero_de_identificaci_n__c IN :DNIDeMap.keySet() OR
//                Email IN :EmailDeMap.keySet())
//        ];
        List<Contact> newContacts = new List<Contact>();

        for (Donacion_entrante__c DE : Des) {
            //Se busca duplicados con el metodo de Salesforce
            List<String> Ids = FindDuplicate(DE);
            //Si existe un duplicado se saca la DE del array y se pone el flag foundCT como true
            if (Ids.size() > 0) {
                Integer i = DEset.indexOf(DE);
                DEset.remove(i);
                CTFound = true;
            }
//            } else {
//                //Si no se encuentra pero si se encontro en lead se convierte el candidato
//                for (Lead foundLead : leads) {
//                    if (String.isNotBlank(DE.DNI__c) && foundLead.N_mero_de_identificaci_n__c == DE.DNI__c) {
//                        DE.Contact__c = convertLead(foundLead, convertStatus.MasterLabel);
//                        CTFound = true;
//                    } else if (String.isNotBlank(DE.DNI__c) && foundLead.Email == DE.Correo_electronico__c) {
//                        DE.Contact__c = convertLead(foundLead, convertStatus.MasterLabel);
//                        CTFound = true;
//                    }
//                }
//            }
            //Si no se encontro en lead ni en contacto se crea un contacto
            if (!CTFound) {
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
                if(DE.No_Contactar__c != 'false')
                    ct.No_Contactar__c = 'Nunca';
                if (DE.Lugar_de_residencia__c == 'Otro Pais') {
                    ct.MailingCountry = 'Otro Pais';
                    ct.MailingState = 'Unica';
                } else {
                    ct.MailingCountry = 'Argentina';
                    ct.MailingState = DE.Lugar_de_residencia__c;
                }
                newContacts.add(ct);
            }


        }

        if(newContacts.size()>0)
            insert newContacts;


        for (Contact ct : newContacts) {
            //Se agrega los contactos creados a la DE
            for (Donacion_entrante__c DE : Des){
                if(DE.DNI__c == ct.N_mero_de_identificaci_n__c){
                    DE.Contact__c = ct.Id;
                }
            }


        }

    }

//Este metodo instancia un contacto temporal para llamar al metodo standard de reglas de duplicados de salesforce
    public static List<String> FindDuplicate(Donacion_entrante__c DE){

        List<String> Ids = new List<String>();
        Contact ct = new Contact(FirstName = DE.First_Name__c,
                LastName = DE.Last_Name__c,
                Email = DE.Correo_electronico__c,
                N_mero_de_identificaci_n__c = DE.DNI__c);

        List<Contact> cts = new List<Contact>();
        cts.add(ct);

        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(cts);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        Ids.add(matchRecord.getRecord().Id);
                    }
                }
            }
        }

        return Ids;

    }
    private Id convertLead(Lead l, String convertStatus){

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l.id);


        lc.setConvertedStatus(convertStatus);
        lc.setDoNotCreateOpportunity(true);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        return lcr.contactId;
    }
}