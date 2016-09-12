/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.ws;

import com.google.gson.Gson;
import com.tsp.gespro.Services.ActividadFullObject;
import com.tsp.gespro.Services.Allservices;
import com.tsp.gespro.Services.DataUbicacion;
import com.tsp.gespro.Services.PromotorAvance;
import com.tsp.gespro.hibernate.dao.ActividadDAO;
import com.tsp.gespro.hibernate.pojo.Actividad;
import com.tsp.gespro.hibernate.pojo.Usuarios;
import java.util.AbstractList;
import java.util.ArrayList;
import java.util.List;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.PathParam;
import javax.ws.rs.Consumes;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.GET;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;

/**
 * REST Web Service
 *
 * @author gloria
 */
@Path("avance")
public class AvanceResource {

    @Context
    private UriInfo context;

    /**
     * Creates a new instance of AvanceResource
     */
    public AvanceResource() {
    }

    /**
     * Retrieves representation of an instance of com.tsp.gespro.ws.AvanceResource
     * @return an instance of java.lang.String
     */
    @GET
    @Produces("application/json")
    @Path("/proyecto")
    public String getJson(@QueryParam("proyecto") String proyecto) {
        
        Allservices allservices = new Allservices();
        List<Actividad> actividades=null;
        
        //Obtengo la lista de actividades de el proyecto.
        if(proyecto!=null && proyecto!=""){
             String where = "WHERE id_proyecto=" + proyecto;
             actividades = allservices.QueryActividadDAO(where);
        }else{
            actividades = new ActividadDAO().getLista();
        }
       

        // Creo una lista de actividades, donde obtenga los objetos
        // completos de actividad, punto y proyecto.
        List<ActividadFullObject> actividadesFull;
        if(actividades!=null){
            actividadesFull = allservices.getActividadesFull(actividades);
        }else{
            return "";
        }

        // Agrupamos los avances por ciudad.
        ArrayList<String> listaDeCiudades = new ArrayList();
       
        for (ActividadFullObject actividadFull : actividadesFull) {
            DataUbicacion ubi=actividadFull.getUbicacion();
            if(ubi!=null){
              String ciudad=actividadFull.getUbicacion().getCiudad();
              if(ciudad!=null && ciudad!=""){
                if (!listaDeCiudades.contains(ciudad)) {
                  listaDeCiudades.add(actividadFull.getUbicacion().getCiudad());
                 }
              }
            } 
        }
        
        String ciudadesJson="";
        int indice = -1;
        for (String ciudad : listaDeCiudades) {
            indice++;
            float sumaDeAvance = 0;
            int contador = 0;
            for (ActividadFullObject actividadFull : actividadesFull) {
                if(actividadFull.getUbicacion()!=null){
                    if (ciudad.equalsIgnoreCase(actividadFull.getUbicacion().getCiudad())) {
                        contador++;
                        sumaDeAvance += actividadFull.getActividad().getAvance();
                    }
                }
                
            }
            ciudadesJson += "\""+ciudad+"\":"+sumaDeAvance/(contador);
            if (listaDeCiudades.size() == indice+1) {
            } else {
                ciudadesJson += ",";
            }
        }
        
        // Agrupamos los avances por ciudad.
        ArrayList<String> listaDeEstados = new ArrayList();

        for (ActividadFullObject actividadFull : actividadesFull) {
            DataUbicacion ubi=actividadFull.getUbicacion();
            if(ubi!=null){
                String estado=actividadFull.getUbicacion().getEstado();
                if(estado!=null && estado!=""){
                    if (!listaDeEstados.contains(estado)) {
                        listaDeEstados.add(actividadFull.getUbicacion().getEstado());
                    }
                }
            } 
        }
        
        String estadosJson="";
        indice = -1;
        for (String estado : listaDeEstados) {
            indice++;
            float sumaDeAvance = 0;
            int contador = 0;
            for (ActividadFullObject actividadFull : actividadesFull) {
                if (estado.equalsIgnoreCase(actividadFull.getUbicacion().getEstado())) {
                    contador++;
                    sumaDeAvance += actividadFull.getActividad().getAvance();
                }
            }
            estadosJson += "\""+estado+"\":"+sumaDeAvance/(contador);
            if (listaDeEstados.size() == indice+1) {
            } else {
                estadosJson += ",";
            }
        }
     System.out.print("Ciudades : " +ciudadesJson);
     System.out.print("Estados : " +estadosJson);

     String json = "{\"ciudades\":{";
     json+=ciudadesJson;
     json+="},";
     json+="\"regiones\":{";
     json+=estadosJson;
     json+="}}";
     System.out.print("Response : " +json);

     return json;
    }
    
      /**
     * Retrieves representation of an instance of com.tsp.gespro.ws.AvanceResource
     * @return an instance of java.lang.String
     */
    @GET
    @Produces("application/json")
    @Path("/promotor")
    public String getPromotorJson(@QueryParam("promotor") String promotor) {
        
        Allservices allservices = new Allservices();
        List<Actividad> actividades=null;
        
        //Obtengo la lista de actividades de el proyecto.
        if(promotor!=null && promotor!=""){
             String where = "WHERE id_user=" + promotor;
             actividades = allservices.QueryActividadDAO(where);
        }else{
            actividades = new ActividadDAO().getLista();
        }
       

        // Creo una lista de actividades, donde obtenga los objetos
        // completos de actividad, punto y proyecto.
        List<ActividadFullObject> actividadesFull;
        actividadesFull = allservices.getActividadesFull(actividades);

        // Agrupamos los avances por ciudad.
        ArrayList<String> listaDeCiudades = new ArrayList();
       
        for (ActividadFullObject actividadFull : actividadesFull) {
            DataUbicacion ubi=actividadFull.getUbicacion();
            if(ubi!=null){
              String ciudad=actividadFull.getUbicacion().getCiudad();
              if(ciudad!=null && ciudad!=""){
                if (!listaDeCiudades.contains(ciudad)) {
                  listaDeCiudades.add(actividadFull.getUbicacion().getCiudad());
                 }
              }
            } 
        }
        
        String ciudadesJson="";
        int indice = -1;
        for (String ciudad : listaDeCiudades) {
            indice++;
            float sumaDeAvance = 0;
            int contador = 0;
            for (ActividadFullObject actividadFull : actividadesFull) {
                if (ciudad.equalsIgnoreCase(actividadFull.getUbicacion().getCiudad())) {
                    contador++;
                    sumaDeAvance += actividadFull.getActividad().getAvance();
                }
            }
            ciudadesJson += "\""+ciudad+"\":"+sumaDeAvance/(contador);
            if (listaDeCiudades.size() == indice+1) {
            } else {
                ciudadesJson += ",";
            }
        }
        
        // Agrupamos los avances por ciudad.
        ArrayList<String> listaDeEstados = new ArrayList();

        for (ActividadFullObject actividadFull : actividadesFull) {
            DataUbicacion ubi=actividadFull.getUbicacion();
            if(ubi!=null){
                String estado=actividadFull.getUbicacion().getEstado();
                if(estado!=null && estado!=""){
                    if (!listaDeEstados.contains(estado)) {
                        listaDeEstados.add(actividadFull.getUbicacion().getEstado());
                    }
                }
            } 
        }
        
        String estadosJson="";
        indice = -1;
        for (String estado : listaDeEstados) {
            indice++;
            float sumaDeAvance = 0;
            int contador = 0;
            for (ActividadFullObject actividadFull : actividadesFull) {
                if (estado.equalsIgnoreCase(actividadFull.getUbicacion().getEstado())) {
                    contador++;
                    sumaDeAvance += actividadFull.getActividad().getAvance();
                }
            }
            estadosJson += "\""+estado+"\":"+sumaDeAvance/(contador);
            if (listaDeEstados.size() == indice+1) {
            } else {
                estadosJson += ",";
            }
        }
     System.out.print("Ciudades : " +ciudadesJson);
     System.out.print("Estados : " +estadosJson);

     String json = "{\"ciudades\":{";
     json+=ciudadesJson;
     json+="},";
     json+="\"regiones\":{";
     json+=estadosJson;
     json+="}}";
     System.out.print("Response : " +json);

     return json;
    }
 
    @GET
    @Produces("application/json")
    @Path("/actividad")
    public String getActividadesJson(@QueryParam("proyecto") String proyecto) {
        
        Allservices allservices = new Allservices();
        List<Actividad> actividades=null;
        
        //Obtengo la lista de actividades de el proyecto.
        if(proyecto!=null && proyecto!=""){
             String where = "WHERE id_proyecto=" + proyecto;
             actividades = allservices.QueryActividadDAO(where);
        }else{
            actividades = new ActividadDAO().getLista();
        }
       
     Gson gson=new Gson();
     String json=gson.toJson(actividades);

     return json;
    }
    
    /**
     * Retrieves representation of an instance of com.tsp.gespro.ws.AvanceResource
     * @return an instance of java.lang.String
     */
    @GET
    @Produces("application/json")
    @Path("/avance-promotor")
    public String getPromotorAvanceJson(@QueryParam("proyecto") String proyecto) {
        
        Allservices allservices = new Allservices();
        List<Actividad> actividades=null;
        
        //Obtengo la lista de actividades de el proyecto.
        if(proyecto!=null && proyecto!=""){
             String where = "WHERE id_proyecto=" + proyecto;
             actividades = allservices.QueryActividadDAO(where);
        }else{
            actividades=new ActividadDAO().lista();
        }
       

        // Creo una lista de actividades, donde obtenga los objetos
        // completos de actividad, punto y proyecto.
        List<ActividadFullObject> actividadesFull;
        actividadesFull = allservices.getActividadesFull(actividades);

        // Agrupamos los avances por promotor.
        ArrayList<String> promotoresList = new ArrayList();
        List<PromotorAvance> avancePromotor=new ArrayList<PromotorAvance>();
        for (ActividadFullObject actividadFull : actividadesFull) {
            Usuarios promotor=actividadFull.getPromotor();
            if(promotor!=null){
              String name=promotor.getUserName();
              if(name!="" && name!=null){
                if (!promotoresList.contains(name)) {
                  promotoresList.add(name);
                 }
              }
            } 
        }
        
        for (String promo : promotoresList) {
            float sumaDeAvance = 0;
            int contador = 0;
            for (ActividadFullObject actividadFull : actividadesFull) {
                if (promo.equalsIgnoreCase(actividadFull.getPromotor().getUserName())) {
                    contador++;
                    sumaDeAvance += actividadFull.getActividad().getAvance();
                }
            }
            PromotorAvance obj=new PromotorAvance();
            obj.setPromotor(promo);
            obj.setAvance(sumaDeAvance/(contador));
            avancePromotor.add(obj);
        }
        
     Gson gson=new Gson();
     String json=gson.toJson(avancePromotor);
     System.out.print("Response : " +json);

     return json;
    }
}
