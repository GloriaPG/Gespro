<%@ page language="java" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%request.setCharacterEncoding("UTF-8");
            
    int idReport = 0;
    
    //String parametrosCustom = request.getParameter("parametrosCustom")!=null?new String( java.net.URLDecoder.decode(request.getParameter("parametrosCustom"), "UTF-8").getBytes("ISO-8859-1"),"UTF-8"):"";
    String parametrosCustom = request.getParameter("parametrosCustom")!=null?java.net.URLDecoder.decode(request.getParameter("parametrosCustom"), "UTF-8"):"";
    String parametrosExtra = request.getParameter("parametrosExtra")!=null?java.net.URLDecoder.decode(request.getParameter("parametrosExtra"), "UTF-8"):"";
    String infoTitle = request.getParameter("infoTitle")!=null?java.net.URLDecoder.decode(request.getParameter("infoTitle"), "UTF-8"):"";
    
    try{
        idReport = Integer.parseInt(request.getParameter("idReport"));
    }catch(NumberFormatException ex){}
%>
<!-- OPCIONES DE EXPORTACIÓN-->
<br class="clear"/>
<div id="div_exportar" name="div_exportar" class="switch" style="float: right;">
    <table cellpadding="0" cellspacing="0">
        <tbody>
                <tr>
                    <td>
                        <form action="../reportesExportar/exportarPDF.jsp" id="search_form_pdf" name="search_form_pdf" method="post" target="_blank" >
                            <input type="hidden" id="i" name="i" value="<%= idReport %>">
                            <input type="hidden" id="parametrosCustom" name="parametrosCustom" value="<%= parametrosCustom%>">
                            <input type="hidden" id="parametrosExtra" name="parametrosExtra" value="<%= parametrosExtra%>">
                            <input type="hidden" id="infoTitle" name="infoTitle" value="<%= infoTitle%>">
                            <input type="submit" id="pdf" name="pdf" class="right_switch" value="PDF" 
                                style="float: right; "/>
                        </form>
                    </td>
                    <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                    <td>
                        <form action="../reportesExportar/exportarXLS.jsp" id="search_form_xls" name="search_form_xls" method="post" target="_blank" >
                            <input type="hidden" id="i" name="i" value="<%= idReport %>">
                            <input type="hidden" id="parametrosCustom" name="parametrosCustom" value="<%= parametrosCustom%>">
                             <input type="hidden" id="parametrosExtra" name="parametrosExtra" value="<%= parametrosExtra%>">
                             <input type="hidden" id="infoTitle" name="infoTitle" value="<%= infoTitle%>">
                            <input type="submit" id="xls" name="xls" class="right_switch" value="XLS" 
                                style="float: right; "/>
                        </form>
                    </td>
                </tr>
        </tbody>
    </table>
</div>
<br class="clear"/>
<!-- FIN OPCIONES DE EXPORTACIÓN-->