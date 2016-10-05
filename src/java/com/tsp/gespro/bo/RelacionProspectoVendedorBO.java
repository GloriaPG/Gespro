/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.bo;

import com.tsp.gespro.dto.RelacionProspectoVendedor;
import com.tsp.gespro.exceptions.RelacionProspectoVendedorDaoException;
import com.tsp.gespro.jdbc.RelacionProspectoVendedorDaoImpl;
import com.tsp.gespro.jdbc.ResourceManager;
import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 *
 * @author DXN
 */
public class RelacionProspectoVendedorBO {
    private RelacionProspectoVendedor relacionProspectoVendedor = null;
    public RelacionProspectoVendedor getRelacionProspectoVendedor() {
        return relacionProspectoVendedor;
    }

    public void setRelacionProspectoVendedor(RelacionProspectoVendedor relacionProspectoVendedor) {
        this.relacionProspectoVendedor = relacionProspectoVendedor;
    }
    
    private Connection conn = null;

    public Connection getConn() {
        return conn;
    }

    public void setConn(Connection conn) {
        this.conn = conn;
    }
    
    public RelacionProspectoVendedorBO(Connection conn){
        this.conn = conn;
    }
    /**
     * Realiza una búsqueda por ID RelacionProspectoVendedor en busca de
     * coincidencias
     * @param idRelacionProspectoVendedor ID Del Usuario para filtrar, -1 para mostrar todos los registros
     * @param idEmpresa ID de la Empresa a filtrar relacionProspectoVendedors, -1 para evitar filtro
     *  @param minLimit Limite inferior de la paginación (Desde) 0 en caso de no existir limite inferior
     * @param maxLimit Limite superior de la paginación (Hasta) 0 en caso de no existir limite superior
     * @param filtroBusqueda Cadena con un filtro de búsqueda personalizado
     * @return DTO RelacionProspectoVendedor
     */
    public RelacionProspectoVendedor[] findRelacionProspectoVendedors(int idProspecto, int idUsuario, int minLimit,int maxLimit, String filtroBusqueda) {
        RelacionProspectoVendedor[] relacionProspectoVendedorDto = new RelacionProspectoVendedor[0];
        RelacionProspectoVendedorDaoImpl relacionProspectoVendedorDao = new RelacionProspectoVendedorDaoImpl(this.conn);
        try {
            String sqlFiltro="";
            if (idProspecto>0){
                sqlFiltro +="ID_PROSPECTO=" + idProspecto + " AND ";
            }else{
                sqlFiltro +="ID_PROSPECTO>0 AND ";
            }
            if (idUsuario>0){
                sqlFiltro +="ID_USUARIO=" + idUsuario + " ";
            }else{
                sqlFiltro +="ID_USUARIO>0 ";
            }
            if (!filtroBusqueda.trim().equals("")){
                sqlFiltro += filtroBusqueda;
            }
            
            if (minLimit<0)
                minLimit=0;
            
            String sqlLimit="";
            if ((minLimit>0 && maxLimit>0) || (minLimit==0 && maxLimit>0))
                sqlLimit = " LIMIT " + minLimit + "," + maxLimit;
            
            relacionProspectoVendedorDto = relacionProspectoVendedorDao.findByDynamicWhere( 
                    sqlFiltro
                    + " ORDER BY FECHA_ASIGNACION DESC"
                    + sqlLimit
                    , new Object[0]);
            
        } catch (Exception ex) {
            System.out.println("Error de consulta a Base de Datos: " + ex.toString());
            ex.printStackTrace();
        }
        
        return relacionProspectoVendedorDto;
    }
     /** 
	 * Deletes a single row in the relacion_prospecto_vendedor table.
	 */
	public void delete(int idProspecto, int idUsuario) throws RelacionProspectoVendedorDaoException
	{
            String SQL_DELETE = "DELETE FROM RELACION_PROSPECTO_VENDEDOR WHERE ID_PROSPECTO = ? AND ID_USUARIO = ?";
		long t1 = System.currentTimeMillis();
		// declare variables
		final boolean isConnSupplied = (this.conn != null);
		Connection conn = null;
		PreparedStatement stmt = null;
		
		try {
			// get the user-specified connection or get a connection from the ResourceManager
			conn = isConnSupplied ? this.conn : ResourceManager.getConnection();
		
			System.out.println( "Executing " + SQL_DELETE + " with ProspectoID: " + idProspecto + ", UsuarioID: " + idUsuario );
			stmt = conn.prepareStatement( SQL_DELETE );
			stmt.setInt( 1, idProspecto );
			stmt.setInt( 2, idUsuario );
			int rows = stmt.executeUpdate();
			long t2 = System.currentTimeMillis();
			System.out.println( rows + " rows affected (" + (t2-t1) + " ms)" );
		}
		catch (Exception _e) {
			_e.printStackTrace();
			throw new RelacionProspectoVendedorDaoException( "Exception: " + _e.getMessage(), _e );
		}
		finally {
			ResourceManager.close(stmt);
			if (!isConnSupplied) {
				ResourceManager.close(conn);
			}
		
		}
		
	}
        /** 
	 * Deletes a todos los prospectos relacionados table.
	 */
	public void deleteProspecto(int idProspecto) throws RelacionProspectoVendedorDaoException
	{
            String SQL_DELETE = "DELETE FROM RELACION_PROSPECTO_VENDEDOR WHERE ID_PROSPECTO = ?";
		long t1 = System.currentTimeMillis();
		// declare variables
		final boolean isConnSupplied = (this.conn != null);
		Connection conn = null;
		PreparedStatement stmt = null;
		
		try {
			// get the user-specified connection or get a connection from the ResourceManager
			conn = isConnSupplied ? this.conn : ResourceManager.getConnection();
		
			System.out.println( "Executing " + SQL_DELETE + " with ProspectoID: " + idProspecto );
			stmt = conn.prepareStatement( SQL_DELETE );
			stmt.setInt( 1, idProspecto );
			int rows = stmt.executeUpdate();
			long t2 = System.currentTimeMillis();
			System.out.println( rows + " rows affected (" + (t2-t1) + " ms)" );
		}
		catch (Exception _e) {
			_e.printStackTrace();
			throw new RelacionProspectoVendedorDaoException( "Exception: " + _e.getMessage(), _e );
		}
		finally {
			ResourceManager.close(stmt);
			if (!isConnSupplied) {
				ResourceManager.close(conn);
			}
		
		}
		
	}      
}
