<%-- 
    Document   : uploadForm
    Created on : 12-oct-2011, 22:50:30
    Author     : ISC Cesar Martinez poseidon24@hotmail.com
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<%
    response.addHeader("Expires", "0");
    response.addHeader("Cache-Control", "no-store, no-cache, must-revalidate");
    response.addHeader("Cache-Control", "post-check=0, pre-check=0");
    response.addHeader("Pragma", "no-cache");
%>
<jsp:include page="../include/jsFunctions.jsp"/>

<%
String msg = "";
%>

<%
    String id = request.getParameter("id")!=null?request.getParameter("id"):"";
    String fn = request.getParameter("fn")!=null?request.getParameter("fn"):"";
    String validate = request.getParameter("validate")!=null?request.getParameter("validate"):"";
    String div = request.getParameter("div")!=null?request.getParameter("div"):"";
%>
<div class="form">
    
    <form id="form_<%=id %>" name="form_<%=id %>" method="post" enctype="multipart/form-data" class="niceform" action="uploadAjax.jsp?div=<%=div%>&validate=<%=validate%>&id_control=<%=id %>" target="iframe_archivo_interno_<%=id %>">
    
        <dl>
            <dd>
                <input type="file" name="<%=id %>" id="<%=id %>" />
                <input type="button" name="btn_<%=id %>" id="btn_<%=id %>" value="Subir" onclick="parent.<%=fn %>('form_<%=id %>');"/>
            </dd>
        </dl>
    </form>
            <iframe id="iframe_archivo_interno_<%=id %>" name="iframe_archivo_interno_<%=id %>" style="border: none" />
    <%=msg%>
</div>