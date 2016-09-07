
<%@page import="com.tsp.gespro.util.RutaEficientar"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.tsp.gespro.factory.RutaMarcadorDaoFactory"%>
<%@page import="com.tsp.gespro.dao.RutaMarcadorDao"%>
<%@page import="com.tsp.gespro.factory.RutaDaoFactory"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.dto.RutaMarcador"%>
<%@page import="com.tsp.gespro.jdbc.RutaMarcadorDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.RutaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RutaPk"%>
<%@page import="com.tsp.gespro.dto.Ruta"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%

    int idEmpresa = user.getUser().getIdEmpresa();

    int idTipoRuta = 0;
    try{
        idTipoRuta = Integer.parseInt(request.getParameter("txt_tipo_ruta"));
    }catch(Exception e){}
    int idPromotor = 0;
    try{
        idPromotor = Integer.parseInt(request.getParameter("id_p"));         
    }catch(Exception e){}
    
    ///*variable para ver si se actualizan los registros de una ruta o si se crea una nueva:
    int idRuta = 0;
    try{
        idRuta = Integer.parseInt(request.getParameter("idRuta"));         
    }catch(Exception e){}
    ///*
    
    String nombreRuta = request.getParameter("txt_nombre_ruta");
    String comentarioRuta = request.getParameter("txt_comentario_ruta");
    String recorridoRuta = request.getParameter("txt_recorrido_ruta");
    String marcadoresRuta = request.getParameter("txt_marcadores_ruta");
    String clientesRuta = request.getParameter("txt_clientes_ruta");
    String prospectosRuta = request.getParameter("txt_prospectos_ruta");
    
    //dias de ruta
    String domingo = request.getParameter("repetir_domingo")!=null?new String(request.getParameter("repetir_domingo").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String lunes = request.getParameter("repetir_lunes")!=null?new String(request.getParameter("repetir_lunes").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String martes = request.getParameter("repetir_martes")!=null?new String(request.getParameter("repetir_martes").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String miercoles = request.getParameter("repetir_miercoles")!=null?new String(request.getParameter("repetir_miercoles").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String jueves = request.getParameter("repetir_jueves")!=null?new String(request.getParameter("repetir_jueves").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String viernes = request.getParameter("repetir_viernes")!=null?new String(request.getParameter("repetir_viernes").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String sabado = request.getParameter("repetir_sabado")!=null?new String(request.getParameter("repetir_sabado").getBytes("ISO-8859-1"),"UTF-8"):"";

    String mensaje = request.getParameter("mensaje")!=null?new String(request.getParameter("mensaje").getBytes("ISO-8859-1"),"UTF-8"):""; 
    
    if(nombreRuta!=null && !nombreRuta.trim().equals("") && comentarioRuta!=null && !comentarioRuta.trim().equals("") && recorridoRuta!=null && !recorridoRuta.trim().equals("") && marcadoresRuta!=null){
        
        marcadoresRuta =  marcadoresRuta.replaceAll("\\),\\(", "|");
        marcadoresRuta =  marcadoresRuta.replaceAll("\\)", "");
        marcadoresRuta =  marcadoresRuta.replaceAll("\\(", "");
        
        String[] paradasRuta = marcadoresRuta.split("\\|");
        
        String diasRuta = "";
        if(!lunes.trim().equals(""))
            diasRuta += lunes+", ";
        if(!martes.trim().equals(""))
            diasRuta += martes+", ";
        if(!miercoles.trim().equals(""))
            diasRuta += miercoles+", ";
        if(!jueves.trim().equals(""))
            diasRuta += jueves+", ";
        if(!viernes.trim().equals(""))
            diasRuta += viernes+", ";
        if(!sabado.trim().equals(""))
            diasRuta += sabado+", ";
        if(!domingo.trim().equals(""))
            diasRuta += domingo+", ";
        
        Ruta rutaDto = null;
        RutaPk rutaPkDto = null;
        
        if(idRuta > 0){//si es una ruta que se esta modificando
            rutaDto = new RutaDaoImpl(user.getConn()).findByPrimaryKey(idRuta);
            rutaPkDto = rutaDto.createPk();
            //extraemos la lista de los marcadores de la ruta y eliminamos cada uno de ellos de la ruta, para meter los nuevos
            RutaMarcadorDaoImpl rutaMarcadorDaoImpl = new RutaMarcadorDaoImpl(user.getConn());
            RutaMarcador[] rutaMarcadors = new RutaMarcadorDaoImpl(user.getConn()).findWhereIdRutaEquals(idRuta);
            for(RutaMarcador marcador : rutaMarcadors){
                rutaMarcadorDaoImpl.delete(marcador.createPk());
            }
            rutaDto.setFhModificaRuta(new Date());
        }else{//si es una ruta nueva:
            rutaDto = new Ruta();
            rutaDto.setFhRegRuta(new Date());
            rutaPkDto = new RutaPk();
        }
        
        rutaDto.setComentarioRuta(new String(comentarioRuta.getBytes("ISO-8859-1"),"UTF-8"));
        
        rutaDto.setIdTipoRuta(idTipoRuta);
        rutaDto.setNombreRuta(new String(nombreRuta.getBytes("ISO-8859-1"),"UTF-8"));
        rutaDto.setParadasRuta(paradasRuta.length);
        rutaDto.setRecorridoRuta(recorridoRuta);
        rutaDto.setIdEmpresa(idEmpresa);
        rutaDto.setDiasSemanaRuta(diasRuta);
        
        try{
            if(idTipoRuta==4){
                
                rutaDto.setIdUsuario(idPromotor);
            }
            if(idRuta > 0){//si fue una ruta que se modifico, se actualizan los datos
                new RutaDaoImpl(user.getConn()).update(rutaPkDto, rutaDto);
            }else{//si es una ruta nueva, se crea el registro
                rutaPkDto = RutaDaoFactory.create(user.getConn()).insert(rutaDto);
            }
           
            String[] ubicacionClientes = new String[0];
            String[] ubicacionProspectos = new String[0];
            
            if(clientesRuta!=null){
                ubicacionClientes = clientesRuta.split("\\|");
            }
            
            if(prospectosRuta!=null){
                ubicacionProspectos = prospectosRuta.split("\\|");
            }
            
            RutaMarcadorDao rutaMarcadorDao = RutaMarcadorDaoFactory.create(user.getConn());
            
            //Ruta libre
            if(idTipoRuta==1){
                //creamos la lista de marcadores para despues eficietarla
                ArrayList<RutaMarcador> marcadoresAEficientar = new ArrayList<RutaMarcador>();
                for(String datosParada:paradasRuta){

                    String[] latLng = datosParada.split(",");

                    RutaMarcador rutaMarcadorDto = new RutaMarcador();
                    rutaMarcadorDto.setIdRuta(rutaPkDto.getIdRuta());
                    rutaMarcadorDto.setLatitudMarcador(latLng[0]);
                    rutaMarcadorDto.setLongitudMarcador(latLng[1]);
                    
                    marcadoresAEficientar.add(rutaMarcadorDto);
                    
                    
                    //rutaMarcadorDao.insert(rutaMarcadorDto);

                }
                ///Enviamos a eficietar
                RutaEficientar eficiente = new RutaEficientar();
                ArrayList<RutaMarcador> marcadoresEficientados = eficiente.eficientarRuta(marcadoresAEficientar);
                //recorremos la lista para ahora si guardarla ya eficientada:
                for(RutaMarcador marcad : marcadoresEficientados){
                    rutaMarcadorDao.insert(marcad);
                }
            }
            
            //ruta por cliente
            if(idTipoRuta==2 || idTipoRuta==4 || idTipoRuta==5){
                //creamos la lista de marcadores para despues eficietarla
                ArrayList<RutaMarcador> marcadoresAEficientar = new ArrayList<RutaMarcador>();
                for(String ubicacionCliente:ubicacionClientes){
                    String[] latLng = ubicacionCliente.split(",");
                    
                    RutaMarcador rutaMarcadorDto = new RutaMarcador();
                    rutaMarcadorDto.setIdRuta(rutaPkDto.getIdRuta());
                    rutaMarcadorDto.setLatitudMarcador(latLng[0]);
                    rutaMarcadorDto.setLongitudMarcador(latLng[1]);
                    rutaMarcadorDto.setIdCliente(Integer.parseInt(latLng[2]));
                                        
                    marcadoresAEficientar.add(rutaMarcadorDto);
                    //rutaMarcadorDao.insert(rutaMarcadorDto);
                }
                ///Enviamos a eficietar
                RutaEficientar eficiente = new RutaEficientar();
                ArrayList<RutaMarcador> marcadoresEficientados = eficiente.eficientarRuta(marcadoresAEficientar);
                //recorremos la lista para ahora si guardarla ya eficientada:
                for(RutaMarcador marcad : marcadoresEficientados){
                    rutaMarcadorDao.insert(marcad);
                }
            }
            
            //ruta por prospecto
            if(idTipoRuta==3){
                 //creamos la lista de marcadores para despues eficietarla
                ArrayList<RutaMarcador> marcadoresAEficientar = new ArrayList<RutaMarcador>();
                for(String ubicacionProspecto:ubicacionProspectos){
                    String[] latLng = ubicacionProspecto.split(",");
                    
                    RutaMarcador rutaMarcadorDto = new RutaMarcador();
                    rutaMarcadorDto.setIdRuta(rutaPkDto.getIdRuta());
                    rutaMarcadorDto.setLatitudMarcador(latLng[0]);
                    rutaMarcadorDto.setLongitudMarcador(latLng[1]);
                    rutaMarcadorDto.setIdProspecto(Integer.parseInt(latLng[2]));

                    marcadoresAEficientar.add(rutaMarcadorDto);
                    //rutaMarcadorDao.insert(rutaMarcadorDto);
                }
                ///Enviamos a eficietar
                RutaEficientar eficiente = new RutaEficientar();
                ArrayList<RutaMarcador> marcadoresEficientados = eficiente.eficientarRuta(marcadoresAEficientar);
                //recorremos la lista para ahora si guardarla ya eficientada:
                for(RutaMarcador marcad : marcadoresEficientados){
                    rutaMarcadorDao.insert(marcad);
                }
            }
            if(mensaje.equals("eficientar")){
                out.print("<!--EXITO-->Puntos Optimizados, de clic en \"Calcular ruta\"");
            }else{
                out.print("<!--EXITO-->Registro actualizado satisfactoriamente.");
            }
        }catch(Exception e){
            e.printStackTrace();
            out.print("<!--ERROR-->Ocurrió un error al almacenar los datos.");
        }
        
    }else{
        out.print("<!--ERROR-->Favor de llenar los datos requeridos.");
    }
    
%>