<%-- 
    Document   : catConceptoEmbalajes_form
    Created on : 27/10/2015, 11:53:04 AM
    Author     : leonardo
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.bo.EmbalajeBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.RelacionConceptoEmbalajeBO"%>
<%@page import="com.tsp.gespro.jdbc.RelacionConceptoEmbalajeDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionConceptoEmbalaje"%>
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
        int idRelacionConceptoEmbalaje = 0;
        try {
            idRelacionConceptoEmbalaje = Integer.parseInt(request.getParameter("idRelacionConceptoEmbalaje"));
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
        
        RelacionConceptoEmbalajeBO relacionConceptoEmbalajeBO = new RelacionConceptoEmbalajeBO(user.getConn());
        RelacionConceptoEmbalaje relacionConceptoEmbalajesDto = null;
        String nombreProducto = "Dando de alta el Producto";
        if(valorIdSesion == 1){//recuperamos el objeto de la lista de sesion
            List<RelacionConceptoEmbalaje> listaObjetosRelacionConceptoEmbalaje = null;
            try{
                listaObjetosRelacionConceptoEmbalaje = (ArrayList<RelacionConceptoEmbalaje>)session.getAttribute("RelacionConceptoEmbalajeSesion");
                if(listaObjetosRelacionConceptoEmbalaje != null){
                    relacionConceptoEmbalajesDto = listaObjetosRelacionConceptoEmbalaje.get(idRelacionConceptoEmbalaje);
                    listaObjetosRelacionConceptoEmbalaje.remove(idRelacionConceptoEmbalaje);//la removemos para que en el ajax la agregremos de new
                    session.setAttribute("RelacionConceptoEmbalajeSesion", listaObjetosRelacionConceptoEmbalaje);
                }
            }catch(Exception e){}
            
        }else if (idRelacionConceptoEmbalaje > 0){
            relacionConceptoEmbalajeBO = new RelacionConceptoEmbalajeBO(idRelacionConceptoEmbalaje,user.getConn());
            relacionConceptoEmbalajesDto = relacionConceptoEmbalajeBO.getRelacionConceptoEmbalaje();
            nombreProducto = new ConceptoBO(relacionConceptoEmbalajesDto.getIdConcepto(), user.getConn()).getConcepto().getNombre();
            mode = "modificarEmbalaje";
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
                        url: "catConceptoEmbalajes_ajax.jsp",
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
                                            location.href = "catConceptoEmbalajes_list.jsp?pagina="+"<%=paginaActual%>"+"&idConcepto=<%=idConcepto%>";
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
        
                    <h1>Relacion Concepto - Embalajes</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="onecolumn">
                        <div>
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_relacionConceptoEmbalaje.png" alt="icon"/>
                                    <% if(relacionConceptoEmbalajesDto!=null){%>
                                    Editar Relacion Concepto Embalaje ID <%=relacionConceptoEmbalajesDto!=null?relacionConceptoEmbalajesDto.getIdRelacion():"" %>
                                    <%}else{%>
                                    Relacion Concepto Embalaje
                                    <%}%>
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="idRelacionConceptoEmbalaje" name="idRelacionConceptoEmbalaje" value="<%=relacionConceptoEmbalajesDto!=null?relacionConceptoEmbalajesDto.getIdRelacion():"" %>" />
                                    <input type="hidden" id="idConcepto" name="idConcepto" value="<%=idConcepto%>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    
                                    <p>
                                        <label>Embalaje:</label><br/>
                                        <select size="1" id="idEmbalaje" name="idEmbalaje" style="width:300px" >
                                            <option value="-1">Seleccione un Embalaje</option>
                                            <%
                                                out.print(new EmbalajeBO(user.getConn()).getEmbalajesByIdHTMLCombo(idEmpresa, (relacionConceptoEmbalajesDto != null ? relacionConceptoEmbalajesDto.getIdEmbalaje() : -1)));
                                            %>
                                        </select>                                        
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Cantidad:</label><br/>
                                        <input maxlength="30" type="text" id="cantidadRelacionConceptoEmbalaje" name="cantidadRelacionConceptoEmbalaje" style="width:300px"
                                               value="<%=relacionConceptoEmbalajesDto!=null?relacionConceptoEmbalajesDto.getCantidad():"0" %>"/>
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