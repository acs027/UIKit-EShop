//
//  CartItemCell.swift
//  EShop
//
//  Created by ali cihan on 29.04.2025.
//

import UIKit
import Kingfisher

class CartItemCell: UITableViewCell {
    let productImageView = UIImageView()
    let nameLabel = UILabel()
    let priceLabel = UILabel()
    let countLabel = UILabel()
    let stepper = UIStepper()
    
    var onStepperValueChanged: ((Double) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupViews() {
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        productImageView.snp.makeConstraints { $0.width.height.equalTo(80) }

        nameLabel.font = .systemFont(ofSize: 16)
        priceLabel.font = .systemFont(ofSize: 14, weight: .medium)

        countLabel.font = .systemFont(ofSize: 16)
        countLabel.textAlignment = .center
        
        stepper.minimumValue = 0
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        
        let topRow = UIStackView(arrangedSubviews: [productImageView, nameLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 12
        
        let bottomRow = UIStackView(arrangedSubviews: [priceLabel, countLabel, stepper])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.distribution = .equalSpacing
        bottomRow.spacing = 12
        
        let verticalStack = UIStackView(arrangedSubviews: [topRow, bottomRow])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        
        contentView.addSubview(verticalStack)
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    @objc private func stepperChanged() {
        countLabel.text = "\(Int(stepper.value))"
        onStepperValueChanged?(stepper.value)
    }
    
    func configure(name: String, count: Int, price: Double, imageURL: URL?) {
        nameLabel.text = name
        priceLabel.text = "₺"+Int(price).formatPrice()
        stepper.value = Double(count)
        countLabel.text = "\(count)"
        
        if let url = imageURL {
            productImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            productImageView.image = UIImage(systemName: "photo")
        }
    }
}
