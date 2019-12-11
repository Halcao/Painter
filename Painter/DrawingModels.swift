//
//  DrawingMode.swift
//  Painter
//
//  Created by Halcao on 2019/12/8.
//  Copyright © 2019 twtstudio. All rights reserved.
//

import UIKit

enum DrawingMode {
    case line
    case triangle
}

class DrawingConfig {
    static var shared = DrawingConfig()

    var fillColor: UIColor = .white
    var strokeColor: UIColor {
        get {
            return colors[selectedColor]
        }
    }
    var lineWidth: CGFloat {
        get {
            return sizes[selectedSize]
        }
    }
    var colors: [UIColor] = [.black, .blue, .red]
    var sizes: [CGFloat] = [1, 2, 3]
    var selectedSize = 0
    var selectedColor = 0
}
