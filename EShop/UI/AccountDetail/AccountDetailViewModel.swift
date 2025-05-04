//
//  AccountDetailViewModel.swift
//  EShop
//
//  Created by ali cihan on 1.05.2025.
//

import Foundation
import FirebaseAuth

class AccountDetailViewModel {
    weak var coordinator: AppCoordinator?

    var displayName: String? {
        Auth.auth().currentUser?.displayName
    }

    var email: String? {
        Auth.auth().currentUser?.email
    }

    var photoURL: URL? {
        Auth.auth().currentUser?.photoURL
    }

    init(coordinator: AppCoordinator?) {
        self.coordinator = coordinator
    }

    func signOut(completion: @escaping () -> Void) {
        do {
            try Auth.auth().signOut()
            coordinator?.showLogin()
            completion()
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }
    }
}
