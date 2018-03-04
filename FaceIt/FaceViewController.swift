//
//  ViewController.swift
//  FaceIt
//
//  Created by MarinaS on 02.02.18.
//  Copyright © 2018 MarinaS. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController
{
	
	fileprivate var expression = FacialExpression(eyes: .open, eyeBrows: .normal, mouth: .frown ) {
		didSet {
			updateUI()
		}
	}
	
	@IBOutlet fileprivate weak var faceView: FaceView! {
		didSet {
			faceView.addGestureRecognizer(UIPinchGestureRecognizer(
				target: faceView,
				action: #selector(faceView.changeScale(_:))
			))
			let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(
				target: self,
				action:#selector(FaceViewController.increaseHappiness)
			)
			happierSwipeGestureRecognizer.direction = .down
			faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
			let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(
				target: self,
				action:#selector(FaceViewController.decreaseHappiness)
			)
			sadderSwipeGestureRecognizer.direction = .up
			faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)
			updateUI()
		}
	}
	
	func increaseHappiness() {
		expression.mouth = expression.mouth.happierMouth()
	}
	
	func decreaseHappiness() {
		expression.mouth = expression.mouth.sadderMouth()
	}
	
	@IBAction func toggleEyes(_ recognizer: UITapGestureRecognizer) {
		if recognizer.state == .ended {
			switch expression.eyes {
			case .open: expression.eyes = .closed
			case .closed: expression.eyes = .open
			case .squinting: break
			}
		}
	}
	
	@IBAction func changeBrows(_ recognizer: UIRotationGestureRecognizer) {
		let minimumRotationForChangeBrows: CGFloat = 0.1
		guard abs(recognizer.rotation) > minimumRotationForChangeBrows else { return }
		switch recognizer.state {
		case .changed, .ended:
			if recognizer.rotation > 0 {
				expression.eyeBrows = expression.eyeBrows.moreRelaxedBrow()
			} else {
				expression.eyeBrows = expression.eyeBrows.moreFurrowedBrow()
			}
			recognizer.rotation = 0.0
		default: break
		}
	}
	
	
	fileprivate let mouthCurvatures: [FacialExpression.Mouth : Double] =
		[.frown: -1.0, .grin: 0.5, .smile: 1.0, .smirk: -0.5, .neutral: 0.0 ]
	
	fileprivate var eyeBrowTilts: [FacialExpression.EyeBrows : Double] =
		[.relaxed: 0.5, .furrowed: -0.5, .normal: 0.0]
	
	fileprivate func updateUI() {
		switch expression.eyes {
		case .open: 	faceView.eyesOpen = true
		case .closed: 	faceView.eyesOpen = false
		case .squinting:faceView.eyesOpen = false
		}
		faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
		faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
	}



}

