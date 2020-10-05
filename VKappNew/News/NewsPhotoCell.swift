//
//  NewsPhotoCell.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class NewsPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView! {
        didSet{
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            photoImageView.isUserInteractionEnabled = true
            photoImageView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    weak var delegate: NewsPhotoCollectionViewDelegate?
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        delegate!.onButtonTapped(photoImageView.image!)
    }
}

