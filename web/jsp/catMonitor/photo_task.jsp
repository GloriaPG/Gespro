<%-- 
    Document   : ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : gloria
--%>

<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.config.Configuration"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.ActividadDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Actividad"%>
<%@page import="com.tsp.gespro.hibernate.dao.ConceptoRegistroFotograficoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.ConceptoRegistroFotografico"%>
<%@page import="com.tsp.gespro.hibernate.dao.ProyectoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Proyecto"%>
<%@page import="com.tsp.gespro.hibernate.dao.FotoActividadDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.FotoActividad"%>
<%@page import="com.tsp.gespro.Services.Allservices"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Actividad objActividad= new Actividad();
    Proyecto objProyecto= new Proyecto();
    ProyectoDAO proyectoDAO= new ProyectoDAO();
    ActividadDAO actividadDAO= new ActividadDAO();
    Allservices services = new Allservices();
    ActividadDAO actividadModel = new ActividadDAO();
        Integer idActividad = request.getParameter("idActividad") != null ? new Integer(request.getParameter("idActividad")): 0;
    String FechaActividad = request.getParameter("fechaActividad") != null ? new String(request.getParameter("fechaActividad").getBytes("ISO-8859-1"), "UTF-8") : "";
    objActividad = actividadDAO.getById(idActividad);
    
             
    EmpresaBO empresaBO = new EmpresaBO(user.getConn());
     ;
    Configuration appConfig = new Configuration();
    String ubicacionImagenesProspectos = appConfig.getApp_content_path() +"proyectos/"+objActividad.getIdProyecto()+"/actividades/"+objActividad.getIdActividad()+"/";

    // Si el id viene que el request parsearlo a integer.

    List <FotoActividad> fotografias = services.queryFotoActividad("where idActividad = "+objActividad.getIdActividad());
    String listImages ="<div class='multiple-items'>";
    if(fotografias.size()>0){
        for(FotoActividad foto: fotografias){
            listImages+="<div class='show_foto'>";
            listImages+="<img src='showImage.jsp?p="+objActividad.getIdProyecto()+"&a="+objActividad.getIdActividad()+"&i="+foto.getFoto()+"'>";
            listImages+="</div>";
        }
    }else{
        listImages+="No se han registrado imagenes para esta Actividad";
    }
    listImages +="</div>";
    listImages +="<script>"
            + "$('.multiple-items').ready(function(){"
            + "$('.multiple-items').slick({"
  +"slidesToShow: 1,"
  +"slidesToScroll: 1,"
  +"autoplay: true,"
  +"autoplaySpeed: 2000,"
  +"});"
            + "});";
    out.print(listImages);
%>