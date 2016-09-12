<%-- 
    Document   : detallesPromotor_ajax
    Created on : 9/01/2013, 07:37:43 PM
    Author     : Luis
--%>

<%@page import="com.tsp.gespro.factory.EstadoEmpleadoDaoFactory"%>
<%@page import="com.tsp.gespro.dto.EstadoEmpleado"%>
<%@page import="com.tsp.gespro.jdbc.EmpleadoBitacoraPosicionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpleadoBitacoraPosicion"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.factory.UsuariosDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.factory.EstatusDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Estatus"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    int id = 0;
    try{
        id = Integer.parseInt(request.getParameter("id"));
    }catch(Exception e){}
    if(id > 0){
        Usuarios empleadoDto = null;
        DatosUsuario datosUsuarioDto = null;
        
        try{
            empleadoDto = UsuariosDaoFactory.create().findByPrimaryKey(id);
            
            UsuarioBO usuarioBO = new UsuarioBO(user.getConn());
            usuarioBO = new UsuarioBO(user.getConn(),id);
            datosUsuarioDto =  usuarioBO.getDatosUsuario();
        }catch(Exception e){}
        if(empleadoDto!=null){
            Estatus estatusDto = null;
            try{
                estatusDto = EstatusDaoFactory.create().findByPrimaryKey(empleadoDto.getIdEstatus());
            }catch(Exception e){}
            
            EmpleadoBitacoraPosicion bitEmp = null;
            String EstadoEmp = "SIN DETALLE";
            try{
                EmpleadoBitacoraPosicionDaoImpl bitacoraDao = new EmpleadoBitacoraPosicionDaoImpl();
                String filtro = " ID_USUARIO = "+ empleadoDto.getIdUsuarios()+ " ORDER BY FECHA DESC LIMIT 0,1";
                bitEmp = bitacoraDao.findByDynamicWhere(filtro,null)[0];                   
                
            }catch(Exception e){}
            
            try{
                EstadoEmpleado estadoDto = EstadoEmpleadoDaoFactory.create().findByPrimaryKey(empleadoDto.getIdEstadoEmpleado());
                EstadoEmp = (estadoDto!=null?estadoDto.getNombre():"SIN DETALLE");
            }catch(Exception e){};
            
            out.print(""
                    + "<p>"
                    + "      <label>Nombre:</label><br/>" 
                    + "      " + (datosUsuarioDto.getNombre()!=null?datosUsuarioDto.getNombre():"") + " " + (datosUsuarioDto.getApellidoPat()!=null?" " + datosUsuarioDto.getApellidoPat():"") + " " +(datosUsuarioDto.getApellidoMat()!=null?" " + datosUsuarioDto.getApellidoMat():"")
                    + "</p>"
                    + "<p>"
                    + "      <label>Estatus:</label><br/>" 
                    + "      " + EstadoEmp
                    + "</p>"
                    + "<p>"
                    + "      <label>No. Empleado:</label><br/>" 
                    + "      " + empleadoDto.getNumEmpleado()
                    + "</p>"
                    + "<p>"
                    + "      <label>Tel&eacute;fono local:</label><br/>" 
                    + "      " + datosUsuarioDto.getTelefono()
                    + "</p>"
                    + "<p>"
                    + "      <label>Correo:</label><br/>" 
                    + "      " + datosUsuarioDto.getCorreo()
                    + "</p>"
                    + "<!--EXITO-->");
        }else{
            out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
        }
    }else{
        out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
    }
    
%>