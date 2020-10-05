//
//  ShareControl.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class ShareCounterControl: UIControl {
    var counterLabel = UILabel()
    var iconButton: UIButton = {
        let iconButton = UIButton()
        iconButton.setImage(UIImage(systemName: "arrow.up.right.circle"), for: .normal)
        iconButton.addTarget(self, action: #selector(changeCounter(_:)), for: .touchUpInside)
        return iconButton
    }()
    
    var countOfShares : Int = 0 {
        didSet{
            counterLabel.text = String(countOfShares)
        }
    }
    var isLiked : Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        counterLabel.font = .systemFont(ofSize: CGFloat(20))
        
        let stack = UIStackView()
        stack.addArrangedSubview(counterLabel)
        stack.addArrangedSubview(iconButton)
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
        if isLiked {
            countOfShares -= 1
        } else {
            countOfShares += 1
        }
        isLiked.toggle()
        counterLabel.text = String(countOfShares)
    }
}

