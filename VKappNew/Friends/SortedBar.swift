//
//  SortedBar.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class SorterBarControl: UIControl {
    private var letters = [String]() {
        didSet{
            if oldValue != letters{
                setupView()
            }
        }
    }
    private var choosedLetter = ""
    
    private var letterButtons = [UIButton]()
    private var stackView = UIStackView()
    
    func configure(users : ResultsForUser?){
        self.letters = calculateSectionNames(users: users)
    }
    
    func setupView() {
        letterButtons.removeAll()
        for letter in letters {
            let button = UIButton(type: .system)
            button.setTitle(letter, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.addTarget(self, action: #selector(selectLetter(_:)), for: .touchUpInside)
            self.letterButtons.append(button)
        }
        stackView.removeFromSuperview()
        stackView = UIStackView(arrangedSubviews: self.letterButtons)
        
        self.addSubview(stackView)
        stackView.spacing = 1
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    @objc private func selectLetter(_ sender: UIButton) {
        if let index = letterButtons.firstIndex(of: sender){
            choosedLetter = letters[index]
            sendActions(for: .valueChanged)
        }
    }
    
    func calculateSectionNames(users : ResultsForUser?) -> [String]{
        
        let allUserLastNameFirstLetters : [String] = users!.map({
            if let first = $0.lastName.first {
                return String(first)
            } else {
                return ""
            }
        })
        return Array<String>(Set(allUserLastNameFirstLetters)).sorted()
    }
    
    func getLetter(for index: Int) -> String{
        self.letters[index]
    }
    func getIndex(for letter: String) -> Int {
        letters.firstIndex(where: {$0 == letter}) ?? 0
    }
    
    func getIndexForChoosedLetter() -> Int {
        letters.firstIndex(where: {$0 == self.choosedLetter}) ?? 0
    }
    
    func getLettersCount() -> Int{
        letters.count
    }
}

