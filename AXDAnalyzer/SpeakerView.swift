//
//  SpeakerView.swift
//  AXDAnalyzer
//
//  Created by Olivier on 17/06/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Cocoa

private let SpeakerImage = NSImage(imageLiteralResourceName: "speaker")

class SpeakerView: NSView {
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var button: NSButton!
    @IBOutlet weak var levelLabel: NSTextField!
    @IBOutlet weak var distanceLabel: NSTextField!
        
    var azimuth: Int = 0 {
        didSet { update() }
    }
    var level: Double = 0 {
        didSet { update() }
    }
    var distance: Double = 0 {
        didSet { update() }
    }
    var isEnabled = true {
        didSet { update() }
    }
    var isSelected = false {
        didSet { update() }
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
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        nib.instantiate(withOwner: self, topLevelObjects: nil)
        
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: contentView.topAnchor),
            bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        self.wantsLayer = true
        let shadow = NSShadow()
        shadow.shadowOffset = NSMakeSize(2, -2)
        shadow.shadowColor = NSColor.lightGray
        shadow.shadowBlurRadius = 3
        self.shadow = shadow
        
        // dont clip text labels
        self.layer?.masksToBounds = false
        contentView.wantsLayer = true
        contentView.layer?.masksToBounds = false
        levelLabel.wantsLayer = true
        levelLabel.layer?.masksToBounds = false
        distanceLabel.wantsLayer = true
        distanceLabel.layer?.masksToBounds = false
        
        update()
    }
    
    private func update() {
        levelLabel.stringValue = "\(Int(level.rounded())) dB"
        distanceLabel.stringValue = "\(distance) m"
        button.isEnabled = isEnabled
        
        levelLabel.isHidden = !isSelected
        distanceLabel.isHidden = !isSelected
        
//        let alpha = levelToAlpha(level)
//        button.(alphaValue = alpha
        
//        let rotation = CGFloat(270 - azimuth)
//        button.image = Sp(eakerImage.rotated(by: rotation)
    }
}

//fileprivate extension NSImage {
//    func rotated(by angle: CGFloat) -> NSImage {
//        let img = NSImage(size: self.size, flipped: false, drawingHandler: { (rect) -> Bool in
//            let (width, height) = (rect.size.width, rect.size.height)
//            let transform = NSAffineTransform()
//            transform.translateX(by: width / 2, yBy: height / 2)
//            transform.rotate(byDegrees: angle)
//            transform.translateX(by: -width / 2, yBy: -height / 2)
//            transform.concat()
//            self.draw(in: rect)
//            return true
//        })
//        img.isTemplate = self.isTemplate
//        return img
//    }
//}

//fileprivate func levelToAlpha(_ level: Double) -> CGFloat {
//    let alpha = CGFloat(1 - level)
//    return max(0.5, min(1.0, alpha))
//}
