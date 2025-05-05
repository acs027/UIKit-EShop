//
//  ProductInfo.swift
//  EShop
//
//  Created by ali cihan on 3.05.2025.
//

import UIKit
import SnapKit

class ProductInfoView: UIView {
    private let productImageView = UIImageView()
    private let brandLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    
    private let ratingStackView = UIStackView()
    private let starsLabel = UILabel()
    private let reviewCountLabel = UILabel()
    var showReviewSheet: (() -> ())?

    init() {
        super.init(frame: .zero)
        setupImageView()
        setupRatingView()
        setupTextLabels()
    }
    
    private func setupImageView() {
        addSubview(productImageView)
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 12
        productImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(250)
        }
    }
    
    private func setupRatingView() {
        addSubview(ratingStackView)
        [starsLabel, reviewCountLabel].forEach(ratingStackView.addArrangedSubview(_:))

        ratingStackView.axis = .horizontal
        ratingStackView.alignment = .center
        ratingStackView.spacing = 4

        starsLabel.font = .systemFont(ofSize: 18)
        starsLabel.textColor = .systemYellow

        reviewCountLabel.font = .systemFont(ofSize: 16)
        reviewCountLabel.textColor = .gray

        ratingStackView.isUserInteractionEnabled = true
        ratingStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showReviewsSheet)))

        ratingStackView.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
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
            $0.top.equalTo(ratingStackView.snp.bottom)
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

    func configure(brand: String,
                   productName: String,
                   price: String,
                   productImageURL: URL?,
                   rating: String,
                   reviewCount: String
    ) {
        brandLabel.text = brand
        nameLabel.text = productName
        priceLabel.text = price
        loadProductImage(imageURL: productImageURL)
        starsLabel.text = rating
        reviewCountLabel.text = reviewCount
    }
    
    func updateRating(rating: String,
                      reviewCount: String) {
        starsLabel.text = rating
        reviewCountLabel.text = reviewCount
    }
    
    
    @objc private func showReviewsSheet() {
        showReviewSheet?()
    }
    
    private func loadProductImage(imageURL: URL?) {
        guard let url = imageURL else { return }
        productImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"), options: [
            .transition(.fade(0.3)),
            .cacheOriginalImage
        ])
    }
}
