import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var audioFile: URL!
    var progressTimer: Timer?
        
    let timeRecordSelector: Selector = #selector(RecordViewController.updateRecordTime)
    @IBOutlet var RecordBtn: UIButton! // 녹음 시작 버튼
    @IBOutlet var RecordTimeLB: UILabel! // 녹음 시간 라벨
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRecord() // 초기화 코드를 viewDidLoad에서 호출
    }
    
    // 녹음 파일 초기화
    func initRecord() {
        selectAudioFile()
        let recordSettings = [
            AVFormatIDKey: kAudioFormatLinearPCM, // PCM 형식을 사용하여 녹음
            AVSampleRateKey: 44100.0, // 샘플레이트
            AVNumberOfChannelsKey: 2, // 채널 수
            AVLinearPCMBitDepthKey: 16, // 비트 심도
            AVLinearPCMIsBigEndianKey: false, // 엔디언
            AVLinearPCMIsFloatKey: false // 부동소수점 여부
        ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
        } catch let error as NSError {
            print("Error-initRecord: \(error)")
        }
        
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        
        RecordTimeLB.text = convertNSTimeIntervalToString(0)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord)
        } catch let error as NSError {
            print("Error-setCategory: \(error)")
        }
        
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("Error-setActive: \(error)")
        }
    }
    
    // 오디오 파일 선택
    func selectAudioFile() {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        audioFile = cacheDirectory.appendingPathComponent("recordFile.wav") // 파일 확장자를 .wav로 변경
        print("녹음파일위치 : \(audioFile.path)")
    }
    
    // 00:00 형태의 문자열로 변환함
    func convertNSTimeIntervalToString(_ time: TimeInterval) -> String {
        let min = Int(time / 60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        return strTime
    }

    @IBAction func RecordBtn(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return } // 안전하게 언래핑
        if title == "Record" { // 녹음을 시작함
            audioRecorder.record()
            sender.setTitle("Stop", for: .normal)
            progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeRecordSelector, userInfo: nil, repeats: true)
        } else { // 녹음을 중지함
            audioRecorder.stop()
            if let timer = progressTimer { // progressTimer가 nil이 아닐 때만 invalidate 호출
                timer.invalidate()
            }
            progressTimer = nil
            sender.setTitle("Record", for: .normal)
        }
    }
    
    // 0.1초마다 호출되며 녹음 시간을 표시함
    @objc func updateRecordTime() {
        RecordTimeLB.text = convertNSTimeIntervalToString(audioRecorder.currentTime)
    }
}
