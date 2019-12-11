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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(close))

    }

    @objc func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}
