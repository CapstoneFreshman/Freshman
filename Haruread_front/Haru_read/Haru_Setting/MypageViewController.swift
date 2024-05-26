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
        load_profile()
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        load_profile()
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
    
    @IBOutlet weak var old: UILabel!
    
    @IBOutlet weak var style: UILabel!
    
    @IBOutlet weak var id: UILabel!
    
    @IBOutlet weak var email: UILabel!
    
    
    public func load_profile() {
        if User.instance.is_authenticated
        {
            if User.instance.profile == nil{
                print("User Profile not loaded yet")
                User.instance.get_profile(onsuccess: load_profile, onfailure: {print("load_profile get_profile failed")})
                return
            }
            
            
            print("MypageViewController.swift: load_profile(profile loaded)")
            old.text = User.instance.profile?.old
            style.text = User.instance.profile?.style
            gender.text = User.instance.profile?.gender
            NameLabel.text = User.instance.profile?.nick_name
            id.text = User.instance.profile?.id
            email.text = User.instance.profile?.email
            
        }
    }
    
    
    //func button(){
     //   let screenWidth = UIScreen.main.bounds.width
      //  self.haruset_button.layer.masksToBounds = true
       // self.haruset_button.layer.cornerRadius = 20
        //self.haruset_button.frame = CGRect(x: (screenWidth - 200) / 2, y: 650, width: 200, height: 50)
   // }
   
        
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
