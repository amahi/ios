//
//  PDFThumbnailGenerator.swift
//  AmahiAnywhere
//
//  Created by Kanyinsola Fapohunda on 30/03/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

import Foundation

class PDFThumbnailGenerator : ThumbnailGenerator {
    
    func getThumbnail(_ url:URL, pageNumber:Int, width:CGFloat) -> UIImage {
        if let pdf:CGPDFDocument = CGPDFDocument(url as CFURL) {
            
            if let firstPage = pdf.page(at: pageNumber) {
                
                var pageRect:CGRect = firstPage.getBoxRect(CGPDFBox.mediaBox)
                let pdfScale:CGFloat = width/pageRect.size.width
                pageRect.size = CGSize(width: pageRect.size.width*pdfScale, height: pageRect.size.height*pdfScale)
                pageRect.origin = CGPoint.zero
                
                UIGraphicsBeginImageContext(pageRect.size)
                
                if let context:CGContext = UIGraphicsGetCurrentContext() {
                    
                    context.setFillColor(red: 1.0,green: 1.0,blue: 1.0,alpha: 1.0)
                    context.fill(pageRect)
                    
                    context.saveGState()
                    
                    context.translateBy(x: 0.0, y: pageRect.size.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.concatenate((firstPage.getDrawingTransform(CGPDFBox.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true)))
                    
                    context.drawPDFPage(firstPage)
                    context.restoreGState()
                    
                    if let thm = UIGraphicsGetImageFromCurrentImageContext() {
                        UIGraphicsEndImageContext();
                        
                        saveImage(url: url, toCache: thm) {
                            AmahiLogger.log("Document Thumbnail for \(url) was stored")
                        }
                        
                        return thm;
                    }
                }
            }
        }
        
        return UIImage(named: "file")!
    }
    
    func getThumbnail(_ url:URL, pageNumber:Int) -> UIImage {
        return self.getThumbnail(url, pageNumber: pageNumber, width: 240.0)
    }
    
    func getThumbnail(_ url:URL) -> UIImage {
        return self.getThumbnail(url, pageNumber: 1, width: 240.0)
    }
}
