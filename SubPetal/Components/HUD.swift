//
//  HUD.swift
//  SubPetal
//
//  Created by alexiscn on 2021/2/12.
//

import UIKit
import MBProgressHUD

public struct HUD {
    
    public enum Level {
        case info
        case ok
        case warning
        case alert
    }
    
    public static var backgroundColor = UIColor(white: 0, alpha: 0.6)

    private(set) static weak var globalHUD: MBProgressHUD?
    private static var globalToast: HUDView? { return globalHUD?.hudView }
    
    private static var keyWindow: UIWindow? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first(where: { $0.isKeyWindow })
    }
    
    public static func show(error: String, duration: TimeInterval = 2.5) {
        show(message: error, duration: duration, level: .warning)
    }
    
    public static func show(message: String, duration: TimeInterval = 2.5, level: Level = .info) {
        DispatchQueue.main.safeAsync {
            guard let window = self.keyWindow else { return }
            
            globalHUD?.hide(animated: false)
            globalHUD = show(message: message, inView: window, duration: duration, level: level)
        }
    }
    
    @discardableResult
    public static func show(message: String, inView view: UIView, duration: TimeInterval = 2.5, level: Level = .info) -> MBProgressHUD? {
        if message.isEmpty { return nil }
        
        let hud: MBProgressHUD
        switch level {
        case .info:
            hud = HUD(withText: message, inView: view, timeOut: duration, showEmotion: false, goodOrNot: true)
        case .ok:
            hud = HUD(withText: message, inView: view, timeOut: duration, showEmotion: true, goodOrNot: true)
        case .warning:
            hud = HUD(withText: message, inView: view, timeOut: duration, showEmotion: true, goodOrNot: false)
        case .alert:
            hud = HUD(withText: message, inView: view, timeOut: duration, showEmotion: true, goodOrNot: false)
        }
        return hud
    }
    
    public static func showIndicator() {
        DispatchQueue.main.safeAsync {
            guard let window = self.keyWindow else { return }
            
            globalHUD?.hide(animated: false)
            globalHUD = showIndicator(inView: window)
        }
    }
    
    public static func removeIndicator() {
        DispatchQueue.main.safeAsync {
            globalHUD?.hide(animated: true)
            globalHUD = nil
        }
    }

    @discardableResult
    public static func showIndicator(inView view: UIView) -> MBProgressHUD? {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.contentColor = UIColor.white
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = backgroundColor
        return hud
    }
    
    private static func HUD(withText: String, inView view: UIView, timeOut: TimeInterval, showEmotion: Bool, goodOrNot: Bool) -> MBProgressHUD {
        let tip: String
        if showEmotion {
            if goodOrNot {
                tip = "😊\(withText)"
            } else {
                tip = "😢\(withText)"
            }
        } else {
            tip = withText
        }
        
        let toastView = HUDView()
        toastView.backgroundColor = backgroundColor
        toastView.tip = tip
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        hud.mode = .customView
        hud.customView = toastView
        hud.offset = CGPoint(x: 0, y: 0)
        
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = UIColor.clear
        hud.bezelView.layer.transform = transformBezelView()
        
        hud.hide(animated: true, afterDelay: timeOut)
        
        toastView.hud = hud
        return hud
    }
    
    fileprivate static func transformBezelView() -> CATransform3D {
        return CATransform3DIdentity
    }
}


fileprivate class HUDView: UIView {
    
    var tip: String? {
        didSet {
            textLabel.text = tip
        }
    }
    
    static let maxWidth: CGFloat = 230
    var font: UIFont? = UIFont.systemFont(ofSize: 15, weight: .semibold) {
        didSet {
            textLabel.font = font
        }
    }
    var insets = UIEdgeInsets(top: 14, left: 25, bottom: 14, right: 25)
    
    private var textLabel: UILabel!
    
    fileprivate weak var hud: MBProgressHUD?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: HUDView.maxWidth, height: CGFloat.greatestFiniteMagnitude))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let maxLabelSize = CGSize(width: size.width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = textLabel.sizeThatFits(maxLabelSize)
        let result = CGSize(width: size.width, height: labelSize.height + insets.top + insets.bottom)
        return result
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = CGRect(x: insets.left, y: insets.top, width: bounds.width-insets.left-insets.right, height: bounds.height-insets.top-insets.bottom)
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        textLabel = UILabel()
        textLabel.frame = CGRect(x: insets.left, y: insets.top, width: bounds.width-insets.left-insets.right, height: bounds.height-insets.top-insets.bottom)
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.font = font
        textLabel.textColor = UIColor.white
        addSubview(textLabel)
    }
    
    func hide(animated: Bool) {
        hud?.hide(animated: animated)
    }
}

extension MBProgressHUD {
    fileprivate var hudView: HUDView? {
        return customView as? HUDView
    }
}

extension DispatchQueue {
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
