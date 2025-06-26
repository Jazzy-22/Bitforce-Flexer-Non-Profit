public class MassActAsistenteEventosAdd {

    asistencia_a_eventos__c asistencia;
    
    public asistencia_a_eventos__c  getAsistencia() {
          if(asistencia == null) asistencia = new asistencia_a_eventos__c();
          return asistencia;
       }
    
     public List<Contact> selectedContacts = new List<Contact>();
    
     public MassActAsistenteEventosAdd(ApexPages.StandardSetController controller) {
                 this.selectedContacts = (list<Contact>)controller.getSelected();
            }
     
     public pageReference createNewAsistente() {
     
      List<Asistencia_a_Eventos__c> newAsistentes = new List<Asistencia_a_Eventos__c>();
      for (Contact c:selectedContacts) {
       Asistencia_a_Eventos__c newAsistencia = new Asistencia_a_Eventos__c (
        Asistente__c = c.id,
        Asisti__c = asistencia.Asisti__c,
        Categor_a_de_asistenc__c = asistencia.Categor_a_de_asistenc__c,
        Detalle_de_otros_importes__c = asistencia.Detalle_de_otros_importes__c,
        Evento__c = asistencia.Evento__c,
        Fecha_de_Inscripci_n__c = asistencia.Fecha_de_Inscripci_n__c,
        Importe__c = asistencia.Importe__c, 
        Importe_transporte__c = asistencia.Importe_transporte__c,
        Inscripto__c = asistencia.Inscripto__c,
        Lugar_de_transporte__c = asistencia.Lugar_de_transporte__c,
        Modo_de_Inscripci_n__c = asistencia.Modo_de_Inscripci_n__c,
        Moneda_importe__c = asistencia.Moneda_importe__c,
        Moneda_otros_importes__c = asistencia.Moneda_otros_importes__c,
        Moneda_transporte__c = asistencia.Moneda_transporte__c,
        Otros_importes__c = asistencia.Otros_importes__c,
        Subtipo_de_Invitado__c = asistencia.Subtipo_de_Invitado__c,
        Transporte__c = asistencia.Transporte__c);
        
        newAsistentes.add(newAsistencia);
    
       /* Integer count  = [select count() from Asistencia_a_Eventos__c where Asistente__c = :c.id and Actividad__c =: asistencia.Actividad__c ];  
             
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
      
      PageReference p = new PageReference('/003/o');
        p.setRedirect(true);
      return p; 
     }
    }