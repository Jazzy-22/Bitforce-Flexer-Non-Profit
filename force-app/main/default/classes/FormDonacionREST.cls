@RestResource(urlMapping='/WebForm')
global without sharing class FormDonacionREST {

    @HttpPost
    global static void doPost(){

//Se convierte el JSON a la clases internas

        String result;
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        RestResponse res = new RestResponse();
        String requestString = body.toString();
        FormDataClass FormData = parse(requestString);
        try{

            Donacion_entrante__c DE = new Donacion_entrante__c(
                    id = FormData.id,
                    First_Name__c = FormData.Nombre,
                    Last_Name__c = FormData.Apellidos,
                    Tipo_de_Documento__c = FormData.Tipo_de_identificacion,
                    DNI__c = FormData.Numero_de_identificacion,
                    Telefono__c = FormData.Telefono,
                    Correo_electronico__c = FormData.Correo_electronico,
                    Correo_electronico_particular__c = FormData.Correo_electronico_particular,
                    Origen__c = FormData.Origen,
                    Origen_del_Contacto__c = FormData.Origen_del_contacto,
                    No_Contactar__c = FormData.No_Contactar,
                    Destino_de_fondos__c = FormData.Destino_de_fondos,
                    Tipo_de_donaci_n__c = FormData.Frecuencia,
                    Canal__c = FormData.Canal,
                    Sub_Canal__c = FormData.Subcanal,
                    Fecha_de_Compromiso__c = FormData.Fecha_de_compromiso,
                    Forma_de_Pago__c = FormData.Forma_de_pago,
                    Tipo_de_Tarjeta__c = FormData.Tipo_de_tarjeta,
                    N_mero_de_Tarjeta__c = FormData.Numero_en_Tarjeta,
                    Monto__c = FormData.Monto,
                    Fecha_de_vencimiento__c = FormData.Fecha_de_vencimiento_de_la_Tarjeta,
                    Fecha_de_Cierre__c = FormData.Fecha_de_cierre,
                    Campana__c = FormData.Campana,
                    Evento__c = FormData.Evento,
                    Lugar_de_residencia__c = FormData.lugar_de_residencia
            );


            upsert DE;
            if(FormData.SorteoID != null && FormData.Numeros != null){
                List<Numero_Sorteo__c> numeros = new List<Numero_Sorteo__c>();
                for(Integer numString : FormData.Numeros){
                    Numero_Sorteo__c num = new Numero_Sorteo__c();
                    num.Sorteo__c = FormData.SorteoID;
                    num.Name = String.valueOf(numString);
                    num.Numero__c = FormData.SorteoID + String.valueOf(numString);
                    num.donacion__c = FormData.id;
                    numeros.add(num);
                }
                if(numeros.size()>0)insert numeros;
            }
            System.debug('test');
            result = 'Success ' + DE.Id;
            RestContext.response.addHeader('Content-Type', 'text/plain');
            RestContext.response.responseBody = Blob.valueOf(result);
            RestContext.response.statusCode = 200;


        }catch(DmlException e){
            System.debug('testcatch');
            RestContext.response.addHeader('Content-Type', 'text/plain');
            RestContext.response.responseBody = Blob.valueOf(e.getDmlMessage(0));
            RestContext.response.statusCode = 400;
        } catch(exception e){
            System.debug('testcatch');
            RestContext.response.addHeader('Content-Type', 'text/plain');
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
            RestContext.response.statusCode = 400;

        }



    }

    public class FormDataClass {
        public String id;
        public string lugar_de_residencia;
        public String Nombre;
        public String Apellidos;
        public String Tipo_de_identificacion;
        public String Numero_de_identificacion;
        public String Telefono;
        public String Correo_electronico;
        public String Correo_electronico_particular;
        public String Origen_del_contacto;
        public String No_Contactar;
        public String Destino_de_fondos;
        public String Frecuencia;
        public String Origen;
        public String Canal;
        public String Subcanal;
        public Date Fecha_de_compromiso;
        public String Forma_de_pago;
        public String Tipo_de_tarjeta;
        public String Numero_en_Tarjeta;
        public String Campana;
        public String Evento;
        public Decimal Monto;
        public String Fecha_de_vencimiento_de_la_Tarjeta;
        public Date Fecha_de_cierre;
        public String SorteoID;
        public List<Integer> Numeros;
    }

    public class FormResult{
        public String Id;
        public String error;
        public integer statusCode;
    }


    Public static FormDataClass parse(string json){
        return (FormDataClass)System.JSON.deserialize(json, FormDataClass.class);
    }

}