<%-- 
    Document   : catSucursales_form
    Created on : 28/11/2012, 04:20:04 PM
    Author     : Leonardo
--%>

<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalSucursalValor"%>
<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalProspectoValor"%>
<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalSucursalValorDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalSucursal"%>
<%@page import="java.util.List"%>
<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalSucursalDAO"%>
<%@page import="com.tsp.gespro.hibernate.dao.EtiquetaFormularioSucursalDAO"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.tsp.gespro.hibernate.pojo.EtiquetaFormularioSucursal"%>
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
<jsp:useBean id="helperEtiquetaSucursal" class="com.tsp.gespro.hibernate.dao.EtiquetaFormularioSucursalDAO"/>

<%
//Verifica si el cliente tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {
        HashMap<String, EtiquetaFormularioSucursal> camposSucursal = helperEtiquetaSucursal.getMap(user.getUser().getIdUsuarios());

        int paginaActual = 1;
        try {
            paginaActual = Integer.parseInt(request.getParameter("pagina"));
        } catch (Exception e) {
        }

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
        if (idEmpresa > 0) {
            empresaBO = new EmpresaBO(idEmpresa, user.getConn());
            empresasDto = empresaBO.getEmpresa();
        }

        //PARA LA DIRECCIÓN DE LA EMPRESA
        UbicacionBO ubicacionBO = new UbicacionBO(user.getConn());
        Ubicacion ubicacionesDto = null;
        if (empresaBO.getEmpresa().getIdUbicacionFiscal() > 0) {
            ubicacionBO = new UbicacionBO(empresaBO.getEmpresa().getIdUbicacionFiscal(), user.getConn());
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
                                    


                    function grabar(){
                    if (validar()){
                    var adicionalesSucursalValidacion = [];
                    $('#areaCamposAdicionalesSucursal *[id*=HiddenAdicional]:hidden').each(function () {
                    var etiqueta = $(this).val();
                    if (etiqueta != "") {
                    var tipo = $("#" + etiqueta.replace(" ", "") + "TipoAdicional").val()
                            var obligatorio = $("#" + etiqueta.replace(" ", "") + "ObligatorioAdicional").val();
                    var idAdicional = $("#" + etiqueta.replace(" ", "") + "IdAdicional").val();
                    var valorAdicional = $("#" + etiqueta.replace(" ",  "") +  "IdValor").val();
                    var  idSucursal  =  $("#idEmpresa").val()?$("#idEmpresa").val():0;
                    var  adicionalSucursal  =  {idAdicional: idAdicional,  idSucursal: idSucursal,  etiqueta: etiqueta,  obligatorio: obligatorio,  tipo: tipo,  valor: valorAdicional};
                    adicionalesSucursalValidacion.push(adicionalSucursal);
                    }
                    });
                    console.log(adicionalesSucursalValidacion);
                    $.ajax({
                    type: "POST",
                            url: "ajaxValidaciones.jsp",
                            data: JSON.stringify(adicionalesSucursalValidacion),
                            success: function (datos) {
                            if  (datos.indexOf("--EXITO-->",  0) >  0) {
                            $.ajax({
                            type: "POST",
                                    url: "catSucursales_ajax.jsp",
                                    data: $("#frm_action").serialize(),
                                    success: function (datos) {
                                    if  (datos.indexOf("--EXITO-->",  0) >  0) {
                                    var  partes  =  [];
                                    partes  =  datos.split(":");
                                    var  adicionalesSucursal  =  [];
                                    $('#areaCamposAdicionalesSucursal *[id*=HiddenAdicional]:hidden').each(function () {
                                    var  etiqueta  =  $(this).val();
                                    if  (etiqueta !=  "") {
                                    var  tipo  =  $("#" +  etiqueta.replace(" ",  "") +  "TipoAdicional").val();
                                            var  obligatorio  =  $("#" +  etiqueta.replace(" ",  "") +  "ObligatorioAdicional").val();
                                    var  idAdicional  =  $("#" +  etiqueta.replace(" ",  "") +  "IdAdicional").val();
                                    var  valorAdicional  =  $("#" +  etiqueta.replace(" ",  "") +  "IdValor").val();
                                    var  idSucursal  =  partes.length >  1 ? partes[1] : $("#idEmpresa").val();
                                    var  adicionalSucursal  =  {idAdicional: idAdicional,  idSucursal: idSucursal,  etiqueta: etiqueta,  obligatorio: obligatorio,  tipo: tipo,  valor: valorAdicional};
                                    adicionalesSucursal.push(adicionalSucursal);
                                    }
                                    });
                                    $.ajax({
                                    type: "POST",
                                            url: "ajaxAdicionalesSucursal.jsp",
                                            data: JSON.stringify(adicionalesSucursal),
                                            beforeSend: function (objeto) {
                                            $("#action_buttons").fadeOut("slow");
                                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                                            $("#ajax_loading").fadeIn("slow");
                                            },
                                            success: function (datos) {
                                            console.log("datos: " +  datos);
                                            if  (datos.indexOf("--EXITO-->",  0) >  0) {
                                            console.log("EXITO!");
                                            $("#ajax_message").html(datos);
                                            $("#ajax_loading").fadeOut("slow");
                                            $("#ajax_message").fadeIn("slow");
                                            apprise('<center><img src=../../images/info.png> <br/>' +  datos + '</center>', {'animate':true},
                                                    function(r){
                                                    location.href  =  "catSucursales_list.jsp?pagina=" + "<%=paginaActual%>";
                                                    });
                                            } else {
                                            $("#ajax_loading").fadeOut("slow");
                                            $("#ajax_message").html("Ocurrió un error al intentar guardar los datos.");
                                            $("#ajax_message").fadeIn("slow");
                                            $("#action_buttons").fadeIn("slow");
                                            }
                                            }
                                    });
                                    } else {
                                    $("#ajax_loading").fadeOut("slow");
                                    $("#ajax_message").html(datos);
                                            $("#ajax_message").fadeIn("slow");
                                            $("#action_buttons").fadeIn("slow");
                                            $.scrollTo('#inner', 800);
                                        }
                                    }
                                });

                            } else {
                            console.log(datos);
                                $("#ajax_loading").fadeOut("slow");
                                $("#ajax_message").html(datos);
                                $("#ajax_message").fadeIn("slow");
                                $("#action_buttons").fadeIn("slow");
                                $.scrollTo('#inner', 800);
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
                //Si se recibio el parametro para que el modo sea en forma de popup
            <%= mode.equals("3") ? "mostrarFormPopUpMode();" : ""%>
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
                                        <% if (empresasDto != null && !mode.equals("")) {%>
                                        Editar Empresa ID <%=empresasDto != null ? empresasDto.getIdEmpresa() : ""%>
                                        <%} else {%>
                                        Nueva Sucursal
                                        <%}%>
                                    </span>
                                    <div style="float: right;" >
                                        <label>** : Heredados de Matriz &nbsp;</label>
                                    </div>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                    <input type="hidden" id="idEmpresa" name="idEmpresa" value="<%= empresasDto != null && !mode.equals("") ? empresasDto.getIdEmpresa() : ""%>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal rfc = camposSucursal.get(EtiquetaFormularioSucursalDAO.RFC);
                                            if (rfc == null) {
                                                rfc = new EtiquetaFormularioSucursal();
                                                rfc.setCampo(EtiquetaFormularioSucursalDAO.RFC);
                                                rfc.setEtiqueta(EtiquetaFormularioSucursalDAO.RFC_DEFAULT);
                                                rfc.setObligatorio(EtiquetaFormularioSucursalDAO.RFC_REQUERIDO_DEFAULT ? 1 : 0);
                                                rfc.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(rfc.getCampo(), rfc);
                                            }
                                            String obligatorioVal = "";
                                            if (rfc.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"rfcObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"rfcHidden\" value=\"" + rfc.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"rfcCampo\" value=\"" + rfc.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"rfcId\" value=\"" + rfc.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="rfcLabel"><%
                                            if (rfc.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(rfc.getEtiqueta());
                                            %>:</label>&nbsp;**<br/>
                                        <input maxlength="30" type="text" id="rfc_sucursal" name="rfc_sucursal" style="width:300px"
                                               readonly disabled value="<%=empresasDto != null ? empresaBO.getEmpresa().getRfc() : ""%>"/>                                        
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal razonSocial2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.RAZON_SOCIAL);
                                            if (razonSocial2 == null) {
                                                razonSocial2 = new EtiquetaFormularioSucursal();
                                                razonSocial2.setCampo(EtiquetaFormularioSucursalDAO.RAZON_SOCIAL);
                                                razonSocial2.setEtiqueta(EtiquetaFormularioSucursalDAO.RAZON_SOCIAL_DEFAULT);
                                                razonSocial2.setObligatorio(EtiquetaFormularioSucursalDAO.RAZON_SOCIAL_REQUERIDO_DEFAULT ? 1 : 0);
                                                razonSocial2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(razonSocial2.getCampo(), razonSocial2);
                                            }
                                            obligatorioVal = "";
                                            if (razonSocial2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"razonSocialObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"razonSocialHidden\" value=\"" + razonSocial2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"razonSocialCampo\" value=\"" + razonSocial2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"razonSocialId\" value=\"" + razonSocial2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="razonSocialLabel"><%
                                            if (razonSocial2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(razonSocial2.getEtiqueta());
                                            %>:</label>&nbsp;**<br/>
                                        <input maxlength="30" type="text" id="razonsocial_sucursal" name="razonsocial_sucursal" style="width:300px"
                                               readonly disabled value="<%=empresasDto != null ? empresaBO.getEmpresa().getRazonSocial() : ""%>"/>                                       
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal regimenFiscal = camposSucursal.get(EtiquetaFormularioSucursalDAO.REGIMEN_FISCAL);
                                            if (regimenFiscal == null) {
                                                regimenFiscal = new EtiquetaFormularioSucursal();
                                                regimenFiscal.setCampo(EtiquetaFormularioSucursalDAO.REGIMEN_FISCAL);
                                                regimenFiscal.setEtiqueta(EtiquetaFormularioSucursalDAO.REGIMEN_FISCAL_DEFAULT);
                                                regimenFiscal.setObligatorio(EtiquetaFormularioSucursalDAO.REGIMEN_FISCAL_REQUERIDO_DEFAULT ? 1 : 0);
                                                regimenFiscal.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(regimenFiscal.getCampo(), regimenFiscal);
                                            }
                                            obligatorioVal = "";
                                            if (regimenFiscal.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"regimenFiscalObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"regimenFiscalHidden\" value=\"" + regimenFiscal.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"regimenFiscalCampo\" value=\"" + regimenFiscal.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"regimenFiscalId\" value=\"" + regimenFiscal.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="regimenFiscalLabel"><%
                                            if (regimenFiscal.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(regimenFiscal.getEtiqueta());
                                            %>:</label>&nbsp;**<br/>
                                        <input maxlength="30" type="text" id="regimen_sucursal" name="regimen_sucursal" style="width:300px"
                                               readonly disabled value="<%=empresasDto != null ? empresaBO.getEmpresa().getRegimenFiscal() : ""%>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal nombreComercial2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.NOMBRE_COMERCIAL);
                                            if (nombreComercial2 == null) {
                                                nombreComercial2 = new EtiquetaFormularioSucursal();
                                                nombreComercial2.setCampo(EtiquetaFormularioSucursalDAO.NOMBRE_COMERCIAL);
                                                nombreComercial2.setEtiqueta(EtiquetaFormularioSucursalDAO.NOMBRE_COMERCIAL_DEFAULT);
                                                nombreComercial2.setObligatorio(EtiquetaFormularioSucursalDAO.NOMBRE_COMERCIAL_REQUERIDO_DEFAULT ? 1 : 0);
                                                nombreComercial2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(nombreComercial2.getCampo(), nombreComercial2);
                                            }
                                            obligatorioVal = "";
                                            if (nombreComercial2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"nombreComercialObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"nombreComercialHidden\" value=\"" + nombreComercial2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"nombreComercialCampo\" value=\"" + nombreComercial2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"nombreComercialId\" value=\"" + nombreComercial2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="nombreComercialLabel"><%
                                            if (nombreComercial2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(nombreComercial2.getEtiqueta());
                                            %>:</label><br/>
                                        <input maxlength="30" type="text" id="nombreSucursal" name="nombreSucursal" style="width:300px"
                                               value="<%=empresasDto != null && !mode.equals("") ? empresaBO.getEmpresa().getNombreComercial() : ""%>"/>                                        
                                    </p>
                                    <br/>  
                                    <br/>                                    
                                    <p>
                                        <label>Estatus:</label>
                                        <input type="checkbox" class="checkbox" <%=empresasDto != null ? (empresasDto.getIdEstatus() == 1 ? "checked" : "") : "checked"%>
                                               id="estatus" name="estatus" value="1"> <%
                                                   EtiquetaFormularioSucursal activo3 = camposSucursal.get(EtiquetaFormularioSucursalDAO.ACTIVO);
                                                   if (activo3 == null) {
                                                       activo3 = new EtiquetaFormularioSucursal();
                                                       activo3.setCampo(EtiquetaFormularioSucursalDAO.ACTIVO);
                                                       activo3.setEtiqueta(EtiquetaFormularioSucursalDAO.ACTIVO_DEFAULT);
                                                       activo3.setObligatorio(EtiquetaFormularioSucursalDAO.ACTIVO_REQUERIDO_DEFAULT ? 1 : 0);
                                                       activo3.setIdUsuario(user.getUser().getIdUsuarios());
                                                       camposSucursal.put(activo3.getCampo(), activo3);
                                                   }
                                                   obligatorioVal = "";
                                                   if (activo3.getObligatorio() == 1) {
                                                       obligatorioVal = "1";
                                                   } else {
                                                       obligatorioVal = "0";
                                                   }
                                                   out.print("<input type=\"hidden\" id=\"activoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                   out.print("<input type=\"hidden\" id=\"activoHidden\" value=\"" + activo3.getEtiqueta() + "\"/>");
                                                   out.print("<input type=\"hidden\" id=\"activoCampo\" value=\"" + activo3.getCampo() + "\"/>");
                                                   out.print("<input type=\"hidden\" id=\"activoId\" value=\"" + activo3.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="activoLabel"><%
                                            if (activo3.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(activo3.getEtiqueta());
                                            %>:</label>
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
                                        <%
                                            EtiquetaFormularioSucursal calle2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.CALLE);
                                            if (calle2 == null) {
                                                calle2 = new EtiquetaFormularioSucursal();
                                                calle2.setCampo(EtiquetaFormularioSucursalDAO.CALLE);
                                                calle2.setEtiqueta(EtiquetaFormularioSucursalDAO.CALLE_DEFAULT);
                                                calle2.setObligatorio(EtiquetaFormularioSucursalDAO.CALLE_REQUERIDO_DEFAULT ? 1 : 0);
                                                calle2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(calle2.getCampo(), calle2);
                                            }
                                            obligatorioVal = "";
                                            if (calle2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"calleObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"calleHidden\" value=\"" + calle2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"calleCampo\" value=\"" + calle2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"calleId\" value=\"" + calle2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="calleLabel"><%
                                            if (calle2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(calle2.getEtiqueta());
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="calle" name="calle" style="width:300px"
                                               value="<%=ubicacionesDto != null && !mode.equals("") ? ubicacionesDto.getCalle() : ""%>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal numeroExterior2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.NUMERO_EXTERIOR);
                                            if (numeroExterior2 == null) {
                                                numeroExterior2 = new EtiquetaFormularioSucursal();
                                                numeroExterior2.setCampo(EtiquetaFormularioSucursalDAO.NUMERO_EXTERIOR);
                                                numeroExterior2.setEtiqueta(EtiquetaFormularioSucursalDAO.NUMERO_EXTERIOR_DEFAULT);
                                                numeroExterior2.setObligatorio(EtiquetaFormularioSucursalDAO.NUMERO_EXTERIOR_REQUERIDO_DEFAULT ? 1 : 0);
                                                numeroExterior2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(numeroExterior2.getCampo(), numeroExterior2);
                                            }
                                            obligatorioVal = "";
                                            if (numeroExterior2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"numeroExteriorObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"numeroExteriorHidden\" value=\"" + numeroExterior2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"numeroExteriorCampo\" value=\"" + numeroExterior2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"numeroExteriorId\" value=\"" + numeroExterior2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="numeroExteriorLabel"><%
                                            if (numeroExterior2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(numeroExterior2.getEtiqueta());
                                            %>:</label><br/>
                                        <input maxlength="30" type="text" id="ext" name="ext" style="width:300px"
                                               value="<%=ubicacionesDto != null && !mode.equals("") ? ubicacionesDto.getNumExt() : ""%>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal numeroInterior2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.NUMERO_INTERIOR);
                                            if (numeroInterior2 == null) {
                                                numeroInterior2 = new EtiquetaFormularioSucursal();
                                                numeroInterior2.setCampo(EtiquetaFormularioSucursalDAO.NUMERO_INTERIOR);
                                                numeroInterior2.setEtiqueta(EtiquetaFormularioSucursalDAO.NUMERO_INTERIOR_DEFAULT);
                                                numeroInterior2.setObligatorio(EtiquetaFormularioSucursalDAO.NUMERO_INTERIOR_REQUERIDO_DEFAULT ? 1 : 0);
                                                numeroInterior2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(numeroInterior2.getCampo(), numeroInterior2);
                                            }
                                            obligatorioVal = "";
                                            if (numeroInterior2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"numeroInteriorObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"numeroInteriorHidden\" value=\"" + numeroInterior2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"numeroInteriorCampo\" value=\"" + numeroInterior2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"numeroInteriorId\" value=\"" + numeroInterior2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="numeroInteriorLabel"><%
                                            if (numeroInterior2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(numeroInterior2.getEtiqueta());
                                            %>:</label><br/>
                                        <input maxlength="30" type="text" id="int" name="int" style="width:300px"
                                               value="<%=ubicacionesDto != null && !mode.equals("") ? ubicacionesDto.getNumInt() : ""%>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal colonia2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.COLONIA);
                                            if (colonia2 == null) {
                                                colonia2 = new EtiquetaFormularioSucursal();
                                                colonia2.setCampo(EtiquetaFormularioSucursalDAO.COLONIA);
                                                colonia2.setEtiqueta(EtiquetaFormularioSucursalDAO.COLONIA_DEFAULT);
                                                colonia2.setObligatorio(EtiquetaFormularioSucursalDAO.COLONIA_REQUERIDO_DEFAULT ? 1 : 0);
                                                colonia2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(colonia2.getCampo(), colonia2);
                                            }
                                            obligatorioVal = "";
                                            if (colonia2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"coloniaObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"coloniaHidden\" value=\"" + colonia2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"coloniaCampo\" value=\"" + colonia2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"coloniaId\" value=\"" + colonia2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="coloniaLabel"><%
                                            if (colonia2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(colonia2.getEtiqueta());
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="colonia" name="colonia" style="width:300px"
                                               value="<%=ubicacionesDto != null && !mode.equals("") ? ubicacionesDto.getColonia() : ""%>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal codigoPostal2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.CODIGO_POSTAL);
                                            if (codigoPostal2 == null) {
                                                codigoPostal2 = new EtiquetaFormularioSucursal();
                                                codigoPostal2.setCampo(EtiquetaFormularioSucursalDAO.CODIGO_POSTAL);
                                                codigoPostal2.setEtiqueta(EtiquetaFormularioSucursalDAO.CODIGO_POSTAL_DEFAULT);
                                                codigoPostal2.setObligatorio(EtiquetaFormularioSucursalDAO.CODIGO_POSTAL_REQUERIDO_DEFAULT ? 1 : 0);
                                                codigoPostal2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(codigoPostal2.getCampo(), codigoPostal2);
                                            }
                                            obligatorioVal = "";
                                            if (codigoPostal2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"codigoPostalObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"codigoPostalHidden\" value=\"" + codigoPostal2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"codigoPostalCampo\" value=\"" + codigoPostal2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"codigoPostalId\" value=\"" + codigoPostal2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="codigoPostalLabel"><%
                                            if (codigoPostal2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(codigoPostal2.getEtiqueta());
                                            %>:</label><br/>
                                        <input maxlength="5" type="text" id="cp" name="cp" style="width:300px"
                                               value="<%=ubicacionesDto != null && !mode.equals("") ? ubicacionesDto.getCodigoPostal() : ""%>"
                                               onkeypress="return validateNumber(event);"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal municipio2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.MUNICIPIO);
                                            if (municipio2 == null) {
                                                municipio2 = new EtiquetaFormularioSucursal();
                                                municipio2.setCampo(EtiquetaFormularioSucursalDAO.MUNICIPIO);
                                                municipio2.setEtiqueta(EtiquetaFormularioSucursalDAO.MUNICIPIO_DEFAULT);
                                                municipio2.setObligatorio(EtiquetaFormularioSucursalDAO.MUNICIPIO_REQUERIDO_DEFAULT ? 1 : 0);
                                                municipio2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(municipio2.getCampo(), municipio2);
                                            }
                                            obligatorioVal = "";
                                            if (municipio2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"municipioObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"municipioHidden\" value=\"" + municipio2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"municipioCampo\" value=\"" + municipio2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"municipioId\" value=\"" + municipio2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="municipioLabel"><%
                                            if (municipio2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(municipio2.getEtiqueta());
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="delMuni" name="delMuni" style="width:300px"
                                               value="<%=ubicacionesDto != null && !mode.equals("") ? ubicacionesDto.getMunicipio() : ""%>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal estado2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.ESTADO);
                                            if (estado2 == null) {
                                                estado2 = new EtiquetaFormularioSucursal();
                                                estado2.setCampo(EtiquetaFormularioSucursalDAO.ESTADO);
                                                estado2.setEtiqueta(EtiquetaFormularioSucursalDAO.ESTADO_DEFAULT);
                                                estado2.setObligatorio(EtiquetaFormularioSucursalDAO.ESTADO_REQUERIDO_DEFAULT ? 1 : 0);
                                                estado2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(estado2.getCampo(), estado2);
                                            }
                                            obligatorioVal = "";
                                            if (estado2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"estadoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"estadoHidden\" value=\"" + estado2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"estadoCampo\" value=\"" + estado2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"estadoId\" value=\"" + estado2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="estadoLabel"><%
                                            if (estado2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(estado2.getEtiqueta());
                                            %>:</label><br/>
                                        <input maxlength="50" type="text" id="estado" name="estado" style="width:300px"
                                               value="<%=ubicacionesDto != null && !mode.equals("") ? ubicacionesDto.getEstado() : ""%>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <%
                                            EtiquetaFormularioSucursal pais2 = camposSucursal.get(EtiquetaFormularioSucursalDAO.PAIS);
                                            if (pais2 == null) {
                                                pais2 = new EtiquetaFormularioSucursal();
                                                pais2.setCampo(EtiquetaFormularioSucursalDAO.PAIS);
                                                pais2.setEtiqueta(EtiquetaFormularioSucursalDAO.PAIS_DEFAULT);
                                                pais2.setObligatorio(EtiquetaFormularioSucursalDAO.PAIS_REQUERIDO_DEFAULT ? 1 : 0);
                                                pais2.setIdUsuario(user.getUser().getIdUsuarios());
                                                camposSucursal.put(pais2.getCampo(), pais2);
                                            }
                                            obligatorioVal = "";
                                            if (pais2.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"paisObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"paisHidden\" value=\"" + pais2.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"paisCampo\" value=\"" + pais2.getCampo() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"paisId\" value=\"" + pais2.getIdEtiquetaFormularioSucursal() + "\"/>");
                                        %>
                                        <label id="paisLabel"><%
                                            if (pais2.getObligatorio() == 1) {
                                                out.print("*");
                                            }
                                            out.print(pais2.getEtiqueta());
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="pais" name="pais" style="width:300px"
                                               value="<%=ubicacionesDto != null && !mode.equals("") ? ubicacionesDto.getPais() : "México"%>"/>
                                    </p>
                                </div>
                            </div>
                            <!--Fin Columna derecha-->
                            <div class="column_left">
                                <div class="header">
                                    <span>
                                        Campos Adicionales
                                    </span>
                                    <div class="switch" style="width:150px">
                                        <table width="100px" cellpadding="0" cellspacing="0">
                                            <tbody>
                                                <tr>
                                                    <td>

                                                    </td>
                                                    <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <div class="content" id="areaCamposAdicionalesSucursal">
                                    <%
                                        CampoAdicionalSucursalDAO casdao = new CampoAdicionalSucursalDAO();
                                        CampoAdicionalSucursalValorDAO casvdao = new CampoAdicionalSucursalValorDAO();
                                        List<CampoAdicionalSucursal> campos3 = casdao.lista(user.getUser().getIdUsuarios());
                                        for (CampoAdicionalSucursal campoAdicional : campos3) {
                                            CampoAdicionalSucursalValor casv = null;
                                            if (empresasDto != null) {
                                                casv = casvdao.getByIdAndSucursal(campoAdicional.getIdCampoAdicionalSucursal(), empresasDto.getIdEmpresa());
                                            }
                                            obligatorioVal = "";
                                            if (campoAdicional.getObligatorio() == 1) {
                                                obligatorioVal = "1";
                                            } else {
                                                obligatorioVal = "0";
                                            }
                                            out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "ObligatorioAdicional\" value=\"" + obligatorioVal + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "HiddenAdicional\" value=\"" + campoAdicional.getEtiqueta() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "IdAdicional\" value=\"" + campoAdicional.getIdCampoAdicionalSucursal() + "\"/>");
                                            out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "TipoAdicional\" value=\"" + campoAdicional.getTipoDato() + "\"/>");
                                    %>
                                    <label id="<%=campoAdicional.getEtiqueta()%>Label"><%
                                        if (campoAdicional.getObligatorio() == 1) {
                                            out.print("*");
                                        }
                                        out.print(campoAdicional.getEtiqueta());
                                        %>:</label> 
                                    <br/>
                                    <input maxlength="100" type="text" id="<%=campoAdicional.getEtiqueta().replace(" ", "")%>IdValor" name="<%=campoAdicional.getEtiqueta().replace(" ", "")%>" style="width:300px;"
                                           value="<%=casv != null ? casv.getValor() : ""%>"/><br/>
                                    <%
                                        }
                                    %>
                                </div>

                            </div>

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