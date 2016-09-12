<%-- 
    Document   : catHorarios_form
    Created on : 29/10/2015, 10:08:41 AM
    Author     : HpPyme
--%>

<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="com.tsp.gespro.dto.DetalleHorario"%>
<%@page import="com.tsp.gespro.bo.DetalleHorarioBO"%>
<%@page import="com.tsp.gespro.dto.HorarioUsuario"%>
<%@page import="com.tsp.gespro.bo.HorariosBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
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
    int idHorario = 0;
    try {
        idHorario = Integer.parseInt(request.getParameter("idHorario"));
        
    } catch (NumberFormatException e) {
    }


    /*
     *   0/"" = nuevo
     *   1 = editar/consultar
     *   2 = eliminar  
     */
    String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
   

    HorariosBO horarioBO = new HorariosBO(user.getConn());
    HorarioUsuario horarioDto = null;    
    DetalleHorarioBO detalleHorarioBO =  new DetalleHorarioBO(user.getConn());
   
    
    if (idHorario > 0){
        horarioBO = new HorariosBO(idHorario,user.getConn());
        horarioDto = horarioBO.getHorarioUsuario();
                
    }
    
    
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/skinCSS.jsp" />

        <jsp:include page="../include/jsFunctions.jsp"/>
        
        <script type="text/javascript">
            
            function grabar(){
            
                    $.ajax({
                        type: "POST",
                        url: "catHorarios_ajax.jsp",
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
                                            location.href = "catHorarios_list.jsp?pagina="+"<%=paginaActual%>";
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

            
  
  $(function() {	
        $.timepicker.regional['es'] = {
    		timeOnlyTitle: 'Elegir Hora',
        	timeText: '',
        	hourText: 'Horas',
        	minuteText: 'Minutos',
        	secondText: 'Segundos',
        	currentText: 'Ahora',
        	closeText: 'Aceptar'
	    };
	 $.timepicker.setDefaults($.timepicker.regional['es']);  
    
	$('.time').timepicker({
		 hourMin: 0,
                 hourMax: 23,
		 addSliderAccess: true,
		 sliderAccessArgs: { touchonly: false },
		
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
                    <h1>Horarios</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    
                        <div class="onecolumn">
                            <div class="header">
                                <span>
                                    <img src="../../images/clock.png" alt="icon"/>
                                    <% if(horarioDto!=null){%>
                                    Editar Horario ID <%=horarioDto!=null?horarioDto.getIdHorario():"" %>
                                    <%}else{%>
                                    Horario
                                    <%}%>
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                <input type="hidden" id="idHorario" name="idHorario" value="<%=horarioDto!=null?horarioDto.getIdHorario():"" %>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    <p>
                                        <label>*Nombre:</label><br/>
                                        <input maxlength="30" type="text" id="nombreHorario" name="nombreHorario" style="width:300px"
                                               value="<%=horarioDto!=null?horarioDto.getNombreHorario():"" %>"/>
                                    </p>
                                    <br/>                                                                                                            
                                    <br/>
                                    <p>
                                        <table class="data" width="100%" cellpadding="0" cellspacing="0">
                                            <thead>
                                                <tr>
                                                    <th>Dia</th>
                                                    <th>Entrada</th>
                                                    <th>Salida</th>
                                                    <th>Tolerancia Entrada (min)</th>
                                                    <th>Comida Salida</th>  
                                                    <th>Comida Entrada</th>
                                                    <th>Periodo Comida (min)</th>  
                                                    <th>Descanso</th>                                                    
                                                </tr>
                                            </thead>
                                            <tbody>       
                                                <%
                                                
                                                
                                                DetalleHorario detalleHorarioDto = null;
                                                DateFormat sdf = new SimpleDateFormat("HH:mm");
                                                
                                                for(int i= 1;i<=7;i++){  
                                                    String dia ="";
                                                    
                                                    if(i==1)
                                                        dia = "LUNES";
                                                    else if(i==2)
                                                        dia = "MARTES";
                                                    else if(i==3)
                                                        dia = "MIERCOLES";
                                                    else if(i==4)
                                                        dia = "JUEVES";
                                                    else if(i==5)
                                                        dia = "VIERNES";
                                                    else if(i==6)
                                                        dia = "SABADO";
                                                    else if(i==7)
                                                        dia = "DOMINGO";
                                                    
                                                    
                                                    
                                                    if (idHorario > 0){ 
                                                        
                                                        try{                                                    
                                                            String filtroDia =" AND DIA = '" + dia + "' " ;
                                                            detalleHorarioDto = detalleHorarioBO.findDetalleHorario(idHorario,-1,-1,filtroDia)[0];
                                                        }catch(Exception e){}
                                                    }
                                                    
                                                    
                                                %>
                                                <tr>                     
                                                    <input type="hidden" id="idDetalleHorario_<%=dia%>" name="idDetalleHorario_<%=dia%>" value="<%=detalleHorarioDto!=null?detalleHorarioDto.getIdDetalleHorario():"" %>" />
                                                    <td>
                                                        <input maxlength="30" type="text" id="dia_<%=dia%>" name="dia_<%=dia%>" style="width:100px"
                                                               value="<%=dia%>" readonly=""/>
                                                    </td>
                                                    <td>
                                                        <input maxlength="30" type="text" id="entrada_<%=dia%>" name="entrada_<%=dia%>" style="width:100px"
                                                               class="time" value="<%=detalleHorarioDto!=null?detalleHorarioDto.getHoraEntrada()!=null?sdf.format(detalleHorarioDto.getHoraEntrada()):"":"" %>" placeholder="hh:mm" readonly />                                                        
                                                    </td>
                                                    <td>
                                                        <input maxlength="30" type="text" id="salida_<%=dia%>" name="salida_<%=dia%>" style="width:100px"
                                                               class="time" value="<%=detalleHorarioDto!=null?detalleHorarioDto.getHoraSalida()!=null?sdf.format(detalleHorarioDto.getHoraSalida()):"":"" %>" placeholder="hh:mm" readonly />
                                                    </td>
                                                    <td>
                                                        <input maxlength="30" type="text" id="tolerancia_<%=dia%>" name="tolerancia_<%=dia%>" style="width:100px"
                                                               value="<%=detalleHorarioDto!=null?detalleHorarioDto.getTolerancia():"" %>" onkeypress="return validateNumber(event);"/>
                                                    </td>
                                                    <td>
                                                        <input maxlength="30" type="text" id="salidaComida_<%=dia%>" name="salidaComida_<%=dia%>" style="width:100px"
                                                               class="time" value="<%=detalleHorarioDto!=null?detalleHorarioDto.getComidaSalida()!=null?sdf.format(detalleHorarioDto.getComidaSalida()):"":"" %>" placeholder="hh:mm" readonly />
                                                    </td>                                        
                                                    <td>
                                                        <input maxlength="30" type="text" id="entradaComida_<%=dia%>" name="entradaComida_<%=dia%>" style="width:100px"
                                                               class="time" value="<%=detalleHorarioDto!=null?detalleHorarioDto.getComidaEntrada()!=null?sdf.format(detalleHorarioDto.getComidaEntrada()):"":"" %>" placeholder="hh:mm" readonly />
                                                    </td>
                                                    <td>
                                                        <input maxlength="30" type="text" id="periodo_<%=dia%>" name="periodo_<%=dia%>" style="width:100px"
                                                               value="<%=detalleHorarioDto!=null?detalleHorarioDto.getPeriodoComida():"" %>" onkeypress="return validateNumber(event);"/>
                                                    </td>
                                                    <td>                                                        
                                                        <input type="checkbox" class="checkbox" <%=detalleHorarioDto!=null?(detalleHorarioDto.getDiaDescanso()==1?"checked":""):"" %> id="descanso_<%=dia%>" name="descanso_<%=dia%>" value="1">
                                                    </td>
                                                </tr>
                                                 <%}%>
                                            </tbody>
                                        </table>
                                    <br/>
                                    <p>
                                        <input type="checkbox" class="checkbox" <%=horarioDto!=null?(horarioDto.getIdEstatus()==1?"checked":""):"checked" %> id="estatus" name="estatus" value="1"> <label for="estatus">Activo</label>
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