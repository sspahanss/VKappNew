//
//  FriendSearchBar.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class FriendsSearchBar: UISearchBar {
    var hiddenView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addHiddenViewForTap()
    }
    
    @objc func searchWasTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.setPositionAdjustment(.init(horizontal: 0, vertical: 0), for: .search)
        self.setShowsCancelButton(true, animated: true)
        if let cancelButton = self.value(forKey: "cancelButton") as? UIButton {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cancelButtonWasTapped(tapGestureRecognizer:)))
            cancelButton.addGestureRecognizer(tapGestureRecognizer)
        }
        becomeFirstResponder()
        hiddenView.removeFromSuperview()
    }
    
    func addHiddenViewForTap(){
        hiddenView = UIView()
        hiddenView.backgroundColor = .clear
        self.addSubview(hiddenView)
        hiddenView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hiddenView.topAnchor.constraint(equalTo: topAnchor),
            hiddenView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hiddenView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hiddenView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchWasTapped(tapGestureRecognizer:)))
        hiddenView.addGestureRecognizer(tapGestureRecognizer)
        self.setPositionAdjustment(.init(horizontal: self.frame.width / 2 - 20, vertical: 0), for: .search)
    }
    @objc func cancelButtonWasTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.text = ""
        self.setShowsCancelButton(false, animated: true)
        self.endEditing(true)
        addHiddenViewForTap()
    }
}
