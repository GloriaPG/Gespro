<%--
    Document   : login
    Created on : 15/08/2011, 04:45:10 PM
    Author     : ISC Cesar Martinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.bo.PasswordBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<jsp:useBean id="intentosFallidos" scope="session" class="java.lang.String"/>

<%


    String login="";
    String captcha ="";
    String captchaSesion = "";
    String mensajeUsuario = "";

    String urlRedir ="login.jsp";

    int intentosFallidosInt = 0;


    try {
        intentosFallidosInt = Integer.parseInt(intentosFallidos);
    }
    catch (Exception e) {
        intentosFallidos = "0";
        intentosFallidosInt = 0;
    }


    String action = request.getParameter("action")==null?"":request.getParameter("action");

    if (action.trim().equalsIgnoreCase("validar")) {
        login = request.getParameter("username")==null?"":request.getParameter("username");
        captcha = request.getParameter("captcha")==null?"":request.getParameter("captcha");

        HttpSession session_actual = request.getSession(true);
        captchaSesion = (String) session_actual.getAttribute("keyCaptcha");
        if (captchaSesion != null) {
            if (captcha.equals(captchaSesion)){

                PasswordBO passwordBO = new PasswordBO();
                if (passwordBO.reestablecerPasswordByLogin(login)){
                    mensajeUsuario ="Un correo se envío a tu cuenta establecida con los nuevos datos de acceso.<br/> <a href='../inicio/login.jsp'>Inicia aquí</a>";
                }else{
                    mensajeUsuario ="No se pudo reestablecer la contraseña de la cuenta indicada.<br/> Revise que el usuario indicado sea correcto. <a href=../inicio/restorePassword.jsp>Intenta de nuevo</a>";
                }

            }else{
                mensajeUsuario ="El texto de comprobación no corresponde. <a href=../inicio/restorePassword.jsp>Intenta de nuevo</a>";
            }
        }else {
            mensajeUsuario ="No se generó correctamente el texto de comprobación en el servidor. <a href=../inicio/restorePassword.jsp>Intenta de nuevo</a>";
        }
    }
    
    if (mensajeUsuario.trim().length()>0){
        mensajeUsuario = "<script> $('#login_info').css('display', 'block');</script>" + mensajeUsuario;
    }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

        <title><jsp:include page="../../jsp/include/titleApp.jsp" /></title>
        <jsp:include page="../include/keyWordSEO.jsp" />

        <link href="../../css/blue/screen.css" rel="stylesheet" type="text/css" media="all"/>

        <jsp:include page="../../jsp/include/jsFunctions.jsp" />

        <script type="text/javascript" charset="utf-8"> 
            $(function(){ 
                // find all the input elements with title attributes
                $('input[title!=""]').hint();
                
                $('#login_info').click(function(){
                       location.href ="login.jsp";
                    });
            });
        </script>

    </head>
    <body class="login">
        <!-- Inicio de ventana de login -->
        <div id="login_wrapper">
            
                <% if (mensajeUsuario.trim().length()>0){ %>
                
                <div id="login_info" class="alert_warning noshadow" 
                     style="width:350px;margin:auto;padding:auto; display: none;">
                    <p><%=mensajeUsuario%></p>
                </div>
                <br class="clear"/>
                <% } else { %>
                
                <div id="login_top_window">
                        <img src="../../images/blue/top_login_window.png" alt="top window"/>
                </div>

                <!-- Inicio de contenido -->
                <div id="login_body_window">
                        <div class="inner">
                                <h3>Reestablecer Contrase&ntilde;a</h3>
                                <form action="restorePassword.jsp?action=validar" method="post" id="form_login" name="form_login">
                                        <p>
                                            <input type="text" name="username" id="username"  style="width:285px" title="Usuario" />
                                        </p>
                                        <p>
                                            <img src='../include/captcha.jsp' alt="Texto Aleatorio de Comprobación">
                                            <input type="text" name="captcha" id="captcha" size="54" style="width:285px" title="Introduce el texto de comprobación aquí..."/>
                                        </p>
                                        <p style="margin-top:5px">
                                                <input type="submit" id="submit" name="submit" value="Enviar" class="Login" style="margin-right:15px"/>
                                                <input type="button" name="Cancelar" id="submit" value="Regresar" onclick="location.href ='login.jsp';//history.back();"/>
                                        </p>
                                </form>
                        </div>
                </div>
                <!-- FIN de contenido -->

                <div id="login_footer_window">
                        <img src="../../images/blue/footer_login_window.png" alt="footer window"/>
                </div>
                <div id="login_reflect">
                        <img src="../../images/blue/reflect.png" alt="window reflect"/>
                </div>
                
                <%}%>
        </div>
        <!-- FIN de ventana de login -->
        
    </body>
</html>
