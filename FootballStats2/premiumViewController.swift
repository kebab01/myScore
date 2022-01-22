//
//  premiumViewController.swift
//  FootballStats2
//
//  Created by Thomas Karbowiak on 1/10/20.
//  Copyright © 2020 Thomas Karbowiak. All rights reserved.
//

import UIKit
import StoreKit

class premiumViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var btnRestore: UIButton!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblGameVersion: UILabel!
    
    let generator = UISelectionFeedbackGenerator()
    
    var myProduct: SKProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        purchaseButton.layer.cornerRadius = 30
        
        fetchProduct()
        
        generator.prepare()
        
        if premiumPurchase == true{
            purchaseButton.isUserInteractionEnabled = false
            purchaseButton.tintColor = .systemGray2
            btnRestore.tintColor = .systemGray2
            btnRestore.isUserInteractionEnabled = false
        }
        lblGameVersion.text = "V" + String(gameVersion) + "." + String(gameSubVersion)
    }
    
    @IBAction func didTapPurchase(_ sender: Any) {
            
//        guard let myProduct  = myProduct else{
//            return
//        }
//
//        if SKPaymentQueue.canMakePayments(){
//            let payment = SKPayment(product: myProduct)
//
//            SKPaymentQueue.default().add(self)
//            SKPaymentQueue.default().add(payment)
//        }
        
        myDefaults.set(true, forKey: "premium")
        premiumPurchase = true

    }

    @IBAction func didTapRestore(_ sender: Any) {
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    @IBAction func didTapReset(_ sender: Any) {
        myDefaults.set(false, forKey: "premium")
        premiumPurchase = false
    }
    @IBAction func didTapTwitter(_ sender: Any) {
        if let url = NSURL(string: "https://twitter.com/tomkar01") {
            UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)
        }
    }
    
    func fetchProduct(){
        let request = SKProductsRequest(productIdentifiers: ["com.ThomasKarbowiak.myScore1.premium"])
        request.delegate = self
        request.start()
    }
    
    func purchaseComplete(){
        
        premiumPurchase = true
        myDefaults.set(true, forKey: "premium")
        
        purchaseButton.isUserInteractionEnabled = false
        purchaseButton.tintColor = .systemGray2
        btnRestore.tintColor = .systemGray2
        btnRestore.isUserInteractionEnabled = false

        let alert = UIAlertController(title: "Thank You!", message: "Thank you for purchasing the premium version of myScore. Please restart app to enable premium features.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel) { (action) in

        }
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func restoreComplete(){
        
        premiumPurchase = true
        myDefaults.set(true, forKey: "premium")
        
        purchaseButton.isUserInteractionEnabled = false
        purchaseButton.tintColor = .systemGray2
        btnRestore.tintColor = .systemGray2
        btnRestore.isUserInteractionEnabled = false

        let alert = UIAlertController(title: "Welcome Back", message: "Welcome back to the premium version of myScore. Please restart the app to enable premium features again.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) in

        }
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
        
    }
    func errorAlert(){
        let alert = UIAlertController(title: "Failed", message: "An error occurd, please try again later", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { (action) in

        }
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first{
            myProduct = product
            print(product.productIdentifier)
            print(product.price)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.priceLocale)
            
            DispatchQueue.main.async {
                let price = product.price
                let currency = product.priceLocale.currencySymbol
                self.lblPrice.text = currency! + "" + price.stringValue
                    }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState {
            case .purchasing:
                // no op
                print("purchasing")
                break
            case .purchased:
                print("purchasing")
                purchaseComplete()
                print("purchase completed")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            case .restored:
                print("restored")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            case .failed, .deferred:
                
                print("failed")
                errorAlert()
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            default:
                print("else")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            }
        }
    }
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("purchasing")
        restoreComplete()
        print("purchase completed")
    }
    
}

