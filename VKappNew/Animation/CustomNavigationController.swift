//
//  CustomNavigationController.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    let interactiveTransition = CustomInteractiveTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .white
        
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            return interactiveTransition.hasStarted ? interactiveTransition : nil
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            self.interactiveTransition.viewController = toVC
            return AnimationPushController()
        case .pop:
            if navigationController.viewControllers.first != toVC {
                self.interactiveTransition.viewController = toVC
            }
            return AnimationPopController()
        default:
            return nil
        }
    }
    
    public static func transform(frame : CGRect, on rotation : CGFloat) -> CGAffineTransform {
        let transA = CGAffineTransform(translationX: frame.size.width/2,y: frame.size.height/2)
        let rotation = CGAffineTransform(rotationAngle: rotation)
        let transB = CGAffineTransform(translationX: -frame.size.width/2,y: -frame.size.height/2)
        
        return transA.concatenating(rotation).concatenating(transB)
    }
}

class CustomInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var viewController: UIViewController? {
        didSet {
            let recognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                              action: #selector(handleScreenEdgeGesture(_:)))
            recognizer.edges = [.left]
            viewController?.view.addGestureRecognizer(recognizer)
        }
    }
    
    var hasStarted: Bool = false
    var shouldFinish: Bool = false
    
    @objc func handleScreenEdgeGesture(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            self.hasStarted = true
            self.viewController?.navigationController?.popViewController(animated: true)
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            let relativeTranslation = translation.x / (recognizer.view?.bounds.width ?? 1)
            let progress = max(0, min(1, relativeTranslation))
            self.shouldFinish = progress > 0.33
            self.update(progress)
        case .ended:
            self.hasStarted = false
            self.shouldFinish ? self.finish() : self.cancel()
        case .cancelled:
            self.hasStarted = false
            self.cancel()
        default: return
        }
    }
}
