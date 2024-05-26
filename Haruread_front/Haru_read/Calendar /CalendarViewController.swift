import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate {

    var calendar: FSCalendar!
    @IBOutlet weak var SelectBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 여백을 추가하여 캘린더의 크기와 위치 조정
        let padding: CGFloat = 20
        calendar = FSCalendar(frame: CGRect(x: padding, y: 200, width: self.view.bounds.width - (padding * 2), height: 300))
        view.addSubview(calendar)
        
        calendar.delegate = self
        
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        
        // 캘린더의 폰트 색상을 "81B787"로 변경
        calendar.appearance.headerTitleColor = UIColor(hex: "7BA880")
        calendar.appearance.weekdayTextColor = UIColor(hex: "7BA880")
        SelectBtn.layer.cornerRadius=20
        
    }
    
    // 캘린더 데이터 로드 함수
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = Calendar.current
        
        // 날짜에서 년, 월, 일 추출
        let year = dateFormatter.component(.year, from: date)
        let month = dateFormatter.component(.month, from: date)
        let day = dateFormatter.component(.day, from: date)
        
        // 년, 월, 일을 정수형으로 출력
        print("년: \(year), 월: \(month), 일: \(day)")
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
