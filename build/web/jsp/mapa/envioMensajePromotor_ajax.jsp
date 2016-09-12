<%-- 
    Document   : envioMensajePromotor_ajax
    Created on : 15/01/2013, 02:45:12 PM
    Author     : Luis
--%>

<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.factory.UsuariosDaoFactory"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.factory.MovilMensajeDaoFactory"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.dto.MovilMensaje"%>
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
            
            String mensaje = request.getParameter("txt_mensaje");
            if(mensaje!=null && !mensaje.trim().equals("")){
            
                MovilMensaje mensajeDto = new MovilMensaje();
                mensajeDto.setEmisorTipo(2);
                mensajeDto.setFechaEmision(new Date());
                mensajeDto.setIdUsuarioEmisor(0);
                mensajeDto.setIdUsuarioReceptor(Integer.parseInt(""+id));
                mensajeDto.setReceptorTipo(1);
                mensajeDto.setMensaje(mensaje);
                
                try{
                    MovilMensajeDaoFactory.create().insert(mensajeDto);
                    out.print("<!--EXITO-->Mensaje enviado satisfactoriamente");
                }catch(Exception e){
                    out.print("<!--ERROR-->Ocurri&oacute; un error al almacenar el mensaje.");
                }
                
            }else{
                out.print("<!--ERROR-->Debe indicar el mensaje a enviar.");
            }
            
        }else{
            out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
        }
    }else{
        out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
    }
%>