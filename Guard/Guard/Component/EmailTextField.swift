//
//  EmailTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/29.
//

import UIKit

open class EmailTextField: AccountTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        keyboardType = .emailAddress
        let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
        let text: String = NSLocalizedString("authing_email", bundle: Bundle(for: Self.self), comment: "")
        self.placeholder = "\(sInput)\(text)"
    }
}