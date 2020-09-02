//
//  WaveOptionsView.swift
//  AXDAnalyzer
//
//  Created by Olivier on 30/07/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Cocoa

private let SampleRates = [44100, 48000]

class WaveOptionsView: NSView {
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var sampleRatePopup: NSPopUpButton!
    
    var sampleRate: Int { return SampleRates[sampleRatePopup.indexOfSelectedItem] }
    
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
    }
}

