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
        summaryLabel.text = User.instance.loaded_diary?.short_text
    }
    
    @IBOutlet weak var background: UILabel!
    // 기능 구현
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?

    let audioSubview = UIView()
    let summarySubview = UIView()

    let feedbackTitleLabel = UILabel()
    let feedbackSubtitleLabel = UILabel()
    let feedbackPlayButton = UIButton()
    let feedbackPauseButton = UIButton()
    let feedbackTimeSlider = UISlider()
    let feedbackCurrentTimeLabel = UILabel()
    let feedbackDurationLabel = UILabel()

    let diaryTitleLabel = UILabel()
    let diarySubtitleLabel = UILabel()
    let diaryPlayButton = UIButton()
    let diaryPauseButton = UIButton()
    let diaryTimeSlider = UISlider()
    let diaryCurrentTimeLabel = UILabel()
    let diaryDurationLabel = UILabel()
    
    
    @IBOutlet weak var summaryLabel: UILabel! // 요약 텍스트
    @IBOutlet weak var homeBtn: UIImageView!
    
    func Label_title() {
        let label = UILabel()
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth: CGFloat = 200
        let labelHeight: CGFloat = 100
        label.frame = CGRect(x: (screenWidth - labelWidth) / 2, y: 0, width: labelWidth, height: labelHeight)
        label.text = "하루읽기"
        label.textAlignment = .center
        label.font = UIFont(name: "HakgyoansimWoojuR", size: 37)
        label.textColor = UIColor.white
        self.view.addSubview(label)
    }

    func setupViews() {
        view.addSubview(audioSubview)

        configureAudioSection(titleLabel: feedbackTitleLabel, subtitleLabel: feedbackSubtitleLabel, titleText: "하루의 피드백", subtitleText: "하루의 피드백을 들어볼 수 있어요!", playButton: feedbackPlayButton, pauseButton: feedbackPauseButton, timeSlider: feedbackTimeSlider, yOffset: 20, audioFileName: "feedback_audio", currentTimeLabel: feedbackCurrentTimeLabel, durationLabel: feedbackDurationLabel)

        configureAudioSection(titleLabel: diaryTitleLabel, subtitleLabel: diarySubtitleLabel, titleText: "음성 일기", subtitleText: "일기 녹음 원본을 들어볼 수 있어요!", playButton: diaryPlayButton, pauseButton: diaryPauseButton, timeSlider: diaryTimeSlider, yOffset: 180, audioFileName: "diary_audio", currentTimeLabel: diaryCurrentTimeLabel, durationLabel: diaryDurationLabel)
    }

    func configureAudioSection(titleLabel: UILabel, subtitleLabel: UILabel, titleText: String, subtitleText: String, playButton: UIButton, pauseButton: UIButton, timeSlider: UISlider, yOffset: CGFloat, audioFileName: String, currentTimeLabel: UILabel, durationLabel: UILabel) {
        // Title and Subtitle Label setup
        setupLabel(label: titleLabel, text: titleText, yOffset: yOffset, fontSize: 18)
        setupLabel(label: subtitleLabel, text: subtitleText, yOffset: yOffset + 30, fontSize: 14)

        // Button and slider setup
        setupButton(button: playButton, icon: "play_icon", x: 50, yOffset: yOffset + 60, action: #selector(playAudio(_:)))
        setupButton(button: pauseButton, icon: "pause_icon", x: 100, yOffset: yOffset + 60, action: #selector(pauseAudio(_:)))

        // Time slider setup
        timeSlider.frame = CGRect(x: 20, y: yOffset + 100, width: view.frame.width - 40, height: 20)
        audioSubview.addSubview(timeSlider)
        
        playButton.accessibilityLabel = audioFileName
        pauseButton.accessibilityLabel = audioFileName

        // Time label setup
        setupLabel(label: currentTimeLabel, text: "00:00", yOffset: yOffset + 130, fontSize: 12)
        setupLabel(label: durationLabel, text: "00:00", yOffset: yOffset + 130, fontSize: 12)
        currentTimeLabel.textAlignment = .left
        durationLabel.textAlignment = .right
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
            button.setTitle(icon, for: .normal)
            button.backgroundColor = .blue
        }
        button.frame = CGRect(x: x, y: yOffset, width: 30, height: 30)
        button.addTarget(self, action: action, for: .touchUpInside)
        audioSubview.addSubview(button)
    }

    @objc func playAudio(_ sender: UIButton) {
        var player: AVAudioPlayer? = nil
        switch(sender.self.accessibilityLabel) {
        case "feedback_audio":
            player = User.instance.feedbackAudioPlayer
        case "diary_audio":
            player = User.instance.originalAudioPlayer
        default:
            player = nil
        }

        if player == nil {
            return
        }
        
        if audioPlayer != nil && audioPlayer?.isPlaying == true{
            audioPlayer?.stop()
        }
        

        audioPlayer = player  // 현재 재생 중인 플레이어 설정
        player?.play()
        startTimer()  // 타이머 시작
    }

    @objc func pauseAudio(_ sender: UIButton) {
        var player: AVAudioPlayer? = nil
        switch(sender.self.accessibilityLabel) {
        case "feedback_audio":
            player = User.instance.feedbackAudioPlayer
        case "diary_audio":
            player = User.instance.originalAudioPlayer
        default:
            player = nil
        }

        if player == nil {
            return
        }

        player?.pause()
        stopTimer()  // 타이머 중지
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc func updateTime() {
        if let player = audioPlayer {
            let currentTime = player.currentTime
            let duration = player.duration
            let currentTimeString = formatTime(time: currentTime)
            let durationString = formatTime(time: duration)

            if player == User.instance.feedbackAudioPlayer {
                feedbackCurrentTimeLabel.text = currentTimeString
                feedbackDurationLabel.text = durationString
            } else if player == User.instance.originalAudioPlayer {
                diaryCurrentTimeLabel.text = currentTimeString
                diaryDurationLabel.text = durationString
            }

            // 슬라이더 업데이트
            let progress = Float(currentTime / duration)
            if player == User.instance.feedbackAudioPlayer {
                feedbackTimeSlider.value = progress
            } else if player == User.instance.originalAudioPlayer {
                diaryTimeSlider.value = progress
            }
        }
    }

    func formatTime(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
