<%-- 
    Document   : ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : gloria
--%>

<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.UsuarioMonitorDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.UsuarioMonitor"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    UsuarioMonitor obj= new UsuarioMonitor();
    UsuarioMonitorDAO usuarioMonitor = new UsuarioMonitorDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("id") != null ? new Integer(request.getParameter("id")): 0;
    // Si el id viene, setearlo en el objeto.

    try{
        // Setear los datos que vienen en el request a un objeto de el tipo
        // UsuarioMonitor para poder actulizarlos o crearlos.
        obj.setNombre(request.getParameter("nombre") != null ? new String(request.getParameter("nombre").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setApellidoPaterno(request.getParameter("apellidoPaterno") != null ? new String(request.getParameter("apellidoPaterno").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setApellidoMaterno(request.getParameter("apellidoMaterno") != null ? new String(request.getParameter("apellidoMaterno").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setEmail(request.getParameter("email") != null ? new String(request.getParameter("email").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setPassword(request.getParameter("password") != null ? new String(request.getParameter("password").getBytes("ISO-8859-1"), "UTF-8"): "");
        
        if(request.getParameter("activo") != null)
        {
          obj.setActivo(new Boolean(request.getParameter("activo")));
        }
    }catch(Exception ex){
        out.print("<--ERROR-->" + ex.getMessage());
    }
    
    
    if(id!=0){
       try{
           if(obj.getEmail()=="" || obj.getPassword()==""){
               out.print("<--ERROR-->" + "Email y password son obligatorios.");
           }
           else{
            obj.setId(id);
            usuarioMonitor.actualizar(obj);
            out.print("<--EXITO-->" +"La actualización fue exitosa.");
           }
       }catch(HibernateException e){
           out.print("<--ERROR-->" + "Ocurrió un error al actualizar.");
           out.print("<--ERROR-->" + e.getMessage());
       }
       
    }else{
       try{
           if(obj.getEmail()=="" || obj.getPassword()==""){
               out.print("<--ERROR-->" + "Email y password son obligatorios.");
           }
           else{
            usuarioMonitor.guardar(obj);
            out.print("<--EXITO-->" + "Se guardó correctamente.");
           }
       }catch(HibernateException e){
           out.print("<--ERROR-->" + "Ocurrió un error al guardar." + e.getMessage());

       } 
    }
           
%>
