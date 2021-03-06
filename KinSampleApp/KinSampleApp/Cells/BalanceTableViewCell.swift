//
//  BalanceTableViewCell.swift
//  KinSampleApp
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class BalanceTableViewCell: KinClientCell {
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pendingBalanceLabel: UILabel!
    @IBOutlet weak var pendingBalanceActivityIndicator: UIActivityIndicatorView!
    var balance: Decimal = 0
    var pendingBalance: Decimal = 0

    var ongoingRequests = 0 {
        didSet {
            self.refreshButton.isEnabled = ongoingRequests == 0
        }
    }

    let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = ""

        return f
    }()

    override var kinAccount: KinAccount! {
        didSet {
            refreshBalance(self)
        }
    }

    @IBAction func refreshBalance(_ sender: Any) {
        ongoingRequests += 1
        balanceActivityIndicator.startAnimating()
        kinAccount.balance { [weak self] balance, error in
            DispatchQueue.main.async {
                self?.balanceActivityIndicator.stopAnimating()
                defer {
                    self?.ongoingRequests -= 1
                }

                guard let balance = balance,
                    error == nil else {
                        self?.balanceLabel.text = "Error"
                        return
                }

                self?.balance = balance
                if let formattedBalance = self?.numberFormatter.string(from: balance as NSDecimalNumber) {
                    self?.balanceLabel.text = "\(formattedBalance) KIN"
                }
            }
        }

        ongoingRequests += 1
        pendingBalanceActivityIndicator.startAnimating()
        kinAccount.pendingBalance { [weak self] pBalance, error in
            DispatchQueue.main.async {
                self?.pendingBalanceActivityIndicator.stopAnimating()
                defer {
                    self?.ongoingRequests -= 1
                }

                guard let pBalance = pBalance,
                    error == nil else {
                        self?.pendingBalanceLabel.text = "Error"
                        return
                }

                self?.pendingBalance = pBalance
                if let formattedPendingBalance = self?.numberFormatter.string(from: pBalance as NSDecimalNumber) {
                    self?.pendingBalanceLabel.text = "\(formattedPendingBalance) KIN"
                }
            }
        }
    }
}
