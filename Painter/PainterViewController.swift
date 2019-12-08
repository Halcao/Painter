//
//  PainterViewController.swift
//  Painter
//
//  Created by Halcao on 2019/12/8.
//  Copyright © 2019 twtstudio. All rights reserved.
//

import UIKit

class PainterViewController: UIViewController {
    private var startPoint: CGPoint?
    // 第二个中间点，画三角形用
//    private var secondPoint: CGPoint?
    private var isDrawingFirstEdge: Bool = false
    private var firstPath: CGPath?

    private var currentLayer: CAShapeLayer?
    private var layers: [CAShapeLayer] = []
    private var drawingMode: DrawingMode = .triangle

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

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
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.red.cgColor
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

        // TODO: initializer for styled layer
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
        startPoint = nil
        currentLayer = nil
    }

    private func drawingTriangleBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if startPoint == nil {
            isDrawingFirstEdge = true
            startPoint = touches.first?.location(in: self.view)
            let layer = CAShapeLayer()
            layer.strokeColor = UIColor.red.cgColor
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
            firstPath = nil
            startPoint = nil
            currentLayer = nil
        }
    }
}
