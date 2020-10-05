//
//  AvatarView.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class AvatarView: UIImageView {
    var imageView = UIImageView()
    var shadowView = UIView()
    
    @IBInspectable var radius: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
            configureShadowView()
        }
    }
    
    @IBInspectable var opacity: Float = 2 {
        didSet {
            setNeedsDisplay()
            configureShadowView()
        }
    }
    
    @IBInspectable var color: UIColor = .black {
        didSet {
            setNeedsDisplay()
            configureShadowView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        configureShadowView()
        configureImageView()
        
    }
    
    private func configureShadowView(){
        shadowView.layer.shadowColor = color.cgColor
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 50, height: 50), cornerRadius: frame.size.width / 2).cgPath
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowOpacity = opacity
        shadowView.layer.shadowRadius = radius
        addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        setConstraints(shadowView)
        
    }
    
    private func configureImageView(){
        let cornerRadius = frame.size.width / 2
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        setConstraints(imageView)
    }
    
    private func setConstraints(_ view : UIView){
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        UIView.animate(
            withDuration: 1,
            animations: { [weak self] in
                self!.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        
        UIView.animate(
            withDuration: 1,
            delay: 1,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0.1,
            options: [],
            animations: { [weak self] in
                self!.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
}
