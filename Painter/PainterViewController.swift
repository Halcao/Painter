//
//  PainterViewController.swift
//  Painter
//
//  Created by Halcao on 2019/12/8.
//  Copyright © 2019 twtstudio. All rights reserved.
//

import UIKit
import Color_Picker_for_iOS
import RLBAlertsPickers
import SwiftMessages
import FlexColorPicker

class PainterViewController: UIViewController {
    private var startPoint: CGPoint?
    // 正在画三角的第一根线
    private var isDrawingFirstEdge: Bool = false
    private var firstPath: CGPath?

    private var currentLayer: CAShapeLayer?
    private var layers: [CAShapeLayer] = []

    private var drawingMode: DrawingMode = .triangle {
        didSet {
            // 切换 statusButton
            if drawingMode == .triangle {
                statusButton.setImage(UIImage(named: "triangle"), for: .normal)
            } else {
                statusButton.setImage(UIImage(named: "line"), for: .normal)
            }
        }
    }

    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var statusButton: UIButton!

    @IBOutlet weak var size1Button: UIButton!
    @IBOutlet weak var size2Button: UIButton!
    @IBOutlet weak var size3Button: UIButton!

    @IBOutlet weak var color1Button: UIButton!
    @IBOutlet weak var color2Button: UIButton!
    @IBOutlet weak var color3Button: UIButton!

    private var colorButtons: [UIButton] = []
    private var sizeButtons: [UIButton] = []
    private var currentColor: Int = 0 {
        didSet {
            if currentColor >= 0 && currentColor < 3 {
                colorButtons[oldValue].isSelected = false
                colorButtons[currentColor].isSelected = true
                DrawingConfig.shared.selectedColor = currentColor
                colorButtons[currentColor].setColor(color: DrawingConfig.shared.colors[currentColor])
            }
        }
    }

    private var currentSize: Int = 0 {
        didSet {
            if currentSize >= 0 && currentSize < 3 {
                sizeButtons[oldValue].isSelected = false
                sizeButtons[currentSize].isSelected = true
                DrawingConfig.shared.selectedSize = currentSize
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        updateRedoButtons()

        statusButton.addDashedBorder()
        statusButton.transform = CGAffineTransform(scaleX: 26.0/30, y: 26.0/30)
        statusButton.isUserInteractionEnabled = false
        self.drawingMode = .line

        sizeButtons = [size1Button, size2Button, size3Button]
        colorButtons = [color1Button, color2Button, color3Button]
        size1Button.isSelected = true
        color1Button.isSelected = true

        for i in 0..<colorButtons.count {
            colorButtons[i].setColor(color: DrawingConfig.shared.colors[i])
            colorButtons[i].tag = i
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(colorTapped(tap:)))
            singleTap.numberOfTapsRequired = 1
            colorButtons[i].addGestureRecognizer(singleTap)
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(colorTapped(tap:)))
            doubleTap.numberOfTapsRequired = 2
            colorButtons[i].addGestureRecognizer(doubleTap)
            singleTap.require(toFail: doubleTap)
        }

        for i in 0..<sizeButtons.count {
            sizeButtons[i].tag = i
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(sizeTapped(tap:)))
            singleTap.numberOfTapsRequired = 1
            sizeButtons[i].addGestureRecognizer(singleTap)
        }
    }

    @IBAction func load(_ sender: Any) {
        let vc = UIDocumentPickerViewController(documentTypes: ["public.content","public.text","public.source-code"], in: UIDocumentPickerMode.open)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.allowsMultipleSelection = false
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        var dict = [[String:Any]]()
        for layer in self.layers {
            dict.append(layer.encode())
        }
        guard let json = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else {
            return
        }

//        let string = String(data: json, encoding: .utf8)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let filename =  formatter.string(from: Date()) + ".json"

        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
        //创建文件
        FileManager.default.createFile(atPath: document.path, contents: json, attributes: nil)

        let items = [document] as [Any]
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil)

        activityVC.completionWithItemsHandler =  { activity, success, items, error in
            // 分享完毕
            if success {
                SwiftMessages.showSuccessMessage(body: "保存成功")
            }
        }
        self.present(activityVC, animated: true, completion: nil)
    }

    @objc func colorTapped(tap: UITapGestureRecognizer) {
        let index = tap.view?.tag ?? 0
        if tap.numberOfTapsRequired == 1 {
            currentColor = index
        } else if tap.numberOfTapsRequired == 2 {
            colorPick(index: index)
        }
    }

    @objc func sizeTapped(tap: UITapGestureRecognizer) {
        currentSize = tap.view?.tag ?? 0
    }

    @objc func registerUndo(layer: CAShapeLayer) {
        if layer.superlayer != nil {
            layer.removeFromSuperlayer()
        }

        if self.layers.contains(layer) {
            self.layers.removeAll(layer)
        }

        undoManager?.registerUndo(withTarget: self, selector: #selector(registerRedo(layer:)), object: layer)
    }

    @objc func registerRedo(layer: CAShapeLayer) {
        if layer.superlayer == nil {
            self.view.layer.addSublayer(layer)
        }

        if !self.layers.contains(layer) {
            self.layers.append(layer)
        }

        undoManager?.registerUndo(withTarget: self, selector: #selector(registerUndo(layer:)), object: layer)
    }

    @IBAction func undo(_ sender: Any) {
        if undoManager?.canUndo ?? false {
            undoManager?.undo()
        }
        updateRedoButtons()
    }

    @IBAction func redo(_ sender: Any) {
        if undoManager?.canRedo ?? false {
            undoManager?.redo()
        }
        updateRedoButtons()
    }

    private func updateRedoButtons() {
        redoButton.isEnabled = undoManager?.canRedo ?? false
        undoButton.isEnabled = undoManager?.canUndo ?? false
    }

    @IBAction func clear(_ sender: Any) {
        alert(title: "确定清空画板吗？") {
            self.layers.forEach { layer in
                if layer.superlayer != nil {
                    layer.removeFromSuperlayer()
                }
            }
            self.layers.removeAll()
            self.undoManager?.removeAllActions()

            self.isDrawingFirstEdge = false
            self.startPoint = nil
            self.firstPath = nil
            self.currentLayer = nil
        }
    }

    @IBAction func manage(_ sender: Any) {
        let images = self.layers.map { $0.toImage() }
        let vc = LayerTableViewController()
        vc.images = images
        vc.didDeleteRow = { row in
            let layer = self.layers.remove(at: row)
            if layer.superlayer != nil {
                layer.removeFromSuperlayer()
            }

            // 防止出错
            self.undoManager?.removeAllActions()
            self.updateRedoButtons()
        }
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }

    @IBAction func switchMode(_ sender: Any) {
        let alert = UIAlertController(style: .alert, title: "模式选择", message: "请选择模式")
        let line = UIAlertAction(title: "线段", style: .default) { action in
            self.drawingMode = .line
        }
        let triangle = UIAlertAction(title: "三角形", style: .default) { action in
            self.drawingMode = .triangle
        }

        let inputLine = UIAlertAction(title: "线段（坐标）", style: .default) { action in
            let v = LineInputView()
            v.show(success: { points in
                let path = UIBezierPath()
                path.move(to: points[0])
                path.addLine(to: points[1])
                let layer = CAShapeLayer().styled()
                layer.path = path.cgPath
                self.view.layer.addSublayer(layer)
                self.layers.append(layer)
                self.undoManager?.registerUndo(withTarget: self, selector: #selector(self.registerUndo(layer:)), object: layer)
                self.updateRedoButtons()
                self.startPoint = nil
                self.currentLayer = nil
                SwiftMessages.hideAll()
            })
        }

        let input3 = UIAlertAction(title: "三角形（坐标）", style: .default) { action in
            let v = TriangleInputView()
            v.show(success: { points in
                let path = UIBezierPath()
                path.move(to: points[0])
                path.addLine(to: points[1])
                path.addLine(to: points[2])
                path.close()
                let layer = CAShapeLayer().styled()
                layer.path = path.cgPath
                self.view.layer.addSublayer(layer)
                self.layers.append(layer)
                self.undoManager?.registerUndo(withTarget: self, selector: #selector(self.registerUndo(layer:)), object: layer)
                self.updateRedoButtons()
                self.startPoint = nil
                self.currentLayer = nil
                SwiftMessages.hideAll()
            })
        }

        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(line)
        alert.addAction(triangle)
        alert.addAction(inputLine)
        alert.addAction(input3)
        alert.addAction(cancel)
        alert.show()
    }

    private func colorPick(index: Int) {
        let vc = ColorPickerViewController()
        vc.delegate = self
        vc.selectedColor = DrawingConfig.shared.colors[index]
        self.currentColor = index
        vc.modalPresentationStyle = .currentContext
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}

// MARK: 触摸事件
extension PainterViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        switch drawingMode {
        case .line:
            drawingLineBegan(touches, with: event)
        case .triangle:
            drawingTriangleBegan(touches, with: event)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        switch drawingMode {
        case .line:
            drawingLineMoved(touches, with: event)
        case .triangle:
            drawingTriangleMoved(touches, with: event)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        switch drawingMode {
        case .line:
            drawingLineEnded(touches, with: event)
        case .triangle:
            drawingTriangleEnded(touches, with: event)
        }
    }
}


extension PainterViewController {
    // 开始画线，记录起点
    private func drawingLineBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startPoint = touches.first?.location(in: self.view)
        let layer = CAShapeLayer().styled()
        currentLayer = layer
        self.view.layer.addSublayer(layer)
    }

    // 画线过程，改变终点
    private func drawingLineMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startPoint = startPoint,
            let endPoint = touches.first?.location(in: self.view),
            let layer = currentLayer else {
                return
        }

        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        layer.path = linePath.cgPath
    }

    // 画线结束，清理中间变量 startPoint
    private func drawingLineEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let layer = currentLayer else {
            return
        }

        layers.append(layer)
        undoManager?.registerUndo(withTarget: self, selector: #selector(registerUndo(layer:)), object: layer)
        updateRedoButtons()
        startPoint = nil
        currentLayer = nil
    }

    private func drawingTriangleBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if startPoint == nil {
            isDrawingFirstEdge = true
            startPoint = touches.first?.location(in: self.view)
            let layer = CAShapeLayer().styled()
            currentLayer = layer
            self.view.layer.addSublayer(layer)
        } else {
            isDrawingFirstEdge = false
        }
    }

    private func drawingTriangleMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let endPoint = touches.first?.location(in: self.view) else {
            return
        }

        if isDrawingFirstEdge {
            drawingLineMoved(touches, with: event)
        } else {
            if let firstPath = firstPath {
                let newPath = UIBezierPath(cgPath: firstPath)
                newPath.addLine(to: endPoint)
                newPath.close()
                currentLayer?.path = newPath.cgPath
            }
        }
    }

    private func drawingTriangleEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let layer = currentLayer else {
                return
        }

        if isDrawingFirstEdge {
            // 将起始点移到第一根线终点
            startPoint = touches.first?.location(in: self.view)
            firstPath = layer.path
        } else {
            // 已经有了两条边，闭合路径

            layers.append(layer)
            undoManager?.registerUndo(withTarget: self, selector: #selector(registerUndo(layer:)), object: layer)
            updateRedoButtons()
            firstPath = nil
            startPoint = nil
            currentLayer = nil
        }
    }
}

extension PainterViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let first = urls.first, first.startAccessingSecurityScopedResource() else {
            return
        }
        guard let data = try? Data(contentsOf: first),
            let array = try? JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0)) as? [[String: Any]] else {
                return
        }
        first.stopAccessingSecurityScopedResource()

        // TODO: 是否保存？
        let layers = array.map { dict in
            return CAShapeLayer(dict: dict)
        }

        self.layers.forEach { layer in
            if layer.superlayer != nil {
                layer.removeFromSuperlayer()
            }
        }
        self.layers = layers
        for layer in layers {
            self.view.layer.addSublayer(layer)
        }
    }
}

extension PainterViewController: ColorPickerDelegate {
    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {

    }

    func colorPicker(_ colorPicker: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
        let index = currentColor
        DrawingConfig.shared.colors[index] = confirmedColor
        self.currentColor = index
    }
}
