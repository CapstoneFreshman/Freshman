import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    var calendar: FSCalendar!
    @IBOutlet weak var SelectBtn: UIButton!
    @IBOutlet weak var SelectDateLabel: UILabel!
    
    // 선택된 날짜의 년, 월, 일을 저장할 변수
    var selectedYear: Int = 0
    var selectedMonth: Int = 0
    var selectedDay: Int = 0
    
    // 감정을 저장할 딕셔너리
    var emotionData: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let padding: CGFloat = 20
        calendar = FSCalendar(frame: CGRect(x: padding, y: 260, width: self.view.bounds.width - (padding * 2), height: 300))
        view.addSubview(calendar)
        
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        
        // 캘린더의 폰트 색상을 "81B787"로 변경
        calendar.appearance.headerTitleColor = UIColor(hexString: "82A987")
        calendar.appearance.weekdayTextColor = UIColor(hexString: "82A987")
        SelectBtn.layer.cornerRadius = 20
        
        let today = Date()
        updateDateLabelWithDate(today)
        calendar.select(today)
        
        loadEmotionData()
    }
    
    // 라벨을 업데이트 하는 함수
    func updateDateLabelWithDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        SelectDateLabel.text = dateFormatter.string(from: date)
        
        let calendar = Calendar.current
        selectedYear = calendar.component(.year, from: date)
        selectedMonth = calendar.component(.month, from: date)
        selectedDay = calendar.component(.day, from: date)
        
        print("선택된 날짜 - 년: \(selectedYear), 월: \(selectedMonth), 일: \(selectedDay)")
    }
    
    // 캘린더에서 날짜를 선택할 때마다 위의 함수를 호출함으로써 라벨을 업데이트 함
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateDateLabelWithDate(date)
    }
    
    // 감정 캘린더 구현 -1
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateKey = dateFormatter.string(from: date)
        
        guard let emotion = emotionData[dateKey] else {
            // 기본 색상 사용 (선택된 색상이 없을 경우)
            return UIColor(hexString: "EEA0A0").withAlphaComponent(1.0)
        }
        
        // 선택된 날짜는 불투명으로
        switch emotion {
        case "테스트 감정":
            return UIColor(hexString: "81B787").withAlphaComponent(1.0)
        case "슬픔":
            return UIColor(hexString: "A0B1EE").withAlphaComponent(1.0)
        case "분노":
            return UIColor(hexString: "EEA0A0").withAlphaComponent(1.0)
        case "무감정":
            return UIColor(hexString: "D3D3D3").withAlphaComponent(1.0)
        default:
            return nil
        }
    }

    // 감정 캘린더 구현-2
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateKey = dateFormatter.string(from: date)
        
        guard let emotion = emotionData[dateKey] else {
            return nil
        }
        
        switch emotion {
        case "테스트 감정":
            return UIColor(hexString: "81B787").withAlphaComponent(0.5)  // 기본 색상 (반투명)
        case "슬픔":
            return UIColor(hexString: "A0B1EE").withAlphaComponent(0.5)
        case "분노":
            return UIColor(hexString: "EEA0A0").withAlphaComponent(0.5)
        case "무감정":
            return UIColor(hexString: "D3D3D3").withAlphaComponent(0.5)
        default:
            return nil
        }
    }

    let mystoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    // 일기 조회 버튼 동작
    @IBAction func GetDiaryBtn(_ sender: Any) {
        User.instance.get_date(year: selectedYear, month: selectedMonth, day: selectedDay) { [self] diary in
            print(String(format: "diary(%d-%d-%d) loaded", self.selectedYear, self.selectedMonth, self.selectedDay))
            debugPrint(diary)
            User.instance.loaded_diary = diary
            
            let diaryCheckViewController = mystoryboard.instantiateViewController(withIdentifier: "DiaryCheckViewController") as! DiaryCheckViewController
            diaryCheckViewController.modalTransitionStyle = .coverVertical
            diaryCheckViewController.modalPresentationStyle = .pageSheet
            self.present(diaryCheckViewController, animated: true, completion: nil)
            
        } onfailure: {
            print(String(format: "diary(%d-%d-%d) loading failed", self.selectedYear, self.selectedMonth, self.selectedDay))
        }
    }
    
    // 날짜 감정 가져오기
    func loadEmotionData() {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        
        guard let year = components.year, let month = components.month else {
            return
        }
        
        for day in 1...31 {
            User.instance.get_date(year: year, month: month, day: day) { diary in
                let dateKey = String(format: "%d-%02d-%02d", year, month, day)
                self.emotionData[dateKey] = diary.emo
                print("Loaded emotion for \(dateKey): \(diary.emo)")
                self.calendar.reloadData()
            } onfailure: {
                print(String(format: "diary(%d-%d-%d) loading failed", year, month, day))
            }
        }
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
