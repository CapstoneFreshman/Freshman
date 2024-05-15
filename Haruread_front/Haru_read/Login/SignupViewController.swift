//
//  SignupViewController.swift
//  Haru_read
//
//  Created by 전서현 on 5/5/24.
//

import UIKit

class SignupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var IdField: UITextField!
    
    @IBOutlet weak var PasswordField1: UITextField!
    
    @IBOutlet weak var PasswordField2: UITextField!
    
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var NicknameField: UITextField!
    
    
    
    
    
    @IBAction func SignupButtonHandler(_ sender: Any) {
        User.instance.signup(username: IdField.text!, password1: PasswordField1.text!, password2: PasswordField2.text!, email: EmailField.text!, nick_name: NicknameField.text!)
    }
    
    

}
