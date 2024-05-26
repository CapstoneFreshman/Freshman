import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var NicknameField: UITextField!
    @IBOutlet weak var IdField: UITextField!
    @IBOutlet weak var PasswordField1: UITextField!
    @IBOutlet weak var PasswordField2: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var NicknameErrorLabel: UILabel!
    @IBOutlet weak var EmailErrorLabel: UILabel!
    @IBOutlet weak var PasswordErrorLabel2: UILabel!
    @IBOutlet weak var IdErrorLabel: UILabel!
    @IBOutlet weak var PasswordErrorLabel1: UILabel!
    @IBOutlet weak var SetupBtn: UIButton!
    @IBOutlet weak var PreBtn: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        SetupBtn.layer.cornerRadius=5
        // PreBtn을 사용자 상호작용 가능하게 설정
            PreBtn.isUserInteractionEnabled = true
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(preBtnTapped))
            PreBtn.addGestureRecognizer(tapGesture)
    }
    
    func setupUI() {
        setupTextField(IdField)
        setupTextField(PasswordField1)
        setupTextField(PasswordField2)
        setupTextField(EmailField)
        setupTextField(NicknameField)
        // 에러 라벨 초기화
        PasswordErrorLabel2.isHidden = true
        EmailErrorLabel.isHidden = true
        NicknameErrorLabel.isHidden = true
        IdErrorLabel.isHidden = true
        PasswordErrorLabel1.isHidden = true
    }
  
    func setupTextField(_ textField: UITextField) {
        // 테두리 제거
        textField.borderStyle = .none
        
        // 라인 추가
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor(red: 129/255, green: 183/255, blue: 135/255, alpha: 1.0).cgColor
        
        textField.layer.addSublayer(bottomLine)
    }
    
    @IBAction func SetupBtnTap(_ sender: Any) {
        let nickname = NicknameField.text ?? ""
        let id = IdField.text ?? ""
        let password1 = PasswordField1.text ?? ""
        let password2 = PasswordField2.text ?? ""
        let email = EmailField.text ?? ""
        
        var isValid = true
        
        // 닉네임 확인
        if nickname.isEmpty {
            NicknameErrorLabel.text = "입력하지 않았습니다"
            NicknameErrorLabel.textColor = .red
            NicknameErrorLabel.isHidden = false
            isValid = false
        } else {
            NicknameErrorLabel.isHidden = true
        }
        
        // 아이디 확인
        if id.isEmpty {
            IdErrorLabel.text = "입력하지 않았습니다"
            IdErrorLabel.textColor = .red
            IdErrorLabel.isHidden = false
            isValid = false
        } else {
            IdErrorLabel.isHidden = true
        }
        
        // 비밀번호 확인
        if password1.isEmpty {
            PasswordErrorLabel1.text = "입력하지 않았습니다"
            PasswordErrorLabel1.textColor = .red
            PasswordErrorLabel1.isHidden = false
            isValid = false
        } else {
            PasswordErrorLabel1.isHidden = true
        }
        
        if password1 != password2 {
            PasswordErrorLabel2.text = "비밀번호가 일치하지 않습니다"
            PasswordErrorLabel2.textColor = .red
            PasswordErrorLabel2.isHidden = false
            isValid = false
        } else {
            PasswordErrorLabel2.isHidden = true
        }
        
        // 이메일 형식 확인
        if email.isEmpty {
            EmailErrorLabel.text = "입력하지 않았습니다"
            EmailErrorLabel.textColor = .red
            EmailErrorLabel.isHidden = false
            isValid = false
        }
         else {
            EmailErrorLabel.isHidden = true
        }
        
        if isValid {
            showSuccessAlert()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func showSuccessAlert() {
        let alertController = UIAlertController(title: "회원가입 성공", message: "가입에 성공하셨습니다", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Home으로 이동", style: .default) { _ in
            self.navigateToNextController()
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    func navigateToNextController() {
        let homeViewController = mystoryboard.instantiateViewController(withIdentifier: "TabViewController")
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
        
    }
    
    @objc func preBtnTapped() {
        let LoginViewController = mystoryboard.instantiateViewController(withIdentifier: "LoginViewController")
        // 모달 전환 스타일 설정
        LoginViewController.modalTransitionStyle = .crossDissolve
        LoginViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(LoginViewController, animated: true, completion: nil)
    }
}
