<%-- 
    Document   : catCompetencias_ajax
    Created on : 26/10/2015, 05:50:56 PM
    Author     : leonardo
--%>

<%@page import="java.util.regex.Matcher"%>
<%@page import="com.tsp.gespro.bo.CompetenciaBO"%>
<%@page import="com.tsp.gespro.mail.TspMailBO"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.jdbc.CompetenciaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Competencia"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
    int idCompetencia = -1;
    String nombreCompetencia ="";
    String descripcion ="";  
    int estatus = 2;//deshabilitado
    
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    try{
        idCompetencia = Integer.parseInt(request.getParameter("idCompetencia"));
    }catch(NumberFormatException ex){}
    nombreCompetencia = request.getParameter("nombreCompetencia")!=null?new String(request.getParameter("nombreCompetencia").getBytes("ISO-8859-1"),"UTF-8"):"";
    descripcion = request.getParameter("descripcion")!=null?new String(request.getParameter("descripcion").getBytes("ISO-8859-1"),"UTF-8"):"";    
    try{
        estatus = Integer.parseInt(request.getParameter("estatus"));
    }catch(NumberFormatException ex){}   
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();    
    if(!gc.isValidString(nombreCompetencia, 1, 30))
        msgError += "<ul>El dato 'nombre' es requerido.";
    if(!gc.isValidString(descripcion, 1, 100))
        msgError += "<ul>El dato 'descripción' es requerido";   
    if(idCompetencia <= 0 && (!mode.equals("")))
        msgError += "<ul>El dato ID 'competencia' es requerido";
    /*
    if(idVendedor<=0)
        msgError += "<ul>El dato 'Vendedor' es requerido";
 * */

    if(msgError.equals("")){
        if(idCompetencia>0){
            if (mode.equals("1")){
            /*
            * Editar
            */
                CompetenciaBO competenciaBO = new CompetenciaBO(idCompetencia,user.getConn());
                Competencia competenciaDto = competenciaBO.getCompetencia();
                
                competenciaDto.setIdEstatus(estatus);
                competenciaDto.setNombre(nombreCompetencia);
                competenciaDto.setDescripcion(descripcion);
               
                
                try{
                    new CompetenciaDaoImpl(user.getConn()).update(competenciaDto.createPk(), competenciaDto);

                    out.print("<!--EXITO-->Registro actualizado satisfactoriamente");
                }catch(Exception ex){
                    out.print("<!--ERROR-->No se pudo actualizar el registro. Informe del error al administrador del sistema: " + ex.toString());
                    ex.printStackTrace();
                }
                
            }else{
                out.print("<!--ERROR-->Acción no válida.");
            }
        }else{
            /*
            *  Nuevo
            */
            
            try {                
                
                /**
                 * Creamos el registro de Cliente
                 */
                Competencia competenciaDto = new Competencia();
                CompetenciaDaoImpl competenciasDaoImpl = new CompetenciaDaoImpl(user.getConn());
                
                competenciaDto.setIdEstatus(estatus);
                competenciaDto.setNombre(nombreCompetencia);
                competenciaDto.setDescripcion(descripcion);                              
                competenciaDto.setIdEmpresa(idEmpresa);

                /**
                 * Realizamos el insert
                 */
                competenciasDaoImpl.insert(competenciaDto);

                out.print("<!--EXITO-->Registro creado satisfactoriamente.<br/>");
            
            }catch(Exception e){
                e.printStackTrace();
                msgError += "Ocurrio un error al guardar el registro: " + e.toString() ;
            }
        }
    }else{
        out.print("<!--ERROR-->"+msgError);
    }

%>