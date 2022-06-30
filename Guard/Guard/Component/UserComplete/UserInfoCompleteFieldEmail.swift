//
//  UserInfoCompleteFieldEmail.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/21.
//

open class UserInfoCompleteFieldEmail: UserInfoCompleteFieldForm {
    
    var emailTextField: EmailTextField = EmailTextField()
    var emailCodeTextField: VerifyCodeTextField = VerifyCodeTextField()
    let getCodeButton: GetEmailCodeButton = GetEmailCodeButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func setup() {
        super.setup()
        
        getCodeButton.scene = "CHANGE_EMAIL"
        
        addSubview(emailTextField)
        addSubview(emailCodeTextField)
        addSubview(getCodeButton)

        emailTextField.borderStyle = .roundedRect
        emailTextField.font = UIFont.systemFont(ofSize: 14)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        emailTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2).isActive = true
        
        emailCodeTextField.borderStyle = .roundedRect
        emailCodeTextField.font = UIFont.systemFont(ofSize: 14)
        emailCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        emailCodeTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        emailCodeTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        emailCodeTextField.trailingAnchor.constraint(equalTo: getCodeButton.leadingAnchor, constant: -8).isActive = true
        emailCodeTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12).isActive = true
        
        getCodeButton.backgroundColor = Const.Color_Button_Gray
        getCodeButton.loadingLocation = 1
        getCodeButton.loadingColor = Const.Color_Authing_Main
        getCodeButton.setTitleColor(Const.Color_Authing_Main, for: .normal)
        getCodeButton.titleLabel?.font = getCodeButton.titleLabel?.font.withSize(12)
        getCodeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        getCodeButton.translatesAutoresizingMaskIntoConstraints = false
        getCodeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        getCodeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        getCodeButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12).isActive = true
        getCodeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    public override func getHeight() ->CGFloat {
        return 128
    }
    
    public func getEmail() -> String? {
        return emailTextField.text
    }
    
    public func getCode() -> String? {
        return emailCodeTextField.text
    }
    
    public override func setFormData(_ data: NSDictionary) {
        super.setFormData(data)
    }
}
