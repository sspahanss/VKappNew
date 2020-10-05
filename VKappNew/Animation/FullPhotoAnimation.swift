//
//  FullPhotoAnimation.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class FullPhotoAnimationController:  NSObject, UIViewControllerAnimatedTransitioning {
    
    private let originFrame: CGRect
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.viewController(forKey: .to) as? FullPhotoViewController,
            let fromVC = (transitionContext.viewController(forKey: .from)!.children.first as? CustomNavigationController)?.children.last as? PhotoListViewController,
            let snapshot = fromVC.imageView.snapshotView(afterScreenUpdates: false) else {
                return
        }
        let containerView = transitionContext.containerView
        destination.view.isHidden = true
        containerView.addSubview(destination.view)
        snapshot.frame = self.originFrame
        containerView.addSubview(snapshot)
        
        
        let destImageHeight = snapshot.frame.height * (destination.imageView.frame.width/snapshot.frame.width)
        
        UIView.animate(withDuration: 1, animations: {
            
            snapshot.frame = CGRect(x: 0,
                                    y: containerView.frame.height / 2 - destImageHeight / 2,
                                    width: destination.imageView.frame.width,
                                    height: destImageHeight)
        }, completion: { success in
            destination.view.isHidden = false
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}


class FullPhotoAnimationDismissController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let endFrame: CGRect
    
    init(endFrame: CGRect) {
        self.endFrame = endFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) as? FullPhotoViewController,
            let destination = transitionContext.viewController(forKey: .to),
            let snapshot = source.imageView.snapshotView(afterScreenUpdates: false)
            else {
                return
        }
       
        source.view.frame = source.imageView.frame
        let containerView = transitionContext.containerView
        containerView.addSubview(destination.view)
        containerView.addSubview(snapshot)
        
        snapshot.frame = source.imageView.frame
        source.view.isHidden = true
        destination.view.isHidden = true
        UIView.animate(withDuration: 1, animations: {
            snapshot.frame = self.endFrame
        }, completion: { success in
            source.view.isHidden = false
            snapshot.removeFromSuperview()
            source.removeFromParent()
            destination.view.isHidden = false
            if transitionContext.transitionWasCancelled {
                destination.view.removeFromSuperview()
            }
            transitionContext.completeTransition(true)
        })
        
    }
}
