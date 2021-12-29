//
//  PasswordTextField.swift
//  Guard
//
//  Created by Lance Mao on 2021/12/14.
//

import UIKit

open class PasswordTextField: BasePasswordTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let sInput: String = NSLocalizedString("authing_please_input", bundle: Bundle(for: Self.self), comment: "")
        let sPassword: String = NSLocalizedString("authing_password", bundle: Bundle(for: Self.self), comment: "")
        self.placeholder = "\(sInput)\(sPassword)"
    }
}
