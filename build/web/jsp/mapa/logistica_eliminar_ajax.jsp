
<%@page import="com.tsp.gespro.factory.RutaMarcadorDaoFactory"%>
<%@page import="com.tsp.gespro.dto.RutaMarcador"%>
<%@page import="com.tsp.gespro.dao.RutaMarcadorDao"%>
<%@page import="com.tsp.gespro.factory.RutaDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Ruta"%>
<%@page import="com.tsp.gespro.dao.RutaDao"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
    int idRuta = 0;
    try{
        idRuta = Integer.parseInt(request.getParameter("id"));
    }catch(Exception e){}
    if(idRuta>0){
    
        String mode = "";
        mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
        
        if(mode.equals("eliminarAsignacion")){
            RutaDao rutaDao = RutaDaoFactory.create(user.getConn());
            Ruta rutaDto = rutaDao.findByPrimaryKey(idRuta);
            rutaDto.setIdUsuario(0);
            try{
                rutaDao.update(rutaDto.createPk(), rutaDto);
                out.print("<!--EXITO-->Registro borrado satisfactoriamente");
            }catch(Exception e){
                out.print("<!--ERROR-->No se pudo eliminar la asignación. Informe del error al administrador del sistema: " + e.toString());                
            }
        }else{
            RutaDao rutaDao = RutaDaoFactory.create(user.getConn());
            try{
                RutaMarcadorDao rutaMarcadorDao = RutaMarcadorDaoFactory.create(user.getConn());
                RutaMarcador[] rutaMarcadorDto = rutaMarcadorDao.findWhereIdRutaEquals(idRuta);
                for(RutaMarcador marcador:rutaMarcadorDto){
                    rutaMarcadorDao.delete(marcador.createPk());
                }

                Ruta rutaDto = rutaDao.findByPrimaryKey(idRuta);
                rutaDao.delete(rutaDto.createPk());

                out.print("<!--EXITO-->Registro borrado satisfactoriamente");

            }catch(Exception e){
                out.print("<!--ERROR-->No se pudo borrar el registro. Informe del error al administrador del sistema: " + e.toString());
            }
        }
    }else{
        out.print("<!--ERROR-->No se pudo borrar el registro. No se recibió un objeto.");
    }
%>
