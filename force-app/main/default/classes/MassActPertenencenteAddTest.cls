@isTest
public with sharing class MassActPertenencenteAddTest {
    @isTest
    static void testMassActPertenencenteAdd() {
        ApexPages.StandardSetController s = new ApexPages.standardSetController(new List<Contact>());
        MassActPertenencenteAdd wizard = new MassActPertenencenteAdd(s);
        wizard.getPertenencia();
        wizard.createNewPertenencente();
       }
}