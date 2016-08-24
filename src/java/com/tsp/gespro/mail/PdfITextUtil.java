/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.tsp.gespro.mail;


import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import java.awt.Color;

/**
 *
 * @author ISC César Ulises Martínez García
 */
public class PdfITextUtil {

    public void agregaCelda(PdfPTable table,Font font, String text, boolean border[], int hAlignment, int vAlignment, float minHeight, int[] padding, int colspan){
        PdfPCell cell = new PdfPCell(new Phrase(text,font));
        if(border.length>0){
            int bLeft = 0;
            int bRight = 0;
            int bTop = 0;
            int bBottom = 0;

            boolean anyBorder = false;
            if(border[0]){
                bLeft = (PdfPCell.LEFT);
                anyBorder = true;
            }
            if(border.length>1 && border[1]){
                bRight = (PdfPCell.RIGHT);
                anyBorder = true;
            }
            if(border.length>2 && border[2]){
                bTop = (PdfPCell.TOP);
                anyBorder = true;
            }
            if(border.length>3 && border[3]){
                bBottom = (PdfPCell.BOTTOM);
                anyBorder = true;
            }
            if(!anyBorder)
                cell.setBorder(PdfPCell.NO_BORDER);
            else
                cell.setBorder(bLeft | bRight | bTop | bBottom);
        }else
            cell.setBorder(PdfPCell.NO_BORDER);
        cell.setHorizontalAlignment(hAlignment);
        cell.setVerticalAlignment(vAlignment);
        if(minHeight>0)
            cell.setMinimumHeight(minHeight);
        if(colspan>0)
            cell.setColspan(colspan);
        if(padding.length>0){
            cell.setPaddingLeft(padding[0]);
            if(padding.length>1){
                cell.setPaddingRight(padding[1]);
                if(padding.length>2){
                    cell.setPaddingTop(padding[2]);
                    if(padding.length>3)
                        cell.setPaddingBottom(padding[3]);
                }
            }
        }
        table.addCell(cell);
    }
    
    public void agregaCelda(PdfPTable table,Font font, Color backgroundColor, String text, boolean border[], int hAlignment, int vAlignment, float minHeight, int[] padding, int colspan){
        PdfPCell cell = new PdfPCell(new Phrase(text,font));
        if(border.length>0){
            int bLeft = 0;
            int bRight = 0;
            int bTop = 0;
            int bBottom = 0;

            boolean anyBorder = false;
            if(border[0]){
                bLeft = (PdfPCell.LEFT);
                anyBorder = true;
            }
            if(border.length>1 && border[1]){
                bRight = (PdfPCell.RIGHT);
                anyBorder = true;
            }
            if(border.length>2 && border[2]){
                bTop = (PdfPCell.TOP);
                anyBorder = true;
            }
            if(border.length>3 && border[3]){
                bBottom = (PdfPCell.BOTTOM);
                anyBorder = true;
            }
            if(!anyBorder)
                cell.setBorder(PdfPCell.NO_BORDER);
            else
                cell.setBorder(bLeft | bRight | bTop | bBottom);
        }else
            cell.setBorder(PdfPCell.NO_BORDER);
        cell.setHorizontalAlignment(hAlignment);
        cell.setVerticalAlignment(vAlignment);
        if(minHeight>0)
            cell.setMinimumHeight(minHeight);
        if(colspan>0)
            cell.setColspan(colspan);
        if(padding.length>0){
            cell.setPaddingLeft(padding[0]);
            if(padding.length>1){
                cell.setPaddingRight(padding[1]);
                if(padding.length>2){
                    cell.setPaddingTop(padding[2]);
                    if(padding.length>3)
                        cell.setPaddingBottom(padding[3]);
                }
            }
        }
        if (backgroundColor!=null)
            cell.setBackgroundColor(backgroundColor);
        table.addCell(cell);
    }

    public void agregaTabla(PdfPTable mainTable, PdfPTable tableToSet, boolean border[], int hAlignment, int vAlignment, float minHeight, int[] padding,int colspan){
        PdfPCell cell = new PdfPCell(tableToSet);
        if(border.length>0){
            int bLeft = 0;
            int bRight = 0;
            int bTop = 0;
            int bBottom = 0;

            boolean anyBorder = false;
            if(border[0]){
                bLeft = (PdfPCell.LEFT);
                anyBorder = true;
            }
            if(border.length>1 && border[1]){
                bRight = (PdfPCell.RIGHT);
                anyBorder = true;
            }
            if(border.length>2 && border[2]){
                bTop = (PdfPCell.TOP);
                anyBorder = true;
            }
            if(border.length>3 && border[3]){
                bBottom = (PdfPCell.BOTTOM);
                anyBorder = true;
            }
            if(!anyBorder)
                cell.setBorder(PdfPCell.NO_BORDER);
            else
                cell.setBorder(bLeft | bRight | bTop | bBottom);
        }else
            cell.setBorder(PdfPCell.NO_BORDER);
        cell.setHorizontalAlignment(hAlignment);
        cell.setVerticalAlignment(vAlignment);
        if(minHeight>0)
            cell.setMinimumHeight(minHeight);
        if(colspan>0)
            cell.setColspan(colspan);
        if(padding.length>0){
            cell.setPaddingLeft(padding[0]);
            if(padding.length>1){
                cell.setPaddingRight(padding[1]);
                if(padding.length>2){
                    cell.setPaddingTop(padding[2]);
                    if(padding.length>3)
                        cell.setPaddingBottom(padding[3]);
                }
            }
        }
        mainTable.addCell(cell);
    }

    public void agregaCeldaImagen(PdfPTable table, Image image, boolean border[], int hAlignment, int vAlignment, float minHeight, int[] padding, int colspan){
        PdfPCell cell = new PdfPCell(new Phrase(" "));
        if(image!=null)
            cell = new PdfPCell(image);
        if(border.length>0){
            int bLeft = 0;
            int bRight = 0;
            int bTop = 0;
            int bBottom = 0;

            boolean anyBorder = false;
            if(border[0]){
                bLeft = (PdfPCell.LEFT);
                anyBorder = true;
            }
            if(border.length>1 && border[1]){
                bRight = (PdfPCell.RIGHT);
                anyBorder = true;
            }
            if(border.length>2 && border[2]){
                bTop = (PdfPCell.TOP);
                anyBorder = true;
            }
            if(border.length>3 && border[3]){
                bBottom = (PdfPCell.BOTTOM);
                anyBorder = true;
            }
            if(!anyBorder)
                cell.setBorder(PdfPCell.NO_BORDER);
            else
                cell.setBorder(bLeft | bRight | bTop | bBottom);
        }else
            cell.setBorder(PdfPCell.NO_BORDER);
        cell.setHorizontalAlignment(hAlignment);
        cell.setVerticalAlignment(vAlignment);
        if(minHeight>0)
            cell.setMinimumHeight(minHeight);
        if(colspan>0)
            cell.setColspan(colspan);
        if(padding.length>0){
            cell.setPaddingLeft(padding[0]);
            if(padding.length>1){
                cell.setPaddingRight(padding[1]);
                if(padding.length>2){
                    cell.setPaddingTop(padding[2]);
                    if(padding.length>3)
                        cell.setPaddingBottom(padding[3]);
                }
            }
        }
        table.addCell(cell);
    }

}
