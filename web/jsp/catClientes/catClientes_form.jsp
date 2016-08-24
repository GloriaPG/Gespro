<%-- 
    Document   : catClientes_form.jsp
    Created on : 26-oct-2012, 12:13:49
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalClienteValor"%>
<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalClienteValorDAO"%>
<%@page import="java.util.List"%>
<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalCliente"%>
<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalClienteDAO"%>
<%@page import="com.tsp.gespro.hibernate.dao.EtiquetaFormularioClienteDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.EtiquetaFormularioCliente"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.tsp.gespro.jdbc.ProspectoDaoImpl"%>
<%@page import="com.tsp.gespro.bo.ProspectoBO"%>
<%@page import="com.tsp.gespro.dto.Prospecto"%>
<%@page import="com.tsp.gespro.jdbc.RelacionClienteVendedorDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionClienteVendedor"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.ClienteCategoria"%>
<%@page import="com.tsp.gespro.bo.ClienteCategoriaBO"%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.PasswordBO"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.jdbc.ClienteDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<jsp:useBean id="helperEtiquetaCliente" class="com.tsp.gespro.hibernate.dao.EtiquetaFormularioClienteDAO"/>

<%
//Verifica si el cliente tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {
        HashMap<String, EtiquetaFormularioCliente> camposCliente = helperEtiquetaCliente.getMap(user.getUser().getIdUsuarios());
        int paginaActual = 1;
        try {
            paginaActual = Integer.parseInt(request.getParameter("pagina"));
        } catch (Exception e) {
        }

        int idEmpresa = user.getUser().getIdEmpresa();

        /*
         * Parámetros
         */
        int idCliente = 0;
        try {
            idCliente = Integer.parseInt(request.getParameter("idCliente"));
        } catch (NumberFormatException e) {
        }

        int idProspecto = -1;
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

        String lunes = "";
        String martes = "";
        String miercoles = "";
        String jueves = "";
        String viernes = "";
        String sabado = "";
        String domingo = "";
        String todos = "";

        ClienteBO clienteBO = new ClienteBO(user.getConn());
        Cliente clientesDto = null;
        if (idCliente > 0) {
            clienteBO = new ClienteBO(idCliente, user.getConn());
            clientesDto = clienteBO.getCliente();
            /*
            StringTokenizer tokensDias = new StringTokenizer(StringManage.getValidString(clientesDto.getDiasVisita()),",");
            String seleccion = "";
            while (tokensDias.hasMoreTokens()) {
                System.out.println("_______recupetando tokens");
                seleccion = "";
                seleccion = tokensDias.nextToken().intern().trim();
                if(seleccion.equals("DOM")){
                    domingo = seleccion;                
                }else if(seleccion.equals("LUN")){
                    lunes = seleccion;
                }else if(seleccion.equals("MAR")){
                    martes = seleccion;
                }else if(seleccion.equals("MIE")){
                    miercoles = seleccion;
                }else if(seleccion.equals("JUE")){
                    jueves = seleccion;
                }else if(seleccion.equals("VIE")){
                    viernes = seleccion;
                }else if(seleccion.equals("SAB")){
                    sabado = seleccion;
                }else if(seleccion.equals("8")){
                    todos = seleccion;
                }
            } 
             */
        } else {
            newRandomPass = new PasswordBO().generateValidPassword();
        }

        /*        RelacionClienteVendedor clienteVendedorDto = null;
        if (clientesDto!=null){
            try{clienteVendedorDto = new RelacionClienteVendedorDaoImpl(user.getConn()).findByPrimaryKey(idCliente);}catch(Exception e){}
        }
         */
        String calleProspecto = "";
        String ciudadProspecto = "";
        String estadoProspecto = "";
        String paisProspecto = "";

        Prospecto prospectoDto = null;
        if (idProspecto > 0) {
            prospectoDto = new ProspectoBO(idProspecto, user.getConn()).getProspecto();
            try {
                prospectoDto.setIdEstatus(2); //Deshabilitado
                new ProspectoDaoImpl(user.getConn()).update(prospectoDto.createPk(), prospectoDto);
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            //REPARAMOS LOS DATOS DE LA DIRECCION:
            if (prospectoDto.getDireccion() != null && !prospectoDto.getDireccion().equals("No registrada")) {//validamos que tenga registrada una dirección
                StringTokenizer tokens = new StringTokenizer(prospectoDto.getDireccion(), ",");
                try {//si existen los 4 tokens se recuperara la información completa (info recuperada automáticamente por e movil).
                    calleProspecto = tokens.nextToken().intern();
                    ciudadProspecto = tokens.nextToken().intern();
                    estadoProspecto = tokens.nextToken().intern();
                    paisProspecto = tokens.nextToken().intern();
                } catch (Exception e) {
                }

            }
        }

        ClienteCategoriaBO clienteCategoriaBO = new ClienteCategoriaBO(user.getConn());
        ClienteCategoria[] clientesCategorias = clienteCategoriaBO.findClienteCategorias(0, idEmpresa, 0, 0, " AND ID_ESTATUS = 1 ");

        //campos adicionales:
        /*ClienteCampoAdicional[] clienteCampoAdicionalsDto = new ClienteCampoAdicional[0];
        ClienteCampoAdicionalBO clienteCampoAdicionalBO = new ClienteCampoAdicionalBO(user.getConn());
        try{
            clienteCampoAdicionalsDto = clienteCampoAdicionalBO.findClienteCampoAdicionals(0, idEmpresa , 0, 0, " AND ID_ESTATUS = 1 ");            
        }catch(Exception e){}
         */
        EmpresaBO empresaBO = new EmpresaBO(user.getConn());
        EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());

        String verificadorSesionGuiaCerrada = "0";
        String cssDatosObligatorios = "border:3px solid red;";//variable para colocar el css del recuadro que encierra al input para la guia interactiva
        try {
            if (session.getAttribute("sesionCerrada") != null) {
                verificadorSesionGuiaCerrada = (String) session.getAttribute("sesionCerrada");
            }
        } catch (Exception e) {
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
                    var adicionalesClienteValidacion = [];
                    $('#areaCamposAdicionalesCliente *[id*=HiddenAdicional]:hidden').each(function () {
                        var etiqueta = $(this).val();
                        if (etiqueta != "") {
                            var tipo = $("#" + etiqueta.replace(" ", "") + "TipoAdicional").val()
                            var obligatorio = $("#" + etiqueta.replace(" ", "") + "ObligatorioAdicional").val();
                            var idAdicional = $("#" + etiqueta.replace(" ", "") + "IdAdicional").val();
                            var valorAdicional = $("#" + etiqueta.replace(" ", "") + "IdValor").val();
                            var idCliente = $("#idCliente").val()?$("#idCliente").val():0;
                            var adicionalCliente = {idAdicional: idAdicional, idCliente: idCliente, etiqueta: etiqueta, obligatorio: obligatorio, tipo: tipo, valor: valorAdicional};
                            adicionalesClienteValidacion.push(adicionalCliente);
                        }
                    });
                    $.ajax({
                        type: "POST",
                        url: "ajaxValidaciones.jsp",
                        data: JSON.stringify(adicionalesClienteValidacion),
                        success: function (datos) {
                            if (datos.indexOf("--EXITO-->", 0) > 0) {
                                $.ajax({
                                    type: "POST",
                                    url: "catClientes_ajax.jsp",
                                    data: $("#frm_action").serialize(),
                                    success: function (datos) {
                                        if (datos.indexOf("--EXITO-->", 0) > 0) {
                                            var partes = [];
                                            partes = datos.split(":");
                                            var adicionalesCliente = [];
                                            $('#areaCamposAdicionalesCliente *[id*=HiddenAdicional]:hidden').each(function () {
                                                var etiqueta = $(this).val();
                                                if (etiqueta != "") {
                                                    var tipo = $("#" + etiqueta.replace(" ", "") + "TipoAdicional").val()
                                                    var obligatorio = $("#" + etiqueta.replace(" ", "") + "ObligatorioAdicional").val();
                                                    var idAdicional = $("#" + etiqueta.replace(" ", "") + "IdAdicional").val();
                                                    var valorAdicional = $("#" + etiqueta.replace(" ", "") + "IdValor").val();
                                                    var idCliente = partes.length > 1 ? partes[1] : $("#idCliente").val();
                                                    var adicionalCliente = {idAdicional: idAdicional, idCliente: idCliente, etiqueta: etiqueta, obligatorio: obligatorio, tipo: tipo, valor: valorAdicional};
                                                    adicionalesCliente.push(adicionalCliente);
                                                }
                                            });
                                            $.ajax({
                                                type: "POST",
                                                url: "ajaxAdicionalesCliente.jsp",
                                                data: JSON.stringify(adicionalesCliente),
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
                                                                    location.href = "catClientes_list.jsp?pagina=" + "<%=paginaActual%>";
            <%} else {%>
                                                                    parent.recargarSelectClientes();
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

            function grabarExpress() {
                $.ajax({
                    type: "POST",
                    url: "catClientes_ajax.jsp?mode=express",
                    data: $("#frm_action").serialize(),
                    beforeSend: function (objeto) {
                        $("#action_buttons").fadeOut("slow");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function (datos) {
                        if (datos.indexOf("--EXITO-->", 0) > 0) {
                            $("#ajax_message").html(datos);
                            $("#ajax_loading").fadeOut("slow");
                            $("#ajax_message").fadeIn("slow");
                            apprise('<center><img src=../../images/info.png> <br/>' + datos + '</center>', {'animate': true},
                                    function (r) {
            <% if (!mode.equals("3")) {%>
                                        location.href = "catClientes_list.jsp";
            <%} else {%>
                                        parent.recargarSelectClientes();
                                        parent.$.fancybox.close();
            <%}%>

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

            function diasMarcado() {
                if ($('#domingoReporte').attr('checked') && $('#lunesReporte').attr('checked') && $('#martesReporte').attr('checked') && $('#miercolesReporte').attr('checked') && $('#juevesReporte').attr('checked') && $('#viernesReporte').attr('checked') && $('#sabadoReporte').attr('checked'))
                    $('#diarioReporte').attr('checked', true);
                else
                    $('#diarioReporte').attr('checked', false);
            }

            function todosDiasMarcados() {
                if ($('#diarioReporte').attr('checked')) {
                    //como esta marcado, desmarcamos todos los demas                
                    $('#domingoReporte').attr('checked', true);
                    $('#lunesReporte').attr('checked', true);
                    $('#martesReporte').attr('checked', true);
                    $('#miercolesReporte').attr('checked', true);
                    $('#juevesReporte').attr('checked', true);
                    $('#viernesReporte').attr('checked', true);
                    $('#sabadoReporte').attr('checked', true);
                } else {
                    //como esta marcado, desmarcamos todos los demas                
                    $('#domingoReporte').attr('checked', false);
                    $('#lunesReporte').attr('checked', false);
                    $('#martesReporte').attr('checked', false);
                    $('#miercolesReporte').attr('checked', false);
                    $('#juevesReporte').attr('checked', false);
                    $('#viernesReporte').attr('checked', false);
                    $('#sabadoReporte').attr('checked', false);
                }
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

                <div class="inner">
                    <h1>Catálogos</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                        <div class="twocolumn">
                            <div class="column_left">
                                <div class="header">
                                    <span>
                                        <img src="../../images/icon_cliente.png" alt="icon"/>
                                        <% if (clientesDto != null) {%>
                                        Editar Cliente ID <%=clientesDto != null ? clientesDto.getIdCliente() : ""%>
                                        <%} else {%>
                                        Cliente
                                        <%}%>
                                    </span>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                    <input type="hidden" id="idCliente" name="idCliente" value="<%=clientesDto != null ? clientesDto.getIdCliente() : ""%>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />


                                    <input type="hidden" id="latitud" name="latitud" value="<%=clientesDto != null ? clientesDto.getLatitud() : (prospectoDto != null ? prospectoDto.getLatitud() : 0)%>" />
                                    <input type="hidden" id="longitud" name="longitud" value="<%=clientesDto != null ? clientesDto.getLongitud() : (prospectoDto != null ? prospectoDto.getLongitud() : 0)%>" />

                                    <p>
                                        <%                                                                EtiquetaFormularioCliente nombreComercial = camposCliente.get(EtiquetaFormularioClienteDAO.NOMBRE_COMERCIAL);
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
                                            %>:</label><br/>
                                        <input maxlength="200" type="text" id="nombreComercial" name="nombreComercial" style="width:300px;"
                                               value="<%= clientesDto != null ? clienteBO.getCliente().getNombreComercial() : (prospectoDto != null ? prospectoDto.getRazonSocial() : "")%>"/>
                                    </p>
                                    <br/>
                                    <%if (clientesCategorias.length > 0) {%>
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
                                            %>:</label><br/>
                                        <select id="idClienteCategoria" name="idClienteCategoria">
                                            <option value="0">Selecciona Tipo de Categoría</option>
                                            <%
                                                out.print(clienteCategoriaBO.getClienteCategoriasByIdHTMLCombo(idEmpresa, (clientesDto != null ? clientesDto.getIdCategoria() : -1)));
                                            %>
                                        </select>
                                    </p>
                                    <br/>
                                    <%}%>

                                    <!--<p>
                                        <label>Clave:</label><br/>
                                        <input maxlength="40" type="text" id="claveCliente" name="claveCliente" style="width:300px"
                                               value="<//%=clientesDto!=null?clienteBO.getCliente().getClave():"" %>"/>
                                    </p>
                                    <br/>-->                                    


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
                                            %>:</label><br/>                                       
                                        <input maxlength="8" type="text" id="telefono" name="telefono" style="width:255px"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getTelefono() : (prospectoDto != null ? prospectoDto.getTelefono() : "")%>"
                                               onkeypress="return validateNumber(event);"/>
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
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="email" name="email" style="width:300px"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getCorreo() : (prospectoDto != null ? prospectoDto.getCorreo() : "")%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="contacto" name="contacto" style="width:300px"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getContacto() : (prospectoDto != null ? prospectoDto.getContacto() : "")%>"/>
                                    </p>
                                    <br/>
                                    <!--<p>
                                        <label>Promotor :</label><br/>
                                        <select id="idVendedor" name="idVendedor">
                                            <option value="-1">Selecciona promotor...</option>
                                    <%
                                        /*    UsuariosBO usuariosBO = new UsuariosBO();
                                        out.print(usuariosBO.getUsuariosByRolHTMLCombo(idEmpresa, RolesBO.ROL_GESPRO, clienteVendedorDto!=null?clienteVendedorDto.getIdUsuario():(prospectoDto!=null?prospectoDto.getIdUsuarioVendedor():0)));                                                
                                         */%>
                                </select>
                            </p>
                            <br/>-->

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
                                            %>:</label><br/>
                                        <select size="1" id="idSucursalEmpresaAsignado" name="idSucursalEmpresaAsignado">
                                            <option value="-1">Selecciona una Sucursal</option>
                                            <%
                                                out.print(new EmpresaBO(user.getConn()).getEmpresasByIdHTMLCombo(idEmpresa, (clientesDto != null ? clientesDto.getIdEmpresa() : -1)));
                                            %>
                                        </select>                                        
                                    </p>  
                                    <br/>

                                    <p>
                                        <input type="checkbox" class="checkbox" <%=clientesDto != null ? (clientesDto.getIdEstatus() == 1 ? "checked" : "") : "checked"%> id="estatus" name="estatus" value="1"> <%
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
                                            %>:</label>
                                    </p>
                                    <br/><br/>

                                    <% if (!mode.equals("3")) {%>
                                    <div id="action_buttons">
                                        <p>
                                            <input type="button" id="enviar" value="Guardar" onclick="grabar();"/>
                                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>

                                            <!--<input type="button" id="enviar" value="Guardar como Express" onclick="grabarExpress();" title="Puede permitir el guardar al cliente con solo tener nombre/razon social"/>-->

                                            <%if (clientesDto != null) {%>
                                            <input type="button" src="../../images/icon_movimiento.png" value="Asignar Ubicación" onclick="window.location.href = 'catClientes_formMapa.jsp?idCliente=' +<%=clientesDto != null ? clientesDto.getIdCliente() : ""%> + '&acc=Mapa'">
                                            <%}%>
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
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="calle" name="calle" style="width:300px;"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getCalle() : (prospectoDto != null ? calleProspecto : "")%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="30" type="text" id="numero" name="numero" style="width:300px;"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getNumero() : (prospectoDto != null ? prospectoDto.getDirNumeroExterior() : "")%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="30" type="text" id="numeroInt" name="numeroInt" style="width:300px"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getNumeroInterior() : (prospectoDto != null ? prospectoDto.getDirNumeroInterior() : "")%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="colonia" name="colonia" style="width:300px;"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getColonia() : (prospectoDto != null ? prospectoDto.getDirColonia() : "")%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="5" type="text" id="cp" name="cp" style="width:300px;"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getCodigoPostal() : (prospectoDto != null ? prospectoDto.getDirCodigoPostal() : "")%>"
                                               onkeypress="return validateNumber(event);"/>
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
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="municipio" name="municipio" style="width:300px;"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getMunicipio() : (prospectoDto != null ? prospectoDto.getDirColonia() : "")%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="estado" name="estado" style="width:300px;"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getEstado() : (prospectoDto != null ? estadoProspecto : "")%>"/>
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
                                            %>:</label><br/>
                                        <input maxlength="100" type="text" id="pais" name="pais" style="width:300px;"
                                               value="<%=clientesDto != null ? clienteBO.getCliente().getPais() : (prospectoDto != null ? paisProspecto : "México")%>"/>                                        
                                    </p>
                                    <br/>


                                    <br/>
                                    <!--<p>
                                        <label>Días de Visita:</label><br/>
                                        <input type="checkbox" class="checkbox" <%=clientesDto != null ? (domingo.equals("DOM") ? "checked" : "") : ""%> id="domingoReporte" name="domingoReporte" value="DOM" onclick="diasMarcado();"> <label for="domingoReporte">Domingo</label>
                                        &nbsp;&nbsp;&nbsp;
                                        <input type="checkbox" class="checkbox" <%=clientesDto != null ? (lunes.equals("LUN") ? "checked" : "") : ""%> id="lunesReporte" name="lunesReporte" value="LUN" onclick="diasMarcado();"> <label for="lunesReporte">Lunes</label>
                                        &nbsp;&nbsp;&nbsp;
                                        <input type="checkbox" class="checkbox" <%=clientesDto != null ? (martes.equals("MAR") ? "checked" : "") : ""%> id="martesReporte" name="martesReporte" value="MAR" onclick="diasMarcado();"> <label for="martesReporte">Martes</label>
                                        &nbsp;&nbsp;&nbsp;
                                        <input type="checkbox" class="checkbox" <%=clientesDto != null ? (miercoles.equals("MIE") ? "checked" : "") : ""%> id="miercolesReporte" name="miercolesReporte" value="MIE" onclick="diasMarcado();"> <label for="miercolesReporte">Miércoles</label>
                                        &nbsp;&nbsp;&nbsp;
                                    </p>
                                    <p>
                                        <input type="checkbox" class="checkbox" <%=clientesDto != null ? (jueves.equals("JUE") ? "checked" : "") : ""%> id="juevesReporte" name="juevesReporte" value="JUE" onclick="diasMarcado();"> <label for="juevesReporte">Jueves</label>
                                        &nbsp;&nbsp;&nbsp;
                                        <input type="checkbox" class="checkbox" <%=clientesDto != null ? (viernes.equals("VIE") ? "checked" : "") : ""%> id="viernesReporte" name="viernesReporte" value="VIE" onclick="diasMarcado();"> <label for="viernesReporte">Viernes</label>
                                        &nbsp;&nbsp;&nbsp;
                                        <input type="checkbox" class="checkbox" <%=clientesDto != null ? (sabado.equals("SAB") ? "checked" : "") : ""%> id="sabadoReporte" name="sabadoReporte" value="SAB" onclick="diasMarcado();"> <label for="sabadoReporte">Sábado</label>
                                        &nbsp;&nbsp;&nbsp;
                                        <input type="checkbox" class="checkbox" id="diarioReporte" name="diarioReporte" value="8" onclick="todosDiasMarcados();"> <label for="diarioReporte">Marcar Todos</label>
                                    </p>
                                    <br/>-->
                                    <!--<p>
                                        <label>Periodo:</label><br/>
                                        <input maxlength="30" type="text" id="periodo" name="periodo" style="width:300px"
                                               value="<//%=clientesDto!=null?clienteBO.getCliente().getPerioricidad():"" %>" onkeypress="return validateNumber(event);" /> Semanas
                                    </p>
                                    <br/>-->                                                                       
                                    <input type="hidden" id="latitud" name="latitud" value="<%=clientesDto != null ? clienteBO.getCliente().getLatitud() : "0"%>/>"
                                           <input type="hidden" id="longitud" name="longitud" value="<%=clientesDto != null ? clienteBO.getCliente().getLongitud() : "0"%>"/>
                                    <br/>


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
                                <div class="content" id="areaCamposAdicionalesCliente">
                                    <%
                                        CampoAdicionalClienteDAO cacdao = new CampoAdicionalClienteDAO();
                                        CampoAdicionalClienteValorDAO cacvdao = new CampoAdicionalClienteValorDAO();
                                        List<CampoAdicionalCliente> campos = cacdao.lista(user.getUser().getIdUsuarios());

                                        for (CampoAdicionalCliente campoAdicional : campos) {
                                            CampoAdicionalClienteValor cacv = null;
                                            if (clientesDto != null) {
                                                cacv = cacvdao.getByIdAndCliente(campoAdicional.getIdCampoAdicionalCliente(), clientesDto.getIdCliente());
                                            }

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
                                        %>:</label> <br/>
                                    <input maxlength="100" type="text" id="<%=campoAdicional.getEtiqueta().replace(" ", "")%>IdValor" name="<%=campoAdicional.getEtiqueta().replace(" ", "")%>" style="width:300px;"
                                           value="<%=cacv != null ? cacv.getValor() : ""%>"/><br/>
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