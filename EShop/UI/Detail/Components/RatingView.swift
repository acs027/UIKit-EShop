//
//  RatingView.swift
//  EShop
//
//  Created by ali cihan on 3.05.2025.
//

import UIKit
import SnapKit

class RatingView: UIView {
    private let ratingStackView = UIStackView()
    private let starsLabel = UILabel()
    private let reviewCountLabel = UILabel()
    var showReviewSheet: (() -> ())?

    init() {
        super.init(frame: .zero)
        setupRatingView()
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
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(rating: String, reviewCount: String) {
        starsLabel.text = rating
        reviewCountLabel.text = reviewCount
    }
    
    @objc private func showReviewsSheet() {
        showReviewSheet?()
    }
}
