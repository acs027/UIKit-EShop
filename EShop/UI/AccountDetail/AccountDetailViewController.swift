//
//  AccountDetailViewController.swift
//  EShop
//
//  Created by ali cihan on 1.05.2025.
//
import UIKit
import SnapKit
import Kingfisher

class AccountDetailViewController: UIViewController {
    private let viewModel: AccountDetailViewModel

    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let signOutButton = UIButton(type: .system)

    init(viewModel: AccountDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Account"

        setupViews()
        fillData()
    }

    private func setupViews() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        view.addSubview(profileImageView)

        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        view.addSubview(nameLabel)

        emailLabel.font = .systemFont(ofSize: 16)
        emailLabel.textColor = .gray
        emailLabel.textAlignment = .center
        view.addSubview(emailLabel)

        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.systemRed, for: .normal)
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        view.addSubview(signOutButton)

        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }

        signOutButton.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
    }

    private func fillData() {
        nameLabel.text = viewModel.displayName ?? "No Name"
        emailLabel.text = viewModel.email ?? "No Email"

        if let url = viewModel.photoURL {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle"))
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
        }
    }

    @objc private func signOutTapped() {
        viewModel.signOut {
            DispatchQueue.main.async {
                print("Signed out")
            }
        }
    }
}
