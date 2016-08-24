<%-- 
    Document   : json_avances_ajax
    Created on : 15/08/2016, 09:27:22 AM
    Author     : gloria
--%>

<%@page import="com.tsp.gespro.hibernate.dao.ProyectoDAO"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="java.util.List"%>
<%@page import="com.tsp.gespro.Services.Allservices"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Proyecto"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Allservices allservices=new Allservices();
    String proyectoId = request.getParameter("proyecto_id") != null ? new String(request.getParameter("proyecto_id").getBytes("ISO-8859-1"), "UTF-8"): "";
    List<Proyecto> proyectos=null;
    if(proyectoId!=""){
        String friltroBusqueda="where proyecto_id="+proyectoId;
        proyectos = allservices.queryProyectoDAO(friltroBusqueda);
    }else{
        proyectos=new ProyectoDAO().lista();
    }
    
    
    String json="";
    for(int i=0;i< proyectos.size();i++){
       Gson gson = new Gson();
       String jsonResponse = gson.toJson(proyectos.get(i));
    }
    Gson gson = new Gson();
    String jsonResponse = gson.toJson(proyectos);
    out.print(jsonResponse);
%>
