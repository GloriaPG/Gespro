<%-- 
    Document   : ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : gloria
--%>

<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.ActividadDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Actividad"%>
<%@page import="com.tsp.gespro.hibernate.dao.ProyectoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Proyecto"%>
<%@page import="com.tsp.gespro.Services.Allservices"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Actividad obj= new Actividad();
    Allservices services = new Allservices();
    ActividadDAO actividadModel = new ActividadDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("idActividad") != null ? new Integer(request.getParameter("idActividad")): 0;
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    String message = "";
    String json = "";
    boolean status = false;
    if(id!=0){
        obj = actividadModel.getById(id);
    }
    
    try{
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
        }

    }catch(Exception ex){
        message = "<--ERROR1-->" + ex.getMessage();
    }
     
   
       try{ 
                   
           if(obj.getActividad().equals("") || obj.getIdUser()== 0 || obj.getIdPunto()== 0 || obj.getIdProyecto()== 0){
               message = "<--ERROR-->" + "Simbolo y nombre son obligatorios.";
           }else{
            if(id!=0){
                actividadModel.actualizar(obj);
                message = "<--EXITO-->" +"La actualización fue exitosa.";
                status = true;
            }else{
                actividadModel.guardar(obj);
                message = "<--EXITO-->" + "Se guardó correctamente.";
                status = true;
            }
            List<Actividad> actividades = services.QueryActividadDAO("where idProyecto = "+obj.getIdProyecto());
            Float promedio = Float.parseFloat("0");
            int cantidad = actividades.size();
            for(Actividad itemAct : actividades){
                promedio += itemAct.getAvance();
            }
            promedio = promedio/cantidad;
            Proyecto proyecto;
            ProyectoDAO proyectoModel = new ProyectoDAO();
            proyecto = proyectoModel.getById(obj.getIdProyecto());
            proyecto.setAvance(promedio);
            proyectoModel.actualizar(proyecto);
        }
       }catch(HibernateException e){
           message = "<--ERROR-->" + "Ocurrió un error al actualizar." + e.getMessage();
       }
       json = "{ status:" + (status ? "true":"false") +", message:'" + message + "'}";
       out.print(json);
           
%>