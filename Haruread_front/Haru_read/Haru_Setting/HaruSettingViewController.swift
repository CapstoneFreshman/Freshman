//
//  HaruSettingViewController.swift
//  Haru_read
//
//  Created by 전서현 on 5/6/24.
//

import UIKit


class HaruSettingViewController: UIViewController {
    weak var delegate: HaruSettingDelegate?
    private var selectedGender: String?
    private var selectedAgeGroup: String?
    private var selectedSpeakingStyle: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        button()
    }
    
    
    // 하루세팅부분코드 - 스토리보드가 아닌 코드로 전부 구현했음
    private func setupUI() {
        view.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 242/255, alpha: 1.0)  // 배경색 변경
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)

        var lastView: UIView? = nil
        let sections = [
            ("성별", ["남자", "여자"]),
            ("연령대", ["유년층", "청소년층", "성인층", "노년층"]),
            ("발화스타일", ["구연체", "낭독체", "대화체", "독백체", "애니체", "중계체", "친절체"])
        ]

        for (index, (title, options)) in sections.enumerated() {
            let sectionView = createSection(title: title, options: options, yOffset: CGFloat(index) * 100)
            scrollView.addSubview(sectionView)
            sectionView.frame.origin.y = lastView?.frame.maxY ?? 130
            lastView = sectionView
        }

        if let lastView = lastView {
            scrollView.contentSize = CGSize(width: view.frame.width, height: lastView.frame.maxY + 20)
        }
    }

    private func createSection(title: String, options: [String], yOffset: CGFloat) -> UIView {
        let sectionView = UIView(frame: CGRect(x: 0, y: yOffset, width: view.frame.width, height: 50 + CGFloat(options.count/2) * 35))
        sectionView.autoresizingMask = [.flexibleWidth]

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1)  // 텍스트 색상 변경
        titleLabel.frame = CGRect(x: 20, y: 5, width: view.frame.width - 40, height: 20)
        sectionView.addSubview(titleLabel)

        let buttonHeight: CGFloat = 30
        let buttonSpacing: CGFloat = 10
        let buttonWidth = (view.frame.width - 60) / 2

        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.setTitleColor(UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1), for: .normal)  // 버튼 텍스트 색상 변경
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.cornerRadius = 5
            button.titleLabel?.font = UIFont(name: "HakgyoansimWoojuR", size: 14)
            let row = index / 2
            let column = index % 2
            button.frame = CGRect(
                x: 20 + CGFloat(column) * (buttonWidth + 20),
                y: titleLabel.frame.maxY + 5 + CGFloat(row) * (buttonHeight + buttonSpacing),
                width: buttonWidth,
                height: buttonHeight)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            sectionView.addSubview(button)
        }

        return sectionView
    }

    // 버튼을 눌렀을 때 동작하는 함수
    @objc func buttonTapped(_ sender: UIButton) {
        // 모든 버튼을 초기 상태로 되돌립니다.
        if let buttons = sender.superview?.subviews.compactMap({ $0 as? UIButton }) {
            for button in buttons {
                button.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 242/255, alpha: 1.0) // 초기 배경색 설정
                button.setTitleColor(UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1), for: .normal) // 초기 텍스트 색상 설정
            }
        }

        // 선택된 버튼의 스타일을 변경합니다.
        sender.backgroundColor = UIColor(red: 0.5059, green: 0.7176, blue: 0.5294, alpha: 1.0) // 버튼 눌렀을 때의 색상 변경
        sender.setTitleColor(.white, for: .normal)
        
        // 데이터 전달
        guard let section = sender.superview else { return }

            // 선택된 값 저장
            if section.tag == 0 { // 성별 섹션
                selectedGender = sender.titleLabel?.text
            } else if section.tag == 1 { // 연령대 섹션
                selectedAgeGroup = sender.titleLabel?.text
            } else if section.tag == 2 { // 발화 스타일 섹션
                selectedSpeakingStyle = sender.titleLabel?.text
            }
    }
    
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    @IBOutlet weak var settingButton: UIButton!
    @IBAction func actionButton(_ sender: Any) {
        if let gender = selectedGender, let ageGroup = selectedAgeGroup, let speakingStyle = selectedSpeakingStyle {
              delegate?.settingsDidUpdate(gender: gender, ageGroup: ageGroup, speakingStyle: speakingStyle)
          }
          dismiss(animated: true, completion: nil)
    }
    func button(){
        let screenWidth = UIScreen.main.bounds.width
        self.settingButton.layer.masksToBounds = true
        self.settingButton.layer.cornerRadius = 20
        self.settingButton.frame = CGRect(x: (screenWidth - 200) / 2, y: 650, width: 200, height: 50)
    }
    
    protocol HaruSettingDelegate: AnyObject {
        func settingsDidUpdate(gender: String, ageGroup: String, speakingStyle: String)
    }



}
