import UIKit

class MypageViewController: UIViewController {

    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @IBOutlet weak var UIVew: UIView!
    @IBOutlet weak var NameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        NameLabel.text = "새로운 텍스트"
        setupUIVew()
        addSeparatorLine()
    }
    @IBAction func page_button(_ sender: Any) {
        let HaruSettingViewController = mystoryboard.instantiateViewController(withIdentifier: "HaruSettingViewController")
        // 모달 전환 스타일 설정
        HaruSettingViewController.modalTransitionStyle = .crossDissolve
        HaruSettingViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(HaruSettingViewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var gender: UILabel!

    func setupUIVew() {
           UIVew.layer.cornerRadius = 20
           UIVew.layer.borderWidth = 2
           UIVew.layer.borderColor = UIColor(hex: "7BA880").cgColor
           UIVew.backgroundColor = .clear
       }
    func addSeparatorLine() {
            let separatorLine = UIView()
            separatorLine.backgroundColor = UIColor(hex: "7BA880")
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            UIVew.addSubview(separatorLine)
            
            NSLayoutConstraint.activate([
                separatorLine.centerYAnchor.constraint(equalTo: UIVew.centerYAnchor),
                separatorLine.leadingAnchor.constraint(equalTo: UIVew.leadingAnchor, constant: 10),
                separatorLine.trailingAnchor.constraint(equalTo: UIVew.trailingAnchor, constant: -10),
                separatorLine.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    
}
