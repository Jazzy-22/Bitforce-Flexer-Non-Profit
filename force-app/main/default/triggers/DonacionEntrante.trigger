/**
 * Created by joaquin on 20/01/2020.
 */

trigger DonacionEntrante on Donacion_entrante__c (after delete, after insert, after undelete,after update, before delete, before insert, before update) {

    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Donacion_entrante__c);
}