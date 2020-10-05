//
//  FriendCell.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    static let identifier = "userCell"
    
    @IBOutlet private weak var userLabel: UILabel!
    @IBOutlet private weak var photoView: AvatarView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userLabel.font = .systemFont(ofSize: CGFloat(16))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with user: User, image: UIImage?) {
        userLabel.text = "\(user.firstName) \(user.lastName)"
        if let image = image {
            photoView.imageView.image = image
        }
        
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.8,
            options:.curveEaseInOut,
            animations: { [weak self] in
                self!.frame.origin.x+=70
        })
    }
}
