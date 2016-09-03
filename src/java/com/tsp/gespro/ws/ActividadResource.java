/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.ws;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.tsp.gespro.Services.ActividadFullObject;
import com.tsp.gespro.Services.Allservices;
import com.tsp.gespro.hibernate.dao.ActividadDAO;
import com.tsp.gespro.hibernate.pojo.Actividad;
import java.lang.reflect.Type;
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
@Path("actividad")
public class ActividadResource {

    @Context
    private UriInfo context;

    /**
     * Creates a new instance of ActividadResource
     */
    public ActividadResource() {
    }

    /**
     * Retrieves representation of an instance of com.tsp.gespro.ws.ActividadResource
     * @return an instance of java.lang.String
     */
    @GET
    @Produces("application/json")
    @Path("/proyecto")
    public String getActividadByProyecto(@QueryParam("proyecto") String proyecto) {
        Allservices service=new Allservices();
        List<Actividad> list=null;
        System.out.println("Proyecto : " + proyecto);
        if(proyecto==null || proyecto==""){
            ActividadDAO obj= new ActividadDAO();
            list= obj.getLista();
            
        }else{
            String where="where id_proyecto="+proyecto;
            list=service.QueryActividadDAO(where);
        }
        
        List<ActividadFullObject> listFull=service.getActividadesFull(list);
        Gson gson = new Gson();
        String jsonResponse=gson.toJson(listFull);
        //TODO return proper representation object
        return jsonResponse;
        
    }
    
     /**
     * Retrieves representation of an instance of com.tsp.gespro.ws.ActividadResource
     * @return an instance of java.lang.String
     */
    @GET
    @Produces("application/json")
    @Path("/promotor")
    public String getActividadByPromotor(@QueryParam("promotor") String promotor) {
        Allservices service=new Allservices();
        List<Actividad> list=null;
        if(promotor==null || promotor==""){
            ActividadDAO obj= new ActividadDAO();
            list= obj.getLista();
            
        }else{
            String where="where id_user="+promotor;
            list=service.QueryActividadDAO(where);
        }
        
        List<ActividadFullObject> listFull=service.getActividadesFull(list);
        Gson gson = new Gson();
        String jsonResponse=gson.toJson(listFull);
        //TODO return proper representation object
        return jsonResponse;
        
    }

}
