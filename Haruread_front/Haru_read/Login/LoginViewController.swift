import UIKit

class LoginViewController: UIViewController {
    
    // UI Components
     let idTextField = UITextField()
     let passwordTextField = UITextField()
     let loginButton = UIButton()
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupUI()
         loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
     }
     
    func setupUI() {
            // View background and corner radius
            view.backgroundColor = UIColor(red: 1.0, green: 0.9804, blue: 0.9490, alpha: 1.0)
            view.layer.cornerRadius = 46
            view.clipsToBounds = true
        
            // 하루 읽기 로고
        let label = UILabel()
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth: CGFloat = 200
        let labelHeight: CGFloat = 100
        label.frame = CGRect(x: (screenWidth - labelWidth) / 2, y: 130, width: labelWidth, height: labelHeight) // 중앙 정렬
        label.text = "하루\n읽기"
        label.numberOfLines = 0  // 라벨의 줄 수를 무제한으로 설정
        label.textAlignment = .center  // 텍스트를 중앙 정렬
        label.font = UIFont(name: "HakgyoansimWoojuR", size: 50)
        label.textColor = UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1.0)  // 색상 코드 설정
        self.view.addSubview(label)


            // Setup idTextField
            idTextField.placeholder = "Id"
            idTextField.borderStyle = .none
            idTextField.frame = CGRect(x: 20, y: 300, width: 335, height: 40)
            idTextField.textAlignment = .left
            view.addSubview(idTextField)

            // Setup passwordTextField
            passwordTextField.placeholder = "Password"
            passwordTextField.borderStyle = .none
            passwordTextField.frame = CGRect(x: 20, y: 350, width: 335, height: 40)
            passwordTextField.isSecureTextEntry = true
            view.addSubview(passwordTextField)

            // Setup loginButton
            loginButton.setTitle("로그인", for: .normal)
            loginButton.backgroundColor = UIColor(red: 0.5059, green: 0.7176, blue: 0.5294, alpha: 1.0)  // 대체 색상 사용
            loginButton.frame = CGRect(x: (screenWidth - 200) / 2, y: 420, width: 200, height: 50)
            loginButton.layer.cornerRadius = 20
            //loginButton.addTarget(self, action: #selector(LoginButton(_:)), for: .touchUpInside)
            view.addSubview(loginButton)
        }
    

    
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

    @objc func loginButtonTapped(_ sender: UIButton) {
        
        User.instance.login(username: idTextField.text!, password: passwordTextField.text!){
            //onsuccess
            
            // HomeViewController로 전환
            let homeViewController = self.mystoryboard.instantiateViewController(withIdentifier: "TabViewController")
            homeViewController.modalPresentationStyle = .fullScreen
            self.present(homeViewController, animated: true, completion: nil)
        }
    }
    @IBAction func SignupButton(_ sender: Any) {
        let SignupViewController = mystoryboard.instantiateViewController(withIdentifier: "SignupViewController")
        // 모달 전환 스타일 설정
        SignupViewController.modalTransitionStyle = .crossDissolve
        SignupViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(SignupViewController, animated: true, completion: nil)
    }
        
    
}



