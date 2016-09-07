<%-- 
    Document   : catUsuarios_reestablecerPass_ajax
    Created on : 26-oct-2012, 10:41:41
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.bo.PasswordBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
    String login = request.getParameter("username")==null?"":request.getParameter("username");
    String password_default = request.getParameter("password_default")!=null?new String(request.getParameter("password_default").getBytes("ISO-8859-1"),"UTF-8"):"";
    
    String mensajeUsuario="";
    
    PasswordBO passwordBO = new PasswordBO();
    if (StringManage.getValidString(password_default).length()<=0){
        //No se señalo una contraseña por defecto, se creará aleatoriamente y se enviara por correo
        if (passwordBO.reestablecerPasswordByLogin(login)){
            mensajeUsuario ="<!--EXITO-->Un correo se envío a la cuenta establecida del usuario con los nuevos datos de acceso. <br/> El nuevo password es: &nbsp;&nbsp; <i>" + passwordBO.getPassword() + "<i>";
        }else{
            mensajeUsuario ="<!--ERROR-->No se pudo reestablecer la contraseña de la cuenta indicada.<br/> Revise que el usuario indicado sea correcto.";
        }
    }else{
        //Se específico una contraseña por defecto. No se enviará por correo.
        if (passwordBO.reestablecerPasswordByLogin(login, password_default)){
            mensajeUsuario ="<!--EXITO-->Datos de acceso del usuario <b><i>"+login+"</i></b> actualizados. <br/> El password registrado es:&nbsp;<b><i>" + passwordBO.getPassword() + "<i></b>";
        }else{
            mensajeUsuario ="<!--ERROR-->No se pudo reestablecer la contraseña de la cuenta indicada.<br/> Revise que el usuario indicado sea correcto.";
        }
    }
    
    
    out.print(mensajeUsuario);
    
%>
