//
//  FastRoomView.swift
//  Fastboard
//
//  Created by xuyunshi on 2021/12/28.
//

import Foundation
import Whiteboard
import UIKit

/// Main view for fastboard
public class FastRoomView: UIView, FastPanelControl {
    @objc
    public dynamic var operationBarDirection: OperationBarDirection = .left {
        didSet {
            overlay?.updateControlBarLayout(direction: operationBarDirection)
        }
    }
    
    /// Is whiteboard only drawable with pencil
    var isPencilDrawOnly: Bool = false {
        didSet {
            pencilHandler?.drawOnlyPencil = isPencilDrawOnly
        }
    }
    
    var pencilHandler: FastboardPencilDrawHandler?
    
    @objc
    public var overlay: FastRoomOverlay?

    @objc
    public init(overlay: FastRoomOverlay?) {
        self.overlay = overlay
        super.init(frame: .zero)
        setupWhiteboardView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Try fill width first
        var width = bounds.width
        var height = width / Fastboard.globalFastboardRatio
        if height > bounds.height {
            height = bounds.height
            width = (Fastboard.globalFastboardRatio * height) + 30
        }
        let x = (bounds.width - width) / 2
        let y = (bounds.height - height) / 2
        whiteboardView.frame = .init(x: x, y: y, width: width, height: height)
    }
    
    @objc
    public var whiteboardView: WhiteBoardView!
    
     func setupWhiteboardView() {
        whiteboardView = WhiteBoardView()
        whiteboardView.frame = self.bounds
         whiteboardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(whiteboardView)
        if #available(iOS 11.0, *) {
            whiteboardView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor).isActive = true
            whiteboardView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor).isActive = true
        }
        whiteboardView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        whiteboardView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
     }
    
    @objc
    public func setAllPanel(hide: Bool) {
        overlay?.setAllPanel(hide: hide)
    }
    
    @objc
    public func setPanelItemHide(item: FastRoomDefaultOperationIdentifier, hide: Bool) {
        overlay?.setPanelItemHide(item: item, hide: hide)
    }
    
    @objc
    public func dismissAllSubPanels() {
        overlay?.dismissAllSubPanels()
    }
}
