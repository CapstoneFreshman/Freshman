import UIKit
import AVFoundation

class DiaryCheckViewController: UIViewController {
    
    // main
    override func viewDidLoad() {
        super.viewDidLoad()
        Label_title()
        setupViews()
        setupConstraints()
        background.layer.cornerRadius=10
    }
    
    @IBOutlet weak var background: UILabel!
    // 기능 구현
    var audioPlayer: AVAudioPlayer?

    let audioSubview = UIView()
    let summarySubview = UIView()

    let feedbackTitleLabel = UILabel()
    let feedbackSubtitleLabel = UILabel()
    let feedbackPlayButton = UIButton()
    let feedbackPauseButton = UIButton()
    let feedbackTimeSlider = UISlider()

    let diaryTitleLabel = UILabel()
    let diarySubtitleLabel = UILabel()
    let diaryPlayButton = UIButton()
    let diaryPauseButton = UIButton()
    let diaryTimeSlider = UISlider()
    @IBOutlet weak var summaryText: UILabel! // 이거랑 연결해서 요약 내용 넣으면 됨!
    
    @IBOutlet weak var homeBtn: UIImageView!
    
    func Label_title() {
        let label = UILabel()
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth: CGFloat = 200
        let labelHeight: CGFloat = 100
        label.frame = CGRect(x: (screenWidth - labelWidth) / 2, y: 0, width: labelWidth, height: labelHeight) // 중앙 정렬
        label.text = "하루읽기"
        label.textAlignment = .center  // 텍스트를 중앙 정렬
        label.font = UIFont(name: "HakgyoansimWoojuR", size: 37)
        label.textColor = UIColor.white
           //label.textColor = UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1.0)  // 색상 코드 설정
           self.view.addSubview(label)
       }

    func setupViews() {
        // Setup audioSubview
        //audioSubview.backgroundColor = UIColor(hex: "F0F0F0")
        view.addSubview(audioSubview)

        configureAudioSection(titleLabel: feedbackTitleLabel, subtitleLabel: feedbackSubtitleLabel, titleText: "하루의 피드백", subtitleText: "하루의 피드백을 들어볼 수 있어요!", playButton: feedbackPlayButton, pauseButton: feedbackPauseButton, timeSlider: feedbackTimeSlider, yOffset: 20, audioFileName: "feedback_audio")

        configureAudioSection(titleLabel: diaryTitleLabel, subtitleLabel: diarySubtitleLabel, titleText: "음성 일기", subtitleText: "일기 녹음 원본을 들어볼 수 있어요!", playButton: diaryPlayButton, pauseButton: diaryPauseButton, timeSlider: diaryTimeSlider, yOffset: 180, audioFileName: "diary_audio")
    }

    func configureAudioSection(titleLabel: UILabel, subtitleLabel: UILabel, titleText: String, subtitleText: String, playButton: UIButton, pauseButton: UIButton, timeSlider: UISlider, yOffset: CGFloat, audioFileName: String) {
        // Title and Subtitle Label setup
        setupLabel(label: titleLabel, text: titleText, yOffset: yOffset, fontSize: 18)
        setupLabel(label: subtitleLabel, text: subtitleText, yOffset: yOffset + 30, fontSize: 14)

        // Button and slider setup
        setupButton(button: playButton, icon: "play_icon", x: 50, yOffset: yOffset + 60, action: #selector(playAudio(_:)))
        setupButton(button: pauseButton, icon: "pause_icon", x: 100, yOffset: yOffset + 60, action: #selector(pauseAudio(_:)))

        timeSlider.frame = CGRect(x: 20, y: yOffset + 100, width: view.frame.width - 40, height: 20)
        audioSubview.addSubview(timeSlider)

        playButton.accessibilityLabel = audioFileName
        pauseButton.accessibilityLabel = audioFileName
    }

    func setupLabel(label: UILabel, text: String, yOffset: CGFloat, fontSize: CGFloat) {
        label.text = text
        label.font = UIFont(name: "HakgyoansimWoojuR", size: fontSize)
        label.textColor = UIColor(hex: "774E3D")
        label.textAlignment = .center
        label.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 25)
        audioSubview.addSubview(label)
    }

    func setupButton(button: UIButton, icon: String, x: CGFloat, yOffset: CGFloat, action: Selector) {
        if let image = UIImage(named: icon) {
            button.setImage(image, for: .normal)
        } else {
            button.setTitle(icon, for: .normal)  // 이미지가 없을 경우 텍스트로 대체
            button.backgroundColor = .blue  // 배경색 추가로 버튼이 보이게 함
        }
        button.frame = CGRect(x: x, y: yOffset, width: 30, height: 30)
        button.addTarget(self, action: action, for: .touchUpInside)
        audioSubview.addSubview(button)
    }


    @objc func playAudio(_ sender: UIButton) {
        guard let url = Bundle.main.url(forResource: "Alarm01", withExtension: "wav") else {
                    print("Error: Audio file not found")
                    return
                }
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                } catch let error {
                    print("Error playing audio: \(error.localizedDescription)")
                }
    }

    @objc func pauseAudio(_ sender: UIButton) {
        audioPlayer?.pause()
    }

    func setupConstraints() {
        audioSubview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            audioSubview.leftAnchor.constraint(equalTo: view.leftAnchor),
            audioSubview.rightAnchor.constraint(equalTo: view.rightAnchor),
            audioSubview.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150)
        ])
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xff0000) >> 16) / 0xff
        let g = CGFloat((rgbValue & 0xff00) >> 8) / 0xff
        let b = CGFloat(rgbValue & 0xff) / 0xff
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
