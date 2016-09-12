<%-- 
    Document   : catConceptoCompetencias_form
    Created on : 27/10/2015, 05:24:00 PM
    Author     : leonardo
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.bo.CompetenciaBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.RelacionConceptoCompetenciaBO"%>
<%@page import="com.tsp.gespro.jdbc.RelacionConceptoCompetenciaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionConceptoCompetencia"%>
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
        int idRelacionConceptoCompetencia = 0;
        try {
            idRelacionConceptoCompetencia = Integer.parseInt(request.getParameter("idRelacionConceptoCompetencia"));
        } catch (NumberFormatException e) {
        }
        int idConcepto = 0;
        try {
            idConcepto = Integer.parseInt(request.getParameter("idConcepto"));
        } catch (NumberFormatException e) {
        }
        
        
        int valorIdSesion = 0; //variable con la que identificamos si vamos a editar un dato de sesion
        try {
            valorIdSesion = Integer.parseInt(request.getParameter("valorIdSesion"));
        } catch (NumberFormatException e) {
        }

        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
        String newRandomPass = "";
        
        RelacionConceptoCompetenciaBO relacionConceptoCompetenciaBO = new RelacionConceptoCompetenciaBO(user.getConn());
        RelacionConceptoCompetencia relacionConceptoCompetenciasDto = null;
        String nombreProducto = "Dando de alta el Producto";
        if(valorIdSesion == 1){//recuperamos el objeto de la lista de sesion
            List<RelacionConceptoCompetencia> listaObjetosRelacionConceptoCompetencia = null;
            try{
                listaObjetosRelacionConceptoCompetencia = (ArrayList<RelacionConceptoCompetencia>)session.getAttribute("RelacionConceptoCompetenciaSesion");
                if(listaObjetosRelacionConceptoCompetencia != null){
                    relacionConceptoCompetenciasDto = listaObjetosRelacionConceptoCompetencia.get(idRelacionConceptoCompetencia);
                    listaObjetosRelacionConceptoCompetencia.remove(idRelacionConceptoCompetencia);//la removemos para que en el ajax la agregremos de new
                    session.setAttribute("RelacionConceptoCompetenciaSesion", listaObjetosRelacionConceptoCompetencia);
                }
            }catch(Exception e){}
            
        }else if (idRelacionConceptoCompetencia > 0){
            relacionConceptoCompetenciaBO = new RelacionConceptoCompetenciaBO(idRelacionConceptoCompetencia,user.getConn());
            relacionConceptoCompetenciasDto = relacionConceptoCompetenciaBO.getRelacionConceptoCompetencia();
            nombreProducto = new ConceptoBO(relacionConceptoCompetenciasDto.getIdConcepto(), user.getConn()).getConcepto().getNombre();
            mode = "modificarCompetencia";
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
            
            function grabar(){
                if(validar()){
                    $.ajax({
                        type: "POST",
                        url: "catConceptoCompetencias_ajax.jsp",
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
                                            location.href = "catConceptoCompetencias_list.jsp?pagina="+"<%=paginaActual%>"+"&idConcepto=<%=idConcepto%>";
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
            
        </script>
    </head>
    <body class="nobg">
        
                    <h1>Relacion Concepto - Competencias</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="onecolumn">
                        <div>
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_relacionConceptoCompetencia.png" alt="icon"/>
                                    <% if(relacionConceptoCompetenciasDto!=null){%>
                                    Editar Relacion Concepto Competencia ID <%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getIdRelacion():"" %>
                                    <%}else{%>
                                    Relacion Concepto Competencia
                                    <%}%>
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="idRelacionConceptoCompetencia" name="idRelacionConceptoCompetencia" value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getIdRelacion():"" %>" />
                                    <input type="hidden" id="idConcepto" name="idConcepto" value="<%=idConcepto%>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    
                                    <p>
                                        <label>Competencia:</label><br/>
                                        <select size="1" id="idCompetencia" name="idCompetencia" style="width:300px" >
                                            <option value="-1">Seleccione un Competencia</option>
                                            <%
                                                out.print(new CompetenciaBO(user.getConn()).getCompetenciasByIdHTMLCombo(idEmpresa, (relacionConceptoCompetenciasDto != null ? relacionConceptoCompetenciasDto.getIdCompetencia() : -1)));
                                            %>
                                        </select>                                        
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Nombre Articulo Competencia:</label><br/>
                                        <input maxlength="100" type="text" id="nombreRelacionConceptoCompetencia" name="nombreRelacionConceptoCompetencia" style="width:300px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getNombreConceptoCompetencia():"" %>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Descripción:</label><br/>
                                        <input maxlength="340" type="text" id="descripcionRelacionConceptoCompetencia" name="descripcionRelacionConceptoCompetencia" style="width:300px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getDescripcion():"" %>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Cantidad:</label><br/>
                                        <input maxlength="12" type="text" id="cantidadRelacionConceptoCompetencia" name="cantidadRelacionConceptoCompetencia" style="width:300px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getCantidad():"0" %>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>*Precio Menudeo/Unitario:</label><br/>
                                        <input maxlength="16" type="text" id="precioRelacionConceptoCompetencia" name="precioRelacionConceptoCompetencia" style="width:300px;"
                                               value="<%=relacionConceptoCompetenciasDto != null ? relacionConceptoCompetenciasDto.getPrecio() : "0"%>"
                                               onkeypress="return validateNumber(event);"/>                                        
                                    </p>
                                    <br/>
                                    <p>
                                    <label>Menudeo : </label><br/>
                                        Hasta: <input maxlength="16" type="text" id="maxPrecioMenudeoRelacionConceptoCompetencia" name="maxPrecioMenudeoRelacionConceptoCompetencia" style="width:180px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getMaxMenudeo():"0" %>"
                                               onkeypress="return validateNumber(event);"/> unidades.
                                    </p>
                                    <br/>  
                                    <p>
                                        <label>Precio Medio Mayoreo :</label><br/>
                                        <input maxlength="16" type="text" id="precioMedioMayoreoRelacionConceptoCompetencia" name="precioMedioMayoreoRelacionConceptoCompetencia" style="width:300px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getPrecioMedioMayoreo():"0" %>"
                                               onkeypress="return validateNumber(event);"/>

                                    </p>
                                    <br/>
                                    <p>
                                        <label>Medio Mayoreo: </label><br/>
                                        Desde: <input maxlength="16" type="text" id="minPrecioMedioRelacionConceptoCompetencia" name="minPrecioMedioRelacionConceptoCompetencia" style="width:60px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getMinMedioMayoreo():"0" %>"
                                               onkeypress="return validateNumber(event);"/> 
                                        Hasta: <input maxlength="16" type="text" id="maxPrecioMedioRelacionConceptoCompetencia" name="maxPrecioMedioRelacionConceptoCompetencia" style="width:60px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getMaxMedioMayoreo():"0" %>"
                                               onkeypress="return validateNumber(event);"/> unidades.
                                    </p> 
                                    <br/>     
                                    <p>
                                        <label>Precio Mayoreo :</label><br/>
                                        <input maxlength="16" type="text" id="precioMayoreoRelacionConceptoCompetencia" name="precioMayoreoRelacionConceptoCompetencia" style="width:300px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getPrecioMayoreo():"0" %>"
                                               onkeypress="return validateNumber(event);"/>

                                    </p>
                                    <br/>
                                    <p>
                                        <label>Mayoreo: </label><br/>                                    
                                        Desde: <input maxlength="16" type="text" id="minPrecioMayoreoRelacionConceptoCompetencia" name="minPrecioMayoreoRelacionConceptoCompetencia" style="width:180px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getMinMayoreo():"0" %>"
                                               onkeypress="return validateNumber(event);"/> unidades.
                                    </p> 
                                    <br/>
                                    <p>
                                        <label>Precio Docena (Precio Unitario):</label><br/>
                                        <input maxlength="16" type="text" id="precioDocenaRelacionConceptoCompetencia" name="precioDocenaRelacionConceptoCompetencia" style="width:300px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getPrecioDocena():"0" %>"
                                               onkeypress="return validateNumber(event);"/>

                                    </p>
                                    <br/>
                                    <p>
                                        <label>Precio Especial (Precio Unitario):</label><br/>
                                        <input maxlength="16" type="text" id="precioEspecialRelacionConceptoCompetencia" name="precioEspecialRelacionConceptoCompetencia" style="width:300px"
                                               value="<%=relacionConceptoCompetenciasDto!=null?relacionConceptoCompetenciasDto.getPrecioEspecial():"0" %>"
                                               onkeypress="return validateNumber(event);"/>

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
                        
                        
                    </div>
                    </form>
                    <!--TODO EL CONTENIDO VA AQUÍ-->

                


    </body>
</html>
<%}%>
