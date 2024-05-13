import UIKit

class CalendarViewController: UIViewController{
    let calendarView = UICalendarView()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func setupLabel() {
        let label = UILabel()
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth: CGFloat = 200
        let labelHeight: CGFloat = 100
        label.frame = CGRect(x: (screenWidth - labelWidth) / 2, y: 80, width: labelWidth, height: labelHeight)
        label.text = "하루읽기"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "HakgyoansimWoojuR", size: 50)
        label.textColor = UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1.0)
        self.view.addSubview(label)
    }


}
