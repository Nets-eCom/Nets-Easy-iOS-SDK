//
//  SubscriptionsCell.swift
//  MiaSample
//
//  Created by Luke on 09/03/2020.
//  Copyright © 2020 Nets AS. All rights reserved.
//

import UIKit

class SubscriptionCell: UITableViewCell {
    
    let chargeButton: UIButton = {
        let button = UIButton()
        button.setTitle("  Charge  ", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        return button
    }()
    
    var chargeAction: () -> Void = { }
    
    @objc private func charge(_: UIButton) {
        chargeAction()
    }
    
    func setChargeButtonStyle(active isActive: Bool) {
        chargeButton.backgroundColor = isActive ? .systemBlue : .systemGray
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(chargeButton)
        chargeButton.addTarget(self, action: #selector(charge(_:)), for: .touchUpInside)
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyConstraints()
    }
    
    private func applyConstraints() {
        [imageView!, textLabel!, detailTextLabel!, chargeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        contentView.frame = bounds
        NSLayoutConstraint.activate([
            imageView!.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1 / 5),
            imageView!.heightAnchor.constraint(equalTo: imageView!.widthAnchor, multiplier: 2 / 3),
            imageView!.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            imageView!.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            textLabel!.leftAnchor.constraint(equalTo: imageView!.rightAnchor, constant: 10),
            textLabel!.topAnchor.constraint(equalTo: imageView!.topAnchor),
            textLabel!.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            textLabel!.heightAnchor.constraint(equalTo: imageView!.heightAnchor),
            chargeButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            chargeButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1 / 4),
            chargeButton.topAnchor.constraint(equalTo: imageView!.bottomAnchor, constant: 10),
            detailTextLabel!.leftAnchor.constraint(equalTo: imageView!.leftAnchor),
            detailTextLabel!.topAnchor.constraint(equalTo: imageView!.bottomAnchor, constant: 10),
            detailTextLabel!.rightAnchor.constraint(equalTo: chargeButton.leftAnchor, constant: 10),
            
            // TODO: Check why this constraint conflicts when inserting/removing cells
            detailTextLabel!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
}
