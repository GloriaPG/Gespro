<%-- 
    Document   : captcha
    Created on : 26/09/2011, 01:20:02 PM
    Author     : ISC Cesar Martinez poseidon24@hotmail.com
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" autoFlush="true"%>
<%@ page import="java.io.*"%>
<%@ page import="java.awt.*"%>
<%@ page import="java.awt.image.*"%>
<%@ page import="javax.imageio.ImageIO"%>
<%@ page import="java.util.*"%>
<%
        /*
         * Para poder llamar al codigo desde una pagina jsp
         * lo hacemos de la siguiente manera
         *  <img src='captcha.jsp'>
         * y el valor estará en la variable de sesion "keyCaptcha"
         */
            try {
                int width = 80;
                int height = 30;
                Random rdm = new Random();
                int rl = rdm.nextInt();
                String hash1 = Integer.toHexString(rl);
                String capstr = hash1.substring(0, 5);
                HttpSession session_actual = request.getSession(true);
                String codigo_generado = (String) session_actual.getAttribute("keyCaptcha");
                if (codigo_generado == null) {
                    session_actual.setAttribute("keyCaptcha", capstr);
                } else {
                    session_actual.invalidate();
                    HttpSession nueva_session = request.getSession(true);
                    nueva_session.setAttribute("keyCaptcha", capstr);
                }
                Color background = new Color(255, 255, 255);
                Color fbl = new Color(0, 100, 0);
                Font fnt = new Font("SansSerif", 1, 17);
                BufferedImage cpimg = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
                Graphics g = cpimg.createGraphics();
                g.setColor(background);
                g.fillRect(0, 0, width, height);
                g.setColor(fbl);
                g.setFont(fnt);
                g.drawString(capstr, 15, 20);
                g.setColor(background);
                g.drawLine(20, 2, 60, 23);
                g.drawLine(50, 22, 80, 25);
                response.setContentType("image/jpeg");
                ServletOutputStream strm = response.getOutputStream();
                ImageIO.write(cpimg, "jpeg", strm);
                cpimg.flush();
                strm.flush();
                strm.close();
            } catch (Exception ex) {
                out.println(ex.getMessage());
            }
%>