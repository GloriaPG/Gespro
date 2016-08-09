<%-- 
    Document   : catSucursales_form
    Created on : 28/11/2012, 04:20:04 PM
    Author     : Leonardo
--%>

<%@page import="com.tsp.gespro.bo.UbicacionBO"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.dto.Ubicacion"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.PasswordBO"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el cliente tiene acceso a este topico
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
        //idEmpresa = 0;
        try {
            idEmpresa = Integer.parseInt(request.getParameter("idEmpresa"));
        } catch (NumberFormatException e) {
        }

        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
        
        EmpresaBO empresaBO = new EmpresaBO(user.getConn());
        Empresa empresasDto = null;
        if (idEmpresa > 0){
            empresaBO = new EmpresaBO(idEmpresa,user.getConn());
            empresasDto = empresaBO.getEmpresa();
        }
        
        
        //PARA LA DIRECCIÓN DE LA EMPRESA
        UbicacionBO ubicacionBO = new UbicacionBO(user.getConn());
        Ubicacion ubicacionesDto = null;
        if (empresaBO.getEmpresa().getIdUbicacionFiscal() > 0){
            ubicacionBO = new UbicacionBO(empresaBO.getEmpresa().getIdUbicacionFiscal(),user.getConn());
            ubicacionesDto = ubicacionBO.getUbicacion();
        }
        
        EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());     
    
        
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/skinCSS.jsp" />

        <jsp:include page="../include/jsFunctions.jsp"/>
        
        <script type="text/javascript">
                        //Recarga de BD dinámicamente el listado de clientes de la empresa
            function recargarSelectClientes(idEmpresa){    
                $.ajax({
                    type: "POST",
                    url: "catSucursales_ajax.jsp",
                    data: { mode: 'recargar_select_clientes', id_empresa : idEmpresa},
                    beforeSend: function(objeto){
                        $("#action_buttons").fadeOut("slow");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                            $("#div_select_cliente").html(datos);
                            $("#ajax_loading").fadeOut("slow");
                            $("#action_buttons").fadeIn("slow");
                            iniciarFlexSelect();
                        }else{
                            $("#ajax_loading").html(datos);
                            $("#action_buttons").fadeIn("slow");
                        }
                    }
                });
            }
            
            
            function selectCliente(idCliente){
                    $.ajax({
                        type: "POST",
                        url: "catSucursales_ajax.jsp",
                        data: { mode: 'select_matriz', id_cliente : idCliente },
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               strJSONCliente = $.trim(datos.replace('<!--EXITO-->',''));
                               
                               $("#ajax_loading").fadeOut("slow");
                               $("#action_buttons").fadeIn("slow");
                           }else{
                               $("#ajax_loading").html(datos);
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });
            }
            
            function iniciarFlexSelect(){
                $("#matriz").flexselect({
                    jsFunction:  function(id) { selectCliente(id); }
                });

                $("select.flexselect").flexselect();
            }
            //****-----------------FIN ACCIONES DE SELECCION CLIENTE
            

            function grabar(){
                if(validar()){                            
                    $.ajax({
                        type: "POST",
                        url: "catSucursales_ajax.jsp",
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
                                            location.href = "catSucursales_list.jsp?pagina="+"<%=paginaActual%>";
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
            }

            function validar(){
                /*
                if(jQuery.trim($("#nombre").val())==""){
                    apprise('<center><img src=../../images/warning.png> <br/>El dato "nombre de contacto" es requerido</center>',{'animate':true});
                    $("#nombre_contacto").focus();
                    return false;
                }
                */
                return true;
            }
            
            function checks() {
                
                var razon = $("#ticket_razon").attr("checked");
                var nComercial = $('#ticket_nComercial').attr("checked");
                
                
                if(razon==false){
                    $('#ticket_razon').val("0");
                }else{
                    $('#ticket_razon').val("1");
                }  
                if(nComercial==false){
                    $('#ticket_nComercial').val("0");
                }else{
                    $('#ticket_nComercial').val("1");
                } 
                    
            }
            
             $(document).ready(function() {
                recargarSelectClientes(<%= idEmpresa %>);
                //Si se recibio el parametro para que el modo sea en forma de popup
                <%= mode.equals("3")? "mostrarFormPopUpMode();":""%>
            });
        </script>
    </head>
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Administración</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_sucursales.png" alt="icon"/>
                                    <% if(empresasDto!=null &&  !mode.equals("") ){%>
                                    Editar Empresa ID <%=empresasDto!=null?empresasDto.getIdEmpresa():"" %>
                                    <%}else{%>
                                    Nueva Sucursal
                                    <%}%>
                                </span>
                                <div style="float: right;" >
                                    <label>** : Heredados de Matriz &nbsp;</label>
                                </div>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="idEmpresa" name="idEmpresa" value="<%= empresasDto!=null &&  !mode.equals("")?empresasDto.getIdEmpresa():"" %>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    <p>
                                        <label>RFC &nbsp;**:</label><br/>
                                        <input maxlength="30" type="text" id="rfc_sucursal" name="rfc_sucursal" style="width:300px"
                                               readonly disabled value="<%=empresasDto!=null?empresaBO.getEmpresa().getRfc():"" %>"/>                                        
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Razón Social &nbsp;**:</label><br/>
                                        <input maxlength="30" type="text" id="razonsocial_sucursal" name="razonsocial_sucursal" style="width:300px"
                                               readonly disabled value="<%=empresasDto!=null?empresaBO.getEmpresa().getRazonSocial():"" %>"/>                                       
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Regimen Fiscal &nbsp;**:</label><br/>
                                        <input maxlength="30" type="text" id="regimen_sucursal" name="regimen_sucursal" style="width:300px"
                                               readonly disabled value="<%=empresasDto!=null?empresaBO.getEmpresa().getRegimenFiscal():"" %>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>*Nombre Comercial:</label><br/>
                                        <input maxlength="30" type="text" id="nombreSucursal" name="nombreSucursal" style="width:300px"
                                               value="<%=empresasDto!=null &&  !mode.equals("")?empresaBO.getEmpresa().getNombreComercial():"" %>"/>                                        
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Matriz:</label><br/>
                                        <div id="div_select_cliente" name="div_select_cliente" style="display: inline;" >
                                        </div>
                                    </p>  
                                    <br/>                                    
                                    <p>
                                        <label>Estatus:</label>
                                        <input type="checkbox" class="checkbox" <%=empresasDto!=null?(empresasDto.getIdEstatus()==1?"checked":""):"checked" %>
                                               id="estatus" name="estatus" value="1"> <label for="estatus">Activo</label>
                                    </p>
                                    <br/><br/>
                                    
                                    <div id="action_buttons">
                                        <p>
                                            <input type="button" id="enviar" value="Guardar" onclick="grabar();"/>
                                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                        </p>
                                    </div>
                                    
                            </div>
                        </div>
                        <!-- End left column window -->
                        
                        <!--Columna derecha-->
                        <div class="column_right">
                            <div class="header">
                                <span>
                                    Domicilio
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                <p>
                                    <label>*Calle</label><br/>
                                    <input maxlength="100" type="text" id="calle" name="calle" style="width:300px"
                                            value="<%=ubicacionesDto!=null &&  !mode.equals("") ?ubicacionesDto.getCalle():"" %>"/>
                                </p>
                                <br/>
                                <p>
                                    <label>*Num Exterior</label><br/>
                                    <input maxlength="30" type="text" id="ext" name="ext" style="width:300px"
                                            value="<%=ubicacionesDto!=null &&  !mode.equals("")?ubicacionesDto.getNumExt():"" %>"/>
                                </p>
                                <br/>
                                <p>
                                    <label>Num Interior</label><br/>
                                    <input maxlength="30" type="text" id="int" name="int" style="width:300px"
                                            value="<%=ubicacionesDto!=null &&  !mode.equals("")?ubicacionesDto.getNumInt():"" %>"/>
                                </p>
                                <br/>
                                <p>
                                    <label>*Colonia:</label><br/>
                                    <input maxlength="100" type="text" id="colonia" name="colonia" style="width:300px"
                                            value="<%=ubicacionesDto!=null &&  !mode.equals("")?ubicacionesDto.getColonia():"" %>"/>
                                </p>
                                <br/>
                                <p>
                                    <label>C.P.</label><br/>
                                    <input maxlength="5" type="text" id="cp" name="cp" style="width:300px"
                                            value="<%=ubicacionesDto!=null &&  !mode.equals("")?ubicacionesDto.getCodigoPostal():"" %>"
                                            onkeypress="return validateNumber(event);"/>
                                </p>
                                <br/>
                                <p>
                                    <label>*Municipio/Delegación:</label><br/>
                                    <input maxlength="100" type="text" id="delMuni" name="delMuni" style="width:300px"
                                            value="<%=ubicacionesDto!=null &&  !mode.equals("")?ubicacionesDto.getMunicipio():"" %>"/>
                                </p>
                                <br/>
                                    <p>
                                    <label>*Estado</label><br/>
                                    <input maxlength="50" type="text" id="estado" name="estado" style="width:300px"
                                            value="<%=ubicacionesDto!=null &&  !mode.equals("")?ubicacionesDto.getEstado():"" %>"/>
                                </p>
                                <br/>
                                <p>
                                    <label>*País</label><br/>
                                    <input maxlength="100" type="text" id="pais" name="pais" style="width:300px"
                                            value="<%=ubicacionesDto!=null &&  !mode.equals("")?ubicacionesDto.getPais():"México" %>"/>
                                </p>
                            </div>
                        </div>
                        <!--Fin Columna derecha-->
                        
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