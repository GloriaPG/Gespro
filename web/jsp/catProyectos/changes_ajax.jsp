<%-- 
    Document   : ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : gloria
--%>

<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.ActividadDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Actividad"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Actividad obj;
    ActividadDAO proyecto = new ActividadDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("idActividad") != null ? new Integer(request.getParameter("idActividad")): 0;
    
    obj = proyecto.getById(id);
    Integer option = request.getParameter("option") != null ? new Integer(request.getParameter("option")): 0;
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    Date date = new Date();
    String message = "";
    String json = "";
    boolean status = false;
    
    try{
        if(option==1){
            obj.setAvance(request.getParameter("avance") != null ? Float.parseFloat(request.getParameter("avance")): 0);
        }
        if(option ==2){
            obj.setComentarios(request.getParameter("comentarios") != null ? new String(request.getParameter("comentarios").getBytes("ISO-8859-1"), "UTF-8"): "");
            if(obj.getTipoActividad() == 1){
                obj.setRecibio(request.getParameter("recibio") != null ? new String(request.getParameter("recibio").getBytes("ISO-8859-1"), "UTF-8"): "");
            }
            obj.setCheckin(new Date());
            obj.setAvance(Float.parseFloat("100"));
        
            

        }
    }catch(Exception ex){
        message = "<--ERROR1-->" + ex.getMessage();
    }
     
   
       try{ 
        if(option==1){
            if(obj.getAvance()==0){
                message = "<--ERROR-->" + "Simbolo y nombre son obligatorios.";
            }else{
                if(id!=0){
                    proyecto.actualizar(obj);
                    message = "<--EXITO-->" +"La actualización fue exitosa.";
                    status = true;
                }
           }
        }
        if(option ==2){
            if(obj.getComentarios().equals("")){
                message = "<--ERROR-->" + "Simbolo y nombre son obligatorios.";
            }else{
                if(id!=0){
                    proyecto.actualizar(obj);
                    message = "<--EXITO-->" +"La actualización fue exitosa.";
                    status = true;
                }
           }
        }
                   
           
       }catch(HibernateException e){
           message = "<--ERROR-->" + "Ocurrió un error al actualizar." + e.getMessage();
       }
       json = "{ status:" + (status ? "true":"false") +", message:'" + message + "'}";
       out.print(json);
    
    /*try{
        // Setear los datos que vienen en el request a un objeto de el tipo
        // UsuarioMonitor para poder actulizarlos o crearlos.
        obj.setActividad(request.getParameter("actividad") != null ? new String(request.getParameter("actividad").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setDescripcion(request.getParameter("descripcion") != null ? new String(request.getParameter("descripcion").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setTipoActividad(request.getParameter("tipoActividad") != null ? Integer.parseInt(request.getParameter("tipoActividad")): 0);
        obj.setIdUser(request.getParameter("idUser") != null ? Integer.parseInt(request.getParameter("idUser")): 0);
        obj.setIdPunto(request.getParameter("idPunto") != null ? Integer.parseInt(request.getParameter("idPunto")): 0);
        obj.setAvance(request.getParameter("avance") != null ? Float.parseFloat(request.getParameter("avance")): 0);
        obj.setCantidad(request.getParameter("cantidad") != null ? Float.parseFloat(request.getParameter("cantidad")): 0);
        obj.setIdProyecto(request.getParameter("idProyecto") != null ? Integer.parseInt(request.getParameter("idProyecto")): 0);
        if(obj.getTipoActividad() == 1){
            obj.setIdProducto(request.getParameter("idProducto") != null ? Integer.parseInt(request.getParameter("idProducto")): 0);
        }*/

   
           
%>