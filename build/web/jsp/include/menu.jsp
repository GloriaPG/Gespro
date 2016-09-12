<%-- 
    Document   : menu
    Created on : 24-oct-2012, 13:26:58
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<!-- Begin shortcut menu -->
<ul id="shortcut">
    <li>
        <a href="../../jsp/inicio/main.jsp" id="shortcut_home" title="Ir a Inicio">
            <img src="../../images/shortcut/home.png" alt="Inicio"/><br/>
            <strong>Inicio</strong>
        </a>
    </li>
    
    <!--
    <li>
        <a href="modal_window.html" title="Ir a Tesorería"
           class="modalbox_iframe">
            <img src="../../images/shortcut/kcalc.png" alt="tesoreria" width="40" height="40"/><br/>
            <strong>Tesorería</strong>
        </a>
    </li>
    -->
    <% if (user.getUser().getIdRoles() != RolesBO.ROL_GESPRO) { %>
    <li>
        <a href="../reporte/reporte_menu.jsp" id="shortcut_reportes" title="Ir a Reportes">
            <img src="../../images/shortcut/kchart.png" alt="Reportes" width="40" height="40" /><br/>
            <strong>Reportes</strong>
        </a>
    </li>
    <%}%>
    
    
    <% if (user.getUser().getIdRoles() != RolesBO.ROL_GESPRO) { %>
    <li>
        <a href="../../jsp/catReportesConfigurables/catReportesConfigurables_list.jsp" id="shortcut_reportes_config" title="Ir a Reportes Configurables">
            <img src="../../images/shortcut/posts.png" alt="Reportes Configurables" width="40" height="40" /><br/>
            <strong>Reportes&nbsp;C.</strong>
        </a>
    </li>
    <%}%>
    <!--
    <li>
        <a href="modal_window.html" title="Ir a Configuraciones"
           class="modalbox_iframe">
            <img src="../../images/shortcut/setting.png" alt="configuraciones"/><br/>
            <strong>Config.</strong>
        </a>
    </li>
    -->
    <li>
        <a href="../user/perfil.jsp" id="shortcut_perfil" title="Perfil del Usuario">
            <img src="../../images/shortcut/personal.png" alt="perfil" width="40" height="40"/><br/>
            <strong>Mi Perfil</strong>
        </a>
    </li>
</ul>
<!-- End shortcut menu -->

<!-- Begin shortcut notification -->
<div id="shortcut_notifications">
    <!--<span class="notification" rel="shortcut_home">1</span>-->
   <% if (user.requirePasswordChange()) {%>
    <span class="notification" rel="shortcut_perfil">!</span>
   <% } %>
</div>
<!-- End shortcut noficaton -->

<br class="clear"/>