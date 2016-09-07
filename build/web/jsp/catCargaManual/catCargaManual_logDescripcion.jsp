<%-- 
    Document   : catCargaManual_logDescripcion
    Created on : 28/08/2015, 05:07:19 PM
    Author     : HpPyme
--%>
<%@page import="com.tsp.sct.dao.dto.CargaXls"%>
<%@page import="com.tsp.sct.dao.jdbc.CargaXlsDaoImpl"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.sct.bo.UsuarioBO"/>
<%

//Verifica si el cliente tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {
    int idCargaManual = -1;
    try{ idCargaManual = Integer.parseInt(request.getParameter("idCargaManual")); }catch(NumberFormatException e){}
    
    
    CargaXlsDaoImpl logErroresDao = new CargaXlsDaoImpl(user.getConn());
    CargaXls logErrores = null;
    String descrip = "";
    if(idCargaManual > 0){
       descrip = logErroresDao.findByPrimaryKey(idCargaManual).getLogText();
    }    
    
    
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">     
    </head>
    <body style="background: #ffffff" > 
        <%=descrip!=null?descrip:""%>
    </body>
</html>
<%}%>