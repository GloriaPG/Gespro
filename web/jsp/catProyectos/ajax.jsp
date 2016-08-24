<%-- 
    Document   : ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : gloria
--%>

<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.ProyectoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Proyecto"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Proyecto obj;
    ProyectoDAO proyecto = new ProyectoDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("id") != null ? new Integer(request.getParameter("id")): 0;
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    String message = "";
    String json = "";
    boolean status = false;
    if(id != 0){
        obj = proyecto.getById(id);
    }else{
        obj= new Proyecto();
    }
    
    try{
        // Setear los datos que vienen en el request a un objeto de el tipo
        // UsuarioMonitor para poder actulizarlos o crearlos.
        obj.setNombre(request.getParameter("nombre") != null ? new String(request.getParameter("nombre").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setFechaInicio(request.getParameter("fechaInicio") != null ? formatter.parse(new String(request.getParameter("fechaInicio").getBytes("ISO-8859-1"), "UTF-8")) : null);
        obj.setFechaProgramada(request.getParameter("fechaProgramada") != null ? formatter.parse(new String(request.getParameter("fechaInicio").getBytes("ISO-8859-1"), "UTF-8")) : null);
        obj.setFechaReal(request.getParameter("fechaReal") != null ? formatter.parse(new String(request.getParameter("fechaInicio").getBytes("ISO-8859-1"), "UTF-8")) : null);
        obj.setIdCliente(request.getParameter("idCliente") != null ? Integer.parseInt(request.getParameter("idCliente")): 0);
        obj.setAvance(request.getParameter("avance") != null ? Float.parseFloat(request.getParameter("avance")): 0);
        obj.setStatus(request.getParameter("status") != null ? 1 : 0);
        obj.setIdPromotor(3);

    }catch(Exception ex){
        message = "<--ERROR1-->" + ex.getMessage();
    }
     
   
       try{ 
           if(obj.getNombre().equals("") || obj.getIdCliente()== 0){
               message = "<--ERROR-->" + "Simbolo y nombre son obligatorios.";
           }else{
            if(id!=0){
                proyecto.actualizar(obj);
                message = "<--EXITO-->" +"La actualización fue exitosa.";
                status = true;
            }else{
                obj.setIdUser(request.getParameter("idUser") != null ? Integer.parseInt(request.getParameter("idUser")): 0);
                proyecto.guardar(obj);
                message = "<--EXITO-->" + "Se guardó correctamente.";
                status = true;
            }
           }
       }catch(HibernateException e){
           message = "<--ERROR-->" + "Ocurrió un error al actualizar." + e.getMessage();
       }
       json = "{ status:" + (status ? "true":"false") +", message:'" + message + "'}";
       out.print(json);
           
%>