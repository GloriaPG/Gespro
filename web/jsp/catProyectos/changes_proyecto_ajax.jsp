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
    Proyecto obj = new Proyecto();
    ProyectoDAO proyecto = new ProyectoDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("idProyecto") != null ? new Integer(request.getParameter("idProyecto")): 0;
    
    obj = proyecto.getById(id);
    Integer option = request.getParameter("option") != null ? new Integer(request.getParameter("option")): 0;
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    Date date = new Date();
    String message = "";
    String json = "";
    boolean status = false;
    try{ 
        if(id!=0){
            obj = proyecto.getById(id);
            obj.setStatus(0);
            proyecto.actualizar(obj);
            message = "<--EXITO-->" +"La actualización fue exitosa.";
            status = true;
        }
    }catch(HibernateException e){
        message = "<--ERROR-->" + "Ocurrió un error al actualizar." + e.getMessage();
    }

     response.sendRedirect("catProyectos.jsp");

   
           
%>