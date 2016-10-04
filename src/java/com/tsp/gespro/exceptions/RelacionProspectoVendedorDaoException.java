/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.exceptions;

/**
 *
 * @author DXN
 */
public class RelacionProspectoVendedorDaoException extends DaoException{
    /**
	 * Method 'RelacionProspectoVendedorDaoException'
	 * 
	 * @param message
	 */
	public RelacionProspectoVendedorDaoException(String message)
	{
		super(message);
	}

	/**
	 * Method 'RelacionProspectoVendedorDaoException'
	 * 
	 * @param message
	 * @param cause
	 */
	public RelacionProspectoVendedorDaoException(String message, Throwable cause)
	{
		super(message, cause);
	}

}
