//
//  Extensions.swift
//  Painter
//
//  Created by Halcao on 2019/12/8.
//  Copyright © 2019 twtstudio. All rights reserved.
//

import UIKit
import RLBAlertsPickers
import SwiftMessages

extension CAShapeLayer {
    func styled() -> CAShapeLayer {
        let config = DrawingConfig.shared
        strokeColor = config.strokeColor.cgColor
        fillColor = config.fillColor.cgColor
        lineWidth = config.lineWidth
        return self
    }
}

func showPicker(title: String, message: String, values: [String], initialSelection: Int = 0, action: @escaping (Int)->Void) {
    let alert = UIAlertController(style: .alert, title: title, message: message)

    var row = 0
    alert.addPickerView(values: [values], initialSelection: (column: 0, row: initialSelection), action: { vc, picker, index, values in
        row = index.row
    })
    let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)

    // 不知为啥.cancel更粗一些
    let action = UIAlertAction(title: "完成", style: .cancel, handler: { _ in
        action(row)
    })
    alert.addAction(action)
    alert.addAction(cancel)

    alert.show()
}

func alert(title: String, action: @escaping ()->()) {
    let vc = UIAlertController(style: .alert, title: title)
    let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
    let done = UIAlertAction(title: "确定", style: .destructive, handler: { _ in
        action()
    })

    vc.addAction(cancel)
    vc.addAction(done)
    vc.show()
}

extension UIView {

    func addDashedBorder() {
        //Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 2
        // passing an array with the values [2,3] sets a dash pattern that alternates between a 2-user-space-unit-long painted segment and a 3-user-space-unit-long unpainted segment
        shapeLayer.lineDashPattern = [2,3]

        let path = CGMutablePath()
//        path.addLines(between: [CGPoint(x: 0, y: 0),
//                                CGPoint(x: self.frame.width, y: 0)])
        path.addRect(self.bounds.inset(by: .init(top: -2, left: -2, bottom: -2, right: -2)))
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
}

extension UIButton {
    func setColor(color: UIColor) {
        for state in [UIButton.State.normal, .selected, .disabled, .highlighted] {
            if let origImage = self.image(for: state) {
                let tintedImage = origImage.withRenderingMode(.alwaysTemplate)
                setImage(tintedImage, for: state)
            }
        }
        tintColor = color
    }
}

extension CGPath {
    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        //print(MemoryLayout.size(ofValue: body))
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }

    func getPathElementsPoints() -> [CGPoint] {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            default: break
            }
        }
        return arrayPoints
    }

    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        return (arrayPoints,arrayTypes)
    }
}

extension CAShapeLayer {
    func toImage() -> UIImage {

        let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)

        let image = renderer.image {
            context in
            return self.render(in: context.cgContext)
        }

        return image
    }

    func encode() -> [String: Any] {
        var dict = [String: Any]()

        if let fillColor = self.fillColor {
            let fillColor = UIColor(cgColor: fillColor)
            var r = 0 as CGFloat
            var g = 0 as CGFloat
            var b = 0 as CGFloat
            var a = 0 as CGFloat
            fillColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            dict["fillColor"] = "\(r),\(g),\(b),\(a)"
        }

        if let strokeColor = self.strokeColor {
            let strokeColor = UIColor(cgColor: strokeColor)
            var r = 0 as CGFloat
            var g = 0 as CGFloat
            var b = 0 as CGFloat
            var a = 0 as CGFloat
            strokeColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            dict["strokeColor"] = "\(r),\(g),\(b),\(a)"
        }

        dict["lineWidth"] = lineWidth
        dict["points"] = self.path?.getPathElementsPoints().map { p in
            return "\(p.x),\(p.y)"
        }

        return dict
    }

    convenience init(dict: [String: Any]) {
        self.init()
        if let points = dict["points"] as? [String] {
            let path = UIBezierPath()
            for i in 0..<points.count {
                let array = points[i].split(separator: ",")
                guard array.count == 2 else {
                    return
                }

                if let x = Double(array[0]),
                    let y = Double(array[1]) {
                    let point = CGPoint(x: x, y: y)
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }

            }
            if points.count > 0 {
                path.close()
            }
            self.path = path.cgPath
        }

        if let strokeColor = dict["strokeColor"] as? String {
            let array = strokeColor.split(separator: ",")
            guard array.count == 4 else {
                return
            }

            if let r = Double(array[0]),
                let g = Double(array[1]),
                let b = Double(array[2]),
                let a = Double(array[3]) {
                let color = UIColor(displayP3Red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
                self.strokeColor = color.cgColor
            }
        }

        if let fillColor = dict["fillColor"] as? String {
            let array = fillColor.split(separator: ",")
            guard array.count == 4 else {
                return
            }

            if let r = Double(array[0]),
                let g = Double(array[1]),
                let b = Double(array[2]),
                let a = Double(array[3]) {
                let color = UIColor(displayP3Red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
                self.fillColor = color.cgColor
            }
        }

        if let lineWidth = dict["lineWidth"] as? CGFloat {
            self.lineWidth = lineWidth
        }
    }
}

extension SwiftMessages {
    static var otherMessages = SwiftMessages()

    static func showInfoMessage(title: String = "", body: String, context: PresentationContext = .automatic, layout: MessageView.Layout = .cardView) {
        message(title: title, body: body, theme: .info, context: context, layout: layout)
    }

    static func showSuccessMessage(title: String = "", body: String, context: PresentationContext = .automatic, layout: MessageView.Layout = .cardView) {
        message(title: title, body: body, theme: .success, context: context, layout: layout)
    }

    static func showWarningMessage(title: String = "", body: String, context: PresentationContext = .automatic, layout: MessageView.Layout = .cardView) {
        message(title: title, body: body, theme: .warning, context: context, layout: layout)
    }

    static func showErrorMessage(title: String = "", body: String, context: PresentationContext = .automatic, layout: MessageView.Layout = .cardView) {
        message(title: title, body: body, theme: .error, context: context, layout: layout)
    }

    static func message(title: String, body: String, theme: Theme, context: PresentationContext? = nil, layout: MessageView.Layout = .cardView) {
        let view = MessageView.viewFromNib(layout: layout)
        view.configureContent(title: title, body: body)
        view.button?.isHidden = true

        view.configureTheme(theme)

        var config = SwiftMessages.Config()
        if let context = context {
            config.presentationContext = context
        } else {
            if let top = UIViewController.current?.navigationController {
                config.presentationContext = .view(top.view)
            } else {
                config.presentationContext = .automatic
            }
        }

        SwiftMessages.show(config: config, view: view)
    }

//    static var otherMessages = SwiftMessages()

    static func showLoading() {
        //        var newMessage = SwiftMessages()
        let nib = UINib(nibName: "LoadingView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! UIView
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindow.Level.alert)
        config.interactiveHide = false
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: true)
        config.duration = .forever
        otherMessages.show(config: config, view: view)
    }

    static func hideLoading() {
        otherMessages.hideAll()
    }
}

extension UIViewController {
    private static func findBest(_ vc: UIViewController) -> UIViewController {
        if let next = vc.presentedViewController {
            return findBest(next)
        } else if let svc = vc as? UISplitViewController, let last = svc.viewControllers.last {
            return findBest(last)
        } else if let svc = vc as? UINavigationController, let top = svc.viewControllers.last {
            return findBest(top)
        } else if let svc = vc as? UITabBarController, let selected = svc.selectedViewController {
            return findBest(selected)
        } else {
            return vc
        }
    }

    static var current: UIViewController? {
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            return findBest(vc)
        } else {
            return nil
        }
    }

    static var top: UIViewController? {

        if let appRootVC = UIApplication.shared.keyWindow?.rootViewController {
            var topVC: UIViewController? = appRootVC
            while topVC?.presentedViewController != nil {
                topVC = topVC?.presentedViewController
            }
            return topVC
        }
        return nil
    }


}


extension CGPoint {
    func distance(from other: CGPoint) -> CGFloat {
        return sqrt(x*other.x+y*other.y)
    }
}

func verfiyTriangle(points: [CGPoint]) -> Bool {
    return points[0].x * (points[1].y - points[2].y) + points[1].x * (points[2].y - points[0].y) + points[2].x * (points[0].y - points[1].y) != 0
}

func verifyScreen(points: [CGPoint]) -> Bool {
    return points.allSatisfy { point -> Bool in
        return UIScreen.main.bounds.contains(point)
    }
}
