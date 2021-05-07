//
//  NetworkingHandler.swift
//  Spellfinder
//
//  Created by Eva Yan on 5/6/21.
//

import Foundation
import Network

class NetworkingHandler: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        // Indicate network status, e.g., offline mode
        print("-- OFFLINE --")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest: URLRequest, completionHandler: (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        // Indicate network status, e.g., back to online
        print("-- ONLINE --")
    }
}
