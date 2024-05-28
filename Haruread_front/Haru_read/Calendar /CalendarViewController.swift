
import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate {
    
    var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize and configure the calendar
        calendar = FSCalendar(frame: CGRect(x: 0, y: 200, width: self.view.bounds.width, height: 300))
        view.addSubview(calendar)
        
        calendar.delegate = self
        
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
    }
    
    // 캘린더 데이터 로드 함수!!!!!!
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
