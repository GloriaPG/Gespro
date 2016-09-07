<%-- 
    Document   : include_check_messages_ajax
    Created on : 14-feb-2013, 18:28:13
    Author     : ISCesarMartinez
--%>
<%@page import="com.tsp.gespro.bo.ZonaHorariaBO"%>
<%@page import="com.tsp.gespro.jdbc.DatosUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.jdbc.MovilMensajeDaoImpl"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.dto.MovilMensaje"%>
<%@page import="com.tsp.gespro.bo.MovilMensajeBO"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.MovilMensajeBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
if (user == null || user.getUser() == null) {
    //Redirección por javascript (cliente)
    out.print("<script>document.location.href='../../jsp/inicio/login.jsp?action=loginRequired&urlSource="+request.getRequestURI()+"?"+request.getQueryString()+"'</script>");
    //Redirección por java (servidor) ***No Funciona correctamente
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource="+request.getRequestURI()+"?"+request.getQueryString());
    response.flushBuffer();
}else{
    try{
        String mensajeAMostrar="";
        
        boolean isFiltroComunicacionConsola = false;
        int filtroIdReceptor = 0;
        int filtroIdEmisor=0; //No filtramos por emisor, recibir de todos
        
        MovilMensajeBO movilMensajeBO = new MovilMensajeBO(user.getConn());
        //si tiene Rol administrador mostramos unicamente mensajes a consola
        if (user.getUser().getIdRoles()==RolesBO.ROL_ADMINISTRADOR_DE_SUCURSAL
                || user.getUser().getIdRoles()==RolesBO.ROL_ADMINISTRADOR ||  user.getUser().getIdRoles()==RolesBO.ROL_DESARROLLO){
            isFiltroComunicacionConsola = true;
            movilMensajeBO.setUserConsola(true);
        }
        
       /* Empleado empleado = new EmpleadoBO(user.getConn()).findEmpleadoByUsuario(user.getUser().getIdUsuarios());
        if (empleado!=null)*/
            filtroIdReceptor = user.getUser().getIdUsuarios();
        
        filtroIdEmisor = user.getUser().getIdEmpresa();
        MovilMensaje[] movilMensajeDtoLista = movilMensajeBO.getMovilMensajesByFilter(
                        true, //los que se han recibido
                        null, //filtro de fecha min
                        null,  //filtro de fecha max
                        true, //filtro para mostrar solo los que no se ha visto
                        isFiltroComunicacionConsola, //filtro solo mensajes para Consola
                        filtroIdReceptor, //filtroReceptor
                        filtroIdEmisor); //filtroEmisor
        
        Usuarios usuario = null;
        UsuariosDaoImpl usuarioDaoImpl = new UsuariosDaoImpl(user.getConn());
        DatosUsuario emple = null;
        DatosUsuarioDaoImpl datosUsuarioDaoImpl = new DatosUsuarioDaoImpl(user.getConn());
        for (MovilMensaje msg : movilMensajeDtoLista){
            try{
            usuario = usuarioDaoImpl.findByPrimaryKey(msg.getIdUsuarioEmisor());
            emple = datosUsuarioDaoImpl.findByPrimaryKey(usuario.getIdDatosUsuario());}catch(Exception e){}
            if(emple != null){
                mensajeAMostrar += "<ul>Nuevo mensaje de " + (emple.getNombre()!=null?emple.getNombre().trim():"") + " " + (emple.getApellidoPat()!=null?emple.getApellidoPat().trim():"") + " " + (emple.getApellidoMat()!=null?emple.getApellidoMat().trim():"") +": <b>" + msg.getMensaje() + "</b><i> el "+ DateManage.formatDateTimeToNormalMinutes(msg.getFechaEmision()) +"</i>";
            }else{
                mensajeAMostrar += "<ul>Nuevo mensaje: <b>" + msg.getMensaje() + "</b><i> el "+ DateManage.formatDateTimeToNormalMinutes(msg.getFechaEmision()) +"</i>";
            }            
            mensajeAMostrar += "<a href=\"../catEmpleados/catEmpleado_Mensajes_form.jsp?idEmpleado="+ msg.getIdUsuarioEmisor() +"\" id=\"consultaForma\" title=\"Consultar\" class=\"modalbox_iframe\"> responder</a>";
                        
            //Actualizamos registro a leido
            msg.setRecibido(1);
            try{
                msg.setFechaRecepcion(ZonaHorariaBO.DateZonaHorariaByIdEmpresa(user.getConn(), new Date(), (int)user.getUser().getIdEmpresa()).getTime());
            }catch(Exception e){
                msg.setFechaRecepcion(new Date());
            }
            
            new MovilMensajeDaoImpl(user.getConn()).update(msg.createPk(), msg);
        }
        
        if (mensajeAMostrar.trim().length()>0){
%>
            <script>
                apprise('<center><b>Nuevos mensajes recibidos</b></center> <br/><%=mensajeAMostrar %>',{'animate':true});
            </script>    
<%
       }
    }catch(Exception ex){
%>
        <script>
            apprise('Error al intentar sincronizar modulo de mensajes: <%=ex.toString()%> ',{'animate':true});
        </script>
<%
        ex.printStackTrace();
    }
}
%>