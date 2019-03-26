//
//  DrawingView.swift
//  FaceDetection-MLKit
//
//  Created by Doyoung Gwak on 26/03/2019.
//  Copyright © 2019 Doyoung Gwak. All rights reserved.
//

import UIKit
import Firebase

class DrawingView: UIView {

    var imageSize: CGSize = .zero
    var faces: [VisionFace] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var emijiLabel: UILabel?
    func setUp() {
        emijiLabel = UILabel()
        emijiLabel?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        emijiLabel?.text = ""
        emijiLabel?.font = UIFont.systemFont(ofSize: 60)
        emijiLabel?.textAlignment = .center
        emijiLabel?.numberOfLines = 1;
        if let emijiLabel = emijiLabel {
            addSubview(emijiLabel)
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            let frameSize = self.bounds.size
            let frameRateSize = frameSize / imageSize
            
            emijiLabel?.center = CGPoint(x: -200, y: -200)
            
            for face in faces {
                let faceFrame = (face.frame * frameRateSize).flipX(fullSize: frameSize)
                
                if face.smilingProbability > 0.6 {
                    emijiLabel?.text = "😆"
                } else {
                    emijiLabel?.text = ""
                }
                print(face.smilingProbability)
                emijiLabel?.center = CGPoint(x: faceFrame.origin.x + faceFrame.width/2, y: faceFrame.origin.y - ((emijiLabel?.frame.height ?? 0)/2))
//                drawRectangle(ctx: ctx, frame: faceFrame, color: UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor)
            }
        }
    }
    
    private func drawRectangle(ctx: CGContext, frame: CGRect, color: CGColor, fill: Bool = false)  {
        let topLeft = frame.origin
        let topRight = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y)
        let bottomRight = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height)
        let bottomLeft = CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)
        
        drawPolygon(ctx: ctx,
                    points: [topLeft, topRight, bottomRight, bottomLeft],
                    color: color,
                    fill: fill)
    }

    private func drawPolygon(ctx: CGContext, points: [CGPoint], color: CGColor, fill: Bool = false) {
        if fill {
            ctx.setStrokeColor(UIColor.clear.cgColor)
            ctx.setFillColor(color)
            ctx.setLineWidth(0.0)
        } else {
            ctx.setStrokeColor(color)
            ctx.setLineWidth(1.0)
        }
        
        
        for i in 0..<points.count {
            if i == 0 {
                ctx.move(to: points[i])
            } else {
                ctx.addLine(to: points[i])
            }
        }
        if let firstPoint = points.first {
            ctx.addLine(to: firstPoint)
        }
        
        if fill {
            ctx.fillPath()
        } else {
            ctx.strokePath();
        }
    }
}

func * (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}
func / (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width / right.width, height: left.height / right.height)
}

func * (left: CGRect, right: CGSize) -> CGRect {
    return CGRect(x: left.origin.x*right.width,
                  y: left.origin.y*right.height,
                  width: left.width*right.width,
                  height: left.height*right.height)
}

extension CGRect {
    func flipX(fullSize: CGSize) -> CGRect {
        return CGRect(x: fullSize.width - origin.x - size.width, y: origin.y, width: size.width, height: size.height)
    }
}
