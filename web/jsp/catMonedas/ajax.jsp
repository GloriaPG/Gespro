<%-- 
    Document   : ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : gloria
--%>

<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.MonedaDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Moneda"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Moneda obj= new Moneda();
    MonedaDAO moneda = new MonedaDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("id") != null ? new Integer(request.getParameter("id")): 0;
    
    try{
        // Setear los datos que vienen en el request a un objeto de el tipo
        // UsuarioMonitor para poder actulizarlos o crearlos.
        obj.setNombre(request.getParameter("nombre") != null ? new String(request.getParameter("nombre").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setCodigo(request.getParameter("codigo") != null ? new String(request.getParameter("codigo").getBytes("ISO-8859-1"), "UTF-8"): "");
        if(request.getParameter("simbolo") != null ){
            obj.setSimbolo(new String(request.getParameter("simbolo").getBytes("ISO-8859-1"), "UTF-8"));
        }
        if(request.getParameter("activo") != null)
        {
          obj.setActivo(new Boolean(request.getParameter("activo")));
        }
    }catch(Exception ex){
        out.print("<--ERROR-->" + ex.getMessage());
    }
    
    if(id!=0){
       try{ 
           obj.setId(id);
           if(obj.getNombre()=="" || obj.getSimbolo()==""){
               out.print("<--ERROR-->" + "Simbolo y nombre son obligatorios.");
           }
           else{
            out.print("<--mmmm--> obj");
            out.print(obj.getSimbolo());
            out.print(obj.getId());
            moneda.actualizar(obj);
            out.print("<--EXITO-->" +"La actualización fue exitosa.");
           }
       }catch(HibernateException e){
           out.print("<--ERROR-->" + "Ocurrió un error al actualizar.");
           out.print("<--ERROR-->" + e.getMessage());
       }
       
    }else{
       try{
           if(obj.getNombre()=="" || obj.getSimbolo()==""){
               out.print("<--ERROR-->" + "Simbolo y nombre son obligatorios.");
           }
           else{
            moneda.guardar(obj);
            out.print("<--EXITO-->" + "Se guardó correctamente.");
           }
       }catch(HibernateException e){
           out.print("<--ERROR-->" + "Ocurrió un error al guardar." + e.getMessage());

       } 
    }
           
%>