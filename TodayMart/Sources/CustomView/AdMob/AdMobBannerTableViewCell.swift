//
//  AdMobBannerTableViewCell.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 14/05/2019.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import SnapKit

class AdMobBannerTableViewCell: UITableViewCell {

    var bannerView: GADBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        contentView.addSubview(bannerView)
        
        bannerView.snp.makeConstraints({
            $0.top.equalTo(contentView.snp.top).offset(0)
            $0.leading.equalTo(contentView.snp.leading).offset(0)
            $0.trailing.equalTo(contentView.snp.trailing).offset(0)
            $0.bottom.equalTo(contentView.snp.bottom).offset(0)
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bannerView.adUnitID = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func loadAd(adUnitId: String) {
        bannerView.adUnitID = adUnitId
        let admobRequest: GADRequest = GADRequest()
        admobRequest.testDevices = ["d33705983b89f6867acfe7f7564ae9b0"]
        bannerView.delegate = self
        bannerView.load(admobRequest)
    }
}

// MARK: - GADBannerViewDelegate
extension AdMobBannerTableViewCell: GADBannerViewDelegate {
    // 광고 수신 완료
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    // 광고 요청 실패
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    // 전체화면 광고 present
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    // 전체화면 광고 dismiss 전
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    // 전체화면 광고 dismiss 후
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    // 광고 클릭으로 다른앱 이동
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
