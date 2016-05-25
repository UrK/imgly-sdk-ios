//
//  IMGLYCropOverlayView.swift
//  SFG
//
//  Created by Uri Kogan on 25/05/2016.
//  Copyright © 2016 Shutterfly. All rights reserved.
//
import UIKit
import QuartzCore

class IMGLYCropOverlayView: UIView {

    static let ZoomGuideLineLength: CGFloat = 24.0
    var contentFrame: CGRect
    var wrapSize: CGSize
    var iPhone4: Bool
    var iPhone5: Bool

    required override init(frame: CGRect) {
        self.contentFrame = CGRectZero
        self.wrapSize = CGSizeZero
        self.iPhone4 = false
        self.iPhone5 = false
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, UIColor(white: 0, alpha: 0.5).CGColor)
        CGContextFillRect(context, self.bounds)
        CGContextSetBlendMode(context, CGBlendMode.Clear)
        CGContextFillRect(context, self.contentFrame)
        CGContextSetBlendMode(context, CGBlendMode.Normal)

        CGContextSetStrokeColorWithColor(context, UIColor(white: 1, alpha: 0.8).CGColor)

        var frame = self.contentFrame

        CGContextTranslateCTM(context, frame.origin.x, frame.origin.y)

        var lineWidth: CGFloat = 2.0

        if(self.iPhone4) {
            lineWidth = (frame.size.width - (self.wrapSize.width*2.0)) / 3.25 * 0.125
        }
        else if(self.iPhone5) {
            lineWidth = (frame.size.width - (self.wrapSize.width*2.0)) / 975 * 22
        }

        CGContextSetStrokeColorWithColor(context, UIColor(white: 0, alpha: 0.5).CGColor)

        CGContextSetLineWidth(context, lineWidth)

        CGContextMoveToPoint(context, 0.0                , lineWidth * 0.5)
        CGContextAddLineToPoint(context, frame.size.width, lineWidth * 0.5)

        CGContextMoveToPoint(context,    frame.size.width-lineWidth * 0.5, lineWidth * 0.5)
        CGContextAddLineToPoint(context, frame.size.width-lineWidth * 0.5, frame.size.height-lineWidth * 0.5)
        CGContextMoveToPoint(context, frame.size.width, frame.size.height-lineWidth * 0.5)
        CGContextAddLineToPoint(context, 0.0              , frame.size.height-lineWidth * 0.5)

        CGContextMoveToPoint(context,    lineWidth * 0.5, frame.size.height-lineWidth * 0.5)
        CGContextAddLineToPoint(context, lineWidth * 0.5, lineWidth * 0.5)

        CGContextStrokePath(context)

        if(self.wrapSize.width > 0.0 || self.wrapSize.height > 0.0) {
            frame = CGRectInset(frame, self.wrapSize.width, self.wrapSize.height)
            let gridWidth: CGFloat = frame.size.width / 3.0
            let gridHeight: CGFloat = frame.size.height / 3.0

            CGContextTranslateCTM(context, self.wrapSize.width, self.wrapSize.height)

            CGContextSetLineWidth(context, 1.0)

            CGContextMoveToPoint(context, gridWidth-1, 0)
            CGContextAddLineToPoint(context, gridWidth-1, gridHeight-1)
            CGContextAddLineToPoint(context, 0, gridHeight-1)

            CGContextMoveToPoint(context, gridWidth+1, 0)
            CGContextAddLineToPoint(context, gridWidth+1, gridHeight-1)
            CGContextAddLineToPoint(context, (gridWidth*2)-1, gridHeight-1)
            CGContextAddLineToPoint(context, (gridWidth*2)-1, 0)

            CGContextMoveToPoint(context, (gridWidth*2)+1, 0)
            CGContextAddLineToPoint(context, (gridWidth*2)+1, gridHeight-1)
            CGContextAddLineToPoint(context, gridWidth*3, gridHeight-1)

            CGContextMoveToPoint(context, 0, gridHeight+1)
            CGContextAddLineToPoint(context, gridWidth-1, gridHeight+1)
            CGContextAddLineToPoint(context, gridWidth-1, (gridHeight*2)-1)
            CGContextAddLineToPoint(context, 0, (gridHeight*2)-1)

            CGContextMoveToPoint(context, gridWidth+1, gridHeight+1)
            CGContextAddLineToPoint(context, (gridWidth*2)-1, gridHeight+1)
            CGContextAddLineToPoint(context, (gridWidth*2)-1, (gridHeight*2)-1)
            CGContextAddLineToPoint(context, gridWidth+1, (gridHeight*2)-1)
            CGContextAddLineToPoint(context, gridWidth+1, gridHeight+1)

            CGContextMoveToPoint(context, gridWidth*3, gridHeight+1)
            CGContextAddLineToPoint(context, (gridWidth*2)+1, gridHeight+1)
            CGContextAddLineToPoint(context, (gridWidth*2)+1, (gridHeight*2)-1)
            CGContextAddLineToPoint(context, gridWidth*3, (gridHeight*2)-1)

            CGContextMoveToPoint(context, gridWidth-1, gridHeight*3)
            CGContextAddLineToPoint(context, gridWidth-1, (gridHeight*2)+1)
            CGContextAddLineToPoint(context, 0, (gridHeight*2)+1)

            CGContextMoveToPoint(context, gridWidth+1, gridHeight*3)
            CGContextAddLineToPoint(context, gridWidth+1, (gridHeight*2)+1)
            CGContextAddLineToPoint(context, (gridWidth*2)-1, (gridHeight*2)+1)
            CGContextAddLineToPoint(context, (gridWidth*2)-1, gridHeight*3)

            CGContextMoveToPoint(context, (gridWidth*2)+1, gridHeight*3)
            CGContextAddLineToPoint(context, (gridWidth*2)+1, (gridHeight*2)+1)
            CGContextAddLineToPoint(context, gridWidth*3, (gridHeight*2)+1)

            CGContextStrokePath(context)

            if(self.iPhone4) {
                CGContextSetFillColorWithColor(context, UIColor(white: 0, alpha: 0.4).CGColor)
                let path = UIBezierPath(roundedRect: CGRectMake(0, 0, frame.size.width, frame.size.height), cornerRadius: 20)
                path.lineWidth = 3
                path.stroke()

                let holeRect = CGRectMake(frame.size.width * 0.125 / 2.375, frame.size.height * 0.125 / 4.625, frame.size.width * 0.75 / 2.375, frame.size.height * 0.5 / 4.675)
                let hole = UIBezierPath(roundedRect: holeRect,cornerRadius:20)
                hole.stroke()
                hole.fill()
            }
            else if(self.iPhone5) {
                let holeFrame = CGRectMake( 1 + frame.size.width * 20 / 717, 1 + frame.size.height * 20 / 1490, frame.size.width * 271 / 717, frame.size.height * 180 / 1490 )

                CGContextSetFillColorWithColor(context, UIColor(white: 0, alpha: 0.4).CGColor)

                let path = UIBezierPath(
                    roundedRect:CGRectMake(-1, -1, frame.size.width+2, frame.size.height+2),
                    cornerRadius: holeFrame.size.height / 2 + holeFrame.origin.y)

                path.lineWidth = 3
                path.stroke()

                let hole = UIBezierPath()

                hole.moveToPoint(CGPointMake(CGRectGetMinX(holeFrame),CGRectGetMaxY(holeFrame)))
                hole.addLineToPoint(CGPointMake(CGRectGetMinX(holeFrame),CGRectGetMidY(holeFrame)))
                hole.addArcWithCenter(
                    CGPointMake(CGRectGetMinX(holeFrame)+holeFrame.size.height/2,CGRectGetMidY(holeFrame)),
                    radius: holeFrame.size.height/2,
                    startAngle:CGFloat(M_PI),
                    endAngle:-CGFloat(M_PI_2),
                    clockwise: true)

                hole.addLineToPoint(CGPointMake(CGRectGetMaxX(holeFrame),CGRectGetMinY(holeFrame)))

                hole.addLineToPoint(CGPointMake(CGRectGetMaxX(holeFrame),CGRectGetMidY(holeFrame)))

                hole.addArcWithCenter(
                    CGPointMake(CGRectGetMaxX(holeFrame)-holeFrame.size.height/2,CGRectGetMidY(holeFrame)),
                    radius: holeFrame.size.height/2,
                    startAngle: 0,
                    endAngle: CGFloat(M_PI_2),
                    clockwise: true)

                hole.addLineToPoint(CGPointMake(CGRectGetMinX(holeFrame),CGRectGetMaxY(holeFrame)))

                CGContextSetFillColorWithColor(context, UIColor(white: 0, alpha: 0.4).CGColor)
                hole.fill()
            }
            else {
                CGContextSetLineWidth(context, 2.0)

                CGContextStrokeRect(context, CGRectMake(-1, -1, frame.size.width+1, frame.size.height+1))
            }
        }
        else {
            frame = CGRectInset(frame, lineWidth, lineWidth)

            let gridWidth: CGFloat = (frame.size.width) / 3.0
            let gridHeight: CGFloat = frame.size.height / 3.0

            CGContextTranslateCTM(context, lineWidth, lineWidth)
            CGContextSetLineWidth(context, 0.5)

            CGContextSetStrokeColorWithColor(context, UIColor(white: 0.2, alpha: 0.4).CGColor)
            CGContextSetFillColorWithColor(context, UIColor(white: 1, alpha: 0.5).CGColor)

            // Draw 4 grid lines
            let r1 = CGRectMake(gridWidth  , -1, 2.0, gridHeight*3+1)
            let r2 = CGRectMake(gridWidth*2, -1, 2.0, gridHeight*3+1)
            let r3 = CGRectMake(0.0 , gridHeight-1, gridWidth*3+1, 2)
            let r4 = CGRectMake(0.0 , gridHeight*2-1, gridWidth*3+1, 2)

            CGContextStrokeRect(context, r1)
            CGContextFillRect(context,r1)

            CGContextStrokeRect(context, r2)
            CGContextFillRect(context,r2)

            CGContextStrokeRect(context, r3)
            CGContextFillRect(context,r3)

            CGContextStrokeRect(context, r4)
            CGContextFillRect(context,r4)

            // Draw 4 orange zoom guide lines
            CGContextSetLineWidth(context, 4.0)

            CGContextSetStrokeColorWithColor(context, UIColor(red:240.0/255, green:83.0/255, blue:35.0/255, alpha:1).CGColor)

            CGContextMoveToPoint(context,    -1 , gridHeight*3 - IMGLYCropOverlayView.ZoomGuideLineLength)
            CGContextAddLineToPoint(context, -1 , gridHeight*3.0+1)
            CGContextAddLineToPoint(context, IMGLYCropOverlayView.ZoomGuideLineLength  , gridHeight*3.0+1)

            CGContextMoveToPoint(context,    gridWidth*3+1             , gridHeight*3 - IMGLYCropOverlayView.ZoomGuideLineLength)
            CGContextAddLineToPoint(context,gridWidth*3+1              , gridHeight*3.0+1)
            CGContextAddLineToPoint(context,gridWidth*3 - IMGLYCropOverlayView.ZoomGuideLineLength, gridHeight*3.0+1)

            CGContextMoveToPoint(context, IMGLYCropOverlayView.ZoomGuideLineLength , -1)
            CGContextAddLineToPoint(context, -1         , -1)
            CGContextAddLineToPoint(context, -1         , IMGLYCropOverlayView.ZoomGuideLineLength)

            CGContextMoveToPoint(context,   gridWidth*3+1  , IMGLYCropOverlayView.ZoomGuideLineLength)
            CGContextAddLineToPoint(context,gridWidth*3+1  , -1)
            CGContextAddLineToPoint(context, gridWidth*3+1-IMGLYCropOverlayView.ZoomGuideLineLength , -1)

            CGContextStrokePath(context)
        }
    }

    override var frame: CGRect {
        didSet {
            self.setNeedsDisplay()
        }
    }

}
