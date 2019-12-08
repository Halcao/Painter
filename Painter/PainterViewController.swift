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
        }
    }

    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var statusButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        updateRedoButtons()
    }

    @IBAction func load(_ sender: Any) {
    }

    @IBAction func save(_ sender: Any) {
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
    }

    @IBAction func switchMode(_ sender: Any) {
    }


    private func colorPick(current: UIColor) {
        let alert = UIAlertController(style: .actionSheet)
        alert.addColorPicker(color: .red) { color in
            // action with selected color
        }
        alert.addAction(title: "Done", style: .cancel)
        alert.show()
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
