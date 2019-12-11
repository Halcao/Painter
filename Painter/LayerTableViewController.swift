//
//  LayerTableViewController.swift
//  Painter
//
//  Created by Halcao on 2019/12/11.
//  Copyright © 2019 twtstudio. All rights reserved.
//

import UIKit
import SnapKit

class LayerTableViewController: UIViewController {
    private var tableView = UITableView(frame: .zero, style: .plain)
    var layers: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    

    private func setup() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
    }

}

extension LayerTableViewController: UITableViewDelegate {

}

extension LayerTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "layer-\(indexPath)")
        let titleLabel = UILabel()
        cell.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(100)
        }

        let imageView = UIImageView(image: layers[indexPath.row])
        cell.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-20)
        }

        return cell
    }
}
