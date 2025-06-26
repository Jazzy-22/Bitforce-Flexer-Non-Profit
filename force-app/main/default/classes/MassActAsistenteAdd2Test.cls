@isTest
public with sharing class MassActAsistenteAdd2Test {
    @isTest
    static void testMassActAsistenteAdd() {
        ApexPages.StandardSetController s = new ApexPages.standardSetController(new List<Pertenencia_a_Actividades__c>());
        MassActAsistenteAdd2 wizard = new MassActAsistenteAdd2(s);
        wizard.getAsistencia();
        wizard.createNewAsistente();
       }
}