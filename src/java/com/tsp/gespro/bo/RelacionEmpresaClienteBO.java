/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.bo;

import com.tsp.gespro.dto.RelacionEmpresaCliente;
import com.tsp.gespro.exceptions.RelacionEmpresaClienteDaoException;
import com.tsp.gespro.jdbc.EmpresaDaoImpl;
import com.tsp.gespro.jdbc.RelacionEmpresaClienteDaoImpl;
import com.tsp.gespro.jdbc.ResourceManager;
import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 *
 * @author leonardo
 */
public class RelacionEmpresaClienteBO {
 private RelacionEmpresaCliente relacionEmpresaCliente = null;

    public RelacionEmpresaCliente getRelacionEmpresaCliente() {
        return relacionEmpresaCliente;
    }

    public void setRelacionEmpresaCliente(RelacionEmpresaCliente relacionEmpresaCliente) {
        this.relacionEmpresaCliente = relacionEmpresaCliente;
    }
    
    private Connection conn = null;

    public Connection getConn() {
        return conn;
    }

    public void setConn(Connection conn) {
        this.conn = conn;
    }
    
    public RelacionEmpresaClienteBO(Connection conn){
        this.conn = conn;
    }
    
    public RelacionEmpresaClienteBO(int idEmpresa, Connection conn){
        this.conn = conn;
        try{
            RelacionEmpresaClienteDaoImpl relacionEmpresaClienteDaoImpl = new RelacionEmpresaClienteDaoImpl(this.conn);
            RelacionEmpresaCliente [] relacionEmpresaClienteArreglo = relacionEmpresaClienteDaoImpl.findWhereIdEmpresaEquals(idEmpresa);
            if(relacionEmpresaClienteArreglo.length > 0) {
                this.relacionEmpresaCliente = relacionEmpresaClienteArreglo[0];
            }
            
        }catch(Exception e){
            e.printStackTrace();
        }
    }
        
    /**
     * Realiza una búsqueda por ID RelacionEmpresaCliente en busca de
     * coincidencias
     * @param idRelacionEmpresaCliente ID Del Usuario para filtrar, -1 para mostrar todos los registros
     * @param idEmpresa ID de la Empresa a filtrar relacionEmpresaClientes, -1 para evitar filtro
     *  @param minLimit Limite inferior de la paginación (Desde) 0 en caso de no existir limite inferior
     * @param maxLimit Limite superior de la paginación (Hasta) 0 en caso de no existir limite superior
     * @param filtroBusqueda Cadena con un filtro de búsqueda personalizado
     * @return DTO RelacionEmpresaCliente
     */
    public RelacionEmpresaCliente[] findRelacionEmpresaClientes(int idEmpresa, int idCliente, int minLimit,int maxLimit, String filtroBusqueda) {
        RelacionEmpresaCliente[] relacionEmpresaClienteDto = new RelacionEmpresaCliente[0];
        RelacionEmpresaClienteDaoImpl relacionEmpresaClienteDao = new RelacionEmpresaClienteDaoImpl(this.conn);
        try {
            String sqlFiltro="";
            if (idEmpresa>0){
                sqlFiltro +="ID_EMPRESA=" + idEmpresa + " AND ";
            }else{
                sqlFiltro +="ID_EMPRESA>0 AND ";
            }
            if (idCliente>0){
                sqlFiltro +="ID_CLIENTE=" + idCliente + " ";
            }else{
                sqlFiltro +="ID_CLIENTE>0 ";
            }
            if (!filtroBusqueda.trim().equals("")){
                sqlFiltro += filtroBusqueda;
            }
            
            if (minLimit<0)
                minLimit=0;
            
            String sqlLimit="";
            if ((minLimit>0 && maxLimit>0) || (minLimit==0 && maxLimit>0))
                sqlLimit = " LIMIT " + minLimit + "," + maxLimit;
            
            relacionEmpresaClienteDto = relacionEmpresaClienteDao.findByDynamicWhere( 
                    sqlFiltro
                    + " ORDER BY ID_EMPRESA DESC"
                    + sqlLimit
                    , new Object[0]);
            
        } catch (Exception ex) {
            System.out.println("Error de consulta a Base de Datos: " + ex.toString());
            ex.printStackTrace();
        }
        
        return relacionEmpresaClienteDto;
    }
    
    /** 
	 * Deletes a single row in the sgfens_pedido_producto table.
	 */
	public void delete(int idEmpresa, int idCliente) throws RelacionEmpresaClienteDaoException
	{
            String SQL_DELETE = "DELETE FROM RELACION_CLIENTE_VENDEDOR WHERE ID_EMPRESA = ? AND ID_CLIENTE = ?";
		long t1 = System.currentTimeMillis();
		// declare variables
		final boolean isConnSupplied = (this.conn != null);
		Connection conn = null;
		PreparedStatement stmt = null;
		
		try {
			// get the user-specified connection or get a connection from the ResourceManager
			conn = isConnSupplied ? this.conn : ResourceManager.getConnection();
		
			System.out.println( "Executing " + SQL_DELETE + " with EmpresaID: " + idEmpresa + ", ClienteID: " + idCliente );
			stmt = conn.prepareStatement( SQL_DELETE );
			stmt.setInt( 1, idEmpresa );
			stmt.setInt( 2, idCliente );
			int rows = stmt.executeUpdate();
			long t2 = System.currentTimeMillis();
			System.out.println( rows + " rows affected (" + (t2-t1) + " ms)" );
		}
		catch (Exception _e) {
			_e.printStackTrace();
			throw new RelacionEmpresaClienteDaoException( "Exception: " + _e.getMessage(), _e );
		}
		finally {
			ResourceManager.close(stmt);
			if (!isConnSupplied) {
				ResourceManager.close(conn);
			}
		
		}
		
	}
        
        /** 
	 * Deletes a todos los clientes relacionados table.
	 */
	public void deleteCliente(int idEmpresa) throws RelacionEmpresaClienteDaoException
	{
            String SQL_DELETE = "DELETE FROM RELACION_CLIENTE_VENDEDOR WHERE ID_EMPRESA = ?";
		long t1 = System.currentTimeMillis();
		// declare variables
		final boolean isConnSupplied = (this.conn != null);
		Connection conn = null;
		PreparedStatement stmt = null;
		
		try {
			// get the user-specified connection or get a connection from the ResourceManager
			conn = isConnSupplied ? this.conn : ResourceManager.getConnection();
		
			System.out.println( "Executing " + SQL_DELETE + " with EmpresaID: " + idEmpresa );
			stmt = conn.prepareStatement( SQL_DELETE );
			stmt.setInt( 1, idEmpresa );
			int rows = stmt.executeUpdate();
			long t2 = System.currentTimeMillis();
			System.out.println( rows + " rows affected (" + (t2-t1) + " ms)" );
		}
		catch (Exception _e) {
			_e.printStackTrace();
			throw new RelacionEmpresaClienteDaoException( "Exception: " + _e.getMessage(), _e );
		}
		finally {
			ResourceManager.close(stmt);
			if (!isConnSupplied) {
				ResourceManager.close(conn);
			}
		
		}
		
	}
    
    /**
     * Realiza una búsqueda por ID RelacionEmpresaCliente en busca de
     * coincidencias
     * @param idRelacionEmpresaCliente ID Del Usuario para filtrar, -1 para mostrar todos los registros
     * @param idEmpresa ID de la Empresa a filtrar relacionEmpresaClientes, -1 para evitar filtro     
     * @return String de cada una de las relacionEmpresaClientes
     */
    
    /*    public String getRelacionEmpresaClientesByIdHTMLCombo(int idEmpresa, int idSeleccionado){
        String strHTMLCombo ="";

        try{
            RelacionEmpresaCliente[] relacionEmpresaClientesDto = findRelacionEmpresaClientes(-1, idEmpresa, 0, 0, " AND ID_ESTATUS!=2 ");
            
            for (RelacionEmpresaCliente relacionEmpresaCliente:relacionEmpresaClientesDto){
                try{
                    //Categoria datosCategoria = new CategoriaDaoImpl(this.conn).findByPrimaryKey(categoria.getIdCategoria());
                    String selectedStr="";

                    if (idSeleccionado==relacionEmpresaCliente.getIdRelacionEmpresaCliente())
                        selectedStr = " selected ";

                    strHTMLCombo += "<option value='"+relacionEmpresaCliente.getIdRelacionEmpresaCliente()+"' "
                            + selectedStr
                            + "title='"+relacionEmpresaCliente.getNombre()+"'>"
                            + relacionEmpresaCliente.getNombre()
                            +"</option>";
                }catch(Exception ex){
                    ex.printStackTrace();
                }
            }
        }catch(Exception e){
            e.printStackTrace();
        }

        return strHTMLCombo;
    }*/
}
