//
//  BRIRAnalysis.swift
//  AXDAnalyzer
//
//  Created by Olivier on 14/06/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Foundation
import Cocoa

struct BRIRAnalysis: Decodable {
    let isMeasurement: Bool
    
    let irName: String
    let level: Double
    let duration: Int
    let peakLevel: Double
    let latency: Double
    let polarity: Int
    let ild: Double
    let itd: Double
    let icc: Double
    let spectralVariance: Int
    let spectralVarianceLeft: Int
    let spectralVarianceRight: Int
    
    let waveformPlotData: String
    let envelopePlotData: String
    let spectrumPlotData: String
    let phasePlotData: String
    let phaseDiffPlotData: String
    let waterfallData: String
    let waterfallFlippedData: String
    
    let distance: Double?
    
    let azimuth: Int
    
    let lateralAngleMatchesCount: [Int:Int]
    let lateralAngleMostMatched: Int
    let lateralAngleHighestMatchesCount: Int
    let lateralAngleMatchesSpread: Double
    
    let lateralAngleSimilarities: [Int:Double]
    let lateralAngleMostSimilar: Int
    let lateralAngleHighestSimilarity: Int
    let lateralAngleSimilaritiesSpread: Double
    
    let frontBackMatchesPlotData: String
    let frontBackMostMatched: Int
    let frontBackHighestMatchesCount: Int
    
    let azimuthMatchesCount: [Int:Double]
    let azimuthMostMatched: Int
    
    let dummyHeadLateralAngleSimilarities: [Int:Double]
    let dummyHeadLateralAngleMostSimilar: Int
    let dummyHeadLateralAngleHighestSimilarity: Int
    let dummyHeadLateralAngleSimilaritiesSpread: Double
    
    let dummyHeadFrontBackSimilaritiesPlotData: String
    let dummyHeadFrontBackMostSimilar: Int
    let dummyHeadFrontBackHighestSimilarity: Double
    
    let dummyHeadAzimuthSimilarities: [Int:Double]
    let dummyHeadAzimuthMostSimilar: Int
    
    let fullDcnnFrontBack: Int
    let fullDcnnFrontBackCertainty: Int
    let ircamDcnnFrontBack: Int
    let ircamDcnnFrontBackCertainty: Int
    let ariDcnnFrontBack: Int
    let ariDcnnFrontBackCertainty: Int
    
    let snr: Double
    let snrLeft: Double
    let snrRight: Double
    let noiseFloor: Double
    let noiseFloorLeft: Double
    let noiseFloorRight: Double
    let tailNoiseDuration: Double
    let tailNoiseDurationLeft: Double
    let tailNoiseDurationRight: Double
    let thd: Double
    
    let reflectionsPlotData: String
    
    let drr: Double
    let drrLeft: Double
    let drrRight: Double
    let edt: Int
    let edtLeft: Int
    let edtRight: Int
    let t10: Int
    let t10Left: Int
    let t10Right: Int
    let t20: Int
    let t20Left: Int
    let t20Right: Int
    let t30: Int
    let t30Left: Int
    let t30Right: Int
    let rt30: Int
    let rt30Left: Int
    let rt30Right: Int
    let rt60: Int
    let rt60Left: Int
    let rt60Right: Int
    let c50: Int
    let c50Left: Int
    let c50Right: Int
    let d50: Int
    let d50Left: Int
    let d50Right: Int
    let c80: Int
    let c80Left: Int
    let c80Right: Int
    let d80: Int
    let d80Left: Int
    let d80Right: Int
    let equivalentRoomVolume: Int
    
    let directWaveformPlotData: String
    
    func getWaveformPlotImage() -> NSImage? {
        return base64DataToImage(waveformPlotData)
    }
    
    func getEnvelopePlotImage() -> NSImage? {
        return base64DataToImage(envelopePlotData)
    }
    
    func getSpectrumPlotImage() -> NSImage? {
        return base64DataToImage(spectrumPlotData)
    }
    
    func getPhasePlotImage() -> NSImage? {
        return base64DataToImage(phasePlotData)
    }
    
    func getPhaseDiffPlotImage() -> NSImage? {
        return base64DataToImage(phaseDiffPlotData)
    }
    
    func getWaterfallImage() -> NSImage? {
        return base64DataToImage(waterfallData)
    }
    
    func getWaterfallFlippedImage() -> NSImage? {
        return base64DataToImage(waterfallFlippedData)
    }
    
    func getDirectWaveformPlotImage() -> NSImage? {
        return base64DataToImage(directWaveformPlotData)
    }
    
    func getFrontBackMatchesPlotImage() -> NSImage? {
        return base64DataToImage(frontBackMatchesPlotData)
    }
    
    func getDummyHeadFrontBackSimilaritiesPlotImage() -> NSImage? {
        return base64DataToImage(dummyHeadFrontBackSimilaritiesPlotData)
    }
    
    func getReflectionsPlotImage() -> NSImage? {
        return base64DataToImage(reflectionsPlotData)
    }
}

private func base64DataToImage(_ base64Data: String) -> NSImage? {
    guard let dataDecoded = Data(base64Encoded: base64Data, options: .ignoreUnknownCharacters) else {
        return nil
    }
    
    let image = NSImage(data: dataDecoded)
    return image
}
