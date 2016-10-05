/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.dao;

import com.tsp.gespro.dto.RelacionProspectoVendedor;
import com.tsp.gespro.exceptions.RelacionProspectoVendedorDaoException;
import java.util.Date;

/**
 *
 * @author DXN
 */
public interface RelacionProspectoVendedorDao {
    /** 
	 * Inserts a new row in the relacion_prospecto_vendedor table.
	 */
	public void insert(RelacionProspectoVendedor dto) throws RelacionProspectoVendedorDaoException;

	/** 
	 * Returns all rows from the relacion_prospecto_vendedor table that match the criteria ''.
	 */
	public RelacionProspectoVendedor[] findAll() throws RelacionProspectoVendedorDaoException;

	/** 
	 * Returns all rows from the relacion_prospecto_vendedor table that match the criteria 'ID_PROSPECTO = :idProspecto'.
	 */
	public RelacionProspectoVendedor[] findWhereIdProspectoEquals(int idProspecto) throws RelacionProspectoVendedorDaoException;

	/** 
	 * Returns all rows from the relacion_prospecto_vendedor table that match the criteria 'ID_USUARIO = :idUsuario'.
	 */
	public RelacionProspectoVendedor[] findWhereIdUsuarioEquals(int idUsuario) throws RelacionProspectoVendedorDaoException;

	/** 
	 * Returns all rows from the relacion_prospecto_vendedor table that match the criteria 'FECHA_ASIGNACION = :fechaAsignacion'.
	 */
	public RelacionProspectoVendedor[] findWhereFechaAsignacionEquals(Date fechaAsignacion) throws RelacionProspectoVendedorDaoException;

	/** 
	 * Sets the value of maxRows
	 */
	public void setMaxRows(int maxRows);

	/** 
	 * Gets the value of maxRows
	 */
	public int getMaxRows();

	/** 
	 * Returns all rows from the relacion_prospecto_vendedor table that match the specified arbitrary SQL statement
	 */
	public RelacionProspectoVendedor[] findByDynamicSelect(String sql, Object[] sqlParams) throws RelacionProspectoVendedorDaoException;

	/** 
	 * Returns all rows from the relacion_prospecto_vendedor table that match the specified arbitrary SQL statement
	 */
	public RelacionProspectoVendedor[] findByDynamicWhere(String sql, Object[] sqlParams) throws RelacionProspectoVendedorDaoException;

}
