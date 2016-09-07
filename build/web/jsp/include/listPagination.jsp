<%-- 
    Document   : listPagination
    Created on : 27-10-2012, 09:28:26
    Author     : ISC César Martínez poseidon24@hotmail.com
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    int paginaActual = 0;
    try{
        paginaActual = Integer.parseInt(request.getParameter("paginaActual"));
    }catch(NumberFormatException ex){}

    int numeroPaginasAMostrar = 0;
    try{
        numeroPaginasAMostrar = Integer.parseInt(request.getParameter("numeroPaginasAMostrar"));
    }catch(NumberFormatException ex){}

    int paginasTotales = 0;
    try{
        paginasTotales = Integer.parseInt(request.getParameter("paginasTotales"));
    }catch(NumberFormatException ex){}

    String url = request.getParameter("url")!=null?request.getParameter("url"):"";
    String parametrosAdicionales = request.getParameter("parametrosAdicionales")!=null?"&"+request.getParameter("parametrosAdicionales"):"";

%>
                        <div class="pagination">
                            <% if(paginaActual>1){ %>
                                <a href="<%=url%>?pagina=1<%=parametrosAdicionales%>">|&laquo;</a>
                                <a href="<%=url%>?pagina=<%=paginaActual-1 %><%=parametrosAdicionales%>">&laquo;</a>
                            <% }else{ %>
                                <a href="#" class="active">|&laquo;</a>
                                <a href="#" class="active">&laquo;</a>
                            <% } %>
                            <%
                            if((numeroPaginasAMostrar+1)<paginaActual)
                                out.print("...");
                            for(int i=(paginaActual>numeroPaginasAMostrar?paginaActual-numeroPaginasAMostrar:1);
                                i<(paginaActual+numeroPaginasAMostrar+1) && i<=paginasTotales;
                                i++){
                                if(paginaActual==i){
                            %>
                                    <a href="#" class="active"><%=i%></a>
                                <% }else{ %>
                                    <!--<a href="<%=url%>?pagina=<%=i%>"><%=i%></a>-->
                                    <a href="<%=url%>?pagina=<%=i%><%=parametrosAdicionales%>"><%=i%></a>
                            <%
                                }
                            }
                            if((paginaActual+numeroPaginasAMostrar+1)<paginasTotales)
                                out.print("...");
                            %>
                            <% if(paginaActual<paginasTotales){ %>
                                <!--<a href="<%=url%>?pagina=<%=paginaActual+1 %>">siguiente >></a>
                                <a href="<%=url%>?pagina=<%=paginasTotales %>">&uacute;ltima >></a>-->
                                <a href="<%=url%>?pagina=<%=paginaActual+1 %><%=parametrosAdicionales%>">&raquo;</a>
                                <a href="<%=url%>?pagina=<%=paginasTotales %><%=parametrosAdicionales%>">&raquo;|</a>
                            <% }else{ %>
                                <a href="#" class="active">&raquo;</a>
                                <a href="#" class="active">&raquo;|</a>
                            <% } %>

                        </div>