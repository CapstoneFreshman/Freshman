import UIKit

class EmotionViewController: UIViewController {
    
    var buttons: [UIButton] = []
    let emotions = ["기쁨", "슬픔", "분노", "무감정"]
    let buttonColors = [
        UIColor(red: 0.76, green: 0.82, blue: 0.87, alpha: 1.0),
        UIColor(red: 0.87, green: 0.89, blue: 0.91, alpha: 1.0),
        UIColor(red: 0.93, green: 0.95, blue: 0.95, alpha: 1.0),
        UIColor(red: 0.79, green: 0.93, blue: 0.90, alpha: 1.0)
    ]
    var selectedEmotion: String?  // 선택된 감정을 저장할 변수 (이거쓰셈)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        view.backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0)  // Pale background
    }
    
    func setupButtons() {
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 10
        let screenWidth = UIScreen.main.bounds.width
        
        for (index, emotion) in emotions.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(emotion, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = buttonColors[index % buttonColors.count]
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.layer.cornerRadius = 25
            button.clipsToBounds = true
            
            let buttonWidth = (screenWidth - 60) / 2
            let row = index / 2
            let column = index % 2
            button.frame = CGRect(x: 20 + CGFloat(column) * (buttonWidth + 20), y: CGFloat(row) * (buttonHeight + buttonSpacing) + 300, width: buttonWidth, height: buttonHeight)
            button.addTarget(self, action: #selector(emotionButtonTapped(_:)), for: .touchUpInside)
            self.view.addSubview(button)
            buttons.append(button)
        }
    }
    
    @objc func emotionButtonTapped(_ sender: UIButton) {
        resetButtons()
        sender.backgroundColor = .darkGray
        selectedEmotion = sender.title(for: .normal)
        print("선택된 감정: \(selectedEmotion ?? "")")
    }
    
    func resetButtons() {
        for (index, button) in buttons.enumerated() {
            button.backgroundColor = buttonColors[index % buttonColors.count]
        }
    }
    
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @IBAction func selectButton(_ sender: Any) {
        let EmotionViewController = mystoryboard.instantiateViewController(withIdentifier: "RecordViewController")
        // 모달 전환 스타일 설정
        EmotionViewController.modalTransitionStyle = .crossDissolve
        EmotionViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(EmotionViewController, animated: true, completion: nil)
    }
    
}
