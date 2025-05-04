//
//  LoginViewController.swift
//  EShop
//
//  Created by ali cihan on 1.05.2025.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import SnapKit

class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel

    private let signInButton = GIDSignInButton()
    private let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUIForAuthState()
    }

    private func setupUI() {
        // Add subviews
        view.addSubview(signInButton)
        view.addSubview(signOutButton)

        // Set up constraints using SnapKit
        signInButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
        }

        signOutButton.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        // Add actions
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
    }

    private func updateUIForAuthState() {
        let isSignedIn = Auth.auth().currentUser != nil
        signInButton.isHidden = isSignedIn
        signOutButton.isHidden = !isSignedIn
        if isSignedIn {
            viewModel.showAccountDetails()
        }
    }

    @objc private func signInTapped() {
        viewModel.signInWithGoogle(presentingVC: self) { [weak self] in
            self?.updateUIForAuthState()
        }
    }

    @objc private func signOutTapped() {
        viewModel.signOut()
        updateUIForAuthState()
    }
}
