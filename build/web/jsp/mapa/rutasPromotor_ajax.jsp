
<%@page import="com.tsp.gespro.factory.RutaDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Ruta"%>
<%@page import="com.tsp.gespro.factory.UsuariosDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%

long id = 0l;
    try{
        id = Long.parseLong(request.getParameter("id"));
    }catch(Exception e){}
    if(id > 0){
        
        Usuarios empleadoDto = null;
        try{
            empleadoDto = UsuariosDaoFactory.create(user.getConn()).findByPrimaryKey(Integer.parseInt(request.getParameter("id")));
        }catch(Exception e){}
        if(empleadoDto!=null){
            
            Ruta[] rutasDto = RutaDaoFactory.create(user.getConn()).findWhereIdUsuarioEquals(empleadoDto.getIdUsuarios());
            
            if(rutasDto.length > 0){
                
                String html = "<table class=\"data\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" >"
                        + "  <thead>"
                        + "        <tr>"
                        + "            <th>ID Ruta</th>"
                        + "            <th>Nombre</th>"
                        + "            <th>Paradas</th>"
                        + "            <th>Ubicar</th>"
                        + "        </tr>"
                        + "    </thead>";

                html +=  "    <tbody>";

                for(Ruta rutaDto : rutasDto){
                    
                    //String marcadores = "";
                    //RutaMarcador[] rutaMarcadores = new RutaMarcadorBO(user.getConn()).findRutaMarcadors(-1, (int)rutaDto.getIdEmpresa(), 0, 0, " AND ID_RUTA = " + rutaDto.getIdRuta());
                    /*
                    RutaMarcador[] rutaMarcadores = RutaMarcadorDaoFactory.create(user.getConn()).findByDynamicWhere("ID_RUTA = " + rutaDto.getIdRuta() + " ORDER BY ID_RUTA_MARCADOR ASC", new Object[0]);
                    for(RutaMarcador rutaMarcador:rutaMarcadores){
                        if(!marcadores.equals("")){
                            marcadores += "|";
                        }
                        marcadores += rutaMarcador.getLatitudMarcador() + "," + rutaMarcador.getLongitudMarcador();
                    }
                    */                    
                    
                    html += "<tr>"
                        + "<td>"
                        + rutaDto.getIdRuta()
                        + "</td>"
                        + "<td>"
                        + rutaDto.getNombreRuta()
                        + "</td>"
                        + "<td>"
                        + rutaDto.getParadasRuta()
                        + "</td>"
                        + "<td>"
                        //+ "<a target='_blank' href='logistica_consulta.jsp?idRuta="+rutaDto.getIdRuta()+"&propiedad=1' onclick=cambiaRuta("+rutaDto.getIdRuta()+");"
                        + "<a onclick=cambiaRuta("+rutaDto.getIdRuta()+"); "    
                        //+ "href='logistica_consulta.jsp?idRuta=" +rutaDto.getIdRuta() +"' "
                        + "> "
                        + "<img src='../../images/icon_movimiento.png' alt='Ubicar'/></a> "
                        + "</td>"
                        + "<tr>";
                }
                

                html +=  "    </tbody>"
                 + "</table><!--EXITO-->";

                out.print(html);
            
            }else{
                out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
            }
        }else{
            out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
        }
    }else{
        out.print("<!--ERROR-->No se encontr&oacute; informaci&oacute;n.");
    }
%>
