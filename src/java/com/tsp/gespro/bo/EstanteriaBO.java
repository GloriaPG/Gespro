/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package com.tsp.gespro.bo;

import com.tsp.gespro.dto.Estanteria;
import com.tsp.gespro.exceptions.EstanteriaDaoException;
import com.tsp.gespro.jdbc.EstanteriaDaoImpl;
import java.sql.Connection;

/**
 *
 * @author leonardo
 */
public class EstanteriaBO {
    
    private Estanteria estanteria = null;

    public Estanteria getEstanteria() {
        return estanteria;
    }

    public void setEstanteria(Estanteria estanteria) {
        this.estanteria = estanteria;
    }
    
    private Connection conn = null;

    public Connection getConn() {
        return conn;
    }

    public void setConn(Connection conn) {
        this.conn = conn;
    }
    
    public EstanteriaBO(Connection conn){
        this.conn = conn;
    }
    
    public EstanteriaBO(int idEstanteria, Connection conn){        
        this.conn = conn;
        try{
            EstanteriaDaoImpl EstanteriaDaoImpl = new EstanteriaDaoImpl(this.conn);
            this.estanteria = EstanteriaDaoImpl.findByPrimaryKey(idEstanteria);
        }catch(Exception e){
            e.printStackTrace();
        }
    }
    
    public Estanteria findEstanteriabyId(int idEstanteria) throws Exception{
        Estanteria Estanteria = null;
        
        try{
            EstanteriaDaoImpl EstanteriaDaoImpl = new EstanteriaDaoImpl(this.conn);
            Estanteria = EstanteriaDaoImpl.findByPrimaryKey(idEstanteria);
            if (Estanteria==null){
                throw new Exception("No se encontro ninguna Estanteria que corresponda con los parámetros específicados.");
            }
            if (Estanteria.getIdEstanteria()<=0){
                throw new Exception("No se encontro ninguna Estanteria que corresponda con los parámetros específicados.");
            }
        }catch(Exception e){
            throw new Exception("Ocurrió un error inesperado mientras se intentaba recuperar la información de la Estanteria del usuario. Error: " + e.getMessage());
        }
        
        return Estanteria;
    }
        
    /**
     * Realiza una búsqueda por ID Estanteria en busca de
     * coincidencias
     * @param idEstanteria ID Del Usuario para filtrar, -1 para mostrar todos los registros
     * @param idEmpresa ID de la Empresa a filtrar estanterias, -1 para evitar filtro
     *  @param minLimit Limite inferior de la paginación (Desde) 0 en caso de no existir limite inferior
     * @param maxLimit Limite superior de la paginación (Hasta) 0 en caso de no existir limite superior
     * @param filtroBusqueda Cadena con un filtro de búsqueda personalizado
     * @return DTO Estanteria
     */
    public Estanteria[] findEstanterias(int idEstanteria, int idEmpresa, int idCliente, int idConcepto, int idUsuarioPromotor, int minLimit,int maxLimit, String filtroBusqueda) {
        Estanteria[] estanteriaDto = new Estanteria[0];
        EstanteriaDaoImpl estanteriaDao = new EstanteriaDaoImpl(this.conn);
        try {
            String sqlFiltro="";
            if (idEstanteria>0){
                sqlFiltro ="ID_ESTANTERIA=" + idEstanteria + " ";
            }else{
                sqlFiltro ="ID_ESTANTERIA>0 ";
            }
            if (idEmpresa>0){                
                sqlFiltro += " AND ID_EMPRESA IN (SELECT ID_EMPRESA FROM EMPRESA WHERE ID_EMPRESA_PADRE = " + idEmpresa + " OR ID_EMPRESA= " + idEmpresa + ")";
            }else{
                sqlFiltro +=" AND ID_EMPRESA>0 ";
            }
            if(idCliente > 0){
                sqlFiltro +=" AND ID_CLIENTE  = " + idCliente;
            }
            if(idConcepto > 0){
                sqlFiltro +=" AND ID_CONCEPTO  = " + idConcepto;
            }else{
                sqlFiltro +=" AND ID_CONCEPTO  >0 ";
            } 
            if(idUsuarioPromotor > 0){
                sqlFiltro +=" AND ID_USUARIO  = " + idUsuarioPromotor;
            }
            
            if (!filtroBusqueda.trim().equals("")){
                sqlFiltro += filtroBusqueda;
            }
            
            if (minLimit<0)
                minLimit=0;
            
            String sqlLimit="";
            if ((minLimit>0 && maxLimit>0) || (minLimit==0 && maxLimit>0))
                sqlLimit = " LIMIT " + minLimit + "," + maxLimit;
            
            estanteriaDto = estanteriaDao.findByDynamicWhere( 
                    sqlFiltro
                    + " ORDER BY ID_ESTANTERIA DESC"
                    + sqlLimit
                    , new Object[0]);
            
        } catch (Exception ex) {
            System.out.println("Error de consulta a Base de Datos: " + ex.toString());
            ex.printStackTrace();
        }
        
        return estanteriaDto;
    }
    /**
     * Realiza una búsqueda por ID estanteria en busca de
     * coincidencias
     * @param idEstanteria ID De la estanteria, -1 para mostrar todos los registros
     * @param idEmpresa ID de la Empresa a filtrar pedido, -1 para evitar filtro
     *  @param minLimit Limite inferior de la paginación (Desde) 0 en caso de no existir limite inferior
     * @param maxLimit Limite superior de la paginación (Hasta) 0 en caso de no existir limite superior
     * @param filtroBusqueda Cadena con un filtro de búsqueda personalizado
     * @return DTO SgfensPedido
     */
    public Estanteria[] findEstanteria(int idEstanteria, int idEmpresa, int minLimit,int maxLimit, String filtroBusqueda) {
        Estanteria[] estanteriaDto = new Estanteria[0];
        EstanteriaDaoImpl estanteriaDao = new EstanteriaDaoImpl(this.conn);
        try {
            String sqlFiltro="";
            if (idEstanteria>0){
                sqlFiltro ="ID_ESTANTERIA=" + idEstanteria + " AND ";
            }else{
                sqlFiltro ="ID_ESTANTERIA>0 AND ";
            }
            if (idEmpresa>0){
                sqlFiltro += " ID_EMPRESA IN (SELECT ID_EMPRESA FROM EMPRESA WHERE ID_EMPRESA_PADRE = " + idEmpresa + " OR ID_EMPRESA= " + idEmpresa + ") ";
            }else{
                sqlFiltro +=" ID_EMPRESA>0 ";
            }
            
            if (!filtroBusqueda.trim().equals("")){
                sqlFiltro += filtroBusqueda;
            }
            
            if (minLimit<0)
                minLimit=0;
            
            String sqlLimit="";
            if ((minLimit>0 && maxLimit>0) || (minLimit==0 && maxLimit>0))
                sqlLimit = " LIMIT " + minLimit + "," + maxLimit;
            
            String orderBy = " ORDER BY FECHA DESC ";
            
            estanteriaDto = estanteriaDao.findByDynamicWhere( 
                    sqlFiltro
                    + orderBy
                    + sqlLimit
                    , new Object[0]);
            
        } catch (Exception ex) {
            System.out.println("Error de consulta a Base de Datos: " + ex.toString());
            ex.printStackTrace();
        }
        
        return estanteriaDto;
    }
    
}

