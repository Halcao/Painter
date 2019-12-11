//
//  ColorPickerViewController.swift
//  Painter
//
//  Created by Halcao on 2019/12/11.
//  Copyright © 2019 twtstudio. All rights reserved.
//

import UIKit
import FlexColorPicker

class ColorPickerViewController: DefaultColorPickerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "选择颜色"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(close))
    }

    @objc func close() {
        self.delegate?.colorPicker(colorPicker, confirmedColor: selectedColor, usingControl: colorPicker.colorControls[0])
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}
