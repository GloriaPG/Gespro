<%-- 
    Document   : historicoPromotor_ajax
    Created on : 10/01/2013, 10:55:39 PM
    Author     : Luis
--%>

<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.factory.UsuariosDaoFactory"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.tsp.gespro.factory.EmpleadoBitacoraPosicionDaoFactory"%>
<%@page import="com.tsp.gespro.dto.EmpleadoBitacoraPosicion"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%

    Date hoy = new Date();
    SimpleDateFormat formateador = new SimpleDateFormat("dd/MM/yyyy");    
    
    int id = 0;
    try{
         id = Integer.parseInt(request.getParameter("id"));
    }catch(Exception e){}
    
    String fechaDe = request.getParameter("fechaDe")!=null? new String(request.getParameter("fechaDe").getBytes("ISO-8859-1"),"UTF-8") : formateador.format(hoy);
    String fechaA = request.getParameter("fechaA")!=null? new String(request.getParameter("fechaA").getBytes("ISO-8859-1"),"UTF-8") :formateador.format(hoy);
       
    
    
    
    if(id > 0){
        
        Usuarios empleadoDto = null;
        DatosUsuario datosUsuarioDto = null;
        try{
             empleadoDto = UsuariosDaoFactory.create(user.getConn()).findByPrimaryKey(id);
            
            UsuarioBO usuarioBO = new UsuarioBO(user.getConn());
            usuarioBO = new UsuarioBO(user.getConn(),id);
            datosUsuarioDto =  usuarioBO.getDatosUsuario();
            
        }catch(Exception e){}
        if(empleadoDto!=null){
            System.out.println("FECHA DE: "+fechaDe);
            System.out.println("FECHA HASTA: "+fechaA+" 23:59:59");
            
            EmpleadoBitacoraPosicion[] empleadoBitacoraPosicionDto = EmpleadoBitacoraPosicionDaoFactory.create(user.getConn()).findByDynamicWhere(""
                + "ID_USUARIO = ? "
                + (fechaDe!=null && !fechaDe.equals("") ?"AND FECHA >= DATE_FORMAT(\"" + new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").format(new SimpleDateFormat("dd/MM/yyyy").parse(fechaDe)) + "\",\"%Y-%m-%d %T\") ":"")
                + (fechaA!=null && !fechaA.equals("")?"AND FECHA <= DATE_FORMAT(\"" + new SimpleDateFormat("yyyy/MM/dd 23:59:59").format(new SimpleDateFormat("dd/MM/yyyy").parse(fechaA)) + "\",\"%Y-%m-%d %T\") ":"")
                //+ " GROUP BY LATITUD, LONGITUD ORDER BY FECHA DESC", new Object[]{empleadoDto.getIdUsuarios()});
                + "  ORDER BY FECHA DESC", new Object[]{empleadoDto.getIdUsuarios()});
            
            
            
                
                String html = ""
                        + "Fecha de: <input type='text' id='txt_fecha_de' size='8' value='"+(fechaDe!=null?fechaDe:"")+"'/>&nbsp;&nbsp;"
                        + "Fecha a: <input type='text' id='txt_fecha_a' size='8' value='"+(fechaA!=null?fechaA:"")+"'/>&nbsp;&nbsp;"
                        + "<input type='button' value='Actualizar' onclick='actualizarHistorico("+id+")'/>&nbsp;&nbsp;"
                        + "<input type='button' value='Reproducir' onclick='reproducirHistorico(0)'/>"
                        + "<table class=\"data\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" >"
                        + "  <thead>"
                        + "        <tr>"
                        + "            <th>Fecha</th>"
                        + "            <th>Latitud</th>"
                        + "            <th>Longitud</th>"
                        + "            <th>Ubicar</th>"
                        + "        </tr>"
                        + "    </thead>";

                html +=  "    <tbody>";
            if(empleadoBitacoraPosicionDto.length > 0){
                for(EmpleadoBitacoraPosicion bitacoraPosicion:empleadoBitacoraPosicionDto){
                    
                    html += "<tr>"
                        + "<td>"
                        + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(bitacoraPosicion.getFecha())
                        + "</td>"
                        + "<td>"
                        + bitacoraPosicion.getLatitud()
                        + "</td>"
                        + "<td>"
                        + bitacoraPosicion.getLongitud()
                        + "</td>"
                        + "<td>"
                        + "<input type='hidden' name='marcadores_buscar' value='"+ bitacoraPosicion.getLatitud() + "," + bitacoraPosicion.getLongitud() +","+ new SimpleDateFormat("dd/MM/yyyy HH:mm").format(bitacoraPosicion.getFecha())+ "'/>"
                        + "<a href='javascript:void(0)' "
                        //+ "onclick='muestraMarcadorBusqueda("+bitacoraPosicion.getLatitud()+","+bitacoraPosicion.getLongitud()+",\"puntos\")'"
                        + "onclick=\"agregaMarcador("
                        + bitacoraPosicion.getLatitud() + ","
                        + bitacoraPosicion.getLongitud() + ","
                        + "'Ubicaci&oacute;n " + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(bitacoraPosicion.getFecha()) + "'"
                        + ")\""
                        + "> "
                        + "<img src='../../images/icon_movimiento.png' alt='Ubicar'/></a> "
                        + "</td>"
                        + "<tr>";
                    
                }
                
                html +=  "    </tbody>"
                 + "</table><!--EXITO-->";

                out.print(html);
                
            }else{
                 html +=  "    </tbody>"
                 + "</table><!--EXITO-->";
                out.print(html);
                out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
            }
            
        }else{
            out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
        }
    }else{
        out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
    }
%>

