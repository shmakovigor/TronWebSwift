# TronWebSwift

Swift API Library for interacting with the TRON Network

## Install

- **Swift Package Manager**
```
    dependencies: [
         .package(url: "https://github.com/fish-yan/TronWebSwift.git")
    ]
```

- **Cocoapods**
```
    pod 'TronWebSwift', :git=>'https://github.com/fish-yan/TronWebSwift.git'
```

## Usage

### Generate Account

```swift
    let signer = try TronSigner.generate()
    // or try TronSigner(privateKey: privateKey)
    print(signer.privateKey)
    print(signer.publicKey)
    print(signer.address.address)
```

### TronWeb
```swift
    let provider = TronWebHttpProvider(URL(string: "https://tron.maiziqianbao.net")!)!
    let tronWeb = TronWeb(provider: provider)
```

- **Get Chain Parameter**
```swift
    let resp = try await self.provider.getChainParameters()
```

- **Get Account**
```swift
    let ownerAddress = TronAddress("TWXNtL6rHGyk2xeVR3QqEN9QGKfgyRTeU2")!
    let resp = try await self.provider.getAccount(ownerAddress)
```

- **Get Account Resource**
```swift
    let ownerAddress = TronAddress("TWXNtL6rHGyk2xeVR3QqEN9QGKfgyRTeU2")!
    let resp = try await self.provider.getAccountResource(ownerAddress)
```

- **Contracts Transfer**
```swift
    let toAddress = TronAddress("TVrXFXRHZtJaEWAgr5h5LChCLFWe2WjaiB")!
    let contractAddress = TronAddress("TEkxiTehnzSmSe2XqrBj4w32RUN966rdz8")
    
    guard let c = self.tronWeb.contract(TronWeb.Utils.trc20ABI, at: contractAddress) else {
        return
    }
    
    var opts = TronTransactionOptions.defaultOptions
    opts.ownerAddress = self.signer.address
    opts.feeLimit = 15000000
    
    let parameters = [toAddress, BigUInt(100)] as [AnyObject]
    let response = try await c.write("transfer", parameters: parameters, signer: self.signer, transactionOptions: opts)
```

- **Asset Transfer**
```swift
    let toAddress = TronAddress("TVrXFXRHZtJaEWAgr5h5LChCLFWe2WjaiB")!
    let amount: Int64 = 100
    let contract = Protocol_TransferContract.with {
        $0.ownerAddress = self.signer.address.data
        $0.toAddress = toAddress.data
        $0.amount = amount
    }
    let tx =  try await self.provider.createTransaction(contract)
    let signedTx = try tx.sign(self.signer)
    
    let response = try await self.provider.broadcastTransaction(signedTx)
```

- **TRC20Info**
```swift
    let contractAddress = TronAddress("TEkxiTehnzSmSe2XqrBj4w32RUN966rdz8")
    
    guard let c = self.tronWeb.contract(TronWeb.Utils.trc20ABI, at: contractAddress) else {
        return
    }
    
    let response = try await c.read("name")
    
    let response2 = try await c.read("balanceOf", parameters: [TronAddress("TWXNtL6rHGyk2xeVR3QqEN9QGKfgyRTeU2")!] as! [AnyObject])
```

- **Estimate Energy**
```swift
    let toAddress = TronAddress("TVrXFXRHZtJaEWAgr5h5LChCLFWe2WjaiB")!
    let contractAddress = TronAddress("TEkxiTehnzSmSe2XqrBj4w32RUN966rdz8")
    
    guard let c = self.tronWeb.contract(TronWeb.Utils.trc20ABI, at: contractAddress) else {
        return
    }
    
    var opts = TronTransactionOptions.defaultOptions
    opts.ownerAddress = TronAddress("TWXNtL6rHGyk2xeVR3QqEN9QGKfgyRTeU2")!
    
    let parameters = [toAddress, BigUInt(100)] as [AnyObject]
    let response = try await c.estimateEnergy("transfer", parameters: parameters, transactionOptions: opts)
```

- **Build Transaction**
```swift
    let ownerAddress = TronAddress("TWXNtL6rHGyk2xeVR3QqEN9QGKfgyRTeU2")!
    let toAddress = TronAddress("TVrXFXRHZtJaEWAgr5h5LChCLFWe2WjaiB")!
    let tx = try await self.tronWeb.build(toAddress, ownerAddress: ownerAddress, amount: BigUInt(100))
```

- **Decode Raw Transaction**
```swift
    let txRawHex = "0a02152822082dfe40c369deb19640a8fea0ea9c305ab101081f12ac010a31747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e54726967676572536d617274436f6e747261637412770a1541ac63d1d65800312f5946de9cc25bb8a10c3f49ec1215413487b63d30b5b2c87fb7ffa8bcfade38eaac1abe18e8072244a9059cbb000000000000000000000041da1ed679700721f29310112b0d7a4b690e14c63500000000000000000000000000000000000000000000000000000000000000647091b19dea9c309001c0c39307"
    let tx = try TronTransaction.with {
        $0.rawData = try TronTransaction.raw(serializedData: Data(hex: txRawHex))
    }
    let human = try tx.toHuman()
```

- **Decode Method Data**
```swift
    let returns = tronContract.decodeMethodData(Data(hex: "a9059cbb00000000000000000000004141a768c9797b8b1a1d41d25ba603f68326fcfc4000000000000000000000000000000000000000000000000000000000000186a0"))
    XCTAssertTrue(returns?.method == "transfer(address,uint256)")
    XCTAssertTrue(returns?.inputs?["_value"] as? BigUInt == BigUInt("100000"))
```