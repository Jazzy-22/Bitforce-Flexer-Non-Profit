public class MassActPertenencenteAdd {

    pertenencia_a_actividades__c pertenencia;
    
    public pertenencia_a_actividades__c  getPertenencia() {
          if(pertenencia == null) pertenencia = new pertenencia_a_actividades__c();
          return pertenencia;
       }
    
     public List<Contact> selectedContacts = new List<Contact>();
    
     public MassActPertenencenteAdd(ApexPages.StandardSetController controller) {
                 this.selectedContacts = (list<Contact>)controller.getSelected();
            }
     
     public pageReference createNewPertenencente() {
     
      List<Pertenencia_a_Actividades__c> newPertenencentes = new List<Pertenencia_a_Actividades__c>();
      for (Contact c:selectedContacts) {
       Pertenencia_a_Actividades__c newPertenencia = new Pertenencia_a_Actividades__c (
        Contacto__c = c.id,
        Actividad__c = pertenencia.Actividad__c, 
        D_a_de_finalizaci_n__c = pertenencia.D_a_de_finalizaci_n__c,
        D_a_de_Inicio__c = pertenencia.D_a_de_Inicio__c,
        Estado__c = pertenencia.Estado__c);
        
        newPertenencentes.add(newPertenencia);
    
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
      
       if (newPertenencentes.size() > 0) {
       upsert newPertenencentes;
      }
      
      PageReference p = new PageReference('/003/o');
      p.setRedirect(true);
      return p; 
     }
    }