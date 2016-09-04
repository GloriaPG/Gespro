/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.ws;

import com.google.gson.Gson;
import java.awt.Image;
import com.sun.jersey.multipart.FormDataParam;
import com.tsp.gespro.config.Configuration;
import com.tsp.gespro.dto.DatosUsuario;
import com.tsp.gespro.hibernate.dao.ActividadDAO;
import com.tsp.gespro.hibernate.dao.FotoActividadDAO;
import com.tsp.gespro.hibernate.pojo.Actividad;
import com.tsp.gespro.hibernate.pojo.FotoActividad;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.io.File;
import java.io.InputStream;
import java.math.BigInteger;
import java.security.SecureRandom;
import java.util.Date;
import javax.imageio.ImageIO;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.PathParam;
import javax.ws.rs.Consumes;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

/**
 * REST Web Service
 *
 * @author gloria
 */
@Path("foto-actividad")
public class FotoActividadResource {

    @Context
    private UriInfo context;

    /**
     * Creates a new instance of FotoActividadResource
     */
    public FotoActividadResource() {
    }

    /**
     * PUT method for updating or creating an instance of FotoActividadResource
     * @param content representation for the resource
     * @return an HTTP response with content of the updated or created resource.
     */
    @POST
    @Produces("application/json")
    @Consumes({MediaType.MULTIPART_FORM_DATA})
    public Response upload(
            @FormDataParam("foto") InputStream fileInputStream,
            @FormDataParam("id_actividad") int id) throws Exception{
       
        if(fileInputStream==null){
            return Response.status(Response.Status.BAD_REQUEST).build(); 
        }
        if(id==0){
            return Response.status(Response.Status.BAD_REQUEST).build(); 
        }
        Actividad actividad=new ActividadDAO().getById(id);
        
        // 404 : La actividad no existe.
        if(actividad==null){
           return Response.status(Response.Status.NOT_FOUND).build(); 
        }
        
        BufferedImage img = ImageIO.read(fileInputStream);
        String path=folder(actividad);
        String name=securityString()+".png";
        try{
            ImageIO.write(img, "png", new File(path+name));
        }catch(Exception e){
            // 500 : Error al intentar guardar la imagen.
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
        FotoActividad foto=new FotoActividad();
        foto.setFoto(name);
        foto.setIdActividad(actividad.getIdActividad());
        foto.setIdPromotor(actividad.getIdUser());
        foto.setIdProyecto(actividad.getIdProyecto());
        foto.setIdPunto(actividad.getIdPunto());
        foto.setTipoActividad(actividad.getTipoActividad());
        foto.setFecha(new Date());
        
        FotoActividadDAO obj=new FotoActividadDAO();
        int idFoto= obj.guardar(foto);
        foto.setId(idFoto);
        
        Gson gson=new Gson();
        String json=gson.toJson(foto);
        return Response.ok(json).build();
    } 
    
    private String folder(Actividad act){
        Configuration conf=new Configuration();
        String path=conf.getApp_content_path();
        path+="/proyectos/"+String.valueOf(act.getIdProyecto())+"/actividades/";
        path+=String.valueOf(act.getIdActividad())+"/";
        System.out.println("Ruta : " + path);
        File folder = new File(path);
        if (!folder.exists()) {
            folder.mkdirs();
        }
        
        return path;
    }
    
  public String securityString() {
    SecureRandom random = new SecureRandom();
    return new BigInteger(130, random).toString(32);
  }
}
