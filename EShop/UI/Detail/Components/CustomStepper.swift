//
//  CustomStepper.swift
//  EShop
//
//  Created by ali cihan on 2.05.2025.
//

import UIKit
import SnapKit

class CustomStepper: UIView {
    // MARK: - Properties
    private(set) var value: Int = 1
    var minimumValue: Int = 1
    var maximumValue: Int = 10
    var valueChanged: ((Int) -> Void)?
    
    // MARK: - UI Components
    private let decrementButton = UIButton(type: .system)
    private let incrementButton = UIButton(type: .system)
    private let valueLabel = UILabel()
    private let stackView = UIStackView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        
        // Setup Buttons
        decrementButton.setTitle("-", for: .normal)
        decrementButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        decrementButton.tintColor = .systemBlue
        decrementButton.addTarget(self, action: #selector(decrementValue), for: .touchUpInside)
        
        incrementButton.setTitle("+", for: .normal)
        incrementButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        incrementButton.tintColor = .systemBlue
        incrementButton.addTarget(self, action: #selector(incrementValue), for: .touchUpInside)
        
        // Setup Label
        valueLabel.text = "\(value)"
        valueLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        valueLabel.textAlignment = .center
        
        // Setup Stack View
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        stackView.addArrangedSubview(decrementButton)
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(incrementButton)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func decrementValue() {
        if value > minimumValue {
            value -= 1
            updateValueLabel()
            valueChanged?(value)
        }
    }
    
    @objc private func incrementValue() {
        if value < maximumValue {
            value += 1
            updateValueLabel()
            valueChanged?(value)
        }
    }
    
    // MARK: - Helpers
    private func updateValueLabel() {
        valueLabel.text = "\(value)"
    }
    
    func setValue(_ newValue: Int) {
        let clampedValue = max(minimumValue, min(maximumValue, newValue))
        value = clampedValue
        updateValueLabel()
    }
}


