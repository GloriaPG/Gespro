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
    UsuarioMonitor datosActuales= new UsuarioMonitor();
    UsuarioMonitorDAO usuarioMonitor = new UsuarioMonitorDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("id") != null ? new Integer(request.getParameter("id")): 0;
    // Si el id viene, setearlo en el objeto.
    if(id!=0){
        // Traer los datos actuales de el usuario.
        datosActuales= usuarioMonitor.getById(id);
        if(request.getParameter("password") != null){
            String password = new String(request.getParameter("password").getBytes("ISO-8859-1"), "UTF-8");
            datosActuales.setPassword(password.trim());
        }
        
    }
    
         
    try{
         usuarioMonitor.actualizar(datosActuales);
         out.print("<--EXITO-->" + "Se guardó correctamente.");

    }catch(HibernateException e){
        out.print("<--ERROR-->" + "Ocurrió un error al guardar." + e.getMessage());

    } 
    
           
%>
