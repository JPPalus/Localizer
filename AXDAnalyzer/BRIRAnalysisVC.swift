//
//  BRIRAnalysisVC
//  AXDAnalyzer
//
//  Created by Olivier on 17/06/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Cocoa
import Foundation

class BRIRAnalysisVC: NSViewController {
    @IBOutlet weak var placeholderView: NSView!
    @IBOutlet weak var detailsView: NSScrollView!
    
    @IBOutlet weak var irNameLabel: NSTextField!
    
    @IBOutlet weak var levelLabel: NSTextField!
    @IBOutlet weak var durationLabel: NSTextField!
    @IBOutlet weak var peakLevelLabel: NSTextField!
    @IBOutlet weak var latencyLabel: NSTextField!
    @IBOutlet weak var polarityLabel: NSTextField!
    @IBOutlet weak var ildLabel: NSTextField!
    @IBOutlet weak var itdLabel: NSTextField!
    @IBOutlet weak var iccLabel: NSTextField!
    @IBOutlet weak var spectralVarianceLabel: NSTextField!
    @IBOutlet weak var spectralVarianceLeftLabel: NSTextField!
    @IBOutlet weak var spectralVarianceRightLabel: NSTextField!
    
    @IBOutlet weak var waveformImageView: NSImageView!
    @IBOutlet weak var envelopeImageView: NSImageView!
    @IBOutlet weak var spectrumImageView: NSImageView!
    @IBOutlet weak var phaseImageView: NSImageView!
    @IBOutlet weak var phaseDiffImageView: NSImageView!
    @IBOutlet weak var waterfallImageView: NSImageView!
    
    @IBOutlet weak var distanceLabel: NSTextField!
    
    @IBOutlet weak var lateralMatchesView: HalfPolarView!
    @IBOutlet weak var lateralMostMatchedLabel: NSTextField!
    @IBOutlet weak var lateralHighestMatchesLabel: NSTextField!
    @IBOutlet weak var lateralMatchesSpreadLabel: NSTextField!
    
    @IBOutlet weak var frontBackMatchesImageView: NSImageView!
    @IBOutlet weak var frontBackMostMatchedLabel: NSTextField!
    @IBOutlet weak var frontBackHighestMatchesLabel: NSTextField!
    
    @IBOutlet weak var lateralSimilaritiesView: HalfPolarView!
    @IBOutlet weak var lateralMostSimilarLabel: NSTextField!
    @IBOutlet weak var lateralHighestSimilarityLabel: NSTextField!
    @IBOutlet weak var lateralSimilaritiesSpreadLabel: NSTextField!
    
    @IBOutlet weak var azimuthMatchesView: PolarView!
    @IBOutlet weak var azimuthMostMatchedLabel: NSTextField!
    
    @IBOutlet weak var dummyHeadLateralSimilaritiesView: HalfPolarView!
    @IBOutlet weak var dummyHeadLateralMostSimilarLabel: NSTextField!
    @IBOutlet weak var dummyHeadLateralHighestSimilarityLabel: NSTextField!
    @IBOutlet weak var dummyHeadLateralSimilaritiesSpreadLabel: NSTextField!
    
    @IBOutlet weak var dummyHeadFrontBackSimilaritiesImageView: NSImageView!
    @IBOutlet weak var dummyHeadFrontBackMostSimilarLabel: NSTextField!
    @IBOutlet weak var dummyHeadFrontBackHighestSimilarityLabel: NSTextField!
    
    @IBOutlet weak var dummyHeadAzimuthSimilaritiesViews: PolarView!
    @IBOutlet weak var dummyHeadAzimuthMostSimilarLabel: NSTextField!
    
    @IBOutlet weak var fullDCNNFrontBackLabel: NSTextField!
    @IBOutlet weak var fullDCNNFrontBackCertaintyLabel: NSTextField!
    @IBOutlet weak var ircamDCNNFrontBackLabel: NSTextField!
    @IBOutlet weak var ircamDCNNFrontBackCertaintyLabel: NSTextField!
    @IBOutlet weak var ariDCNNFrontBackLabel: NSTextField!
    @IBOutlet weak var ariDCNNFrontBackCertaintyLabel: NSTextField!
    @IBOutlet weak var fullDCNNLateralAzimuthLabel: NSTextField!
    @IBOutlet weak var fullDCNNElevationLabel: NSTextField!
    
    @IBOutlet weak var snrLabel: NSTextField!
    @IBOutlet weak var snrLeftLabel: NSTextField!
    @IBOutlet weak var snrRightLabel: NSTextField!
    @IBOutlet weak var noiseFloorLabel: NSTextField!
    @IBOutlet weak var noiseFloorLeftLabel: NSTextField!
    @IBOutlet weak var noiseFloorRightLabel: NSTextField!
    @IBOutlet weak var tailNoiseDurationLabel: NSTextField!
    @IBOutlet weak var tailNoiseDurationLeftLabel: NSTextField!
    @IBOutlet weak var tailNoiseDurationRightLabel: NSTextField!
//    @IBOutlet weak var thdLabel: NSTextField!

    @IBOutlet weak var reflectionsImageView: NSImageView!
    
    @IBOutlet weak var drrLabel: NSTextField!
    @IBOutlet weak var drrLeftLabel: NSTextField!
    @IBOutlet weak var drrRightLabel: NSTextField!
    @IBOutlet weak var edtLabel: NSTextField!
    @IBOutlet weak var edtLeftLabel: NSTextField!
    @IBOutlet weak var edtRightLabel: NSTextField!
    @IBOutlet weak var t10Label: NSTextField!
    @IBOutlet weak var t10LeftLabel: NSTextField!
    @IBOutlet weak var t10RightLabel: NSTextField!
    @IBOutlet weak var t20Label: NSTextField!
    @IBOutlet weak var t20LeftLabel: NSTextField!
    @IBOutlet weak var t20RightLabel: NSTextField!
    @IBOutlet weak var t30Label: NSTextField!
    @IBOutlet weak var t30LeftLabel: NSTextField!
    @IBOutlet weak var t30RightLabel: NSTextField!
    @IBOutlet weak var rt30Label: NSTextField!
    @IBOutlet weak var rt30LeftLabel: NSTextField!
    @IBOutlet weak var rt30RightLabel: NSTextField!
    @IBOutlet weak var rt60Label: NSTextField!
    @IBOutlet weak var rt60LeftLabel: NSTextField!
    @IBOutlet weak var rt60RightLabel: NSTextField!
    @IBOutlet weak var c50Label: NSTextField!
    @IBOutlet weak var c50LeftLabel: NSTextField!
    @IBOutlet weak var c50RightLabel: NSTextField!
    @IBOutlet weak var d50Label: NSTextField!
    @IBOutlet weak var d50LeftLabel: NSTextField!
    @IBOutlet weak var d50RightLabel: NSTextField!
    @IBOutlet weak var c80Label: NSTextField!
    @IBOutlet weak var c80LeftLabel: NSTextField!
    @IBOutlet weak var c80RightLabel: NSTextField!
    @IBOutlet weak var d80Label: NSTextField!
    @IBOutlet weak var d80LeftLabel: NSTextField!
    @IBOutlet weak var d80RightLabel: NSTextField!
//    @IBOutlet weak var equivalentRoomVolumeLabel: NSTextField!
    
    @IBOutlet weak var directPeakLevelLabel: NSTextField!
    @IBOutlet weak var directLevelLabel: NSTextField!
    @IBOutlet weak var directLatencyLabel: NSTextField!
    @IBOutlet weak var directPolarityLabel: NSTextField!
    @IBOutlet weak var directSpectralVarianceLabel: NSTextField!
    @IBOutlet weak var directILDLabel: NSTextField!
    @IBOutlet weak var directITDLabel: NSTextField!
    
    @IBOutlet weak var directWaveformImageView: NSImageView!
    
    var analysis: BRIRAnalysis? {
        didSet { updateView() }
    }
    
    private var isWaterfallFlipped = false
    
    override func viewDidLoad() {
        setupView()
        super.viewDidLoad()
    }
    
    private func setupView() {
        placeholderView.wantsLayer = true
        placeholderView.layer!.backgroundColor = CGColor.white
//
        for polarView in [azimuthMatchesView, dummyHeadAzimuthSimilaritiesViews] {
            polarView!.showDistanceRulers = false
            polarView!.showDistanceGraduations = false
            polarView!.majorAngleGraduations = [0, 45, 90, 135, 180, -135, -90, -45]
            polarView!.minorAngleGraduations = [15, 30, 60, 75, 105, 120, 150, 165, -165, -150, -120, -105, -75, -60, -30, -15]
        }
        
        for halfPolarView in [lateralMatchesView, lateralSimilaritiesView, dummyHeadLateralSimilaritiesView] {
            halfPolarView!.showDistanceRulers = false
            halfPolarView!.showDistanceGraduations = false
            halfPolarView!.majorAngleGraduations = [0, 45, 90, -90, -45]
            halfPolarView!.minorAngleGraduations = [15, 30, 60, 75, -75, -60, -30, -15]
        }
        
        updateView()
    }
    
    private func updateView() {
        if let analysis = analysis {
            placeholderView.isHidden = true
            detailsView.isHidden = false
            updateViewWithAnalysis(analysis)
        } else {
            detailsView.isHidden = true
            placeholderView.isHidden = false
            detailsView.contentView.scroll(to: NSPoint.zero)
            detailsView.verticalScroller?.floatValue = 0.0
        }
    }
    
    private func updateViewWithAnalysis(_ analysis: BRIRAnalysis) {
        irNameLabel.stringValue = analysis.irName
        
        levelLabel.stringValue = "\(analysis.level) dB"
        durationLabel.stringValue = "\(analysis.duration) ms"
        peakLevelLabel.stringValue = "\(analysis.peakLevel) dB"
        latencyLabel.stringValue = "\(analysis.latency) ms"
        polarityLabel.stringValue = analysis.polarity == 1 ? "Positive" : "Negative"
        ildLabel.stringValue = "\(analysis.ild) dB"
        itdLabel.stringValue = "\(analysis.itd) ms"
        iccLabel.stringValue = "\(analysis.icc)"
        spectralVarianceLabel.stringValue = "\(analysis.spectralVariance)"
        spectralVarianceLeftLabel.stringValue = "\(analysis.spectralVarianceLeft)"
        spectralVarianceRightLabel.stringValue = "\(analysis.spectralVarianceRight)"
        
        
        if isWaterfallFlipped {
            waterfallImageView.image = analysis.getWaterfallImage()
        } else {
            waterfallImageView.image = analysis.getWaterfallFlippedImage()
        }
        
        waveformImageView.image = analysis.getWaveformPlotImage()
        envelopeImageView.image = analysis.getEnvelopePlotImage()
        spectrumImageView.image = analysis.getSpectrumPlotImage()
        phaseImageView.image = analysis.getPhasePlotImage()
        phaseDiffImageView.image = analysis.getPhaseDiffPlotImage()
        
        if let distance = analysis.distance {
            distanceLabel.stringValue = "\(distance) m"
        } else {
           distanceLabel.stringValue = ""
        }

        
        let lateralMaxMatchesCount = Double(analysis.lateralAngleMatchesCount.values.max() ?? 1)
        lateralMatchesView.histogramValues = analysis.lateralAngleMatchesCount.mapValues { Double($0) / lateralMaxMatchesCount}
        lateralMostMatchedLabel.stringValue = "\(analysis.lateralAngleMostMatched)°"
        lateralHighestMatchesLabel.stringValue = "\(analysis.lateralAngleHighestMatchesCount)"
        lateralMatchesSpreadLabel.stringValue = "\(analysis.lateralAngleMatchesSpread)"
        
        frontBackMatchesImageView.image = analysis.getFrontBackMatchesPlotImage()
        frontBackMostMatchedLabel.stringValue = analysis.frontBackMostMatched == 0 ? "Front" : "Back"
        frontBackHighestMatchesLabel.stringValue = "\(analysis.frontBackHighestMatchesCount)"
        
        lateralSimilaritiesView.curveValues = analysis.lateralAngleSimilarities
        lateralMostSimilarLabel.stringValue = "\(analysis.lateralAngleMostSimilar)°"
        lateralHighestSimilarityLabel.stringValue = "\(analysis.lateralAngleHighestSimilarity) %"
        lateralSimilaritiesSpreadLabel.stringValue = "\(analysis.lateralAngleSimilaritiesSpread)"
        
        let azimuthMaxMatchesCount = Double(analysis.azimuthMatchesCount.values.max() ?? 1)
        azimuthMatchesView.histogramValues = analysis.azimuthMatchesCount.mapValues { Double($0) / azimuthMaxMatchesCount}
        azimuthMostMatchedLabel.stringValue = "\(analysis.azimuthMostMatched)°"
        
        dummyHeadLateralSimilaritiesView.curveValues = analysis.dummyHeadLateralAngleSimilarities
        dummyHeadLateralMostSimilarLabel.stringValue = "\(analysis.dummyHeadLateralAngleMostSimilar)°"
        dummyHeadLateralHighestSimilarityLabel.stringValue = "\(analysis.dummyHeadLateralAngleHighestSimilarity) %"
        dummyHeadLateralSimilaritiesSpreadLabel.stringValue = "\(analysis.dummyHeadLateralAngleSimilaritiesSpread)"
        
        
        dummyHeadFrontBackSimilaritiesImageView.image = analysis.getDummyHeadFrontBackSimilaritiesPlotImage()
        dummyHeadFrontBackMostSimilarLabel.stringValue = analysis.dummyHeadFrontBackMostSimilar == 0 ? "Front" : "Back"
        dummyHeadFrontBackHighestSimilarityLabel.stringValue = "\(analysis.dummyHeadFrontBackHighestSimilarity)"
        
        dummyHeadAzimuthSimilaritiesViews.curveValues = analysis.dummyHeadAzimuthSimilarities
        dummyHeadAzimuthMostSimilarLabel.stringValue = "\(analysis.dummyHeadAzimuthMostSimilar)°"
        
        fullDCNNFrontBackLabel.stringValue = analysis.fullDcnnFrontBack == 0 ? "Front" : "Back"
        fullDCNNFrontBackCertaintyLabel.stringValue = "\(analysis.fullDcnnFrontBackCertainty) %"
        ircamDCNNFrontBackLabel.stringValue = analysis.ircamDcnnFrontBack == 0 ? "Front" : "Back"
        ircamDCNNFrontBackCertaintyLabel.stringValue = "\(analysis.ircamDcnnFrontBackCertainty) %"
        ariDCNNFrontBackLabel.stringValue = analysis.ariDcnnFrontBack == 0 ? "Front" : "Back"
        ariDCNNFrontBackCertaintyLabel.stringValue = "\(analysis.ariDcnnFrontBackCertainty) %"
//        fullDCNNElevationLabel.stringValue = "\(analysis.elevation)°"
        
        
        snrLabel.stringValue = "\(analysis.snr) dB"
        snrLeftLabel.stringValue = "\(analysis.snrLeft) dB"
        snrRightLabel.stringValue = "\(analysis.snrRight) dB"
        noiseFloorLabel.stringValue = "\(analysis.noiseFloor) dB"
        noiseFloorLeftLabel.stringValue = "\(analysis.noiseFloorLeft) dB"
        noiseFloorRightLabel.stringValue = "\(analysis.noiseFloorRight) dB"
        tailNoiseDurationLabel.stringValue = "\(analysis.tailNoiseDuration) ms"
        tailNoiseDurationLeftLabel.stringValue = "\(analysis.tailNoiseDurationLeft) ms"
        tailNoiseDurationRightLabel.stringValue = "\(analysis.tailNoiseDurationRight) ms"
//        thdLabel.stringValue = "\(analysis.thd) %"
        
        reflectionsImageView.image = analysis.getReflectionsPlotImage()
        
        drrLabel.stringValue = "\(analysis.drr) dB"
        drrLeftLabel.stringValue = "\(analysis.drrLeft) dB"
        drrRightLabel.stringValue = "\(analysis.drrRight) dB"
        edtLabel.stringValue = "\(analysis.edt) ms"
        edtLeftLabel.stringValue = "\(analysis.edtLeft) ms"
        edtRightLabel.stringValue = "\(analysis.edtRight) ms"
        t10Label.stringValue = "\(analysis.t10) ms"
        t10LeftLabel.stringValue = "\(analysis.t10Left) ms"
        t10RightLabel.stringValue = "\(analysis.t10Right) ms"
        t20Label.stringValue = "\(analysis.t20) ms"
        t20LeftLabel.stringValue = "\(analysis.t20Left) ms"
        t20RightLabel.stringValue = "\(analysis.t20Right) ms"
        t30Label.stringValue = "\(analysis.t30) ms"
        t30LeftLabel.stringValue = "\(analysis.t30Left) ms"
        t30RightLabel.stringValue = "\(analysis.t30Right) ms"
        rt30Label.stringValue = "\(analysis.rt30) ms"
        rt30LeftLabel.stringValue = "\(analysis.rt30Left) ms"
        rt30RightLabel.stringValue = "\(analysis.rt30Right) ms"
        rt60Label.stringValue = "\(analysis.rt60) ms"
        rt60LeftLabel.stringValue = "\(analysis.rt60Left) ms"
        rt60RightLabel.stringValue = "\(analysis.rt60Right) ms"
        c50Label.stringValue = "\(analysis.c50) dB"
        c50LeftLabel.stringValue = "\(analysis.c50Left) dB"
        c50RightLabel.stringValue = "\(analysis.c50Right) dB"
        d50Label.stringValue = "\(analysis.d50) %"
        d50LeftLabel.stringValue = "\(analysis.d50Left) %"
        d50RightLabel.stringValue = "\(analysis.d50Right) %"
        c80Label.stringValue = "\(analysis.c80) dB"
        c80LeftLabel.stringValue = "\(analysis.c80Left) dB"
        c80RightLabel.stringValue = "\(analysis.c80Right) dB"
        d80Label.stringValue = "\(analysis.d80) %"
        d80LeftLabel.stringValue = "\(analysis.d80Left) %"
        d80RightLabel.stringValue = "\(analysis.d80Right) %"
//        equivalentRoomVolumeLabel.stringValue = "\(analysis.equivalentRoomVolume) m³"
        
        directWaveformImageView.image = analysis.getDirectWaveformPlotImage()
    }
    
    @IBAction func didClickWaterfallImage(_ sender: Any) {
        isWaterfallFlipped.toggle()
        
        if isWaterfallFlipped {
            waterfallImageView.image = analysis?.getWaterfallImage()
        } else {
            waterfallImageView.image = analysis?.getWaterfallFlippedImage()
        }
    }
}
