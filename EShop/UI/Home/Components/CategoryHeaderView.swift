//
//  CategoryHeaderView.swift
//  EShop
//
//  Created by ali cihan on 30.04.2025.
//

import UIKit
import SnapKit

protocol CategoryHeaderViewDelegate: AnyObject {
    func didTapSeeAll(for category: Category)
}

class CategoryHeaderView: UICollectionReusableView {
    static let identifier = "CategoryHeaderView"

    weak var delegate: CategoryHeaderViewDelegate?

    private var currentCategory: Category?

    private let titleLabel = UILabel()
    private let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tümü", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(seeAllButton)

        titleLabel.font = .boldSystemFont(ofSize: 18)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        seeAllButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
    }

    @objc private func seeAllTapped() {
        guard let category = currentCategory else { return }
        delegate?.didTapSeeAll(for: category)
    }

    func configure(with category: Category) {
        currentCategory = category
        titleLabel.text = category.rawValue
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
