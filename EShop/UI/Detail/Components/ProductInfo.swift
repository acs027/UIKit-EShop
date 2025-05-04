//
//  ProductInfo.swift
//  EShop
//
//  Created by ali cihan on 3.05.2025.
//

import UIKit
import SnapKit

class ProductInfo: UIView {
    private let brandLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setupTextLabels()
    }
    
    private func setupTextLabels() {
        [brandLabel, nameLabel, priceLabel].forEach(addSubview(_:))

        brandLabel.font = .systemFont(ofSize: 16, weight: .medium)
        brandLabel.textColor = .systemBlue
        brandLabel.textAlignment = .center

        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center

        priceLabel.font = .boldSystemFont(ofSize: 20)
        priceLabel.textColor = .systemGreen
        priceLabel.textAlignment = .center

        brandLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.left.right.equalToSuperview().inset(20)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(brandLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(20)
        }

        priceLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    


    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(brand: String, productName: String, price: String) {
        brandLabel.text = brand
        nameLabel.text = productName
        priceLabel.text = price
    }
    
    @objc private func showReviewsSheet() {
//        presentReviewsList()
    }
}
