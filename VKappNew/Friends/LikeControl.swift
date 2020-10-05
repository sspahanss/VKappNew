//
//  LikeControl.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class LikeCounterControl: UIControl {
    var counterLabel = UILabel()
    var iconButton: UIButton = {
        let iconButton = UIButton()
        iconButton.setImage(UIImage(systemName: "heart"), for: .normal)
        iconButton.addTarget(self, action: #selector(changeCounter(_:)), for: .touchUpInside)
        return iconButton
    }()
    
    private var countOfLikes : Int = 0 {
        didSet{
            counterLabel.text = String(countOfLikes)
        }
    }
    
    private var isLiked : Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        counterLabel.backgroundColor = UIColor.white
        setupView()
    }
    
    func configure(count: Int, isLiked : Bool?){
        if let isLiked = isLiked {
            self.isLiked = isLiked
        }
        self.countOfLikes = count
    }
    
    private func setupView() {
        backgroundColor = .clear
        iconButton.setImage(UIImage(systemName: isLiked ? "heart.fill": "heart"), for: .normal)
        iconButton.tintColor = isLiked ? .red : .blue
        
        
        counterLabel.adjustsFontSizeToFitWidth = true
        counterLabel.minimumScaleFactor = 0.5
        
        
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
        self.reloadInputViews()
    }
    
    @objc private func changeCounter(_ sender: UIButton) {
        if isLiked {
            countOfLikes -= 1
        } else {
            countOfLikes += 1
        }
        isLiked.toggle()
        iconButton.setImage(UIImage(systemName: isLiked ? "heart.fill": "heart"), for: .normal)
        iconButton.tintColor = isLiked ? .red : UIColor(named: "VK")
        UIView.transition(with: counterLabel,
                          duration: 0.75,
                          options: .transitionFlipFromTop,
                          animations: { [weak self] in
                            self!.iconButton.isUserInteractionEnabled = false
                            self!.counterLabel.text = String(self!.countOfLikes)
        }, completion : { _ in
            self.iconButton.isUserInteractionEnabled = true
        })
        
    }
}
