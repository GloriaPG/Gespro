<%-- 
    Document   : catConceptoEmbalajes_ajax
    Created on : 27/10/2015, 12:26:42 PM
    Author     : leonardo
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.tsp.gespro.bo.RelacionConceptoEmbalajeBO"%>
<%@page import="com.tsp.gespro.mail.TspMailBO"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.jdbc.RelacionConceptoEmbalajeDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionConceptoEmbalaje"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
    int idRelacionConceptoEmbalaje = -1;
    String nombreRelacionConceptoEmbalaje ="";
    String descripcion ="";  
    int estatus = 2;//deshabilitado
    int idEmbalaje = 0;
    int idConcepto = 0;
    double cantidadRelacionConceptoEmbalaje = 0;
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    try{
        idRelacionConceptoEmbalaje = Integer.parseInt(request.getParameter("idRelacionConceptoEmbalaje"));
    }catch(NumberFormatException ex){}
    nombreRelacionConceptoEmbalaje = request.getParameter("nombreRelacionConceptoEmbalaje")!=null?new String(request.getParameter("nombreRelacionConceptoEmbalaje").getBytes("ISO-8859-1"),"UTF-8"):"";
    descripcion = request.getParameter("descripcion")!=null?new String(request.getParameter("descripcion").getBytes("ISO-8859-1"),"UTF-8"):"";    
    try{
        estatus = Integer.parseInt(request.getParameter("estatus"));
    }catch(NumberFormatException ex){}
    try{
        idEmbalaje = Integer.parseInt(request.getParameter("idEmbalaje"));
    }catch(NumberFormatException ex){}
    try{
        idConcepto = Integer.parseInt(request.getParameter("idConcepto"));
    }catch(NumberFormatException ex){}
    try{
        cantidadRelacionConceptoEmbalaje = Double.parseDouble(request.getParameter("cantidadRelacionConceptoEmbalaje"));
    }catch(Exception ex){}
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();    
    if(idEmbalaje <= 0)
        msgError += "<ul>Selecciones un Embalaje";    
    /*
    if(idVendedor<=0)
        msgError += "<ul>El dato 'Vendedor' es requerido";
 * */
    int datosSesion = 0;
    try{
        datosSesion = Integer.parseInt(request.getParameter("datosSesion"));
    }catch(NumberFormatException ex){}
    int idRelacion = 0;
    try{
        idRelacion = Integer.parseInt(request.getParameter("idRelacion"));
    }catch(NumberFormatException ex){}
    
    if(msgError.equals("")){   
        if(mode.equals("eliminar") && (datosSesion == 1)){//eliminamos el dato de sesion
            //verificamos si el listado de embalajes por concepto esta en sesión; solo esto aplica cuando el concepto es nuevo y no se ha guardado:
            List<RelacionConceptoEmbalaje> listaObjetosRelacionConceptoEmbalaje = null;
            try{
                listaObjetosRelacionConceptoEmbalaje = (ArrayList<RelacionConceptoEmbalaje>)session.getAttribute("RelacionConceptoEmbalajeSesion");
            }catch(Exception e){}
                if(listaObjetosRelacionConceptoEmbalaje != null){
                    listaObjetosRelacionConceptoEmbalaje.remove(idRelacion);
                    session.setAttribute("RelacionConceptoEmbalajeSesion", listaObjetosRelacionConceptoEmbalaje);
                }
            out.print("<!--EXITO-->Registro borrado satisfactoriamente.<br/>");
        }else if(mode.equals("eliminar")){
            RelacionConceptoEmbalaje relacionConceptoEmbalajeDto = new RelacionConceptoEmbalaje();            
            relacionConceptoEmbalajeDto = new RelacionConceptoEmbalajeBO(idRelacion, user.getConn()).getRelacionConceptoEmbalaje();
            new RelacionConceptoEmbalajeDaoImpl(user.getConn()).delete(relacionConceptoEmbalajeDto.createPk());
            out.print("<!--EXITO-->Registro borrado satisfactoriamente.<br/>");
        }else if(mode.equals("modificarEmbalaje")){ 
            RelacionConceptoEmbalaje relacionConceptoEmbalajeDto = new RelacionConceptoEmbalajeDaoImpl(user.getConn()).findByPrimaryKey(idRelacionConceptoEmbalaje);
            relacionConceptoEmbalajeDto.setIdConcepto(idConcepto);
            relacionConceptoEmbalajeDto.setIdEmbalaje(idEmbalaje);
            relacionConceptoEmbalajeDto.setCantidad(cantidadRelacionConceptoEmbalaje);
            new RelacionConceptoEmbalajeDaoImpl(user.getConn()).update(relacionConceptoEmbalajeDto.createPk(), relacionConceptoEmbalajeDto);
            out.print("<!--EXITO-->Registro actualizado satisfactoriamente.<br/>");
        }else{//falta colocar el de eliminar de base de datos
            
            /*
            *  Nuevo
            */
            
            try {                
                
                /**
                 * Creamos el registro de Cliente
                 */
                RelacionConceptoEmbalaje relacionConceptoEmbalajeDto = new RelacionConceptoEmbalaje();
                RelacionConceptoEmbalajeDaoImpl relacionConceptoEmbalajesDaoImpl = new RelacionConceptoEmbalajeDaoImpl(user.getConn());
                
                relacionConceptoEmbalajeDto.setIdConcepto(idConcepto);
                relacionConceptoEmbalajeDto.setIdEmbalaje(idEmbalaje);
                relacionConceptoEmbalajeDto.setCantidad(cantidadRelacionConceptoEmbalaje);
                
                if(idConcepto == 0){//cargamos en sesion el listado de embalajes que se van a cargar al concepto:
                    List<RelacionConceptoEmbalaje> listaObjetosRelacionConceptoEmbalaje = null;
                    try{
                        listaObjetosRelacionConceptoEmbalaje = (ArrayList<RelacionConceptoEmbalaje>)session.getAttribute("RelacionConceptoEmbalajeSesion");
                    }catch(Exception e){}
                    if(listaObjetosRelacionConceptoEmbalaje == null){
                        listaObjetosRelacionConceptoEmbalaje = new ArrayList<RelacionConceptoEmbalaje>();
                    }
                    listaObjetosRelacionConceptoEmbalaje.add(relacionConceptoEmbalajeDto);
                    session.setAttribute("RelacionConceptoEmbalajeSesion", listaObjetosRelacionConceptoEmbalaje);
                }else{//si ya esta creado el concepto solo lo agregamos a la base de datos

                /**
                 * Realizamos el insert
                 */
                    relacionConceptoEmbalajesDaoImpl.insert(relacionConceptoEmbalajeDto);
                }

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