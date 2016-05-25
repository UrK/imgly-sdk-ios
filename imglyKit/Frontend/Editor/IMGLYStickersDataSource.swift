//
//  IMGLYStickersDataSource.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public protocol IMGLYStickersDataSourceDelegate: class, UICollectionViewDataSource {
    var stickers: [IMGLYSticker] { get }
}

public class IMGLYStickersDataSource: NSObject, IMGLYStickersDataSourceDelegate {
    public let stickers: [IMGLYSticker]
    
    override init() {
        let stickerFiles = [
            "glasses_nerd",
            "glasses_normal",
            "glasses_shutter_green",
            "glasses_shutter_yellow",
            "glasses_sun",
            "hat_cap",
            "hat_party",
            "hat_sherrif",
            "hat_zylinder",
            "heart",
            "mustache_long",
            "mustache1",
            "mustache2",
            "mustache3",
            "pipe",
            "snowflake",
            "star",
            "huh",
            "crunch",
            "bang",
            "craaack",
            "exclamation_01",
            "ouch",
            "splat",
            "boom",
            "powpow",
            "zap",
            "zaap",
            "zam",
            "zwosh",
            "wham",
            "exclamation_02",
            "whap",
            "clang",
            "zaaap",
            "vroom",
            "pow",
            "1439051786_4172",
            "4c9EG6pKi",
            "4cb4yL5di",
            "Blue-and-pink-carnival-mask-clip-art-image",
            "ClownWig",
            "Cool-Smilies-Vector-Icon-Set_0000_Layer-2",
            "Cool-Smilies-Vector-Icon-Set_0001_Layer-3",
            "Cool-Smilies-Vector-Icon-Set_0002_Layer-4",
            "Cool-Smilies-Vector-Icon-Set_0003_Layer-5",
            "Cool-Smilies-Vector-Icon-Set_0004_Layer-6",
            "Eyes-&-Mouths_0000_Layer-2",
            "Eyes-&-Mouths_0001_Layer-3",
            "Eyes-&-Mouths_0002_Layer-5",
            "Eyes-&-Mouths_0003_Layer-6",
            "Eyes-&-Mouths_0004_Layer-7",
            "Eyes-&-Mouths_0005_Layer-8",
            "Eyes-&-Mouths_0006_Layer-9",
            "Flib's_Wig",
            "Free-hat-clip-art-clipart-clipart-clipartcow",
            "Hat-clip-art-borders-free-clipart-images-2",
            "Mustache_20_2B_20Glasses_original",
            "Party_hat_set_0000_Layer-2",
            "Party_hat_set_0001_Layer-3",
            "Party_hat_set_0002_Layer-4",
            "Party_hat_set_0003_Layer-5",
            "Party_hat_set_0004_Layer-6",
            "Red-Wig",
            "Top-hat-clipart-free-clipart-images",
            "beard-clipart-61c7cae2020e404d9e61f5d0b01b525a_p_400",
            "bow-tie-clipart-06",
            "brown-hair-clipart-brown-wig-md",
            "brown-hair-clipart-mustachebrown",
            "cowboy-hat-clipart-03",
            "di7oRgrkT",
            "eyes-clipart-09",
            "funny-glasses-2",
            "hat-clip-art-orange-hat-md",
            "hat-clipart-jester-hat",
            "mustache-clipart-mustache",
            "orange-tie",
            "party_glasses_clipart_by_marinka7-d8j3u1t",
            "rinrAXkqT",
            "wig-hi"
        ]
        
        stickers = stickerFiles.map { (file: String) -> IMGLYSticker? in
            if let image = UIImage(named: file, inBundle: NSBundle(forClass: IMGLYStickersDataSource.self), compatibleWithTraitCollection: nil) {
                let thumbnail = UIImage(named: file + "_thumbnail", inBundle: NSBundle(forClass: IMGLYStickersDataSource.self), compatibleWithTraitCollection: nil)
                return IMGLYSticker(image: image, thumbnail: thumbnail)
            }
            
            return nil
            }.filter { $0 != nil }.map { $0! }
        
        super.init()
    }
    
    public init(stickers: [IMGLYSticker]) {
        self.stickers = stickers
        super.init()
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StickersCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! IMGLYStickerCollectionViewCell
        
        cell.imageView.image = stickers[indexPath.row].thumbnail ?? stickers[indexPath.row].image
        
        return cell
    }
}
