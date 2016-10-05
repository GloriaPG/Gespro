/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.jdbc;


import com.tsp.gespro.dao.RelacionProspectoVendedorDao;
import com.tsp.gespro.dto.RelacionProspectoVendedor;
import com.tsp.gespro.exceptions.RelacionProspectoVendedorDaoException;
import static com.tsp.gespro.jdbc.RelacionProspectoVendedorDaoImpl.COLUMN_ID_PROSPECTO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;

/**
 *
 * @author DXN
 */
public class RelacionProspectoVendedorDaoImpl extends AbstractDAO implements RelacionProspectoVendedorDao{

    protected java.sql.Connection userConn;

	/** 
	 * All finder methods in this class use this SELECT constant to build their queries
	 */
	protected final String SQL_SELECT = "SELECT ID_PROSPECTO, ID_USUARIO, FECHA_ASIGNACION FROM " + getTableName() + "";

	/** 
	 * Finder methods will pass this value to the JDBC setMaxRows method
	 */
	protected int maxRows;

	/** 
	 * SQL INSERT statement for this table
	 */
	protected final String SQL_INSERT = "INSERT INTO " + getTableName() + " ( ID_PROSPECTO, ID_USUARIO, FECHA_ASIGNACION ) VALUES ( ?, ?, ? )";

	/** 
	 * Index of column ID_PROSPECTO
	 */
	protected static final int COLUMN_ID_PROSPECTO = 1;

	/** 
	 * Index of column ID_USUARIO
	 */
	protected static final int COLUMN_ID_USUARIO = 2;

	/** 
	 * Index of column FECHA_ASIGNACION
	 */
	protected static final int COLUMN_FECHA_ASIGNACION = 3;

	/** 
	 * Number of columns
	 */
	protected static final int NUMBER_OF_COLUMNS = 3;

	/** 
	 * Inserts a new row in the relacion_prospecto_vendedor table.
	 */
    
    @Override
    public void insert(RelacionProspectoVendedor dto) throws RelacionProspectoVendedorDaoException {
        long t1 = System.currentTimeMillis();
		// declare variables
		final boolean isConnSupplied = (userConn != null);
		Connection conn = null;
		PreparedStatement stmt = null;
		ResultSet rs = null;
		
		try {
			// get the user-specified connection or get a connection from the ResourceManager
			conn = isConnSupplied ? userConn : ResourceManager.getConnection();
		
			StringBuffer sql = new StringBuffer();
			StringBuffer values = new StringBuffer();
			sql.append( "INSERT INTO " + getTableName() + " (" );
			int modifiedCount = 0;
			if (dto.isIdProspectoModified()) {
				if (modifiedCount>0) {
					sql.append( ", " );
					values.append( ", " );
				}
		
				sql.append( "ID_PROSPECTO" );
				values.append( "?" );
				modifiedCount++;
			}
		
			if (dto.isIdUsuarioModified()) {
				if (modifiedCount>0) {
					sql.append( ", " );
					values.append( ", " );
				}
		
				sql.append( "ID_USUARIO" );
				values.append( "?" );
				modifiedCount++;
			}
		
			if (dto.isFechaAsignacionModified()) {
				if (modifiedCount>0) {
					sql.append( ", " );
					values.append( ", " );
				}
		
				sql.append( "FECHA_ASIGNACION" );
				values.append( "?" );
				modifiedCount++;
			}
		
			if (modifiedCount==0) {
				// nothing to insert
				throw new IllegalStateException( "Nothing to insert" );
			}
		
			sql.append( ") VALUES (" );
			sql.append( values );
			sql.append( ")" );
			stmt = conn.prepareStatement( sql.toString() );
			int index = 1;
			if (dto.isIdProspectoModified()) {
				stmt.setInt( index++, dto.getIdProspecto() );
			}
		
			if (dto.isIdUsuarioModified()) {
				stmt.setInt( index++, dto.getIdUsuario() );
			}
		
			if (dto.isFechaAsignacionModified()) {
				stmt.setDate(index++, dto.getFechaAsignacion()==null ? null : new java.sql.Date( dto.getFechaAsignacion().getTime() ) );
			}
		
			System.out.println( "Executing " + sql.toString() + " with values: " + dto );
			int rows = stmt.executeUpdate();
			long t2 = System.currentTimeMillis();
			System.out.println( rows + " rows affected (" + (t2-t1) + " ms)" );
			reset(dto);
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

    @Override
    public RelacionProspectoVendedor[] findAll() throws RelacionProspectoVendedorDaoException {
       return findByDynamicSelect( SQL_SELECT, null );
    }

    @Override
    public RelacionProspectoVendedor[] findWhereIdProspectoEquals(int idProspecto) throws RelacionProspectoVendedorDaoException {
        return findByDynamicSelect( SQL_SELECT + " WHERE ID_PROSPECTO = ? ORDER BY ID_PROSPECTO", new Object[] {  new Integer(idProspecto) } );
    }

    @Override
    public RelacionProspectoVendedor[] findWhereIdUsuarioEquals(int idUsuario) throws RelacionProspectoVendedorDaoException {
        return findByDynamicSelect( SQL_SELECT + " WHERE ID_USUARIO = ? ORDER BY ID_USUARIO", new Object[] {  new Integer(idUsuario) } );
    }

    @Override
    public RelacionProspectoVendedor[] findWhereFechaAsignacionEquals(Date fechaAsignacion) throws RelacionProspectoVendedorDaoException {
        return findByDynamicSelect( SQL_SELECT + " WHERE FECHA_ASIGNACION = ? ORDER BY FECHA_ASIGNACION", new Object[] { fechaAsignacion==null ? null : new java.sql.Date( fechaAsignacion.getTime() ) } );
    }

    @Override
    public void setMaxRows(int maxRows) {
      this.maxRows = maxRows;
    }

    @Override
    public int getMaxRows() {
        return maxRows;
    }

    @Override
    public RelacionProspectoVendedor[] findByDynamicSelect(String sql, Object[] sqlParams) throws RelacionProspectoVendedorDaoException {
        // declare variables
		final boolean isConnSupplied = (userConn != null);
		Connection conn = null;
		PreparedStatement stmt = null;
		ResultSet rs = null;
		
		try {
			// get the user-specified connection or get a connection from the ResourceManager
			conn = isConnSupplied ? userConn : ResourceManager.getConnection();
		
			// construct the SQL statement
			final String SQL = sql;
		
		
			System.out.println( "Executing " + SQL );
			// prepare statement
			stmt = conn.prepareStatement( SQL );
			stmt.setMaxRows( maxRows );
		
			// bind parameters
			for (int i=0; sqlParams!=null && i<sqlParams.length; i++ ) {
				stmt.setObject( i+1, sqlParams[i] );
			}
		
		
			rs = stmt.executeQuery();
		
			// fetch the results
			return fetchMultiResults(rs);
		}
		catch (Exception _e) {
			_e.printStackTrace();
			throw new RelacionProspectoVendedorDaoException( "Exception: " + _e.getMessage(), _e );
		}
		finally {
			ResourceManager.close(rs);
			ResourceManager.close(stmt);
			if (!isConnSupplied) {
				ResourceManager.close(conn);
			}
		
		}
    }

    @Override
    public RelacionProspectoVendedor[] findByDynamicWhere(String sql, Object[] sqlParams) throws RelacionProspectoVendedorDaoException {
        // declare variables
		final boolean isConnSupplied = (userConn != null);
		Connection conn = null;
		PreparedStatement stmt = null;
		ResultSet rs = null;
		
		try {
			// get the user-specified connection or get a connection from the ResourceManager
			conn = isConnSupplied ? userConn : ResourceManager.getConnection();
		
			// construct the SQL statement
			final String SQL = SQL_SELECT + " WHERE " + sql;
		
		
			System.out.println( "Executing " + SQL );
			// prepare statement
			stmt = conn.prepareStatement( SQL );
			stmt.setMaxRows( maxRows );
		
			// bind parameters
			for (int i=0; sqlParams!=null && i<sqlParams.length; i++ ) {
				stmt.setObject( i+1, sqlParams[i] );
			}
		
		
			rs = stmt.executeQuery();
		
			// fetch the results
			return fetchMultiResults(rs);
		}
		catch (Exception _e) {
			_e.printStackTrace();
			throw new RelacionProspectoVendedorDaoException( "Exception: " + _e.getMessage(), _e );
		}
		finally {
			ResourceManager.close(rs);
			ResourceManager.close(stmt);
			if (!isConnSupplied) {
				ResourceManager.close(conn);
			}
		
		}
    }
    /**
     * Method 'RelacionProspectoVendedorDaoImpl'
     * 
     */
    public RelacionProspectoVendedorDaoImpl()
    {
    }

    /**
     * Method 'RelacionProspectoVendedorDaoImpl'
     * 
     * @param userConn
     */
    public RelacionProspectoVendedorDaoImpl(final java.sql.Connection userConn)
    {
    	this.userConn = userConn;
    }
    /**
	 * Method 'getTableName'
	 * 
	 * @return String
	 */
	public String getTableName()
	{
		return "relacion_prospecto_vendedor";
	}

	/** 
	 * Fetches a single row from the result set
	 */
	protected RelacionProspectoVendedor fetchSingleResult(ResultSet rs) throws SQLException
	{
		if (rs.next()) {
			RelacionProspectoVendedor dto = new RelacionProspectoVendedor();
			populateDto( dto, rs);
			return dto;
		} else {
			return null;
		}
		
	}

	/** 
	 * Fetches multiple rows from the result set
	 */
	protected RelacionProspectoVendedor[] fetchMultiResults(ResultSet rs) throws SQLException
	{
		Collection resultList = new ArrayList();
		while (rs.next()) {
			RelacionProspectoVendedor dto = new RelacionProspectoVendedor();
			populateDto( dto, rs);
			resultList.add( dto );
		}
		
		RelacionProspectoVendedor ret[] = new RelacionProspectoVendedor[ resultList.size() ];
		resultList.toArray( ret );
		return ret;
	}

	/** 
	 * Populates a DTO with data from a ResultSet
	 */
	protected void populateDto(RelacionProspectoVendedor dto, ResultSet rs) throws SQLException
	{
		dto.setIdProspecto( rs.getInt( COLUMN_ID_PROSPECTO ) );
		dto.setIdUsuario( rs.getInt( COLUMN_ID_USUARIO ) );
		dto.setFechaAsignacion( rs.getDate(COLUMN_FECHA_ASIGNACION ) );
		reset(dto);
	}

	/** 
	 * Resets the modified attributes in the DTO
	 */
	protected void reset(RelacionProspectoVendedor dto)
	{
		dto.setIdProspectoModified( false );
		dto.setIdUsuarioModified( false );
		dto.setFechaAsignacionModified( false );
	}

	

}
