/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.dto;

/**
 *
 * @author DXN
 */
/** 
 * This class represents the primary key of the relacion_prospecto_vendedor table.
 */
public class RelacionProspectoVendedorPk {
    protected int idProspecto;

	/** 
	 * This attribute represents whether the primitive attribute idProspecto is null.
	 */
	protected boolean idProspectoNull;

	/** 
	 * Sets the value of idProspecto
	 */
	public void setIdProspecto(int idProspecto)
	{
		this.idProspecto = idProspecto;
	}

	/** 
	 * Gets the value of idProspecto
	 */
	public int getIdProspecto()
	{
		return idProspecto;
	}

	/**
	 * Method 'RelacionProspectoVendedorPk'
	 * 
	 */
	public RelacionProspectoVendedorPk()
	{
	}

	/**
	 * Method 'RelacionProspectoVendedorPk'
	 * 
	 * @param idProspecto
	 */
	public RelacionProspectoVendedorPk(final int idProspecto)
	{
		this.idProspecto = idProspecto;
	}

	/** 
	 * Sets the value of idProspectoNull
	 */
	public void setIdProspectoNull(boolean idProspectoNull)
	{
		this.idProspectoNull = idProspectoNull;
	}

	/** 
	 * Gets the value of idProspectoNull
	 */
	public boolean isIdProspectoNull()
	{
		return idProspectoNull;
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
		
		if (!(_other instanceof RelacionProspectoVendedorPk)) {
			return false;
		}
		
		final RelacionProspectoVendedorPk _cast = (RelacionProspectoVendedorPk) _other;
		if (idProspecto != _cast.idProspecto) {
			return false;
		}
		
		if (idProspectoNull != _cast.idProspectoNull) {
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
		_hashCode = 29 * _hashCode + (idProspectoNull ? 1 : 0);
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
		ret.append( "com.tsp.gespro.dto.RelacionProspectoVendedorPk: " );
		ret.append( "idProspecto=" + idProspecto );
		return ret.toString();
	}

    
}
