<%-- 
    Document   : catConceptoEmbalajes_list
    Created on : 27/10/2015, 11:38:58 AM
    Author     : leonardo
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.tsp.gespro.dto.Embalaje"%>
<%@page import="com.tsp.gespro.bo.EmbalajeBO"%>
<%@page import="com.tsp.gespro.dto.Concepto"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.dto.RelacionConceptoEmbalaje"%>
<%@page import="com.tsp.gespro.bo.RelacionConceptoEmbalajeBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";
    String filtroBusqueda = "";
    if (!buscar.trim().equals(""))
        filtroBusqueda = " AND (NOMBRE LIKE '%" + buscar + "%' OR DESCRIPCION LIKE '%" +buscar+"%')";
    
    int idRelacionConceptoEmbalaje = -1;
    try{ idRelacionConceptoEmbalaje = Integer.parseInt(request.getParameter("idRelacionConceptoEmbalaje")); }catch(NumberFormatException e){}
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    int idConcepto = 0;
    try {
        idConcepto = Integer.parseInt(request.getParameter("idConcepto"));
    } catch (NumberFormatException e) {}    
    
    ConceptoBO conceptoBO = new ConceptoBO(user.getConn());
    Concepto conceptosDto = null;
    if (idConcepto > 0) {
        conceptoBO = new ConceptoBO(idConcepto, user.getConn());
        conceptosDto = conceptoBO.getConcepto();
        
    }
        
    /*
    * Paginación
    */
    int paginaActual = 1;
    double registrosPagina = 10;
    double limiteRegistros = 0;
    int paginasTotales = 0;
    int numeroPaginasAMostrar = 5;

    try{
        paginaActual = Integer.parseInt(request.getParameter("pagina"));
    }catch(Exception e){}

    try{
        registrosPagina = Integer.parseInt(request.getParameter("registros_pagina"));
    }catch(Exception e){}
    
     RelacionConceptoEmbalajeBO relacionConceptoEmbalajeBO = new RelacionConceptoEmbalajeBO(user.getConn());
     RelacionConceptoEmbalaje[] relacionConceptoEmbalajesDto = new RelacionConceptoEmbalaje[0];
     
     //verificamos si el listado de embalajes por concepto esta en sesión; solo esto aplica cuando el concepto es nuevo y no se ha guardado:
    List<RelacionConceptoEmbalaje> listaObjetosRelacionConceptoEmbalaje = null;
    try{
        listaObjetosRelacionConceptoEmbalaje = (ArrayList<RelacionConceptoEmbalaje>)session.getAttribute("RelacionConceptoEmbalajeSesion");
    }catch(Exception e){}
    
    //VARIABLE DE CONTROL PARA SABER SI SON DATOS DE SESION O DATOS DE BASE DE DATOS:
    int datosSesion = 0;
            
    if(listaObjetosRelacionConceptoEmbalaje != null){
        relacionConceptoEmbalajesDto = (RelacionConceptoEmbalaje[])listaObjetosRelacionConceptoEmbalaje.toArray(new RelacionConceptoEmbalaje[0]);
        
        registrosPagina = listaObjetosRelacionConceptoEmbalaje.size();
        limiteRegistros = listaObjetosRelacionConceptoEmbalaje.size();
        
        datosSesion = 1;
    }else{     
        try{
            limiteRegistros = relacionConceptoEmbalajeBO.findRelacionConceptoEmbalajes(idRelacionConceptoEmbalaje, idConcepto, 0, 0, 0, filtroBusqueda).length;

            if (!buscar.trim().equals(""))
                registrosPagina = limiteRegistros;

            paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

           if(paginaActual<0)
               paginaActual = 1;
           else if(paginaActual>paginasTotales)
               paginaActual = paginasTotales;

           relacionConceptoEmbalajesDto = relacionConceptoEmbalajeBO.findRelacionConceptoEmbalajes(idRelacionConceptoEmbalaje, idConcepto, 0,
                   ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                   filtroBusqueda);
           
        datosSesion = 0;
        
        }catch(Exception ex){
            ex.printStackTrace();
        }
    }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catConceptos/catConceptoEmbalajes_form.jsp";
    String paramName = "idRelacionConceptoEmbalaje";
    String parametrosPaginacion="";// "idEmpresa="+idEmpresa;
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    
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
            function eliminarRelacionEmbalaje(idRelacion, datosSesion, idEmbalaje){
                if(idRelacion>=0){
                    $.ajax({
                        type: "POST",
                        url: "catConceptoEmbalajes_ajax.jsp",
                        data: { mode: 'eliminar', idRelacion : idRelacion, datosSesion : datosSesion , idEmbalaje : idEmbalaje},
                        beforeSend: function(objeto){
                            //$("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style="">ESPERE, procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_message").html(datos);
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                                        function(r){
                                            location.href = "catConceptoEmbalajes_list.jsp?pagina="+"<%=paginaActual%>";
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
                
                if(datosSesion == 1){//verificamos si removeremos un dato de 
                    
                }else{
                    
                }
                
            }
        </script>

    </head>
    <body class="nobg">
        <h1>Relacion Concepto - Embalajes</h1>
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_relacionConceptoEmbalaje.png" alt="icon"/>
                                <%=conceptosDto != null?conceptosDto.getNombreDesencriptado():"" %>
                            </span>
                            <div class="switch" style="width:300px">
                                <table width="300px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                            <tr>                                                
                                                <td>
                                                    <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Crear Nuevo" 
                                                            style="float: right; width: 100px;" onclick="location.href='<%=urlTo%><%=conceptosDto != null?"?idConcepto="+idConcepto:"" %>'"/>
                                                </td>
                                                
                                            </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <br class="clear"/>
                        <div class="content">
                            <form id="form_data" name="form_data" action="" method="post">
                                <table class="data" width="100%" cellpadding="0" cellspacing="0">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Nombre Embalaje</th>
                                            <th>Cantidad</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            EmbalajeBO embalajeBO = new EmbalajeBO(user.getConn());
                                            Embalaje embalaje = null;
                                            int valorIdSesion = 0;//variable para ayudar en los id's si son datos de sesion                                            
                                            
                                            for (RelacionConceptoEmbalaje item:relacionConceptoEmbalajesDto){
                                                if(datosSesion == 1){
                                                    item.setIdRelacion(valorIdSesion);
                                                    valorIdSesion++;
                                                }
                                                try{
                                                    embalaje = embalajeBO.findMarcabyId(item.getIdEmbalaje());
                                        %>
                                        <tr>
                                            <!--<td><input type="checkbox"/></td>-->
                                            <td><%=item.getIdRelacion() %></td>
                                            <td><%=embalaje.getNombre() %></td>
                                            <td><%=item.getCantidad()%></td>
                                            <td>
                                                
                                                <a href="<%=urlTo%>?<%=paramName%>=<%=item.getIdRelacion()%>&acc=1&pagina=<%=paginaActual%>&valorIdSesion=<%=datosSesion%>&idConcepto=<%=conceptosDto != null?conceptosDto.getIdConcepto():"0" %>"><img src="../../images/icon_edit.png" alt="editar" class="help" title="Editar"/></a>
                                                &nbsp;&nbsp;
                                                
                                                <a href="#" onclick="eliminarRelacionEmbalaje(<%=item.getIdRelacion()%>,<%=datosSesion%>, <%=item.getIdEmbalaje()%>);"><img src="../../images/icon_delete.png" alt="delete" class="help" title="Delete"/></a>
                                            </td>
                                        </tr>
                                        <%      }catch(Exception ex){
                                                    ex.printStackTrace();
                                                }
                                            } 
                                        %>
                                    </tbody>
                                </table>
                            </form>

                            <!-- INCLUDE OPCIONES DE EXPORTACIÓN-->
                            <!--<//jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <//jsp:param name="idReport" value="<//%= ReportBO.MARCA_REPORT %>" />
                                <//jsp:param name="parametrosCustom" value="<//%= filtroBusquedaEncoded %>" />
                            <///jsp:include>-->
                            <!-- FIN INCLUDE OPCIONES DE EXPORTACIÓN-->
                                    
                            <jsp:include page="../include/listPagination.jsp">
                                <jsp:param name="paginaActual" value="<%=paginaActual%>" />
                                <jsp:param name="numeroPaginasAMostrar" value="<%=numeroPaginasAMostrar%>" />
                                <jsp:param name="paginasTotales" value="<%=paginasTotales%>" />
                                <jsp:param name="url" value="<%=request.getRequestURI() %>" />
                                <jsp:param name="parametrosAdicionales" value="<%=parametrosPaginacion%>" />
                            </jsp:include>
                            
                        </div>
                    </div>
                
            <!-- Fin de Contenido-->
        
    </body>
</html>
<%}%>