import UIKit

class EmotionViewController: UIViewController {
    
    @IBOutlet weak var SelectBtn: UIButton!
    
    //감정 이미지
    @IBOutlet weak var happyBtn: UIImageView!
    @IBOutlet weak var sadBtn: UIImageView!
    @IBOutlet weak var noemotionBtn: UIImageView!
    @IBOutlet weak var angryBtn: UIImageView!
    
    // 감정 라벨
    @IBOutlet weak var happyLb: UILabel!
    @IBOutlet weak var sadLb: UILabel!
    @IBOutlet weak var angryLb: UILabel!
    @IBOutlet weak var noemotionLb: UILabel!
 
    var selectedEmotion: String?  // 선택된 감정을 저장할 변수
    
    @IBOutlet weak var DateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupButtons()
        view.backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0)  // Pale background
        SelectBtn.layer.cornerRadius = 20
        setCurrentDateTime()
        setupGestureRecognizers()
    }
    
    func setupGestureRecognizers() {
        guard let happyBtn = happyBtn,
              let sadBtn = sadBtn,
              let angryBtn = angryBtn,
              let noemotionBtn = noemotionBtn else {
            print("하나 이상의 아웃렛이 nil입니다. 아웃렛 연결을 확인하세요.")
            return
        }

        // 각 이미지 뷰에 탭 인식기를 추가합니다.
        let tapHappy = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let tapSad = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let tapAngry = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let tapNoemotion = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        // 이미지 뷰가 사용자의 인터랙션을 받을 수 있도록 설정합니다.
        happyBtn.isUserInteractionEnabled = true
        sadBtn.isUserInteractionEnabled = true
        angryBtn.isUserInteractionEnabled = true
        noemotionBtn.isUserInteractionEnabled = true

        // 각 이미지 뷰에 탭 인식기를 연결합니다.
        happyBtn.addGestureRecognizer(tapHappy)
        sadBtn.addGestureRecognizer(tapSad)
        angryBtn.addGestureRecognizer(tapAngry)
        noemotionBtn.addGestureRecognizer(tapNoemotion)

        // 초기 라벨 투명도 설정
        happyLb.alpha = 0.5
        sadLb.alpha = 0.5
        angryLb.alpha = 0.5
        noemotionLb.alpha = 0.5
        happyBtn.alpha = 0.5
        sadBtn.alpha = 0.5
        angryBtn.alpha = 0.5
        noemotionBtn.alpha = 0.5
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        resetLabelsOpacity() // 모든 라벨의 투명도를 리셋합니다.

        // 탭된 이미지 뷰에 따라 해당하는 라벨의 투명도를 조정하고, 감정을 저장합니다.
        switch imageView {
        case happyBtn:
            happyLb.alpha = 1.0
            happyBtn.alpha = 1.0
            selectedEmotion = "기쁨"
        case sadBtn:
            sadLb.alpha = 1.0
            sadBtn.alpha = 1.0
            selectedEmotion = "슬픔"
        case angryBtn:
            angryLb.alpha = 1.0
            angryBtn.alpha = 1.0
            selectedEmotion = "분노"
        case noemotionBtn:
            noemotionLb.alpha = 1.0
            noemotionBtn.alpha = 1.0
            selectedEmotion = "무감정"
        default:
            break
        }
        print("선택된 감정: \(selectedEmotion ?? "없음")")
    }

    func resetLabelsOpacity() {
        // 모든 라벨의 투명도를 초기 상태(0.5)로 설정합니다.
        happyLb?.alpha = 0.5
        sadLb?.alpha = 0.5
        angryLb?.alpha = 0.5
        noemotionLb?.alpha = 0.5
        happyBtn?.alpha = 0.5
        sadBtn?.alpha = 0.5
        angryBtn?.alpha = 0.5
        noemotionBtn?.alpha = 0.5
    }
    
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @IBAction func selectButton(_ sender: Any) {
        let recordViewController = mystoryboard.instantiateViewController(withIdentifier: "RecordViewController")
        // 모달 전환 스타일 설정
        recordViewController.modalTransitionStyle = .crossDissolve
        recordViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(recordViewController, animated: true, completion: nil)
        
        }
    func setCurrentDateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")  // 한국 시간대 설정
        let currentDate = Date()
        DateLabel.text = dateFormatter.string(from: currentDate)
    }
}
