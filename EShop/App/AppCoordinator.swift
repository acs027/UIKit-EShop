//
//  AppCoordinator.swift
//  EShop
//
//  Created by ali cihan on 27.04.2025.
//

import UIKit

class AppCoordinator {
    private let window: UIWindow
    private let tabBarController = UITabBarController()

    // Navigation controllers for each tab
    private let homeNavController = UINavigationController()
    private let cartNavController = UINavigationController()
    private let accountNavController = UINavigationController()
    private let categoriesNavController = UINavigationController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        // Home Tab
        let homeVC = MainViewController(viewModel: MainViewModel(coordinator: self))
        homeVC.title = "Anasayfa"
        homeNavController.viewControllers = [homeVC]
        homeNavController.tabBarItem = UITabBarItem(title: "Anasayfa", image: UIImage(systemName: "house"), tag: 0)

        // Cart Tab
        let cartVC = CartViewController(viewModel: CartViewModel(coordinator: self))
        cartVC.title = "Sepetim"
        cartNavController.viewControllers = [cartVC]
        cartNavController.tabBarItem = UITabBarItem(title: "Sepetim", image: UIImage(systemName: "cart"), tag: 1)

        // Account Tab
        let loginVM = LoginViewModel(coordinator: self)
        let loginVC = LoginViewController(viewModel: loginVM)
        accountNavController.viewControllers = [loginVC]
        accountNavController.tabBarItem = UITabBarItem(title: "Hesabım", image: UIImage(systemName: "person"), tag: 2)

        // Set ViewControllers to TabBar
        tabBarController.viewControllers = [
            homeNavController,
            cartNavController,
            accountNavController,
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white

            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
    }

    func showProductDetail(product: Product) {
        let detailVC = ProductDetailViewController(viewModel: ProductDetailViewModel(product: product, coordinator: self))
        homeNavController.pushViewController(detailVC, animated: true)
    }

    func showCart() {
//        let cartVC = CartViewController(viewModel: CartViewModel(coordinator: self))
//        homeNavController.pushViewController(cartVC, animated: true)
        tabBarController.selectedViewController = cartNavController
    }
    
    func backToSearch() {
        tabBarController.selectedViewController = homeNavController
    }

    func showCategoryProducts(category: Category, products: [Product]) {
        let viewModel = CategoryProductsViewModel(category: category, products: products, coordinator: self)
        let vc = CategoryProductsViewController(viewModel: viewModel)
        homeNavController.pushViewController(vc, animated: true)
    }
    
    func showSearchedProducts(products: [Product]) {
        let viewModel = SearchViewModel(products: products, coordinator: self)
        let vc = SearchViewController(viewModel: viewModel)
        homeNavController.pushViewController(vc, animated: true)
    }
}

extension AppCoordinator {
    func showLogin() {
        let loginVM = LoginViewModel(coordinator: self)
        let loginVC = LoginViewController(viewModel: loginVM)
        accountNavController.setViewControllers([loginVC], animated: true)
        tabBarController.selectedViewController = accountNavController
    }

    func showAccountDetail() {
        let accountDetailVM = AccountDetailViewModel(coordinator: self)
        let accountDetailVC = AccountDetailViewController(viewModel: accountDetailVM)
        accountNavController.setViewControllers([accountDetailVC], animated: true)
        tabBarController.selectedViewController = accountNavController
    }
}

extension AppCoordinator {
    func addToBadge(quantity: Int) {
        if let badgeString = cartNavController.tabBarItem.badgeValue,
           let value = Int(badgeString) {
            self.cartNavController.tabBarItem.badgeValue = "\(value + quantity)"
        } else {
            self.cartNavController.tabBarItem.badgeValue = "\(quantity)"
        }
        
    }
    
    func setBadgeValue(quantity: Int) {
        if quantity == 0 {
            cartNavController.tabBarItem.badgeValue = nil
        } else {
            cartNavController.tabBarItem.badgeValue = "\(quantity)"
        }
    }
}


