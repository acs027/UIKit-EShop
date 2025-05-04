//
//  ProductCell.swift
//  EShop
//
//  Created by ali cihan on 30.04.2025.
//

import UIKit
import SnapKit
import Kingfisher

class ProductCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let ratingLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let addToCartButton = UIButton()
    var addToCartTapped: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        contentView.backgroundColor = .systemGroupedBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFit
        
        
        ratingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        ratingLabel.textAlignment = .center
        ratingLabel.numberOfLines = 1

        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2

        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .systemGray
        priceLabel.textAlignment = .left
        
        
        let cartImage = UIImage(systemName: "cart.badge.plus")
        addToCartButton.setImage(cartImage, for: .normal)
        addToCartButton.tintColor = .systemBlue
        addToCartButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        addToCartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)

        contentView.addSubview(imageView)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(addToCartButton)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.equalToSuperview().inset(8)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
        }

        priceLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
        
        addToCartButton.snp.makeConstraints{ make in
            make.right.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }

    func configure(with product: Product, ratingLabelText: String) {
        nameLabel.text = product.name
        priceLabel.text = "₺\(product.price.formatPrice())"
        ratingLabel.text = ratingLabelText
        let urlString = "http://kasimadalan.pe.hu/urunler/resimler/" + product.image
        if let url = URL(string: urlString) {
            imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
    
    @objc func cartButtonTapped() {
        addToCartTapped?(nameLabel.text ?? "")
    }
}
