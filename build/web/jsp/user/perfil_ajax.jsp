<%-- 
    Document   : perfil_ajax
    Created on : 19-dic-2012, 14:23:15
    Author     : ISCesarMartinez
--%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page import="com.tsp.gespro.jdbc.DatosUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.bo.PasswordBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    Usuarios usuarios = user.getUser();
    Ldap ldap = user.getLdap();
    DatosUsuario datosUsuario = user.getDatosUsuario();
    /**
     * No es obligatorio que todos los usuarios tengan estos datos,
     * por lo tanto puede tener valor NULO  
    */
    String mode = "";
    
    /*
    * Parámetros
    */
    String nombre ="";
    String apaterno="";
    String amaterno="";
    
    String direccion="";
    
    String lada="";
    String telefono="";
    //String extension="";
    String celular="";
    String email="";
    
    
    String passwordNuevo = "";
    String passwordNuevoConfirmacion = "";
    
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    nombre = request.getParameter("datosUsuario_nombre")!=null?new String(request.getParameter("datosUsuario_nombre").getBytes("ISO-8859-1"),"UTF-8"):"";
    apaterno = request.getParameter("datosUsuario_apaterno")!=null?new String(request.getParameter("datosUsuario_apaterno").getBytes("ISO-8859-1"),"UTF-8"):"";
    amaterno = request.getParameter("datosUsuario_amaterno")!=null?new String(request.getParameter("datosUsuario_amaterno").getBytes("ISO-8859-1"),"UTF-8"):"";
    direccion = request.getParameter("datosUsuario_direccion")!=null?new String(request.getParameter("datosUsuario_direccion").getBytes("ISO-8859-1"),"UTF-8"):"";
    lada = request.getParameter("datosUsuario_lada")!=null?new String(request.getParameter("datosUsuario_lada").getBytes("ISO-8859-1"),"UTF-8"):"";
    telefono = request.getParameter("datosUsuario_telefono")!=null?new String(request.getParameter("datosUsuario_telefono").getBytes("ISO-8859-1"),"UTF-8"):"";
    //extension = request.getParameter("extension")!=null?new String(request.getParameter("extension").getBytes("ISO-8859-1"),"UTF-8"):"";
    celular = request.getParameter("datosUsuario_celular")!=null?new String(request.getParameter("datosUsuario_celular").getBytes("ISO-8859-1"),"UTF-8"):"";
    email = request.getParameter("ldap_email")!=null?new String(request.getParameter("ldap_email").getBytes("ISO-8859-1"),"UTF-8"):"";
    
    passwordNuevo = request.getParameter("ldap_pass")!=null?new String(request.getParameter("ldap_pass").getBytes("ISO-8859-1"),"UTF-8"):"";
    passwordNuevoConfirmacion = request.getParameter("ldap_pass_confirm")!=null?new String(request.getParameter("ldap_pass_confirm").getBytes("ISO-8859-1"),"UTF-8"):"";
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();
    PasswordBO passwordBO = new PasswordBO();
    if(!gc.isValidString(nombre, 1, 50))
        msgError += "<ul>El dato 'nombre' es requerido. Máximo 50 carácteres.";
    if(!gc.isValidString(apaterno, 0, 100))
        msgError += "<ul>El dato 'apellido paterno' es requerido. Máximo 50 caracteres.";
    if(!gc.isValidString(amaterno, 0, 100))
        msgError += "<ul>El dato 'apellido materno' es requerido. Máximo 50 caracteres.";
    if(!gc.isValidString(direccion, 1, 100))
        msgError += "<ul>El dato 'direccion' es requerido. Maximo 100 caracteres.";
    /*if(!gc.isNumeric(lada, 2, 3))
        msgError += "<ul>El dato 'lada' es inválido. Mínimo 2 y máximo 3 números.";*/
    if(!gc.isNumeric(telefono, 7, 10))
        msgError += "<ul>El dato 'Telefono' es incorrecto. Minimo 7 y maximo 10 numeros.";
    /*
    if(!gc.isValidString(extension, 0, 5))
        msgError += "<ul>El dato 'extension' es inválido. ";
    */
    if(celular.trim().length()>0 && !gc.isValidString(celular, 10, 11))
        msgError += "<ul>El dato 'celular' es incorrecto. Minimo 10 y maximo 11 numeros. O puede dejarlo vacío";
    if(email.equals(""))
        msgError += "<ul>El dato 'correo' es requerido. <br/>";
    if(!gc.isEmail(email))
        msgError += "<ul>El dato 'Correo electr&oacute;nico' es incorrecto. <br/>";
    
    if(passwordNuevo.trim().length()>0  && !passwordNuevo.trim().equals(passwordNuevoConfirmacion)){
        msgError = "<ul>La contraseña y su confirmación no coinciden<br/>";
    }
    
    //Si se cambio la contraseña se verifica que sea una válida
    if (passwordNuevo.trim().length()>0 && passwordNuevo.trim().equals(passwordNuevoConfirmacion)){
        try{
            passwordBO.isValidPassword(user.getUser().getUserName(), passwordNuevo);
        }catch(Exception ex){
            msgError += "<ul>"+ex.getMessage();
        }
    }
    
    
    if(msgError.equals("")){
        if (usuarios!=null){
            
            Encrypter datoEnc =  new Encrypter();
            datoEnc.setMd5(true);////ESTA PARTE DE CODIGO ES PARA GENERAR EL md5
            
            usuarios.setIntentos(0);
            
            if (datosUsuario!=null){
                datosUsuario.setNombre(nombre);
                datosUsuario.setApellidoPat(apaterno);
                datosUsuario.setApellidoMat(amaterno);
                datosUsuario.setCelular(celular);
                datosUsuario.setCorreo(email);
                datosUsuario.setDireccion(direccion);               
                datosUsuario.setTelefono(telefono);
            }
            
            if (ldap!=null){
                //Cambio de contraseña
                if (passwordNuevo.trim().length()>0 && passwordNuevoConfirmacion.trim().length()>0){
                    String pwdCodificado = datoEnc.encodeString2(passwordNuevo);
                    ldap.setPassword(pwdCodificado);
                    //ldap.setFirmado(1);
                }

                //ldap.setEmail(email);
            }
            
            if (msgError.equals("")){
                try{
                    //Actualizamos registros
                    new UsuariosDaoImpl(user.getConn()).update(usuarios.createPk(), usuarios);
                    
                    if (ldap!=null)
                        new LdapDaoImpl(user.getConn()).update(ldap.createPk(), ldap);
                    
                    if (datosUsuario!=null)
                        new DatosUsuarioDaoImpl(user.getConn()).update(datosUsuario.createPk(), datosUsuario);
                    
                    /*if (datosVendedor!=null)
                        new SgfensVendedorDatosDaoImpl(user.getConn()).update(datosVendedor.createPk(), datosVendedor);*/
                    
                }catch(Exception ex){
                    msgError += ex.toString();
                }
            }
            
            if (!msgError.equals("")){
                out.print("<!--ERROR-->"+msgError);
            }else{
                out.print("<!--EXITO--> Los cambios fueron aplicados exitosamente.");
            }
            
        }else{
            out.print("<!--ERROR-->No se pudieron recuperar los datos básicos del usuario. Intente iniciando sesión de nuevo.");
        }
    }else{
        out.print("<!--ERROR-->"+msgError);
    }
    
%>
