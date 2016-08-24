<%-- 
    Document   : catEmpleados_form.jsp
    Created on : 08-01-2013, 12:13:49
    Author     : Leonardo 
--%>

<%@page import="com.tsp.gespro.bo.HorariosBO"%>
<%@page import="com.tsp.gespro.bo.EmpleadoRolBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.dto.EmpleadoBitacoraPosicion"%>
<%@page import="com.tsp.gespro.jdbc.EmpleadoBitacoraPosicionDaoImpl"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.DispositivoMovilBO"%>
<%@page import="com.tsp.gespro.dto.DispositivoMovil"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.PasswordBO"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el Empleado tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {
        
        int paginaActual = 1;
        try{
            paginaActual = Integer.parseInt(request.getParameter("pagina"));
        }catch(Exception e){}

       
        
        int idEmpresa = user.getUser().getIdEmpresa();
        
        /*
         * Parámetros
         */
        int idUsuario = 0;
        try {
            idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
        } catch (NumberFormatException e) {
        }
               

        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         *   3 = nuevo (modalidad PopUp [cotizaciones, pedidos, facturas]) 
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
        String newRandomPass = "";
        
        UsuarioBO usuarioBO = new UsuarioBO(user.getConn());
        Usuarios usuariosDto = null;
        DatosUsuario datosUsuarioDto = null;
        
        if (idUsuario > 0){
            usuarioBO = new UsuarioBO(user.getConn(),idUsuario);
            usuariosDto = usuarioBO.getUser();
            
             datosUsuarioDto =  usuarioBO.getDatosUsuario();
        }else{
            newRandomPass = new PasswordBO().generateValidPassword();
        }
        
      
        EmpresaBO empresaBO = new EmpresaBO(user.getConn());
        EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());
        
    
 
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="shortcut icon" href="../../images/favicon.ico">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/skinCSS.jsp" />

        <jsp:include page="../include/jsFunctions.jsp"/>
        
        <script type="text/javascript">
            
            function grabar(){               
                    $.ajax({
                        type: "POST",
                        url: "catEmpleados_ajax.jsp",
                        data: $("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_message").html(datos);
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                                        function(r){
                                            <% if (!mode.equals("3")) {%>
                                                location.href = "catEmpleados_list.jsp?pagina="+"<%=paginaActual%>";
                                            <%}else{%>
                                                parent.recargarSelectEmpleados();
                                                parent.$.fancybox.close();
                                            <%}%>
                                            
                                        });
                           }else{
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").html(datos);
                               $("#ajax_message").fadeIn("slow");
                               $("#action_buttons").fadeIn("slow");
                               $.scrollTo('#inner',800);
                           }
                        }
                    });               
            }

            
            
            $(document).ready(function() {
                //Si se recibio el parametro para que el modo sea en forma de popup
                <%= mode.equals("3")? "mostrarFormPopUpMode();":""%>
            });
            
            function mostrarFormPopUpMode(){
		$('#left_menu').hide();
                $('#header').hide();
		//$('#show_menu').show();
		$('body').addClass('nobg');
		$('#content').css('marginLeft', 30);
		$('#wysiwyg').css('width', '97%');
		setNotifications();
            }
            
            
            
            
        </script>
    </head>
    <body>
        <div class="content_wrapper">

            <% if (!mode.equals("3")) {%>
                <jsp:include page="../include/header.jsp" flush="true"/>
                <jsp:include page="../include/leftContent.jsp"/>
            <% } %>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner" id="leito">
                    <h1>Catálogos</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    
                                    <%if(usuariosDto!=null){
                                    
                                        long s = (new Date()).getTime();
                                        long d = 0; 
                                        try{
                                            EmpleadoBitacoraPosicionDaoImpl bitacoraDao = new EmpleadoBitacoraPosicionDaoImpl();
                                            String filtro = " ID_USUARIO = "+ usuariosDto.getIdUsuarios()+ " ORDER BY ID_BITACORA_POSICION DESC LIMIT 0,1";
                                            EmpleadoBitacoraPosicion bitEmp = bitacoraDao.findByDynamicWhere(filtro,null)[0];

                                            d = bitEmp.getFecha().getTime();
                                            //d = empleadoDto.getFechaHora().getTime();
                                        }catch(Exception e){}
                                        long diferencia = s - d;
                                        System.out.println("-------DIFERENCIA: "+diferencia);
                                        if(diferencia < 300000){
                                        %>
                                            <img src="../../images/estatusEmpleado/icon_activoTrabajando.png" alt="icon"/>                                            
                                        <%}else{%>
                                            <img src="../../images/estatusEmpleado/icon_desactivado.png" alt="icon"/>                                           
                                        <%}
                                        
                                    }else{%>
                                        <img src="../../images/estatusEmpleado/icon_desactivado.png" alt="icon"/>
                                    <%}
                                    %>
                                    
                                    <% if(usuariosDto!=null){%>
                                    Editar Empleado ID <%=usuariosDto!=null?usuariosDto.getIdUsuarios():"" %>
                                    <%}else{%>
                                    Empleado
                                    <%}%>
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="idUsuario" name="idUsuario" value="<%=usuariosDto!=null?usuariosDto.getIdUsuarios():"" %>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    <p>
                                        <label>*Número de Empleado:</label><br/>
                                        <input maxlength="50" type="text" id="numEmpleado" name="numEmpleado" style="width:300px;"
                                               value="<%=usuariosDto!=null?usuariosDto.getNumEmpleado():"" %>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>*Nombre:</label><br/>
                                        <input maxlength="70" type="text" id="nombreEmpleado" name="nombreEmpleado" style="width:300px;"
                                               value="<%=datosUsuarioDto!=null?datosUsuarioDto.getNombre():"" %>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>*Apellido Paterno:</label><br/>
                                        <input maxlength="70" type="text" id="apellidoPaternoEmpleado" name="apellidoPaternoEmpleado" style="width:300px;"
                                               value="<%=datosUsuarioDto!=null?datosUsuarioDto.getApellidoPat() :"" %>"/>
                                    </p>
                                    <br/>                                    
                                    <p>
                                        <label>*Apellido Materno:</label><br/>
                                        <input maxlength="70" type="text" id="apellidoMaternoEmpleado" name="apellidoMaternoEmpleado" style="width:300px;"
                                               value="<%=datosUsuarioDto!=null?datosUsuarioDto.getApellidoMat():"" %>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Teléfono:</label><br/>                                        
                                        <input maxlength="10" type="text" id="telefonoEmpleado" name="telefonoEmpleado" style="width:300px"
                                               value="<%=datosUsuarioDto!=null?datosUsuarioDto.getTelefono():"" %>"
                                               onkeypress="return validateNumber(event);"/>
                                    </p>  
                                    <br/> 
                                    <p>
                                        <label>Correo Electrónico:</label><br/>
                                        <input maxlength="100" type="text" id="emailEmpleado" name="emailEmpleado" style="width:300px"
                                               value="<%=datosUsuarioDto!=null?datosUsuarioDto.getCorreo():"" %>"/>
                                    </p>  
                                    <br/>
                                    <p>
                                        <label>Ciudad:</label><br/>
                                        <input maxlength="100" type="text" id="ciudad" name="ciudad" style="width:300px"
                                               value="<%=datosUsuarioDto!=null?datosUsuarioDto.getCiudad():"" %>"/>
                                    </p>  
                                    <br/> 
                                    <p>
                                        <label>Dirección:</label><br/>
                                        <input maxlength="100" type="text" id="direccionEmpleado" name="direccionEmpleado" style="width:300px"
                                               value="<%=datosUsuarioDto!=null?datosUsuarioDto.getDireccion():"" %>"/>
                                    </p>  
                                    <br/> 
                                    <p>
                                        <label>Dispositivo Movil:</label><br/>
                                        <select size="1" id="idDispositivoMovilEmpleado" name="idDispositivoMovilEmpleado" >
                                            <option value="-1" >Selecciona un Dispositivo</option>
                                                <%
                                                    out.print(new DispositivoMovilBO(user.getConn()).getDispositivosMovilesByIdHTMLCombo(idEmpresa, (usuariosDto!=null?usuariosDto.getIdDispositivo():-1) ));                                                     
                                                %>
                                        </select>                                        
                                    </p>  
                                    <br/> 
                                    <p>
                                        <label>*Rol Asignado:</label><br/>
                                        <select size="1" id="idRolEmpleado" name="idRolEmpleado" style="">
                                            <option value="-1">Selecciona un Rol</option>
                                                <%
                                                   out.print(new EmpleadoRolBO(user.getConn()).getRolesByIdHTMLComboGespro(idEmpresa, (usuariosDto!=null?usuariosDto.getIdRoles():-1), user.getUser().getIdRoles() )); //Metodo original                                                    
                                                %>
                                        </select>                                        
                                    </p>  
                                    <br/> 
                                    <p>
                                        <label>*Asignar a Empresa/Sucursal:</label><br/>
                                        <select size="1" id="idSucursalEmpresaAsignado" name="idSucursalEmpresaAsignado">
                                            <option value="-1">Selecciona una Sucursal</option>
                                                <%
                                                    out.print(new EmpresaBO(user.getConn()).getEmpresasByIdHTMLCombo(idEmpresa, (usuariosDto!=null?usuariosDto.getIdEmpresa():-1) ));                                                    
                                                %>
                                        </select>                                        
                                    </p>  
                                    <br/>                                                                         
                                    <p>
                                        <input type="checkbox" class="checkbox" <%=usuariosDto!=null?(usuariosDto.getIdEstatus()==1?"checked":""):"checked" %> id="estatus" name="estatus" value="1"> <label for="estatus">Activo</label>
                                    </p>
                                                                       
                                    <br/><br/>
                                    
                                    <% if (!mode.equals("3")) {%>
                                        <div id="action_buttons">
                                            <p>
                                                <input type="button" id="enviar" value="Guardar" onclick="grabar();"/>
                                                <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                            </p>
                                        </div>
                                    <%}else{
                                        //En caso de ser Formulario en modo PopUp
                                    %>
                                        <div id="action_buttons">
                                            <p>
                                                <input type="button" id="enviar" value="Guardar" onclick="grabar();"/>
                                                <input type="button" id="regresar" value="Cerrar" onclick="parent.$.fancybox.close();"/>
                                            </p>
                                        </div>
                                    <%}%>
                                    
                            </div>
                        </div>
                        <!-- End left column window -->
                        <!--Inicio columna derecha -->
                        <div class="column_right">
                            <div class="header">
                                <span>                                    
                                    Datos de Acceso
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="idUsuario" name="idUsuario" value="<%=usuariosDto!=null?usuariosDto.getIdUsuarios():"" %>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    <p>
                                        <label>*Usuario:</label><br/>
                                        <input maxlength="50" type="text" id="usuarioEmpleado" name="usuarioEmpleado" style="width:300px;"
                                               value="<%=usuariosDto!=null?usuariosDto.getUserName():"" %>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>*Contraseña:</label><br/>
                                        <input maxlength="20" type="text" id="contrasenaEmpleado" name="contrasenaEmpleado" style="width:300px;"
                                               value=""/>
                                    </p>
                                    <br/>                                    
                            </div>
                        </div>
                        <!-- Fin columna Derecha -->
                        
                        <!--Inicio columna derecha -->
                        <div class="column_right">
                            <div class="header">
                                <span>                                    
                                    Datos Adicionales
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <p>
                                        <label>Distancia obligatoria (En metros):</label><br/>
                                        <input maxlength="8" type="text" id="distanciaObligaEmple" name="distanciaObligaEmple" style="width:300px"
                                               value="<%=usuariosDto!=null?usuariosDto.getDistanciaObligatorio():"0" %>" onkeypress="return validateNumber(event);"/>
                                    
                                    </p>  
                                    <br/>
                                    
                                    <p>
                                        <label>Solicitar Estatus cada (min):</label><br/>
                                        <input maxlength="8" type="text" id="tiempoEstatus" name="tiempoEstatus" style="width:300px"
                                               value="<%=usuariosDto!=null?usuariosDto.getMinutosEstatus():"0" %>" onkeypress="return validateNumber(event);"/>
                                    
                                    </p>  
                                    <br/>
                                   <p>
                                    <label>Horario de Trabajo:</label><br/>
                                        <select size="1" id="idhorarioAsignado" name="idhorarioAsignado">
                                            <option value="-1">Selecciona un Horario</option>
                                                <%
                                                    out.print(new HorariosBO(user.getConn()).getHorariosByIdHTMLCombo(idEmpresa, (usuariosDto!=null?usuariosDto.getIdHorarioAsignado():-1) ));                                                    
                                                %>
                                        </select>
                                    </p>  
                                    <br/>   
                            </div>
                        </div>
                        <!-- Fin columna Derecha -->
                        
                        
                        
                        
                    </div>
                    </form>
                    <!--TODO EL CONTENIDO VA AQUÍ-->

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>
    </body>
</html>
<%}%>