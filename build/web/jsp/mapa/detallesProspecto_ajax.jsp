<%-- 
    Document   : detallesProspecto_ajax
    Created on : 14/01/2013, 02:49:13 PM
    Author     : Luis
--%>


<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.tsp.gespro.factory.EstatusDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Estatus"%>
<%@page import="com.tsp.gespro.factory.ProspectoDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Prospecto"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    long id = 0l;
    try{
        id = Long.parseLong(request.getParameter("id"));
    }catch(Exception e){}
    if(id > 0){
        Prospecto prospectoDto = null;
        try{
            prospectoDto = ProspectoDaoFactory.create().findByPrimaryKey(Integer.parseInt(request.getParameter("id")));
        }catch(Exception e){}
        if(prospectoDto!=null){
            Estatus estatusDto = null;
            try{
                estatusDto = EstatusDaoFactory.create().findByPrimaryKey((int) prospectoDto.getIdEstatus());
            }catch(Exception e){}
            
            
            
            out.print(""
                    + "<p>"
                    + "      <label>Nombre:</label><br/>" 
                    + "      " + prospectoDto.getRazonSocial()
                    + "</p>"
                    + "<p>"
                    + "      <label>Estado:</label><br/>" 
                    + "      " + (estatusDto!=null?estatusDto.getNombre():"")
                    + "</p>"
                   /* + "<p>"
                    + "      <label>Monto interesado:</label><br/>" 
                    + "      " + prospectoDto.getMontoInteresado()
                    + "</p>" */
                    + "<p>"
                    + "      <label>Fecha de registro:</label><br/>" 
                    + "      " + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(prospectoDto.getFechaRegistro())
                    + "</p>"
                 /*   + "<p>"
                    + "      <label>Seguimiento:</label><br/>" 
                    + "      " + htmlSeguimiento
                    + "</p>" */
                    );                                       
            
            
            
            out.print("<!--EXITO-->");
        }else{
            out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
        }
    }else{
        out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
    }
    
%>
