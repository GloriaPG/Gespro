<%-- 
    Document   : catConceptoEstanteria_form
    Created on : 30/10/2015, 06:16:03 PM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.util.FormatUtil"%>
<%@page import="com.tsp.gespro.bo.CompetenciaBO"%>
<%@page import="com.tsp.gespro.dto.Competencia"%>
<%@page import="com.tsp.gespro.bo.EstanteriaDescripcionBO"%>
<%@page import="com.tsp.gespro.dto.EstanteriaDescripcion"%>
<%@page import="com.tsp.gespro.dto.Concepto"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.EstanteriaBO"%>
<%@page import="com.tsp.gespro.jdbc.EstanteriaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Estanteria"%>
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
        int idEstanteria = 0;
        try {
            idEstanteria = Integer.parseInt(request.getParameter("idEstanteria"));
        } catch (NumberFormatException e) {
        }
        
        int idCliente = -1;
        try{ idCliente = Integer.parseInt(request.getParameter("idCliente")); }catch(NumberFormatException e){}
        int idConcepto = -1;
        try{ idConcepto = Integer.parseInt(request.getParameter("idConcepto")); }catch(NumberFormatException e){}
        int idUsuario = -1;//id del usuario promotor
        try{ idUsuario = Integer.parseInt(request.getParameter("idUsuario")); }catch(NumberFormatException e){}

        Empresa empresaDto = new EmpresaBO(user.getConn()).getEmpresaMatriz(user.getUser().getIdEmpresa());
        String rfcEmpresaMatriz = empresaDto.getRfc();
        
        String buscar_fechamin = "";
        String buscar_fechamax = "";
        Date fechaMin=null;
        Date fechaMax=null;
        String strWhereRangoFechas="";
        String filtroBusqueda = "";
        String parametrosPaginacion = "";

        {
            try{
                fechaMin = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("q_fh_min"));
                buscar_fechamin = DateManage.formatDateToSQL(fechaMin);
            }catch(Exception e){}
            try{
                fechaMax = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("q_fh_max"));
                buscar_fechamax = DateManage.formatDateToSQL(fechaMax);
            }catch(Exception e){}

            /*Filtro por rango de fechas*/
            if (fechaMin!=null && fechaMax!=null){
                strWhereRangoFechas="(CAST(FECHA_HORA AS DATE) BETWEEN '"+buscar_fechamin+"' AND '"+buscar_fechamax+"')";
                if(!parametrosPaginacion.equals(""))
                        parametrosPaginacion+="&";
                parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax)+"&q_fh_min="+DateManage.formatDateToNormal(fechaMin);
            }
            if (fechaMin!=null && fechaMax==null){
                strWhereRangoFechas="(FECHA_HORA  >= '"+buscar_fechamin+"')";
                if(!parametrosPaginacion.equals(""))
                        parametrosPaginacion+="&";
                parametrosPaginacion+="q_fh_min="+DateManage.formatDateToNormal(fechaMin);
            }
            if (fechaMin==null && fechaMax!=null){
                strWhereRangoFechas="(FECHA_HORA  <= '"+buscar_fechamax+" 23:59:59')";
                if(!parametrosPaginacion.equals(""))
                        parametrosPaginacion+="&";
                parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax);
            }
        }
        if (!strWhereRangoFechas.trim().equals("")){
            filtroBusqueda += " AND " + strWhereRangoFechas;
        }/*else{//si el filtro por fecha es vacio entonces recuperamos solo la fotos de hasta 72 horas:
            Calendar c = Calendar.getInstance();
            c.add(Calendar.DATE, -2);//lo enviamos como día de ante ayer
            Date date = c.getTime(); //dia de ante ayer
            filtroBusqueda += " AND " + " (CAST(FECHA_HORA AS DATE) BETWEEN '"+DateManage.formatDateToSQL(date)+"' AND '"+DateManage.formatDateToSQL(new Date())+"') ";                     
        }*/
        
        /*int planoEntrada = -1;
        try{ planoEntrada = Integer.parseInt(request.getParameter("planoEntrada")); }catch(NumberFormatException e){}
        int planoSalida = -1;
        try{ planoSalida = Integer.parseInt(request.getParameter("planoSalida")); }catch(NumberFormatException e){}
        int pop = -1;
        try{ pop = Integer.parseInt(request.getParameter("pop")); }catch(NumberFormatException e){}
        int competencia = -1;
        try{ competencia = Integer.parseInt(request.getParameter("competencia")); }catch(NumberFormatException e){}
        int premios = -1;
        try{ premios = Integer.parseInt(request.getParameter("premios")); }catch(NumberFormatException e){}
        
        String filtroTipoFoto = "";
        
        if(planoEntrada > 0){
           filtroTipoFoto += " ID_TIPO_FOTO = 1 ";
        }
        if(planoSalida > 0){
            if(!filtroTipoFoto.trim().equals(""))
                filtroTipoFoto += " OR ";
            filtroTipoFoto += " ID_TIPO_FOTO = 2 ";
        }
        if(pop > 0){
            if(!filtroTipoFoto.trim().equals(""))
                filtroTipoFoto += " OR ";        
            filtroTipoFoto += " ID_TIPO_FOTO = 3 ";
        }
        if(competencia > 0){
            if(!filtroTipoFoto.trim().equals(""))
                filtroTipoFoto += " OR ";
            filtroTipoFoto += " ID_TIPO_FOTO = 4 ";
        }
        if(premios > 0){
           if(!filtroTipoFoto.trim().equals(""))
                filtroTipoFoto += " OR ";
           filtroTipoFoto += " ID_TIPO_FOTO = 5 ";
        }
        
        if (!filtroTipoFoto.trim().equals("")){
            filtroBusqueda += " AND ( " + filtroTipoFoto + ") ";
        }*/
           
        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
                
        EstanteriaBO estanteriaBO = new EstanteriaBO(user.getConn());
        Estanteria estanteriasDto = null;
        if (idEstanteria > 0){
            estanteriaBO = new EstanteriaBO(idEstanteria,user.getConn());
            estanteriasDto = estanteriaBO.getEstanteria();
        }
        
        EstanteriaDescripcionBO estanteriaDescripcionBO = new EstanteriaDescripcionBO(user.getConn());
        EstanteriaDescripcion[] estanteriasDescripcionDto = new EstanteriaDescripcion[0];
        try{
            estanteriasDescripcionDto = estanteriaDescripcionBO.findEstanteriaDescripcions(0, idEstanteria, 0, 0, 0, filtroBusqueda);
        }catch(Exception ex){
            ex.printStackTrace();
        }  
        
        Concepto concepto = null;
        try{
            concepto = new ConceptoBO(idConcepto, user.getConn()).getConcepto();
        }catch(Exception e){}
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
                if(validar()){
                    $.ajax({
                        type: "POST",
                        url: "catEstanteria_ajax.jsp",
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
                                            location.href = "catEstanteria_list.jsp?pagina="+"<%=paginaActual%>";
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
            
        </script>
    </head>
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Pop</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                Búsqueda Avanzada &dArr;
                            </span>
                        </div>
                        <br class="clear"/>
                        <div class="content" style="display: none;">
                            <form action="catEstanteria_form.jsp" id="search_form_advance" name="search_form_advance" method="post">
                                <p>
                                    Por Fecha de Periodo &raquo;&nbsp;&nbsp;
                                    <label>Desde:</label>
                                    <input maxlength="15" type="text" id="q_fh_min" name="q_fh_min" style="width:100px"
                                            value="" readonly/>
                                    &nbsp; &laquo; &mdash; &raquo; &nbsp;
                                    <label>Hasta:</label>
                                    <input maxlength="15" type="text" id="q_fh_max" name="q_fh_max" style="width:100px"
                                        value="" readonly/>
                                </p>
                                <br/>
                                
                                <!--<p>
                                <label>Cliente:</label><br/>
                                <select id="q_idcliente" name="q_idcliente" class="flexselect">
                                    <option></option>
                                    </%= new ClienteBO(user.getConn()).getClientesByIdHTMLCombo(idEmpresa, -1," AND ID_ESTATUS <> 2 " +  ) %>
                                </select>
                                </p>
                                <br/>-->                                
                                
                                <p>
                                <label>Promotor:</label><br/>
                                <select id="idUsuario" name="idUsuario" class="flexselect">
                                    <option></option>
                                    <%= new UsuariosBO().getUsuariosByRolHTMLCombo(idEmpresa, RolesBO.ROL_GESPRO, 0) %>
                                </select>
                                </p>
                                <br/>
                                
                                <p>
                                <input type="checkbox" class="checkbox" id="planoEntrada" name="planoEntrada" value="1"> <label for="planoEntrada">Foto planograma de entrada</label>
                                </p><p>
                                <input type="checkbox" class="checkbox" id="planoSalida" name="planoSalida" value="2"> <label for="planoSalida">Foto planograma de salida</label>
                                </p><p>
                                <input type="checkbox" class="checkbox" id="pop" name="pop" value="3"> <label for="pop">Foto pop (material promocional)</label>
                                </p><p>
                                <input type="checkbox" class="checkbox" id="competencia" name="competencia" value="4"> <label for="competencia">Foto competencia</label> 
                                </p><p>
                                <input type="checkbox" class="checkbox" id="premios" name="premios" value="5"> <label for="premios">Foto give ways (premios)</label>                                    
                                </p>    
                                <br/>
                                
                                <div id="action_buttons">
                                    <p>
                                        <input type="button" id="buscar" value="Buscar" onclick="$('#search_form_advance').submit();"/>
                                    </p>
                                </div>
                                
                            </form>
                        </div>
                    </div>
                    
                    
                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="onecolumn">
                        <div>                            
                            <div class="header">
                                <center>
                                    <span style="float: inherit;">
                                        <img src="../../images/icon_estanteria.png" alt="icon"/>
                                    <% if(estanteriasDescripcionDto!=null){%>
                                    <%=estanteriasDescripcionDto!=null?concepto.getNombre() + " " + DateManage.formatDateToNormal(estanteriasDto.getFecha()):"" %>
                                    <%}else{%>
                                    
                                    <%}%>
                                </span>
                                </center>
                            </div>                            
                            <br class="clear"/>
                            <table class="data" width="100%" cellpadding="0" cellspacing="0">
                                                <!--<div class="header">
                                                    <span>
                                                        <img src="../../images/icon_prospecto.png" alt="icon"/>
                                                        Imágenes del producto
                                                    </span>
                                                </div>-->


                                <%if(estanteriasDescripcionDto != null){
                                    //OBTENEMOS LOS PORCENTAJES Y PROMEDIOS
                                    double participacionAnaquel = 0;
                                    double diferenciaPrecio = 0;
                                    double precioPromedio = 0;
                                    double productosCompetencia = 0;
                                    int numeroCompetidores = 0;
                                    int diferenciaAfavor = 0;//inicializamos con 0 de que es mas caro el producto de la competencia
                                    for(EstanteriaDescripcion estanteriaDescripcion : estanteriasDescripcionDto){
                                        productosCompetencia += estanteriaDescripcion.getCantidad(); //total de productos de la competencia
                                        if(estanteriaDescripcion.getPrecio() != 0){
                                            precioPromedio += estanteriaDescripcion.getPrecio();                                        
                                            numeroCompetidores++;
                                        }
                                    }
                                    if(numeroCompetidores > 0){
                                        precioPromedio = precioPromedio/numeroCompetidores;
                                    }
                                    participacionAnaquel = (estanteriasDto.getCantidad() * 100) / (estanteriasDto.getCantidad() + productosCompetencia);
                                    if(precioPromedio > 0){
                                        diferenciaPrecio = estanteriasDto.getPrecio() - precioPromedio;
                                    }
                                    if(diferenciaPrecio > 0){
                                        diferenciaAfavor = 1;//es mas caro mi producto
                                    }else if(diferenciaPrecio == 0){
                                        diferenciaAfavor = 3;//no hay diferencia a favor
                                    }else{
                                        diferenciaPrecio = ((diferenciaPrecio)*(-1));
                                    }
                                        
                                    
                                %>
                            
                                    <tr>
                                        <td><center><%="Participación en anaquel"%></br><%=FormatUtil.doubleToString(participacionAnaquel)+" %"%></center></td>
                                        <td><center><%="Producto propio en anaquel"%></br><%=FormatUtil.doubleToString(estanteriasDto.getCantidad())%></center></td>
                                        <td><center><%="Precio propio"%></br><%="$ "+FormatUtil.doubleToString(estanteriasDto.getPrecio())%></center></td>
                                        <td><center><%="Diferencia de precio"%></br><%=diferenciaAfavor==3?" ":diferenciaAfavor==1?"+":"-" + "$ "+FormatUtil.doubleToString(diferenciaPrecio)%></center></td>
                                    </tr>
                                    <tr>
                                        <th colspan="4"><center>Precio Promedio : $<%=FormatUtil.doubleToString(precioPromedio)%></center></th>
                                    </tr>
                                    <tr>
                                        <th colspan="4"><center>Producto de la competencia : <%=FormatUtil.doubleToString(productosCompetencia)%></center></th>
                                    </tr>                                    
                                <%}%>
                                <!-- End left column window -->


                            </table>
                            <table class="data" width="100%" cellpadding="0" cellspacing="0">    
                                <tr>
                                    <td style="width: 33%"><center><%="Competencia"%></center></td>
                                    <td style="width: 33%"><center><%="Cantidad en anaquel"%></center></td>
                                    <td style="width: 33%"><center><%="Precio"%></center></td>
                                </tr>
                                <%for(EstanteriaDescripcion estanteriaDescripcion : estanteriasDescripcionDto){
                                    Competencia competencia = new CompetenciaBO(estanteriaDescripcion.getIdCompetencia(), user.getConn()).getCompetencia();
                                %>
                                    <tr>               
                                        <td><center><%=competencia.getNombre()%></center></td>
                                        <td><center><%=FormatUtil.doubleToString(estanteriaDescripcion.getCantidad())%></center></td>
                                        <td><center><%="$ "+FormatUtil.doubleToString(estanteriaDescripcion.getPrecio())%></center></td>                                    
                                    </tr>
                                <%
                                }%>
                            </table>
                                    
                        </div>
                    </div>
                    </form>
                    <!--TODO EL CONTENIDO VA AQUÍ-->

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