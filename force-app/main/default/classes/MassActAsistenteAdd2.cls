public class MassActAsistenteAdd2 {

    asistencia_a_actividades__c asistencia;
    
    public asistencia_a_actividades__c  getAsistencia() {
          if(asistencia == null) asistencia = new asistencia_a_actividades__c();
          return asistencia;
       }
    
     public List<Pertenencia_a_Actividades__c> selectedContacts = new List<Pertenencia_a_Actividades__c>();
    
     public MassActAsistenteAdd2 (ApexPages.StandardSetController controller) {
                 this.selectedContacts = (list<Pertenencia_a_Actividades__c>)controller.getSelected();
            }
     
     public pageReference createNewAsistente() {
     
      List<Asistencia_a_Actividades__c> newAsistentes = new List<Asistencia_a_Actividades__c>();
      for (Pertenencia_a_Actividades__c p:selectedContacts) {
      Pertenencia_a_Actividades__c per2=[select Contacto__c, Actividad__c from Pertenencia_a_Actividades__c where id=:p.id];
      Asistencia_a_Actividades__c newAsistencia = new Asistencia_a_Actividades__c (
        Asistente__c = per2.Contacto__c,
        Actividad__c = per2.Actividad__c, 
        Fecha__c = asistencia.Fecha__c);
        
        newAsistentes.add(newAsistencia);
    
       /* Integer count  = [select count() from Asistencia_a_Actividades__c where Asistente__c = :c.id and Actividad__c =: asistencia.Actividad__c ];  
             
          if (count < 1)
          {
          newAsistentes.add(newAsistencia);
          }
          else{
          newAsistentes.add(newAsistencia);
          }
     */     
      }
      
       if (newAsistentes.size() > 0) {
       upsert newAsistentes;
      }
      
      PageReference p = new PageReference('/a09/o');
        p.setRedirect(true);
      return p; 
     }
    }