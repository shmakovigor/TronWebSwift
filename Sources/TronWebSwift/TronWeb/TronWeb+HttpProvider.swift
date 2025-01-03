//
//  Web3HttpProvider.swift
//  
//
//  Created by mathwallet on 2022/6/29.
//

import Foundation

public class TronWebHttpProvider {
    public var url: URL
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()
    
    public init?(_ httpProviderURL: URL) {
        guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else {return nil}
        self.url = httpProviderURL
    }
}

extension TronWebHttpProvider {
    static func GET<K: Decodable>(_ parameters: [String: Any]? = nil, providerURL: URL, session: URLSession)  async throws -> K {
        let url = providerURL.appendingQueryParameters(parameters)
        var urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, _) = try await session.data(for: urlRequest)
        if let errResp = try? JSONDecoder().decode(TronWebResponse.Error.self, from: data) {
            throw TronWebError.processingError(desc: errResp.error)
        }
        guard let resp = try? JSONDecoder().decode(K.self, from: data) else {
            throw TronWebError.nodeError(desc: "Received an error message from node")
        }
        return resp
    }
    
    static func POST<K: Decodable>(_ parameters: [String: Any]? = nil, providerURL: URL, session: URLSession) async throws -> K {
        var urlRequest = URLRequest(url: providerURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if let p = parameters {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: p, options: .fragmentsAllowed)
        }
        let (data, _) = try await session.data(for: urlRequest)
        if let errResp = try? JSONDecoder().decode(TronWebResponse.Error.self, from: data) {
            throw TronWebError.processingError(desc: errResp.error)
        }
        guard let resp = try? JSONDecoder().decode(K.self, from: data) else {
            throw TronWebError.nodeError(desc: "Received an error message from node")
        }
        return resp
    }
}

extension TronWebHttpProvider {
    
    public func getChainParameters() async throws -> Protocol_ChainParameters {
        let providerURL = self.url.appending(.getChainParameters)
        return try await TronWebHttpProvider.GET(nil, providerURL: providerURL, session: self.session)
    }
    
    public func getNowBlock() async throws -> Protocol_Block {
        let providerURL = self.url.appending(.getNowBlock)
        return try await TronWebHttpProvider.POST(nil, providerURL: providerURL, session: self.session)
    }
    
    public func getAccount(_ address: TronAddress) async throws -> Protocol_Account {
        let parameters: [String: Encodable] = [
            "address": address.address,
            "visible": true
        ]
        let providerURL = self.url.appending(.getAccount)
        return try await TronWebHttpProvider.POST(parameters, providerURL: providerURL, session: self.session)
    }
    
    public func getAccountResource(_ address: TronAddress) async throws -> Protocol_AccountResourceMessage {
        let parameters: [String: Encodable] = [
            "address": address.address,
            "visible": true
        ]
        let providerURL = self.url.appending(.getAccountResource)
        return try await TronWebHttpProvider.POST(parameters, providerURL: providerURL, session: self.session)
    }
    
    public func createTransaction(_ contract: Protocol_TransferContract) async throws -> Protocol_Transaction {
        let parameters: [String: Encodable] = [
            "owner_address": contract.ownerAddress.toHexString(),
            "to_address": contract.toAddress.toHexString(),
            "amount": contract.amount,
            "visible": false
        ]
        let providerURL = self.url.appending(.createTransaction)
        return try await TronWebHttpProvider.POST(parameters, providerURL: providerURL, session: self.session)
    }
    
    public func transferAsset(_ contract: Protocol_TransferAssetContract) async throws -> Protocol_Transaction {
        let parameters: [String: Encodable] = [
            "owner_address": contract.ownerAddress.toHexString(),
            "to_address": contract.toAddress.toHexString(),
            "asset_name": contract.assetName.toHexString(),
            "amount": contract.amount,
            "visible": false
        ]
        let providerURL = self.url.appending(.transferAsset)
        return try await TronWebHttpProvider.POST(parameters, providerURL: providerURL, session: self.session)
    }
    
    public func triggerSmartContract(_ request: TronTriggerSmartContractExtension) async throws -> Protocol_TransactionExtention {
        let parameters: [String: Encodable] = [
            "owner_address": request.contract.ownerAddress.toHexString(),
            "contract_address": request.contract.contractAddress.toHexString(),
            "function_selector": request.functionSelector,
            "parameter": request.parameter.toHexString(),
            "fee_limit": request.feeLimit,
            "call_value": request.contract.callValue,
            "token_id": request.contract.tokenID,
            "call_token_value": request.contract.callTokenValue,
            "visible": false
        ]
        let providerURL = self.url.appending(.triggerSmartContract)
        return try await TronWebHttpProvider.POST(parameters, providerURL: providerURL, session: self.session)
    }
    
    public func triggerConstantContract(_ request: TronTriggerSmartContractExtension) async throws -> Protocol_TransactionExtention {
        let parameters: [String: Encodable] = [
            "owner_address": request.contract.ownerAddress.toHexString(),
            "contract_address": request.contract.contractAddress.toHexString(),
            "function_selector": request.functionSelector,
            "parameter": request.parameter.toHexString(),
            "call_value": request.contract.callValue,
            "visible": false
        ]
        let providerURL = self.url.appending(.triggerConstantContract)
        return try await TronWebHttpProvider.POST(parameters, providerURL: providerURL, session: self.session)
    }
    
    public func broadcastTransaction(_ transaction: Protocol_Transaction) async throws -> TronTransactionSendingResult {
        let parameters: [String: Encodable] = [
            "transaction": try! transaction.serializedData().toHexString()
        ]
        let providerURL = self.url.appending(.broadcastTransaction)
        return try await TronWebHttpProvider.POST(parameters, providerURL: providerURL, session: self.session)
    }
}
