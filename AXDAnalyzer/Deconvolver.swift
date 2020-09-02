//
//  Deconvolver.swift
//  AXDAnalyzer
//
//  Created by Olivier on 26/08/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Foundation

class Deconvolver {
    func deconvolve(sweepURL: URL, completion: @escaping (_ brirsFolder: URL) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let sweepPath = sweepURL.path
            let tempFolderURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let tempBRIRsFolderURL = tempFolderURL.appendingPathComponent(ProcessInfo().globallyUniqueString, isDirectory: true)
            let fileManager = FileManager.default
            try! fileManager.createDirectory(at: tempBRIRsFolderURL, withIntermediateDirectories: false)
            let brirPath = tempBRIRsFolderURL.appendingPathComponent("%02d.wav").path
            
            var errorCode = AXDANALYZ_NO_ERROR
            axdanalyz_deconvolve_measure_signal(sweepPath, brirPath, &errorCode)
            
            DispatchQueue.main.async {
                completion(tempBRIRsFolderURL)
            }
        }
    }
}
