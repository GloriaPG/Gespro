<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalSucursalValorDAO"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    CampoAdicionalSucursalValorDAO cacvdao=new CampoAdicionalSucursalValorDAO();    
    try{
       cacvdao.guardarCambios(request.getParameterMap());
       out.print("<--EXITO-->" + "Se guardó correctamente. ");
    }catch(Exception ex){
        out.print("<--ERROR-->" + ex.getMessage());
    }
           
%>