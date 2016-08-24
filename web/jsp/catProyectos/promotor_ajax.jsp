<%-- 
    Document   : productos_ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : Fabian
--%>

<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.PromotorproyectoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Promotorproyecto"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Promotorproyecto obj= new Promotorproyecto();
    PromotorproyectoDAO proyecto = new PromotorproyectoDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("id") != null ? new Integer(request.getParameter("id")): 0;
    Integer option = request.getParameter("option") != null ? new Integer(request.getParameter("option")): 0;
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    String message = "";
    String json = "";
    boolean status = false;
    if(option==1){
       
    
    try{
        // Setear los datos que vienen en el request a un objeto de el tipo
        // UsuarioMonitor para poder actulizarlos o crearlos.obj.setIdProducto(request.getParameter("idProducto") != null ? Integer.parseInt(request.getParameter("idProducto")): 0);
obj.setIdProyecto(request.getParameter("idProyecto") != null ? Integer.parseInt(request.getParameter("idProyecto")): 0);
obj.setIdUser(request.getParameter("idUsuario") != null ? Integer.parseInt(request.getParameter("idUsuario")): 0);

        
    }catch(Exception ex){
        message = "<--ERROR1-->" + ex.getMessage();
    }
     
   
       try{ 
           
       out.print(obj.getIdUser());
       out.print(obj.getIdProyecto());
           if(obj.getIdUser() == 0 || obj.getIdProyecto() == 0){
               message = "<--ERROR-->" + "Simbolo y nombre son obligatorios.";
           }else{
                proyecto.guardar(obj);
                message = "<--EXITO-->" + "Se guardó correctamente.";
                status = true;
           }
       }catch(HibernateException e){
           message = "<--ERROR-->" + "Ocurrió un error al actualizar." + e.getMessage();
       }
       json = "{ status:" + (status ? "true":"false") +", message:'" + message + "'}";
       out.print(json);
    }
    if(option==2){
        proyecto.eliminar(id);
        
       json = "{ status:true, message:'<--EXITO-->" + "Se guardó correctamente.'}";
       out.print(json);
    }
           
%>