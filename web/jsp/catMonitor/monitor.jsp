<%-- 
    Document   : mapa
    Created on : 13-ago-2016, 15:18:23
    Author     : zesk8
--%>

<%@page import="com.tsp.gespro.hibernate.pojo.Actividad"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Usuarios"%>
<%@page import="com.tsp.gespro.Services.Allservices"%>
<%@page import="com.tsp.gespro.hibernate.pojo.LoginCliente"%>
<%@page import="com.tsp.gespro.hibernate.dao.LoginClienteDAO"%>
<%@page import="com.tsp.gespro.dto.Roles"%>
<%@page import="com.tsp.gespro.jdbc.RolesDaoImpl"%>
<%@page import="com.tsp.gespro.hibernate.dao.ProyectoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Proyecto"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Monitor de Proyectos</title>
        <script   src="https://code.jquery.com/jquery-1.11.0.min.js"   integrity="sha256-spTpc4lvj4dOkKjrGokIrHkJgNA0xMS98Pw9N7ir9oI="   crossorigin="anonymous"></script>  
        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        <!-- Latest compiled and minified CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
        <!-- Optional theme -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

        <!-- Latest compiled and minified JavaScript -->
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
        <%
            List<Proyecto> proyectoList = new Allservices().queryProyectoDAO("where status=1");
            List<Usuarios> promotores=new Allservices().QueryUsuariosDAO("where ID_ROLES=4");
            RolesDaoImpl rolesDaoImpl=new RolesDaoImpl(user.getConn());
            Roles rol=rolesDaoImpl.findByPrimaryKey(user.getUser().getIdRoles());
            
            if(rol.getNombre().equals("CLIENTE")){
                LoginClienteDAO loginClienteDAO=new LoginClienteDAO(user.getConn());
                LoginCliente lc=loginClienteDAO.getByIdUsuario(user.getUser().getIdUsuarios());
                proyectoList = new ProyectoDAO().getListByIdClient(lc.getIdCliente());
                String query="(";
                String proyectosID="";
                for(Proyecto proyecto: proyectoList){
                     proyectosID += String.valueOf(proyecto.getIdProyecto()) +",";
                }
                if(proyectosID.length()>0){
                    query+=proyectosID.substring(0,proyectosID.length()-1);
                }else{
                    query="(0";
                }

                query += ")";
                String where="where id_proyecto in " + query;
                List<Actividad> actividades=new Allservices().QueryActividadDAO(where);
                String promotoresID="";
                query="(";
                for(Actividad pro: actividades){
                     if(pro.getIdUser()!=null){
                         promotoresID += String.valueOf(pro.getIdUser()) +",";
                     }     
                }
                if(promotoresID.length()>0){
                    query+=promotoresID.substring(0,promotoresID.length()-1);
                }else{
                    query="(0";
                }
                
                query+=")";
                where="where id_usuarios in " + query;
                promotores=new Allservices().QueryUsuariosDAO(where);
            }
            
        %>
        
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
              <div class="col-md-12 text-center">
                   <h1>Avance de proyectos</h1>
              </div>
              <div class="col-md-12 text-center">
                  <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="../../jsp/inicio/main.jsp">Home</a></li>
                    <li class="breadcrumb-item active">Monitor</li>
                  </ol>
              </div>
            </div>
            <div class="row">
              <div class="col-md-1"></div>
              <div class="col-md-11">
                  <form class="form-inline">
                    <div class="form-group region">
                      <label for="region">Region</label>
                      <select name="region" id="region" class="form-control">
                        <option value="MX" selected>México</option>
                        <option value="BZ">Belize</option>
                        <option value="CR">Costa Rica</option>
                        <option value="GT">Guatemala</option>
                        <option value="HN">Honduras</option>
                        <option value="NI">Nicaragua</option>
                        <option value="PA">Panama</option>
                        <option value="SV">El Salvador</option>
                        <option value="AR">Argentina</option>
                        <option value="BO">Bolivia</option>
                        <option value="BR">Brazil</option>
                        <option value="CL">Chile</option>
                        <option value="CO">Colombia</option>
                        <option value="EC">Ecuador</option>
                        <option value="FK">Malvinas</option>
                        <option value="GF">French Guiana</option>
                        <option value="GY">Guyana</option>
                        <option value="PE">Perú</option>
                        <option value="PY">Paraguay</option>
                        <option value="SR">Suriname</option>
                        <option value="UY">Uruguay</option>
                        <option value="VE">Venezuela</option>
                      </select>
                    </div>
                    <div class="form-group proyectos">
                      <label for="proyecto">Proyecto</label>
                      <input type="hidden" id="id_proyecto" value=""/>
                      <select id="selector-proyecto" name="proyecto" id="proyecto"class="form-control">
                        <option value="0">Seleccione un proyecto</option>
                        <%
                         for(Proyecto proyecto:proyectoList) {%>
                            <option value="<%=proyecto.getIdProyecto()%>"> <%=proyecto.getNombre()%> </option>
                        <%  
                         }
                         %>
                     </select>
                    </div>
                     <button id="btnProyectos"  class="btn btn-primary">Buscar avance</button>
                    <div class="form-group promotores">
                        <label for="promotores">Promotores</label>
                        <input type="hidden" id="id_promotor" value=""/>
                        <select id="selector-proyecto" name="promotor" id="promotor" class="form-control">
                         <option value="0">Seleccione un promotor</option>
                         <%
                         for(Usuarios promo: promotores) {%>
                          <option value="<%= promo.getIdUsuarios() %>"> <%= promo.getUserName() %> </option>
                          <%  
                           }
                          %>
                       </select>
                    </div>
                    <button id="btnPromotores"  class="btn btn-primary">Buscar avance</button>
                  </form>
              </div>
            </div>
            <div class="row">
              <div class="col-md-1"></div>
              <div class="col-md-5">
                <h1>Avance por estado</h1>
                <div id="regions_div"></div>
              </div>
              <div class="col-md-5">
                <h1>Avance por ciudad</h1>
                <div id="chart_div"></div>
              </div>
              <div class="col-md-1"></div>
            </div>
            <div class="row">
              <div class="col-md-1"></div>
              <div class="col-md-5">
               <table class="table table-sm">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Proyecto</th>
                    <th>Avance</th>
                    <th></th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  <%
                     for(Proyecto pro:proyectoList){                       
                  %>
                  <tr>
                      <th scope="row"><%= pro.getIdProyecto()%></th>
                    <td><%= pro.getNombre()%></td>
                    <td><%= pro.getAvance() %> %</td>
                    <td><button href="#myModal" data-id="<%= pro.getIdProyecto() %>" data-toggle="modal" type="button" class="btn btn-link btnActividad">Actividades</button></td>
                    <td><button href="#modalPromotor" data-id="<%= pro.getIdProyecto() %>" data-toggle="modal" type="button" class="btn btn-link btnPromotor">Promotores</button></td>
                  </tr>
                  <%}%>
                </tbody>
              </table>
              </div>
              
              <div class="col-md-5">
                <table class="table table-sm">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Proyecto</th>
                    <th>Avance</th>
                    <th></th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  <%
                     for(Proyecto pro:proyectoList){                       
                  %>
                  <tr>
                      <th scope="row"><%= pro.getIdProyecto()%></th>
                    <td><%= pro.getNombre()%></td>
                    <td><%= pro.getAvance() %> %</td>
                    <td><button href="#myModal" data-id="<%= pro.getIdProyecto() %>" data-toggle="modal" type="button" class="btn btn-link btnActividad">Actividades</button></td>
                    <td><button href="#modalPromotor" data-id="<%= pro.getIdProyecto() %>" data-toggle="modal" type="button" class="btn btn-link btnPromotor">Promotores</button></td>
                  </tr>
                  <%}%>
                </tbody>
              </table>
              </div>
              <div class="col-md-1"></div>
            </div>
        </div>
        
        <script type="text/javascript">
            $( document ).ready(function() {
                var URLdomain = window.location.host;
                function proyectos(){
                    var restURL="http://"+URLdomain+"/Gespro/rest/avance/proyecto/";
                    restURL+="?proyecto="+$("#id_proyecto").val();
                    printMaps(restURL);
                }

                function promotores(){
                    var URLdomain = window.location.host;
                    var restURL="http://"+URLdomain+"/Gespro/rest/avance/promotor/";
                    restURL+="?promotor="+$("#id_promotor").val();
                    printMaps(restURL);
                }
                $( "#btnProyectos" ).click(function(e) {
                    e.preventDefault();
                    proyectos();
                });
                $( "#btnPromotores" ).click(function(e) {
                   e.preventDefault();
                   promotores();
                });
                $(".btnActividad").on('click', function(event) {
                   event.preventDefault();
                   var restURL="http://"+URLdomain+"/Gespro/rest/avance/actividad";
                   restURL+="?proyecto="+$(this).attr('data-id');
                   $.get(restURL, function(data) {
                        var tr="";
                        data.map(function(item) {
                            tr+="<tr>";
                            tr+="<th scope='row'>";
                            tr+=item.idActividad;
                            tr+="</th>";
                            tr+="<td>";
                            tr+=item.actividad;
                            tr+="</td>";
                            tr+="<td>";
                            tr+=item.descripcion;
                            tr+="</td>";
                            tr+="<td>";
                            if(typeof item.checkin != "undefined" ){
                                tr+=item.checkin;
                            }else{
                                tr+="Sin checkin";
                            }
                            
                            tr+="</td>";
                            if(item.avance==100.00){
                                tr+="<td class='bg-success'>"
                            }else{
                              tr+="<td>";  
                            }
                            tr+=item.avance+" %";
                            tr+="</td>";
                            tr+="</tr>";
                        });
                        
                        $("#actividades_tr").html(tr);
                    })
                    .done(function() {
                    })
                    .fail(function(error) {
                      console.log("Error" + error);
                    })
                });
                
                $( ".btnPromotor").on('click', function(event) {
                   var restURL="http://"+URLdomain+"/Gespro/rest/avance/avance-promotor";
                   restURL+="?proyecto="+$(this).attr('data-id');
                   $.get(restURL, function(data) {
                        var tr="";
                        data.map(function(item) {
                            tr+="<tr>";
                            tr+="<th scope='row'>";
                            tr+=item.promotor;
                            tr+="</th>";
                            tr+="<td class='bg-info text-center'>";
                            tr+=item.avance+" %";
                            tr+="</td>";
                            tr+="</tr>";
                        });
                        
                        $("#promotor_tr").html(tr);
                    })
                    .done(function() {
                    })
                    .fail(function(error) {
                      console.log("Error" + error);
                    })
                });
            
            });
            
            
            google.load("maps", "3", {other_params: "key=AIzaSyA6cb9XFRRlRZbkOAvgjoRiGTOuKbemoJ0"});
            google.charts.load('current', {'packages':['geochart']});
            /**
             * Draw regions maps
             * @type Array Regions array
             * @returns {void}
             */
            function drawRegionsMap(regionsArray) {
                var data = google.visualization.arrayToDataTable(regionsArray);
                var region=$( "#region" ).val();
                console.log("datos ; " + region);
                var options = {
                    region: region,
                    resolution: 'provinces',
                    colorAxis: {colors: ['#70ad47', '#ffc000', '#ed7d31']}
                };
                var chart = new google.visualization.GeoChart(document.getElementById('regions_div'));

                chart.draw(data, options);
            }
            /**
             * Draw markers array
             * @type Array Markers array
             * @returns {void}
             */
            function drawMarkersMap(markersArray) {
                var data = google.visualization.arrayToDataTable(markersArray);
                var region=$( "#region" ).val();
                console.log("datos ; " + region);
                var options = {
                    region: region,
                    displayMode: 'markers',
                    resolution: 'provinces',
                    colorAxis: {colors: ['#70ad47', '#ffc000', '#ed7d31']}
                };
                var chart = new google.visualization.GeoChart(document.getElementById('chart_div'));
                chart.draw(data, options);
            }
            
            /** 
             * Get map info from end-point and show maps
             * @returns {void}
             */
            function printMaps(restURL) {
                var regionsArray = [
                    ['State', 'Avance']
                ];
                var markersArray = [
                    ['City',   'Avace']
                ];

                $.get(restURL, function(data) {
                    var regions = data.regiones;
                    var cities = data.ciudades;
                    // Fill markers and regions if status response was 200
                    if (typeof regions != 'undefined' || typeof cities != 'undefined') {
                       // Fill regions array
                        Object.keys(regions).map(function(key) {
                            regionsArray.push([key, regions[key]]);
                        });
                        // Fill cities array
                         Object.keys(cities).map(function(key) {
                             markersArray.push([key, cities[key]]);
                         }); 
                         drawRegionsMap(regionsArray);
                         drawMarkersMap(markersArray);
                    }
                })
                .done(function() {
                })
                .fail(function(error) {
                  console.log("Error" + error);
                })
            }           

            $("select[name=proyecto]").change(function(){
                $('#id_proyecto').val($(this).val());
            });
            $("select[name=promotor]").change(function(){
                $('#id_promotor').val($(this).val());
            });
            
        </script>
        
        <div class="modal fade" id="myModal">
        <div class="modal-dialog">
              <div class="modal-content">
                <div class="modal-header">
                  <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                  <h3 class="modal-title">Actividades</h3>
                </div>
                <div class="modal-body">
                          <h5 class="text-center">Estás son las actividades del proyecto seleccionado.</h5>
                  <table class="table table-striped" id="tblGrid">
                    <thead id="tblHead">
                      <tr>
                        <th>#</th>
                        <th>Actividad</th>
                        <th>Descripción</th>
                        <th>Checkin</th>
                        <th>Avance</th>
                      </tr>
                    </thead>
                    <tbody id="actividades_tr">
                    </tbody>
                  </table>
                </div>
                <div class="modal-footer">
                  <button type="button" class="btn btn-default " data-dismiss="modal">Close</button>
                </div>			
              </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
          </div><!-- /.modal -->
          
       <div class="modal fade" id="modalPromotor">
        <div class="modal-dialog">
              <div class="modal-content">
                <div class="modal-header">
                  <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                  <h3 class="modal-title">Promotores</h3>
                </div>
                <div class="modal-body">
                          <h5 class="text-center">Avances por promotor de el proyecto seleccionado.</h5>
                  <table class="table table-striped" id="tblGrid">
                    <thead id="tblHead">
                      <tr>
                        <th>#Promotor</th>
                        <th class="bg-info text-center">Avance</th>
                      </tr>
                    </thead>
                    <tbody id="promotor_tr">
                    </tbody>
                  </table>
                </div>
                <div class="modal-footer">
                  <button type="button" class="btn btn-default " data-dismiss="modal">Close</button>
                </div>			
              </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
          </div><!-- /.modal -->
    </body>
</html>
