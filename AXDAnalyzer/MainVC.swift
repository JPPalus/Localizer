//
//  MainVC.swift
//  AXDAnalyzer
//
//  Created by Olivier on 05/06/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Cocoa

extension MainVC {
    enum State {
        case empty, loading, failed(errorMessage: String), loaded
    }
}

private let ProgressMessages = ["Uploading data", "Computing spectrum", "Computing SNR", "Analyzing reverberation", "Analyzing azimuth", "Analyzing elevation", "Estimating reflections", "Analyzing localization with neural network"]

class MainVC: NSViewController, NSSplitViewDelegate, PolarOverviewVCDelegate, RemoteAnalyzerDelegate {
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var placeholderView: NSView!
    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var loadingMessageLabel: NSTextField!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var errorView: NSView!
    @IBOutlet weak var errorMessageLabel: NSTextField!
    @IBOutlet weak var panView: NSView!
    @IBOutlet weak var panSlider: NSSlider!
    @IBOutlet weak var saveView: NSView!
    
    weak var polarOverviewVC: PolarOverviewVC!
    weak var analysisVC: BRIRAnalysisVC!
    
    private var state = State.empty
    private var remoteAnalyzer: RemoteAnalyzer? = nil
    private var isMeasurement: Bool = false
    private var indexOfAnalysisSelected: Int?
    private var analyses = [BRIRAnalysis]()
    
    // variables used to show progress
    private var analysisTimePerBRIR: TimeInterval = 15.0
    private var lastProgressTime = Date()
    private var progressTimer: Timer? = nil
    
    private var deconvolveKey: String?
    private var deconvolvedBRIRsFolder: URL?
    
    override func viewDidLoad() {
        updateView()
        super.viewDidLoad()
    }
    
    override func viewDidLayout() {
        splitView.setPosition(splitView.bounds.width / 3, ofDividerAt: 0)
        super.viewDidLayout()
    }
    
    private func updateView() {
        switch state {
        case .empty:
            placeholderView.isHidden = false
            loadingView.isHidden = true
            errorView.isHidden = true
            splitView.isHidden = true
            
        case .loading:
            placeholderView.isHidden = true
            loadingView.isHidden = false
            loadingIndicator.startAnimation(nil)
            errorView.isHidden = true
            splitView.isHidden = true
            
        case .failed(let errorMessage):
            placeholderView.isHidden = true
            loadingView.isHidden = true
            errorView.isHidden = false
            errorMessageLabel.stringValue = errorMessage
            splitView.isHidden = true
            
        case .loaded:
            placeholderView.isHidden = true
            loadingView.isHidden = true
            errorView.isHidden = true
            splitView.isHidden = false
            
            if isMeasurement {
                panView.isHidden = false
                saveView.isHidden = false
                panSlider.integerValue = indexOfAnalysisSelected ?? 0
            } else {
                panView.isHidden = true
                saveView.isHidden = true
            }
        }
    }
    
    private func updateProgressMessage() {
        let currentTime = Date()
        let progress = currentTime.timeIntervalSince(lastProgressTime) / (analysisTimePerBRIR / 2)
        var messageIndex = Int(round(progress * Double(ProgressMessages.count - 1)))
        messageIndex = min(messageIndex, ProgressMessages.count - 1)
        let message = "\(ProgressMessages[messageIndex]) for IR \(remoteAnalyzer!.analyzedBRIRsCount + 1) of \(remoteAnalyzer!.brirsCount)"
        loadingMessageLabel.stringValue = message
    }

    func loadProfile() {
        let panel = NSOpenPanel()
        panel.title = "Load Profile"
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.canCreateDirectories = false
        
        let result = panel.runModal()
        guard result == .OK, !panel.urls.isEmpty else {
            return
        }
        
        let urls = panel.urls
        var urlsAll = urls
        for url in urls {
            if url.pathExtension != "" {
                continue
            }
            let fileManager = FileManager.default
            guard let urlsInFolder = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else {
                continue
            }
            urlsAll += urlsInFolder
        }
        
        isMeasurement = false
        indexOfAnalysisSelected = nil
        deconvolveKey = nil
        deconvolvedBRIRsFolder = nil
        
        startRemoteAnalysis(brirsURLs: urlsAll, isMeasurement: false)
    }
    
    // MARK: -
    
    func loadMeasurement() {
        let panel = NSOpenPanel()
        panel.title = "Load Measurement"
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["wav", "aiff", "bwf"]
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        
        let result = panel.runModal()
        guard result == .OK, let url = panel.url else {
            return
        }
        
        isMeasurement = true
        indexOfAnalysisSelected = 0
        deconvolveKey = nil
        deconvolvedBRIRsFolder = nil
        
        deconvolveMeasurement(sweepURL: url)
    }
    
    func exportMeasurement() {
        let panel = NSSavePanel()
        panel.title = "Export Measurement Signal"
        panel.canCreateDirectories = true
        panel.allowedFileTypes = ["wav"]
        panel.canCreateDirectories = false
        panel.nameFieldStringValue = "axd_measure_signal.wav"
        let waveOptionsView = WaveOptionsView()
        panel.accessoryView = waveOptionsView
        
        let result = panel.runModal()
        guard result == .OK, let url = panel.url else {
            return
        }
        
        let sampleRate = waveOptionsView.sampleRate
        var errorCode = AXDANALYZ_NO_ERROR
        axdanalyz_gen_measure_signal(Int32(sampleRate), url.path, &errorCode)
    }
    
    private func startRemoteAnalysis(brirsURLs: [URL], isMeasurement: Bool) {
        state = .loading
        analyses = []
        
        remoteAnalyzer?.delegate = nil
        remoteAnalyzer?.cancel()
        
        remoteAnalyzer = RemoteAnalyzer(brirsURLs: brirsURLs, isMeasurement: isMeasurement)
        
        remoteAnalyzer?.delegate = self
        remoteAnalyzer?.start()
        
        lastProgressTime = Date()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateProgressMessage()
        }
        
        updateProgressMessage()
        updateView()
    }
    
    // MARK: - Split view delegate
    
    func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return false
    }
    
    func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return splitView.bounds.width * 1 / 3
    }
    
    func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        return splitView.bounds.width * 2 / 3
    }
    
    // MARK: - Polar VC delegate
    
    func polarOverviewVC(_ polarOverviewVC: PolarOverviewVC, didSelectAnalysis analysis: BRIRAnalysis) {
        analysisVC.analysis = analysis
    }
    
    func deconvolveMeasurement(sweepURL: URL) {
        state = .loading
        
        
        let deconvolver = Deconvolver()
        let deconvolveKey = UUID().uuidString
        self.deconvolveKey = deconvolveKey
        deconvolver.deconvolve(sweepURL: sweepURL) { [weak self] brirsFolder in
            guard let strongSelf = self else {
                return
            }
            
            guard let currentKey = strongSelf.deconvolveKey, deconvolveKey == currentKey else {
                return
            }
            
            strongSelf.deconvolvedBRIRsFolder = brirsFolder
            
            let fileManager = FileManager.default
            let brirsURLs = try! fileManager.contentsOfDirectory(at: brirsFolder, includingPropertiesForKeys: nil)
            strongSelf.startRemoteAnalysis(brirsURLs: brirsURLs, isMeasurement: true)
        }
        
        loadingMessageLabel.stringValue = "Preparing impulse responses"
        updateView()

    }
    
    // MARK: - Remote analysis delegate
    
    func remoteAnalyzerDidProgress(_ remoteAnalyzer: RemoteAnalyzer) {
        let currentTime = Date()
        analysisTimePerBRIR = currentTime.timeIntervalSince(lastProgressTime)
        lastProgressTime = currentTime
        updateProgressMessage()
    }
    
    func remoteAnalyzer(_ remoteAnalyzer: RemoteAnalyzer, didFailWithError error: RemoteAnalyzerError) {
        let errorMessage = { () -> String in
            switch(error) {
            case .noIRToAnalyze: return "No impulse response to analyze"
            case .invalidResponse: return "Received invalid response"
            case .networkFailure: return "Network failure"
            case .openFileFailed: return "Could not open local impulse response"
            case .openFolderFailed: return "Could not open local folder"
            }
        }()
        state = .failed(errorMessage: errorMessage)
        progressTimer?.invalidate()
        progressTimer = nil
        updateView()
    }
    
    func remoteAnalyzer(_ remoteAnalyzer: RemoteAnalyzer, didReceiveAnalyses analyses: [BRIRAnalysis]) {
        self.analyses = analyses
        polarOverviewVC.analyses = analyses
        if isMeasurement, let indexOfAnalysis = indexOfAnalysisSelected {
            polarOverviewVC.indexOfAnalysisToHighlight = indexOfAnalysis
            analysisVC.analysis = analyses[indexOfAnalysis]
        } else {
            polarOverviewVC.indexOfAnalysisToHighlight = nil
            analysisVC.analysis = nil
        }
        
        state = .loaded
        progressTimer?.invalidate()
        progressTimer = nil
        
        updateView()
    }
    
    // MARK: -
    
    @IBAction func panSliderDidChange(_ sender: NSSlider) {
        if !isMeasurement {
            return
        }
        
        indexOfAnalysisSelected = panSlider.integerValue
        polarOverviewVC.indexOfAnalysisToHighlight = panSlider.integerValue
        analysisVC.analysis = analyses[panSlider.integerValue]
    }
    
    @IBAction func saveButtonDidClick(_ sender: NSButton) {
        guard let brirsFolder = deconvolvedBRIRsFolder else {
            return
        }
        guard let indexOfAnalysis = indexOfAnalysisSelected else {
            return
        }
        
        let panel = NSSavePanel()
        panel.title = "Save IR"
        panel.canCreateDirectories = true
        panel.allowedFileTypes = ["wav"]
        let result = panel.runModal()
        
        guard result == .OK, let saveURL = panel.url else {
            return
        }
        
        let fileManager = FileManager.default
        guard var brirURLs = try? fileManager.contentsOfDirectory(at: brirsFolder, includingPropertiesForKeys: nil) else {
            return
        }
        
        brirURLs = brirURLs.filter{ $0.pathExtension == "wav" }
        brirURLs.sort(by: { $0.path < $1.path })
        
        let sourceURL = brirURLs[indexOfAnalysis]
        // TODO: TRIM and WINDOW
        do {
            if fileManager.fileExists(atPath: saveURL.path) {
                try? fileManager.removeItem(at: saveURL)
            }
            
            try fileManager.copyItem(at: sourceURL, to: saveURL)
        } catch {
            print("Could not copy IR file: \(error.localizedDescription)")
            
            let alert = NSAlert()
            alert.messageText = "Could not save file"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedPolarOverviewVCSegue" {
            polarOverviewVC = (segue.destinationController as! PolarOverviewVC)
            polarOverviewVC.delegate = self
        }
        else if segue.identifier == "EmbedBRIRAnalysisVCSegue" {
            analysisVC = (segue.destinationController as! BRIRAnalysisVC)
        }
        
        super.prepare(for: segue, sender: sender)
    }
}
