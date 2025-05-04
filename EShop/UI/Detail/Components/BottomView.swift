//
//  BottomView.swift
//  EShop
//
//  Created by ali cihan on 3.05.2025.
//

import UIKit

class BottomView: UIView {
    private var bottomPriceLabel = UILabel()
    private let bottomAddButton = UIButton(type: .system)
    private let quantityControl = CustomStepper()
    private let bottomBar = UIView()
    var quantityValueChanged: ((Int) -> Void)?
    var addToCartButtonTapped: (() -> ())?
    
    init() {
        super.init(frame: .zero)
        setupQuantityControl()
        setupBottomBar()
        setupBottomPriceLabel()
        setupBottomAddButton()
        setupStackViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupQuantityControl() {
        quantityControl.minimumValue = 1
        quantityControl.maximumValue = 10
        quantityControl.setValue(1)
        quantityControl.valueChanged = { [weak self] value in
            self?.setValueChanged(value: value)
        }
        quantityControl.snp.makeConstraints {
            $0.height.equalTo(36)
            $0.width.equalTo(120)
        }
    }
    
    
    private func setupBottomBar() {
        addSubview(bottomBar)
        bottomBar.backgroundColor = .white
        bottomBar.layer.shadowColor = UIColor.black.cgColor
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomBar.layer.shadowRadius = 6
        bottomBar.layer.shadowOpacity = 0.1

        bottomBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupBottomPriceLabel() {
        bottomPriceLabel.font = .boldSystemFont(ofSize: 18)
        bottomPriceLabel.textColor = .systemGreen
        bottomPriceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private func setupBottomAddButton() {
        bottomAddButton.setTitle("Sepete ekle", for: .normal)
        bottomAddButton.backgroundColor = .systemBlue
        bottomAddButton.tintColor = .white
        bottomAddButton.layer.cornerRadius = 12
        bottomAddButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        bottomAddButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        bottomAddButton.snp.makeConstraints { $0.height.equalTo(48) }
    }
    
    private func setupStackViews() {
        let priceQuantityStack = UIStackView(arrangedSubviews: [bottomPriceLabel, quantityControl])
        priceQuantityStack.axis = .horizontal
        priceQuantityStack.spacing = 16
        priceQuantityStack.alignment = .center

        let bottomStack = UIStackView(arrangedSubviews: [priceQuantityStack, bottomAddButton])
        bottomStack.axis = .vertical
        bottomStack.spacing = 12
        bottomStack.alignment = .fill

        bottomBar.addSubview(bottomStack)
        bottomStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
    
    func configure(totalPrice: String) {
        bottomPriceLabel.text = totalPrice
    }
    
    @objc private func addToCartTapped() {
        addToCartButtonTapped?()
    }
    
    private func setValueChanged(value: Int) {
        quantityValueChanged?(value)
    }
    

}
