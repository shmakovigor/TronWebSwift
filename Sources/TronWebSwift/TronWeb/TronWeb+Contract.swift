//
//  TronWeb+Contract.swift
//
//
//  Created by mathwallet on 2022/7/2.
//

import Foundation
import BigInt

extension TronWeb {
    public func contract(_ abiString: String, at: TronAddress?) -> WebContract? {
        return WebContract(provider: self.provider, abiString: abiString, at: at, transactionOptions: self.transactionOptions)
    }
    
    public class WebContract {
        var contract: TronContract
        var provider : TronWebHttpProvider
        public var transactionOptions: TronTransactionOptions? = nil
        
        public init?(provider: TronWebHttpProvider, abiString: String, at: TronAddress? = nil, transactionOptions: TronTransactionOptions? = nil) {
            self.provider = provider
            self.transactionOptions = transactionOptions
            guard let c = TronContract(abiString, at: at) else {
                return nil
            }
            self.contract = c
        }
        
        public func build(_ method: String, parameters: [AnyObject] = [AnyObject](), transactionOptions: TronTransactionOptions? = nil) async throws -> TronTransaction {
            let opts = transactionOptions ?? self.transactionOptions
            guard let request = contract.method(method, parameters: parameters, transactionOptions: opts) else {
                throw TronWebError.processingError(desc: "Invalid Contract.")
            }
            let txEx = try await self.provider.triggerSmartContract(request)
            return txEx.transaction
        }
        
        public func write(_ method: String, parameters: [AnyObject] = [AnyObject](), signer: TronSigner, transactionOptions: TronTransactionOptions? = nil) async throws -> TronTransactionSendingResult {
            let opts = transactionOptions ?? self.transactionOptions
            guard let request = contract.method(method, parameters: parameters, transactionOptions: opts) else {
                throw TronWebError.processingError(desc: "Contract writing error.")
            }
            let txEx = try await self.provider.triggerSmartContract(request)
            let signedTx = try txEx.transaction.sign(signer)
            return try await self.provider.broadcastTransaction(signedTx)
        }
        
        public func read(_ method: String, parameters: [AnyObject] = [AnyObject](), transactionOptions: TronTransactionOptions? = nil) async throws -> [String: Any] {
            let opts = transactionOptions ?? self.transactionOptions
            guard let request = contract.method(method, parameters: parameters, transactionOptions: opts) else {
                throw TronWebError.processingError(desc: "Invalid Contract.")
            }
            let res = try await self.provider.triggerConstantContract(request)
            if let returnData = res.constantResult.first {
                return contract.decodeReturnData(method, data: returnData) ?? [:]
            } else {
                throw TronWebError.processingError(desc: "Contract read error.")
            }
        }
        
        
        public func estimateEnergy(_ method: String, parameters: [AnyObject] = [AnyObject](), transactionOptions: TronTransactionOptions? = nil) async throws -> BigUInt {
            let opts = transactionOptions ?? self.transactionOptions
            guard let request = contract.method(method, parameters: parameters, transactionOptions: opts) else {
                throw TronWebError.processingError(desc: "Invalid Contract.")
            }
            let res = try await self.provider.triggerConstantContract(request)
            return BigUInt(res.energyUsed)
        }
    }
    
}
