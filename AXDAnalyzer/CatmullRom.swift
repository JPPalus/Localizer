//
//  CatmullRom.swift
//  AXDAnalyzer
//
//  Created by Olivier on 24/07/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Cocoa

private let Epsilon = CGFloat(1.0e-5)

func interpolateCatmullRomCurve(_ points: [CGPoint], alpha: CGFloat = 0.5, shouldCloseFlat: Bool = false) -> NSBezierPath {
    assert(points.count > 4)
    assert(alpha >= 0 && alpha <= 1)
    
    let path = NSBezierPath()
    path.move(to: points.first!)
    
    for i in 0..<points.count {
        var iPrev = i == 0 ? points.count - 1 : i - 1
        var iNext = (i + 1) % points.count
        var iNextNext = (iNext + 1) % points.count
        
        if shouldCloseFlat {
            iPrev = i == 0 ? 0 : i - 1
            iNext = (i == points.count - 1) ? i : i + 1
            iNextNext = (iNext == points.count - 1) ? iNext : iNext + 1
        }
        
        let p0 = points[iPrev]
        let p1 = points[i]
        let p2 = points[iNext]
        let p3 = points[iNextNext]
        
        let d1 = (p1 - p0).length
        let d2 = (p2 - p1).length
        let d3 = (p3 - p2).length
        
        let cp1: CGPoint = {
            if abs(d1) < Epsilon {
                return p1
            }
            
            var cp = p2 * pow(d1, 2 * alpha)
            cp = cp - (p0 * pow(d2, 2 * alpha))
            cp = cp + p1 * (2 * pow(d1, 2 * alpha) + 3 * pow(d1, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha))
            cp = cp * (1.0 / (3 * pow(d1, alpha) * (pow(d1, alpha) + pow(d2, alpha))))
            
            return cp
        }()
        
        let cp2: CGPoint = {
            if abs(d3) < Epsilon {
                return p2
            }
            
            var cp = p1 * pow(d3, 2 * alpha)
            cp = cp - p3 * pow(d2, 2 * alpha)
            cp = cp + p2 * (2 * pow(d3, 2 * alpha) + 3 * pow(d3, alpha) * pow(d2, alpha) + pow(d2, 2 * alpha))
            cp = cp * (1.0 / (3 * pow(d3, alpha) * (pow(d3, alpha) + pow(d2, alpha))))
            
            return cp
        }()
        
        path.curve(to: p2, controlPoint1: cp1, controlPoint2: cp2)
    }
    
    path.close()
    return path
}


private extension CGPoint {
    var length: CGFloat { return sqrt(x * x + y * y) }
    
    static func *(left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
    
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
}
