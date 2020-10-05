//
//  CommentControl.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import Foundation

import UIKit

class CommentCounterControl: UIControl {
    var counterLabel = UILabel()
    var iconButton: UIButton = {
        let iconButton = UIButton()
        iconButton.setImage(UIImage(systemName: "message"), for: .normal)
        iconButton.addTarget(self, action: #selector(changeCounter(_:)), for: .touchUpInside)
        return iconButton
    }()
    
    var countOfComments : Int = 0 {
        didSet{
            counterLabel.text = String(countOfComments)
        }
    }
    
    
    weak var delegate: CommentCounterDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        counterLabel.backgroundColor = UIColor.white
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        
        counterLabel.adjustsFontSizeToFitWidth = true
        counterLabel.minimumScaleFactor = 0.5
        
        let stack = UIStackView()
        stack.addArrangedSubview(counterLabel)
        stack.addArrangedSubview(iconButton)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            counterLabel.trailingAnchor.constraint(equalTo: iconButton.leadingAnchor)
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc private func changeCounter(_ sender: UIButton) {
        counterLabel.text = String(countOfComments)
        
        delegate!.onButtonTapped()
    }
}
