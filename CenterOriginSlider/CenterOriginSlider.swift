//
//  CenterOriginSlider.swift
//  CenterOriginSlider
//
//  Created by 多鹿豊 on 2018/01/21.
//  Copyright © 2018年 多鹿豊. All rights reserved.
//

import UIKit

@IBDesignable
open class CenterOriginSlider: UISlider {
    
    @IBInspectable open var minimumTrackBackgroundColor: UIColor = .lightGray {
        didSet {
            prepareMinimumTrackImage()
            setMinimumTrackImage()
        }
    }
    
    @IBInspectable open var minimumTrackForegroudColor: UIColor = .black {
        didSet {
            prepareMinimumTrackImage()
            setMinimumTrackImage()
        }
    }
    
    @IBInspectable open var maximumTrackBackgroundColor: UIColor = .lightGray {
        didSet {
            prepareMaximumTrackImage()
            setMaximumTrackImage()
        }
    }
    
    @IBInspectable open var maximumTrackForegroudColor: UIColor = .black {
        didSet {
            prepareMaximumTrackImage()
            setMaximumTrackImage()
        }
    }
    
    @IBInspectable open var trackHeight: CGFloat = 1.5 {
        didSet {
            prepareTrackImage()
            setTrackImage()
        }
    }
    
    open var isCenterFeedbackEnabled: Bool = true
    
    override open var bounds: CGRect {
        didSet {
            prepareTrackImage()
            setTrackImage()
        }
    }
    
    private var centerValue: Float { return (minimumValue + maximumValue) / 2 }
    private var minimumBackgroundImage = UIImage()
    private var maximumBackgroundImage = UIImage()
    private var minimumTrackStretchableImage = UIImage()
    private var maximumTrackStretchableImage = UIImage()
    private var feedbackGenerator: Any? = {
        if #available(iOS 10.0, *) {
            let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.comminInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.comminInit()
    }
    
    open override func prepareForInterfaceBuilder() {
        prepareMinimumTrackImage()
        prepareMaximumTrackImage()
        setTrackImage()
    }
    
    fileprivate func comminInit() {
        self.addTarget(self, action: #selector(CenterOriginSlider.valueChanged), for: .valueChanged)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        prepareMinimumTrackImage()
        prepareMaximumTrackImage()
        setTrackImage()
    }
    
    private func prepareTrackImage() {
        prepareMinimumTrackImage()
        prepareMaximumTrackImage()
    }
    
    private func prepareMinimumTrackImage() {
        minimumBackgroundImage = UIImage.filled(with: minimumTrackBackgroundColor, size: CGSize(width: (self.frame.size.width / 2 - alignmentRectInsets.left), height: trackHeight))
        let minimumForegroundImage = UIImage.filled(with: minimumTrackForegroudColor, size: CGSize(width: 3, height: trackHeight))
        let compositeImage = minimumBackgroundImage.composite(otherImage: minimumForegroundImage, size: CGSize(width: minimumBackgroundImage.size.width + minimumForegroundImage.size.width, height: trackHeight), position: CGPoint(x: minimumBackgroundImage.size.width, y: 0))
        minimumTrackStretchableImage = compositeImage.resizableImage(withCapInsets: UIEdgeInsetsMake(0, minimumBackgroundImage.size.width + 1, 0, 1), resizingMode: .tile)
    }
    
    private func prepareMaximumTrackImage() {
        maximumBackgroundImage = UIImage.filled(with: maximumTrackBackgroundColor, size: CGSize(width: (self.frame.size.width / 2 - alignmentRectInsets.right), height: trackHeight))
        let maximumForegroundImage = UIImage.filled(with: maximumTrackForegroudColor, size: CGSize(width: 3, height: trackHeight))
        let compositeImage = maximumForegroundImage.composite(otherImage: maximumBackgroundImage, size: CGSize(width: maximumBackgroundImage.size.width + maximumForegroundImage.size.width, height: trackHeight), position: CGPoint(x: maximumForegroundImage.size.width, y: 0))
        maximumTrackStretchableImage = compositeImage.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 1, 0, maximumBackgroundImage.size.width + 1), resizingMode: .tile)
    }
    
    @objc private func valueChanged() {
        setTrackImage()
        if self.value == self.centerValue {
            if #available(iOS 10.0, *), self.isCenterFeedbackEnabled {
                (feedbackGenerator as? UIImpactFeedbackGenerator)?.impactOccurred()
            }
        }
    }
    
    private func setTrackImage() {
        setMinimumTrackImage()
        setMaximumTrackImage()
    }
    
    private func setMinimumTrackImage() {
        if self.value <= centerValue {
            self.setMinimumTrackImage(minimumBackgroundImage, for: .normal)
        } else {
            self.setMinimumTrackImage(minimumTrackStretchableImage, for: .normal)
        }
    }
    
    private func setMaximumTrackImage() {
        if self.value <= centerValue {
            self.setMaximumTrackImage(maximumTrackStretchableImage, for: .normal)
        } else {
            self.setMaximumTrackImage(maximumBackgroundImage, for: .normal)
        }
    }
    
}

private extension UIImage {
    
    static func filled(with color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func composite(otherImage: UIImage, size: CGSize, position: CGPoint) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let rect = CGRect(origin: .zero, size: size)
        self.draw(in: rect)
        
        let otherRect = CGRect(origin: position, size: otherImage.size)
        otherImage.draw(in: otherRect)
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return compositeImage
    }
    
}
