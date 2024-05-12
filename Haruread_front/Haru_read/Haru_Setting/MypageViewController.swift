//
//  Setting1ViewController.swift
//  Haru_read
//
//  Created by 전서현 on 5/6/24.
//

import UIKit
import AudioKit

class MypageViewController: UIViewController {


    
    @IBOutlet weak var NameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        Label_title()
        NameLabel.text = "새로운 텍스트"
        drawLine()
      
    }
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @IBAction func page_button(_ sender: Any) {
        let HaruSettingViewController = mystoryboard.instantiateViewController(withIdentifier: "HaruSettingViewController")
        // 모달 전환 스타일 설정
        HaruSettingViewController.modalTransitionStyle = .crossDissolve
        HaruSettingViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(HaruSettingViewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var gender: UILabel!
    
    //func button(){
     //   let screenWidth = UIScreen.main.bounds.width
      //  self.haruset_button.layer.masksToBounds = true
       // self.haruset_button.layer.cornerRadius = 20
        //self.haruset_button.frame = CGRect(x: (screenWidth - 200) / 2, y: 650, width: 200, height: 50)
   // }
   
    
    func Label_title(){
        let label = UILabel()
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth: CGFloat = 200
        let labelHeight: CGFloat = 100
        label.frame = CGRect(x: (screenWidth - labelWidth) / 2, y: 80, width: labelWidth, height: labelHeight) // 중앙 정렬
        label.text = "하루읽기"
        label.numberOfLines = 0  // 라벨의 줄 수를 무제한으로 설정
        label.textAlignment = .center  // 텍스트를 중앙 정렬
        label.font = UIFont(name: "HakgyoansimWoojuR", size: 50)
        label.textColor = UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1.0)  // 색상 코드 설정
        self.view.addSubview(label)
    }
    
    func drawLine() {
        let linePath1 = UIBezierPath()
        let linePath2 = UIBezierPath()

        linePath1.move(to: CGPoint(x: 10, y: 190))
        linePath1.addLine(to: CGPoint(x: view.bounds.width - 10, y: 190))
        linePath2.move(to: CGPoint(x: 10, y: 320))
        linePath2.addLine(to: CGPoint(x: view.bounds.width - 10, y: 320))

        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.path = linePath1.cgPath
        shapeLayer1.strokeColor = UIColor.black.cgColor
        shapeLayer1.lineWidth = 1
        shapeLayer1.fillColor = UIColor.clear.cgColor
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.path = linePath2.cgPath
        shapeLayer2.strokeColor = UIColor.black.cgColor
        shapeLayer2.lineWidth = 1
        shapeLayer2.fillColor = UIColor.clear.cgColor

        view.layer.addSublayer(shapeLayer1)
        view.layer.addSublayer(shapeLayer2)
    }
    

 
}
