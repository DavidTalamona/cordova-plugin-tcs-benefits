//
//  TCSBenefitsCardView.swift
//  interface-tcs-ios
//
//  Created by Tobias Herrmann on 13.12.17.
//  Copyright © 2017 apNet AG. All rights reserved.
//

import Foundation
import TCSSDK
import UIKit

protocol TCSBenefitsCardViewDelegate: TCSModuleCardViewBaseDelegate {

}

enum ViewState : String {
    case NORMAL = "NORMAL"
    case ERROR = "ERROR"
    case LOGIN = "LOGIN"
    case LOADER = "LOADER"
}

internal class TCSBenefitsCardView : TCSBaseCardView {

    weak var benefitsCardViewDelegate: TCSBenefitsCardViewDelegate?
    fileprivate var container: TCSBenefitsCardViewContainer!

    private var tcsUser: TCSUserComponent?

    private var apiData: [String: Any]?
    private var apiDataCommon: Data?

    private var errorVisible = false
    private var loginVisible = false

    private static let moduleHeaderHeight: CGFloat = 60
    private static let boxWidth = UIScreen.main.bounds.size.width - 20 - 40; // 20 is spacing between module box and screen, 40 is padding in box
    private static let oneThirdModuleWidth = TCSBenefitsCardView.boxWidth / 3

    private var currentViewState: ViewState = ViewState.NORMAL

    var promoVideoUrl: String = ""
    private var promoVideoPreviewImageUrl: String = ""

    override func setupContentView() {

        self.tcsUser = TCSBenefitsModule.getTcsProvider()!.getTCSUserComponent()

        container = TCSBenefitsCardViewContainer.benefitsViewFromXIB() as! TCSBenefitsCardViewContainer
        contentView.benefitsAddFullsizeSubview(container)

        // loading images/fonts, must be done in swift code, because interface builder cannot handle assets inside framework files...
        container.logoutViewCollapsedImage.image = UIImage(named: "dummypic", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.logoutViewCollapsedPlayButton.image = UIImage(named: "play-button icon", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.logoutViewExpandedImage.image = UIImage(named: "dummypic", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.logoutViewExpandedPlayButton.image = UIImage(named: "play-button icon", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.errorViewCollapsedImage.image = UIImage(named: "smiley-thinking icon S", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.errorViewExpandedImage.image = UIImage(named: "smiley-thinking icon", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.errorViewExpandedButton.setImage(UIImage(named: "synchronize icon", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil), for: .normal)
        container.normalViewCollapsedImage.image = UIImage(named: "my benefits icon", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.normalViewExpandedImage1.image = UIImage(named: "my benefits icon", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.normalViewExpandedImage2.image = UIImage(named: "sofort benefit icon S", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.normalViewExpandedImage3.image = UIImage(named: "circle", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
        container.normalViewExpandedImage4.image = UIImage(named: "credit card icon", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)

        UIFont.loadAllFonts(bundleIdentifierString: Bundle(for: TCSBenefitsModule.self).bundleIdentifier!)
        container.logoutViewCollapsedText1.font = UIFont(name: "MuseoSlab-700", size: 15)
        container.logoutViewCollapsedText2.font = UIFont(name: "MuseoSans-300", size: 13)
        container.logoutViewExpandedText.font = UIFont(name: "MuseoSans-300", size: 13)
        container.errorViewCollapsedText1.font = UIFont(name: "MuseoSans-300", size: 15)
        container.errorViewCollapsedText2.font = UIFont(name: "MuseoSans-300", size: 13)
        container.errorViewExpandedText1.font = UIFont(name: "MuseoSans-300", size: 13)
        container.errorViewExpandedText2.font = UIFont(name: "MuseoSans-300", size: 13)
        container.errorViewExpandedText3.font = UIFont(name: "MuseoSans-300", size: 13)
        container.errorViewExpandedButton.titleLabel?.font = UIFont(name: "MuseoSlab-700", size: 15)
        container.normalViewCollapsedTotalCashback.font = UIFont(name: "MuseoSans-700", size: 15)
        container.normalViewCollapsedText1.font = UIFont(name: "MuseoSans-300", size: 15)
        container.normalViewCollapsedText2.font = UIFont(name: "MuseoSans-300", size: 13)
        container.normalViewExpandedTotalCashback.font = UIFont(name: "MuseoSlab-700", size: 30)
        container.normalViewExpandedText5.font = UIFont(name: "MuseoSlab-700", size: 20)
        container.normalViewExpandedText1.font = UIFont(name: "MuseoSans-700", size: 15)
        container.normalViewExpandedInstantCashback.font = UIFont(name: "MuseoSlab-700", size: 20)
        container.normalViewExpandedBenefitCashback.font = UIFont(name: "MuseoSlab-700", size: 20)
        container.normalViewExpandedCreditCashback.font = UIFont(name: "MuseoSlab-700", size: 20)
        container.normalViewExpandedText2.font = UIFont(name: "MuseoSans-300", size: 9)
        container.normalViewExpandedText3.font = UIFont(name: "MuseoSans-300", size: 9)
        container.normalViewExpandedText4.font = UIFont(name: "MuseoSans-300", size: 9)
        container.normalViewExpandedText6.font = UIFont(name: "MuseoSans-300", size: 13)

        // enable multiline for label
        container.normalViewExpandedText2.lineBreakMode = .byWordWrapping
        container.normalViewExpandedText2.numberOfLines = 0;
        container.normalViewExpandedText3.lineBreakMode = .byWordWrapping
        container.normalViewExpandedText3.numberOfLines = 0;
        container.normalViewExpandedText4.lineBreakMode = .byWordWrapping
        container.normalViewExpandedText4.numberOfLines = 0;

        // calculate 1/3 box width for layout weight groups and apply to elements
        container.normalViewExpandedGroup1Element1Width.constant = TCSBenefitsCardView.oneThirdModuleWidth
        container.normalViewExpandedWeightGroup1Element2.widthAnchor.constraint(equalToConstant: TCSBenefitsCardView.oneThirdModuleWidth).isActive = true
        container.normalViewExpandedGroup1Element3Width.constant = TCSBenefitsCardView.oneThirdModuleWidth

        container.normalViewExpandedText2.widthAnchor.constraint(equalToConstant: TCSBenefitsCardView.oneThirdModuleWidth).isActive = true
        container.normalViewExpandedText3.widthAnchor.constraint(equalToConstant: TCSBenefitsCardView.oneThirdModuleWidth).isActive = true
        container.normalViewExpandedText4.widthAnchor.constraint(equalToConstant: TCSBenefitsCardView.oneThirdModuleWidth).isActive = true

        // make rounded corners to buttons
        container.errorViewExpandedButton.layer.cornerRadius = 4

        // add click events
        container.logoutViewCollapsedText2.isUserInteractionEnabled = true
        container.logoutViewCollapsedText2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(normalStart)))
        container.logoutViewExpandedText.isUserInteractionEnabled = true
        container.logoutViewExpandedText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(normalStart)))

        container.errorViewCollapsedText2.isUserInteractionEnabled = true
        container.errorViewCollapsedText2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(normalStart)))
        container.errorViewExpandedText3.isUserInteractionEnabled = true
        container.errorViewExpandedText3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(normalStart)))
        container.errorViewExpandedButton.addTarget(self, action: #selector(refreshDataWrapper), for: .touchUpInside)

        container.normalViewCollapsedText2.isUserInteractionEnabled = true
        container.normalViewCollapsedText2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(normalStart)))
        container.normalViewExpandedClickArea1.isUserInteractionEnabled = true
        container.normalViewExpandedClickArea1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cashbackStart)))
        container.normalViewExpandedClickArea2.isUserInteractionEnabled = true
        container.normalViewExpandedClickArea2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cashbackStart)))
        container.normalViewExpandedText6.isUserInteractionEnabled = true
        container.normalViewExpandedText6.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(normalStart)))

        container.logoutViewCollapsedArea.isUserInteractionEnabled = true
        container.logoutViewCollapsedArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startVideo)))
        container.logoutViewExpandedArea.isUserInteractionEnabled = true
        container.logoutViewExpandedArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startVideo)))

        updateLocalizableStrings()
        adjustBenefitLabelPosition()
    }

    private func adjustBenefitLabelPosition() {
        // adjust position of label before image (benefit cashback)
        let indentLabelToImage :CGFloat = 15
        let widthImageAndLabel :CGFloat = container.normalViewExpandedText3.intrinsicContentSize.width + indentLabelToImage
        let remainingSpaceLeft = (TCSBenefitsCardView.oneThirdModuleWidth - widthImageAndLabel) / 2

        container.normalViewExpandedImage3SpacingLeft.constant = remainingSpaceLeft
        container.normalViewExpandedText3SpacingLeft.constant = remainingSpaceLeft + indentLabelToImage
    }

    override func updateState(isExpanded: Bool) {
        super.updateState(isExpanded: isExpanded)
        refreshViews()
    }

    private func refreshViews() {

        DispatchQueue.main.async(){
            // hide all containers
            self.container.logoutViewExpanded.isHidden = true
            self.container.logoutViewCollapsed.isHidden = true
            self.container.errorViewCollapsed.isHidden = true
            self.container.errorViewExpanded.isHidden = true
            self.container.normalViewCollapsed.isHidden = true
            self.container.normalViewExpanded.isHidden = true
            self.container.loaderView.isHidden = true

            // show the right container
            if (self.currentViewState == ViewState.ERROR) {
                if (self.isExpanded) {
                    self.container.errorViewExpanded.isHidden = false
                } else {
                    self.container.errorViewCollapsed.isHidden = false
                }
            } else if (self.currentViewState == ViewState.LOGIN) {
                // show promo video if available
                if (self.promoVideoUrl != "") {
                    self.container.logoutViewExpandedPlayButton.isHidden = false
                    self.container.logoutViewCollapsedPlayButton.isHidden = false
                } else {
                    self.container.logoutViewExpandedPlayButton.isHidden = true
                    self.container.logoutViewCollapsedPlayButton.isHidden = true
                }

                if (self.promoVideoPreviewImageUrl != "") {
                    self.downloadImage(url: self.promoVideoPreviewImageUrl, imageViewOne: self.container.logoutViewExpandedImage, imageViewTwo: self.container.logoutViewCollapsedImage)
                } else {
                    self.container.logoutViewCollapsedImage.image = UIImage(named: "dummypic", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
                    self.container.logoutViewExpandedImage.image = UIImage(named: "dummypic", in: Bundle(for: TCSBenefitsModule.self), compatibleWith: nil)
                }


                // display correct state
                if (self.isExpanded) {
                    self.container.logoutViewExpanded.isHidden = false
                } else {
                    self.container.logoutViewCollapsed.isHidden = false
                }
            } else if (self.currentViewState == ViewState.LOADER) {
                self.container.loaderView.isHidden = false
            } else {
                if (self.isExpanded) {
                    self.container.normalViewExpanded.isHidden = false
                } else {
                    self.container.normalViewCollapsed.isHidden = false
                }
            }

            self.delegate?.cardViewInvokesToUpdateHeight(self)
        }
    }

    private func downloadImage(url: String, imageViewOne: UIImageView, imageViewTwo: UIImageView) {
        let urlWrapper = URL(string: url)
        URLSession.shared.dataTask(with: (urlWrapper)!, completionHandler: {(data, response, error) -> Void in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageViewOne.image = UIImage(data: data)
                imageViewTwo.image = UIImage(data: data)
            }
        }).resume()
    }

    override func updateLocalizableStrings() {
        DispatchQueue.main.async(){

            let path = Bundle(for: TCSBenefitsModule.self).path(forResource: TCSBenefitsModule.currentLanguage, ofType: "lproj")
            let bundle = Bundle(path: path!)!

            TCSBenefitsModule.moduleName = NSLocalizedString("CardTitle", bundle: bundle, comment: "")

            self.container.logoutViewCollapsedText1.text = NSLocalizedString("logoutViewText1", bundle: bundle, comment: "")
            self.container.logoutViewCollapsedText2.text = NSLocalizedString("logoutViewText2", bundle: bundle, comment: "")
            self.container.logoutViewExpandedText.text = NSLocalizedString("logoutViewText2", bundle: bundle, comment: "")

            self.container.errorViewCollapsedText1.text = NSLocalizedString("errorViewText1", bundle: bundle, comment: "")
            self.container.errorViewCollapsedText2.text = NSLocalizedString("errorViewText2", bundle: bundle, comment: "")
            self.container.errorViewExpandedText1.text = NSLocalizedString("errorViewText1Part1", bundle: bundle, comment: "")
            self.container.errorViewExpandedText2.text = NSLocalizedString("errorViewText1Part2", bundle: bundle, comment: "")
            self.container.errorViewExpandedButton.titleLabel?.text = NSLocalizedString("errorViewButton", bundle: bundle, comment: "")
            self.container.errorViewExpandedText3.text = NSLocalizedString("errorViewText2", bundle: bundle, comment: "")

            self.container.normalViewCollapsedText1.text = NSLocalizedString("normalViewText1", bundle: bundle, comment: "")
            self.container.normalViewCollapsedText2.text = NSLocalizedString("normalViewText2", bundle: bundle, comment: "")
            self.container.normalViewExpandedText1.text = NSLocalizedString("normalViewText3", bundle: bundle, comment: "")
            self.container.normalViewExpandedText2.text = NSLocalizedString("normalViewText4", bundle: bundle, comment: "")
            self.container.normalViewExpandedText3.text = NSLocalizedString("normalViewText5", bundle: bundle, comment: "")
            self.container.normalViewExpandedText4.text = NSLocalizedString("normalViewText6", bundle: bundle, comment: "")
            self.container.normalViewExpandedText6.text = NSLocalizedString("normalViewText2", bundle: bundle, comment: "")
        }
    }

    @objc(normalStart)
    private func normalStart() {
        startFullScreen()
    }

    @objc(getToKnowStart)
    private func getToKnowStart() {
        setStartupType(page: "GetToKnow")
        startFullScreen()
    }

    @objc(cashbackStart)
    private func cashbackStart() {
        setStartupType(page: "Cashback")
        startFullScreen()
    }

    @objc(startVideo)
    private func startVideo() {
        DispatchQueue.main.async() {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                let videoController = TCSBenefitsVideoController.init(videoUrl: self.promoVideoUrl)
                topController.present(videoController, animated: true, completion: nil)
            }
        }
    }

    override func desiredContentHeight() -> CGFloat? {
        if (self.currentViewState == ViewState.ERROR) {
            if (self.isExpanded) {
                return 248 + TCSBenefitsCardView.moduleHeaderHeight // 248 = 30 + 30 + 20 + 13 + 5 + 13 + 20 + 44 + 30 + 13 + 30
            } else {
                return 123 + TCSBenefitsCardView.moduleHeaderHeight // 123 = 30 + 20 + 30 + 13 + 30
            }
        } else if (self.currentViewState == ViewState.LOGIN) {
            if (self.isExpanded) {
                let imageWidth = TCSBenefitsCardView.boxWidth
                let imageHeight = imageWidth * (10/16) // picture has 16:10 aspect ratio

                return 103 + imageHeight + TCSBenefitsCardView.moduleHeaderHeight // 103 = 30 + 30 + 13 + 30
            } else {
                return 153 + TCSBenefitsCardView.moduleHeaderHeight // 153 = 30 + 50 + 30 + 13 + 30
            }
        } else if (self.currentViewState == ViewState.LOADER) {
            return 30 + 30 + 30 + TCSBenefitsCardView.moduleHeaderHeight
        } else {
            if (self.isExpanded) {
                return 334 + TCSBenefitsCardView.moduleHeaderHeight // 334 = 30 + 30 + 30 + 30 + 15 + 20 + 1 + 15 + 45 + 15 + 30 + 30 + 13 + 30
            } else {
                return 123 + TCSBenefitsCardView.moduleHeaderHeight // 123 = 30 + 20 + 30 + 13 + 30
            }
        }
    }

    override func actualContentHeight() -> CGFloat? {
        return desiredContentHeight()
    }

    private func showErrorState() {
        if (currentViewState != ViewState.ERROR) {
            currentViewState = ViewState.ERROR
            refreshViews()
        }
    }

    private func showLoginState() {
        if (currentViewState != ViewState.LOGIN) {
            currentViewState = ViewState.LOGIN
            refreshViews()
        }
    }

    private func showNormalState() {
        if (currentViewState != ViewState.NORMAL) {
            currentViewState = ViewState.NORMAL
            refreshViews()
        }
    }

    private func showLoaderState() {
        if (currentViewState != ViewState.LOADER) {
            currentViewState = ViewState.LOADER
            refreshViews()
        }
    }

    @objc(refreshDataWrapper)
    private func refreshDataWrapper() {
        TCSBenefitsModule.refreshData(isDoingRefresh: true)
    }

    func loadApiData(isDoingRefresh: Bool) {

        self.showLoaderState()

        if (self.tcsUser!.isLoggedIn()) {

            let userProfile = self.tcsUser!.getUserProfile()!

            let url = "https://www.pluscash.ch/api/app/tcs/nativeData/" + userProfile.refPerson
            let urlWrapper = URL(string: url)

            URLSession.shared.dataTask(with: (urlWrapper)!, completionHandler: {(data, response, error) -> Void in

                if (error != nil) {
                    self.showErrorState()
                } else {

                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {

                        if let cashback = jsonObj?.value(forKey: "benefit") as? NSDictionary {
                            if let benefitCashbackObj = cashback.value(forKey: "cashback") as? NSDictionary {
                                if let benefitCashback = benefitCashbackObj.value(forKey: "total") {
                                    if let instantCashbackObj = cashback.value(forKey: "instant") as? NSDictionary {
                                        if let instantCashback = instantCashbackObj.value(forKey: "total") {
                                            if let creditCardCashbackObj = cashback.value(forKey: "creditCard") as? NSDictionary {
                                                if let creditCardCashback = creditCardCashbackObj.value(forKey: "total") {

                                                    let benefitCashbackDbl = Double(String.init(describing: benefitCashback))!
                                                    let instantCashbackDbl = Double(String.init(describing: instantCashback))!
                                                    let creditCardCashbackDbl = Double(String.init(describing: creditCardCashback))!

                                                    let totalCashbackDbl = benefitCashbackDbl + instantCashbackDbl + creditCardCashbackDbl

                                                    DispatchQueue.main.async(){
                                                        self.container.normalViewCollapsedTotalCashback.text = String(format: "%.2f", totalCashbackDbl)
                                                        self.container.normalViewExpandedTotalCashback.text = String(format: "%.2f", totalCashbackDbl)
                                                        self.container.normalViewExpandedInstantCashback.text = String(format: "%.2f", instantCashbackDbl)
                                                        self.container.normalViewExpandedBenefitCashback.text = String(format: "%.2f", benefitCashbackDbl)
                                                        self.container.normalViewExpandedCreditCashback.text = String(format: "%.2f", creditCardCashbackDbl)

                                                        self.adjustBenefitLabelPosition()

                                                        self.showNormalState()
                                                    }

                                                } else {
                                                    self.showErrorState()
                                                }
                                            } else {
                                                self.showErrorState()
                                            }
                                        } else {
                                            self.showErrorState()
                                        }
                                    } else {
                                        self.showErrorState()
                                    }
                                } else {
                                    self.showErrorState()
                                }
                            } else {
                                self.showErrorState()
                            }
                        } else {
                            self.showErrorState()
                        }

                    } else {
                        self.showErrorState()
                    }
                }

            }).resume()

        } else {

            let url = "https://www.pluscash.ch/api/app/tcs/nativeDataCommon/"
            let urlWrapper = URL(string: url)

            if (isDoingRefresh) {
                URLSession.shared.dataTask(with: (urlWrapper)!, completionHandler: {(data, response, error) -> Void in
                    self.apiDataCommon = data

                    if (error != nil) {
                        self.showLoginState()
                    } else {
                        self.handleCommonApiData(data: data)
                    }
                }).resume()
            } else {
                handleCommonApiData(data: apiDataCommon)
            }
        }
    }

    private func handleCommonApiData(data: Data?) {
        if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
            if let promoVideo = jsonObj?.value(forKey: "promoVideo") as? NSDictionary {

                var languageKey = "de"
                if (Locale.preferredLanguages[0].range(of:"fr") != nil) {
                    languageKey = "fr"
                } else if (Locale.preferredLanguages[0].range(of:"it") != nil) {
                    languageKey = "it"
                }

                if let videoUrl = promoVideo.value(forKey: languageKey) {
                    self.promoVideoUrl = String.init(describing: videoUrl)
                    if let previewImageUrl = promoVideo.value(forKey: "previewImage") {
                        self.promoVideoPreviewImageUrl = String.init(describing: previewImageUrl)
                    }
                    self.setVideoActive(isActive: true)
                } else {
                    self.setVideoActive(isActive: false)
                }
            } else {
                self.setVideoActive(isActive: false)
            }
        } else {
            self.setVideoActive(isActive: false)
        }
    }

    private func setVideoActive(isActive: Bool) {
        if (!isActive) {
            self.promoVideoUrl = ""
            self.promoVideoPreviewImageUrl = ""
        }
        self.showLoginState()
    }

    private func setStartupType(page: String) {
        let jsonObject: [String: Any] = [
            "type": "startup",
            "page": page
        ]
        TCSBenefitsModule.startupJSON = jsonObject
    }
}
