//
//  IMGLYMainEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum IMGLYEditorResult: Int {
    case Done
    case Cancel
}

@objc public enum IMGLYMainMenuButtonType: Int {
    case Magic
    case Filter
    case Stickers
    case Orientation
    case Focus
    case Crop
    case Brightness
    case Contrast
    case Saturation
    case Noise
    case Text
    case Reset
}

public typealias IMGLYEditorCompletionBlock = (IMGLYEditorResult, UIImage?) -> Void

private let ButtonCollectionViewCellReuseIdentifier = "ButtonCollectionViewCell"
private let ButtonCollectionViewCellSize = CGSize(width: 66, height: 90)

public class IMGLYMainEditorViewController: IMGLYEditorViewController {
    
    // MARK: - Properties

    public var cropSize = CGSizeZero
    private var overlayView: IMGLYCropOverlayView?
    private var memeGenerator: SFGMemeGeneratorViewController?
    
    public lazy var actionButtons: [IMGLYActionButton] = {
        let bundle = NSBundle(forClass: self.dynamicType)
        var handlers = [IMGLYActionButton]()

        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.crop", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_crop", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Crop) }))

        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.magic", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_magic", inBundle: bundle, compatibleWithTraitCollection: nil),
                selectedImage: UIImage(named: "icon_option_magic_active", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Magic) },
                showSelection: { [unowned self] in return self.fixedFilterStack.enhancementFilter.enabled }))
        
        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.filter", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_filters", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Filter) }))
        
        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.stickers", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_sticker", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Stickers) }))
        
        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.orientation", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_orientation", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Orientation) }))
        
        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.focus", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_focus", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Focus) }))
        
        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.brightness", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_brightness", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Brightness) }))
        
        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.contrast", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_contrast", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Contrast) }))
        
        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.saturation", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_saturation", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Saturation) }))
        
        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("main-editor.button.text", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_text", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Text) }))

        handlers.append(
            IMGLYActionButton(
                title: NSLocalizedString("Meme", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_meme", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.startMemeGenerator() }))

        return handlers
        }()
    
    public var completionBlock: IMGLYEditorCompletionBlock?
    public var initialFilterType = IMGLYFilterType.None
    public var initialFilterIntensity = NSNumber(double: 0.75)
    public private(set) var fixedFilterStack = IMGLYFixedFilterStack()
    
    private let maxLowResolutionSideLength = CGFloat(1600)
    public var highResolutionImage: UIImage? {
        didSet {
            generateLowResolutionImage()
        }
    }

    private func startMemeGenerator() {
        if memeGenerator == nil {
            memeGenerator = SFGMemeGeneratorViewController(image: self.previewImageView.image)
        }
        self.navigationController?.pushViewController(memeGenerator!, animated: true)
        self.navigationController?.delegate = self
    }

    public func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if viewController != self {
            return
        }

        guard let generator = self.memeGenerator else {
            return
        }

        self.previewImageView.image = generator.applyMemeToImage(self.previewImageView.image, real: false)
    }
    
    // MAR: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("main-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(IMGLYMainEditorViewController.cancelTapped(_:)))

        navigationController?.delegate = self

        fixedFilterStack.effectFilter = IMGLYInstanceFactory.effectFilterWithType(initialFilterType)
        fixedFilterStack.effectFilter.inputIntensity = initialFilterIntensity
        
        updatePreviewImage()
        configureMenuCollectionView()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.configureOverlay()
        self.previewImageView.frame = self.overlayView!.contentFrame
        self.previewImageView.clipsToBounds = false;
    }

    // MARK: - Configuration

    private func configureMenuCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = ButtonCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(IMGLYButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCellReuseIdentifier)
        
        let views = [ "collectionView" : collectionView ]
        bottomContainerView.addSubview(collectionView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[collectionView]|", options: [], metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views))
    }

    private func configureOverlay() {

        if overlayView == nil {
            overlayView = IMGLYCropOverlayView(frame: self.previewImageView.bounds)
            self.view.addSubview(overlayView!)
        }

        let viewWidth = CGRectGetWidth(self.previewImageView.bounds)
        let viewHeight = CGRectGetHeight(self.previewImageView.bounds)

        let viewAspectRatio = viewHeight / viewWidth
        let cropAspectRatio = cropSize.height / cropSize.width
        var overlayFrame: CGRect

        if viewAspectRatio > cropAspectRatio {
            overlayFrame = CGRectMake(
                0,
                (viewHeight - (viewWidth * cropAspectRatio)) / 2,
                CGRectGetWidth(self.view.bounds),
                viewWidth * cropAspectRatio)
        } else {
            overlayFrame = CGRectMake(
                (viewWidth - (viewHeight / cropAspectRatio)) / 2,
                0,
                viewHeight / cropAspectRatio,
                viewHeight)
        }

        overlayView!.backgroundColor = UIColor.clearColor()
        overlayView!.userInteractionEnabled = false
        overlayView!.contentFrame = overlayFrame
    }
    
    // MARK: - Helpers
    
    private func subEditorButtonPressed(buttonType: IMGLYMainMenuButtonType) {
        if (buttonType == IMGLYMainMenuButtonType.Magic) {
            if !updating {
                fixedFilterStack.enhancementFilter.enabled = !fixedFilterStack.enhancementFilter.enabled
                updatePreviewImage()
            }
        } else {
            if let viewController = IMGLYInstanceFactory.viewControllerForButtonType(buttonType, withFixedFilterStack: fixedFilterStack) {
                viewController.lowResolutionImage = lowResolutionImage
                viewController.previewImageView.image = previewImageView.image
                viewController.completionHandler = subEditorDidComplete
                
                showViewController(viewController, sender: self)
            }
        }
    }
    
    private func subEditorDidComplete(image: UIImage?, fixedFilterStack: IMGLYFixedFilterStack) {
        previewImageView.image = image
        self.fixedFilterStack = fixedFilterStack
    }
    
    private func generateLowResolutionImage() {
        if let highResolutionImage = self.highResolutionImage {
            if highResolutionImage.size.width > maxLowResolutionSideLength || highResolutionImage.size.height > maxLowResolutionSideLength  {
                let scale: CGFloat
                
                if(highResolutionImage.size.width > highResolutionImage.size.height) {
                    scale = maxLowResolutionSideLength / highResolutionImage.size.width
                } else {
                    scale = maxLowResolutionSideLength / highResolutionImage.size.height
                }
                
                let newWidth  = CGFloat(roundf(Float(highResolutionImage.size.width) * Float(scale)))
                let newHeight = CGFloat(roundf(Float(highResolutionImage.size.height) * Float(scale)))
                lowResolutionImage = highResolutionImage.imgly_normalizedImageOfSize(CGSize(width: newWidth, height: newHeight))
            } else {
                lowResolutionImage = highResolutionImage.imgly_normalizedImage
            }
        }
    }
    
    private func updatePreviewImage() {
        if let lowResolutionImage = self.lowResolutionImage {
            updating = true
            dispatch_async(PhotoProcessorQueue) {
                let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage, filters: self.fixedFilterStack.activeFilters)
                
                dispatch_async(dispatch_get_main_queue()) {
                    let firstTime = self.previewImageView.image == nil
                    
                    self.previewImageView.image = processedImage
                    
                    if (firstTime){
                        // center offset
                        self.previewImageView.initialZoomScaleWasSet = true
                        
                        let imgHight = (processedImage?.size.height)!
                        let imgWidth = (processedImage?.size.width)!
                        
                        let offset = CGPointMake(fabs(self.previewImageView.frame.size.width - imgWidth) / 2.0,
                                                 fabs(self.previewImageView.frame.size.height - imgHight) / 2.0)
                        self.previewImageView.setContentOffset(offset, animated: false)
                        
                        let zoomScale = max(self.previewImageView.frame.size.height / imgHight,
                                            self.previewImageView.frame.size.width / imgWidth)
                        self.previewImageView.minimumZoomScale = zoomScale
                        self.previewImageView.zoomScale = zoomScale
                    }
                    
                    self.updating = false
                }
            }
        }
    }
    
    // MARK: - EditorViewController
    
    override public func tappedDone(sender: UIBarButtonItem?) {
        if let completionBlock = completionBlock {
            highResolutionImage = highResolutionImage?.imgly_normalizedImage
            var filteredHighResolutionImage: UIImage?
            
            if let highResolutionImage = self.highResolutionImage {
                sender?.enabled = false
                dispatch_async(PhotoProcessorQueue) {
                    filteredHighResolutionImage = IMGLYPhotoProcessor.processWithUIImage(highResolutionImage, filters: self.fixedFilterStack.activeFilters)

                    let imageScale = filteredHighResolutionImage!.size.width / self.previewImageView.image!.size.width

                    let cropRect = CGRectMake(
                        self.previewImageView.contentOffset.x / self.previewImageView.zoomScale * imageScale,
                        self.previewImageView.contentOffset.y / self.previewImageView.zoomScale * imageScale,
                        CGRectGetWidth(self.previewImageView.bounds) / self.previewImageView.zoomScale * imageScale,
                        CGRectGetHeight(self.previewImageView.bounds) / self.previewImageView.zoomScale * imageScale)

                    filteredHighResolutionImage = UIImage(CGImage:
                        CGImageCreateWithImageInRect(filteredHighResolutionImage!.CGImage, cropRect)!)

                    if self.memeGenerator != nil {
                        filteredHighResolutionImage = self.memeGenerator!.applyMemeToImage(filteredHighResolutionImage, real: true)
                    }

                    dispatch_async(dispatch_get_main_queue()) {
                        completionBlock(.Done, filteredHighResolutionImage)
                        sender?.enabled = true
                    }
                }
            } else {
                completionBlock(.Done, filteredHighResolutionImage)
            }
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @objc private func cancelTapped(sender: UIBarButtonItem?) {
        if let completionBlock = completionBlock {
            completionBlock(.Cancel, nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    public override var enableZoomingInPreviewImage: Bool {
        return true
    }
}

extension IMGLYMainEditorViewController: UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionButtons.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ButtonCollectionViewCellReuseIdentifier, forIndexPath: indexPath) 
        
        if let buttonCell = cell as? IMGLYButtonCollectionViewCell {
            let actionButton = actionButtons[indexPath.item]
            
            if let selectedImage = actionButton.selectedImage, let showSelectionBlock = actionButton.showSelection where showSelectionBlock() {
                buttonCell.imageView.image = selectedImage
            } else {
                buttonCell.imageView.image = actionButton.image
            }
            
            buttonCell.textLabel.text = actionButton.title
        }
        
        return cell
    }
}

extension IMGLYMainEditorViewController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let actionButton = actionButtons[indexPath.item]
        actionButton.handler()
        
        if actionButton.selectedImage != nil && actionButton.showSelection != nil {
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }
}

extension IMGLYMainEditorViewController: UINavigationControllerDelegate {
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return IMGLYNavigationAnimationController()
    }
}
