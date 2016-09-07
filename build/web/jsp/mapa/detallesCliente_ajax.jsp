<%-- 
    Document   : detallesCliente_ajax
    Created on : 11/01/2013, 08:27:48 PM
    Author     : Luis
--%>

<%@page import="com.tsp.gespro.factory.EstatusDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Estatus"%>
<%@page import="com.tsp.gespro.factory.ClienteDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    long id = 0l;
    try{
        id = Long.parseLong(request.getParameter("id"));
    }catch(Exception e){}
    if(id > 0){
        Cliente clienteDto = null;
        try{
            clienteDto = ClienteDaoFactory.create().findByPrimaryKey(Integer.parseInt(request.getParameter("id")));
        }catch(Exception e){}
        if(clienteDto!=null){
            Estatus estatusDto = null;
            try{
                estatusDto = EstatusDaoFactory.create().findByPrimaryKey(clienteDto.getIdEstatus());
            }catch(Exception e){}
            
            
            String nombrecliente ="";
            if(clienteDto.getNombreComercial()!=null&&!clienteDto.getNombreComercial().toUpperCase().equals("NULL")&&!clienteDto.getNombreComercial().toUpperCase().equals("Campo por llenar")){
                nombrecliente += clienteDto.getNombreComercial();
            }
            
            
            out.print(""
                    + "<p>"
                    + "      <label>Nombre:</label><br/>" 
                    + "      " + nombrecliente
                    + "</p>"
                    + "<p>"
                    + "      <label>Estado:</label><br/>" 
                    + "      " + (estatusDto!=null?estatusDto.getIdEstatus()!=3?estatusDto.getNombre():"ACTIVO</br>(No disponible para facturar)":"")
                    + "</p>"
                    
                    + "<!--EXITO-->");
        }else{
            out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
        }
    }else{
        out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
    }
    
%>