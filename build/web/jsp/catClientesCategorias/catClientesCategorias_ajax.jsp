<%-- 
    Document   : newjspcatClientesCategorias_ajax
    Created on : 3/07/2015, 03:45:48 PM
    Author     : leonardo
--%>

<%@page import="java.util.regex.Matcher"%>
<%@page import="com.tsp.gespro.bo.ClienteCategoriaBO"%>
<%@page import="com.tsp.gespro.mail.TspMailBO"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.jdbc.ClienteCategoriaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.ClienteCategoria"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
    int idClienteCategoria = -1;
    String nombreClienteCategoria ="";
    String descripcion ="";  
    int estatus = 2;//deshabilitado
    
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    try{
        idClienteCategoria = Integer.parseInt(request.getParameter("idClienteCategoria"));
    }catch(NumberFormatException ex){}
    nombreClienteCategoria = request.getParameter("nombreClienteCategoria")!=null?new String(request.getParameter("nombreClienteCategoria").getBytes("ISO-8859-1"),"UTF-8"):"";
    descripcion = request.getParameter("descripcion")!=null?new String(request.getParameter("descripcion").getBytes("ISO-8859-1"),"UTF-8"):"";    
    try{
        estatus = Integer.parseInt(request.getParameter("estatus"));
    }catch(NumberFormatException ex){}   
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();    
    if(!gc.isValidString(nombreClienteCategoria, 1, 30))
        msgError += "<ul>El dato 'nombre' es requerido.";
    if(!gc.isValidString(descripcion, 1, 100))
        msgError += "<ul>El dato 'descripción' es requerido";   
    if(idClienteCategoria <= 0 && (!mode.equals("")))
        msgError += "<ul>El dato ID 'ClienteCategoria' es requerido";
   
    if(msgError.equals("")){
        if(idClienteCategoria>0){
            if (mode.equals("1")){
            /*
            * Editar
            */
                ClienteCategoriaBO clienteCategoriaBO = new ClienteCategoriaBO(idClienteCategoria,user.getConn());
                ClienteCategoria clienteCategoriaDto = clienteCategoriaBO.getClienteCategoria();
                
                clienteCategoriaDto.setIdEstatus(estatus);
                clienteCategoriaDto.setNombreClasificacion(nombreClienteCategoria);
                clienteCategoriaDto.setDescripcion(descripcion);
               
                
                try{
                    new ClienteCategoriaDaoImpl(user.getConn()).update(clienteCategoriaDto.createPk(), clienteCategoriaDto);

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
                ClienteCategoria clienteCategoriaDto = new ClienteCategoria();
                ClienteCategoriaDaoImpl clienteCategoriasDaoImpl = new ClienteCategoriaDaoImpl(user.getConn());
                
                clienteCategoriaDto.setIdEstatus(estatus);
                clienteCategoriaDto.setNombreClasificacion(nombreClienteCategoria);
                clienteCategoriaDto.setDescripcion(descripcion);                              
                clienteCategoriaDto.setIdEmpresa(idEmpresa);

                /**
                 * Realizamos el insert
                 */
                clienteCategoriasDaoImpl.insert(clienteCategoriaDto);

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