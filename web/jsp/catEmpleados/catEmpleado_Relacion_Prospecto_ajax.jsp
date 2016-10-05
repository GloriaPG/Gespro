<%-- 
    Document   : catEmpleado_Relacion_Prospecto_ajax
    Created on : 30/09/2016, 12:15:36 PM
    Author     : DXN
--%>
<%@page import="com.tsp.gespro.jdbc.RelacionProspectoVendedorDaoImpl"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.jdbc.DatosUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionProspectoVendedor"%>
<%@page import="com.tsp.gespro.bo.RelacionProspectoVendedorBO"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
    int idUsuarioEmpleado = -1;
    int idProspecto = -1;
    
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    try{
        idUsuarioEmpleado = Integer.parseInt(request.getParameter("idUsuarioEmpleado"));
    }catch(NumberFormatException ex){}
    
    try{
        idProspecto = Integer.parseInt(request.getParameter("idProspecto"));
    }catch(NumberFormatException ex){}   
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();    
    if(idUsuarioEmpleado <= 0){
        msgError += "<ul>El dato 'Promotor' es requerido";
    }  
    if(idProspecto <= 0){
        msgError += "<ul>El dato 'Prospecto' es requerido";
    }
    /*
    if(idVendedor<=0)
        msgError += "<ul>El dato 'Vendedor' es requerido";
 * */

    if(msgError.equals("")){
        if( (idProspecto > 0 && idUsuarioEmpleado > 0)){
            RelacionProspectoVendedorBO relacionProspectoVendedorBO = new RelacionProspectoVendedorBO(user.getConn());
            try{
                relacionProspectoVendedorBO.deleteProspecto(idProspecto);
            }catch(Exception ex){
                
            }
            RelacionProspectoVendedor prospectoVendedor = new RelacionProspectoVendedor();
            prospectoVendedor.setIdProspecto(idProspecto);
            prospectoVendedor.setIdUsuario(idUsuarioEmpleado);
            prospectoVendedor.setFechaAsignacion(new Date());
            try{
                new RelacionProspectoVendedorDaoImpl(user.getConn()).insert(prospectoVendedor);
                out.print("<!--EXITO-->Prospecto asignado satisfactoriamente");
            }catch(Exception ex){
                out.print("<!--ERROR-->No se pudo asignar el promotor. Informe del error al administrador del sistema: " + ex.toString());
                ex.printStackTrace();
            }
        }else{
            out.print("<!--ERROR-->No se selecciono un promotor.");
        }
    }else{
        out.print("<!--ERROR-->"+msgError);
    }

%>

