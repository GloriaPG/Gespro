<%-- 
    Document   : cat_Seguimiento_ajax
    Created on : 23/05/2013, 07:07:07 PM
    Author     : Leonardo
--%>

<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.tsp.gespro.bo.PosMovilEstatusParametrosBO"%>
<%@page import="com.tsp.gespro.mail.TspMailBO"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.PosMovilEstatusParametrosDaoImpl"%>
<%@page import="com.tsp.gespro.dto.PosMovilEstatusParametros"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
 
    int minutosPosMovil = 0;
    
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
   
    
    try{
        minutosPosMovil = Integer.parseInt(request.getParameter("minutosPosMovil"));
    }catch(NumberFormatException ex){}   
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();        
    if(minutosPosMovil<0 ){
        msgError += "<ul>El dato 'Tiempo' es requerido";
    }
    
    if(msgError.equals("")){
        if(minutosPosMovil>=0){
            try{
                UsuariosBO usuariosBO = new UsuariosBO(user.getConn());
                Usuarios[] usuariosDto = new Usuarios[0];

                String filtroBusqueda =  " AND ID_ROLES = 4 ";
                usuariosDto = usuariosBO.findUsuarios(-1, idEmpresa , 0, 0, filtroBusqueda);


                if(usuariosDto.length>0){

                    for(Usuarios usu:usuariosDto){
                        usu.setMinutosEstatus(minutosPosMovil);

                        new UsuariosDaoImpl().update(usu.createPk(), usu);                    
                    }
                }

                out.print("<!--EXITO-->Registro actualizado satisfactoriamente");
            }catch(Exception ex){
                out.print("<!--ERROR-->No se pudo actualizar el registro. Informe del error al administrador del sistema: " + ex.toString());
                ex.printStackTrace();
            }
        }else{
            msgError += "Tiempo no especificado.";
        }
    }else{
        out.print("<!--ERROR-->"+msgError);
    }

%>