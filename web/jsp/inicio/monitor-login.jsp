<%-- 
    Document   : monitor-login
    Created on : 14/08/2016, 02:18:38 PM
    Author     : oem
--%>

<%@page import="java.util.Calendar"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.util.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<jsp:useBean id="monitor" scope="request" class="com.tsp.gespro.hibernate.pojo.UsuarioMonitor"/>
<jsp:setProperty name="monitor" property="*"/>
<jsp:useBean id="monitorDo" scope="request" class="com.tsp.gespro.hibernate.dao.UsuarioMonitorDAO"/>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="shortcut icon" href="../../images/favicon.ico">
    
    <title><jsp:include page="../../jsp/include/titleApp.jsp" /></title>
    <jsp:include page="../include/keyWordSEO.jsp" />

    <jsp:include page="../../jsp/include/skinCSS_login.jsp" />

    <jsp:include page="../../jsp/include/jsFunctions.jsp" />
    
    <link href="../../css/login/login_gespro.css" rel="stylesheet" type="text/css" media="all"/>
    <link href='https://fonts.googleapis.com/css?family=Montserrat:400,700' rel='stylesheet' type='text/css'>
    <script type="text/javascript" charset="utf-8"> 
        
        function submitFormulario(){
            $('#login_info').click(function(){
                        $(this).fadeOut('fast');
                });
            $('#form_login').submit();
        }
        
    </script>
    <!---->
    <!--<script language="javascript" type="text/javascript">
        $(document).ready(function(){ $(":input:first").focus(); });
    </script>-->
    <!---->

</head>
<body class="login">
    <!--<div id="adholder">
         <div id="adinner">
           <div class="adright"></div>
        </div>
    </div>-->
  <div id="envolvente1" >
  <div>
    <!-- Inicio de ventana de login -->

<div align="center" id="login_wrapper">
            <c:if test="${not empty monitor.email && not empty monitor.password}">
                <c:set value="${monitorDo.handleAutentificacion(monitor)}" var="autentication" />
                <c:set value="${autentication.activo}" var="activo"/>
                <c:if test="${activo}">
                    <!-- aqui es la variable de session -->
                    <c:set value="${monitorDo.handleAutentificacion(monitor)}" var="sessionmonitor" scope="session"/>
                </c:if> 
            </c:if>
            <div id="login_info" class="alert_warning noshadow" 
                 style="width:350px;margin:0;padding:auto; 
                 <c:choose>
                     <c:when test='${autentication.nombre == "Invalid"}'>
                         display: block;
                     </c:when>
                     <c:when test='${activo}'>
                         display: none;
                     </c:when>
                 </c:choose>">
                <p>
                        Usuario o contraseña inválidos
                </p>
            </div>
            <br class="clear"/>
            <div id="login_top_window">
                <div class="loginLinePretoriano">&nbsp;</div>
            </div>

            <!-- Inicio de contenido -->
            <div id="login_body_window">
                    <div class="inner">
                      <div id="logo_gespro_02" style="text-align:center; display:none">
                      <img src="images/login/gespro_logo.png"  alt="" width="30%" height="30%" /> 
          			  </div>
                            <form action="monitor-login.jsp" method="post" id="form_login" name="form_login">
                                    <p>
                                        <input type="text" id="username" name="email" style="width:285px" title="Usuario" placeholder="Usuario"/>
                                    </p>
                                    <p>
                                        <input type="password" id="password" name="password" style="width:270px" title="Contraseña" placeholder="******"/>
                                   
                                        <!--<input type="submit" id="submit" name="submit" value="Entrar" class="Login" style="margin-right:15px"/>-->
                                        <div id="login_submit_text">
                                            <a href="#" onclick="submitFormulario();" class="forgot_pass">Entrar</a>
                                        </div>
                                    </p>
                                     </p>
                                    &nbsp;&nbsp;&nbsp;<a href="../inicio/restorePassword.jsp" class="forgot_pass">Olvide mi Contraseña</a>
                                    <p>
                            </form>
                    </div>
            </div>
            <!-- FIN de contenido -->
            <div id="login_footer_window">
                <div class="loginLinePretoriano">&nbsp;</div>
            </div>
            <div id="login_right_bg">
                &nbsp;
            </div>
    </div>
     <!-- FIN de ventana de login --> 
    
    <!--coliseo-->
    <div style="display:inline-block; width:45%" id="gespro_01">
                <img src="../../images/login/gespro_logo.png" width="70%" height="70%" />
                </div>

    <!--coliseo-->
            </div>
            </div>
</body>
</html>