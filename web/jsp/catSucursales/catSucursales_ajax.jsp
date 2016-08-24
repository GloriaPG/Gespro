<%-- 
    Document   : catSucursales_ajax
    Created on : 28/11/2012, 01:32:21 PM
    Author     : Leonardo
--%>

<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.bo.UbicacionBO"%>
<%@page import="com.tsp.gespro.dto.UbicacionPk"%>
<%@page import="com.tsp.gespro.jdbc.UbicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ubicacion"%>
<%@page import="com.tsp.gespro.dto.Ubicacion"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.mail.TspMailBO"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
    int idEmpresaSucursal = -1;
    String nombreSucursal ="";
    int creditos = 0;
    String calle ="";  
    String ext =""; 
    String inte =""; 
    String colonia =""; 
    String cp =""; 
    String pais =""; 
    String estado =""; 
    String delMuni =""; 
    int estatus = 2;//deshabilitado
   
       
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
        try{
            idEmpresaSucursal = Integer.parseInt(request.getParameter("idEmpresa"));
        }catch(NumberFormatException ex){}
        nombreSucursal = request.getParameter("nombreSucursal")!=null?new String(request.getParameter("nombreSucursal").getBytes("ISO-8859-1"),"UTF-8"):"";
         try{
            creditos = Integer.parseInt(request.getParameter("creditos"));
        }catch(NumberFormatException ex){}
        calle = request.getParameter("calle")!=null?new String(request.getParameter("calle").getBytes("ISO-8859-1"),"UTF-8"):"";    
        ext = request.getParameter("ext")!=null?new String(request.getParameter("ext").getBytes("ISO-8859-1"),"UTF-8"):"";    
        inte = request.getParameter("int")!=null?new String(request.getParameter("int").getBytes("ISO-8859-1"),"UTF-8"):"";    
        colonia = request.getParameter("colonia")!=null?new String(request.getParameter("colonia").getBytes("ISO-8859-1"),"UTF-8"):"";    
        cp = request.getParameter("cp")!=null?new String(request.getParameter("cp").getBytes("ISO-8859-1"),"UTF-8"):"";    
        pais = request.getParameter("pais")!=null?new String(request.getParameter("pais").getBytes("ISO-8859-1"),"UTF-8"):"";    
        estado = request.getParameter("estado")!=null?new String(request.getParameter("estado").getBytes("ISO-8859-1"),"UTF-8"):"";
        delMuni = request.getParameter("delMuni")!=null?new String(request.getParameter("delMuni").getBytes("ISO-8859-1"),"UTF-8"):"";    
        try{
            estatus = Integer.parseInt(request.getParameter("estatus"));
        }catch(NumberFormatException ex){}   


        EmpresaBO empresaBO = new EmpresaBO(user.getConn());
        EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());     

        /*
        * Validaciones del servidor
        */
        String msgError = "";
        GenericValidator gc = new GenericValidator();    
        if(!gc.isValidString(nombreSucursal, 1, 100))
            msgError += "<ul>El dato 'nombre comercial' es requerido.";
        if(!gc.isValidString(calle, 1, 100))
            msgError += "<ul>El dato 'calle' es requerido";
        if(!gc.isValidString(ext, 1, 30))
            msgError += "<ul>El dato 'número exterior' es requerido";
        if(!gc.isValidString(colonia, 1, 100))
            msgError += "<ul>El dato 'colonia' es requerido";    
        if(!gc.isValidString(cp, 1, 5))
            msgError += "<ul>El dato 'codigo postal' es invalido."; 
        if(!gc.isValidString(pais, 1, 100))
            msgError += "<ul>El dato 'pais' es requerido";
        if(!gc.isValidString(delMuni, 1, 100))
            msgError += "<ul>El dato 'delegación/municipio' es requerido";                  
        if(!gc.isValidString(estado, 1, 50))
            msgError += "<ul>El dato 'estado' es requerido";  
        if(idEmpresaSucursal <= 0 && (!mode.equals("")))
            msgError += "<ul>El dato ID 'empresa' es requerido";
        /*
        if(idVendedor<=0)
            msgError += "<ul>El dato 'Vendedor' es requerido";
     * */

        if(msgError.equals("")){
            if(idEmpresaSucursal>0){
                if (mode.equals("1")){
                /*
                * Editar
                */
                    empresaBO = new EmpresaBO(idEmpresaSucursal,user.getConn());
                    Empresa empresaDto = empresaBO.getEmpresa();

                    Empresa datoEmpresaLogeada = new EmpresaDaoImpl(user.getConn()).findByPrimaryKey(idEmpresa); //Para recuperar los datos de la empresa logeada

                    empresaDto.setIdEstatus(estatus);
                    empresaDto.setIdEmpresaPadre(idEmpresa);                        
                    empresaDto.setIdUbicacionFiscal(empresaBO.getEmpresa().getIdUbicacionFiscal());
                    empresaDto.setIdTipoEmpresa(4); // 4:Sucursal
                    empresaDto.setRfc(datoEmpresaLogeada.getRfc());
                    empresaDto.setRazonSocial(datoEmpresaLogeada.getRazonSocial());
                    empresaDto.setNombreComercial(nombreSucursal);               
                    empresaDto.setRegimenFiscal(datoEmpresaLogeada.getRegimenFiscal());


                    UbicacionBO ubicacionBO = new UbicacionBO(empresaBO.getEmpresa().getIdUbicacionFiscal(),user.getConn());
                    Ubicacion ubicacionDto = ubicacionBO.getUbicacion();

                    ubicacionDto.setCalle(calle);
                    ubicacionDto.setNumExt(ext);
                    ubicacionDto.setNumInt(inte);
                    ubicacionDto.setColonia(colonia);
                    ubicacionDto.setCodigoPostal(cp);
                    ubicacionDto.setPais(pais);
                    ubicacionDto.setEstado(estado);
                    ubicacionDto.setMunicipio(delMuni);

                    try{
                        new EmpresaDaoImpl(user.getConn()).update(empresaDto.createPk(), empresaDto);
                        new UbicacionDaoImpl(user.getConn()).update(ubicacionDto.createPk(), ubicacionDto);
                        
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

                    //REALIZAMOS EL INSERT DE LA UBICACION FISCAL
                    Ubicacion ubicacionDto = new Ubicacion();
                    UbicacionDaoImpl ubicacionesDaoImpl = new UbicacionDaoImpl(user.getConn());

                    ubicacionDto.setCalle(calle);
                    ubicacionDto.setNumExt(ext);
                    ubicacionDto.setNumInt(inte);
                    ubicacionDto.setColonia(colonia);
                    ubicacionDto.setCodigoPostal(cp);
                    ubicacionDto.setPais(pais);
                    ubicacionDto.setEstado(estado);
                    ubicacionDto.setMunicipio(delMuni);

                     /**
                     * Realizamos el insert
                     */
                    UbicacionPk ubicacionPk = ubicacionesDaoImpl.insert(ubicacionDto);

                    /**
                    * Creamos el registro de Empresa
                    */
                    Empresa empresaDto = new Empresa();
                    EmpresaDaoImpl empresasDaoImpl = new EmpresaDaoImpl(user.getConn());




                    Empresa datoEmpresaLogeada = empresasDaoImpl.findByPrimaryKey(idEmpresa); //Para recuperar los datos de la empresa logeada


                    empresaDto.setIdEstatus(estatus);
                    empresaDto.setIdEmpresaPadre(idEmpresa);                        
                    empresaDto.setIdUbicacionFiscal(ubicacionPk.getIdUbicacion());
                    empresaDto.setIdTipoEmpresa(4); // 4:Sucursal
                    empresaDto.setRfc(datoEmpresaLogeada.getRfc());
                    empresaDto.setRazonSocial(datoEmpresaLogeada.getRazonSocial());
                    empresaDto.setNombreComercial(nombreSucursal);               
                    empresaDto.setRegimenFiscal(datoEmpresaLogeada.getRegimenFiscal());                
                    
                    /**
                     * Realizamos el insert
                     */
                    empresasDaoImpl.insert(empresaDto);
                        
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