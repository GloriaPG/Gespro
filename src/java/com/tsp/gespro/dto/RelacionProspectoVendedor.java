/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.dto;

import java.io.Serializable;
import java.util.Date;

/**
 *
 * @author DXN
 */
public class RelacionProspectoVendedor implements Serializable
{
	/** 
	 * This attribute maps to the column ID_PROSPECTO in the relacion_prospecto_vendedor table.
	 */
	protected int idProspecto;

	/** 
	 * This attribute represents whether the attribute idProspecto has been modified since being read from the database.
	 */
	protected boolean idProspectoModified = false;

	/** 
	 * This attribute maps to the column ID_USUARIO in the relacion_prospecto_vendedor table.
	 */
	protected int idUsuario;

	/** 
	 * This attribute represents whether the attribute idUsuario has been modified since being read from the database.
	 */
	protected boolean idUsuarioModified = false;

	/** 
	 * This attribute maps to the column FECHA_ASIGNACION in the relacion_prospecto_vendedor table.
	 */
	protected Date fechaAsignacion;

	/** 
	 * This attribute represents whether the attribute fechaAsignacion has been modified since being read from the database.
	 */
	protected boolean fechaAsignacionModified = false;

	/**
	 * Method 'RelacionProspectoVendedor'
	 * 
	 */
	public RelacionProspectoVendedor()
	{
	}

	/**
	 * Method 'getIdProspecto'
	 * 
	 * @return int
	 */
	public int getIdProspecto()
	{
		return idProspecto;
	}

	/**
	 * Method 'setIdProspecto'
	 * 
	 * @param idProspecto
	 */
	public void setIdProspecto(int idProspecto)
	{
		this.idProspecto = idProspecto;
		this.idProspectoModified = true;
	}

	/** 
	 * Sets the value of idProspectoModified
	 */
	public void setIdProspectoModified(boolean idProspectoModified)
	{
		this.idProspectoModified = idProspectoModified;
	}

	/** 
	 * Gets the value of idProspectoModified
	 */
	public boolean isIdProspectoModified()
	{
		return idProspectoModified;
	}

	/**
	 * Method 'getIdUsuario'
	 * 
	 * @return int
	 */
	public int getIdUsuario()
	{
		return idUsuario;
	}

	/**
	 * Method 'setIdUsuario'
	 * 
	 * @param idUsuario
	 */
	public void setIdUsuario(int idUsuario)
	{
		this.idUsuario = idUsuario;
		this.idUsuarioModified = true;
	}

	/** 
	 * Sets the value of idUsuarioModified
	 */
	public void setIdUsuarioModified(boolean idUsuarioModified)
	{
		this.idUsuarioModified = idUsuarioModified;
	}

	/** 
	 * Gets the value of idUsuarioModified
	 */
	public boolean isIdUsuarioModified()
	{
		return idUsuarioModified;
	}

	/**
	 * Method 'getFechaAsignacion'
	 * 
	 * @return Date
	 */
	public Date getFechaAsignacion()
	{
		return fechaAsignacion;
	}

	/**
	 * Method 'setFechaAsignacion'
	 * 
	 * @param fechaAsignacion
	 */
	public void setFechaAsignacion(Date fechaAsignacion)
	{
		this.fechaAsignacion = fechaAsignacion;
		this.fechaAsignacionModified = true;
	}

	/** 
	 * Sets the value of fechaAsignacionModified
	 */
	public void setFechaAsignacionModified(boolean fechaAsignacionModified)
	{
		this.fechaAsignacionModified = fechaAsignacionModified;
	}

	/** 
	 * Gets the value of fechaAsignacionModified
	 */
	public boolean isFechaAsignacionModified()
	{
		return fechaAsignacionModified;
	}

	/**
	 * Method 'equals'
	 * 
	 * @param _other
	 * @return boolean
	 */
	public boolean equals(Object _other)
	{
		if (_other == null) {
			return false;
		}
		
		if (_other == this) {
			return true;
		}
		
		if (!(_other instanceof RelacionProspectoVendedor)) {
			return false;
		}
		
		final RelacionProspectoVendedor _cast = (RelacionProspectoVendedor) _other;
		if (idProspecto != _cast.idProspecto) {
			return false;
		}
		
		if (idProspectoModified != _cast.idProspectoModified) {
			return false;
		}
		
		if (idUsuario != _cast.idUsuario) {
			return false;
		}
		
		if (idUsuarioModified != _cast.idUsuarioModified) {
			return false;
		}
		
		if (fechaAsignacion == null ? _cast.fechaAsignacion != fechaAsignacion : !fechaAsignacion.equals( _cast.fechaAsignacion )) {
			return false;
		}
		
		if (fechaAsignacionModified != _cast.fechaAsignacionModified) {
			return false;
		}
		
		return true;
	}

	/**
	 * Method 'hashCode'
	 * 
	 * @return int
	 */
	public int hashCode()
	{
		int _hashCode = 0;
		_hashCode = 29 * _hashCode + idProspecto;
		_hashCode = 29 * _hashCode + (idProspectoModified ? 1 : 0);
		_hashCode = 29 * _hashCode + idUsuario;
		_hashCode = 29 * _hashCode + (idUsuarioModified ? 1 : 0);
		if (fechaAsignacion != null) {
			_hashCode = 29 * _hashCode + fechaAsignacion.hashCode();
		}
		
		_hashCode = 29 * _hashCode + (fechaAsignacionModified ? 1 : 0);
		return _hashCode;
	}

	/**
	 * Method 'toString'
	 * 
	 * @return String
	 */
	public String toString()
	{
		StringBuffer ret = new StringBuffer();
		ret.append( "com.tsp.gespro.dto.RelacionProspectoVendedor: " );
		ret.append( "idProspecto=" + idProspecto );
		ret.append( ", idUsuario=" + idUsuario );
		ret.append( ", fechaAsignacion=" + fechaAsignacion );
		return ret.toString();
	}
    
}
