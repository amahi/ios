//
//  AudioPlayerViewController+Gesture.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 10..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit

extension AudioPlayerViewController: QueueHeaderTapDelegate{
    
   @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    
        switch sender.state {
        case .began:
            let yVelocity = sender.velocity(in: view).y
            if (yVelocity > 200 && currentQueueState == .open) || (yVelocity < -200 && currentQueueState == .collapsed){
                startInteractiveTransition(state:nextState,duration: 0.7)
            }
        case .changed:
            let yTranslation = sender.translation(in: self.playerQueueContainer).y
            var fractionComplete = yTranslation/self.queueVCHeight
            fractionComplete = currentQueueState == .collapsed ? -fractionComplete : fractionComplete
            updateInteractiveTransition(fractionCompleted:fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func startInteractiveTransition(state:QueueState,duration: TimeInterval){
        if interactiveAnimators.isEmpty{
            animateIfNeeded(state: state, duration: duration)
        }
        for animator in interactiveAnimators{
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func animateIfNeeded(state:QueueState,duration:TimeInterval){
        if interactiveAnimators.isEmpty{
            setupQueueAnimator(for:state, with:duration)
            setupCornerAnimator(for:state, with:duration)
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat){
        for animator in interactiveAnimators{
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition(){
        for animator in interactiveAnimators{
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
   @objc func handleArrowHeadTap() {
        animateIfNeeded(state: nextState, duration: 0.7)
    }

    func didTapOnQueueHeader() {
        animateIfNeeded(state: nextState, duration: 0.7)
    }
    
    private func setupQueueAnimator(for state:QueueState, with duration:TimeInterval){
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.85) { [weak self] in
            switch state{
            case .collapsed:
                self?.queueTopConstraintForCollapse?.isActive = true
                self?.queueTopConstraintForOpen?.isActive = false
                self?.playerQueueContainer.header.alpha = 1
                self?.playerQueueContainer.header.arrowHead.transform = self?.playerQueueContainer.header.arrowHead.transform.rotated(by: CGFloat.pi) ?? CGAffineTransform(rotationAngle: CGFloat.pi)
            case .open:
                self?.queueTopConstraintForCollapse?.isActive = false
                self?.queueTopConstraintForOpen?.isActive = true
                self?.playerQueueContainer.header.alpha = 1
                self?.playerQueueContainer.header.arrowHead.transform = self?.playerQueueContainer.header.arrowHead.transform.rotated(by: CGFloat.pi) ?? CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            
            self?.view.layoutIfNeeded()
        }
        
        animator.addCompletion { (_) in
            if let index = self.interactiveAnimators.index(of: animator){
                self.interactiveAnimators.remove(at: index)
            }
            self.currentQueueState = state
        }
        
        animator.startAnimation()
        interactiveAnimators.append(animator)
    }
    
    private func setupCornerAnimator(for state:QueueState, with duration:TimeInterval){
        
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.85) {
            switch state{
            case .collapsed:
                self.playerQueueContainer.clipsToBounds = true
                self.playerQueueContainer.layer.cornerRadius = 0
                self.playerQueueContainer.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            case .open:
                self.playerQueueContainer.clipsToBounds = true
                self.playerQueueContainer.layer.cornerRadius = 30
                self.playerQueueContainer.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            }
            
            self.view.layoutIfNeeded()
        }
        
        animator.addCompletion { [weak self](_) in
            if let index = self?.interactiveAnimators.index(of: animator){
                self?.interactiveAnimators.remove(at: index)
            }
            self?.currentQueueState = state
        }
        
        animator.startAnimation()
        interactiveAnimators.append(animator)
        
    }
}
