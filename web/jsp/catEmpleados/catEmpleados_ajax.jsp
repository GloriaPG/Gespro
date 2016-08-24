<%-- 
    Document   : catEmpleados_ajax
    Created on : 09-01-2013, 05:52:45 PM
    Author     : Leonardo
--%>


<%@page import="com.tsp.gespro.dto.LdapPk"%>
<%@page import="com.tsp.gespro.jdbc.ExistenciaAlmacenDaoImpl"%>
<%@page import="com.tsp.gespro.dto.ExistenciaAlmacen"%>
<%@page import="com.tsp.gespro.bo.ExistenciaAlmacenBO"%>
<%@page import="com.tsp.gespro.jdbc.ClienteDaoImpl"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="java.text.DateFormat"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.math.RoundingMode"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="com.tsp.gespro.jdbc.ConceptoDaoImpl"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.dto.Concepto"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.jdbc.DispositivoMovilDaoImpl"%>
<%@page import="com.tsp.gespro.bo.DispositivoMovilBO"%>
<%@page import="com.tsp.gespro.dto.DispositivoMovil"%>
<%@page import="com.tsp.gespro.bo.DatosUsuarioBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.dto.UsuariosPk"%>
<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.dto.DatosUsuarioPk"%>
<%@page import="com.tsp.gespro.jdbc.DatosUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.tsp.gespro.mail.TspMailBO"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";

    int idEmpresa = user.getUser().getIdEmpresa();
    //OBTENERMOS EL ID_EMPRESA_PADRE
    Empresa empresaDatosPadre = new Empresa();
    EmpresaBO empresaBOPadre = new EmpresaBO(user.getConn());
    try {
        empresaDatosPadre = empresaBOPadre.findEmpresabyId(idEmpresa);
    } catch (Exception ex) {
    }

    /*
     * Parámetros
     */
    int idUsuario = -1;
    String numEmpleado = "";
    String nombreEmpleado = "";
    String apellidoPaternoEmpleado = "";
    String apellidoMaternoEmpleado = "";
    String telefono = "";
    String ciudad = "";
    String emailEmpleado = "";
    String direccion = "";
    int idDispositivoMovilEmpleado = -1;
    int idRolUsuario = -1;
    int idSucursalEmpresaAsignado = -1;
    double distanciaObligaEmple = 0;
    int estatus = 2;//deshabilitado
    String usuarioEmpleado = "";
    String contrasenaEmpleado = "";
    Date now = new Date();
    int idhorarioAsignado = -1;

    int clientesBarras = 2;//deshabilitado   
    int permisoVentaCredito = 2;//deshabilitado
    int trabajarFueraLinea = 2;//deshabilitado    
    int precioCompra = 2;//deshabilitado
    int permisoAccionesClientes = 3;//crear y editar

    String extension = "";
    String celular = "";
    int firmado = -1; //Cambiar a 1 cuando el usuario en cuestion cambia su contraseña
    int tiempoEstatus = 0;//Tiempo para solicitar estatus
    /*
     * Recepción de valores
     */
    String msgError = "";
    GenericValidator gc = new GenericValidator();
    ciudad = request.getParameter("ciudad") != null ? new String(request.getParameter("ciudad").getBytes("ISO-8859-1"), "UTF-8") : "";

    mode = request.getParameter("mode") != null ? request.getParameter("mode") : "";
    if (mode.equals("2")) { //SI ES 2 ES PARA BORRAR

        try {
            idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
        } catch (NumberFormatException ex) {
        }

        UsuarioBO usuarioBO = new UsuarioBO(user.getConn(), idUsuario);
        Usuarios usuarioDto = usuarioBO.getUser();
        usuarioDto.setIdEstatus(2);

        try {
            new UsuariosDaoImpl(user.getConn()).update(usuarioDto.createPk(), usuarioDto);
            out.print("<!--EXITO-->Registro borrado satisfactoriamente");
        } catch (Exception ex) {
            out.print("<!--ERROR-->No se pudo borrar el registro. Informe del error al administrador del sistema: " + ex.toString());
            ex.printStackTrace();
        }
        try {
                //ACTUALIZAMOS EL NUMERO DE LICENCIAS DISPONIBLES

            Empresa empresaMatriz = new Empresa();
            EmpresaBO empresaMatrizBO = new EmpresaBO(user.getConn());
            empresaMatriz = empresaMatrizBO.findEmpresabyId(empresaDatosPadre.getIdEmpresaPadre());
            new EmpresaDaoImpl(user.getConn()).update(empresaMatriz.createPk(), empresaMatriz);

        } catch (Exception ex) {
            out.print("<!--ERROR-->Existio un problema con la actualización de las licencias. Informe del error al administrador del sistema: " + ex.toString());
            ex.printStackTrace();
        }

    } else {

        try {
            idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
        } catch (NumberFormatException ex) {
        }
        numEmpleado = request.getParameter("numEmpleado") != null ? new String(request.getParameter("numEmpleado").getBytes("ISO-8859-1"), "UTF-8") : "";
        nombreEmpleado = request.getParameter("nombreEmpleado") != null ? new String(request.getParameter("nombreEmpleado").getBytes("ISO-8859-1"), "UTF-8") : "";
        apellidoPaternoEmpleado = request.getParameter("apellidoPaternoEmpleado") != null ? new String(request.getParameter("apellidoPaternoEmpleado").getBytes("ISO-8859-1"), "UTF-8") : "";
        apellidoMaternoEmpleado = request.getParameter("apellidoMaternoEmpleado") != null ? new String(request.getParameter("apellidoMaternoEmpleado").getBytes("ISO-8859-1"), "UTF-8") : "";
        telefono = request.getParameter("telefonoEmpleado") != null ? new String(request.getParameter("telefonoEmpleado").getBytes("ISO-8859-1"), "UTF-8") : "";
        emailEmpleado = request.getParameter("emailEmpleado") != null ? new String(request.getParameter("emailEmpleado").getBytes("ISO-8859-1"), "UTF-8") : "";
        direccion = request.getParameter("direccionEmpleado") != null ? new String(request.getParameter("direccionEmpleado").getBytes("ISO-8859-1"), "UTF-8") : "";
        usuarioEmpleado = request.getParameter("usuarioEmpleado") != null ? new String(request.getParameter("usuarioEmpleado").getBytes("ISO-8859-1"), "UTF-8") : "";
        contrasenaEmpleado = request.getParameter("contrasenaEmpleado") != null ? new String(request.getParameter("contrasenaEmpleado").getBytes("ISO-8859-1"), "UTF-8") : "";
        ciudad = request.getParameter("ciudad") != null ? new String(request.getParameter("ciudad").getBytes("ISO-8859-1"), "UTF-8") : "";

        try {
            idDispositivoMovilEmpleado = Integer.parseInt(request.getParameter("idDispositivoMovilEmpleado"));
        } catch (NumberFormatException ex) {
        }
        try {
            idRolUsuario = Integer.parseInt(request.getParameter("idRolEmpleado"));
        } catch (NumberFormatException ex) {
        }
        try {
            estatus = Integer.parseInt(request.getParameter("estatus"));
        } catch (NumberFormatException ex) {
        }

        try {
            distanciaObligaEmple = Double.parseDouble(request.getParameter("distanciaObligaEmple"));
        } catch (Exception ex) {
        }

        try {
            idSucursalEmpresaAsignado = Integer.parseInt(request.getParameter("idSucursalEmpresaAsignado"));
        } catch (Exception ex) {
        }
        
        try {
            idhorarioAsignado = Integer.parseInt(request.getParameter("idhorarioAsignado"));
        } catch (Exception ex) {
        }
        try{ firmado = Integer.parseInt(request.getParameter("firmado")); }catch(NumberFormatException ex){}
        
        try {
            tiempoEstatus = Integer.parseInt(request.getParameter("tiempoEstatus"));
        } catch (Exception ex) {
        }
        
        
        /*
         * Validaciones del servidor
         */
        if (!gc.isValidString(numEmpleado, 1, 50)) {
            msgError += "<ul>El dato 'Numero de Empleado' es requerido.";
        }
        if (!gc.isValidString(nombreEmpleado, 1, 70)) {
            msgError += "<ul>El dato 'Nombre' es requerido";
        }
        if (!gc.isValidString(apellidoPaternoEmpleado, 1, 70)) {
            msgError += "<ul>El dato 'Apellido Paterno' es requerido";
        }
        if (!gc.isValidString(apellidoMaternoEmpleado, 1, 70)) {
            msgError += "<ul>El dato 'Apellido Materno' es requerido";
        }
        if (!emailEmpleado.equals("")) {
            if (!gc.isEmail(emailEmpleado)) {
                msgError += "<ul>El dato 'Correo electr&oacute;nico' es incorrecto. <br/>";
            }
        }
        if (idRolUsuario < 0) {
            msgError += "<ul>El dato 'Rol' es requerido";
        }
        if (!gc.isValidString(usuarioEmpleado, 1, 50)) {
            msgError += "<ul>El dato 'Usuario' es requerido.";
        }
        if (!gc.isValidString(contrasenaEmpleado, 1, 20) && mode.equals("")) {
            msgError += "<ul>El dato 'Contraseña' es requerido.";
        }
        if (idSucursalEmpresaAsignado < 0) {
            msgError += "<ul>El dato 'Sucursal' es requerido";
        }
        if (tiempoEstatus < 0) {
            msgError += "<ul>El dato 'Solicitar Estatus' es requerido";
        }

        //verificamos si existe el nombre de usuario
        UsuariosDaoImpl usersDaoImpl = new UsuariosDaoImpl();
        Usuarios[] usuariosDtos = usersDaoImpl.findWhereUserNameEquals(usuarioEmpleado.trim());
        //Validación nombre se usuario existente
        if (mode.equals("1")) {

            UsuarioBO usuario2BO = new UsuarioBO(idUsuario);
            Usuarios usuarioActualizarDto = usuario2BO.getUser();

            if (!usuarioActualizarDto.getUserName().equals(usuarioEmpleado)) {
                if (usuariosDtos.length > 0) {
                    msgError += "<ul>El Nombre de 'Usuario' ya esta siendo utilizado por otra persona.";
                }
            }
        } else {

            UsuariosDaoImpl usersDaoImpl2 = new UsuariosDaoImpl();
            Usuarios[] usuariosDtos2 = usersDaoImpl2.findWhereUserNameEquals(usuarioEmpleado.trim());
            if (usuariosDtos2.length > 0) {
                msgError += "<ul>El Nombre de 'Usuario' ya esta siendo utilizado por otra persona.";
            }
        }
            if (idUsuario <= 0 && (!mode.equals(""))) {
                msgError += "<ul>El dato ID 'Usuario' es requerido";
            }

            if (msgError.equals("")) {
                if (idUsuario > 0) {

                    if (mode.equals("1")) {
                        /*
                         * Editar
                         */
                        UsuarioBO usuarioBO = new UsuarioBO(user.getConn(), idUsuario);
                        Usuarios usuarioDto = usuarioBO.getUser();

                        //DATOS PARA LA TABLA DATOS_USUARIO
                        DatosUsuario datosUsuario = new DatosUsuario();
                        DatosUsuarioDaoImpl datosUsuarioDaoImpl = new DatosUsuarioDaoImpl(user.getConn());
                        datosUsuario = datosUsuarioDaoImpl.findByPrimaryKey(usuarioDto.getIdDatosUsuario());

                        datosUsuario.setNombre(nombreEmpleado);
                        datosUsuario.setApellidoPat(apellidoPaternoEmpleado);
                        datosUsuario.setApellidoMat(apellidoMaternoEmpleado);
                        datosUsuario.setDireccion(direccion);
                        datosUsuario.setTelefono(telefono);
                        datosUsuario.setExtension(extension);
                        datosUsuario.setCelular(celular);
                        datosUsuario.setCorreo(emailEmpleado);
                        datosUsuario.setCiudad(ciudad);
                    

                        //insert datos usuario
                        datosUsuarioDaoImpl.update(datosUsuario.createPk(), datosUsuario);//INSERTAMOS EL REGISTRO DE DATOS USUARIO Y RECUPERAMOS EL OBJETO PARA TENER EL ID ASIGNADO               

                        //DATOS PARA LA TABLA LDAP
                        Ldap ldap = new Ldap();
                        LdapDaoImpl ldapDaoImpl = new LdapDaoImpl(user.getConn());

                        ldap = ldapDaoImpl.findByPrimaryKey(usuarioDto.getIdLdap());

                        

                        ldap.setUsuario(usuarioEmpleado);
                        
                        if(!contrasenaEmpleado.trim().equals("")){                            
                            Encrypter encriptacion = new Encrypter();//ENCRIPTAMOS EL PASS
                            encriptacion.setMd5(true);
                            ldap.setPassword(encriptacion.encodeString2(contrasenaEmpleado));
                        }
                        
                        if (firmado==1){
                            ldap.setFirmado(1);
                        }

                        ldapDaoImpl.update(ldap.createPk(), ldap);

                        //DATOS PARA LA TABLA usuarios               
                        UsuariosDaoImpl usuariosDaoImpl = new UsuariosDaoImpl(user.getConn());

                        if (idSucursalEmpresaAsignado < 0) {
                            usuarioDto.setIdEmpresa(idEmpresa);
                        } else {
                            usuarioDto.setIdEmpresa(idSucursalEmpresaAsignado);
                        }

                        //usuarioDto.setIdDatosUsuario(datosUsuario.getIdDatosUsuario());
                        usuarioDto.setIdEstatus(estatus);
                        usuarioDto.setIdRoles(idRolUsuario);
                        //usuarioDto.setIdLdap(ldapPk.getIdLdap());
                        usuarioDto.setUserName(usuarioEmpleado);
                        //usuarioDto.setFechaAlta(now);
                        //usuarioDto.setFechaVigencia(now);
                        usuarioDto.setIntentos(0);
                        usuarioDto.setContrato(0);

                        if (idDispositivoMovilEmpleado > 0) {
                            usuarioDto.setIdDispositivo(idDispositivoMovilEmpleado);
                        } else {
                            usuarioDto.setIdDispositivo(-1);
                        }

                        usuarioDto.setDistanciaObligatorio(distanciaObligaEmple);
                        usuarioDto.setNumEmpleado(numEmpleado);
                        usuarioDto.setIdHorarioAsignado(idhorarioAsignado);
                        usuarioDto.setMinutosEstatus(tiempoEstatus);

                        usuarioDto.setClientesCodigoBarras(clientesBarras);
                        usuarioDto.setPermisoVentaCredito(permisoVentaCredito);
                        usuarioDto.setTrabajarFueraLinea(trabajarFueraLinea);
                        usuarioDto.setPrecioDeCompra(precioCompra);
                        usuarioDto.setPermisoAccionesCliente(permisoAccionesClientes);

                        //Si selecciono un dispositivo Movil lo actualizamos a asignado.                                
                        if (idDispositivoMovilEmpleado > 0) {
                            //lo quitamos a los demeas empleados.
                            Usuarios[] dispMovilAsignado = new Usuarios[0];
                            dispMovilAsignado = new UsuariosDaoImpl().findWhereIdDispositivoEquals(idDispositivoMovilEmpleado);

                            if (dispMovilAsignado.length > 0) {

                                try {
                                    for (Usuarios item : dispMovilAsignado) {
                                        item.setIdDispositivo(0);
                                        new UsuariosDaoImpl().update(item.createPk(), item);

                                    }

                                } catch (Exception e) {
                                }

                            } else {
                                DispositivoMovilBO movilBO = new DispositivoMovilBO(idDispositivoMovilEmpleado, user.getConn());
                                DispositivoMovil movil = new DispositivoMovil();
                                movil = movilBO.getDispositivoMovil();
                                short x = 1;
                                movil.setAsignado(x);
                                DispositivoMovilDaoImpl dispositivoMovilDaoImpl = new DispositivoMovilDaoImpl(user.getConn());
                                try {
                                    dispositivoMovilDaoImpl.update(movil.createPk(), movil);
                                } catch (Exception ex) {
                                    out.print("<!--ERROR-->No se pudo actualizar el registro del movil. Informe del error al administrador del sistema: " + ex.toString());
                                    ex.printStackTrace();
                                }
                            }
                        }

                        try {

                            usuariosDaoImpl.update(usuarioDto.createPk(), usuarioDto);

                            out.print("<!--EXITO-->Registro actualizado satisfactoriamente");
                        } catch (Exception ex) {
                            out.print("<!--ERROR-->No se pudo actualizar el registro. Informe del error al administrador del sistema: " + ex.toString());
                            ex.printStackTrace();
                        }

                    } else {
                        out.print("<!--ERROR-->Acción no válida.");
                    }

                } else {
                    /*
                     *  Nuevo
                     */

                    try {

                        /**
                         * Creamos el registro de Empleado
                         */
                        //////////VALIDAMOS CUANTOS REGISTROS TIENE PARA VER SI LO DEJAMOS CREAR O NO, DEPENDIENDO DEL PAQUETE:
                        EmpresaBO empresaBO = new EmpresaBO(user.getConn());
                        EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());

                        UsuariosBO usuariosBO = new UsuariosBO();
                        Usuarios[] listaUsuarios = new Usuarios[0];
                        listaUsuarios = usuariosBO.findUsuarios(-1, empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa(), 0, 0, " AND ID_ESTATUS <> 2 ");

                        System.out.println("---------------USUARIOS: " + listaUsuarios.length);

                        if (listaUsuarios.length < empresaPermisoAplicacionDto.getMaxNumUsuarios()) {

                            //DATOS PARA LA TABLA DATOS_USUARIO
                            DatosUsuario datosUsuario = new DatosUsuario();
                            DatosUsuarioDaoImpl datosUsuarioDaoImpl = new DatosUsuarioDaoImpl(user.getConn());

                            datosUsuario.setNombre(nombreEmpleado);
                            datosUsuario.setApellidoPat(apellidoPaternoEmpleado);
                            datosUsuario.setApellidoMat(apellidoMaternoEmpleado);
                            datosUsuario.setDireccion(direccion);
                            datosUsuario.setTelefono(telefono);
                            datosUsuario.setExtension(extension);
                            datosUsuario.setCelular(celular);
                            datosUsuario.setCorreo(emailEmpleado);
                            datosUsuario.setCiudad(ciudad);

                            //insert datos usuario
                            DatosUsuarioPk datosUsuarioPk = datosUsuarioDaoImpl.insert(datosUsuario);//INSERTAMOS EL REGISTRO DE DATOS USUARIO Y RECUPERAMOS EL OBJETO PARA TENER EL ID ASIGNADO               

                            //DATOS PARA LA TABLA LDAP
                            Ldap ldap = new Ldap();
                            LdapDaoImpl ldapDaoImpl = new LdapDaoImpl(user.getConn());

                            Encrypter encriptacion = new Encrypter();//ENCRIPTAMOS EL PASS
                            encriptacion.setMd5(true);

                            ldap.setUsuario(usuarioEmpleado);
                            ldap.setPassword(encriptacion.encodeString2(contrasenaEmpleado));
                            ldap.setFirmado(0);

                            LdapPk ldapPk = ldapDaoImpl.insert(ldap);

                            //DATOS PARA LA TABLA usuarios
                            Usuarios usuarioDto = new Usuarios();
                            UsuariosDaoImpl usuariosDaoImpl = new UsuariosDaoImpl(user.getConn());

                            if (idSucursalEmpresaAsignado < 0) {
                                usuarioDto.setIdEmpresa(idEmpresa);
                            } else {
                                usuarioDto.setIdEmpresa(idSucursalEmpresaAsignado);
                            }

                            usuarioDto.setIdDatosUsuario(datosUsuarioPk.getIdDatosUsuario());
                            usuarioDto.setIdEstatus(estatus);
                            usuarioDto.setIdRoles(idRolUsuario);
                            usuarioDto.setIdLdap(ldapPk.getIdLdap());
                            usuarioDto.setUserName(usuarioEmpleado);
                            usuarioDto.setFechaAlta(now);
                            usuarioDto.setFechaVigencia(now);
                            usuarioDto.setIntentos(0);
                            usuarioDto.setContrato(0);

                            if (idDispositivoMovilEmpleado > 0) {
                                usuarioDto.setIdDispositivo(idDispositivoMovilEmpleado);
                            } else {
                                usuarioDto.setIdDispositivo(-1);
                            }

                            usuarioDto.setDistanciaObligatorio(distanciaObligaEmple);
                            usuarioDto.setNumEmpleado(numEmpleado);
                            usuarioDto.setIdHorarioAsignado(idhorarioAsignado);
                            usuarioDto.setMinutosEstatus(tiempoEstatus);

                            usuarioDto.setClientesCodigoBarras(clientesBarras);
                            usuarioDto.setPermisoVentaCredito(permisoVentaCredito);
                            usuarioDto.setTrabajarFueraLinea(trabajarFueraLinea);
                            usuarioDto.setPrecioDeCompra(precioCompra);
                            usuarioDto.setPermisoAccionesCliente(permisoAccionesClientes);

                            //Si selecciono un dispositivo Movil lo actualizamos a asignado.                                
                            if (idDispositivoMovilEmpleado > 0) {
                                //lo quitamos a los demeas empleados.
                                Usuarios[] dispMovilAsignado = new Usuarios[0];
                                dispMovilAsignado = new UsuariosDaoImpl().findWhereIdDispositivoEquals(idDispositivoMovilEmpleado);

                                if (dispMovilAsignado.length > 0) {

                                    try {
                                        for (Usuarios item : dispMovilAsignado) {
                                            item.setIdDispositivo(-1);
                                            new UsuariosDaoImpl().update(item.createPk(), item);

                                        }

                                    } catch (Exception e) {
                                    }

                                } else {
                                    DispositivoMovilBO movilBO = new DispositivoMovilBO(idDispositivoMovilEmpleado, user.getConn());
                                    DispositivoMovil movil = new DispositivoMovil();
                                    movil = movilBO.getDispositivoMovil();
                                    short x = 1;
                                    movil.setAsignado(x);
                                    DispositivoMovilDaoImpl dispositivoMovilDaoImpl = new DispositivoMovilDaoImpl(user.getConn());
                                    try {
                                        dispositivoMovilDaoImpl.update(movil.createPk(), movil);
                                    } catch (Exception ex) {
                                        out.print("<!--ERROR-->No se pudo actualizar el registro del movil. Informe del error al administrador del sistema: " + ex.toString());
                                        ex.printStackTrace();
                                    }
                                }
                            }

                            usuariosDaoImpl.insert(usuarioDto);

                            out.print("<!--EXITO-->Registro creado satisfactoriamente.<br/>");

                        } else {
                            out.print("<!--ERROR-->No se permite crear mas usuarios. El límite de tu empresa Matriz son: " + empresaPermisoAplicacionDto.getMaxNumUsuarios() + " usuarios.");
                        }

                    } catch (Exception e) {
                        e.printStackTrace();
                        msgError += "Ocurrio un error al guardar el registro: " + e.toString();
                    }
                }

            } else {
                out.print("<!--ERROR-->" + msgError);
            }
        }
%>