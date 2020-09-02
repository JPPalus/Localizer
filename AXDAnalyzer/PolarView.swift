//
//  PolarView.swift
//  AXDAnalyzer
//
//  Created by Olivier on 19/07/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Cocoa

extension PolarView {
    struct Item {
        let view: NSView
        let relativeSize: CGSize
        let relativeDistance: CGFloat
        let angle: CGFloat
    }
}

private let GraduationFontSize = CGFloat(14)
private let MajorDashPattern: [CGFloat] = [1 / 100, 1 / 50]
private let MinorDashPattern: [CGFloat] = MajorDashPattern
private let MajorRulerColor = NSColor.gray
private let MinorRulerColor = NSColor.lightGray
private let StrokeColor = NSColor.fromHex(0x1f77b4)
private let FillColor =  NSColor.fromHex(0x1f77b4, alpha: 0.5)

class PolarView: NSView {
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var innerView: NSView!
    
    var distanceGraduations: [CGFloat:String] = [0.25: "0.5", 0.5: "1.0", 0.75: "1.5", 1.0: "2.0"]
    var majorAngleGraduations: [Int] = [0, 90, 180, -90]
    var minorAngleGraduations: [Int] = []
    
    var histogramValues: [Int:Double]? = nil {
        didSet { setNeedsDisplay(bounds) }
    }
    
    var curveValues: [Int:Double]? = nil {
        didSet { setNeedsDisplay(bounds) }
    }
    
    var showAngleGraduations = true
    var showAngleRulers = true
    var showDistanceGraduations = true
    var showDistanceRulers = true
    
    var items = [Item]() {
        willSet { removeCurrentItems() }
        didSet { layoutItems() }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    
    private func setup() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        nib.instantiate(withOwner: self, topLevelObjects: nil)
        
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
            contentView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.heightAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
        
        // dont clip subviews
        self.layer?.masksToBounds = false
        contentView.wantsLayer = true
        contentView.layer?.masksToBounds = false
        innerView.wantsLayer = true
        innerView.layer?.masksToBounds = false
    }
    
    private func removeCurrentItems() {
        for item in items {
            item.view.removeFromSuperview()
        }
    }
    
    private func layoutItems() {
        for item in items {
            positionView(item.view,
                         size: item.relativeSize,
                         distance: item.relativeDistance,
                         angle: item.angle)
        }
    }
    
    private func positionView(_ view: NSView, size: CGSize, distance: CGFloat, angle: CGFloat) {
        innerView.addSubview(view)
        
        let x = 1 + distance * cos(degreesToRadians(angle - 90))
        let y = 1 + distance * sin(degreesToRadians(angle - 90))
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: innerView, attribute: .centerX, multiplier: x, constant: 0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: innerView, attribute: .centerY, multiplier: y, constant: 0),
            
            view.widthAnchor.constraint(equalTo: innerView.widthAnchor, multiplier: size.width),
            view.heightAnchor.constraint(equalTo: innerView.heightAnchor, multiplier: size.height)
        ])
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        let drawArea = contentView.convert(innerView.frame, to: self)
        
        drawOuterCircle(drawArea: drawArea)
        
        if showAngleRulers {
            drawAngleRulers(majorAngleGraduations, drawArea: drawArea, isMajor: true)
            drawAngleRulers(minorAngleGraduations, drawArea: drawArea, isMajor: false)
        }
        if showDistanceRulers {
            drawDistanceRulers(drawArea: drawArea)
        }
        if showAngleGraduations {
            drawAngleGraduations(majorAngleGraduations, drawArea: drawArea, isMajor: true)
            drawAngleGraduations(minorAngleGraduations, drawArea: drawArea, isMajor: false)
        }
        if showDistanceGraduations {
            drawDistancesGraduations(drawArea: drawArea)
        }
        
        if let histogramValues = histogramValues {
            drawHistogram(histogramValues, drawArea: drawArea)
        }
        
        if let curveValues = curveValues {
            drawCurve(curveValues, drawArea: drawArea)
        }
        
        super.draw(dirtyRect)
    }
    
    private func drawOuterCircle(drawArea: NSRect) {
        let path = NSBezierPath(ovalIn: drawArea)
        NSColor.white.setFill()
        path.fill()
        NSColor.gray.setStroke()
        path.stroke()
    }
    
    private func drawAngleRulers(_ angleGraduations: [Int], drawArea: NSRect, isMajor: Bool) {
        let path = NSBezierPath()
        path.lineWidth = 1
        path.move(to: CGPoint(x: drawArea.midX, y: drawArea.midY))
        if isMajor {
            let dashPattern = MajorDashPattern.map { $0 * drawArea.width }
            path.setLineDash(dashPattern, count: dashPattern.count, phase: 0.0)
            NSColor.gray.setStroke()
        } else {
            let dashPattern = MinorDashPattern.map { $0 * drawArea.width }
            path.setLineDash(dashPattern, count: dashPattern.count, phase: 0.0)
            NSColor.lightGray.setStroke()
        }
        
        let radius = drawArea.width / 2
        
        for angle in angleGraduations {
            let path = path.copy() as! NSBezierPath
            
            let angleRadians = degreesToRadians(360 - CGFloat(angle - 90))
            let x = drawArea.midX + radius * cos(angleRadians)
            let y = drawArea.midY + radius * sin(angleRadians)
            
            path.line(to: CGPoint(x: x, y: y))
            path.stroke()
        }
    }
    
    private func drawDistanceRulers(drawArea: NSRect) {
        let path = NSBezierPath(ovalIn: drawArea)
        let dashPattern = MajorDashPattern.map { $0 * drawArea.width }
        path.setLineDash(dashPattern, count: dashPattern.count, phase: 0.0)
        path.lineWidth = 1
        
        for distance in distanceGraduations.keys {
            if distance >= 1 {
                continue
            }
            
            let scaleFactor = 1 - distance
            let translateFactorX = distance * drawArea.midX
            let translateFactorY = distance * drawArea.midY
            
            let scale = AffineTransform(scale: scaleFactor)
            let translate = AffineTransform(translationByX: translateFactorX,
                                            byY: translateFactorY)
            
            let path = path.copy() as! NSBezierPath
            
            path.transform(using: scale)
            path.transform(using: translate)
            path.stroke()
        }
    }
    
    private func drawAngleGraduations(_ angleGraduations: [Int], drawArea: NSRect, isMajor: Bool) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: NSFont.systemFont(ofSize: GraduationFontSize),
            .foregroundColor: isMajor ? NSColor.gray : NSColor.lightGray
        ]
        
        let radius = drawArea.width / 2
        
        for angle in angleGraduations {
            let attributedString = NSAttributedString(string: String(format: "% 2d°", angle),
                attributes: attributes)
            
            let stringSize = attributedString.boundingRect(with: drawArea.size)
            
            let angleRadians = degreesToRadians(360 - CGFloat(angle - 90))
            let x = drawArea.midX + radius * cos(angleRadians)
            let y = drawArea.midY + radius * sin(angleRadians)
            
            // recenter
            let deltaX = stringSize.width * (-0.5 + 0.6 * cos(angleRadians))
            let deltaY = stringSize.height * (-0.5 + 0.6 * sin(angleRadians))
            
            let stringRect = CGRect(x: x + deltaX,
                                    y: y + deltaY,
                                    width: stringSize.width,
                                    height: stringSize.height)
            
            attributedString.draw(in: stringRect)
        }
    }
    
    private func drawDistancesGraduations(drawArea: NSRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: NSFont.systemFont(ofSize: GraduationFontSize),
            .foregroundColor: NSColor.gray
        ]
        
        for (distance, label) in distanceGraduations {
            let attributedString = NSAttributedString(string: label,
                                                      attributes: attributes)
            
            let stringSize = attributedString.boundingRect(with: drawArea.size)
            
            let radius = distance * drawArea.width / 2
            
            let angleRadians = degreesToRadians(45)
            let x = drawArea.midX + radius * cos(angleRadians)
            let y = drawArea.midY + radius * sin(angleRadians)
            
            
            let stringRect = CGRect(x: x,
                                    y: y,
                                    width: stringSize.width,
                                    height: stringSize.height)
            
            attributedString.draw(in: stringRect)
        }
    }
    
//    private func drawHistogram(_ histogramValues: [Int:Double], drawArea: NSRect) {
//        let center = NSPoint(x: drawArea.midX, y: drawArea.midY)
//
//        let outerRadius = drawArea.width / 2
//        let maxRadius = 0.95 * outerRadius
//        let minRadius = 0.1 * outerRadius
//
//        let angles = histogramValues.keys.sorted()
//        let angleStep = angles[1] - angles[0]
//        for angle in angles {
//            var angleStart = CGFloat(angle) - CGFloat(angleStep) / 2
//            var angleEnd = CGFloat(angle) + CGFloat(angleStep) / 2
//            angleStart = 360 - angleStart + 90
//            angleEnd = 360 - angleEnd + 90
//
//            let value = histogramValues[angle]!
//            let innerRadius = maxRadius - (maxRadius - minRadius) * CGFloat(value)
//
//            let angleStartRadians = degreesToRadians(angleStart)
//            let angleEndRadians = degreesToRadians(angleEnd)
//
//            let xOuterStart = drawArea.midX + outerRadius * cos(angleStartRadians)
//            let yOuterStart = drawArea.midY + outerRadius * sin(angleStartRadians)
//            let outerStart = NSPoint(x: xOuterStart, y: yOuterStart)
//
//            let xInnerEnd = drawArea.midX + innerRadius * cos(angleEndRadians)
//            let yInnerEnd = drawArea.midY + innerRadius * sin(angleEndRadians)
//            let innerEnd = NSPoint(x: xInnerEnd, y: yInnerEnd)
//
//            let path = NSBezierPath()
//
//            path.move(to: outerStart)
//            path.appendArc(withCenter: center, radius: outerRadius,
//                           startAngle: angleStart, endAngle: angleEnd, clockwise: true)
//            path.line(to: innerEnd)
//            path.appendArc(withCenter: center, radius: innerRadius,
//                           startAngle: angleEnd, endAngle: angleStart, clockwise: false)
//            path.close()
//
//            NSColor.lightGray.setFill()
//            path.fill()
//            NSColor.gray.setStroke()
//            path.lineWidth = 2
//            path.stroke()
//        }
//    }
    
    private func drawHistogram(_ histogramValues: [Int:Double], drawArea: NSRect) {
        let center = NSPoint(x: drawArea.midX, y: drawArea.midY)

        let radius = drawArea.width / 2

        let angles = histogramValues.keys.sorted()
        let angleStep = angles[1] - angles[0]
        for angle in angles {
            var angleStart = CGFloat(angle) - CGFloat(angleStep) / 2
            var angleEnd = CGFloat(angle) + CGFloat(angleStep) / 2
            angleStart = 360 - angleStart + 90
            angleEnd = 360 - angleEnd + 90

            let value = histogramValues[angle]!
            let radius = radius * CGFloat(value)

            let path = NSBezierPath()

            path.move(to: center)
            path.appendArc(withCenter: center, radius: radius,
                           startAngle: angleStart, endAngle: angleEnd, clockwise: true)
            path.line(to: center)
            path.close()

            FillColor.setFill()
            path.fill()
            StrokeColor.setStroke()
            path.lineWidth = 2
            path.stroke()
        }
    }
    
    private func drawCurve(_ curveValues: [Int:Double], drawArea: NSRect) {
        let radius = drawArea.width / 2
        
        var points = [CGPoint]()
        
        let angles = curveValues.keys.sorted()
        for angle in angles {
            let value = curveValues[angle]!
            
            let angle = 360 - angle + 90
            let angleRadians = degreesToRadians(CGFloat(angle))
            let radius = radius * CGFloat(value)
            
            let x = drawArea.midX + radius * cos(angleRadians)
            let y = drawArea.midY + radius * sin(angleRadians)
            let point = NSPoint(x: x, y: y)
            
            points.append(point)
        }
        
        let linePath = interpolateCatmullRomCurve(points, alpha: 0.5)
        
        FillColor.setFill()
        linePath.fill()
        StrokeColor.setStroke()
        linePath.lineWidth = 2
        linePath.stroke()
    }
}

fileprivate func degreesToRadians(_ number: CGFloat) -> CGFloat {
    return number * .pi / 180
}

fileprivate extension NSColor {
    class func fromHex(_ hex: Int, alpha: CGFloat = 1.0) -> NSColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        return NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
}
