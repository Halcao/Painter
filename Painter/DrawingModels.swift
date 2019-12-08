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
    var strokeColor: UIColor = .black
    var lineWidth: CGFloat = 2
}
