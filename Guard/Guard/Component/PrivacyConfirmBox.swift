//
//  PrivacyConfirmBox.swift
//  Guard
//
//  Created by Lance Mao on 2022/2/24.
//

import CoreGraphics

open class PrivacyToast: UIView {
    
    let privacyBox: PrivacyConfirmBox = PrivacyConfirmBox()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
                
        let maskView = UIView.init()
        maskView.backgroundColor = UIColor.black
        maskView.alpha = 0.5
        self.addSubview(maskView)
        maskView.translatesAutoresizingMaskIntoConstraints = false
        maskView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        maskView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        maskView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        maskView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        let privacyView = UIView()
        privacyView.backgroundColor = UIColor.white
        privacyView.layer.cornerRadius = 8
        self.addSubview(privacyView)
        privacyView.translatesAutoresizingMaskIntoConstraints = false
        privacyView.widthAnchor.constraint(equalToConstant: Const.SCREEN_WIDTH - 50).isActive = true
        privacyView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        privacyView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        privacyView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        privacyBox.fontSize = 16
        privacyView.addSubview(privacyBox)
        privacyBox.translatesAutoresizingMaskIntoConstraints = false
        privacyBox.leadingAnchor.constraint(equalTo: privacyView.leadingAnchor, constant: 20).isActive = true
        privacyBox.trailingAnchor.constraint(equalTo: privacyView.trailingAnchor, constant: -20).isActive = true
        privacyBox.heightAnchor.constraint(equalToConstant: 20).isActive = true
        privacyBox.topAnchor.constraint(equalTo: privacyView.topAnchor, constant: (160 - 56)/2 - 10).isActive = true

        let line = UIView.init()
        line.backgroundColor = UIColor.init(red: 0.906, green: 0.906, blue: 0.906, alpha: 1)
        privacyView.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.leadingAnchor.constraint(equalTo: privacyView.leadingAnchor, constant: 0).isActive = true
        line.trailingAnchor.constraint(equalTo: privacyView.trailingAnchor, constant: 0).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line.bottomAnchor.constraint(equalTo: privacyView.bottomAnchor, constant: -56).isActive = true

        let line2 = UIView.init()
        line2.backgroundColor = UIColor.init(red: 0.906, green: 0.906, blue: 0.906, alpha: 1)
        privacyView.addSubview(line2)
        line2.translatesAutoresizingMaskIntoConstraints = false
        line2.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        line2.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 0).isActive = true
        line2.bottomAnchor.constraint(equalTo: privacyView.bottomAnchor, constant: 0).isActive = true
        line2.centerXAnchor.constraint(equalTo: privacyView.centerXAnchor).isActive = true

        let cancelButton = UIButton.init()
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor.init(red: 0.11, green: 0.13, blue: 0.16, alpha: 1.0), for: .normal)
        cancelButton.addTarget(self, action:#selector(cancelClick(sender:)), for: .touchUpInside)
        privacyView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.trailingAnchor.constraint(equalTo: line2.leadingAnchor, constant: 0).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        cancelButton.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 0).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: privacyView.bottomAnchor, constant: 0).isActive = true
        
        let doneButton = UIButton.init()
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.setTitle("同意", for: .normal)
        doneButton.setTitleColor(UIColor.init(red: 0.13, green: 0.35, blue: 0.9, alpha: 1.0), for: .normal)
        doneButton.addTarget(self, action:#selector(doneClick(sender:)), for: .touchUpInside)
        privacyView.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.trailingAnchor.constraint(equalTo: privacyView.trailingAnchor, constant: 0).isActive = true
        doneButton.leadingAnchor.constraint(equalTo: line2.trailingAnchor, constant: 0).isActive = true
        doneButton.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 0).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: privacyView.bottomAnchor, constant: 0).isActive = true
        
    }

    @objc func cancelClick(sender: UIButton) {
        self.removeSelf()
    }
    
    @objc func doneClick(sender: UIButton) {
        self.privacyBox.isChecked = true
        
        if let privacy: PrivacyConfirmBox = Util.findView(self.viewController?.view ?? UIView(), viewClass: PrivacyConfirmBox.self) {
            privacy.isChecked = true
        }
        
        self.removeSelf()
    }
    
    func removeSelf() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    class func showToast(viewController: UIViewController) {
        
        let toast = PrivacyToast()
        viewController.view.addSubview(toast)
        toast.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        }
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.leftAnchor.constraint(equalTo: viewController.view.leftAnchor, constant: 0).isActive = true
        toast.topAnchor.constraint(equalTo: viewController.view.topAnchor, constant: 0).isActive = true
        toast.rightAnchor.constraint(equalTo: viewController.view.rightAnchor, constant: 0).isActive = true
        toast.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: 0).isActive = true
    }
}

open class PrivacyConfirmBox: UIView, UITextViewDelegate {
    
    let size = 15.0
    
    var fontSize = 12.0
    
    let imageUnchecked = UIImage(named: "authing_checkbox_unchecked", in: Bundle(for: PrivacyConfirmBox.self), compatibleWith: nil)
    let imageChecked = UIImage(named: "authing_checkbox_checked", in: Bundle(for: PrivacyConfirmBox.self), compatibleWith: nil)
    let checkBox: UIButton = UIButton()
    let checkBoxImageView: UIImageView = UIImageView()
    let label: UITextView = UITextView()
    
    public var isChecked: Bool = false {
        didSet {
            if (isChecked) {
                checkBoxImageView.image = imageChecked
            } else {
                checkBoxImageView.image = imageUnchecked
            }
        }
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        isHidden = true
        addSubview(checkBoxImageView)
        addSubview(checkBox)
        addSubview(label)
        
        checkBoxImageView.image = imageUnchecked
        checkBoxImageView.translatesAutoresizingMaskIntoConstraints = false
        checkBoxImageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        checkBoxImageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        checkBoxImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        checkBoxImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        checkBox.addTarget(self, action:#selector(onClick(sender:)), for: .touchUpInside)
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        checkBox.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkBox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        checkBox.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        checkBox.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        label.delegate = self
        label.isEditable = false
        label.isScrollEnabled = false
        label.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        DispatchQueue.main.async() {
            Util.getConfig(self) { config in
                self._setup(config)
            }
        }
    }
    
    private func _setup(_ config: Config?) {
        let regBtn = Util.findView(self, viewClass: RegisterButton.self)
        let loginBtn = Util.findView(self, viewClass: LoginButton.self)
        
        var loc: Int = 0
        if (regBtn != nil) {
            loc = 1
        } else if (loginBtn != nil) {
            loc = 2
        }
        
        var shouldShow = false
        let lang = Util.getLangHeader()
        if let agreements = config?.agreements {
            for agreement in agreements {
                if (lang == agreement["lang"] as? String) {
                    let availableAt = agreement["availableAt"] as? Int
                    if (availableAt == nil) {
                        continue
                    }
                    if (availableAt! == 2 || (loc == 1 && availableAt! == 0) || (loc == 2 && availableAt! == 1)) {
                        if let title = agreement["title"] as? String {
                            let t = "<meta charset=\"utf-8\">\n" + title
                            let data = t.data(using: .utf8)!
                            let attributedString = try? NSMutableAttributedString(
                                data: data,
                                options: [.documentType: NSMutableAttributedString.DocumentType.html],
                                documentAttributes: nil)
                            let para = NSMutableParagraphStyle.init()
                            attributedString?.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: NSMakeRange(0, attributedString?.length ?? 0))
                            attributedString?.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: fontSize), range:  NSMakeRange(0, attributedString?.length ?? 0))

                            self.label.attributedText = attributedString
                            shouldShow = true
                        }
                        break
                    }
                }
            }
        }
        
        if (shouldShow) {
            isHidden = false
        } else {
            constraints.forEach { constraint in
                if (constraint.firstAttribute == .height) {
                    constraint.constant = 0
                    self.updateConstraints()
                }
            }
        }
    }
    
    @objc private func onClick(sender: UIButton) {
        isChecked = !isChecked
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        label.selectedTextRange = nil
    }
}
