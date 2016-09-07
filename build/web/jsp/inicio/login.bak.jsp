<%--
    Document   : login
    Created on : 15/08/2011, 04:45:10 PM
    Author     : ISC Cesar Martinez poseidon24@hotmail.com
--%>
<%@page import="com.tsp.sct.bo.SGAccionBitacoraBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="intentosFallidos" scope="session" class="java.lang.String"/>
<jsp:useBean id="user" scope="session" class="com.tsp.sct.bo.UsuarioBO"/>

<%

    String login="";
    String pwd = "";
    String mensajeUsuario = "";

    String urlRedir ="main.jsp";

    int intentosFallidosInt = 0;


    try {
        intentosFallidosInt = Integer.parseInt(intentosFallidos);
    }
    catch (Exception e) {
        intentosFallidos = "0";
        intentosFallidosInt = 0;
    }


    String action = request.getParameter("action")==null?"":request.getParameter("action");

    if(action.trim().equalsIgnoreCase("loginRequired")){
        urlRedir = request.getParameter("urlSource")==null?urlRedir:request.getParameter("urlSource");
    }

 
    if (action.trim().equalsIgnoreCase("logout")) {
        if (user!=null && user.getUser()!=null){
            SGAccionBitacoraBO accionBitacora = new SGAccionBitacoraBO(user.getConn());
            accionBitacora.insertAccionLogout(user.getUser().getIdUsuarios(), "");
        }
        
        request.getSession().setAttribute("user", null);
        user=null;
        //mensajeUsuario="<script>apprise('<center><img src=../../images/candado.png> <br/>Sesión finalizada. <br/>Que tengas un excelente día, vuelve pronto!</center>',{'animate':true});</script>";
        mensajeUsuario = "<script> $('#login_info').css('display', 'block');</script> <center><img src=../../images/candado.png> <br/>Sesión finalizada.</center>";
    }else if (action.trim().equalsIgnoreCase("logoutInactiveSession")) {
        if (user!=null && user.getUser()!=null){
            SGAccionBitacoraBO accionBitacora = new SGAccionBitacoraBO(user.getConn());
            accionBitacora.insertAccionLogout(user.getUser().getIdUsuarios(), "Cierre de sesión automática por inactividad del usuario.");
        }

        request.getSession().setAttribute("user", null);
        user=null;
        
        //mensajeUsuario="<script>apprise('<center><img src=../../images/candado.png> <br/>Sesión finalizada por inactividad del usuario.</center>',{'animate':true});</script>";
        mensajeUsuario = "<script> $('#login_info').css('display', 'block');</script> <center><img src=../../images/candado.png> <br/>Sesión finalizada por inactividad del usuario.</center>";
    }
    else if (request.getParameter("username")!=null) {
        login = request.getParameter("username")==null?"":request.getParameter("username");
        pwd = request.getParameter("password")==null?"":request.getParameter("password");
 
        //Validamos el Login
        try{
            if (user.login(login, pwd)) {
                SGAccionBitacoraBO accionBitacora = new SGAccionBitacoraBO(user.getConn());
                accionBitacora.insertAccionLogin(user.getUser().getIdUsuarios(), "");

                request.getSession().setAttribute("user", user);

                if (user.requirePasswordChange()){
                    urlRedir = "../user/perfil.jsp?mode=1";
                }

                response.sendRedirect(urlRedir);
            }else{
                //mensajeUsuario = "<script>apprise('Usuario o contraseña inválidos',{'animate':true}); $('username').focus();</script>";
                mensajeUsuario = "<script> $('#login_info').css('display', 'block');</script> Usuario o contraseña inválidos";
            }
       }catch(Exception ex){
            mensajeUsuario = "<script> $('#login_info').css('display', 'block');</script> " + ex.toString();
       }
        
     }
 
    
        
%>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

    <title><jsp:include page="../../jsp/include/titleApp.jsp" /></title>
    <jsp:include page="../include/keyWordSEO.jsp" />

    <jsp:include page="../../jsp/include/skinCSS_login.jsp" />

    <jsp:include page="../../jsp/include/jsFunctions.jsp" />

    <script type="text/javascript" charset="utf-8"> 
        $(function(){ 
            // find all the input elements with title attributes
            $('input[title!=""]').hint();
            $('#login_info').click(function(){
                        $(this).fadeOut('fast');
                });
        });
    </script>
    <!---->
    <!--<script language="javascript" type="text/javascript">
        $(document).ready(function(){ $(":input:first").focus(); });
    </script>-->
    <!---->

</head>
<body class="login">
    <!-- Inicio de ventana de login -->
    <div id="login_wrapper">
            <div id="login_info" class="alert_warning noshadow" 
                 style="width:350px;margin:auto;padding:auto; display: none;">
                <p><%=mensajeUsuario%></p>
            </div>
            <br class="clear"/>
            <div id="login_top_window">
                    <img src="../../images/blue/top_login_window.png" alt="top window"/>
            </div>

            <!-- Inicio de contenido -->
            <div id="login_body_window">
                    <div class="inner">
                            <img src="../../images/login_logo.png" alt="logo"/>
                            <form action="login.jsp?<%out.print((request.getQueryString()!=null)&&(!action.trim().equalsIgnoreCase("logout") && !action.trim().equalsIgnoreCase("logoutInactiveSession"))?request.getQueryString():"action=login");%>" method="post" id="form_login" name="form_login">
                                    <p>
                                        <input type="text" id="username" name="username" style="width:285px" title="Usuario"/>
                                    </p>
                                    <p>
                                        <input type="password" id="password" name="password" style="width:285px" title="******"/>
                                    </p>
                                    <p style="margin-top:50px">
                                            <input type="submit" id="submit" name="submit" value="Entrar" class="Login" style="margin-right:15px"/>
                                            <a href="../inicio/restorePassword.jsp" class="forgot_pass">Olvide mi Contraseña!</a>
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
    </div>
    <!-- FIN de ventana de login -->
    
    
        
</body>
</html>