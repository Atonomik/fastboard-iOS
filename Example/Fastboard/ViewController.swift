//
//  ViewController.swift
//  Fastboard
//
//  Created by yunshi on 12/22/2021.
//  Copyright (c) 2021 yunshi. All rights reserved.
//

import UIKit
import Fastboard
import Whiteboard
import SnapKit

extension WhiteApplianceNameKey: CaseIterable {
    public static var allCases: [WhiteApplianceNameKey] {
        [.ApplianceClicker,
         .AppliancePencil,
         .ApplianceSelector,
         .ApplianceText,
         .ApplianceEllipse,
         .ApplianceRectangle,
         .ApplianceEraser,
         .ApplianceStraight,
         .ApplianceArrow,
         .ApplianceHand,
         .ApplianceLaserPointer
        ]
    }
}

extension WhiteApplianceShapeTypeKey: CaseIterable {
    public static var allCases: [WhiteApplianceShapeTypeKey] {
        [
            .ApplianceShapeTypeTriangle,
            .ApplianceShapeTypeRhombus,
            .ApplianceShapeTypePentagram,
            .ApplianceShapeTypeSpeechBalloon
        ]
    }
}

class ViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.landscape, .portrait]
    }
    
    
    var fastRoom: FastRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCustomApps()
    }
    
    func setupViews() {
        view.backgroundColor = .gray
        setupFastboard()
        setupMediaTools()
    }
    
    func setupCustomApps() {
        guard let js = Bundle.main.url(forResource: "monaco.iife", withExtension: "js")
        else { return }
        let jsCode = try! String(contentsOf: js)
        let params = WhiteRegisterAppParams(javascriptString: jsCode, kind: "Monaco", variable: "NetlessAppMonaco.default")
        fastRoom.whiteSDK.registerApp(with: params) { error in
            
        }
        				
        guard let youtubeJs = Bundle.main.url(forResource: "plyr.iife", withExtension: "js")
        else { return }
        let youtubeJsCode = try! String(contentsOf: youtubeJs)
        let youtubeParams = WhiteRegisterAppParams(javascriptString: youtubeJsCode, kind: "Plyr", variable: "NetlessAppPlyr.default")
        fastRoom.whiteSDK.registerApp(with: youtubeParams) { error in
            
        }
    }
    
    func setupFastboard(custom: FastRoomOverlay? = nil) {
        let config: FastRoomConfiguration = FastRoomConfiguration(appIdentifier: RoomInfo.APPID.value,
                                           roomUUID: RoomInfo.ROOMUUID.value,
                                           roomToken: RoomInfo.ROOMTOKEN.value,
                                            region: .US,
                                           userUID: "ahmet")
        config.customOverlay = custom
        let fastRoom = Fastboard.createFastRoom(withFastRoomConfig: config)
        fastRoom.delegate = self
        let fastRoomView = fastRoom.view
        view.addSubview(fastRoomView)
        fastRoomView.frame = view.bounds
        
        fastRoomView.translatesAutoresizingMaskIntoConstraints = false
        fastRoomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        fastRoomView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        fastRoomView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        fastRoomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        let activity: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            activity = UIActivityIndicatorView(style: .medium)
        } else {
            activity = UIActivityIndicatorView(style: .gray)
        }
        fastRoomView.addSubview(activity)
        activity.snp.makeConstraints { $0.center.equalToSuperview() }
        activity.startAnimating()
        mediaControlView.isHidden = false
        fastRoom.joinRoom { _ in
            activity.stopAnimating()
            self.mediaControlView.isHidden = false
        }
        self.fastRoom = fastRoom
    }
    
    func setupMediaTools() {
        view.addSubview(mediaControlView)
        mediaControlView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(fastRoom.view.snp.top)
            make.height.equalTo(44)
        }
    }
    
    func reloadFastboard(overlay: FastRoomOverlay? = nil) {
        fastRoom.view.removeFromSuperview()
        setupFastboard(custom: overlay)
    }
    
    var isHide = false {
        didSet {
            fastRoom.setAllPanel(hide: isHide)
            let str = NSLocalizedString(isHide ? "On" : "Off", comment: "")
        }
    }
    
    var currentTheme: ExampleTheme = .auto {
        didSet {
            switch currentTheme {
            case .light:
                FastRoomThemeManager.shared.apply(FastRoomDefaultTheme.defaultLightTheme)
            case .dark:
                FastRoomThemeManager.shared.apply(FastRoomDefaultTheme.defaultDarkTheme)
            case .auto:
                if #available(iOS 13, *) {
                    FastRoomThemeManager.shared.apply(FastRoomDefaultTheme.defaultAutoTheme)
                } else {
                    return
                }
            }
        }
    }
    
    func applyNextTheme() -> ExampleTheme {
        let all = ExampleTheme.allCases
        let index = all.firstIndex(of: self.currentTheme)!
        if index == all.count - 1 {
            self.currentTheme = all.first!
        } else {
            let targetCurrentTheme = all[index + 1]
            if targetCurrentTheme == .auto {
                if #available(iOS 13, *) {
                    self.currentTheme = targetCurrentTheme
                } else {
                    self.currentTheme = all.first!
                }
            } else {
                self.currentTheme = targetCurrentTheme
            }
        }
        usingCustomTheme = false
        return self.currentTheme
    }
    
    var usingCustomTheme: Bool = false {
        didSet {
            if usingCustomTheme {
                FastRoomControlBar.appearance().itemWidth = 26
                FastRoomControlBar.appearance().commonRadius = 4
                FastRoomPanelItemButton.appearance().indicatorInset = .init(top: 0, left: 0, bottom: 3, right: 3)
                let white = FastRoomWhiteboardAssets(whiteboardBackgroundColor: .white,
                                             containerColor: .gray)
                let control = FastRoomControlBarAssets(backgroundColor: .init(hexString: customColor.controlBarBg),
                                               borderColor: .clear,
                                               effectStyle: .init(style: .regular))
                let panel = FastRoomPanelItemAssets(normalIconColor: .white,
                                                    selectedIconColor: .init(hexString: customColor.selColor),
                                                    selectedIconBgColor: .init(hexString: customColor.iconSelectedBgColor),
                                                    highlightColor: .init(hexString: customColor.highlightColor),
                                                    highlightBgColor: .clear,
                                                    disableColor: UIColor.gray.withAlphaComponent(0.7),
                                                    subOpsIndicatorColor: .white,
                                                    pageTextLabelColor: .white,
                                                    selectedBackgroundCornerradius: 0,
                                                    selectedBackgroundEdgeinset: .zero)
                let theme = FastRoomThemeAsset(whiteboardAssets: white,
                                       controlBarAssets: control,
                                       panelItemAssets: panel)
                FastRoomThemeManager.shared.apply(theme)
            } else {
                FastRoomPanelItemButton.appearance().indicatorInset = .init(top: 0, left: 0, bottom: 8, right: 8)
                FastRoomControlBar.appearance().commonRadius = 10
                FastRoomControlBar.appearance().itemWidth = 44
                let i = self.currentTheme
                self.currentTheme = i
            }
        }
    }
    
    var storedColors: [UIColor] = FastRoomDefaultOperationItem.defaultColors
    var usingCustomPanelItemColor: Bool = false {
        didSet {
            if usingCustomPanelItemColor {
                FastRoomDefaultOperationItem.defaultColors = [.red, .yellow, .blue]
            } else {
                FastRoomDefaultOperationItem.defaultColors = storedColors
            }
            self.reloadFastboard(overlay: nil)
        
        }
    }
    
    var defaultPhoneItems = CompactFastRoomOverlay.defaultCompactAppliance
    var usingCustomPhoneItems = false {
        didSet {
            if usingCustomTheme {
                CompactFastRoomOverlay.defaultCompactAppliance = [.AppliancePencil, .ApplianceSelector, .ApplianceEraser]
            } else {
                CompactFastRoomOverlay.defaultCompactAppliance = defaultPhoneItems
            }
            reloadFastboard(overlay: nil)
            
        }
    }
    
    var defaultPadItems = RegularFastRoomOverlay.customOperationPanel
    var usingCustomPadItems = false {
        didSet {
            if usingCustomPadItems {
                var items: [FastRoomOperationItem] = []
                let shape = SubOpsItem(subOps: RegularFastRoomOverlay.shapeItems)
                items.append(shape)
                items.append(FastRoomDefaultOperationItem.selectableApplianceItem(.AppliancePencil, shape: nil))
                items.append(FastRoomDefaultOperationItem.clean())
                let panel = FastRoomPanel(items: items)
                RegularFastRoomOverlay.customOperationPanel = {
                    return panel
                }
            } else {
                RegularFastRoomOverlay.customOperationPanel = defaultPadItems
            }
            reloadFastboard(overlay: nil)
        }
    }
    
    var usingCustomIcons = false {
        didSet {
            if usingCustomIcons {
                FastRoomThemeManager.shared.updateIcons(using: Bundle.main)
            } else {
                let path = Bundle(for: Fastboard.self).path(forResource: "Icons", ofType: "bundle")
                let bundle = Bundle(path: path!)!
                FastRoomThemeManager.shared.updateIcons(using: bundle)
            }
            AppearanceManager.shared.commitUpdate()
            reloadFastboard()
            view.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    var usingCustomOverlay = false {
        didSet {
            if usingCustomOverlay {
                self.reloadFastboard(overlay: CustomFastboardOverlay())
                FastRoomControlBar.appearance().itemWidth = 66
                AppearanceManager.shared.commitUpdate()
            } else {
                reloadFastboard()
                FastRoomControlBar.appearance().itemWidth = 44
                AppearanceManager.shared.commitUpdate()
            }
        }
    }
    
    var hideAllPanel = false {
        didSet {
            fastRoom.view.overlay?.setAllPanel(hide: hideAllPanel)
        }
    }
    
    func insertItem(_ item: StorageItem) {
        if item.fileType == .img {
            URLSession.shared.downloadTask(with: URLRequest(url: item.fileURL)) { url, r, err in
                guard
                    let url = url,
                    let data = try? Data(contentsOf: url),
                    let img = UIImage(data: data)
                else {
                    return
                }
                self.fastRoom.insertImg(item.fileURL, imageSize: img.size)
            }.resume()
        }
        if item.fileType == .video ||
            item.fileType == .music {
            self.fastRoom.insertMedia(item.fileURL, title: item.fileName, completionHandler: nil)
            return
        }
        WhiteConverterV5.checkProgress(withTaskUUID: item.taskUUID,
                                       token: item.taskToken,
                                       region: item.region,
                                       taskType: item.taskType) { info, error in
            if let error = error {
                print(error)
                return
            }
            guard let info = info else { return }
            let pages = info.progress?.convertedFileList ?? []
            switch item.fileType {
            case .img, .music, .video:
                return
            case .word, .pdf:
                self.fastRoom.insertStaticDocument(pages,
                                                    title: item.fileName,
                                                    completionHandler: nil)
            case .ppt:
                if item.taskType == .dynamic {
                    self.fastRoom.insertPptx(pages,
                                              title: item.fileName,
                                              completionHandler: nil)
                } else {
                    self.fastRoom.insertStaticDocument(pages,
                                                        title: item.fileName,
                                                        completionHandler: nil)
                }
            default:
                return
            }
        }
    }
    
    
    lazy var mediaControlView = ExampleControlView(items: [
        .init(title: NSLocalizedString("Insert Mock PPTX", comment: ""), status: nil, clickBlock: { [unowned self] _ in
            if let item = storage.first(where: { $0.taskType == .dynamic }) {
                self.insertItem(item)
                self.fastRoom.room?.setViewMode(.broadcaster)
            }
        }),
        .init(title: NSLocalizedString("Insert Mock DOC", comment: ""), status: nil, clickBlock: { [unowned self] _ in
            if let item = storage.first(where: { $0.fileType == .word }) { self.insertItem(item) }
        }),
        .init(title: NSLocalizedString("Insert Mock PDF", comment: ""), status: nil, clickBlock: { [unowned self] _ in
            if let item = storage.first(where: { $0.fileType == .pdf }) { self.insertItem(item) }
        }),
        .init(title: NSLocalizedString("Insert Mock PPT", comment: ""), status: nil, clickBlock: { [unowned self] _ in
            if let item = storage.first(where: { $0.fileType == .ppt && $0.taskType == .static })
            { self.insertItem(item) }
        }),
        .init(title: NSLocalizedString("Insert Mock MP4", comment: ""), status: nil, clickBlock: { [unowned self] _ in
            if let item = storage.first(where: { $0.fileType == .video }) { self.insertItem(item) }
        }),
        .init(title: NSLocalizedString("Insert Mock MP3", comment: ""), status: nil, clickBlock: { [unowned self] _ in
            if let item = storage.first(where: { $0.fileType == .music }) { self.insertItem(item) }
        }),
        .init(title: NSLocalizedString("Insert Mock Image", comment: ""), status: nil, clickBlock: { [unowned self] _ in
            if let item = storage.first(where: { $0.fileType == .img }) { self.insertItem(item) }
        }),
        .init(title: "VSCode", status: nil, enable: true, clickBlock: { [unowned self] _ in
            let options = WhiteAppOptions()
            options.title = "VSCode"
            let params = WhiteAppParam(kind: "Monaco", options: options, attrs: [:])
            self.fastRoom.room?.addApp(params, completionHandler: { _ in })
        }),
        .init(title: "Youtube", status: nil, enable: true, clickBlock: { [unowned self] _ in
            let options = WhiteAppOptions()
            options.title = "Youtube"
            let appParams = WhiteAppParam(kind: "Plyr",
                                          options: options,
                                          attrs: ["src": "https://www.youtube.com/embed/bTqVqk7FSmY",
                                                  "provider": "youtube"])
            self.fastRoom.room?.addApp(appParams, completionHandler: { _ in })
        })
    ])
}

extension ViewController: FastRoomDelegate {
    func fastboardDidJoinRoomSuccess(_ fastboard: FastRoom, room: WhiteRoom) {
        print(#function, room)
    }
    
    func fastboardPhaseDidUpdate(_ fastboard: FastRoom, phase: FastRoomPhase) {
        print(#function, phase)
    }
    
    func fastboardUserKickedOut(_ fastboard: FastRoom, reason: String) {
        print(#function, reason)
    }
    
    func fastboardDidOccurError(_ fastboard: FastRoom, error: FastRoomError) {
        print(#function, error.localizedDescription)
    }
}
