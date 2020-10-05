//
//  AnimationController.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class AnimationPushController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        transitionContext.containerView.addSubview(destination.view)
        destination.view.frame = source.view.frame
        
        destination.view.transform = CustomNavigationController.transform(frame: destination.view.frame, on: .pi*3/2)
        
        //почему то без кейфрейма не сработало
        UIView.animateKeyframes(withDuration: self.transitionDuration(using: transitionContext),
                                delay: 0,
                                options: .calculationModePaced,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: 1,
                                                       animations: {
                                                        destination.view.transform = .identity
                                                        source.view.transform = CustomNavigationController.transform(frame: source.view.frame, on: .pi/2)
                                    })
        }) { finished in
            if finished && !transitionContext.transitionWasCancelled {
                //source.removeFromParent()
            } else if transitionContext.transitionWasCancelled {
                destination.view.transform = .identity
            }
            transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
        }
        source.view.transform = .identity
    }
}


class AnimationPopController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        transitionContext.containerView.sendSubviewToBack(destination.view)
        
        destination.view.frame = source.view.frame
        destination.view.transform = CustomNavigationController.transform(frame: destination.view.frame, on: .pi / 2)
        UIView.animate(withDuration: 1, animations: {
            source.view.transform = CustomNavigationController.transform(frame: source.view.frame, on: -.pi / 2)
            destination.view.transform = .identity
        }, completion: { finished in
            if finished && !transitionContext.transitionWasCancelled {
                source.removeFromParent()
            } else if transitionContext.transitionWasCancelled {
                destination.view.transform = .identity
            }
            transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
        })
        
    }
}

