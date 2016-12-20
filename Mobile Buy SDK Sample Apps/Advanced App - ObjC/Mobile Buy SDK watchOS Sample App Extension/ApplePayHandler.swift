//
//  ApplePayHandler.swift
//  Mobile Buy SDK Advanced Sample
//
//  Created by Shopify.
//  Copyright (c) 2016 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Buy
import WatchKit

class ApplePayHandler: NSObject, BUYPaymentProviderDelegate {
    
    private var checkout: BUYCheckout!
    private var client: BUYClient!
    private var dataProvider: DataProvider!
    private var interfaceController: WKInterfaceController!
    private var paymentController: BUYPaymentController!
    private var paymentProvider: BUYApplePayPaymentProvider!
    
    init(dataProvider: DataProvider, interfaceController: WKInterfaceController) {
        super.init()
        self.dataProvider = dataProvider
        self.interfaceController = interfaceController
        self.interfaceController.pushController(withName: "LoadingInterfaceController", context: nil)
        self.paymentController = BUYPaymentController.init()
        self.setupPaymentProvider()
    }
    
    private func setupPaymentProvider() {
        self.client = self.dataProvider.getClient()
        self.paymentProvider = BUYApplePayPaymentProvider.init(client: self.client, merchantID: self.dataProvider.merchantId)
        self.paymentProvider.delegate = self
        self.paymentController.add(self.paymentProvider)
    }
    
    func checkoutWithApplePay(variant: BUYProductVariant) {
        if self.isApplePayAvailable() {
            self.checkout = self.checkoutWithVariant(variant: variant)
            self.startApplePayCheckout(checkout: self.checkout)
        }
    }
    
    private func startApplePayCheckout(checkout: BUYCheckout) {
        if ((self.paymentProvider.delegate != nil) && (self.paymentProvider.delegate?.responds(to: #selector(BUYPaymentProviderDelegate.paymentProvider(_:wantsPaymentControllerPresented:))))!) {
                self.paymentController.start(checkout, withProviderType: BUYApplePayPaymentProviderId)
        }
    }
    
    private func checkoutWithVariant(variant: BUYProductVariant) -> BUYCheckout {
        let modelManager = self.client.modelManager
        let cart = modelManager.insertCart(withJSONDictionary: nil)
        cart?.add(variant)
        return modelManager.checkout(with: cart!)
    }
    
    private func isApplePayAvailable() -> Bool {
        return self.paymentProvider.isAvailable
    }
    
    func paymentProviderWantsControllerDismissed(_ provider: BUYPaymentProvider) {
        self.interfaceController.pop()
    }
    
    func paymentProvider(_ provider: BUYPaymentProvider, wantsPaymentControllerPresented controller: PKPaymentAuthorizationController) {
        controller.present(completion: nil)
    }
}
