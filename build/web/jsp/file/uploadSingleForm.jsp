<%-- 
    Document   : uploadSingleForm
    Created on : 23-jul-2012, 18:18:18
    Author     : ISCesarMartinez, ISC Cesar Martinez poseidon24@hotmail.com
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<script type="text/javascript" src="../../js/jquery.js"></script>

<%
    String id = request.getParameter("id")!=null?request.getParameter("id"):"";
    String validate = request.getParameter("validate")!=null?request.getParameter("validate"):"any";
    String queryCustom = request.getParameter("queryCustom")!=null?request.getParameter("queryCustom"):"";
    String returnURL = request.getParameter("returnURL")!=null?request.getParameter("returnURL"):"";
    String reloadIFrameParent = request.getParameter("reloadIFrameParent")!=null?request.getParameter("reloadIFrameParent"):"false";
    
    //String div = request.getParameter("div")!=null?request.getParameter("div"):"";
%>

<div class="form">
    
    <form id="form_<%=id %>" name="form_<%=id %>" method="post" enctype="multipart/form-data" class="niceform" action="../file/uploadSingleAjax.jsp?reloadIFrameParent=<%=reloadIFrameParent%>&validate=<%=validate%>&returnURL=<%=returnURL%>&<%=queryCustom%>" >
        <dl>
            <dd>
                <input type="file" name="<%=id %>" id="<%=id %>" />
                <input type="button" name="btn_<%=id %>" id="btn_<%=id %>" value="Subir" onclick="if ($('#<%=id %>').val().length>0){submit();}else{ alert('selecciona archivo!');}"/>
            </dd>
        </dl>
    </form>
    
    <iframe id="iframe_archivo_correo_interno" name="iframe_archivo_interno" style="border: none;" />
</div>
