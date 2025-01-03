import Foundation
import BigInt

public typealias TronTransaction = Protocol_Transaction
public typealias TronTransferContract = Protocol_TransferContract
public typealias TronTransferAssetContract = Protocol_TransferAssetContract
public typealias TronTriggerSmartContract = Protocol_TriggerSmartContract

public enum TronWebError: LocalizedError {
    case invalidProvider
    case nodeError(desc:String)
    case processingError(desc:String)
    case unknown(message: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidProvider:
            return "TronWeb.Error.invalidProvider"
        case .nodeError(let desc):
            return desc
        case .processingError(let desc):
            return desc
        case .unknown(let message):
            return message
        }
    }
}
    
public struct TronWeb {
    public let provider: TronWebHttpProvider
    let transactionOptions: TronTransactionOptions?
    
    public init(provider: TronWebHttpProvider, options: TronTransactionOptions? = nil) {
        self.provider = provider
        self.transactionOptions = options
    }
    
    public func build(_ toAddress: TronAddress, ownerAddress: TronAddress, amount: BigUInt) async throws -> TronTransaction {
        let contract = Protocol_TransferContract.with {
            $0.ownerAddress = ownerAddress.data
            $0.toAddress = toAddress.data
            $0.amount = Int64(amount.description) ?? 0
        }
        return try await self.provider.createTransaction(contract)
    }
    
    public func build(_ toAddress: TronAddress, ownerAddress: TronAddress, assetName: String, amount: BigUInt) async throws -> TronTransaction {
        let contract = Protocol_TransferAssetContract.with {
            $0.ownerAddress = ownerAddress.data
            $0.assetName = assetName.data(using: .utf8)!
            $0.toAddress = toAddress.data
            $0.amount = Int64(amount.description) ?? 0
        }
        return try await self.provider.transferAsset(contract)
    }
}
