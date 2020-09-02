//
//  PolarOverviewVC.swift
//  AXDAnalyzer
//
//  Created by Olivier on 19/07/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Cocoa

protocol PolarOverviewVCDelegate: class {
    func polarOverviewVC(_ polarOverviewVC: PolarOverviewVC, didSelectAnalysis analysis: BRIRAnalysis)
}

private let DistanceRange = 0.25...2
private let SpeakerRelativeSize = CGSize(width: 0.075, height: 0.075)

class PolarOverviewVC: NSViewController {
    @IBOutlet weak var polarView: PolarView!
    
    weak var delegate: PolarOverviewVCDelegate? = nil
    
    var analyses = [BRIRAnalysis]() {
        didSet { updateView() }
    }
    
    var indexOfAnalysisToHighlight: Int? = nil {
        didSet { updateView() }
    }

    private var speakerViews = [SpeakerView]()
    
    
    private func updateView() {
        for speakerView in speakerViews {
            speakerView.removeFromSuperview()
            speakerView.button.target = nil
            speakerView.button.action = nil
        }
        
        speakerViews = []
        
        var polarItems = [PolarView.Item]()
        
        for (index, analysis) in analyses.enumerated() {
            let speakerView = SpeakerView()
            speakerView.distance = analysis.distance ?? 1
            speakerView.azimuth = analysis.azimuth
            speakerView.level = analysis.level
            
            speakerView.button.target = self
            speakerView.button.action = #selector(didClickSpeakerButton)
            
            if let indexOfAnalysisToHighlight = indexOfAnalysisToHighlight {
                if index == indexOfAnalysisToHighlight {
                    speakerView.isEnabled = true
                    speakerView.isSelected = true
                } else {
                    speakerView.isEnabled = false
                    speakerView.isSelected = false
                }
            }
            
            speakerViews.append(speakerView)
            
            let polarDistance = speakerDistanceToPolarDistance(analysis.distance ?? 1)
            let item = PolarView.Item(view: speakerView,
                                      relativeSize: SpeakerRelativeSize,
                                      relativeDistance: polarDistance,
                                      angle: CGFloat(speakerView.azimuth))
            
            polarItems.append(item)
        }
        
        if let indexOfAnalysisToHighlight = indexOfAnalysisToHighlight {
            let polarItem = polarItems[indexOfAnalysisToHighlight]
            polarItems.remove(at: indexOfAnalysisToHighlight)
            polarItems.append(polarItem)
        }   
        
        polarView.items = polarItems
        
    }
    

    @objc private func didClickSpeakerButton(_ sender: Any) {
        guard let button = sender as? NSButton else {
            print("Warning: Could not cast sender to button")
            return
        }

        guard let indexOfSpeaker = speakerViews.firstIndex(where: { $0.button == button }) else {
            print("Warning: Could not find speaker view with button clicked")
            return
        }
        
        for speakerView in speakerViews {
            speakerView.isSelected = false
        }
        
        let speakerView = speakerViews[indexOfSpeaker]
        speakerView.isSelected = true

        let analysis = analyses[indexOfSpeaker]

//        polarView.histogramValues = analysis.azimuthProbabilities
        
        delegate?.polarOverviewVC(self, didSelectAnalysis: analysis)
    }
}

private func speakerDistanceToPolarDistance(_ speakerDistance: Double) -> CGFloat {
    var polarDistance = max(DistanceRange.lowerBound, min(DistanceRange.upperBound, speakerDistance))
    polarDistance /= DistanceRange.upperBound
    return CGFloat(polarDistance)
}

/// https://stackoverflow.com/a/54310657
private extension NSView {
    func bringSubviewToFront(_ view: NSView) {
        var theView = view
        self.sortSubviews({(viewA,viewB,rawPointer) in
            let view = rawPointer?.load(as: NSView.self)
            
            switch view {
            case viewA:
                return ComparisonResult.orderedDescending
            case viewB:
                return ComparisonResult.orderedAscending
            default:
                return ComparisonResult.orderedSame
            }
        }, context: &theView)
    }
    
}
