@isTest
public with sharing class MassActAsistenteEventosAddTest {
    @isTest 
    static void testMassActAsistenteEventosAdd() {
        ApexPages.StandardSetController s = new ApexPages.standardSetController(new List<Contact>());
        MassActAsistenteEventosAdd wizard = new MassActAsistenteEventosAdd(s);
        wizard.getAsistencia();
        wizard.createNewAsistente();
       }
}