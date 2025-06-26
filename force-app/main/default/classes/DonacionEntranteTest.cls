/**
 * Created by joaquin on 23/01/2020.
 */


@isTest
private class DonacionEntranteTest {
        @isTest
    static  void TestDEnuevoCt() {

// Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

// Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'DonacionEntrante';
        th.npsp__Class__c = 'DonacionEntrante';
        th.npsp__Object__c = 'Donacion_entrante__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert;AfterInsert;AfterUpdate;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

// set up test data
        Contact con1 = new Contact(FirstName = 'Jess', LastName = 'Lopez');
        insert con1;


        test.startTest();
        Donacion_entrante__c DE = new Donacion_entrante__c(
                First_Name__c = 'Joaquin',
                Last_Name__c = 'Test',
                Tipo_de_Documento__c = 'DNI',
                DNI__c = '34630388',
                Telefono__c = '43434343',
                Correo_electronico__c = 'Tedt@example.com',
                Correo_electronico_particular__c = 'Testing@example.com',
                Origen__c = 'Otro',
                Origen_del_Contacto__c = '',
                No_Contactar__c = '',
                Tipo_de_donaci_n__c = 'Monthly',
                Forma_de_Pago__c = 'Tarjeta de Crédito',
                Tipo_de_Tarjeta__c = 'Visa',
                N_mero_de_Tarjeta__c ='1',
                Monto__c = 234
        );

        insert DE;

        test.stopTest();
    }
@isTest
    static void TestDEoldct() {

// Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

// Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'DonacionEntrante';
        th.npsp__Class__c = 'DonacionEntrante';
        th.npsp__Object__c = 'Donacion_entrante__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert;AfterInsert;AfterUpdate;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

// set up test data
        Contact con1 = new Contact(FirstName = 'Jess', LastName = 'Lopez',N_mero_de_identificaci_n__c = '34630388');
        insert con1;


        test.startTest();
        Donacion_entrante__c DE = new Donacion_entrante__c(
                First_Name__c = 'Joaquin',
                Last_Name__c = 'Test',
                Tipo_de_Documento__c = 'DNI',
                DNI__c = '34630388',
                Telefono__c = '43434343',
                Correo_electronico__c = 'Tedt@example.com',
                Correo_electronico_particular__c = 'Testing@example.com',
                Origen__c = 'Otro',
                Origen_del_Contacto__c = '',
                No_Contactar__c = '',
                Tipo_de_donaci_n__c = 'Unica',
                Forma_de_Pago__c = 'Tarjeta de Crédito',
                Tipo_de_Tarjeta__c = 'Visa',
                N_mero_de_Tarjeta__c ='1',
                Monto__c = 234,
                Fecha_de_Cierre__c = System.today()
        );

        insert DE;
        DE = [SELECT Contact__c FROM Donacion_entrante__c WHERE Id = :DE.ID ];
        System.assert(DE.Contact__c == null);
        DE.Contact__c = con1.Id;


        update DE;
        List<Opportunity> opps = [SELECT ID FROM Opportunity];
        System.assert(opps.size()>0);
        System.assert(DE.Contact__c != null);

            Contact[] cts = ContactosEncontradosCtrl.getContacts(DE.Id);
        String testsString = ContactosEncontradosCtrl.createNewContact(DE.Id);

        test.stopTest();
    }

        @isTest
        static void Testctrl() {

// Retrieve default NPSP Trigger Handlers
                List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

// Add our Trigger Handler to cached Trigger Handlers
                npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
                th.Name = 'DonacionEntrante';
                th.npsp__Class__c = 'DonacionEntrante';
                th.npsp__Object__c = 'Donacion_entrante__c';
                th.npsp__Trigger_Action__c = 'BeforeInsert;AfterInsert;AfterUpdate;';
                th.npsp__Active__c = true;
                th.npsp__Load_Order__c = 1;
                th.npsp__Asynchronous__c = false;

                triggerHandlers.add(th);

                Contact con1 = new Contact(FirstName = 'Jess', LastName = 'Lopez',N_mero_de_identificaci_n__c = '34630388');
                insert con1;


                test.startTest();
                Donacion_entrante__c DE = new Donacion_entrante__c(
                        First_Name__c = 'Joaquin',
                        Last_Name__c = 'Test',
                        Tipo_de_Documento__c = 'DNI',
                        DNI__c = '34630388',
                        Telefono__c = '43434343',
                        Correo_electronico__c = 'Tedt@example.com',
                        Correo_electronico_particular__c = 'Testing@example.com',
                        Origen__c = 'Otro',
                        Origen_del_Contacto__c = '',
                        No_Contactar__c = '',
                        Tipo_de_donaci_n__c = 'Unica',
                        Forma_de_Pago__c = 'Tarjeta de Crédito',
                        Tipo_de_Tarjeta__c = 'Visa',
                        N_mero_de_Tarjeta__c ='1',
                        Monto__c = 234,
                        Fecha_de_Cierre__c = System.today()
                );

                insert DE;
                DE = [SELECT Contact__c FROM Donacion_entrante__c WHERE Id = :DE.ID ];
                System.assert(DE.Contact__c == null);
                Contact ct = new Contact(Id = con1.Id,
                N_mero_de_identificaci_n__c = '',
                Email = '');


                update Ct;

                String testsString = ContactosEncontradosCtrl.createNewContact(DE.Id);

                test.stopTest();
        }


    @isTest static void TestRest() {
            // Set up a test request
            RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        Sorteo__c sor = new Sorteo__c(Name = 'test', Cantidad_de_numeros__c = 1000, numeros_visibles_front__c = 150);
        insert sor;

        request.requestUri =
                    '/services/apexrest/WebForm';
            request.httpMethod = 'GET';
        request.requestBody = Blob.valueOf('{"SorteoID" : "'+sor.Id+'","Numeros" : [1,2,3]}');
            RestContext.request = request;
        RestContext.response = res;

        FormDonacionREST.doPost();
    }

    @isTest static void TestRestSorteo() {
            // Set up a test request
        Sorteo__c sor = new Sorteo__c(Name = 'test', Cantidad_de_numeros__c = 1000, numeros_visibles_front__c = 150);
        insert sor;
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();

        request.requestUri =
                    '/services/apexrest/sorteo/'+sor.Id;
            request.httpMethod = 'GET';
            RestContext.request = request;
        RestContext.response = res;
            Sorteo.doget();
    }
}