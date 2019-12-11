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
    var images: [UIImage] = []
    var didDeleteRow: ((Int)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.left.right.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        title = "管理图形"

        let done = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(close))
        let edit = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editRow))
        self.navigationItem.leftBarButtonItem = edit
        self.navigationItem.rightBarButtonItem = done
    }

    @objc func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func editRow() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }
}

extension LayerTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.images.remove(at: indexPath.row)
        didDeleteRow?(indexPath.row)
        tableView.reloadData()
//        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension LayerTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "layer-\(indexPath)")
        let titleLabel = UILabel()
        titleLabel.text = "图形 - \(indexPath.row)"
        cell.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(100)
        }

        let imageView = UIImageView(image: images[indexPath.row])
        imageView.contentMode = .scaleAspectFit
        imageView.image = images[indexPath.row]
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
