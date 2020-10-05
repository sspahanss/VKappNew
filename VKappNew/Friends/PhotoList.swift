//
//  PhotoList.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit
import Alamofire
import RealmSwift

class PhotoListViewController: UIViewController {
    private var userId = 0
    private var photos : Results<Photo>?{
        didSet{
            imageView.photos = photos
            if let unwrappedArray = photos, !unwrappedArray.isEmpty{
                if let photo = unwrappedArray[0].getPhotoBigSize() {
                    imageView.image = photo
                }
            }
        }
    }
    private var newsPhoto : UIImage?
    private let photoInteractiveTransition = PhotoInteractiveTransition()
    
    @IBOutlet var imageView: PhotoListImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if userId != 0 {
            photos = RealmService.getPhotos(for: userId)
            DataService.getAllPhotosForUser(userId: userId,
                                            completion: {
                                                [weak self] array in
                                                self?.photos = array
                }
            )
        }
        if let newsPhoto = newsPhoto {
            imageView.image = newsPhoto
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    func configure(for id: Int, with fullName: String) {
        userId = id
        title = fullName
    }
    
    func configureForNews(for data : UIImage) {
        imageView = PhotoListImageView(image: data)
        newsPhoto = data
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openFullPhotoOnViewSegue" {
            let photoVC = segue.destination as! FullPhotoViewController
            photoVC.photo = photos![imageView.activePhotoIndex]
            photoVC.transitioningDelegate = self
            self.photoInteractiveTransition.viewController = photoVC
        }
    }
    
    @objc func onTap(_ recognizer: UIPanGestureRecognizer) {
        if newsPhoto == nil {
            performSegue(withIdentifier: "openFullPhotoOnViewSegue", sender: self)
        }
    }
}

extension PhotoListViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FullPhotoAnimationDismissController(endFrame: imageView.frame)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FullPhotoAnimationController(originFrame: imageView.frame)
    }
}


