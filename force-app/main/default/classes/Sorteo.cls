/**
 * Created by joaquin on 29/09/2020.
 */
@RestResource(urlMapping='/sorteo/*')
global without sharing class Sorteo {
    @HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String SorteoID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Integer cantNumeros = 0;
        Integer cantsubset = 10;
        List<Numero_Sorteo__c> numeros = [SELECT name, Sorteo__r.numeros_visibles_front__c, Sorteo__r.Cantidad_de_numeros__c from Numero_Sorteo__c where Sorteo__c = :SorteoID];
        response respuesta = new response();
        respuesta.numerosDisponibles = new List<Integer>();
        respuesta.numerosUsados = new List<Integer>();
        respuesta.subset = new Set<Integer>();
        try {
            if (numeros.size() > 0) {
                System.debug(numeros);
                cantNumeros = Integer.valueOf(numeros[0].Sorteo__r.Cantidad_de_numeros__c) + 1;
                cantsubset = Integer.valueOf(numeros[0].Sorteo__r.numeros_visibles_front__c);
            } else {
                Sorteo__c s = [select Cantidad_de_numeros__c, numeros_visibles_front__c from Sorteo__c where Id = :SorteoID];
                cantNumeros = s.Cantidad_de_numeros__c.intValue() + 1;
                cantsubset = s.numeros_visibles_front__c.intValue();
                System.debug(cantNumeros);
            }

            for (Numero_Sorteo__c num : numeros) {
                respuesta.numerosUsados.add(Integer.valueOf(num.Name));
            }

            System.debug(cantNumeros);
            for (Integer i = 1; i < cantNumeros; i++) {
                System.debug(respuesta.numerosUsados);
                System.debug(i);
                if (!respuesta.numerosUsados.contains(i)) {
                    respuesta.numerosDisponibles.add(i);
                }
            }

            for (Integer i = 0; i < cantsubset; i++) {
                Integer numero;
                if(respuesta.numerosDisponibles.size() <= i){
                    break;
                }
                if(cantsubset >= respuesta.numerosDisponibles.size()){
                    numero = respuesta.numerosDisponibles[i];
                }else{
                    Double randomNumber = Math.random();
                    numero = respuesta.numerosDisponibles[(randomNumber * (respuesta.numerosDisponibles.size() - 1)).intValue()];
                    while (respuesta.subset.contains(numero)) {
                        randomNumber = Math.random();
                        numero = respuesta.numerosDisponibles[(randomNumber * (respuesta.numerosDisponibles.size() - 1)).intValue()];
                    }
                }

                respuesta.subset.add(numero);
            }
            System.debug(respuesta);
            System.debug(res);
            res.responseBody = Blob.valueOf(JSON.serialize(respuesta));
            res.statusCode = 200;
        }catch(Exception e){
            res.responseBody = Blob.valueOf(e.getMessage() + ' ' + e.getStackTraceString() + e.getLineNumber());
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            res.statusCode = 400;
        }
    }

    global class response{
        List<Integer> numerosUsados;
        List<Integer> numerosDisponibles;
        Set<Integer> subset;
    }
}