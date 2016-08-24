/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.ws;

import com.google.gson.Gson;
import com.tsp.gespro.Services.Allservices;
import com.tsp.gespro.hibernate.dao.ProyectoDAO;
import com.tsp.gespro.hibernate.pojo.Proyecto;
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
@Path("proyecto")
public class ProyectoResource {

    @Context
    private UriInfo context;

    /**
     * Creates a new instance of ProyectoResource
     */
    public ProyectoResource() {
    }

    /**
     * Retrieves representation of an instance of com.tsp.gespro.ws.ProyectoResource
     * @return an instance of java.lang.String
     */
    @GET
    @Produces("application/json")
   @Path("/query")
    public String getPryectoByCliente(@QueryParam("cliente") String cliente) {
        Allservices service=new Allservices();
        List<Proyecto> list=null;
        System.out.println("Cliente : " + cliente);
        if(cliente==null || cliente==""){
            ProyectoDAO obj= new ProyectoDAO();
            list= obj.getLista();
            
        }else{
            String where="where id_cliente="+cliente;
            list=service.queryProyectoDAO(where);
        }
        
        Gson gson = new Gson();
        String jsonResponse=gson.toJson(list);
        //TODO return proper representation object
        return jsonResponse;
        
    }


}
