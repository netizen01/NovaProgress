//
//  NovaProgress.swift
//

import UIKit
import CoreGraphics

@objc public class NovaProgress: NSObject {

    public static let sharedInstance = NovaProgress()


    public func push(status: String? = nil, animated: Bool = true) {
        if let status = status {
            statusMessages.append(status)
        } else {
            statusMessages.append("")
        }

        updateProgress(animated)
    }

    public func clear(animated: Bool = true) {
        statusMessages.removeAll(keepCapacity: false)

        updateProgress(animated)
    }

    public func pop(animated: Bool = true) {
        if statusMessages.count > 0 {
            statusMessages.removeLast()
        }
        updateProgress(animated)
    }

    public var currentStatus: String? {
        return statusMessages.last
    }

    public var linearRotation: Bool = true {
        didSet {
            progressView.linearRotation = linearRotation
        }
    }

    public var containerView: UIView?

    public private(set) var visible: Bool = false

    public var fadeAnimationDuration: Double = 0.25
    public var progressRadius: Double = 50 {
        didSet {
            progressView.frame = CGRect(x: 0, y: 0, width: progressRadius * 2, height: progressRadius * 2)
            progressView.center = modalView.center
        }
    }

    private override init() {
        modalView.addSubview(progressView)
        modalView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        modalView.alpha = 0
        progressView.frame = CGRect(x: 0, y: 0, width: progressRadius * 2, height: progressRadius * 2)
    }

    private let progressView = NovaProgressView(frame: CGRectZero)
    private let modalView = UIView(frame: CGRectZero)

    private func updateProgress(animated: Bool) {
        if statusMessages.count > 0 {
            updateLabel(animated)
            show(animated)
        } else {
            hide(animated)
        }
    }

    private func updateLabel(animated: Bool ) {

    }

    private var statusMessages: [String] = []

    private func show(animated: Bool) {
        visible = true

        if containerView == nil {
            containerView = UIApplication.sharedApplication().keyWindow
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
            UIView.animateWithDuration(fadeAnimationDuration, delay: 0, options: [.BeginFromCurrentState, .AllowAnimatedContent, .CurveEaseInOut], animations: { [weak self] in

                self?.modalView.alpha = 1

                }) { (success) in

            }

        } else {
            progressView.spinCircles(0)

            modalView.alpha = 1
        }

    }

    private func hide(animated: Bool) {
        if animated {

            progressView.closeCircles(fadeAnimationDuration)
            UIView.animateWithDuration(fadeAnimationDuration, delay: 0, options: [.BeginFromCurrentState, .AllowAnimatedContent, .CurveEaseInOut], animations: { [weak self] in

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

    var innerCircleColor: UIColor = UIColor.grayColor() {
        didSet {
            innerCircleLayer.strokeColor = innerCircleColor.CGColor
        }
    }
    var outerCircleColor: UIColor = UIColor.whiteColor() {
        didSet {
            outerCircleLayer.strokeColor = outerCircleColor.CGColor
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

    private var linearRotation: Bool = true

    private let outerCircleLayer = CAShapeLayer()
    private let innerCircleLayer = CAShapeLayer()

    private let outerCircleView = UIView(frame: CGRectZero)
    private let innerCircleView = UIView(frame: CGRectZero)

    private var innerCircleCurrentRotation: Double = 0
    private var outerCircleCurrentRotation: Double = 0

    private var innerCircleArcPercentage: CGFloat = 0.4
    private var outerCircleArcPercentage: CGFloat = 0.3

    private func spinCircles(delay: Double) {
        spinOuterCircle(delay)
        spinInnerCircle(delay)
    }

    private func openCircles(duration: Double) {

        UIView.animateWithDuration(duration, delay: 0, options: [.BeginFromCurrentState, .AllowAnimatedContent], animations: { [weak self] in
            if let s = self {

                s.outerCircleLayer.strokeStart = (1 - s.outerCircleArcPercentage) * 0.5
                s.outerCircleLayer.strokeEnd = s.outerCircleLayer.strokeStart + s.outerCircleArcPercentage

                s.innerCircleLayer.strokeStart = (1 - s.innerCircleArcPercentage) * 0.5
                s.innerCircleLayer.strokeEnd = s.innerCircleLayer.strokeStart + s.innerCircleArcPercentage

            }
            }) { (success) in

        }
    }

    private func closeCircles(duration: Double) {

        UIView.animateWithDuration(duration, delay: 0, options: [.BeginFromCurrentState, .AllowAnimatedContent], animations: { [weak self] in
            if let s = self {

                s.outerCircleLayer.strokeStart = 0
                s.outerCircleLayer.strokeEnd = 1

                s.innerCircleLayer.strokeStart = 0
                s.innerCircleLayer.strokeEnd = 1
            }
            }) { (success) in

        }
    }

    private func spinOuterCircle(delay: Double) {


        if linearRotation {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = -M_PI * 2
            animation.duration = 2
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.removedOnCompletion = false
            animation.repeatCount = HUGE
            animation.fillMode = kCAFillModeForwards
            animation.autoreverses = false
            outerCircleView.layer.addAnimation(animation, forKey: "rotate")

        } else {
            let duration = Double(Float(arc4random()) /  Float(UInt32.max)) * 0.5 + 0.25
            let randomRotation = Double(Float(arc4random()) /  Float(UInt32.max)) * M_PI_4 + M_PI_4
            _ = Double(Float(arc4random()) /  Float(UInt32.max)) * 1.0 + 1.0

            UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [.BeginFromCurrentState, .AllowAnimatedContent], animations: { [weak self] in
                if let s = self {
                    s.outerCircleView.transform = CGAffineTransformMakeRotation(CGFloat(s.outerCircleCurrentRotation))
                }

                }) { [weak self] (success) in
                    self?.outerCircleCurrentRotation -= randomRotation
                    if success {
                        self?.spinOuterCircle(0.25)
                    }
            }
        }
    }

    private func spinInnerCircle(delay: Double) {

        if linearRotation {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = M_PI * 2
            animation.duration = 4
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.removedOnCompletion = false
            animation.repeatCount = HUGE
            animation.fillMode = kCAFillModeForwards
            animation.autoreverses = false
            innerCircleView.layer.addAnimation(animation, forKey: "rotate")

        } else {
            UIView.animateWithDuration(1, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.BeginFromCurrentState, .AllowAnimatedContent], animations: { [weak self] in
                if let s = self {
                    s.innerCircleView.transform = CGAffineTransformMakeRotation(CGFloat(s.innerCircleCurrentRotation))
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

    private func configureLayers() {
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
        outerCircleLayer.fillColor = UIColor.clearColor().CGColor
        outerCircleLayer.strokeColor = outerCircleColor.CGColor

        innerCircleLayer.lineWidth = innerStrokeWidth
        innerCircleLayer.strokeStart = 0
        innerCircleLayer.strokeEnd = 1
        innerCircleLayer.lineCap = kCALineCapSquare
        innerCircleLayer.fillColor = UIColor.clearColor().CGColor
        innerCircleLayer.strokeColor = innerCircleColor.CGColor

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

    private override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = min(frame.size.height, frame.size.width) * 0.5
        
        let outerPadding = outerStrokeWidth * 0.5
        let outerPath = UIBezierPath(ovalInRect: CGRect(x: outerPadding, y: outerPadding, width: (radius - outerPadding) * 2, height: (radius - outerPadding) * 2))
        outerCircleLayer.path = outerPath.CGPath
        
        let innerPadding = outerStrokeWidth + circlePadding + innerStrokeWidth * 0.5
        let innerPath = UIBezierPath(ovalInRect: CGRect(x: innerPadding, y: innerPadding, width: (radius - innerPadding) * 2, height: (radius - innerPadding) * 2))
        innerCircleLayer.path = innerPath.CGPath
    }
    
}
