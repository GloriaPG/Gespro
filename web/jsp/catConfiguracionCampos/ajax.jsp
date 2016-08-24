<%@page import="com.tsp.gespro.hibernate.dao.EtiquetaFormularioClienteDAO"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Si el id viene que el request parsearlo a integer.
    EtiquetaFormularioClienteDAO etiquetaFormularioClienteDAO=new EtiquetaFormularioClienteDAO();   
    
    try{
       etiquetaFormularioClienteDAO.guardarCambios(request.getParameterMap(),user.getUser().getIdUsuarios());
       out.print("<--EXITO-->" + "Se guardó correctamente. ");
    }catch(Exception ex){
        out.print("<--ERROR-->" + ex.getMessage());
    }
           
%>