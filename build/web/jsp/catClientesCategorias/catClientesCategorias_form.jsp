<%-- 
    Document   : catClientesCategorias_form
    Created on : 3/07/2015, 03:45:39 PM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.PasswordBO"%>
<%@page import="com.tsp.gespro.bo.ClienteCategoriaBO"%>
<%@page import="com.tsp.gespro.jdbc.ClienteCategoriaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.ClienteCategoria"%>
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
        int idClienteCategoria = 0;
        try {
            idClienteCategoria = Integer.parseInt(request.getParameter("idClienteCategoria"));
        } catch (NumberFormatException e) {
        }

        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
        String newRandomPass = "";
        
        ClienteCategoriaBO clienteCategoriaBO = new ClienteCategoriaBO(user.getConn());
        ClienteCategoria clienteCategoriasDto = null;
        if (idClienteCategoria > 0){
            clienteCategoriaBO = new ClienteCategoriaBO(idClienteCategoria,user.getConn());
            clienteCategoriasDto = clienteCategoriaBO.getClienteCategoria();
        }else{
            newRandomPass = new PasswordBO().generateValidPassword();
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
                        url: "catClientesCategorias_ajax.jsp",
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
                                            location.href = "catClientesCategorias_list.jsp?pagina="+"<%=paginaActual%>";
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
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Categoria Cliente</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_clienteCategoria.png" alt="icon"/>
                                    <% if(clienteCategoriasDto!=null){%>
                                    Editar Cliente Categoría ID <%=clienteCategoriasDto!=null?clienteCategoriasDto.getIdCategoria():"" %>
                                    <%}else{%>
                                    Cliente Categoría
                                    <%}%>
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="idClienteCategoria" name="idClienteCategoria" value="<%=clienteCategoriasDto!=null?clienteCategoriasDto.getIdCategoria():"" %>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    <p>
                                        <label>*Categoría:</label><br/>
                                        <input maxlength="50" type="text" id="nombreClienteCategoria" name="nombreClienteCategoria" style="width:300px"
                                               value="<%=clienteCategoriasDto!=null?clienteCategoriaBO.getClienteCategoria().getNombreClasificacion():"" %>"/>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>*Descripción/Especialidad:</label><br/>
                                        <input maxlength="150" type="text" id="descripcion" name="descripcion" style="width:300px"
                                               value="<%=clienteCategoriasDto!=null?clienteCategoriaBO.getClienteCategoria().getDescripcion():"" %>"/>
                                    </p>
                                    <br/>                                                                        
                                    
                                    <p>
                                        <input type="checkbox" class="checkbox" <%=clienteCategoriasDto!=null?(clienteCategoriasDto.getIdEstatus()==1?"checked":""):"checked" %> id="estatus" name="estatus" value="1"> <label for="estatus">Activo</label>
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

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>


    </body>
</html>
<%}%>