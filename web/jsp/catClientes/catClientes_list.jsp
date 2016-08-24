<%-- 
    Document   : catClientes_list.jsp
    Created on : 256-oct-2012, 12:13:49
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.bo.RelacionClienteVendedorBO"%>
<%@page import="com.tsp.gespro.report.ReportBO"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.dto.RegistroCheckin"%>
<%@page import="com.tsp.gespro.jdbc.RegistroCheckinDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionClienteVendedor"%>
<%@page import="com.tsp.gespro.jdbc.RelacionClienteVendedorDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.jdbc.ClienteCategoriaDaoImpl"%>
<%@page import="com.tsp.gespro.bo.ClienteCategoriaBO"%>
<%@page import="com.tsp.gespro.dto.ClienteCategoria"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>

<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.bo.DatosUsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
   
      
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";    //
    String buscar_idvendedor = request.getParameter("q_idvendedor")!=null?request.getParameter("q_idvendedor"):"";
    String buscar_isMostrarSoloActivos = request.getParameter("inactivos")!=null?request.getParameter("inactivos"):"1";
   
    
    int idClienteCategoria = -1;
    try{
        idClienteCategoria = Integer.parseInt(request.getParameter("idClienteCategoria"));
    }catch(NumberFormatException ex){}
    
    
    int tipoClientes = 0;// 0-> asignados    1-> compartidos  
    try{ tipoClientes = Integer.parseInt(request.getParameter("tipoClientes")); }catch(NumberFormatException e){} //para validar clientes asignados o compartidos
    
    String filtroBusqueda = ""; //"AND ID_ESTATUS=1 ";
    if (!buscar.trim().equals(""))
        filtroBusqueda += " AND (NOMBRE_COMERCIAL LIKE '%" + buscar +"%' OR CONTACTO LIKE '%"+buscar+"%')";
    
    //Si es usuario con rol vendedor entonces aplicamos filtro el listado de clientes
    /*if (user.getUser().getIdRoles() == RolesBO.ROL_OPERADOR){
        filtroBusqueda += " AND ID_CLIENTE IN (SELECT ID_CLIENTE FROM SGFENS_CLIENTE_VENDEDOR WHERE ID_USUARIO_VENDEDOR="+user.getUser().getIdUsuarios()+")";
    }*/
    
    
    if (buscar_isMostrarSoloActivos.trim().equals("1")){
        filtroBusqueda += " AND ID_ESTATUS = 1 ";        
    }
    
   
    if (!buscar_idvendedor.trim().equals("")){
        filtroBusqueda += " AND ID_CLIENTE IN ( SELECT ID_CLIENTE FROM relacion_cliente_vendedor WHERE ID_USUARIO='" + buscar_idvendedor +"') ";        
    }

    
    if(idClienteCategoria > 0){
        filtroBusqueda += " AND ID_CATEGORIA = " + idClienteCategoria;
    }
    
    
    
    int idCliente = -1;
    try{ idCliente = Integer.parseInt(request.getParameter("idCliente")); }catch(NumberFormatException e){}
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
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
    
     ClienteBO clienteBO = new ClienteBO(user.getConn());
     Cliente[] clientesDto = new Cliente[0];
     try{
         System.out.println("------qq--");
         limiteRegistros = clienteBO.findClientes(idCliente, idEmpresa , 0, 0, filtroBusqueda).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        clientesDto = clienteBO.findClientes(idCliente, idEmpresa,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catClientes/catClientes_form.jsp";
    String urlTo2 = "../catClientes/catClientes_formMapa.jsp";
    String urlTo3 = "../catCodigoBarras/catCodigoBarras_form.jsp";
    String urlTo4 = "../catPop/catConceptoRegistroFotografico_form.jsp";
    String urlTo5 = "../catEstanteria/catConceptoEstanteria_list.jsp";
    String urlTo6 = "../catClientes/catClientes_descargar_imagenes.jsp";
    
    String paramName = "idCliente";
    String parametrosPaginacion="inactivos="+buscar_isMostrarSoloActivos+"&q_idvendedor="+buscar_idvendedor+"&idClienteCategoria="+idClienteCategoria; // "idEmpresa="+idEmpresa;
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    
    ClienteCategoriaBO clienteCategoriaBO = new ClienteCategoriaBO(user.getConn());
    ClienteCategoria[] clientesCategorias = clienteCategoriaBO.findClienteCategorias(0, idEmpresa, 0, 0, " AND ID_ESTATUS = 1 ");
    
    EmpresaBO empresaBO = new EmpresaBO(user.getConn());
    EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());     
    
    
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
            function eliminar(idCliente){              
                apprise('¿Estas seguro de eliminar (cambiar de estatus) el registro del cliente?', {'verify':true, 'animate':true, 'textYes':'Si', 'textNo':'Cancelar'}, function(r)
                {
                    if(r){
                        ajaxReestablecer(idCliente);
                    }
                });
            }
            
            
            function inactiv(){               
                if($("#inactivos").attr("checked")){
                    $("#inactivos").val("2");
                }else{
                     $("#inactivos").val("1");
                }
            }
            
        </script>
        
        <script type="text/javascript">
            
            $(document).ready(function(){
                asignarFuncionCheckboxGeneral();
            });
            
            /**
            * Asigna una funcion para el checkbox maestro que hara
            * que un conjunto de checkbox se active o desactive
            */
            function asignarFuncionCheckboxGeneral(){
                //Checkbox
                $("input[name=check_master_id]").change(function(){
                    $('input[name=check_id]').each( function() {
                        if($("input[name=check_master_id]:checked").length === 1){
                            this.checked = true;
                        } else {
                            this.checked = false;
                        }
                    });
                });
            }
            
            /**
            * Funcion para invocar una acción para varios registros a la ves
            * Recorre todos los checkbox con nombre: check_id
            * y toma su valor para enviarlos como parametros GET separados por coma
            * a la JSP correspondiente
            */
            function muestraMultiplesAsignacionEmpleado(conservarAsignacion){
                //alert("Se descarga zip");

                var query_string = '../../jsp/catEmpleados/catEmpleado_Relacion_Cliente_Masivo_form.jsp?acc=asignacionClientesMasivos&conservarAsignacion='+conservarAsignacion+'&tipoCodigo=bar&idsClientes=';

                var idString ="";

                $("input[name=check_id]").each(function(){
                    if(this.checked){
                        idString += this.value + ",";
                    }
                });
                if (idString!==""){
                    query_string += idString;
                    //alert("cadena: "+query_string);

                    //window.open(query_string, "Múltiples Códigos de Barra", "location=0,status=0,scrollbars=0,menubar=0,resizable=0,width=800,height=600");
                    window.open(query_string);
                    
                }else{
                    apprise('No se selecciono ningun registro para Asignar a un empleado',{
                        'warning':true,
                        'animate':true
                    });
                }
            }
            
            function validaAsignacionClientes(){
                apprise('<img src=../../images/info.png> ¿Desea conservar las asignaciones previas de los clientes seleccionados?', {'verify':true, 'animate':true, 'textYes':'Si', 'textNo':'No'}, 
                        function(r){
                            if(r){
                                // Usuario dio click 'Yes'
                                //$('#asignacionPrevia').val("1");//conservar la asignación previa del cliente
                                muestraMultiplesAsignacionEmpleado(1);
                            }else{
                                //$('#asignacionPrevia').val("2");//no conservar la asignacion previa del cliente
                                muestraMultiplesAsignacionEmpleado(2);
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
                    <h1>Catálogos</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                    
                    
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                Busqueda Avanzada &dArr;
                            </span>
                        </div>
                        <br class="clear"/>
                        <div class="content" style="display: none;">
                            <form action="catClientes_list.jsp" id="search_form_advance" name="search_form_advance" method="post">
                                 
                                <p>
                                    <label>Buscar por Promotor:</label><br/>
                                    <select id="q_idvendedor" name="q_idvendedor" class="flexselect" title="Vendedor" style="float: left;">                                    
                                    <option value ="">Selecciona promotor</option>
                                    <%= new UsuariosBO().getUsuariosByRolHTMLCombo(idEmpresa, RolesBO.ROL_GESPRO, 0) %>                                     
                                    </select>
                                </p>
                                <br/><br/>
                                
                                <%if(clientesCategorias.length > 0){%>
                                    <p>
                                        <label>Tipo:</label><br/>
                                        <select id="idClienteCategoria" name="idClienteCategoria">
                                            <option value="0">Selecciona Tipo de Categoría de Cliente</option>
                                            <%
                                                out.print(clienteCategoriaBO.getClienteCategoriasByIdHTMLCombo(idEmpresa, -1));
                                            %>
                                        </select>
                                    </p>
                                    <br/><br/>
                                <%}%>
                                
                                <p>
                                    <input type="checkbox" class="checkbox" id="inactivos" name="inactivos" value="1"  onchange="inactiv();" > <label for="inactivos">Mostrar Inactivos</label>                                   
                                </p>
                                <br/><br/> 
                            
                                <div id="action_buttons">
                                    <p>
                                        <input type="button" id="buscar" value="Buscar" onclick="$('#search_form_advance').submit();"/>
                                    </p>
                                </div>
                                
                            </form>
                        </div>
                    </div>
                    

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_cliente.png" alt="icon"/>
                                Catálogo de Clientes
                            </span>
                            <div class="switch" style="width:80%">
                                <table width="80%px" cellpadding="0" cellspacing="0">
						<tbody>
							<tr>
                                                            <td>
                                                                <div id="search">
                                                                <form action="catClientes_list.jsp" id="search_form" name="search_form" method="get">                                                                                                                                                
                               
                                                                        <input type="text" id="q" name="q" title="Buscar por Nombre comercial/ Contacto" class="" style="width: 70%; float: left; "
                                                                               value="<%=buscar%>"/>
                                                                        <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  value="" style="cursor: pointer; width: 30px; height: 25px; float: left"/>
                                                                        
                                                                </form>
                                                                </div>
                                                            </td>
                                                            <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                                            
                                                            <td>
                                                                <input type="button" id="nuevo" name="nuevo" class="right_switch expose" value="Crear Nuevo" 
                                                                       style="float: right; width: 100px;" onclick="location.href='<%=urlTo%>'"/>
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
                                            <th><input type="checkbox" name="check_master_id" value="" /></th>
                                            <th>ID</th>
                                            <th>Nombre Comercial</th>
                                            <th>Contacto</th>
                                            <th>Estatus</th>
                                            <th>Promotor</th>                                            
                                            <th>Último check in</th>
                                            <th>Categoría</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            ClienteCategoriaDaoImpl categoriaDaoImpl = new ClienteCategoriaDaoImpl(user.getConn());
                                            RelacionClienteVendedor relacionCliente = null;
                                            Usuarios usuario = null;
                                            ClienteCategoria clienteCategoria = null; 
                                            RegistroCheckin registroCheck = null;
                                            for (Cliente item:clientesDto){
                                                try{
                                                    relacionCliente =  null;
                                                    usuario = null;
                                                    try{relacionCliente = new RelacionClienteVendedorBO(user.getConn()).findRelacionClienteVendedors(item.getIdCliente(),0,0,0,"")[0];}catch(Exception e){}
                                                    try{usuario = new UsuariosBO(relacionCliente.getIdUsuario(), user.getConn()).getUsuario();}catch(Exception e){}
                                                    clienteCategoria = categoriaDaoImpl.findByPrimaryKey(item.getIdCategoria());
                                                    try{registroCheck = new RegistroCheckinDaoImpl(user.getConn()).findByDynamicWhere(" ID_CLIENTE = " +item.getIdCliente() + " ORDER BY FECHA_HORA DESC ", null)[0];}catch(Exception e){}
                                        %>
                                        <tr <%=(item.getIdEstatus()==2)?"class='inactive'":""%> >
                                            <td><input type="checkbox" name="check_id" id="check_id" value="<%= item.getIdCliente() %>"/></td>
                                            <td><%=item.getIdCliente() %></td>
                                            <td><%=item.getNombreComercial()%></td>
                                            <td><%=item.getContacto()!=null?item.getContacto():""%></td>
                                            <td><%=(item.getIdEstatus()==1)?"Activo":(item.getIdEstatus()==3?"Express":"Inactivo")%></td>
                                            <td>
                                                <% 
                                                if (usuario!=null){
                                                    DatosUsuario datosUsuarioVendedor = new DatosUsuarioBO(usuario.getIdDatosUsuario(), user.getConn()).getDatosUsuario();
                                                    if (datosUsuarioVendedor!=null){
                                                        out.print(StringManage.getValidString(datosUsuarioVendedor.getNombre())
                                                                + " " + StringManage.getValidString(datosUsuarioVendedor.getApellidoPat()));
                                                    }else{
                                                        out.print("<i>¡ No Existe !</i>");
                                                    }
                                                }else{
                                                       out.print("<i>-Sin Asignar-</i>"); 
                                                }
                                                %>
                                            </td>   
                                            <td><%=registroCheck!=null?DateManage.formatDateTimeToNormalMinutes(registroCheck.getFechaHora()):""%></td>
                                            <td><%=clienteCategoria!=null?clienteCategoria.getNombreClasificacion():""%></td>
                                            <td>
                                               
                                                <a href="<%=urlTo%>?<%=paramName%>=<%=item.getIdCliente()%>&acc=1&pagina=<%=paginaActual%>"><img src="../../images/icon_edit.png" alt="editar" class="help" title="Editar"/></a>
                                                &nbsp;&nbsp;
                                                <a href="<%=urlTo2%>?<%=paramName%>=<%=item.getIdCliente()%>&acc=Mapa"><img src="../../images/icon_movimiento.png" alt="localización" class="help" title="Localización"/></a>
                                                <!--<a href="#" onclick="eliminar('<%=item.getIdCliente()%>');"><img src="../../images/icon_delete.png" alt="eliminar" class="help" title="Eliminar"/></a>-->
                                                &nbsp;&nbsp;
                                                <!--<a href="<%=urlTo3%>?<%=paramName%>=<%=item.getIdCliente()%>&acc=CodigoBarras"><img src="../../images/icon_barras.png" alt="codigoBarras" class="help" title="Código Barras"/></a>-->
                                                <a href="<%=urlTo4%>?<%=paramName%>=<%=item.getIdCliente()%>&acc=Pop"><img src="../../images/icon_pop.png" alt="pop" class="help" title="Pop"/>
                                                &nbsp;&nbsp;
                                                <a href="<%=urlTo5%>?<%=paramName%>=<%=item.getIdCliente()%>&acc=Estanteria"><img src="../../images/icon_estanteria.png" alt="pop" class="help" title="Estanteria"/>
                                                &nbsp;&nbsp;
                                                <a href="<%=urlTo6%>?<%=paramName%>=<%=item.getIdCliente()%>&acc=DescargarImagenes"><img src="../../images/download.png" alt="downloadImages" class="help" title="Descargar imagenes"/>
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
                                    
                                    <br><br>
                                    <tbody>
                                        <tr>
                                        <td>
                                            <center>

                                            <a href="#" onclick="validaAsignacionClientes()" id="idCodigoBarraMultiple" title="Asignación Empleado">
                                                <img src="../../images/icon_users.png" alt="Asignación Empleado" title="Asignación de Registros Seleccionados" class="help" />
                                                Asignación a Empleado
                                            </a>
                                            
                                            </center>
                                        </td>
                                        </tr>
                                    </tbody>
                                    
                            <!-- INCLUDE OPCIONES DE EXPORTACIÓN-->
                            <jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <jsp:param name="idReport" value="<%= ReportBO.CLIENTE_REPORT %>" />
                                <jsp:param name="parametrosCustom" value="<%= filtroBusquedaEncoded %>" />
                            </jsp:include>
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

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>


    </body>
</html>
<%}%>