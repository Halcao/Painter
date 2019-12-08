//
//  Extensions.swift
//  Painter
//
//  Created by Halcao on 2019/12/8.
//  Copyright © 2019 twtstudio. All rights reserved.
//

import UIKit
import RLBAlertsPickers

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
