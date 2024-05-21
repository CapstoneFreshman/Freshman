
import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate {
    
    var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize and configure the calendar
        calendar = FSCalendar(frame: CGRect(x: 0, y: 200, width: self.view.bounds.width, height: 300))
        view.addSubview(calendar)
        
        // Set the calendar delegate
        calendar.delegate = self
        
        // Additional calendar configuration (optional)
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
    @IBAction func DiaryBtn(_ sender: Any) {
        // Storyboard와 ViewController의 Identifier 확인 필요
        let mystoryboard = UIStoryboard(name: "Main", bundle: nil)
 
        let DiaryCheckViewController = mystoryboard.instantiateViewController(withIdentifier: "DiaryCheckViewController")
        // 모달 전환 스타일 설정
        DiaryCheckViewController.modalTransitionStyle = .crossDissolve
        DiaryCheckViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(DiaryCheckViewController, animated: true, completion: nil)
    }
    
}
