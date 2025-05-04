//
//  LoginViewModel.swift
//  EShop
//
//  Created by ali cihan on 1.05.2025.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class LoginViewModel {
    private weak var coordinator: AppCoordinator?

    init(coordinator: AppCoordinator?) {
        self.coordinator = coordinator
    }

    func signInWithGoogle(presentingVC: UIViewController, completion: @escaping () -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    print("Firebase Sign-In error: \(error.localizedDescription)")
                } else {
                    print("Signed in as: \(authResult?.user.email ?? "No email")")
                    self?.coordinator?.showAccountDetail()
                    completion()
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    
    func showAccountDetails() {
        coordinator?.showAccountDetail()
    }
}
