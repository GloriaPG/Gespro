package com.tsp.gespro.hibernate.pojo;
// Generated 20/08/2016 10:29:04 AM by Hibernate Tools 3.6.0



/**
 * Coberturaproyecto generated by hbm2java
 */
public class Coberturaproyecto  implements java.io.Serializable {


     private Integer id;
     private int idCobertura;
     private int idProyecto;

    public Coberturaproyecto() {
    }

    public Coberturaproyecto(int idCobertura, int idProyecto) {
       this.idCobertura = idCobertura;
       this.idProyecto = idProyecto;
    }
   
    public Integer getId() {
        return this.id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    public int getIdCobertura() {
        return this.idCobertura;
    }
    
    public void setIdCobertura(int idCobertura) {
        this.idCobertura = idCobertura;
    }
    public int getIdProyecto() {
        return this.idProyecto;
    }
    
    public void setIdProyecto(int idProyecto) {
        this.idProyecto = idProyecto;
    }




}


