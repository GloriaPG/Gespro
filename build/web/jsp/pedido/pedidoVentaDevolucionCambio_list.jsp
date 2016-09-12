<%-- 
    Document   : pedidoVentaDevolucionCambio_list
    Created on : 26/06/2015, 10:54:35 AM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.bo.SGPedidoBO"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.jdbc.SgfensPedidoDaoImpl"%>
<%@page import="com.tsp.gespro.dto.SgfensPedido"%>
<%@page import="com.tsp.gespro.report.ReportBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    int idEmpresa = user.getUser().getIdEmpresa();
    
    String buscar_folio = request.getParameter("q_folio")!=null? new String(request.getParameter("q_folio").getBytes("ISO-8859-1"),"UTF-8") :"";
    String buscar_idcliente = request.getParameter("q_idcliente")!=null?request.getParameter("q_idcliente"):"";
    String buscar_idestatus = request.getParameter("q_idestatus")!=null?request.getParameter("q_idestatus"):"";
    
    String parametrosPaginacion="q_folio="+buscar_folio+"&q_idcliente="+buscar_idcliente+"&q_idestatus="+buscar_idestatus;
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
            function mostrarCalendario(){
                //fh_min
                //fh_max

                var dates = $('#q_fh_min, #q_fh_max').datepicker({
                        //minDate: 0,
			changeMonth: true,
			//numberOfMonths: 2,
                        //beforeShow: function() {$('#fh_min').css("z-index", 9999); },
                        beforeShow: function(input, datepicker) {
                            setTimeout(function() {
                                    $(datepicker.dpDiv).css('zIndex', 998);
                            }, 500)},
			onSelect: function( selectedDate ) {
				var option = this.id == "q_fh_min" ? "minDate" : "maxDate",
					instance = $( this ).data( "datepicker" ),
					date = $.datepicker.parseDate(
						instance.settings.dateFormat ||
						$.datepicker._defaults.dateFormat,
						selectedDate, instance.settings );
				dates.not( this ).datepicker( "option", option, date );
			}
		});

            }
            
            function escondeDivCambDevo(){                
                document.getElementById("divPedVentDevCamb").style.display="none";
            }
        </script>
    </head>
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Ventas</h1>
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <div class=twocolumn>
                      <div class="column_left">
                        <div class="header">
                            <span>
                                Búsqueda Avanzada &dArr;
                            </span>
                        </div>
                        <br class="clear"/>
                        <div class="content" style="display: none;">
                            <form action="pedidoVentaDevolucionCambio_list.jsp" id="search_form_advance" name="search_form_advance" method="post">
                                <!--<p>
                                    Por Fecha de Emision <br/>
                                    <label>Desde:</label>
                                    <input maxlength="15" type="text" id="q_fh_min" name="q_fh_min" style="width:100px"
                                            value="" readonly/>
                                    &nbsp; &laquo; &mdash; &raquo; &nbsp;
                                    <label>Hasta:</label>
                                    <input maxlength="15" type="text" id="q_fh_max" name="q_fh_max" style="width:100px"
                                        value="" readonly/>
                                </p>-->
                                <br/>
                                
                                <p>
                                    <label>Folio:</label>
                                    <input type="text" style="width: 100px;" id="q_folio" name="q_folio"/>
                                </p>
                                <br/>
                                
                                <p>
                                <label>Cliente:</label><br/>
                                <select id="q_idcliente" name="q_idcliente" class="flexselect" style="width: 300px;">
                                    <option></option>
                                    <%= new ClienteBO(user.getConn()).getClientesByIdHTMLCombo(idEmpresa, -1," AND ID_ESTATUS=1 " ) %>
                                </select>
                                </p>
                                <br/>
                                                                
                                <p>
                                <label>Tipo:</label><br/>
                                <select id="q_idestatus" name="q_idestatus">
                                    <option></option>
                                    <option value="1">Venta Pendiente Entrega</option>
                                    <option value="2">Venta Entregada</option>
                                    <option value="3">Venta Cancelada</option>
                                    <option value="4">Venta Entregada Parcial</option>
                                    
                                    <option value="5">Devolución</option>
                                    <option value="6">Cambio</option>                                    
                                </select>
                                </p>
                                <br/>
                                
                                <br/>
                                <div id="action_buttons">
                                    <p>
                                        <input type="button" id="buscar" value="Buscar" onclick="$('#search_form_advance').submit();"/>
                                    </p>
                                </div>
                                
                            </form>
                        </div>
                      </div>
                      
                    </div>                   
                    <br class="clear"/>
                    
                    <!-- Facturas -->
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_ventas3.png" alt="icon"/>
                                Pedidos
                            </span>                            
                        </div>
                        <br class="clear"/>
                        <div class="content">
                            <iframe id="frame_pedidos" src="pedidoVentaDevolucionCambio_pedido_list.jsp?<%= parametrosPaginacion %>" 
                                    height="300" width="100%" 
                                    style="border:0;">        
                                <p>Tu navegador no acepta el uso de iframes.</p>
                            </iframe>
                        </div>
                    </div>
                    <!-- Fin Facturas-->
                    
                    <!-- Pedidos -->
                    <div class="onecolumn" id="divPedVentDevCamb" style="display: block">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_devCam.png" alt="icon"/>
                                Cambios y Devoluciones
                            </span>                            
                        </div>
                        <br class="clear"/>
                        <div class="content">
                            <iframe id="frame_cambDevol" src="pedidoVentaDevolucionCambio_devolucionCambio_list.jsp?<%= parametrosPaginacion %>" 
                                    height="300" width="100%" 
                                    style="border:0;">        
                                <p>Tu navegador no acepta el uso de iframes.</p>
                            </iframe>
                        </div>
                    </div>
                    <!-- Fin Pedidos-->
                    
                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>

        <script>
            mostrarCalendario();
            $("select.flexselect").flexselect();
        </script>
    </body>
</html>
<%}%>