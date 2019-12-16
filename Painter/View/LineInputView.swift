//
//  TriangleInputView.swift
//  Painter
//
//  Created by Halcao on 2019/12/11.
//  Copyright © 2019 twtstudio. All rights reserved.
//

import UIKit
import SwiftMessages

class LineInputView: UIView {
    private var textField1 = UITextField()
    private var textField2 = UITextField()
    private var textField3 = UITextField()
    private var textField4 = UITextField()
    private var doneButton = UIButton()
    private var blankView = UIView()
    private var success: (([CGPoint])->Void)?

    private var fields: [UITextField] {
        get {
            return [textField1, textField2, textField3, textField4]
        }
    }

    init() {
        super.init(frame: CGRect(x: 30, y: UIScreen.main.bounds.height*0.15, width: UIScreen.main.bounds.width-60, height: 300))
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func textFieldStyling(field: UITextField, isX: Bool) {
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.keyboardType = .decimalPad
        field.returnKeyType = .next
        field.placeholder = isX ? "x" : "y"
    }

    private func setup() {
        self.addSubview(blankView)
        var isX = true
        fields.forEach { field in
            self.addSubview(field)
            self.textFieldStyling(field: field, isX: isX)
            isX.toggle()
        }
        self.addSubview(doneButton)

        let width = 100
        let height = 30

        textField1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.right.equalTo(self.snp.centerX).offset(-10)
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        textField2.snp.makeConstraints { make in
            make.centerY.equalTo(textField1)
            make.left.equalTo(self.snp.centerX).offset(10)
            make.width.equalTo(textField1)
            make.height.equalTo(textField1)
        }

        textField3.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(10)
            make.left.equalTo(textField1)
            make.width.equalTo(textField1)
            make.height.equalTo(textField1)
        }

        textField4.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(10)
            make.left.equalTo(textField2)
            make.width.equalTo(textField1)
            make.height.equalTo(textField1)
        }

        doneButton.layer.cornerRadius = 15
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.setTitle("确定", for: .normal)
        doneButton.backgroundColor = UIColor(hue: 199.0/360.0, saturation: 1.0, brightness: 0.91, alpha: 1.0)
        doneButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(textField3.snp.bottom).offset(15)
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }

        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)

        blankView.backgroundColor = .white
        blankView.layer.cornerRadius = 8
        blankView.layer.masksToBounds = true
        blankView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
    }
}

extension LineInputView {
    @objc func done() {
        var array = [Double]()
        for i in 0..<fields.count {
            if let text = fields[i].text,
                let num = Double(text) {
                array.append(num)
            } else {
                SwiftMessages.showErrorMessage(body: "请保证第\(i/2 + 1)行\(i % 2 + 1)列数据正确")
                return
            }
        }

        var points: [CGPoint] = []
        for i in 0..<array.count/2 {
            points.append(CGPoint(x: array[2*i], y: array[2*i+1]))
        }

        if verifyScreen(points: points) == false {
            SwiftMessages.showErrorMessage(body: "点在屏幕外，请重新输入")
            return
        }

        success?(points)
    }

    func show(success: @escaping ([CGPoint])->()) {
        SwiftMessages.hideAll()
        self.success = success
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.duration = .forever
        config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
        config.presentationContext  = .window(windowLevel: UIWindow.Level.normal)
        SwiftMessages.otherMessages.show(config: config, view: self)
    }
}
