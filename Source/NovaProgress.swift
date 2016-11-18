//
//  NovaProgress.swift
//

import UIKit
import CoreGraphics

@objc open class NovaProgress: NSObject {

    open static let sharedInstance = NovaProgress()


    open func push(_ status: String? = nil, animated: Bool = true) {
        if let status = status {
            statusMessages.append(status)
        } else {
            statusMessages.append("")
        }

        updateProgress(animated)
    }

    open func clear(_ animated: Bool = true) {
        statusMessages.removeAll(keepingCapacity: false)

        updateProgress(animated)
    }

    open func pop(_ animated: Bool = true) {
        if statusMessages.count > 0 {
            statusMessages.removeLast()
        }
        updateProgress(animated)
    }

    open var currentStatus: String? {
        return statusMessages.last
    }

    open var linearRotation: Bool = true {
        didSet {
            progressView.linearRotation = linearRotation
        }
    }

    open var containerView: UIView?

    open fileprivate(set) var visible: Bool = false

    open var fadeAnimationDuration: Double = 0.25
    open var progressRadius: Double = 50 {
        didSet {
            progressView.frame = CGRect(x: 0, y: 0, width: progressRadius * 2, height: progressRadius * 2)
            progressView.center = modalView.center
        }
    }

    fileprivate override init() {
        modalView.addSubview(progressView)
        modalView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        modalView.alpha = 0
        progressView.frame = CGRect(x: 0, y: 0, width: progressRadius * 2, height: progressRadius * 2)
    }

    fileprivate let progressView = NovaProgressView(frame: CGRect.zero)
    fileprivate let modalView = UIView(frame: CGRect.zero)

    fileprivate func updateProgress(_ animated: Bool) {
        if statusMessages.count > 0 {
            updateLabel(animated)
            show(animated)
        } else {
            hide(animated)
        }
    }

    fileprivate func updateLabel(_ animated: Bool ) {

    }

    fileprivate var statusMessages: [String] = []

    fileprivate func show(_ animated: Bool) {
        visible = true

        if containerView == nil {
            containerView = UIApplication.shared.keyWindow
        }
        
        if containerView == nil {
            return
        }

        if modalView.superview !== containerView {
            modalView.removeFromSuperview()
            containerView!.addSubview(modalView)
        }

        modalView.frame = containerView!.bounds
        progressView.center = modalView.center
        progressView.setNeedsLayout()
        progressView.layoutIfNeeded()

        if animated {

            progressView.openCircles(fadeAnimationDuration)
            progressView.spinCircles(0)
            UIView.animate(withDuration: fadeAnimationDuration, delay: 0, options: [.beginFromCurrentState, .allowAnimatedContent], animations: { [weak self] in

                self?.modalView.alpha = 1

                }) { (success) in

            }

        } else {
            progressView.spinCircles(0)

            modalView.alpha = 1
        }

    }

    fileprivate func hide(_ animated: Bool) {
        if animated {

            progressView.closeCircles(fadeAnimationDuration)
            UIView.animate(withDuration: fadeAnimationDuration, delay: 0, options: [.beginFromCurrentState, .allowAnimatedContent], animations: { [weak self] in

                self?.modalView.alpha = 0

                }) { [weak self] (success) in
                    self?.modalView.removeFromSuperview()
                    self?.visible = !success
            }

        } else {
            progressView.closeCircles(fadeAnimationDuration)
            modalView.removeFromSuperview()
            visible = false
        }
    }
}



private class NovaProgressView: UIView {

    var innerCircleColor: UIColor = UIColor.gray {
        didSet {
            innerCircleLayer.strokeColor = innerCircleColor.cgColor
        }
    }
    var outerCircleColor: UIColor = UIColor.white {
        didSet {
            outerCircleLayer.strokeColor = outerCircleColor.cgColor
        }
    }

    var innerStrokeWidth: CGFloat = 4 {
        didSet {
            innerCircleLayer.lineWidth = innerStrokeWidth

            setNeedsLayout()
        }
    }

    var outerStrokeWidth: CGFloat = 6 {
        didSet {
            outerCircleLayer.lineWidth = outerStrokeWidth

            setNeedsLayout()
        }
    }

    var circlePadding: CGFloat = 8 {
        didSet {
            setNeedsLayout()
        }
    }

    fileprivate var linearRotation: Bool = true

    fileprivate let outerCircleLayer = CAShapeLayer()
    fileprivate let innerCircleLayer = CAShapeLayer()

    fileprivate let outerCircleView = UIView(frame: CGRect.zero)
    fileprivate let innerCircleView = UIView(frame: CGRect.zero)

    fileprivate var innerCircleCurrentRotation: Double = 0
    fileprivate var outerCircleCurrentRotation: Double = 0

    fileprivate var innerCircleArcPercentage: CGFloat = 0.4
    fileprivate var outerCircleArcPercentage: CGFloat = 0.3

    fileprivate func spinCircles(_ delay: Double) {
        spinOuterCircle(delay)
        spinInnerCircle(delay)
    }

    fileprivate func openCircles(_ duration: Double) {

        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .allowAnimatedContent], animations: { [weak self] in
            if let s = self {

                s.outerCircleLayer.strokeStart = (1 - s.outerCircleArcPercentage) * 0.5
                s.outerCircleLayer.strokeEnd = s.outerCircleLayer.strokeStart + s.outerCircleArcPercentage

                s.innerCircleLayer.strokeStart = (1 - s.innerCircleArcPercentage) * 0.5
                s.innerCircleLayer.strokeEnd = s.innerCircleLayer.strokeStart + s.innerCircleArcPercentage

            }
            }) { (success) in

        }
    }

    fileprivate func closeCircles(_ duration: Double) {

        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .allowAnimatedContent], animations: { [weak self] in
            if let s = self {

                s.outerCircleLayer.strokeStart = 0
                s.outerCircleLayer.strokeEnd = 1

                s.innerCircleLayer.strokeStart = 0
                s.innerCircleLayer.strokeEnd = 1
            }
            }) { (success) in

        }
    }

    fileprivate func spinOuterCircle(_ delay: Double) {


        if linearRotation {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = -M_PI * 2
            animation.duration = 2
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.isRemovedOnCompletion = false
            animation.repeatCount = HUGE
            animation.fillMode = kCAFillModeForwards
            animation.autoreverses = false
            outerCircleView.layer.add(animation, forKey: "rotate")

        } else {
            let duration = Double(Float(arc4random()) /  Float(UInt32.max)) * 0.5 + 0.25
            let randomRotation = Double(Float(arc4random()) /  Float(UInt32.max)) * M_PI_4 + M_PI_4
            _ = Double(Float(arc4random()) /  Float(UInt32.max)) * 1.0 + 1.0

            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [.beginFromCurrentState, .allowAnimatedContent], animations: { [weak self] in
                if let s = self {
                    s.outerCircleView.transform = CGAffineTransform(rotationAngle: CGFloat(s.outerCircleCurrentRotation))
                }

                }) { [weak self] (success) in
                    self?.outerCircleCurrentRotation -= randomRotation
                    if success {
                        self?.spinOuterCircle(0.25)
                    }
            }
        }
    }

    fileprivate func spinInnerCircle(_ delay: Double) {

        if linearRotation {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = M_PI * 2
            animation.duration = 4
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.isRemovedOnCompletion = false
            animation.repeatCount = HUGE
            animation.fillMode = kCAFillModeForwards
            animation.autoreverses = false
            innerCircleView.layer.add(animation, forKey: "rotate")

        } else {
            UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.beginFromCurrentState, .allowAnimatedContent], animations: { [weak self] in
                if let s = self {
                    s.innerCircleView.transform = CGAffineTransform(rotationAngle: CGFloat(s.innerCircleCurrentRotation))
                }

                }) { [weak self] (success) in
                    self?.innerCircleCurrentRotation += M_PI_4
                    if success {
                        self?.spinInnerCircle(0.15)
                    }
            }
        }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)

        configureLayers()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureLayers()
    }

    fileprivate func configureLayers() {
        innerCircleLayer.removeFromSuperlayer()
        outerCircleLayer.removeFromSuperlayer()

        innerCircleCurrentRotation = (Double(arc4random_uniform(100)) / 100) * M_PI
        outerCircleCurrentRotation = (Double(arc4random_uniform(100)) / 100) * M_PI

        outerCircleView.layer.addSublayer(outerCircleLayer)
        innerCircleView.layer.addSublayer(innerCircleLayer)

        outerCircleLayer.lineWidth = outerStrokeWidth
        outerCircleLayer.strokeStart = 0.0
        outerCircleLayer.strokeEnd = 1
        outerCircleLayer.lineCap = kCALineCapSquare
        outerCircleLayer.fillColor = UIColor.clear.cgColor
        outerCircleLayer.strokeColor = outerCircleColor.cgColor

        innerCircleLayer.lineWidth = innerStrokeWidth
        innerCircleLayer.strokeStart = 0
        innerCircleLayer.strokeEnd = 1
        innerCircleLayer.lineCap = kCALineCapSquare
        innerCircleLayer.fillColor = UIColor.clear.cgColor
        innerCircleLayer.strokeColor = innerCircleColor.cgColor

        addSubview(innerCircleView)
        addSubview(outerCircleView)
    }


    override var frame: CGRect {
        set {
            super.frame = newValue

            innerCircleView.frame = bounds
            outerCircleView.frame = bounds
        }
        get {
            return super.frame
        }
    }

    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = min(frame.size.height, frame.size.width) * 0.5
        
        let outerPadding = outerStrokeWidth * 0.5
        let outerPath = UIBezierPath(ovalIn: CGRect(x: outerPadding, y: outerPadding, width: (radius - outerPadding) * 2, height: (radius - outerPadding) * 2))
        outerCircleLayer.path = outerPath.cgPath
        
        let innerPadding = outerStrokeWidth + circlePadding + innerStrokeWidth * 0.5
        let innerPath = UIBezierPath(ovalIn: CGRect(x: innerPadding, y: innerPadding, width: (radius - innerPadding) * 2, height: (radius - innerPadding) * 2))
        innerCircleLayer.path = innerPath.cgPath
    }
    
}
