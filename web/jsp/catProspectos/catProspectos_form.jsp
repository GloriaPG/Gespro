<%-- 
    Document   : catProspectos_form.jsp
    Created on : 06-nov-2012, 12:13:49
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalProspectoValorDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalProspectoValor"%>
<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalProspecto"%>
<%@page import="java.util.List"%>
<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalProspectoDAO"%>
<%@page import="com.tsp.gespro.hibernate.dao.EtiquetaFormularioProspectoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.EtiquetaFormularioProspecto"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.dto.Prospecto"%>
<%@page import="com.tsp.gespro.bo.ProspectoBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<jsp:useBean id="helperEtiquetaProspecto" class="com.tsp.gespro.hibernate.dao.EtiquetaFormularioProspectoDAO"/>
<%
//Verifica si el prospecto tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {
        HashMap<String, EtiquetaFormularioProspecto> camposProspecto = helperEtiquetaProspecto.getMap(user.getUser().getIdUsuarios());
        int paginaActual = 1;
        try {
            paginaActual = Integer.parseInt(request.getParameter("pagina"));
        } catch (Exception e) {
        }

        int idEmpresa = user.getUser().getIdEmpresa();

        /*
         * Parámetros
         */
        int idProspecto = 0;
        try {
            idProspecto = Integer.parseInt(request.getParameter("idProspecto"));
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

        ProspectoBO prospectoBO = new ProspectoBO(user.getConn());
        Prospecto prospectoDto = null;
        if (idProspecto > 0) {
            prospectoBO = new ProspectoBO(idProspecto, user.getConn());
            prospectoDto = prospectoBO.getProspecto();
        }
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

            function grabar() {
                if (validar()) {
                    var adicionalesProspectoValidacion = [];
                    $('#areaCamposAdicionalesProspecto *[id*=HiddenAdicional]:hidden').each(function () {
                        var etiqueta = $(this).val();
                        if (etiqueta != "") {
                            var tipo = $("#" + etiqueta.replace(" ", "") + "TipoAdicional").val()
                            var obligatorio = $("#" + etiqueta.replace(" ", "") + "ObligatorioAdicional").val();
                            var idAdicional = $("#" + etiqueta.replace(" ", "") + "IdAdicional").val();
                            var valorAdicional = $("#" + etiqueta.replace(" ", "") + "IdValor").val();
                            var idProspecto = $("#idProspecto").val();
                            var idProspecto = $("#idProspecto").val()?$("#idProspecto").val():0;
                            var adicionalProspecto = {idAdicional: idAdicional, idProspecto: idProspecto, etiqueta: etiqueta, obligatorio: obligatorio, tipo: tipo, valor: valorAdicional};
                            adicionalesProspectoValidacion.push(adicionalProspecto);
                        }
                    });
                    $.ajax({
                        type: "POST",
                        url: "ajaxValidaciones.jsp",
                        data: JSON.stringify(adicionalesProspectoValidacion),
                        success: function (datos) {
                            if (datos.indexOf("--EXITO-->", 0) > 0) {
                                $.ajax({
                                    type: "POST",
                                    url: "catProspectos_ajax.jsp",
                                    data: $("#frm_action").serialize(),
                                    success: function (datos) {
                                        if (datos.indexOf("--EXITO-->", 0) > 0) {
                                            var partes = [];
                                            partes = datos.split(":");
                                            var adicionalesProspecto = [];
                                            $('#areaCamposAdicionalesProspecto *[id*=HiddenAdicional]:hidden').each(function () {
                                                var etiqueta = $(this).val();
                                                if (etiqueta != "") {
                                                    var tipo = $("#" + etiqueta.replace(" ", "") + "TipoAdicional").val()
                                                    var obligatorio = $("#" + etiqueta.replace(" ", "") + "ObligatorioAdicional").val();
                                                    var idAdicional = $("#" + etiqueta.replace(" ", "") + "IdAdicional").val();
                                                    var valorAdicional = $("#" + etiqueta.replace(" ", "") + "IdValor").val();
                                                    var idProspecto = partes.length > 1 ? partes[1] : $("#idProspecto").val();
                                                    var adicionalProspecto = {idAdicional: idAdicional, idProspecto: idProspecto, etiqueta: etiqueta, obligatorio: obligatorio, tipo: tipo, valor: valorAdicional};
                                                    adicionalesProspecto.push(adicionalProspecto);
                                                }
                                            });
                                            $.ajax({
                                                type: "POST",
                                                url: "ajaxAdicionalesProspecto.jsp",
                                                data: JSON.stringify(adicionalesProspecto),
                                                beforeSend: function (objeto) {
                                                    $("#action_buttons").fadeOut("slow");
                                                    $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                                                    $("#ajax_loading").fadeIn("slow");
                                                },
                                                success: function (datos) {
                                                    console.log("datos: " + datos);
                                                    if (datos.indexOf("--EXITO-->", 0) > 0) {
                                                        console.log("EXITO!");
                                                        $("#ajax_message").html(datos);
                                                        $("#ajax_loading").fadeOut("slow");
                                                        $("#ajax_message").fadeIn("slow");
                                                        apprise('<center><img src=../../images/info.png> <br/>' + datos + '</center>', {'animate': true},
                                                                function (r) {
            <% if (!mode.equals("3")) {%>
                                                                    location.href = "catProspectos_list.jsp?pagina=" + "<%=paginaActual%>";
            <%} else {%>
                                                                    parent.recargarSelectProspectos();
                                                                    parent.$.fancybox.close();
            <%}%>

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

            function validar() {
                /*
                 if(jQuery.trim($("#nombre").val())==""){
                 apprise('<center><img src=../../images/warning.png> <br/>El dato "nombre de contacto" es requerido</center>',{'animate':true});
                 $("#nombre_contacto").focus();
                 return false;
                 }
                 */
                return true;
            }

            $(document).ready(function () {
                //Si se recibio el parametro para que el modo sea en forma de popup
            <%= mode.equals("3") ? "mostrarFormPopUpMode();" : ""%>
            });

            function mostrarFormPopUpMode() {
                $('#left_menu').hide();
                $('#header').hide();
                //$('#show_menu').show();
                $('body').addClass('nobg');
                $('#content').css('marginLeft', 30);
                $('#wysiwyg').css('width', '97%');
                setNotifications();
            }

            /// Mapa
            var coordenada;
            var marker;
            var map;

            var latitudProspecto = <%=prospectoDto != null ? prospectoDto.getLatitud() : 0%>;
            var longitudProspecto = <%=prospectoDto != null ? prospectoDto.getLongitud() : 0%>
            var idProspectoActualizar = <%=prospectoDto != null ? prospectoDto.getIdProspecto() : 0%>

            function initialize() {

                var coordenada = new google.maps.LatLng(latitudProspecto, longitudProspecto);

                var mapOptions = {
                    zoom: 14,
                    center: coordenada
                };

                map = new google.maps.Map(document.getElementById('map_canvas'),
                        mapOptions);

                marker = new google.maps.Marker({
                    map: map,
                    animation: google.maps.Animation.DROP,
                    position: coordenada,
                    title: "Prospecto ID: " + idProspectoActualizar
                });

                google.maps.event.addListener(marker, 'click', function () {
                    infowindow.open(map, marker);
                });

                //VAMOS A RECUPERAR LAS COORDENADAS /////////////////////
                //Creo un evento asociado a "mapa" cuando se hace "click" sobre el
                google.maps.event.addListener(map, "dblclick", function (evento) {
                    latitudProspecto = evento.latLng.lat();
                    longitudProspecto = evento.latLng.lng();

                    //LIMPIAMOS EL MAPA Y LO MOSTRMOS DE NUEVO CON LAS NUEVAS COORDENADAS
                    initialize();
                    //ACTUALIZAMOS LAS COORDENADAS
                    actualizarCoordenadasProspecto(latitudProspecto, longitudProspecto, idProspectoActualizar);
                    //Puedo unirlas en una unica variable si asi lo prefiero
                    //var coordenadas = evento.latLng.lat() + ", " + evento.latLng.lng();

                    //Las muestro con un popup
                    //alert(coordenadas);

                    //Creo un marcador utilizando las coordenadas obtenidas y almacenadas por separado en "latitud" y "longitud"
                    //var coordenadas = new google.maps.LatLng(latitud, longitud); /* Debo crear un punto geografico utilizando google.maps.LatLng */
                    //var marcador = new google.maps.Marker({position: coordenadas,map: mapita, animation: google.maps.Animation.DROP, title:"Un marcador cualquiera"});
                }); //Fin del evento
                /////////////////////



            }

            function actualizarCoordenadasProspecto(latitudProspecto, longitudProspecto, idProspectoActualizar) {
                if (idProspectoActualizar > 0) {
                    $.ajax({
                        type: "POST",
                        url: "../include/Mapa_ajax.jsp",
                        data: {mode: "2", latitudActualizada: latitudProspecto, longitudActualizada: longitudProspecto, idActualizar: idProspectoActualizar},
                        beforeSend: function (objeto) {
                            //$("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function (datos) {
                            if (datos.indexOf("--EXITO-->", 0) > 0) {
                                //$("#ajax_message").html(datos);
                                $("#ajax_loading").fadeOut("slow");
                                //$("#ajax_message").fadeIn("slow");
                                apprise('<center><img src=../../images/info.png> <br/>' + datos + '</center>', {'animate': true},
                                        function (r) {
                                            //location.href = "catEmpleados_list.jsp";
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
                }
            }

            function loadScript() {
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.src = 'https://maps.googleapis.com/maps/api/js?libraries=geometry,drawing&sensor=false&' +
                        'callback=initialize';
                document.body.appendChild(script);
            }

            window.onload = loadScript;


            /// Fin Mapa  

        </script>
    </head>
    <body>
        <div class="content_wrapper">

            <% if (!mode.equals("3")) {%>
            <jsp:include page="../include/header.jsp" flush="true"/>
            <jsp:include page="../include/leftContent.jsp"/>
            <%}%>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Ventas</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                        <div class="twocolumn">
                            <div class="column_left">
                                <div class="header">
                                    <span>
                                        <img src="../../images/icon_prospecto.png" alt="icon"/>
                                        <% if (prospectoDto != null) {%>
                                        Editar Prospecto ID <%=prospectoDto != null ? prospectoDto.getIdProspecto() : ""%>
                                        <%} else {%>
                                        Prospecto
                                        <%}%>
                                    </span>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                    <input type="hidden" id="idProspecto" name="idProspecto" value="<%=prospectoDto != null ? prospectoDto.getIdProspecto() : ""%>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
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
                                            String obligatorioVal = "";
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
                                            %>:</label>><br/>
                                        <input maxlength="200" type="text" id="razonSocial" name="razonSocial" style="width:300px"
                                               value="<%=prospectoDto != null ? prospectoBO.getProspecto().getRazonSocial() : ""%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="contacto" name="contacto" style="width:300px"
                                               value="<%=prospectoDto != null ? prospectoBO.getProspecto().getContacto() : ""%>"/>
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
                                            %>:</label>-
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
                                            %>:</label><br/>
                                        <input maxlength="3" type="text" id="lada" name="lada" style="width:25px"
                                               value="<%=prospectoDto != null ? prospectoBO.getProspecto().getLada() : ""%>"/> -
                                        <input maxlength="8" type="text" id="telefono" name="telefono" style="width:255px"
                                               value="<%=prospectoDto != null ? prospectoBO.getProspecto().getTelefono() : ""%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="11" type="text" id="celular" name="celular" style="width:300px"
                                               value="<%=prospectoDto != null ? prospectoBO.getProspecto().getCelular() : ""%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="email" name="email" style="width:300px"
                                               value="<%=prospectoDto != null ? prospectoBO.getProspecto().getCorreo() : ""%>"/>
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
                                            %>:</label><br/>
                                        <textarea rows="5" cols="35" id="descripcion" name="descripcion"><%=prospectoDto != null ? prospectoBO.getProspecto().getDescripcion() : ""%></textarea>
                                    </p>
                                    <br/>
                                    <p>
                                        <input type="checkbox" class="checkbox" <%=prospectoDto != null ? (prospectoDto.getIdEstatus() == 1 ? "checked" : "") : "checked"%> id="estatus" name="estatus" value="1"> <%
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
                                            %>:</label>
                                    </p>
                                    <br/>
                                    <br/>

                                    <% if (!mode.equals("3")) {%>
                                    <div id="action_buttons">
                                        <p>
                                            <input type="button" id="enviar" value="Guardar" onclick="grabar();"/>
                                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                        </p>
                                    </div>
                                    <%} else {
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

                            <div class="column_right">
                                <div class="header">
                                    <span>
                                        <img src="../../images/icon_prospecto.png" alt="icon"/>
                                        Imágenes del prospecto
                                    </span>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                    <% if (prospectoDto != null) { %>
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
                                            %>:</label>
                                        <br/>
                                        <% if (!StringManage.getValidString(prospectoDto.getNombreImagenProspecto()).equals("")) {%>
                                        <img src='showImageProspecto.jsp?image=<%=prospectoBO.getProspecto().getNombreImagenProspecto()%>' alt="Foto Prospecto">
                                        <% } else { %>
                                        <br/>
                                        <i>&lt;&lt; Sin imágen registrada &gt;&gt;</i>
                                        <% } %>
                                    </p>
                                    <%
                                        }
                                    %>
                                </div>
                            </div>
                            <br><br><br><br><br><br><br><br>

                            <div class="column_right">                            
                                <div class="header">
                                    <span>
                                        <img src="../../images/icon_mapa_1.png" alt="icon"/>
                                        Ubicación
                                    </span>
                                </div>
                                <div class="content">
                                    <div id="map_canvas" style="height: 230px; width: 100%">
                                        <img src="../../images/maps/ajax-loader.gif" alt="Cargando" style="margin: auto;"/>
                                    </div>     
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
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <div class="content" id="areaCamposAdicionalesProspecto">
                                    <%
                                        CampoAdicionalProspectoDAO capdao = new CampoAdicionalProspectoDAO();
                                        CampoAdicionalProspectoValorDAO capvdao = new CampoAdicionalProspectoValorDAO();
                                        List<CampoAdicionalProspecto> campos2 = capdao.lista(user.getUser().getIdUsuarios());
                                        for (CampoAdicionalProspecto campoAdicional : campos2) {
                                            CampoAdicionalProspectoValor capv = null;
                                            if (prospectoDto != null) {
                                                capv = capvdao.getByIdAndProspecto(campoAdicional.getIdCampoAdicionalProspecto(), prospectoDto.getIdProspecto());
                                            }
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
                                        %>:</label> <br/>
                                    <input maxlength="100" type="text" id="<%=campoAdicional.getEtiqueta().replace(" ", "")%>IdValor" name="<%=campoAdicional.getEtiqueta().replace(" ", "")%>" style="width:300px;"
                                           value="<%=capv != null ? capv.getValor() : ""%>"/><br/>
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