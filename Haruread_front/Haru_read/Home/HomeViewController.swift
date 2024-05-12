import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var diaryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Label_title()
        button()
    }
    
    func button(){
        let screenWidth = UIScreen.main.bounds.width
        self.diaryButton.layer.masksToBounds = true
        self.diaryButton.layer.cornerRadius = 20
        self.diaryButton.frame = CGRect(x: (screenWidth - 200) / 2, y: 650, width: 200, height: 50)
    }
    
    func Label_title(){
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
    }
    
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @IBAction func diaryButton(_ sender: Any) {
        let EmotionViewController = mystoryboard.instantiateViewController(withIdentifier: "EmotionViewController")
        // 모달 전환 스타일 설정
        EmotionViewController.modalTransitionStyle = .crossDissolve
        EmotionViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(EmotionViewController, animated: true, completion: nil)
    }
    
}
