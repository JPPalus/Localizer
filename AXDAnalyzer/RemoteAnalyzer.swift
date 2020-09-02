//
//  RemoteAnalyzer.swift
//  AXDAnalyzer
//
//  Created by Olivier on 14/06/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Foundation

private let BRIRAnalysisURL = URL(string: "http://127.0.0.1:5000/analyze_brir")!
private let MeasurementAnalysisURL = URL(string: "http://127.0.0.1:5000/analyze_measurement")!
private let BatchBRIRAnalysesURL = URL(string: "http://127.0.0.1:5000/analyze_brirs")!
private let MaxNbFilesUploaded = 12
private let NetworkTimeout = 180.0

enum RemoteAnalyzerError: Error {
    case openFolderFailed
    case openFileFailed
    case noIRToAnalyze
    case networkFailure
    case invalidResponse
}

protocol RemoteAnalyzerDelegate: class {
    func remoteAnalyzerDidProgress(_ remoteAnalyzer: RemoteAnalyzer)
    func remoteAnalyzer(_ remoteAnalyzer: RemoteAnalyzer, didFailWithError error: RemoteAnalyzerError)
    func remoteAnalyzer(_ remoteAnalyzer: RemoteAnalyzer, didReceiveAnalyses analyses: [BRIRAnalysis])
}

//fileprivate struct Response: Decodable {
//    let analyses: [BRIRAnalysis]
//}

class RemoteAnalyzer {
    var delegate: RemoteAnalyzerDelegate? = nil
    private(set) var error: RemoteAnalyzerError? = nil
    private(set) var analyses: [BRIRAnalysis] = []
    var brirsCount: Int { return tasks.count }
    var analyzedBRIRsCount: Int { return analyses.count }
    
    private let urlSession: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = NetworkTimeout
        sessionConfig.timeoutIntervalForResource = NetworkTimeout
        let session = URLSession(configuration: sessionConfig)
        return session
    }()
    
    private var isCanceled = false
    private var tasks = [URLSessionTask]()
    
    init(brirsURLs: [URL], isMeasurement: Bool) {
        var brirsURLs = brirsURLs.filter{ $0.pathExtension == "wav" }
        
        if brirsURLs.isEmpty {
                didFail(withError: .noIRToAnalyze)
        }
        
        brirsURLs.sort(by: { $0.path < $1.path })
        if brirsURLs.count > MaxNbFilesUploaded {
            brirsURLs = Array(brirsURLs[0..<MaxNbFilesUploaded])
        }
        
        for brirURL in brirsURLs {
            let fileName = brirURL.lastPathComponent
            guard let data = try? Data(contentsOf: brirURL) else {
                didFail(withError: .openFileFailed)
                return
            }

            let task = requestBRIRAnalysis(fileName: fileName, data: data, isMeasurement: isMeasurement)
            tasks.append(task)
        }
    }
    
    func start() {
        if let error = error {
            didFail(withError: error)
        } else {
            tasks.first?.resume()
        }
    }
    
    func cancel() {
        let tasks = self.tasks
        self.tasks = []
        self.analyses = []
        
        for task in tasks {
            task.cancel()
        }
        
        isCanceled = true
    }
    
    
    private func requestBRIRAnalysis(fileName: String, data: Data, isMeasurement: Bool) -> URLSessionTask {
        let url = isMeasurement ? MeasurementAnalysisURL : BRIRAnalysisURL
        let (request, body) = buildUploadRequest(endPointURL: url,
                                                 filesNames: [fileName], filesDatas: [data])
        
        let task = urlSession.uploadTask(with: request, from: body) { [weak self] data, response, error in
            self?.didReceiveUploadResponse(data: data, response: response, error: error)
        };
        
        return task
    }
    
//    private func requestBatchBRIRAnalyses(irURLs: [URL]) throws -> URLSessionTask {
//        let (request, body) = buildUploadRequest(endPointURL: BatchBRIRAnalysesURL,
//                                                 filesURLs: irURLs)
//
//        let task = urlSession.uploadTask(with: request, from: body) { [weak self] data, response, error in
//            self?.didReceiveUploadResponse(data: data, response: response, error: error)
//        };
//
//        return task
//    }
    
    private func didReceiveUploadResponse(data: Data?, response: URLResponse?, error: Error?) {
        guard !isCanceled && self.error == nil else {
            return
        }
        
        if let error = error {
            print("Error uploading data: \(error)")
            didFail(withError: .networkFailure)
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            print("No response received after uploading data")
            didFail(withError: .invalidResponse)
            return
        }
        
        guard (200...299).contains(response.statusCode) else {
            print("Got error status code after uploading data: \(response.statusCode)")
            didFail(withError: .invalidResponse)
            return
        }
        
        guard let data = data else {
            print("Response data is missing")
            didFail(withError: .invalidResponse)
            return
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let analysis = try? decoder.decode(BRIRAnalysis.self, from: data) else {
            do {
                try decoder.decode(BRIRAnalysis.self, from: data)
            } catch let error {
                if let e = error as? (DecodingError) {
                    print(e.errorDescription!)
                }
            }
            print("Could not decode JSON")
            didFail(withError: .invalidResponse)
            return
        }
        
        analyses.append(analysis)
        if analyses.count == tasks.count {
            DispatchQueue.main.async{ [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.delegate?.remoteAnalyzer(strongSelf, didReceiveAnalyses: strongSelf.analyses)
            }
        } else {
            DispatchQueue.main.async{ [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.delegate?.remoteAnalyzerDidProgress(strongSelf)
                strongSelf.tasks[strongSelf.analyses.count].resume()
            }
        }
    }
    
    private func didFail(withError error: RemoteAnalyzerError) {
        self.error = error
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.remoteAnalyzer(strongSelf, didFailWithError: error)
        }
    }

    private func buildUploadRequest(endPointURL: URL, filesNames: [String], filesDatas: [Data]) -> (URLRequest, Data) {
        var request = URLRequest(url: endPointURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file-count\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(filesNames.count)".data(using: .utf8)!)
        
        for i in 0..<filesNames.count {
            let fileName = filesNames[i]
            let fileData = filesDatas[i]
            
            // Add the image data to the raw http request data
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file-\(i+1)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
        }
        
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return (request, body)
    }
}
