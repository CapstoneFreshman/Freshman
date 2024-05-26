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
        Label_title()
        load_profile()
        drawLine()
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        load_profile()
    }
    
    
    
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @IBAction func page_button(_ sender: Any) {
        let HaruSettingViewController = mystoryboard.instantiateViewController(withIdentifier: "HaruSettingViewController")
        // 모달 전환 스타일 설정
        HaruSettingViewController.modalTransitionStyle = .crossDissolve
        HaruSettingViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(HaruSettingViewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var gender: UILabel!   
    
    @IBOutlet weak var old: UILabel!
    
    @IBOutlet weak var style: UILabel!
    
    @IBOutlet weak var id: UILabel!
    
    public func load_profile() {
        if User.instance.is_authenticated
        {
            if User.instance.profile == nil{
                print("User Profile not loaded yet")
                User.instance.get_profile(onsuccess: load_profile, onfailure: {print("load_profile get_profile failed")})
                return
            }
            
            
            old.text = User.instance.profile?.old
            style.text = User.instance.profile?.style
            gender.text = User.instance.profile?.gender
            NameLabel.text = User.instance.profile?.nick_name
            id.text = User.instance.profile?.id
            
        }
    }
    
    
    //func button(){
     //   let screenWidth = UIScreen.main.bounds.width
      //  self.haruset_button.layer.masksToBounds = true
       // self.haruset_button.layer.cornerRadius = 20
        //self.haruset_button.frame = CGRect(x: (screenWidth - 200) / 2, y: 650, width: 200, height: 50)
   // }
   
    
    func Label_title(){
        let label = UILabel()
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth: CGFloat = 200
        let labelHeight: CGFloat = 100
        label.frame = CGRect(x: (screenWidth - labelWidth) / 2, y: 80, width: labelWidth, height: labelHeight) // 중앙 정렬
        label.text = "하루읽기"
        label.numberOfLines = 0  // 라벨의 줄 수를 무제한으로 설정
        label.textAlignment = .center  // 텍스트를 중앙 정렬
        label.font = UIFont(name: "HakgyoansimWoojuR", size: 50)
        label.textColor = UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1.0)  // 색상 코드 설정
        self.view.addSubview(label)
    }
    
    func drawLine() {
        let linePath1 = UIBezierPath()
        let linePath2 = UIBezierPath()

        linePath1.move(to: CGPoint(x: 10, y: 190))
        linePath1.addLine(to: CGPoint(x: view.bounds.width - 10, y: 190))
        linePath2.move(to: CGPoint(x: 10, y: 320))
        linePath2.addLine(to: CGPoint(x: view.bounds.width - 10, y: 320))

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
