<%--
    Document   : main
    Created on : 16/08/2011, 11:41:27 PM
    Author     : ISC Cesar Martinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.dto.Roles"%>
<%@page import="com.tsp.gespro.jdbc.RolesDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user==null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
}else{
    EmpresaBO empresaBO = new EmpresaBO(user.getConn());
    EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());     
    
    String verificadorSesionGuiaCerrada = "0";
try{
    if(session.getAttribute("sesionCerrada")!= null){
        verificadorSesionGuiaCerrada = (String)session.getAttribute("sesionCerrada");
    }
}catch(Exception e){}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../../jsp/include/titleApp.jsp" /></title>
        
        <jsp:include page="../../jsp/include/skinCSS.jsp" />

        <jsp:include page="../../jsp/include/jsFunctions.jsp"/>
    </head>
    <body>       
        <div class="content_wrapper">
            
            <jsp:include page="../include/header.jsp" flush="true"/>
            
            <jsp:include page="../include/leftContent.jsp"/>
            
            <!-- Inicio de Contenido -->
            <%  RolesDaoImpl rolesDaoImpl=new RolesDaoImpl(user.getConn());
                Roles rol=rolesDaoImpl.findByPrimaryKey(user.getUser().getIdRoles());
                if(!rol.getNombre().equals("CLIENTE")){
            %>  
            <div id="content">
                
                <div class="inner">                                      
                    <jsp:include page="../Dashboard/empleados_estatus.jsp" flush="true"/>
                                      
                </div>
                
                <jsp:include page="../include/footer.jsp"/>
            </div>
            <%}else{%>
            <div id="content">
                
                <div class="inner">                                      
                    Bienvenido <%=user.getUser().getUserName()%>
                                      
                </div>
                
                <jsp:include page="../include/footer.jsp"/>
            <%}%>
            <!-- Fin de Contenido-->
        </div>
    </body>   
</html>
<%}%>