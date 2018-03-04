//
//  FaceView.swift
//  FaceIt
//
//  Created by MarinaS on 02.02.18.
//  Copyright © 2018 MarinaS. All rights reserved.
//

import UIKit

@IBDesignable  // http://nshipster.com/ibinspectable-ibdesignable/
class FaceView: UIView
{
	@IBInspectable var scale: CGFloat = 0.90 { didSet { setNeedsDisplay() }}
	@IBInspectable var mouthCurvature: Double = 1.0 { didSet { setNeedsDisplay() }}
	@IBInspectable var eyesOpen: Bool = true { didSet { setNeedsDisplay() }}
	@IBInspectable var eyeBrowTilt: Double = 0.0 { didSet { setNeedsDisplay() }}
	@IBInspectable var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() }}
	@IBInspectable var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() }}
	
	func changeScale(_ recognizer: UIPinchGestureRecognizer) {
		switch recognizer.state {
		case .changed, .ended:
			scale *= recognizer.scale
			recognizer.scale = 1.0
		default: break
		}
	}
	
	fileprivate var skullRadius: CGFloat {
		return min(bounds.height, bounds.width) / 2 * scale
	}
	
	fileprivate var skullCenter: CGPoint {
		return CGPoint(x: bounds.midX, y: bounds.midY)
//		return convertPoint(center, fromView: superview)
	}
	
	fileprivate struct Ratios {
		static let SkullRadiusToEyeOffset: 		CGFloat = 3
		static let SkullRadiusToEyeRadius: 		CGFloat = 10
		static let SkullRadiusToEyeSeparation:	CGFloat = 1.5
		static let SkullRadiusToBrowOffset: 	CGFloat = 5
		static let SkullRadiusToMouthWidth: 	CGFloat = 1
		static let SkullRadiusToMouthHeight: 	CGFloat = 3
		static let SkullRadiusToMouthOffset: 	CGFloat = 3
	}
	
	fileprivate enum Eye {
		case left
		case right
	}
	
	fileprivate func pathForCircleCenteredAtPoint(_ midPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath
	{	let path = UIBezierPath(arcCenter: midPoint,
	 	                        radius: radius,
	 	                        startAngle: 0.0,
	 	                        endAngle: CGFloat(Double.pi*2),
	 	                        clockwise: false)
		path.lineWidth = lineWidth
		return path
	}
	
	fileprivate func getEyeCenter(_ eye: Eye) -> CGPoint
	{
		let eyeOffset = skullRadius / Ratios.SkullRadiusToEyeOffset
		var eyeCenter = skullCenter
		eyeCenter.y -= eyeOffset
		switch eye {
			case .left: eyeCenter.x -= eyeOffset
			case .right: eyeCenter.x += eyeOffset
		}
		return eyeCenter
	}
	
	fileprivate func pathForEye(_ eye: Eye) -> UIBezierPath
	{
		let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
		let eyeCenter = getEyeCenter(eye)
		if eyesOpen {
			return pathForCircleCenteredAtPoint(eyeCenter, withRadius: eyeRadius)
		}
		let path = UIBezierPath()
		path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
		path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
		path.lineWidth = lineWidth
		return path
	}
	
	fileprivate func pathForBrow(_ eye: Eye) -> UIBezierPath
	{
		let tilt = eye == .left ? eyeBrowTilt * -1 : eyeBrowTilt
		var browCenter = getEyeCenter(eye)
		browCenter.y -= skullRadius / Ratios.SkullRadiusToBrowOffset
		let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
		let tiltOffset = CGFloat(max(-1, min(tilt, 1))) * eyeRadius / 2
		let browStart = CGPoint(x: browCenter.x - eyeRadius, y: browCenter.y - tiltOffset)
		let browEnd = CGPoint(x: browCenter.x + eyeRadius, y: browCenter.y + tiltOffset)
		let path = UIBezierPath()
		path.move(to: browStart)
		path.addLine(to: browEnd)
		path.lineWidth = lineWidth
		return path
	}

	fileprivate func pathForMouth() -> UIBezierPath
	{
		let mouthWidth = skullRadius / Ratios.SkullRadiusToMouthWidth
		let mouthHeight = skullRadius / Ratios.SkullRadiusToMouthHeight
		let mouthOffset = skullRadius / Ratios.SkullRadiusToMouthOffset
		
		let mouthOrigin = CGPoint(x: skullCenter.x - mouthWidth/2, y: skullCenter.y + mouthOffset)
		let mouthSize = CGSize(width: mouthWidth, height: mouthHeight)
		let mouthRect = CGRect(origin: mouthOrigin, size: mouthSize)
		
		let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
		let start = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
		let end = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
		let cp1 = CGPoint(x: mouthRect.minX + mouthRect.width / 3, y: mouthRect.minY + smileOffset)
		let cp2 = CGPoint(x: mouthRect.maxX - mouthRect.width / 3, y: mouthRect.minY + smileOffset)
		
		let path = UIBezierPath()
		path.move(to: start)
		path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
		path.lineWidth = lineWidth
		return path
	}
	
    override func draw(_ rect: CGRect)
	{	color.set()
		pathForCircleCenteredAtPoint(skullCenter, withRadius:skullRadius).stroke()
		pathForEye(.left).stroke()
		pathForBrow(.left).stroke()
		pathForEye(.right).stroke()
		pathForBrow(.right).stroke()
		pathForMouth().stroke()
    }
 

}
