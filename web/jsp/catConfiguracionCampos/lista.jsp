<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalSucursal"%>
<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalProspecto"%>
<%@page import="com.tsp.gespro.hibernate.pojo.EtiquetaFormularioSucursal"%>
<%@page import="com.tsp.gespro.hibernate.pojo.EtiquetaFormularioProspecto"%>
<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalCliente"%>
<%@page import="com.tsp.gespro.hibernate.pojo.EtiquetaFormularioCliente"%>
<%@page import="java.util.HashMap"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.tsp.gespro.hibernate.dao.*"%>
<%@page import="java.util.List"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<jsp:useBean id="helperEtiquetaCliente" class="com.tsp.gespro.hibernate.dao.EtiquetaFormularioClienteDAO"/>
<jsp:useBean id="helperEtiquetaProspecto" class="com.tsp.gespro.hibernate.dao.EtiquetaFormularioProspectoDAO"/>
<jsp:useBean id="helperEtiquetaSucursal" class="com.tsp.gespro.hibernate.dao.EtiquetaFormularioSucursalDAO"/>
<%
//Verifica si el usuario tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {
        HashMap<String, EtiquetaFormularioCliente> camposCliente = helperEtiquetaCliente.getMap(user.getUser().getIdUsuarios());
        HashMap<String, EtiquetaFormularioProspecto> camposProspecto = helperEtiquetaProspecto.getMap(user.getUser().getIdUsuarios());
        HashMap<String, EtiquetaFormularioSucursal> camposSucursal = helperEtiquetaSucursal.getMap(user.getUser().getIdUsuarios());

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />
        <title><jsp:include page="../include/titleApp.jsp" /></title>        
        <jsp:include page="../include/skinCSS.jsp" />
        <jsp:include page="../include/jsFunctions.jsp"/>
        <style>
            /* The Modal (background) */
            .modal {
                display: none; /* Hidden by default */
                position: fixed; /* Stay in place */
                z-index: 1; /* Sit on top */
                left: 0;
                top: 0;
                width: 100%; /* Full width */
                height: 100%; /* Full height */
                overflow: auto; /* Enable scroll if needed */
                background-color: rgb(0,0,0); /* Fallback color */
                background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
            }

            /* Modal Content/Box */
            .modal-content {
                background-color: #fefefe;
                margin: 15% auto; /* 15% from the top and centered */
                padding: 20px;
                border: 1px solid #888;
                width: 300px; /* Could be more or less, depending on screen size */
                height: 200px;
                padding-left: 40px; 
            }

            /* The Close Button */
            .close {
                color: #aaa;
                float: right;
                font-size: 18px;
                font-weight: bold;
            }
            .close:hover,
            .close:focus {
                color: black;
                text-decoration: none;
                cursor: pointer;
            }
            /*----------tap panel style------*/
            .tab-panel {
                width: 100%;
                display: inline-block;
            }

            .tab-link:after {
                display: block;
                padding-top: 20px;
                content: '';
            }

            .tab-link li {
                margin: 0px 0px;
                float: left;
                list-style: none;
            }

            .tab-link a {
                padding: 8px 15px;
                display: inline-block;
                border-radius: 10px 3px 0px 0px;
                background: #8dc8f5;
                font-weight: bold;
                color: #4c4c4c;
            }

            .tab-link a:hover {
                background: #b7c7e5;
                text-decoration: none;
            }

            li.active a, li.active a:hover {
                background: #ccc;
                color: #0094ff;
                text-decoration:none;
            }

            .content-area {
                padding: 15px;
                border-radius: 3px;            
            }

            .inactive{
                display: none;
            }

            .active {
                display: block;
            }
        </style>

        <script>
            function openModalProspecto(campo) {
                $("#etiquetaModalProspecto #modalCampoProspecto").val(campo);
                $("#etiquetaModalProspecto #etiquetaProspecto").val($(".etiquetasProspecto #" + campo + "Hidden").val());
                var obligatorio = $(".etiquetasProspecto #" + campo + "Obligatorio").val();
                $("#etiquetaModalProspecto #obligatorioProspecto").prop("checked", obligatorio == 1 ? true : false);
                if (campo == "activo") {
                    $("#etiquetaModalProspecto #obligatorioProspecto").prop("disabled", true);
                } else {
                    $("#etiquetaModalProspecto #obligatorioProspecto").prop("disabled", false);
                }
                $("#etiquetaModalProspecto").css('display', 'block');
            }
            function openModalCliente(campo) {
                $("#etiquetaModalCliente #modalCampoCliente").val(campo);
                $("#etiquetaModalCliente #etiquetaCliente").val($(".etiquetasCliente #" + campo + "Hidden").val());
                var obligatorio = $(".etiquetasCliente #" + campo + "Obligatorio").val();
                $("#etiquetaModalCliente #obligatorioCliente").prop("checked", obligatorio == 1 ? true : false);
                if (campo == "activo") {
                    $("#etiquetaModalCliente #obligatorioCliente").prop("disabled", true);
                } else {
                    $("#etiquetaModalCliente #obligatorioCliente").prop("disabled", false);
                }
                $("#etiquetaModalCliente").css('display', 'block');
            }
            function openModalSucursal(campo) {
                $("#etiquetaModalSucursal #modalCampoSucursal").val(campo);
                $("#etiquetaModalSucursal #etiquetaSucursal").val($(".etiquetasSucursal #" + campo + "Hidden").val());
                var obligatorio = $(".etiquetasSucursal #" + campo + "Obligatorio").val();
                $("#etiquetaModalSucursal #obligatorioSucursal").prop("checked", obligatorio == 1 ? true : false);
                if (campo == "activo") {
                    $("#etiquetaModalSucursal #obligatorioSucursal").prop("disabled", true);
                } else {
                    $("#etiquetaModalSucursal #obligatorioSucursal").prop("disabled", false);
                }
                $("#etiquetaModalSucursal").css('display', 'block');
            }
            
            function editarCampoAdicionalCliente(campo) {
                var etiqueta = $('#areaCamposAdicionalesCliente #' + campo + 'HiddenAdicional').val();
                var tipo = $("#areaCamposAdicionalesCliente #" + etiqueta + "TipoAdicional").val()
                var obligatorio = $("#areaCamposAdicionalesCliente #" + etiqueta + "ObligatorioAdicional").val();
                var idAdicional = $("#areaCamposAdicionalesCliente #" + etiqueta + "IdAdicional").val();
                $("#campoAdicionalModalCliente #etiquetaAnteriorModal").val(etiqueta);
                $("#campoAdicionalModalCliente #etiquetaCampoAdicional").val(etiqueta);
                $("#campoAdicionalModalCliente #obligatorioCampoAdicional").prop("checked", obligatorio == 1 ? true : false);
                $("#campoAdicionalModalCliente #tipoDatoAdicional").val(tipo);
                $("#campoAdicionalModalCliente #idCampoAdicionalModal").val(idAdicional);
                $("#campoAdicionalModalCliente").css('display', 'block');

            }
            function editarCampoAdicionalProspecto(campo) {
                var etiqueta = $('#areaCamposAdicionalesProspecto #' + campo + 'HiddenAdicional').val();
                var tipo = $("#areaCamposAdicionalesProspecto #" + etiqueta + "TipoAdicional").val()
                var obligatorio = $("#areaCamposAdicionalesProspecto #" + etiqueta + "ObligatorioAdicional").val();
                var idAdicional = $("#areaCamposAdicionalesProspecto #" + etiqueta + "IdAdicional").val();
                $("#campoAdicionalModalProspecto #etiquetaAnteriorModal").val(etiqueta);
                $("#campoAdicionalModalProspecto #etiquetaCampoAdicional").val(etiqueta);
                $("#campoAdicionalModalProspecto #obligatorioCampoAdicional").prop("checked", obligatorio == 1 ? true : false);
                $("#campoAdicionalModalProspecto #tipoDatoAdicional").val(tipo);
                $("#campoAdicionalModalProspecto #idCampoAdicionalModal").val(idAdicional);
                $("#campoAdicionalModalProspecto").css('display', 'block');

            }
            function editarCampoAdicionalSucursal(campo) {
                var etiqueta = $('#areaCamposAdicionalesSucursal #' + campo + 'HiddenAdicional').val();
                var tipo = $("#areaCamposAdicionalesSucursal #" + etiqueta + "TipoAdicional").val()
                var obligatorio = $("#areaCamposAdicionalesSucursal #" + etiqueta + "ObligatorioAdicional").val();
                var idAdicional = $("#areaCamposAdicionalesSucursal #" + etiqueta + "IdAdicional").val();
                $("#campoAdicionalModalSucursal #etiquetaAnteriorModal").val(etiqueta);
                $("#campoAdicionalModalSucursal #etiquetaCampoAdicional").val(etiqueta);
                $("#campoAdicionalModalSucursal #obligatorioCampoAdicional").prop("checked", obligatorio == 1 ? true : false);
                $("#campoAdicionalModalSucursal #tipoDatoAdicional").val(tipo);
                $("#campoAdicionalModalSucursal #idCampoAdicionalModal").val(idAdicional);
                $("#campoAdicionalModalSucursal").css('display', 'block');

            }
            
            function guardarCampoAdicionalCliente() {
                var idAdicional = $("#campoAdicionalModalCliente #idCampoAdicionalModal").val();
                var contenido = "";
                var etiqueta = $("#campoAdicionalModalCliente #etiquetaCampoAdicional").val();
                var etiquetaAnterior = $("#campoAdicionalModalCliente #etiquetaAnteriorModal").val();
                var obligatorio = $("#campoAdicionalModalCliente #obligatorioCampoAdicional").prop("checked");
                var tipoDato = $("#campoAdicionalModalCliente #tipoDatoAdicional").val();
                var obligatorioVal = obligatorio ? 1 : 0;
                if (idAdicional > 0) {                    
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "ObligatorioAdicional").val(obligatorioVal);
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "HiddenAdicional").val(etiqueta);
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "TipoAdicional").val(tipoDato);
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "Label").text((obligatorio ? "*" : "") + etiqueta);
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "ObligatorioAdicional").attr("id", etiqueta.replace(" ", "") + "ObligatorioAdicional");
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "HiddenAdicional").attr("id", etiqueta.replace(" ", "") + "HiddenAdicional");
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "TipoAdicional").attr("id", etiqueta.replace(" ", "") + "TipoAdicional");
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "Label").attr("id", etiqueta.replace(" ", "") + "Label");
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "IdAdicional").attr("id", etiqueta.replace(" ", "") + "IdAdicional");                    
                    var js = "editarCampoAdicionalCliente(\"" + etiqueta + "\")";                    
                    var newclick = new Function(js);                    
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "linkEditarCliente").attr('onclick', '').click(newclick);
                    $("#areaCamposAdicionalesCliente #" + etiquetaAnterior.replace(" ", "") + "linkEditarCliente").attr("id", etiqueta.replace(" ", "") + "linkEditarCliente");


                } else {
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "ObligatorioAdicional\" value=\"" + obligatorioVal + "\"/>";
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "HiddenAdicional\" value=\"" + etiqueta + "\"/>";
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "IdAdicional\" value=\"" + 0 + "\"/>";
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "TipoAdicional\" value=\"" + tipoDato + "\"/>";
                    contenido += "<label id = \"" + etiqueta.replace(" ", "") + "Label\">";
                    if (obligatorio) {
                        contenido += "*";
                    }
                    contenido += etiqueta;
                    contenido += " : </label> <img id=\"" + etiqueta + "linkEditarCliente\" src='../../images/icon_edit.png' alt='icon' onclick='editarCampoAdicionalCliente(\"" + etiqueta + "\")' onmouseover='' style='cursor: pointer; ' /><br/>";
                    $("#areaCamposAdicionalesCliente").append(contenido);
                }
                $("#campoAdicionalModalCliente").css('display', 'none');

            }
            function guardarCampoAdicionalProspecto() {
                var idAdicional = $("#campoAdicionalModalProspecto #idCampoAdicionalModal").val();
                var contenido = "";
                var etiqueta = $("#campoAdicionalModalProspecto #etiquetaCampoAdicional").val();
                var etiquetaAnterior = $("#campoAdicionalModalProspecto #etiquetaAnteriorModal").val();
                var obligatorio = $("#campoAdicionalModalProspecto #obligatorioCampoAdicional").prop("checked");
                var tipoDato = $("#campoAdicionalModalProspecto #tipoDatoAdicional").val();
                var obligatorioVal = obligatorio ? 1 : 0;
                if (idAdicional > 0) {                    
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "ObligatorioAdicional").val(obligatorioVal);
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "HiddenAdicional").val(etiqueta);
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "TipoAdicional").val(tipoDato);
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "Label").text((obligatorio ? "*" : "") + etiqueta);
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "ObligatorioAdicional").attr("id", etiqueta.replace(" ", "") + "ObligatorioAdicional");
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "HiddenAdicional").attr("id", etiqueta.replace(" ", "") + "HiddenAdicional");
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "TipoAdicional").attr("id", etiqueta.replace(" ", "") + "TipoAdicional");
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "Label").attr("id", etiqueta.replace(" ", "") + "Label");
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "IdAdicional").attr("id", etiqueta.replace(" ", "") + "IdAdicional");                    
                    var js = "editarCampoAdicionalProspecto(\"" + etiqueta + "\")";                    
                    var newclick = new Function(js);                    
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "linkEditarProspecto").attr('onclick', '').click(newclick);
                    $("#areaCamposAdicionalesProspecto #" + etiquetaAnterior.replace(" ", "") + "linkEditarProspecto").attr("id", etiqueta.replace(" ", "") + "linkEditarProspecto");


                } else {
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "ObligatorioAdicional\" value=\"" + obligatorioVal + "\"/>";
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "HiddenAdicional\" value=\"" + etiqueta + "\"/>";
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "IdAdicional\" value=\"" + 0 + "\"/>";
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "TipoAdicional\" value=\"" + tipoDato + "\"/>";
                    contenido += "<label id = \"" + etiqueta.replace(" ", "") + "Label\">";
                    if (obligatorio) {
                        contenido += "*";
                    }
                    contenido += etiqueta;
                    contenido += " : </label> <img id=\"" + etiqueta + "linkEditarProspecto\" src='../../images/icon_edit.png' alt='icon' onclick='editarCampoAdicionalProspecto(\"" + etiqueta + "\")' onmouseover='' style='cursor: pointer; ' /><br/>";
                    $("#areaCamposAdicionalesProspecto").append(contenido);
                }
                $("#campoAdicionalModalProspecto").css('display', 'none');

            }
            function guardarCampoAdicionalSucursal() {
                var idAdicional = $("#campoAdicionalModalSucursal #idCampoAdicionalModal").val();
                var contenido = "";
                var etiqueta = $("#campoAdicionalModalSucursal #etiquetaCampoAdicional").val();
                var etiquetaAnterior = $("#campoAdicionalModalSucursal #etiquetaAnteriorModal").val();
                var obligatorio = $("#campoAdicionalModalSucursal #obligatorioCampoAdicional").prop("checked");
                var tipoDato = $("#campoAdicionalModalSucursal #tipoDatoAdicional").val();
                var obligatorioVal = obligatorio ? 1 : 0;
                if (idAdicional > 0) {                    
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "ObligatorioAdicional").val(obligatorioVal);
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "HiddenAdicional").val(etiqueta);
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "TipoAdicional").val(tipoDato);
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "Label").text((obligatorio ? "*" : "") + etiqueta);
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "ObligatorioAdicional").attr("id", etiqueta.replace(" ", "") + "ObligatorioAdicional");
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "HiddenAdicional").attr("id", etiqueta.replace(" ", "") + "HiddenAdicional");
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "TipoAdicional").attr("id", etiqueta.replace(" ", "") + "TipoAdicional");
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "Label").attr("id", etiqueta.replace(" ", "") + "Label");
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "IdAdicional").attr("id", etiqueta.replace(" ", "") + "IdAdicional");                    
                    var js = "editarCampoAdicionalSucursal(\"" + etiqueta + "\")";                    
                    var newclick = new Function(js);                    
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "linkEditarSucursal").attr('onclick', '').click(newclick);
                    $("#areaCamposAdicionalesSucursal #" + etiquetaAnterior.replace(" ", "") + "linkEditarSucursal").attr("id", etiqueta.replace(" ", "") + "linkEditarSucursal");


                } else {
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "ObligatorioAdicional\" value=\"" + obligatorioVal + "\"/>";
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "HiddenAdicional\" value=\"" + etiqueta + "\"/>";
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "IdAdicional\" value=\"" + 0 + "\"/>";
                    contenido += "<input type=\"hidden\" id=\"" + etiqueta.replace(" ", "") + "TipoAdicional\" value=\"" + tipoDato + "\"/>";
                    contenido += "<label id = \"" + etiqueta.replace(" ", "") + "Label\">";
                    if (obligatorio) {
                        contenido += "*";
                    }
                    contenido += etiqueta;
                    contenido += " : </label> <img id=\"" + etiqueta + "linkEditarSucursal\" src='../../images/icon_edit.png' alt='icon' onclick='editarCampoAdicionalSucursal(\"" + etiqueta + "\")' onmouseover='' style='cursor: pointer; ' /><br/>";
                    $("#areaCamposAdicionalesSucursal").append(contenido);
                }
                $("#campoAdicionalModalSucursal").css('display', 'none');

            }

            function nuevoCampoAdicionalCliente() {
                $("#campoAdicionalModalCliente #idCampoAdicionalModal").val(0);
                $("#campoAdicionalModalCliente #etiquetaCampoAdicional").val("");
                $("#campoAdicionalModalCliente #obligatorioCampoAdicional").prop("checked", false);
                $("#campoAdicionalModalCliente #tipoDatoAdicional").val(0);
                $("#campoAdicionalModalCliente #etiquetaAnteriorModal").val("");
                $("#campoAdicionalModalCliente").css('display', 'block');
            }
            function nuevoCampoAdicionalProspecto() {
                $("#campoAdicionalModalProspecto #idCampoAdicionalModal").val(0);
                $("#campoAdicionalModalProspecto #etiquetaCampoAdicional").val("");
                $("#campoAdicionalModalProspecto #obligatorioCampoAdicional").prop("checked", false);
                $("#campoAdicionalModalProspecto #tipoDatoAdicional").val(0);
                $("#campoAdicionalModalProspecto #etiquetaAnteriorModal").val("");
                $("#campoAdicionalModalProspecto").css('display', 'block');
            }
            function nuevoCampoAdicionalSucursal() {
                $("#campoAdicionalModalSucursal #idCampoAdicionalModal").val(0);
                $("#campoAdicionalModalSucursal #etiquetaCampoAdicional").val("");
                $("#campoAdicionalModalSucursal #obligatorioCampoAdicional").prop("checked", false);
                $("#campoAdicionalModalSucursal #tipoDatoAdicional").val(0);
                $("#campoAdicionalModalSucursal #etiquetaAnteriorModal").val("");
                $("#campoAdicionalModalSucursal").css('display', 'block');
            }
            
            function grabarProspecto() {
                var camposProspecto = [];
                var adicionalesProspecto = [];
                $('.etiquetasProspecto *[id*=Campo]:hidden').each(function () {

                    var campo = $(this).val();
                    if (campo != "") {
                        var etiqueta = $(".etiquetasProspecto #" + campo + "Hidden").val()
                        var obligatorio = $(".etiquetasProspecto #" + campo + "Obligatorio").val();
                        var idCampo = $(".etiquetasProspecto #" + campo + "Id").val();
                        var campoProspecto = {idCampo: idCampo, campo: campo, etiqueta: etiqueta, obligatorio: obligatorio};
                        camposProspecto.push(campoProspecto);
                    }
                });
                $('#areaCamposAdicionalesProspecto *[id*=HiddenAdicional]:hidden').each(function () {
                    var etiqueta = $(this).val();
                    if (etiqueta != "") {
                        var tipo = $("#areaCamposAdicionalesProspecto #" + etiqueta.replace(" ", "") + "TipoAdicional").val()
                        var obligatorio = $("#areaCamposAdicionalesProspecto #" + etiqueta.replace(" ", "") + "ObligatorioAdicional").val();
                        var idAdicional = $("#areaCamposAdicionalesProspecto #" + etiqueta.replace(" ", "") + "IdAdicional").val();
                        var adicionalProspecto = {idAdicional: idAdicional, etiqueta: etiqueta, obligatorio: obligatorio, tipo: tipo};
                        adicionalesProspecto.push(adicionalProspecto);
                    }
                });
                $.ajax({
                    type: "POST",
                    url: "ajaxProspecto.jsp",
                    data: JSON.stringify(camposProspecto),
                    beforeSend: function (objeto) {
                        $("#action_buttons").fadeOut("slow");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function (datos) {
                        if (datos.indexOf("--EXITO-->", 0) > 0) {
                            $.ajax({
                                type: "POST",
                                url: "ajaxAdicionalesProspecto.jsp",
                                data: JSON.stringify(adicionalesProspecto),
                                success: function (datos) {

                                }
                            });
                            $("#ajax_message").html("Los datos se guardaron correctamente.");
                            $("#ajax_loading").fadeOut("slow");
                            $("#ajax_message").fadeIn("slow");
                            apprise('<center><img src=../../images/info.png> <br/>Los datos se guardaron correctamente.</center>', {'animate': true},
                                    function (r) {
                                        javascript:window.location.href = "lista.jsp";
                                        parent.$.fancybox.close();
                                    });
                        } else {
                            $("#ajax_loading").fadeOut("slow");
                            $("#ajax_message").html("Ocurrió un error al intentar guardar los datos.");
                            $("#ajax_message").fadeIn("slow");
                            $("#action_buttons").fadeIn("slow");
                        }
                    }
                });
            }
            function grabarCliente() {
                var camposCliente = [];
                var adicionalesCliente = [];
                $('.etiquetasCliente *[id*=Campo]:hidden').each(function () {

                    var campo = $(this).val();
                    if (campo != "") {
                        var etiqueta = $(".etiquetasCliente #" + campo + "Hidden").val()
                        var obligatorio = $(".etiquetasCliente #" + campo + "Obligatorio").val();
                        var idCampo = $(".etiquetasCliente #" + campo + "Id").val();
                        var campoCliente = {idCampo: idCampo, campo: campo, etiqueta: etiqueta, obligatorio: obligatorio};
                        camposCliente.push(campoCliente);
                    }
                });
                $('#areaCamposAdicionalesCliente *[id*=HiddenAdicional]:hidden').each(function () {
                    var etiqueta = $(this).val();
                    if (etiqueta != "") {
                        var tipo = $("#areaCamposAdicionalesCliente #" + etiqueta.replace(" ", "") + "TipoAdicional").val()
                        var obligatorio = $("#areaCamposAdicionalesCliente #" + etiqueta.replace(" ", "") + "ObligatorioAdicional").val();
                        var idAdicional = $("#areaCamposAdicionalesCliente #" + etiqueta.replace(" ", "") + "IdAdicional").val();
                        var adicionalCliente = {idAdicional: idAdicional, etiqueta: etiqueta, obligatorio: obligatorio, tipo: tipo};
                        adicionalesCliente.push(adicionalCliente);
                    }
                });
                $.ajax({
                    type: "POST",
                    url: "ajax.jsp",
                    data: JSON.stringify(camposCliente),
                    beforeSend: function (objeto) {
                        $("#action_buttons").fadeOut("slow");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function (datos) {
                        if (datos.indexOf("--EXITO-->", 0) > 0) {
                            $.ajax({
                                type: "POST",
                                url: "ajaxAdicionalesCliente.jsp",
                                data: JSON.stringify(adicionalesCliente),
                                success: function (datos) {

                                }
                            });
                            $("#ajax_message").html("Los datos se guardaron correctamente.");
                            $("#ajax_loading").fadeOut("slow");
                            $("#ajax_message").fadeIn("slow");
                            apprise('<center><img src=../../images/info.png> <br/>Los datos se guardaron correctamente.</center>', {'animate': true},
                                    function (r) {
                                        javascript:window.location.href = "lista.jsp";
                                        parent.$.fancybox.close();
                                    });
                        } else {
                            $("#ajax_loading").fadeOut("slow");
                            $("#ajax_message").html("Ocurrió un error al intentar guardar los datos.");
                            $("#ajax_message").fadeIn("slow");
                            $("#action_buttons").fadeIn("slow");
                        }
                    }
                });
            }            
            function grabarSucursal() {
                var camposSucursal = [];
                var adicionalesSucursal = [];
                $('.etiquetasSucursal *[id*=Campo]:hidden').each(function () {

                    var campo = $(this).val();
                    if (campo != "") {
                        var etiqueta = $(".etiquetasSucursal #" + campo + "Hidden").val()
                        var obligatorio = $(".etiquetasSucursal #" + campo + "Obligatorio").val();
                        var idCampo = $(".etiquetasSucursal #" + campo + "Id").val();
                        var campoSucursal = {idCampo: idCampo, campo: campo, etiqueta: etiqueta, obligatorio: obligatorio};
                        camposSucursal.push(campoSucursal);
                    }
                });
                $('#areaCamposAdicionalesSucursal *[id*=HiddenAdicional]:hidden').each(function () {
                    var etiqueta = $(this).val();
                    if (etiqueta != "") {
                        var tipo = $("#areaCamposAdicionalesSucursal #" + etiqueta.replace(" ", "") + "TipoAdicional").val()
                        var obligatorio = $("#areaCamposAdicionalesSucursal #" + etiqueta.replace(" ", "") + "ObligatorioAdicional").val();
                        var idAdicional = $("#areaCamposAdicionalesSucursal #" + etiqueta.replace(" ", "") + "IdAdicional").val();
                        var adicionalSucursal = {idAdicional: idAdicional, etiqueta: etiqueta, obligatorio: obligatorio, tipo: tipo};
                        adicionalesSucursal.push(adicionalSucursal);
                    }
                });
                $.ajax({
                    type: "POST",
                    url: "ajaxSucursal.jsp",
                    data: JSON.stringify(camposSucursal),
                    beforeSend: function (objeto) {
                        $("#action_buttons").fadeOut("slow");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function (datos) {
                        if (datos.indexOf("--EXITO-->", 0) > 0) {
                            $.ajax({
                                type: "POST",
                                url: "ajaxAdicionalesSucursal.jsp",
                                data: JSON.stringify(adicionalesSucursal),
                                success: function (datos) {

                                }
                            });
                            $("#ajax_message").html("Los datos se guardaron correctamente.");
                            $("#ajax_loading").fadeOut("slow");
                            $("#ajax_message").fadeIn("slow");
                            apprise('<center><img src=../../images/info.png> <br/>Los datos se guardaron correctamente.</center>', {'animate': true},
                                    function (r) {
                                        javascript:window.location.href = "lista.jsp";
                                        parent.$.fancybox.close();
                                    });
                        } else {
                            $("#ajax_loading").fadeOut("slow");
                            $("#ajax_message").html("Ocurrió un error al intentar guardar los datos.");
                            $("#ajax_message").fadeIn("slow");
                            $("#action_buttons").fadeIn("slow");
                        }
                    }
                });
            }
            
            
            function guardarEtiquetaCliente() {
                var campo = $("#etiquetaModalCliente #modalCampoCliente").val();
                $(".etiquetasCliente #" + campo + "Hidden").val($("#etiquetaModalCliente #etiquetaCliente").val());
                var obligatorio = $("#etiquetaModalCliente #obligatorioCliente").prop("checked");
                $(".etiquetasCliente #" + campo + "Obligatorio").val(obligatorio ? 1 : 0);
                var campoEtiqueta = obligatorio ? "*" : ""
                campoEtiqueta += $(".etiquetasCliente #" + campo + "Hidden").val();
                $(".etiquetasCliente #" + campo + "Label").text(campoEtiqueta);
                $("#etiquetaModalCliente").css('display', 'none');
            }
            function guardarEtiquetaProspecto() {
                var campo = $("#etiquetaModalProspecto #modalCampoProspecto").val();
                $(".etiquetasProspecto #" + campo + "Hidden").val($("#etiquetaModalProspecto #etiquetaProspecto").val());
                var obligatorio = $("#etiquetaModalProspecto #obligatorioProspecto").prop("checked");
                $(".etiquetasProspecto #" + campo + "Obligatorio").val(obligatorio ? 1 : 0);
                var campoEtiqueta = obligatorio ? "*" : ""
                campoEtiqueta += $(".etiquetasProspecto #" + campo + "Hidden").val();
                $(".etiquetasProspecto #" + campo + "Label").text(campoEtiqueta);
                $("#etiquetaModalProspecto").css('display', 'none');
            }
            function guardarEtiquetaSucursal() {
                var campo = $("#etiquetaModalSucursal #modalCampoSucursal").val();
                $(".etiquetasSucursal #" + campo + "Hidden").val($("#etiquetaModalSucursal #etiquetaSucursal").val());
                var obligatorio = $("#etiquetaModalSucursal #obligatorioSucursal").prop("checked");
                $(".etiquetasSucursal #" + campo + "Obligatorio").val(obligatorio ? 1 : 0);
                var campoEtiqueta = obligatorio ? "*" : ""
                campoEtiqueta += $(".etiquetasSucursal #" + campo + "Hidden").val();
                $(".etiquetasSucursal #" + campo + "Label").text(campoEtiqueta);
                $("#etiquetaModalSucursal").css('display', 'none');
            }
            $(document).ready(function () {
                $(".close").on("click", function (e) {
                    $("#etiquetaModalCliente").css('display', 'none');
                    $("#campoAdicionalModalCliente").css('display', 'none');
                    $("#etiquetaModalProspecto").css('display', 'none');
                    $("#campoAdicionalModalProspecto").css('display', 'none');
                    $("#etiquetaModalSucursal").css('display', 'none');
                    $("#campoAdicionalModalSucursal").css('display', 'none');
                })
                $('.tab-panel .tab-link a').on('click', function (e) {
                    var currentAttrValue = jQuery(this).attr('href');

                    // Show/Hide Tabs
                    //Fade effect
                    //   $('.tab-panel ' + currentAttrValue).fadeIn(1000).siblings().hide();
                    //Sliding effect
                    $('.tab-panel ' + currentAttrValue).slideDown(400).siblings().slideUp(400);

                    //Sliding up-down effect
                    // $('.tab-panel ' + currentAttrValue).siblings().slideUp(400);
                    // $('.tab-panel ' + currentAttrValue).delay(400).slideDown(400);

                    // Change/remove current tab to active
                    $(this).parent('li').addClass('active').siblings().removeClass('active');

                    e.preventDefault();
                });
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

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_users.png" alt="icon"/>
                                Configuración de campos
                            </span>
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
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
                        <br class="clear"/>

                        <div>
                            <form id="form_data" name="form_data" action="" method="post">

                                <div class="tab-panel">
                                    <ul class="tab-link">
                                        <li class="active"><a href="#FirstTab">Clientes</a></li>
                                        <li><a href="#SecondTab">Prospectos</a></li>
                                        <li><a href="#ThirdTab">Sucursales</a></li>
                                    </ul>

                                    <div class="content-area">
                                        <div id="FirstTab" class="active">
                                            <div class="twocolumn">
                                                <div class="column_left etiquetasCliente">
                                                    <div class="header">
                                                        <span>
                                                            <img src="../../images/icon_cliente.png" alt="icon"/>
                                                            Cliente                                    
                                                        </span>
                                                    </div>
                                                    <br class="clear"/>
                                                    <div class="content">                                    
                                                        <p>                                    
                                                            <%
                                                                EtiquetaFormularioCliente nombreComercial = camposCliente.get(EtiquetaFormularioClienteDAO.NOMBRE_COMERCIAL);
                                                                if (nombreComercial == null) {
                                                                    nombreComercial = new EtiquetaFormularioCliente();
                                                                    nombreComercial.setCampo(EtiquetaFormularioClienteDAO.NOMBRE_COMERCIAL);
                                                                    nombreComercial.setEtiqueta(EtiquetaFormularioClienteDAO.NOMBRE_COMERCIAL_DEFAULT);
                                                                    nombreComercial.setObligatorio(EtiquetaFormularioClienteDAO.NOMBRE_COMERCIAL_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    nombreComercial.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(nombreComercial.getCampo(), nombreComercial);
                                                                }
                                                                String obligatorioVal = "";
                                                                if (nombreComercial.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"nombreComercialObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"nombreComercialHidden\" value=\"" + nombreComercial.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"nombreComercialCampo\" value=\"" + nombreComercial.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"nombreComercialId\" value=\"" + nombreComercial.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="nombreComercialLabel"><%
                                                                if (nombreComercial.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(nombreComercial.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('nombreComercial')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="200" type="text" id="nombreComercial" name="nombreComercial" style="width:300px;"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>                                    
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente tipo = camposCliente.get(EtiquetaFormularioClienteDAO.TIPO);
                                                                if (tipo == null) {
                                                                    tipo = new EtiquetaFormularioCliente();
                                                                    tipo.setCampo(EtiquetaFormularioClienteDAO.TIPO);
                                                                    tipo.setEtiqueta(EtiquetaFormularioClienteDAO.TIPO_DEFAULT);
                                                                    tipo.setObligatorio(EtiquetaFormularioClienteDAO.TIPO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    tipo.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(tipo.getCampo(), tipo);
                                                                }
                                                                obligatorioVal = "";
                                                                if (tipo.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"tipoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"tipoHidden\" value=\"" + tipo.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"tipoCampo\" value=\"" + tipo.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"tipoId\" value=\"" + tipo.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="tipoLabel"><%
                                                                if (tipo.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(tipo.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('tipo')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <select id="idClienteCategoria" name="idClienteCategoria" disabled="true">
                                                                <option value="0">Selecciona Tipo de Categoría</option>                                            
                                                            </select>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente telefono = camposCliente.get(EtiquetaFormularioClienteDAO.TELEFONO);
                                                                if (telefono == null) {
                                                                    telefono = new EtiquetaFormularioCliente();
                                                                    telefono.setCampo(EtiquetaFormularioClienteDAO.TELEFONO);
                                                                    telefono.setEtiqueta(EtiquetaFormularioClienteDAO.TELEFONO_DEFAULT);
                                                                    telefono.setObligatorio(EtiquetaFormularioClienteDAO.TELEFONO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    telefono.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(telefono.getCampo(), telefono);
                                                                }
                                                                obligatorioVal = "";
                                                                if (telefono.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"telefonoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"telefonoHidden\" value=\"" + telefono.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"telefonoCampo\" value=\"" + telefono.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"telefonoId\" value=\"" + telefono.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="telefonoLabel"><%
                                                                if (telefono.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(telefono.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('telefono')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="8" type="text" id="telefono" name="telefono" style="width:255px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>                                    
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente correoElectronico = camposCliente.get(EtiquetaFormularioClienteDAO.CORREO_ELECTRONICO);
                                                                if (correoElectronico == null) {
                                                                    correoElectronico = new EtiquetaFormularioCliente();
                                                                    correoElectronico.setCampo(EtiquetaFormularioClienteDAO.CORREO_ELECTRONICO);
                                                                    correoElectronico.setEtiqueta(EtiquetaFormularioClienteDAO.CORREO_ELECTRONICO_DEFAULT);
                                                                    correoElectronico.setObligatorio(EtiquetaFormularioClienteDAO.CORREO_ELECTRONICO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    correoElectronico.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(correoElectronico.getCampo(), correoElectronico);
                                                                }
                                                                obligatorioVal = "";
                                                                if (correoElectronico.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"correoElectronicoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"correoElectronicoHidden\" value=\"" + correoElectronico.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"correoElectronicoCampo\" value=\"" + correoElectronico.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"correoElectronicoId\" value=\"" + correoElectronico.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="correoElectronicoLabel"><%
                                                                if (correoElectronico.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(correoElectronico.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('correoElectronico')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="email" name="email" style="width:300px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente contacto = camposCliente.get(EtiquetaFormularioClienteDAO.CONTACTO);
                                                                if (contacto == null) {
                                                                    contacto = new EtiquetaFormularioCliente();
                                                                    contacto.setCampo(EtiquetaFormularioClienteDAO.CONTACTO);
                                                                    contacto.setEtiqueta(EtiquetaFormularioClienteDAO.CONTACTO_DEFAULT);
                                                                    contacto.setObligatorio(EtiquetaFormularioClienteDAO.CONTACTO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    contacto.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(contacto.getCampo(), contacto);
                                                                }
                                                                obligatorioVal = "";
                                                                if (contacto.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"contactoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"contactoHidden\" value=\"" + contacto.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"contactoCampo\" value=\"" + contacto.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"contactoId\" value=\"" + contacto.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="contactoLabel"><%
                                                                if (contacto.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(contacto.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('contacto')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="contacto" name="contacto" style="width:300px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente sucursal = camposCliente.get(EtiquetaFormularioClienteDAO.SUCURSAL);
                                                                if (sucursal == null) {
                                                                    sucursal = new EtiquetaFormularioCliente();
                                                                    sucursal.setCampo(EtiquetaFormularioClienteDAO.SUCURSAL);
                                                                    sucursal.setEtiqueta(EtiquetaFormularioClienteDAO.SUCURSAL_DEFAULT);
                                                                    sucursal.setObligatorio(EtiquetaFormularioClienteDAO.SUCURSAL_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    sucursal.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(sucursal.getCampo(), sucursal);
                                                                }
                                                                obligatorioVal = "";
                                                                if (sucursal.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"sucursalObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"sucursalHidden\" value=\"" + sucursal.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"sucursalCampo\" value=\"" + sucursal.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"sucursalId\" value=\"" + sucursal.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="sucursalLabel"><%
                                                                if (sucursal.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(sucursal.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('sucursal')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <select size="1" id="idSucursalEmpresaAsignado" name="idSucursalEmpresaAsignado" disabled="true">
                                                                <option value="-1">Selecciona una Sucursal</option>                                                
                                                            </select>                                        
                                                        </p>  
                                                        <br/>

                                                        <p>
                                                            <input type="checkbox" class="checkbox" id="estatus" name="estatus" value="1" disabled="true"> 
                                                            <%
                                                                EtiquetaFormularioCliente activo = camposCliente.get(EtiquetaFormularioClienteDAO.ACTIVO);
                                                                if (activo == null) {
                                                                    activo = new EtiquetaFormularioCliente();
                                                                    activo.setCampo(EtiquetaFormularioClienteDAO.ACTIVO);
                                                                    activo.setEtiqueta(EtiquetaFormularioClienteDAO.ACTIVO_DEFAULT);
                                                                    activo.setObligatorio(EtiquetaFormularioClienteDAO.ACTIVO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    activo.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(activo.getCampo(), activo);
                                                                }
                                                                obligatorioVal = "";
                                                                if (activo.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"activoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"activoHidden\" value=\"" + activo.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"activoCampo\" value=\"" + activo.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"activoId\" value=\"" + activo.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="activoLabel"><%
                                                                if (activo.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(activo.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('activo')" onmouseover="" style="cursor: pointer;" /><br/>
                                                        </p>                                                                                         
                                                    </div>
                                                </div>
                                                <!-- End left column window -->

                                                <!--Columna derecha-->
                                                <div class="column_right etiquetasCliente">
                                                    <div class="header">
                                                        <span>
                                                            Domicilio
                                                        </span>
                                                    </div>
                                                    <br class="clear"/>
                                                    <div class="content">
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente calle = camposCliente.get(EtiquetaFormularioClienteDAO.CALLE);
                                                                if (calle == null) {
                                                                    calle = new EtiquetaFormularioCliente();
                                                                    calle.setCampo(EtiquetaFormularioClienteDAO.CALLE);
                                                                    calle.setEtiqueta(EtiquetaFormularioClienteDAO.CALLE_DEFAULT);
                                                                    calle.setObligatorio(EtiquetaFormularioClienteDAO.CALLE_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    calle.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(calle.getCampo(), calle);
                                                                }
                                                                obligatorioVal = "";
                                                                if (calle.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"calleObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"calleHidden\" value=\"" + calle.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"calleCampo\" value=\"" + calle.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"calleId\" value=\"" + calle.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="calleLabel"><%
                                                                if (calle.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(calle.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('calle')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="calle" name="calle" style="width:300px;"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente numeroExterior = camposCliente.get(EtiquetaFormularioClienteDAO.NUMERO_EXTERIOR);
                                                                if (numeroExterior == null) {
                                                                    numeroExterior = new EtiquetaFormularioCliente();
                                                                    numeroExterior.setCampo(EtiquetaFormularioClienteDAO.NUMERO_EXTERIOR);
                                                                    numeroExterior.setEtiqueta(EtiquetaFormularioClienteDAO.NUMERO_EXTERIOR_DEFAULT);
                                                                    numeroExterior.setObligatorio(EtiquetaFormularioClienteDAO.NUMERO_EXTERIOR_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    numeroExterior.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(numeroExterior.getCampo(), numeroExterior);
                                                                }
                                                                obligatorioVal = "";
                                                                if (numeroExterior.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"numeroExteriorObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"numeroExteriorHidden\" value=\"" + numeroExterior.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"numeroExteriorCampo\" value=\"" + numeroExterior.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"numeroExteriorId\" value=\"" + numeroExterior.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="numeroExteriorLabel"><%
                                                                if (numeroExterior.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(numeroExterior.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('numeroExterior')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="30" type="text" id="numero" name="numero" style="width:300px;"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente numeroInterior = camposCliente.get(EtiquetaFormularioClienteDAO.NUMERO_INTERIOR);
                                                                if (numeroInterior == null) {
                                                                    numeroInterior = new EtiquetaFormularioCliente();
                                                                    numeroInterior.setCampo(EtiquetaFormularioClienteDAO.NUMERO_INTERIOR);
                                                                    numeroInterior.setEtiqueta(EtiquetaFormularioClienteDAO.NUMERO_INTERIOR_DEFAULT);
                                                                    numeroInterior.setObligatorio(EtiquetaFormularioClienteDAO.NUMERO_INTERIOR_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    numeroInterior.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(numeroInterior.getCampo(), numeroInterior);
                                                                }
                                                                obligatorioVal = "";
                                                                if (numeroInterior.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"numeroInteriorObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"numeroInteriorHidden\" value=\"" + numeroInterior.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"numeroInteriorCampo\" value=\"" + numeroInterior.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"numeroInteriorId\" value=\"" + numeroInterior.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="numeroInteriorLabel"><%
                                                                if (numeroInterior.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(numeroInterior.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('numeroInterior')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="30" type="text" id="numeroInt" name="numeroInt" style="width:300px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente colonia = camposCliente.get(EtiquetaFormularioClienteDAO.COLONIA);
                                                                if (colonia == null) {
                                                                    colonia = new EtiquetaFormularioCliente();
                                                                    colonia.setCampo(EtiquetaFormularioClienteDAO.COLONIA);
                                                                    colonia.setEtiqueta(EtiquetaFormularioClienteDAO.COLONIA_DEFAULT);
                                                                    colonia.setObligatorio(EtiquetaFormularioClienteDAO.COLONIA_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    colonia.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(colonia.getCampo(), colonia);
                                                                }
                                                                obligatorioVal = "";
                                                                if (colonia.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"coloniaObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"coloniaHidden\" value=\"" + colonia.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"coloniaCampo\" value=\"" + colonia.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"coloniaId\" value=\"" + colonia.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="coloniaLabel"><%
                                                                if (colonia.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(colonia.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('colonia')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="colonia" name="colonia" style="width:300px;"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente codigoPostal = camposCliente.get(EtiquetaFormularioClienteDAO.CODIGO_POSTAL);
                                                                if (codigoPostal == null) {
                                                                    codigoPostal = new EtiquetaFormularioCliente();
                                                                    codigoPostal.setCampo(EtiquetaFormularioClienteDAO.CODIGO_POSTAL);
                                                                    codigoPostal.setEtiqueta(EtiquetaFormularioClienteDAO.CODIGO_POSTAL_DEFAULT);
                                                                    codigoPostal.setObligatorio(EtiquetaFormularioClienteDAO.CODIGO_POSTAL_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    codigoPostal.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(codigoPostal.getCampo(), codigoPostal);
                                                                }
                                                                obligatorioVal = "";
                                                                if (codigoPostal.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"codigoPostalObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"codigoPostalHidden\" value=\"" + codigoPostal.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"codigoPostalCampo\" value=\"" + codigoPostal.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"codigoPostalId\" value=\"" + codigoPostal.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="codigoPostalLabel"><%
                                                                if (codigoPostal.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(codigoPostal.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('codigoPostal')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="5" type="text" id="cp" name="cp" style="width:300px;"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente municipio = camposCliente.get(EtiquetaFormularioClienteDAO.MUNICIPIO);
                                                                if (municipio == null) {
                                                                    municipio = new EtiquetaFormularioCliente();
                                                                    municipio.setCampo(EtiquetaFormularioClienteDAO.MUNICIPIO);
                                                                    municipio.setEtiqueta(EtiquetaFormularioClienteDAO.MUNICIPIO_DEFAULT);
                                                                    municipio.setObligatorio(EtiquetaFormularioClienteDAO.MUNICIPIO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    municipio.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(municipio.getCampo(), municipio);
                                                                }
                                                                obligatorioVal = "";
                                                                if (municipio.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"municipioObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"municipioHidden\" value=\"" + municipio.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"municipioCampo\" value=\"" + municipio.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"municipioId\" value=\"" + municipio.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="municipioLabel"><%
                                                                if (municipio.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(municipio.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('municipio')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="municipio" name="municipio" style="width:300px;"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente estado = camposCliente.get(EtiquetaFormularioClienteDAO.ESTADO);
                                                                if (estado == null) {
                                                                    estado = new EtiquetaFormularioCliente();
                                                                    estado.setCampo(EtiquetaFormularioClienteDAO.ESTADO);
                                                                    estado.setEtiqueta(EtiquetaFormularioClienteDAO.ESTADO_DEFAULT);
                                                                    estado.setObligatorio(EtiquetaFormularioClienteDAO.ESTADO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    estado.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(estado.getCampo(), estado);
                                                                }
                                                                obligatorioVal = "";
                                                                if (estado.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"estadoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"estadoHidden\" value=\"" + estado.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"estadoCampo\" value=\"" + estado.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"estadoId\" value=\"" + estado.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="estadoLabel"><%
                                                                if (estado.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(estado.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('estado')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="estado" name="estado" style="width:300px;"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioCliente pais = camposCliente.get(EtiquetaFormularioClienteDAO.PAIS);
                                                                if (pais == null) {
                                                                    pais = new EtiquetaFormularioCliente();
                                                                    pais.setCampo(EtiquetaFormularioClienteDAO.PAIS);
                                                                    pais.setEtiqueta(EtiquetaFormularioClienteDAO.PAIS_DEFAULT);
                                                                    pais.setObligatorio(EtiquetaFormularioClienteDAO.PAIS_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    pais.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposCliente.put(pais.getCampo(), pais);
                                                                }
                                                                obligatorioVal = "";
                                                                if (pais.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"paisObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"paisHidden\" value=\"" + pais.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"paisCampo\" value=\"" + pais.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"paisId\" value=\"" + pais.getIdEtiquetaFormularioCliente() + "\"/>");
                                                            %>
                                                            <label id="paisLabel"><%
                                                                if (pais.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(pais.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalCliente('pais')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="pais" name="pais" style="width:300px;"
                                                                   value="" disabled="true"/>
                                                        </p>                                
                                                    </div>
                                                    <div id="action_buttons">
                                                        <p>
                                                            <input type="button" id="enviar" value="Guardar" onclick="grabarCliente();"/>
                                                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>                                            
                                                        </p>
                                                    </div>   
                                                </div>
                                                <br/>

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

                                                                        <td>
                                                                            <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Nuevo Campo" 
                                                                                   style="float: right; width: 100px;" onclick="nuevoCampoAdicionalCliente()"/>
                                                                        </td>                                           
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                    <div class="content" id="areaCamposAdicionalesCliente">
                                                        <%
                                                            CampoAdicionalClienteDAO cacdao = new CampoAdicionalClienteDAO();
                                                            List<CampoAdicionalCliente> campos = cacdao.lista(user.getUser().getIdUsuarios());
                                                            for (CampoAdicionalCliente campoAdicional : campos) {
                                                                obligatorioVal = "";
                                                                if (campoAdicional.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "ObligatorioAdicional\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "HiddenAdicional\" value=\"" + campoAdicional.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "IdAdicional\" value=\"" + campoAdicional.getIdCampoAdicionalCliente() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "TipoAdicional\" value=\"" + campoAdicional.getTipoDato() + "\"/>");
                                                        %>
                                                        <label id="<%=campoAdicional.getEtiqueta()%>Label"><%
                                                            if (campoAdicional.getObligatorio() == 1) {
                                                                out.print("*");
                                                            }
                                                            out.print(campoAdicional.getEtiqueta());
                                                            %>:</label> <img id="<%=campoAdicional.getEtiqueta()%>linkEditarCliente" src="../../images/icon_edit.png" alt="icon" onclick="editarCampoAdicionalCliente('<%=campoAdicional.getEtiqueta()%>')" onmouseover="" style="cursor: pointer;" /><br/><%
                                                                }
                                                            %>
                                                    </div>

                                                </div>
                                                <br/><br/>

                                            </div>
                                        </div>

                                        <div id="SecondTab" class="inactive">
                                            <div class="twocolumn">
                                                <div class="column_left etiquetasProspecto">
                                                    <div class="header">
                                                        <span>
                                                            <img src="../../images/icon_prospecto.png" alt="icon"/>
                                                            Prospecto
                                                        </span>
                                                    </div>
                                                    <br class="clear"/>
                                                    <div>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioProspecto razonSocial = camposProspecto.get(EtiquetaFormularioProspectoDAO.RAZON_SOCIAL);
                                                                if (razonSocial == null) {
                                                                    razonSocial = new EtiquetaFormularioProspecto();
                                                                    razonSocial.setCampo(EtiquetaFormularioProspectoDAO.RAZON_SOCIAL);
                                                                    razonSocial.setEtiqueta(EtiquetaFormularioProspectoDAO.RAZON_SOCIAL_DEFAULT);
                                                                    razonSocial.setObligatorio(EtiquetaFormularioProspectoDAO.RAZON_SOCIAL_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    razonSocial.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposProspecto.put(razonSocial.getCampo(), razonSocial);
                                                                }
                                                                obligatorioVal = "";
                                                                if (razonSocial.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"razonSocialObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"razonSocialHidden\" value=\"" + razonSocial.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"razonSocialCampo\" value=\"" + razonSocial.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"razonSocialId\" value=\"" + razonSocial.getIdEtiquetaFormularioProspecto() + "\"/>");
                                                            %>
                                                            <label id="razonSocialLabel"><%
                                                                if (razonSocial.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(razonSocial.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalProspecto('razonSocial')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="200" type="text" id="razonSocial" name="razonSocial" style="width:300px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioProspecto contacto2 = camposProspecto.get(EtiquetaFormularioProspectoDAO.CONTACTO);
                                                                if (contacto2 == null) {
                                                                    contacto2 = new EtiquetaFormularioProspecto();
                                                                    contacto2.setCampo(EtiquetaFormularioProspectoDAO.CONTACTO);
                                                                    contacto2.setEtiqueta(EtiquetaFormularioProspectoDAO.CONTACTO_DEFAULT);
                                                                    contacto2.setObligatorio(EtiquetaFormularioProspectoDAO.CONTACTO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    contacto2.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposProspecto.put(contacto2.getCampo(), contacto2);
                                                                }
                                                                obligatorioVal = "";
                                                                if (contacto2.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"contactoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"contactoHidden\" value=\"" + contacto2.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"contactoCampo\" value=\"" + contacto2.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"contactoId\" value=\"" + contacto2.getIdEtiquetaFormularioProspecto() + "\"/>");
                                                            %>
                                                            <label id="contactoLabel"><%
                                                                if (contacto2.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(contacto2.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalProspecto('contacto')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="contacto" name="contacto" style="width:300px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioProspecto lada = camposProspecto.get(EtiquetaFormularioProspectoDAO.LADA);
                                                                if (lada == null) {
                                                                    lada = new EtiquetaFormularioProspecto();
                                                                    lada.setCampo(EtiquetaFormularioProspectoDAO.LADA);
                                                                    lada.setEtiqueta(EtiquetaFormularioProspectoDAO.LADA_DEFAULT);
                                                                    lada.setObligatorio(EtiquetaFormularioProspectoDAO.LADA_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    lada.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposProspecto.put(lada.getCampo(), lada);
                                                                }
                                                                obligatorioVal = "";
                                                                if (lada.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"ladaObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"ladaHidden\" value=\"" + lada.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"ladaCampo\" value=\"" + lada.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"ladaId\" value=\"" + lada.getIdEtiquetaFormularioProspecto() + "\"/>");
                                                            %>
                                                            <label id="ladaLabel"><%
                                                                if (lada.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(lada.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalProspecto('lada')" onmouseover="" style="cursor: pointer;" />-
                                                                <%
                                                                EtiquetaFormularioProspecto telefono2 = camposProspecto.get(EtiquetaFormularioProspectoDAO.TELEFONO);
                                                                if (telefono2 == null) {
                                                                    telefono2 = new EtiquetaFormularioProspecto();
                                                                    telefono2.setCampo(EtiquetaFormularioProspectoDAO.TELEFONO);
                                                                    telefono2.setEtiqueta(EtiquetaFormularioProspectoDAO.TELEFONO_DEFAULT);
                                                                    telefono2.setObligatorio(EtiquetaFormularioProspectoDAO.TELEFONO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    telefono2.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposProspecto.put(telefono2.getCampo(), telefono2);
                                                                }
                                                                obligatorioVal = "";
                                                                if (telefono2.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"telefonoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"telefonoHidden\" value=\"" + telefono2.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"telefonoCampo\" value=\"" + telefono2.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"telefonoId\" value=\"" + telefono2.getIdEtiquetaFormularioProspecto() + "\"/>");
                                                            %>
                                                            <label id="telefonoLabel"><%
                                                                if (telefono2.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(telefono2.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalProspecto('telefono')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="3" type="text" id="lada" name="lada" style="width:25px"
                                                                   value="" disabled="true"/> -
                                                            <input maxlength="8" type="text" id="telefono" name="telefono" style="width:255px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioProspecto celular = camposProspecto.get(EtiquetaFormularioProspectoDAO.CELULAR);
                                                                if (celular == null) {
                                                                    celular = new EtiquetaFormularioProspecto();
                                                                    celular.setCampo(EtiquetaFormularioProspectoDAO.CELULAR);
                                                                    celular.setEtiqueta(EtiquetaFormularioProspectoDAO.CELULAR_DEFAULT);
                                                                    celular.setObligatorio(EtiquetaFormularioProspectoDAO.CELULAR_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    celular.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposProspecto.put(celular.getCampo(), celular);
                                                                }
                                                                obligatorioVal = "";
                                                                if (celular.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"celularObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"celularHidden\" value=\"" + celular.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"celularCampo\" value=\"" + celular.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"celularId\" value=\"" + celular.getIdEtiquetaFormularioProspecto() + "\"/>");
                                                            %>
                                                            <label id="celularLabel"><%
                                                                if (celular.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(celular.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalProspecto('celular')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="11" type="text" id="celular" name="celular" style="width:300px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioProspecto correoElectronico2 = camposProspecto.get(EtiquetaFormularioProspectoDAO.CORREO_ELECTRONICO);
                                                                if (correoElectronico2 == null) {
                                                                    correoElectronico2 = new EtiquetaFormularioProspecto();
                                                                    correoElectronico2.setCampo(EtiquetaFormularioProspectoDAO.CORREO_ELECTRONICO);
                                                                    correoElectronico2.setEtiqueta(EtiquetaFormularioProspectoDAO.CORREO_ELECTRONICO_DEFAULT);
                                                                    correoElectronico2.setObligatorio(EtiquetaFormularioProspectoDAO.CORREO_ELECTRONICO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    correoElectronico2.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposProspecto.put(correoElectronico2.getCampo(), correoElectronico2);
                                                                }
                                                                obligatorioVal = "";
                                                                if (correoElectronico2.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"correoElectronicoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"correoElectronicoHidden\" value=\"" + correoElectronico2.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"correoElectronicoCampo\" value=\"" + correoElectronico2.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"correoElectronicoId\" value=\"" + correoElectronico2.getIdEtiquetaFormularioProspecto() + "\"/>");
                                                            %>
                                                            <label id="correoElectronicoLabel"><%
                                                                if (correoElectronico2.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(correoElectronico2.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalProspecto('correoElectronico')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="email" name="email" style="width:300px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioProspecto descripcion = camposProspecto.get(EtiquetaFormularioProspectoDAO.DESCRIPCION);
                                                                if (descripcion == null) {
                                                                    descripcion = new EtiquetaFormularioProspecto();
                                                                    descripcion.setCampo(EtiquetaFormularioProspectoDAO.DESCRIPCION);
                                                                    descripcion.setEtiqueta(EtiquetaFormularioProspectoDAO.DESCRIPCION_DEFAULT);
                                                                    descripcion.setObligatorio(EtiquetaFormularioProspectoDAO.DESCRIPCION_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    descripcion.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposProspecto.put(descripcion.getCampo(), descripcion);
                                                                }
                                                                obligatorioVal = "";
                                                                if (descripcion.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"descripcionObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"descripcionHidden\" value=\"" + descripcion.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"descripcionCampo\" value=\"" + descripcion.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"descripcionId\" value=\"" + descripcion.getIdEtiquetaFormularioProspecto() + "\"/>");
                                                            %>
                                                            <label id="descripcionLabel"><%
                                                                if (descripcion.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(descripcion.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalProspecto('descripcion')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <textarea rows="5" cols="35" id="descripcion" name="descripcion" disabled="true"></textarea>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <input type="checkbox" class="checkbox" id="estatus" name="estatus" value="1" disabled="true"> <%
                                                                EtiquetaFormularioProspecto activo2 = camposProspecto.get(EtiquetaFormularioProspectoDAO.ACTIVO);
                                                                if (activo2 == null) {
                                                                    activo2 = new EtiquetaFormularioProspecto();
                                                                    activo2.setCampo(EtiquetaFormularioProspectoDAO.ACTIVO);
                                                                    activo2.setEtiqueta(EtiquetaFormularioProspectoDAO.ACTIVO_DEFAULT);
                                                                    activo2.setObligatorio(EtiquetaFormularioProspectoDAO.ACTIVO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    activo2.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposProspecto.put(activo2.getCampo(), activo2);
                                                                }
                                                                obligatorioVal = "";
                                                                if (activo2.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"activoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"activoHidden\" value=\"" + activo2.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"activoCampo\" value=\"" + activo2.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"activoId\" value=\"" + activo2.getIdEtiquetaFormularioProspecto() + "\"/>");
                                                            %>
                                                            <label id="activoLabel"><%
                                                                if (activo2.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(activo2.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalProspecto('activo')" onmouseover="" style="cursor: pointer;" /><br/>
                                                        </p>
                                                        <br/>
                                                        <br/>

                                                    </div>
                                                </div>
                                                <!-- End left column window -->

                                                <div class="column_right etiquetasProspecto">
                                                    <div class="header">
                                                        <span>
                                                            <img src="../../images/icon_prospecto.png" alt="icon"/>
                                                            Imágenes del prospecto
                                                        </span>
                                                    </div>
                                                    <br class="clear"/>
                                                    <div class="content">

                                                        <p>
                                                            <%
                                                                EtiquetaFormularioProspecto fotoProspecto = camposProspecto.get(EtiquetaFormularioProspectoDAO.FOTO_PROSPECTO);
                                                                if (fotoProspecto == null) {
                                                                    fotoProspecto = new EtiquetaFormularioProspecto();
                                                                    fotoProspecto.setCampo(EtiquetaFormularioProspectoDAO.FOTO_PROSPECTO);
                                                                    fotoProspecto.setEtiqueta(EtiquetaFormularioProspectoDAO.FOTO_PROSPECTO_DEFAULT);
                                                                    fotoProspecto.setObligatorio(EtiquetaFormularioProspectoDAO.FOTO_PROSPECTO_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    fotoProspecto.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposProspecto.put(fotoProspecto.getCampo(), fotoProspecto);
                                                                }
                                                                obligatorioVal = "";
                                                                if (fotoProspecto.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"fotoProspectoObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"fotoProspectoHidden\" value=\"" + fotoProspecto.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"fotoProspectoCampo\" value=\"" + fotoProspecto.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"fotoProspectoId\" value=\"" + fotoProspecto.getIdEtiquetaFormularioProspecto() + "\"/>");
                                                            %>
                                                            <label id="fotoProspectoLabel"><%
                                                                if (fotoProspecto.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(fotoProspecto.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalProspecto('fotoProspecto')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <br/>

                                                        </p>                                
                                                    </div>
                                                </div>
                                                <br><br><br><br><br><br><br><br>

                                                <div class="column_right etiquetasProspecto">                            
                                                    <div class="header">
                                                        <span>
                                                            <img src="../../images/icon_mapa_1.png" alt="icon"/>
                                                            Ubicación
                                                        </span>
                                                    </div>   
                                                    <div id="action_buttons">
                                                            <p>
                                                                <input type="button" id="enviar" value="Guardar" onclick="grabarProspecto();"/>
                                                                <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                                            </p>
                                                        </div>                                    
                                                </div>  
                                                
                                                <div class="column_right">
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

                                                                        <td>
                                                                            <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Nuevo Campo" 
                                                                                   style="float: right; width: 100px;" onclick="nuevoCampoAdicionalProspecto()"/>
                                                                        </td>                                           
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                    <div class="content" id="areaCamposAdicionalesProspecto">
                                                        <%
                                                            CampoAdicionalProspectoDAO capdao = new CampoAdicionalProspectoDAO();
                                                            List<CampoAdicionalProspecto> campos2 = capdao.lista(user.getUser().getIdUsuarios());
                                                            for (CampoAdicionalProspecto campoAdicional : campos2) {
                                                                obligatorioVal = "";
                                                                if (campoAdicional.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "ObligatorioAdicional\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "HiddenAdicional\" value=\"" + campoAdicional.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "IdAdicional\" value=\"" + campoAdicional.getIdCampoAdicionalProspecto() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"" + campoAdicional.getEtiqueta().replace(" ", "") + "TipoAdicional\" value=\"" + campoAdicional.getTipoDato() + "\"/>");
                                                        %>
                                                        <label id="<%=campoAdicional.getEtiqueta()%>Label"><%
                                                            if (campoAdicional.getObligatorio() == 1) {
                                                                out.print("*");
                                                            }
                                                            out.print(campoAdicional.getEtiqueta());
                                                            %>:</label> <img id="<%=campoAdicional.getEtiqueta()%>linkEditarProspecto" src="../../images/icon_edit.png" alt="icon" onclick="editarCampoAdicionalProspecto('<%=campoAdicional.getEtiqueta()%>')" onmouseover="" style="cursor: pointer;" /><br/><%
                                                                }
                                                            %>
                                                    </div>

                                                </div>
                                                <br/><br/>


                                            </div>
                                        </div>

                                        <div id="ThirdTab" class="inactive">
                                            <div class="twocolumn">
                                                <div class="column_left etiquetasSucursal">
                                                    <div class="header">
                                                        <span>
                                                            <img src="../../images/icon_sucursales.png" alt="icon"/>                                                            
                                                            Sucursal                                                            
                                                        </span>
                                                        <div style="float: right;" >
                                                            <label>** : Heredados de Matriz &nbsp;</label>
                                                        </div>
                                                    </div>
                                                    <br class="clear"/>
                                                    <div>
                                                        <p><%
                                                                EtiquetaFormularioSucursal rfc = camposSucursal.get(EtiquetaFormularioSucursalDAO.RFC);
                                                                if (rfc == null) {
                                                                    rfc = new EtiquetaFormularioSucursal();
                                                                    rfc.setCampo(EtiquetaFormularioSucursalDAO.RFC);
                                                                    rfc.setEtiqueta(EtiquetaFormularioSucursalDAO.RFC_DEFAULT);
                                                                    rfc.setObligatorio(EtiquetaFormularioSucursalDAO.RFC_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    rfc.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposSucursal.put(rfc.getCampo(), rfc);
                                                                }
                                                                obligatorioVal = "";
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
                                                                %>:</label>&nbsp;** <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('rfc')" onmouseover="" style="cursor: pointer;" /><br/>                                                            
                                                            <input maxlength="30" type="text" id="rfc_sucursal" name="rfc_sucursal" style="width:300px"
                                                                   readonly disabled value=""/>
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
                                                                %>:</label>&nbsp;** <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('razonSocial')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="30" type="text" id="razonsocial_sucursal" name="razonsocial_sucursal" style="width:300px"
                                                                   readonly disabled value=""/>
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
                                                                %>:</label>&nbsp;**  <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('regimenFiscal')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="30" type="text" id="regimen_sucursal" name="regimen_sucursal" style="width:300px"
                                                                   readonly disabled value=""/>
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('nombreComercial')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="30" type="text" id="nombreSucursal" name="nombreSucursal" style="width:300px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                        <br/>
                                                        <p>
                                                            <%
                                                                EtiquetaFormularioSucursal matriz = camposSucursal.get(EtiquetaFormularioSucursalDAO.MATRIZ);
                                                                if (matriz == null) {
                                                                    matriz = new EtiquetaFormularioSucursal();
                                                                    matriz.setCampo(EtiquetaFormularioSucursalDAO.MATRIZ);
                                                                    matriz.setEtiqueta(EtiquetaFormularioSucursalDAO.MATRIZ_DEFAULT);
                                                                    matriz.setObligatorio(EtiquetaFormularioSucursalDAO.MATRIZ_REQUERIDO_DEFAULT ? 1 : 0);
                                                                    matriz.setIdUsuario(user.getUser().getIdUsuarios());
                                                                    camposSucursal.put(matriz.getCampo(), matriz);
                                                                }
                                                                obligatorioVal = "";
                                                                if (matriz.getObligatorio() == 1) {
                                                                    obligatorioVal = "1";
                                                                } else {
                                                                    obligatorioVal = "0";
                                                                }
                                                                out.print("<input type=\"hidden\" id=\"matrizObligatorio\" value=\"" + obligatorioVal + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"matrizHidden\" value=\"" + matriz.getEtiqueta() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"matrizCampo\" value=\"" + matriz.getCampo() + "\"/>");
                                                                out.print("<input type=\"hidden\" id=\"matrizId\" value=\"" + matriz.getIdEtiquetaFormularioSucursal() + "\"/>");
                                                            %>
                                                            <label id="matrizLabel"><%
                                                                if (matriz.getObligatorio() == 1) {
                                                                    out.print("*");
                                                                }
                                                                out.print(matriz.getEtiqueta());
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('matriz')" onmouseover="" style="cursor: pointer;" /><br/>
                                                        <div id="div_select_cliente" name="div_select_cliente" style="display: inline;" >
                                                        </div>
                                                        </p>  
                                                        <br/>                                    
                                                        <p>
                                                            <label>Estatus:</label>
                                                            <input type="checkbox" class="checkbox" disabled="true"
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('activo')" onmouseover="" style="cursor: pointer;" /><br/>
                                                        </p>
                                                        <br/><br/>

                                                    </div>
                                                </div>
                                                <!-- End left column window -->

                                                <!--Columna derecha-->
                                                <div class="column_right etiquetasSucursal">
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('calle')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="calle" name="calle" style="width:300px"
                                                                   value="" disabled="true"/>
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('numeroExterior')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="30" type="text" id="ext" name="ext" style="width:300px"
                                                                   value="" disabled="true"/>
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('numeroInterior')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="30" type="text" id="int" name="int" style="width:300px"
                                                                   value="" disabled="true"/>
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('colonia')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="colonia" name="colonia" style="width:300px"
                                                                   value="" disabled="true"/>
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('codigoPostal')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="5" type="text" id="cp" name="cp" style="width:300px"
                                                                   value="" disabled="true"/>
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('municipio')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="delMuni" name="delMuni" style="width:300px"
                                                                   value="" disabled="true"/>
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('estado')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="50" type="text" id="estado" name="estado" style="width:300px"
                                                                   value="" disabled="true"/>
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
                                                                %>:</label> <img src="../../images/icon_edit.png" alt="icon" onclick="openModalSucursal('pais')" onmouseover="" style="cursor: pointer;" /><br/>
                                                            <input maxlength="100" type="text" id="pais" name="pais" style="width:300px"
                                                                   value="" disabled="true"/>
                                                        </p>
                                                    </div>
                                                    <div id="action_buttons">
                                                            <p>
                                                                <input type="button" id="enviar" value="Guardar" onclick="grabarSucursal();"/>
                                                                <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
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

                                                                        <td>
                                                                            <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Nuevo Campo" 
                                                                                   style="float: right; width: 100px;" onclick="nuevoCampoAdicionalSucursal()"/>
                                                                        </td>                                           
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                    <div class="content" id="areaCamposAdicionalesSucursal">
                                                        <%
                                                            CampoAdicionalSucursalDAO casdao = new CampoAdicionalSucursalDAO();
                                                            List<CampoAdicionalSucursal> campos3 = casdao.lista(user.getUser().getIdUsuarios());
                                                            for (CampoAdicionalSucursal campoAdicional : campos3) {
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
                                                            %>:</label> <img id="<%=campoAdicional.getEtiqueta()%>linkEditarSucursal" src="../../images/icon_edit.png" alt="icon" onclick="editarCampoAdicionalSucursal('<%=campoAdicional.getEtiqueta()%>')" onmouseover="" style="cursor: pointer;" /><br/><%
                                                                }
                                                            %>
                                                    </div>

                                                </div>

                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </form>

                        </div>
                    </div>

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>
        <div id="etiquetaModalCliente" class="modal">

            <!-- Modal content -->
            <div class="modal-content">
                <span class="close">x</span>
                <br/>
                <br/>
                <br/>
                <input id="modalCampoCliente" type="hidden" value=""/>
                <p>Etiqueta: 
                    <input type="text" id="etiquetaCliente"/>

                </p>
                <p>
                    Obligatorio:
                    <input type="checkbox" class="checkbox" id="obligatorioCliente"value="1">
                </p>
                <br/>
                <br/>
                <p style="text-align: center">
                    <input type="button" value="Guardar" onclick="guardarEtiquetaCliente()">                    
                </p>
                <br/>
            </div>

        </div>

        <div id="campoAdicionalModalCliente" class="modal">

            <!-- Modal content -->
            <div class="modal-content">
                <span class="close">x</span>
                <br/>
                <br/>
                <br/>
                <input id="idCampoAdicionalModal" type="hidden" value=""/>
                <input id="etiquetaAnteriorModal" type="hidden" value=""/>
                <p>Etiqueta: 
                    <input type="text" id="etiquetaCampoAdicional"/>

                </p>
                <p>
                    Obligatorio:
                    <input type="checkbox" class="checkbox" id="obligatorioCampoAdicional"value="1">
                </p>
                <p>
                    Tipo de dato:
                    <select id="tipoDatoAdicional" name="tipoDatoAdicional">
                        <option value=0>Selecciona Tipo de Dato</option>
                        <option value=1>Numerico</option>
                        <option value=2>Solo letras</option>
                        <option value=3>Alfanumerico</option>
                    </select>
                </p>
                <br/>
                <br/>
                <p style="text-align: center">
                    <input type="button" value="Guardar" onclick="guardarCampoAdicionalCliente()">                    
                </p>
                <br/>
            </div>

        </div>
            
            <div id="etiquetaModalProspecto" class="modal">

            <!-- Modal content -->
            <div class="modal-content">
                <span class="close">x</span>
                <br/>
                <br/>
                <br/>
                <input id="modalCampoProspecto" type="hidden" value=""/>
                <p>Etiqueta: 
                    <input type="text" id="etiquetaProspecto"/>

                </p>
                <p>
                    Obligatorio:
                    <input type="checkbox" class="checkbox" id="obligatorioProspecto"value="1">
                </p>
                <br/>
                <br/>
                <p style="text-align: center">
                    <input type="button" value="Guardar" onclick="guardarEtiquetaProspecto()">                    
                </p>
                <br/>
            </div>

        </div>

        <div id="campoAdicionalModalProspecto" class="modal">

            <!-- Modal content -->
            <div class="modal-content">
                <span class="close">x</span>
                <br/>
                <br/>
                <br/>
                <input id="idCampoAdicionalModal" type="hidden" value=""/>
                <input id="etiquetaAnteriorModal" type="hidden" value=""/>
                <p>Etiqueta: 
                    <input type="text" id="etiquetaCampoAdicional"/>

                </p>
                <p>
                    Obligatorio:
                    <input type="checkbox" class="checkbox" id="obligatorioCampoAdicional"value="1">
                </p>
                <p>
                    Tipo de dato:
                    <select id="tipoDatoAdicional" name="tipoDatoAdicional">
                        <option value=0>Selecciona Tipo de Dato</option>
                        <option value=1>Numerico</option>
                        <option value=2>Solo letras</option>
                        <option value=3>Alfanumerico</option>
                    </select>
                </p>
                <br/>
                <br/>
                <p style="text-align: center">
                    <input type="button" value="Guardar" onclick="guardarCampoAdicionalProspecto()">                    
                </p>
                <br/>
            </div>

        </div>
            <div id="etiquetaModalSucursal" class="modal">

            <!-- Modal content -->
            <div class="modal-content">
                <span class="close">x</span>
                <br/>
                <br/>
                <br/>
                <input id="modalCampoSucursal" type="hidden" value=""/>
                <p>Etiqueta: 
                    <input type="text" id="etiquetaSucursal"/>

                </p>
                <p>
                    Obligatorio:
                    <input type="checkbox" class="checkbox" id="obligatorioSucursal"value="1">
                </p>
                <br/>
                <br/>
                <p style="text-align: center">
                    <input type="button" value="Guardar" onclick="guardarEtiquetaSucursal()">                    
                </p>
                <br/>
            </div>

        </div>

        <div id="campoAdicionalModalSucursal" class="modal">

            <!-- Modal content -->
            <div class="modal-content">
                <span class="close">x</span>
                <br/>
                <br/>
                <br/>
                <input id="idCampoAdicionalModal" type="hidden" value=""/>
                <input id="etiquetaAnteriorModal" type="hidden" value=""/>
                <p>Etiqueta: 
                    <input type="text" id="etiquetaCampoAdicional"/>

                </p>
                <p>
                    Obligatorio:
                    <input type="checkbox" class="checkbox" id="obligatorioCampoAdicional"value="1">
                </p>
                <p>
                    Tipo de dato:
                    <select id="tipoDatoAdicional" name="tipoDatoAdicional">
                        <option value=0>Selecciona Tipo de Dato</option>
                        <option value=1>Numerico</option>
                        <option value=2>Solo letras</option>
                        <option value=3>Alfanumerico</option>
                    </select>
                </p>
                <br/>
                <br/>
                <p style="text-align: center">
                    <input type="button" value="Guardar" onclick="guardarCampoAdicionalSucursal()">                    
                </p>
                <br/>
            </div>

        </div>
    </body>
</html>
<%}%>