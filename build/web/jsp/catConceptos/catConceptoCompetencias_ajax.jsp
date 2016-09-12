<%-- 
    Document   : catConceptoCompetencias_ajax
    Created on : 27/10/2015, 05:24:10 PM
    Author     : leonardo
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.tsp.gespro.bo.RelacionConceptoCompetenciaBO"%>
<%@page import="com.tsp.gespro.mail.TspMailBO"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.jdbc.RelacionConceptoCompetenciaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionConceptoCompetencia"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
    int idRelacionConceptoCompetencia = -1;
    String nombreRelacionConceptoCompetencia ="";
    String descripcion ="";  
    int estatus = 2;//deshabilitado
    int idCompetencia = 0;
    int idConcepto = 0;
    double cantidadRelacionConceptoCompetencia = 0;
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    try{
        idRelacionConceptoCompetencia = Integer.parseInt(request.getParameter("idRelacionConceptoCompetencia"));
    }catch(NumberFormatException ex){}
    nombreRelacionConceptoCompetencia = request.getParameter("nombreRelacionConceptoCompetencia")!=null?new String(request.getParameter("nombreRelacionConceptoCompetencia").getBytes("ISO-8859-1"),"UTF-8"):"";
    descripcion = request.getParameter("descripcion")!=null?new String(request.getParameter("descripcion").getBytes("ISO-8859-1"),"UTF-8"):"";    
    try{
        estatus = Integer.parseInt(request.getParameter("estatus"));
    }catch(NumberFormatException ex){}
    try{
        idCompetencia = Integer.parseInt(request.getParameter("idCompetencia"));
    }catch(NumberFormatException ex){}
    try{
        idConcepto = Integer.parseInt(request.getParameter("idConcepto"));
    }catch(NumberFormatException ex){}
    try{
        cantidadRelacionConceptoCompetencia = Double.parseDouble(request.getParameter("cantidadRelacionConceptoCompetencia"));
    }catch(Exception ex){}
    
        
    String descripcionRelacionConceptoCompetencia = "";
    float precioRelacionConceptoCompetencia = 0;
    double maxPrecioMenudeoRelacionConceptoCompetencia = 0;
    float precioMedioMayoreoRelacionConceptoCompetencia = 0;
    double minPrecioMedioRelacionConceptoCompetencia = 0;
    double maxPrecioMedioRelacionConceptoCompetencia = 0;
    double precioMayoreoRelacionConceptoCompetencia = 0;
    double minPrecioMayoreoRelacionConceptoCompetencia = 0;
    double precioDocenaRelacionConceptoCompetencia = 0;
    double precioEspecialRelacionConceptoCompetencia = 0;
    
    descripcionRelacionConceptoCompetencia = request.getParameter("descripcionRelacionConceptoCompetencia")!=null?new String(request.getParameter("descripcionRelacionConceptoCompetencia").getBytes("ISO-8859-1"),"UTF-8"):"";
    
    try {
        precioRelacionConceptoCompetencia = Float.parseFloat(request.getParameter("precioRelacionConceptoCompetencia") != null ? new String(request.getParameter("precioRelacionConceptoCompetencia").getBytes("ISO-8859-1"), "UTF-8") : "");
    } catch (NumberFormatException ex) {}
    try{
        maxPrecioMenudeoRelacionConceptoCompetencia = Double.parseDouble(request.getParameter("maxPrecioMenudeoRelacionConceptoCompetencia"));
    }catch(Exception ex){}
    try{
        precioMedioMayoreoRelacionConceptoCompetencia = Float.parseFloat(request.getParameter("precioMedioMayoreoRelacionConceptoCompetencia"));
    }catch(Exception ex){}
    try{
        minPrecioMedioRelacionConceptoCompetencia = Double.parseDouble(request.getParameter("minPrecioMedioRelacionConceptoCompetencia"));
    }catch(Exception ex){}
    try{
        maxPrecioMedioRelacionConceptoCompetencia = Double.parseDouble(request.getParameter("maxPrecioMedioRelacionConceptoCompetencia"));
    }catch(Exception ex){}
    try{
        precioMayoreoRelacionConceptoCompetencia = Double.parseDouble(request.getParameter("precioMayoreoRelacionConceptoCompetencia"));
    }catch(Exception ex){}
    try{
        minPrecioMayoreoRelacionConceptoCompetencia = Double.parseDouble(request.getParameter("minPrecioMayoreoRelacionConceptoCompetencia"));
    }catch(Exception ex){}
    try{
        precioDocenaRelacionConceptoCompetencia = Double.parseDouble(request.getParameter("precioDocenaRelacionConceptoCompetencia"));
    }catch(Exception ex){}
    try{
        precioEspecialRelacionConceptoCompetencia = Double.parseDouble(request.getParameter("precioEspecialRelacionConceptoCompetencia"));
    }catch(Exception ex){}
     
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();    
    if(idCompetencia <= 0)
        msgError += "<ul>Selecciones un Competencia";    
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
            //verificamos si el listado de competencias por concepto esta en sesión; solo esto aplica cuando el concepto es nuevo y no se ha guardado:
            List<RelacionConceptoCompetencia> listaObjetosRelacionConceptoCompetencia = null;
            try{
                listaObjetosRelacionConceptoCompetencia = (ArrayList<RelacionConceptoCompetencia>)session.getAttribute("RelacionConceptoCompetenciaSesion");
            }catch(Exception e){}
                if(listaObjetosRelacionConceptoCompetencia != null){
                    listaObjetosRelacionConceptoCompetencia.remove(idRelacion);
                    session.setAttribute("RelacionConceptoCompetenciaSesion", listaObjetosRelacionConceptoCompetencia);
                }
            out.print("<!--EXITO-->Registro borrado satisfactoriamente.<br/>");
        }else if(mode.equals("eliminar")){
            RelacionConceptoCompetencia relacionConceptoCompetenciaDto = new RelacionConceptoCompetencia();            
            relacionConceptoCompetenciaDto = new RelacionConceptoCompetenciaBO(idRelacion, user.getConn()).getRelacionConceptoCompetencia();
            new RelacionConceptoCompetenciaDaoImpl(user.getConn()).delete(relacionConceptoCompetenciaDto.createPk());
            out.print("<!--EXITO-->Registro borrado satisfactoriamente.<br/>");
        }else if(mode.equals("modificarCompetencia")){ 
            RelacionConceptoCompetencia relacionConceptoCompetenciaDto = new RelacionConceptoCompetenciaDaoImpl(user.getConn()).findByPrimaryKey(idRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setIdConcepto(idConcepto);
            relacionConceptoCompetenciaDto.setIdCompetencia(idCompetencia);
            relacionConceptoCompetenciaDto.setCantidad(cantidadRelacionConceptoCompetencia);
            
            relacionConceptoCompetenciaDto.setNombreConceptoCompetencia(nombreRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setDescripcion(descripcionRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setPrecio(precioRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setPrecioDocena(precioDocenaRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setPrecioMedioMayoreo(precioMedioMayoreoRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setPrecioMayoreo(precioMayoreoRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setPrecioEspecial(precioEspecialRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setMaxMenudeo(maxPrecioMenudeoRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setMinMedioMayoreo(minPrecioMedioRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setMaxMedioMayoreo(maxPrecioMedioRelacionConceptoCompetencia);
            relacionConceptoCompetenciaDto.setMinMayoreo(minPrecioMayoreoRelacionConceptoCompetencia);
            
            new RelacionConceptoCompetenciaDaoImpl(user.getConn()).update(relacionConceptoCompetenciaDto.createPk(), relacionConceptoCompetenciaDto);
            out.print("<!--EXITO-->Registro actualizado satisfactoriamente.<br/>");
        }else{//falta colocar el de eliminar de base de datos
            
            /*
            *  Nuevo
            */
            
            try {                
                
                /**
                 * Creamos el registro de Cliente
                 */
                RelacionConceptoCompetencia relacionConceptoCompetenciaDto = new RelacionConceptoCompetencia();
                RelacionConceptoCompetenciaDaoImpl relacionConceptoCompetenciasDaoImpl = new RelacionConceptoCompetenciaDaoImpl(user.getConn());
                
                relacionConceptoCompetenciaDto.setIdConcepto(idConcepto);
                relacionConceptoCompetenciaDto.setIdCompetencia(idCompetencia);
                relacionConceptoCompetenciaDto.setCantidad(cantidadRelacionConceptoCompetencia);
                
                relacionConceptoCompetenciaDto.setNombreConceptoCompetencia(nombreRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setDescripcion(descripcionRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setPrecio(precioRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setPrecioDocena(precioDocenaRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setPrecioMedioMayoreo(precioMedioMayoreoRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setPrecioMayoreo(precioMayoreoRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setPrecioEspecial(precioEspecialRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setMaxMenudeo(maxPrecioMenudeoRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setMinMedioMayoreo(minPrecioMedioRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setMaxMedioMayoreo(maxPrecioMedioRelacionConceptoCompetencia);
                relacionConceptoCompetenciaDto.setMinMayoreo(minPrecioMayoreoRelacionConceptoCompetencia);
                
                if(idConcepto == 0){//cargamos en sesion el listado de competencias que se van a cargar al concepto:
                    List<RelacionConceptoCompetencia> listaObjetosRelacionConceptoCompetencia = null;
                    try{
                        listaObjetosRelacionConceptoCompetencia = (ArrayList<RelacionConceptoCompetencia>)session.getAttribute("RelacionConceptoCompetenciaSesion");
                    }catch(Exception e){}
                    if(listaObjetosRelacionConceptoCompetencia == null){
                        listaObjetosRelacionConceptoCompetencia = new ArrayList<RelacionConceptoCompetencia>();
                    }
                    listaObjetosRelacionConceptoCompetencia.add(relacionConceptoCompetenciaDto);
                    session.setAttribute("RelacionConceptoCompetenciaSesion", listaObjetosRelacionConceptoCompetencia);
                }else{//si ya esta creado el concepto solo lo agregamos a la base de datos

                /**
                 * Realizamos el insert
                 */
                    relacionConceptoCompetenciasDaoImpl.insert(relacionConceptoCompetenciaDto);
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