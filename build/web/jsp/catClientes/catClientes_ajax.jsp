<%-- 
    Document   : catClientes_ajax
    Created on : 26-oct-2012, 13:48:45
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.dto.ClientePk"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.jdbc.RelacionClienteVendedorDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionClienteVendedor"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.mail.TspMailBO"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.jdbc.ClienteDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
    int idCliente = -1;
    int idClienteCategoria = 0;
    int periodoVisita = 1;
    String rfc ="";
    String razonSocial ="";
    String nombre ="";
    String apaterno="";
    String amaterno="";
    
    String calle="";
    String numero="";
    String numeroInt="";
    String colonia="";
    String cp="";
    String municipio="";
    String estado="";
    String pais="";
    String referencia = "";
    
    String lada="";
    String telefono="";
    String extension="";
    String celular="";
    String email="";
    String contacto="";
    double latitud = 0;
    double longitud = 0;
    
    String claveCliente = "";
    
    int idVendedor = -1;
    int estatus = 2;//deshabilitado
    int permisoVentaCredito = 2;//deshabilitado
    String nombreComercial="";
    
    int idSucursalEmpresaAsignado = idEmpresa;
    
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    try{
        idCliente = Integer.parseInt(request.getParameter("idCliente"));
    }catch(NumberFormatException ex){}
    try{
        idClienteCategoria = Integer.parseInt(request.getParameter("idClienteCategoria"));
    }catch(NumberFormatException ex){}
    rfc = request.getParameter("rfc")!=null?new String(request.getParameter("rfc").getBytes("ISO-8859-1"),"UTF-8"):"";
    razonSocial = request.getParameter("razonSocial")!=null?new String(request.getParameter("razonSocial").getBytes("ISO-8859-1"),"UTF-8"):"";
    nombre = request.getParameter("nombre")!=null?new String(request.getParameter("nombre").getBytes("ISO-8859-1"),"UTF-8"):"";
    apaterno = request.getParameter("apaterno")!=null?new String(request.getParameter("apaterno").getBytes("ISO-8859-1"),"UTF-8"):"";
    amaterno = request.getParameter("amaterno")!=null?new String(request.getParameter("amaterno").getBytes("ISO-8859-1"),"UTF-8"):"";
    calle = request.getParameter("calle")!=null?new String(request.getParameter("calle").getBytes("ISO-8859-1"),"UTF-8"):"";
    numero = request.getParameter("numero")!=null?new String(request.getParameter("numero").getBytes("ISO-8859-1"),"UTF-8"):"";
    numeroInt = request.getParameter("numeroInt")!=null?new String(request.getParameter("numeroInt").getBytes("ISO-8859-1"),"UTF-8"):"";
    colonia = request.getParameter("colonia")!=null?new String(request.getParameter("colonia").getBytes("ISO-8859-1"),"UTF-8"):"";
    municipio = request.getParameter("municipio")!=null?new String(request.getParameter("municipio").getBytes("ISO-8859-1"),"UTF-8"):"";
    estado = request.getParameter("estado")!=null?new String(request.getParameter("estado").getBytes("ISO-8859-1"),"UTF-8"):"";
    pais = request.getParameter("pais")!=null?new String(request.getParameter("pais").getBytes("ISO-8859-1"),"UTF-8"):"";
    referencia = request.getParameter("referenciaDir")!=null?new String(request.getParameter("referenciaDir").getBytes("ISO-8859-1"),"UTF-8"):"";
    cp = request.getParameter("cp")!=null?new String(request.getParameter("cp").getBytes("ISO-8859-1"),"UTF-8"):"";
    lada = request.getParameter("lada")!=null?new String(request.getParameter("lada").getBytes("ISO-8859-1"),"UTF-8"):"";
    telefono = request.getParameter("telefono")!=null?new String(request.getParameter("telefono").getBytes("ISO-8859-1"),"UTF-8"):"";
    extension = request.getParameter("extension")!=null?new String(request.getParameter("extension").getBytes("ISO-8859-1"),"UTF-8"):"";
    celular = request.getParameter("celular")!=null?new String(request.getParameter("celular").getBytes("ISO-8859-1"),"UTF-8"):"";
    email = request.getParameter("email")!=null?new String(request.getParameter("email").getBytes("ISO-8859-1"),"UTF-8"):"";
    contacto = request.getParameter("contacto")!=null?new String(request.getParameter("contacto").getBytes("ISO-8859-1"),"UTF-8"):"";    
    nombreComercial = request.getParameter("nombreComercial")!=null?new String(request.getParameter("nombreComercial").getBytes("ISO-8859-1"),"UTF-8"):"";
    
    claveCliente = request.getParameter("claveCliente")!=null?new String(request.getParameter("claveCliente").getBytes("ISO-8859-1"),"UTF-8"):"";
    
    try{
        latitud = Double.parseDouble(request.getParameter("latitud"));
        longitud = Double.parseDouble(request.getParameter("longitud"));
    }catch(Exception ex){}   
    try{
        estatus = Integer.parseInt(request.getParameter("estatus"));
    }catch(NumberFormatException ex){}
    try{
        idVendedor = Integer.parseInt(request.getParameter("idVendedor"));
    }catch(NumberFormatException ex){}
    try{
        periodoVisita = Integer.parseInt(request.getParameter("periodo"));
    }catch(NumberFormatException ex){}
    try{
        permisoVentaCredito = Integer.parseInt(request.getParameter("ventaCredito"));
    }catch(NumberFormatException ex){}
        
    try{
        int idSucursalTemportal = Integer.parseInt(request.getParameter("idSucursalEmpresaAsignado"));        
        if(idSucursalTemportal > 0){
            idSucursalEmpresaAsignado = idSucursalTemportal;
        }
        
    }catch(NumberFormatException ex){}
    
    
        
    if(rfc.trim().equals(""))
        rfc = "XAXX010101000";
    
    
    ///**Dias de visita
    /*String domingoReporte = request.getParameter("domingoReporte")!=null?new String(request.getParameter("domingoReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String lunesReporte = request.getParameter("lunesReporte")!=null?new String(request.getParameter("lunesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String martesReporte = request.getParameter("martesReporte")!=null?new String(request.getParameter("martesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String miercolesReporte = request.getParameter("miercolesReporte")!=null?new String(request.getParameter("miercolesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String juevesReporte = request.getParameter("juevesReporte")!=null?new String(request.getParameter("juevesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String viernesReporte = request.getParameter("viernesReporte")!=null?new String(request.getParameter("viernesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String sabadoReporte = request.getParameter("sabadoReporte")!=null?new String(request.getParameter("sabadoReporte").getBytes("ISO-8859-1"),"UTF-8"):"";
    */ ///**
    
    EmpresaBO empresaBO = new EmpresaBO(user.getConn());
    EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());     
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();
    
    System.out.println("_________MODE: "+mode);
    
    
   ////--**recuperamos datos y Ids de campos personalizados:   
/*        ClienteCampoAdicional[] clienteCampoAdicionalsDto = new ClienteCampoAdicional[0];
        ClienteCampoAdicionalBO clienteCampoAdicionalBO = new ClienteCampoAdicionalBO(user.getConn());
        
        List<ClienteCampoContenido> clienteCampoContenidos = new ArrayList<ClienteCampoContenido>();
        
        try{
            clienteCampoAdicionalsDto = clienteCampoAdicionalBO.findClienteCampoAdicionals(0, idEmpresa , 0, 0, " AND ID_ESTATUS = 1 "); 
            int identificadorCampoAdicional = -1;
            String valorCampoPersonalizado = "";
            for(ClienteCampoAdicional cliCampo : clienteCampoAdicionalsDto){
                ClienteCampoContenido clienteCampoContenido = new ClienteCampoContenido();
                identificadorCampoAdicional = -1;
                valorCampoPersonalizado = request.getParameter(cliCampo.getLabelNombre())!=null?new String(request.getParameter(cliCampo.getLabelNombre()).getBytes("ISO-8859-1"),"UTF-8"):"";
                try{
                    identificadorCampoAdicional = Integer.parseInt(request.getParameter("idCliCampAdi_"+cliCampo.getIdClienteCampo()));
                    
                    if(cliCampo.getTipoLabel() == 1){//validamos si es de tipo numerico, entonces debe ser solo numerico
                        if(!gc.isNumeric(valorCampoPersonalizado, 1, 20)){
                             msgError += "<ul>El tipo de dato numerico no es valido para: "+ cliCampo.getLabelNombre();
                        }
                    }
                    
                    if(!valorCampoPersonalizado.trim().equals("")){
                        clienteCampoContenido.setIdClienteCampo(identificadorCampoAdicional);
                        clienteCampoContenido.setValorLabel( valorCampoPersonalizado );
                        clienteCampoContenidos.add(clienteCampoContenido);
                    }
                }catch(NumberFormatException ex){}
                //cliCampo.setValorLabel( request.getParameter(cliCampo.getLabelNombre())!=null?new String(request.getParameter(cliCampo.getLabelNombre()).getBytes("ISO-8859-1"),"UTF-8"):"" );
            }
        }catch(Exception e){}
*/   ////--**
    
    if(mode.equals("express")){ //si el cliente será creado como cliene express
        //validamos unicamente lo siguiente:
        if(razonSocial.trim().equals("") && nombre.trim().equals("") && apaterno.trim().equals("")){
             msgError += "<ul>El dato 'nombre, apellidos o Razon Social' es requerido";
        }else{
            if(razonSocial.trim().equals("")){
                if(!gc.isValidString(nombre, 1, 100))
                    msgError += "<ul>El dato 'nombre' es requerido";
                if(!gc.isValidString(apaterno, 0, 100))
                    msgError += "<ul>El dato 'apellido paterno' es requerido";
            }
            if(nombre.trim().equals("") && apaterno.trim().equals("")){
                if(!gc.isValidString(razonSocial, 1, 200))
                msgError += "<ul>El dato 'razon Social' es requerido.";
            }            
        }
        if(msgError.equals("")){
                /*
                *  Nuevo Express
                */

                try {
                    /**
                     * Creamos el registro de Cliente de maneta express (con ID_ESTATUS = 3)
                     */
                    if(idCliente>0){//edita express
                        ClienteBO clienteBO = new ClienteBO(idCliente,user.getConn());
                        Cliente clienteDto = clienteBO.getCliente();
                        
                        
                        clienteDto.setIdEstatus(3); // de que va a faltar que sea editado, ya que se creo de tipo express
                        /*clienteDto.setRfcCliente(rfc);
                        clienteDto.setRazonSocial(razonSocial);
                        clienteDto.setNombreCliente(nombre);
                        clienteDto.setApellidoPaternoCliente(apaterno);
                        clienteDto.setApellidoMaternoCliente(amaterno);*/
                        clienteDto.setCalle(calle);
                        clienteDto.setNumero(numero);
                        clienteDto.setNumeroInterior(numeroInt);
                        clienteDto.setCodigoPostal(cp);
                        clienteDto.setColonia(colonia);
                        clienteDto.setMunicipio(municipio);
                        clienteDto.setEstado(estado);
                        clienteDto.setPais(pais);
                        //clienteDto.setLada(lada);
                        clienteDto.setTelefono(telefono);
                        //clienteDto.setExtension(extension);
                        //clienteDto.setCelular(celular);
                        clienteDto.setCorreo(email);
                        clienteDto.setContacto(contacto);
                        //clienteDto.setGenerico(0);
                        clienteDto.setIdEmpresa(idSucursalEmpresaAsignado);
                        //clienteDto.setPermisoVentaCredito(permisoVentaCredito);
                        clienteDto.setNombreComercial(nombreComercial); 
                        //clienteDto.setReferencia(referencia);
                    
                    /*    String diasVisita = "";
                        if(!lunesReporte.trim().equals(""))
                            diasVisita += lunesReporte+", ";
                        if(!martesReporte.trim().equals(""))
                            diasVisita += martesReporte+", ";
                        if(!miercolesReporte.trim().equals(""))
                            diasVisita += miercolesReporte+", ";
                        if(!juevesReporte.trim().equals(""))
                            diasVisita += juevesReporte+", ";
                        if(!viernesReporte.trim().equals(""))
                            diasVisita += viernesReporte+", ";
                        if(!sabadoReporte.trim().equals(""))
                            diasVisita += sabadoReporte+", ";
                        if(!domingoReporte.trim().equals(""))
                            diasVisita += domingoReporte+", ";

                        clienteDto.setDiasVisita(diasVisita);*/
                        //clienteDto.setPerioricidad(periodoVisita);
                        
                        //clienteDto.setSincronizacionMicrosip(2);
                        
                        clienteDto.setIdCategoria(idClienteCategoria);
                        
                        //clienteDto.setClave(claveCliente);
                        
                        
/********                        //Relacion con vendedor
                        if (idVendedor>0){
                            //ClienteVendedorBO clienteVendedorBO = new SGClienteVendedorBO(idCliente,user.getConn());
                            RelacionClienteVendedor clienteVendedorDto = new RelacionClienteVendedorDaoImpl(user.getConn()).findByPrimaryKey(idCliente);

                           if (clienteVendedorDto!=null){
                                //si ya existe registro, lo actualizamos
                                clienteVendedorDto.setIdUsuario(idVendedor);
                                new RelacionClienteVendedorDaoImpl(user.getConn()).update(clienteVendedorDto.createPk(), clienteVendedorDto);
                           }else{
                                // si no existe registro, lo creamos
                                clienteVendedorDto = new RelacionClienteVendedor();

                                clienteVendedorDto.setIdCliente(idCliente);
                                clienteVendedorDto.setIdUsuario(idVendedor);
                                new RelacionClienteVendedorDaoImpl(user.getConn()).insert(clienteVendedorDto);
                           }
                       }
**********/
                        /////**--Insertamos los registros de datos personalizados:
                        /*ClienteCampoContenidoDaoImpl campoContenidoDaoImpl = new ClienteCampoContenidoDaoImpl(user.getConn());
                        ClienteCampoAdicionalBO clienteCampoContenidoBO = new ClienteCampoAdicionalBO(user.getConn());
                        clienteCampoContenidoBO.deleteCamposAdicionalesCliente(idCliente);
                        for(ClienteCampoContenido cliPersonalizados : clienteCampoContenidos){
                            cliPersonalizados.setIdCliente(idCliente);
                            campoContenidoDaoImpl.insert(cliPersonalizados);
                        }*/
                        /////**--
                        
                        try{
                            new ClienteDaoImpl(user.getConn()).update(clienteDto.createPk(), clienteDto);

                            out.print("<!--EXITO-->Registro actualizado satisfactoriamente");
                        }catch(Exception ex){
                            out.print("<!--ERROR-->No se pudo actualizar el registro. Informe del error al administrador del sistema: " + ex.toString());
                            ex.printStackTrace();
                        }
                        
                        
                    }else{ //nuevo express
                        Cliente clienteDto = new Cliente();
                        ClienteDaoImpl clientesDaoImpl = new ClienteDaoImpl(user.getConn());

                        int idClienteNuevo;
                        //Cliente ultimoRegistroClientes = clientesDaoImpl.findLast();
                        //idClienteNuevo = ultimoRegistroClientes.getIdCliente() + 1;
                        //clienteDto.setIdCliente(idClienteNuevo);

                        clienteDto.setIdEstatus(3); // de que va a faltar que sea editado, ya que se creo de tipo express
                        /*clienteDto.setRfcCliente(rfc);
                        clienteDto.setRazonSocial(razonSocial);
                        clienteDto.setNombreCliente(nombre);
                        clienteDto.setApellidoPaternoCliente(apaterno);
                        clienteDto.setApellidoMaternoCliente(amaterno);*/
                        clienteDto.setCalle(calle);
                        clienteDto.setNumero(numero);
                        clienteDto.setNumeroInterior(numeroInt);
                        clienteDto.setCodigoPostal(cp);
                        clienteDto.setColonia(colonia);
                        clienteDto.setMunicipio(municipio);
                        clienteDto.setEstado(estado);
                        clienteDto.setPais(pais);
                        //clienteDto.setLada(lada);
                        clienteDto.setTelefono(telefono);
                        //clienteDto.setExtension(extension);
                        //clienteDto.setCelular(celular);
                        clienteDto.setCorreo(email);
                        clienteDto.setContacto(contacto);
                        //clienteDto.setGenerico(0);
                        clienteDto.setIdEmpresa(idSucursalEmpresaAsignado);
                        //clienteDto.setPermisoVentaCredito(permisoVentaCredito);
                        clienteDto.setNombreComercial(nombreComercial);
                        //clienteDto.setReferencia(referencia);
                        
                        /*    String diasVisita = "";
                        if(!lunesReporte.trim().equals(""))
                            diasVisita += lunesReporte+", ";
                        if(!martesReporte.trim().equals(""))
                            diasVisita += martesReporte+", ";
                        if(!miercolesReporte.trim().equals(""))
                            diasVisita += miercolesReporte+", ";
                        if(!juevesReporte.trim().equals(""))
                            diasVisita += juevesReporte+", ";
                        if(!viernesReporte.trim().equals(""))
                            diasVisita += viernesReporte+", ";
                        if(!sabadoReporte.trim().equals(""))
                            diasVisita += sabadoReporte+", ";
                        if(!domingoReporte.trim().equals(""))
                            diasVisita += domingoReporte+", ";

                        clienteDto.setDiasVisita(diasVisita);
                        clienteDto.setPerioricidad(periodoVisita);
                        */
                        clienteDto.setIdCategoria(idClienteCategoria);
                        
              /*          clienteDto.setClave(claveCliente);*/
                        /**
                         * Realizamos el insert
                         */
              /*          ClientePk clientePk = clientesDaoImpl.insert(clienteDto);
                        
                        /////**--Insertamos los registros de datos personalizados:
                        //borramos los datos personalizados para insertarlos nuevamente:
                        
                        /*if(clientePk.getIdCliente() > 0){
                            ClienteCampoContenidoDaoImpl campoContenidoDaoImpl = new ClienteCampoContenidoDaoImpl(user.getConn());
                            ClienteCampoAdicionalBO clienteCampoContenidoBO = new ClienteCampoAdicionalBO(user.getConn());
                            clienteCampoContenidoBO.deleteCamposAdicionalesCliente(clientePk.getIdCliente());
                            for(ClienteCampoContenido cliPersonalizados : clienteCampoContenidos){
                                cliPersonalizados.setIdCliente(clientePk.getIdCliente());
                                campoContenidoDaoImpl.insert(cliPersonalizados);
                            }
                        }*/
                        /////**--

                        //Relacion con vendedor
                        if (idVendedor > 0){
                            RelacionClienteVendedor clienteVendedorDto = new RelacionClienteVendedor();
                            // si no existe registro, lo creamos
                            clienteVendedorDto.setIdCliente(clienteDto.getIdCliente());
                            clienteVendedorDto.setIdUsuario(idVendedor);
                            new RelacionClienteVendedorDaoImpl(user.getConn()).insert(clienteVendedorDto);
                       }
                        out.print("<!--EXITO-->Registro creado satisfactoriamente.<br/>");                    
                    
                    }
                }catch(Exception e){
                    e.printStackTrace();
                    msgError += "Ocurrio un error al guardar el registro: " + e.toString() ;
                }
        }else{
            out.print("<!--ERROR-->"+msgError);
        }
    }else if(mode.equals("dirMapa")){ //Actualiza direccion desde catClientes_formMapa
        
        
        if(!gc.isValidString(calle, 1, 100))
            msgError += "<ul>El dato 'calle' es requerido";
        if(!gc.isValidString(numero, 1, 30))
            msgError += "<ul>El dato 'numero' es requerido";
        if(!gc.isValidString(numeroInt, 0, 30))
            msgError += "<ul>El dato 'numero Interior' es requerido";
        /*if(empresaPermisoAplicacionDto.getRfcPorNipCodigo() == 0){
            if(!gc.isCodigoPostal(cp))
                msgError += "<ul>El dato 'Codigo Postal' no es válido.";
        }*/
        if(!gc.isValidString(colonia, 0, 100))
            msgError += "<ul>El dato 'colonia' es incorrecto. Máximo 100 caracteres.";
        if(!gc.isValidString(municipio, 1, 100))
            msgError += "<ul>El dato 'municipio' es requerido";
        if(!gc.isValidString(estado, 1, 100))
            msgError += "<ul>El dato 'estado' es requerido";
        if(!gc.isValidString(pais, 1, 100))
            msgError += "<ul>El dato 'pais' es requerido";
        if(periodoVisita>4||periodoVisita<1)
            msgError += "<ul>El dato 'periodo' debe estra entre 1 y 4.";
        
        if (msgError.equals("")){
           
            ClienteBO clienteBO = new ClienteBO(idCliente,user.getConn());
            Cliente clienteDto = clienteBO.getCliente();

            clienteDto.setCalle(calle);
            clienteDto.setNumero(numero);
            clienteDto.setNumeroInterior(numeroInt);
            clienteDto.setCodigoPostal(cp);
            clienteDto.setColonia(colonia);
            clienteDto.setMunicipio(municipio);
            clienteDto.setEstado(estado);
            clienteDto.setPais(pais);
            //clienteDto.setSincronizacionMicrosip(2);

            try{
                new ClienteDaoImpl(user.getConn()).update(clienteDto.createPk(), clienteDto);

                out.print("<!--EXITO-->Registro actualizado satisfactoriamente");
            }catch(Exception ex){
                out.print("<!--ERROR-->No se pudo actualizar el registro. Informe del error al administrador del sistema: " + ex.toString());
                ex.printStackTrace();
            }

        }else{
            out.print("<!--ERROR-->"+msgError);
        }
        
    }else if(mode.equals("latlng")){
        
        try{
            ClienteBO clienteBO = new ClienteBO(idCliente,user.getConn());
            Cliente clienteDto = clienteBO.getCliente();
            out.print(clienteDto.getLatitud()+","+clienteDto.getLongitud());
        }catch(Exception ex){
                //out.print("<!--ERROR-->");
                
        }
        
    }else{
          
 /*   if(empresaPermisoAplicacionDto.getRfcPorNipCodigo() == 1 || empresaPermisoAplicacionDto.getRfcPorNipCodigo() == 2){
        if( (rfc.length() <= 10 && rfc.length() >= 6) ){
            //el rfc es un nip (colombia)
        }else{
            if(!gc.isRFC(rfc) && !gc.isRuc(rfc))
                msgError += "<ul>El dato 'RFC"+(empresaPermisoAplicacionDto.getRfcPorNipCodigo() == 1?"/NIP":empresaPermisoAplicacionDto.getRfcPorNipCodigo() == 2?"/RUC":"")+"' no es válido.";
            /*if(rfc.trim().length()==13){
                if(!gc.isValidString(nombre, 1, 100))
                    msgError += "<ul>El dato 'nombre' es requerido";
                if(!gc.isValidString(apaterno, 0, 100))
                    msgError += "<ul>El dato 'apellido paterno' es requerido";
                if(!gc.isValidString(amaterno, 0, 100))
                    msgError += "<ul>El dato 'apellido materno' es requerido";
            }else if(rfc.trim().length()==12){
                if(!gc.isValidString(razonSocial, 1, 200))
                msgError += "<ul>El dato 'razon Social' es requerido.";
            }*/
 /*       }
    }else{
        if(!gc.isRFC(rfc))
                msgError += "<ul>El dato 'rfc' no es válido.";
            if(rfc.trim().length()==13){
                if(!gc.isValidString(nombre, 1, 100))
                    msgError += "<ul>El dato 'nombre' es requerido";
                if(!gc.isValidString(apaterno, 0, 100))
                    msgError += "<ul>El dato 'apellido paterno' es requerido";
                if(!gc.isValidString(amaterno, 0, 100))
                    msgError += "<ul>El dato 'apellido materno' es requerido";
            }else if(rfc.trim().length()==12){
                if(!gc.isValidString(razonSocial, 1, 200))
                msgError += "<ul>El dato 'razon Social' es requerido.";
            }
    }*/

        if(!gc.isValidString(calle, 1, 100))
            msgError += "<ul>El dato 'calle' es requerido";
        if(!gc.isValidString(numero, 1, 30))
            msgError += "<ul>El dato 'numero' es requerido";
        if(!gc.isValidString(numeroInt, 0, 30))
            msgError += "<ul>El dato 'numero Interior' es requerido";
/*        if(empresaPermisoAplicacionDto.getRfcPorNipCodigo() == 0){
            if(!gc.isCodigoPostal(cp))
                msgError += "<ul>El dato 'Codigo Postal' no es válido.";
        }
*/        if(!gc.isValidString(colonia, 0, 100))
            msgError += "<ul>El dato 'colonia' es incorrecto. Máximo 100 caracteres.";
        if(!gc.isValidString(municipio, 1, 100))
            msgError += "<ul>El dato 'municipio' es requerido";
        if(!gc.isValidString(estado, 1, 100))
            msgError += "<ul>El dato 'estado' es requerido";
        if(!gc.isValidString(pais, 1, 100))
            msgError += "<ul>El dato 'pais' es requerido";
 /*       if (lada.trim().length()>0){
            if(!gc.isNumeric(lada, 2, 3))
                msgError += "<ul>El dato 'lada' es inválido. Mínimo 2 y máximo 3 números.";
        }
*/
        if (telefono.trim().length()>0){
            if(!gc.isNumeric(telefono, 7, 8))
                msgError += "<ul>El dato 'Telefono' es incorrecto. Minimo 7 y maximo 8 numeros.";
        }
/*        if(!gc.isValidString(extension, 0, 5))
            msgError += "<ul>El dato 'extension' es inválido. ";
        if(!gc.isValidString(celular, 0, 11))
            msgError += "<ul>El dato 'celular' es requerido. Minimo 10 y maximo 11 numeros.";
 */       if(!gc.isValidString(contacto, 0, 100))
            msgError += "<ul>El dato 'nombre de contacto' es incorrecto. Máximo 100 caracteres.";
        //if(email.equals(""))
        //    msgError += "<ul>El dato 'correo' es requerido. <br/>";
        if (email.trim().length()>0){
            if(!gc.isEmail(email))
                msgError += "<ul>El dato 'Correo electr&oacute;nico' es incorrecto. <br/>";
        }
        if(idCliente <= 0 && !mode.equals("") && !mode.equals("3"))
            msgError += "<ul>El dato ID 'cliente' es requerido";
        
        if(periodoVisita>4||periodoVisita<1)
            msgError += "<ul>El dato 'periodo' debe estra entre 1 y 4.";
        
        /*
        if(idVendedor<=0)
            msgError += "<ul>El dato 'Vendedor' es requerido";
     * */
        
      /*  if(estatus == 2){
            msgError = "" ;
            
            //validamos unicamente lo siguiente:
            if(razonSocial.trim().equals("") && nombre.trim().equals("") && apaterno.trim().equals("")){
                 msgError += "<ul>El dato 'nombre, apellidos o Razon Social' es requerido";
            }else{
                if(razonSocial.trim().equals("")){
                    if(!gc.isValidString(nombre, 1, 100))
                        msgError += "<ul>El dato 'nombre' es requerido";
                    if(!gc.isValidString(apaterno, 0, 100))
                        msgError += "<ul>El dato 'apellido paterno' es requerido";
                }
                if(nombre.trim().equals("") && apaterno.trim().equals("")){
                    if(!gc.isValidString(razonSocial, 1, 200))
                    msgError += "<ul>El dato 'razon Social' es requerido.";
                }
            }
        }*/

        if(msgError.equals("")){
            if(idCliente>0){
                if (mode.equals("1")){
                /*
                * Editar
                */
                    ClienteBO clienteBO = new ClienteBO(idCliente,user.getConn());
                    Cliente clienteDto = clienteBO.getCliente();

                    clienteDto.setIdEstatus(estatus);
                    clienteDto.setIdEmpresa(idSucursalEmpresaAsignado);
                    /*clienteDto.setRfcCliente(rfc);
                    clienteDto.setRazonSocial(razonSocial);
                    clienteDto.setNombreCliente(nombre);
                    clienteDto.setApellidoPaternoCliente(apaterno);
                    clienteDto.setApellidoMaternoCliente(amaterno);*/

                    clienteDto.setCalle(calle);
                    clienteDto.setNumero(numero);
                    clienteDto.setNumeroInterior(numeroInt);
                    clienteDto.setCodigoPostal(cp);
                    clienteDto.setColonia(colonia);
                    clienteDto.setMunicipio(municipio);
                    clienteDto.setEstado(estado);
                    clienteDto.setPais(pais);

                    //clienteDto.setLada(lada);
                    clienteDto.setTelefono(telefono);
                    //clienteDto.setExtension(extension);
                    //clienteDto.setCelular(celular);
                    clienteDto.setCorreo(email);
                    clienteDto.setContacto(contacto);
                    
                    //clienteDto.setLatitud(latitud);
                    //clienteDto.setLongitud(longitud);
                    
                    //clienteDto.setReferencia(referencia);
                    
                    /*String diasVisita = "";
                    if(!lunesReporte.trim().equals(""))
                        diasVisita += lunesReporte+", ";
                    if(!martesReporte.trim().equals(""))
                        diasVisita += martesReporte+", ";
                    if(!miercolesReporte.trim().equals(""))
                        diasVisita += miercolesReporte+", ";
                    if(!juevesReporte.trim().equals(""))
                        diasVisita += juevesReporte+", ";
                    if(!viernesReporte.trim().equals(""))
                        diasVisita += viernesReporte+", ";
                    if(!sabadoReporte.trim().equals(""))
                        diasVisita += sabadoReporte+", ";
                    if(!domingoReporte.trim().equals(""))
                        diasVisita += domingoReporte+", ";
                    
                    clienteDto.setDiasVisita(diasVisita);
                    clienteDto.setPerioricidad(periodoVisita);                    
                    clienteDto.setSincronizacionMicrosip(2);                    
                    clienteDto.setPermisoVentaCredito(permisoVentaCredito);*/
                    clienteDto.setNombreComercial(nombreComercial);
                    clienteDto.setIdCategoria(idClienteCategoria);
                    /*
                    clienteDto.setClave(claveCliente);
                    
                    /////**--Insertamos los registros de datos personalizados:                    
                    /*ClienteCampoContenidoDaoImpl campoContenidoDaoImpl = new ClienteCampoContenidoDaoImpl(user.getConn());
                    ClienteCampoAdicionalBO clienteCampoContenidoBO = new ClienteCampoAdicionalBO(user.getConn());
                    clienteCampoContenidoBO.deleteCamposAdicionalesCliente(idCliente);
                    for(ClienteCampoContenido cliPersonalizados : clienteCampoContenidos){
                        cliPersonalizados.setIdCliente(idCliente);
                        campoContenidoDaoImpl.insert(cliPersonalizados);
                    }*/
                   
/**********                    //Relacion con vendedor                    
                    if (idVendedor>0){
                            //ClienteVendedorBO clienteVendedorBO = new SGClienteVendedorBO(idCliente,user.getConn());
                            RelacionClienteVendedor clienteVendedorDto = new RelacionClienteVendedorDaoImpl(user.getConn()).findByPrimaryKey(idCliente);

                           if (clienteVendedorDto!=null){
                                //si ya existe registro, lo actualizamos
                                clienteVendedorDto.setIdUsuario(idVendedor);
                                new RelacionClienteVendedorDaoImpl(user.getConn()).update(clienteVendedorDto.createPk(), clienteVendedorDto);
                           }else{
                                // si no existe registro, lo creamos
                                clienteVendedorDto = new RelacionClienteVendedor();

                                clienteVendedorDto.setIdCliente(idCliente);
                                clienteVendedorDto.setIdUsuario(idVendedor);
                                new RelacionClienteVendedorDaoImpl(user.getConn()).insert(clienteVendedorDto);
                           }
                       }
***********/
                    try{
                        new ClienteDaoImpl(user.getConn()).update(clienteDto.createPk(), clienteDto);

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
                    Cliente clienteDto = new Cliente();
                    ClienteDaoImpl clientesDaoImpl = new ClienteDaoImpl(user.getConn());

                    //int idClienteNuevo;

                    //Cliente ultimoRegistroClientes = clientesDaoImpl.findLast();
                    //idClienteNuevo = ultimoRegistroClientes.getIdCliente() + 1;

                    //clienteDto.setIdCliente(idClienteNuevo);

                    clienteDto.setIdEstatus(estatus);

                    /*clienteDto.setRfcCliente(rfc);
                    clienteDto.setRazonSocial(razonSocial);
                    clienteDto.setNombreCliente(nombre);
                    clienteDto.setApellidoPaternoCliente(apaterno);
                    clienteDto.setApellidoMaternoCliente(amaterno);*/

                    clienteDto.setCalle(calle);
                    clienteDto.setNumero(numero);
                    clienteDto.setNumeroInterior(numeroInt);
                    clienteDto.setCodigoPostal(cp);
                    clienteDto.setColonia(colonia);
                    clienteDto.setMunicipio(municipio);
                    clienteDto.setEstado(estado);
                    clienteDto.setPais(pais);

                    //clienteDto.setLada(lada);
                    clienteDto.setTelefono(telefono);
                    //clienteDto.setExtension(extension);
                    //clienteDto.setCelular(celular);
                    clienteDto.setCorreo(email);
                    clienteDto.setContacto(contacto);

                    //clienteDto.setGenerico(0);
                    clienteDto.setIdEmpresa(idSucursalEmpresaAsignado);
                    
                    clienteDto.setLatitud(latitud);
                    clienteDto.setLongitud(longitud);
                    
                    //clienteDto.setReferencia(referencia);
                    
                    /*String diasVisita = "";
                    if(!lunesReporte.trim().equals(""))
                        diasVisita += lunesReporte+", ";
                    if(!martesReporte.trim().equals(""))
                        diasVisita += martesReporte+", ";
                    if(!miercolesReporte.trim().equals(""))
                        diasVisita += miercolesReporte+", ";
                    if(!juevesReporte.trim().equals(""))
                        diasVisita += juevesReporte+", ";
                    if(!viernesReporte.trim().equals(""))
                        diasVisita += viernesReporte+", ";
                    if(!sabadoReporte.trim().equals(""))
                        diasVisita += sabadoReporte+", ";
                    if(!domingoReporte.trim().equals(""))
                        diasVisita += domingoReporte+", ";
                    
                    clienteDto.setDiasVisita(diasVisita);
                    clienteDto.setPerioricidad(periodoVisita);
                    clienteDto.setPermisoVentaCredito(permisoVentaCredito);*/
                    clienteDto.setNombreComercial(nombreComercial);
                    clienteDto.setIdCategoria(idClienteCategoria);
                    clienteDto.setFechaRegistro(new Date());
                    clienteDto.setIdUsuarioAlta(user.getUser().getIdUsuarios());
                    
                    //clienteDto.setClave(claveCliente);

                    /**
                     * Realizamos el insert
                     */
                    ClientePk clientePk = clientesDaoImpl.insert(clienteDto);
                    
                    /////**--Insertamos los registros de datos personalizados:
                    /*if(clientePk.getIdCliente() > 0){
                        ClienteCampoContenidoDaoImpl campoContenidoDaoImpl = new ClienteCampoContenidoDaoImpl(user.getConn());
                        ClienteCampoAdicionalBO clienteCampoContenidoBO = new ClienteCampoAdicionalBO(user.getConn());
                        clienteCampoContenidoBO.deleteCamposAdicionalesCliente(clientePk.getIdCliente());
                        for(ClienteCampoContenido cliPersonalizados : clienteCampoContenidos){
                            cliPersonalizados.setIdCliente(clientePk.getIdCliente());
                            campoContenidoDaoImpl.insert(cliPersonalizados);
                        }
                    }*/

                    //Relacion con vendedor
                    if (idVendedor>0){
                        RelacionClienteVendedor clienteVendedorDto = new RelacionClienteVendedor();

                        // si no existe registro, lo creamos
                        clienteVendedorDto.setIdCliente(clienteDto.getIdCliente());
                        clienteVendedorDto.setIdUsuario(idVendedor);
                        new RelacionClienteVendedorDaoImpl(user.getConn()).insert(clienteVendedorDto);
                   }
                    
                    //Consumo de Creditos Operacion
                    /*try{
                        BitacoraCreditosOperacionBO bcoBO = new BitacoraCreditosOperacionBO(user.getConn());
                        bcoBO.registraDescuento(user.getUser(), 
                                BitacoraCreditosOperacionBO.CONSUMO_ACCION_REGISTRO_CLIENTE, 
                                null, clienteDto.getIdCliente(), 0, 0, 
                                "Registro de Cliente", null, true);
                    }catch(Exception ex){
                        ex.printStackTrace();
                    }*/

                    out.print("<!--EXITO-->Registro creado satisfactoriamente.<br/>:"+clienteDto.getIdCliente());

                }catch(Exception e){
                    e.printStackTrace();
                    msgError += "Ocurrio un error al guardar el registro: " + e.toString() ;
                }
            }
        }else{
            out.print("<!--ERROR-->"+msgError);
        }
    
}

%>