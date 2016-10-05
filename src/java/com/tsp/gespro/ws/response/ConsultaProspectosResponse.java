/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.ws.response;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author DXN
 */
public class ConsultaProspectosResponse extends WSResponse implements Serializable{
    private List<WsItemProspecto> wsItemProspecto;
    public List<WsItemProspecto> getWsItemProspecto() {
        if (wsItemProspecto==null)
            wsItemProspecto = new ArrayList<>();
        return wsItemProspecto;
    }

    public void setWsItemProspecto(List<WsItemProspecto> wsItemProspecto) {
        this.wsItemProspecto = wsItemProspecto;
    }    
    
    
}
