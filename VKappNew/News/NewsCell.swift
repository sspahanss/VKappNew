//
//  NewsCell.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var avatarView: AvatarView!
    @IBOutlet private weak var authorNameLabel: UILabel!
    @IBOutlet private weak var createDateLabel: UILabel!
    
    @IBOutlet private weak var messageLabel: UILabel!
    
    @IBOutlet private weak var likeCounterControl: LikeCounterControl!
    @IBOutlet private weak var photoCollectionView: UICollectionView!
    
    @IBOutlet private weak var viewsCounter: UILabel!
    
    @IBOutlet private weak var commentsCounter: CommentCounterControl!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var hideButtonBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var heightCollectionConstraint: NSLayoutConstraint!
    @IBOutlet var msgLabelHeightConstraintGreaterThen: NSLayoutConstraint!
    @IBOutlet var msgLabelHeightConstraintLessThen: NSLayoutConstraint!
    
    weak var photoDelegate: NewsPhotoCollectionViewDelegate?
    weak var delegate: CommentCounterDelegate?
    
    var photos = [UIImage]()
    var isButtonHidden = false
    
    @IBAction func touchHideButton(_ sender: Any) {
        hideButton.isHidden = true
        hideButtonBottomContraint.constant = 0
        msgLabelHeightConstraintLessThen.isActive = false
        msgLabelHeightConstraintGreaterThen.isActive = true
        isButtonHidden.toggle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageLabel.sizeToFit()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.isUserInteractionEnabled = true
        photoCollectionView.reloadData()
        
        commentsCounter.delegate = self
        if photos.isEmpty {
            heightCollectionConstraint.constant = 0
        }
        if msgLabelHeightConstraintLessThen != nil {
            msgLabelHeightConstraintLessThen.isActive = false
        }
        if messageLabel.text != nil {
            if messageLabel.bounds.height > 200 {
                msgLabelHeightConstraintLessThen.isActive = true
                msgLabelHeightConstraintGreaterThen.isActive = false
                if !isButtonHidden {
                    hideButton.isHidden = false
                    hideButtonBottomContraint.constant = 30
                }
            } else {
                hideButton.isHidden = true
                hideButtonBottomContraint.constant = 0
            }
        }
        
    }
    
    func configure(for currentNews : News, with photos : [UIImage], by author : (name: String, photo: UIImage?)){
        authorNameLabel.text = author.name
        if let authorImage = author.photo {
            avatarView.imageView.image = authorImage
        }
        createDateLabel.text = formatTimeAgo(date: currentNews.date)
        messageLabel.text = currentNews.text
        setLikeCounterControl(count: currentNews.getLikesInfo().0, isLiked: currentNews.getLikesInfo().1)
        commentsCounter.counterLabel.text = "\(currentNews.comments?.count ?? 0)"
        viewsCounter.text = "\(currentNews.views?.count ?? 0)"
        
        self.photos = photos
    }
    
    func setLikeCounterControl(count : Int, isLiked : Bool? = nil){
        likeCounterControl.configure(count: count, isLiked: isLiked)
    }
    
    private func formatTimeAgo(date: Int) -> String {
        let date = NSDate(timeIntervalSince1970: Double(date))
        let result = Date().timeIntervalSince(date as Date)
        return result.toRelativeDateTime()
    }
}
extension NewsTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { photos.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! NewsPhotoCollectionViewCell
        cell.photoImageView.image = photos[indexPath.row]
        cell.isUserInteractionEnabled = true
        cell.delegate = self
        return cell
    }
    
}

extension NewsTableViewCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = collectionView.frame.width / 2
        return CGSize(width: width, height: width)
    }
}

protocol CommentCounterDelegate: class {
    func onButtonTapped()
}

protocol NewsPhotoCollectionViewDelegate: class {
    func onButtonTapped(_ data : UIImage)
}

extension NewsTableViewCell : CommentCounterDelegate {
    func onButtonTapped(){
        delegate!.onButtonTapped()
    }
}
extension NewsTableViewCell : NewsPhotoCollectionViewDelegate {
    func onButtonTapped(_ data : UIImage){
        photoDelegate!.onButtonTapped(data)
    }
}

