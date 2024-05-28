import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance {

    var calendar: FSCalendar!
    @IBOutlet weak var SelectBtn: UIButton!
    @IBOutlet weak var SelectDateLabel: UILabel!
    // 선택된 날짜의 년, 월, 일을 저장할 변수
    var selectedYear: Int = 0
    var selectedMonth: Int = 0
    var selectedDay: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 여백을 추가하여 캘린더의 크기와 위치 조정
        let padding: CGFloat = 20
        calendar = FSCalendar(frame: CGRect(x: padding, y: 260, width: self.view.bounds.width - (padding * 2), height: 300))
        view.addSubview(calendar)
        
        calendar.delegate = self
        
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        
        // 캘린더의 폰트 색상을 "81B787"로 변경
        calendar.appearance.headerTitleColor = UIColor(hex: "82A987")
        calendar.appearance.weekdayTextColor = UIColor(hex: "82A987")
        SelectBtn.layer.cornerRadius=20
        
        updateDateLabelWithDate(Date())
        
    }
    
    func updateDateLabelWithDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"  // 날짜 형식 지정
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        SelectDateLabel.text = dateFormatter.string(from: date)
        
        // 연, 월, 일을 변수에 저장
        let calendar = Calendar.current
        selectedYear = calendar.component(.year, from: date)
        selectedMonth = calendar.component(.month, from: date)
        selectedDay = calendar.component(.day, from: date)

        // 변수 값 출력 (디버깅 용도)
        print("선택된 날짜 - 년: \(selectedYear), 월: \(selectedMonth), 일: \(selectedDay)")
            
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateDateLabelWithDate(date)  // 선택한 날짜로 라벨 업데이트
        
    }
        
    
    /*
    // 캘린더 데이터 로드 함수
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = Calendar.current
        
        // 날짜에서 년, 월, 일 추출
        let year = dateFormatter.component(.year, from: date)
        let month = dateFormatter.component(.month, from: date)
        let day = dateFormatter.component(.day, from: date)
        
        // 년, 월, 일을 정수형으로 출력
        print("년: \(year), 월: \(month), 일: \(day)")
    }*/
    
    
    
    
    // FSCalendarDelegateAppearance 메서드
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor(hex: "EEA0A0") // 선택된 날짜 색상
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) {
            return UIColor(hex: "A0B1EE") // 오늘 날짜 색상
        }
        return nil
    }
    
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @IBAction func GetDiaryBtn(_ sender: Any) {
        
        User.instance.get_date(year: selectedYear, month: selectedMonth, day: selectedDay){ [self]diary in
            print(String(format: "diary(%d-%d-%d) loaded", self.selectedYear, self.selectedMonth, self.selectedDay))
            debugPrint(diary)
            User.instance.loaded_diary = diary
            
            let diaryCheckViewController = mystoryboard.instantiateViewController(withIdentifier: "DiaryCheckViewController") as! DiaryCheckViewController
            // 모달 전환 스타일 설정
            diaryCheckViewController.modalTransitionStyle = .coverVertical
            diaryCheckViewController.modalPresentationStyle = .pageSheet
            // 모달 방식으로 뷰 컨트롤러를 표시
            self.present(diaryCheckViewController, animated: true, completion: nil)
            
        }onfailure: {
            print(String(format: "diary(%d-%d-%d) loading failed", self.selectedYear, self.selectedMonth, self.selectedDay))
        }
        // 함수호출
        
        // 화면전환
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
