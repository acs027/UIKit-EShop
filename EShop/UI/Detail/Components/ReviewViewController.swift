//
//  ReviewViewController.swift
//  EShop
//
//  Created by ali cihan on 1.05.2025.
//

import UIKit

class ReviewViewController: UIViewController {
    var onSubmit: ((Int, String) -> Void)?

    private let ratingControl = UISegmentedControl(items: ["1", "2", "3", "4", "5"])
    private let reviewTextView = UITextView()
    private let submitButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        view.addSubview(ratingControl)
        view.addSubview(reviewTextView)
        view.addSubview(submitButton)

        ratingControl.selectedSegmentIndex = 4
        ratingControl.tintColor = .systemYellow

        reviewTextView.layer.borderColor = UIColor.lightGray.cgColor
        reviewTextView.layer.borderWidth = 1
        reviewTextView.layer.cornerRadius = 8
        reviewTextView.font = UIFont.systemFont(ofSize: 16)

        submitButton.setTitle("Gönder", for: .normal)
        submitButton.backgroundColor = .systemGreen
        submitButton.tintColor = .white
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        ratingControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
        }

        reviewTextView.snp.makeConstraints { make in
            make.top.equalTo(ratingControl.snp.bottom).offset(12)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(100)
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(reviewTextView.snp.bottom).offset(12)
            make.centerX.equalTo(view)
            make.width.equalTo(160)
            make.height.equalTo(44)
        }
    }

    @objc private func submitTapped() {
        let rating = ratingControl.selectedSegmentIndex + 1
        let text = reviewTextView.text ?? ""
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alert = UIAlertController(title: "Empty Review", message: "Please enter a review.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        onSubmit?(rating, text)
        dismiss(animated: true)
    }
}
