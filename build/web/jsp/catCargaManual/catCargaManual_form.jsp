<%-- 
    Document   : catCargaManual_form
    Created on : 28/08/2015, 05:13:48 PM
    Author     : HpPyme
--%>

<%@page import="com.tsp.gespro.config.Configuration"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
//Verifica si el cliente tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {

        long idEmpresa = user.getUser().getIdEmpresa();
        
        /*
         * Parámetros
         */
      
        

        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";        
        
    Configuration appConfig = new Configuration();      
    String rutaArchivoLayoutProductos =  appConfig.getApp_content_path()+ "/recursos/Layout Productos.xls";
    String rutaArchivoLayoutProductosEncoded = java.net.URLEncoder.encode(rutaArchivoLayoutProductos, "UTF-8");
    String rutaArchivoLayoutClientes =  appConfig.getApp_content_path()+ "/recursos/Layout Clientes Gespro.xls";
    String rutaArchivoLayoutClientesEncoded = java.net.URLEncoder.encode(rutaArchivoLayoutClientes, "UTF-8");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <link rel="shortcut icon" href="../../images/favicon.ico">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/skinCSS.jsp" />

        <jsp:include page="../include/jsFunctions.jsp"/>
        
        <script type="text/javascript">
            
            function grabar(tipoCarga){                
                    $.ajax({
                        type: "POST",
                        url: "catCargaManual_ajax.jsp",
                        data: $("#frm_action").serialize() + "&tipoCarga="+tipoCarga,
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               //$("#ajax_message").html(datos);
                               //$("#ajax_loading").fadeOut("slow");
                               //$("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                                        function(r){
                                            location.href = "catCargaManual_list.jsp";
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

            function recuperarNombreArchivoProds(nombreArchivo){
                $('#nombreArchivo').val('' + nombreArchivo);
            }
            
            function recuperarNombreArchivoClientes(nombreImagen) {
                $('#nombreArchivocli').val('' + nombreImagen);
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
                    <h1>Administración</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <!--<div class="column_left">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_excel.png" alt="icon"/>
                                    Productos
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">                                    
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />                                                                                                       
                                    
                                    <%
                                        //Si se esta en modo para agregar un nuevo registro se muestra el upload
                                        if (mode.equals("")){
                                    %>
                                    <p>
                                        <label>*Subir Archivo (.xls)</label><br/>
                                        <iframe src="../file/uploadSingleForm.jsp?id=archivoImagen&validate=xls&queryCustom=isCargaXls=1" 
                                                id="iframe_archivos_jpg" 
                                                name="iframe_archivos_jpg" 
                                                style="border: none" scrolling="no"
                                                height="80" width="400">
                                            <p>Tu navegador no soporta iframes y son necesarios para el buen funcionamiento del aplicativo</p>
                                        </iframe>
                                    </p>
                                    <% } %>
                                    
                                    <p>
                                        <label>*Nombre Archivo:</label><br/>
                                        <input maxlength="30" type="text" id="nombreArchivo" name="nombreArchivo" style="width:300px"
                                               readonly />
                                    </p>
                                    <br/>                                    
                                    <p>                                                                                                          
                                        <img src="../../images/icon_excel.png"/>
                                        <a href="../file/download.jsp?ruta_archivo=<%=rutaArchivoLayoutProductosEncoded%>">Layout Productos</a>                                                              
                                    <p>
                                    <br/>   
                                    <div id="action_buttons">
                                        <p>
                                            <% if (mode.equals("")){ %>
                                            <input type="button" id="enviar" value="Guardar" onclick="grabar('productos');"/>
                                           <%}%>
                                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                        </p>
                                    </div>
                                    
                                </div>
                            </div>-->
                        <!-- End left column window -->
                        
                        
                        
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_excel.png" alt="icon"/>
                                    Clientes
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">                                    
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />                                                                                                       
                                    
                                    <%
                                        //Si se esta en modo para agregar un nuevo registro se muestra el upload
                                        if (mode.equals("")){
                                    %>
                                    <p>
                                        <label>*Subir Archivo (.xls)</label><br/>
                                        <iframe src="../file/uploadSingleForm.jsp?id=archivoImagen&validate=xls&queryCustom=isCargaXls=2" 
                                                id="iframe_archivos_jpg" 
                                                name="iframe_archivos_jpg" 
                                                style="border: none" scrolling="no"
                                                height="80" width="400">
                                            <p>Tu navegador no soporta iframes y son necesarios para el buen funcionamiento del aplicativo</p>
                                        </iframe>
                                    </p>
                                    <% } %>
                                    
                                    <p>
                                        <label>*Nombre Archivo:</label><br/>
                                        <input maxlength="30" type="text" id="nombreArchivocli" name="nombreArchivocli" style="width:300px"
                                               readonly />
                                    </p>
                                    <br/>                                    
                                    <p>                                                                                                          
                                        <img src="../../images/icon_excel.png"/>
                                        <a href="../file/download.jsp?ruta_archivo=<%=rutaArchivoLayoutClientesEncoded%>">Layout Clientes</a>                                                              
                                    </p>
                                    <br/>   
                                    <div id="action_buttons">
                                        <p>
                                            <% if (mode.equals("")){ %>
                                            <input type="button" id="enviar" value="Guardar" onclick="grabar('clientes');"/>
                                           <%}%>
                                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                        </p>
                                    </div>
                                    
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