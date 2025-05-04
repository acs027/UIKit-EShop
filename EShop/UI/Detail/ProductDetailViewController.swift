//
//  ProductDetailViewController.swift
//  EShop
//
//  Created by ali cihan on 27.04.2025.
//
import UIKit
import Combine
import Kingfisher
import FirebaseAuth

class ProductDetailViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ProductDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let productImageView = UIImageView()
    private let ratingView = RatingView()
    private let productInfoView = ProductInfo()
    private let reviewButton = UIButton(type: .system)
    private let bottomBarView = BottomView()

    // MARK: - Lifecycle
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ürün Detayı"
        view.backgroundColor = .white
        setupViews()
        setupBindings()
        setupNavBar()
        configureWithProduct()
    }

    // MARK: - Setup Views
    private func setupViews() {
        [scrollView, bottomBarView].forEach(view.addSubview(_:))
        scrollView.addSubview(contentView)

        setupConstraints()
        setupContent()
        setupBottomBar()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomBarView.snp.top)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }

        bottomBarView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func setupContent() {
        setupImageView()
        setupRatingView()
        setupProductInfoView()
        setupReviewButton()
    }

    private func setupImageView() {
        contentView.addSubview(productImageView)
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 12
        productImageView.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(20)
            $0.centerX.equalTo(contentView)
            $0.height.equalTo(250)
        }
    }

    private func setupRatingView() {
        contentView.addSubview(ratingView)
        ratingView.showReviewSheet = { [weak self] in
            self?.presentReviewsList()
        }
        ratingView.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom)
            $0.centerX.equalTo(contentView)
        }
    }

    private func setupProductInfoView() {
        contentView.addSubview(productInfoView)
        productInfoView.snp.makeConstraints {
            $0.top.equalTo(ratingView.snp.bottom)
            $0.centerX.equalTo(contentView)
        }
    }

    private func setupReviewButton() {
        contentView.addSubview(reviewButton)
        reviewButton.applyFilledStyle(title: "Ürüne Yorum Yap", backgroundColor: .systemOrange)
        reviewButton.addTarget(self, action: #selector(reviewProductTapped), for: .touchUpInside)
        reviewButton.isHidden = !viewModel.isUserLoggedIn
        reviewButton.snp.makeConstraints {
            $0.top.equalTo(productInfoView.snp.bottom).offset(24)
            $0.centerX.equalTo(contentView)
            $0.width.equalTo(contentView).multipliedBy(0.8)
            $0.height.equalTo(50)
            $0.bottom.equalTo(contentView).offset(-24)
        }
    }

    private func setupBottomBar() {
        bottomBarView.quantityValueChanged = { [weak self] newQuantity in
            self?.viewModel.quantity = newQuantity
        }
        bottomBarView.addToCartButtonTapped = { [weak self] in
            self?.addToCartTapped()
        }
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "cart.fill"),
            style: .plain,
            target: self,
            action: #selector(cartButtonTapped)
        )
    }

    // MARK: - Data Configuration
    private func configureWithProduct() {
        productInfoView.configure(
            brand: viewModel.product.brand,
            productName: viewModel.product.name,
            price: "₺\(viewModel.product.price.formatPrice())"
        )
        bottomBarView.configure(totalPrice: totalPriceText)
        loadProductImage()
    }

    private func loadProductImage() {
        guard let url = viewModel.productImageURL else { return }
        productImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"), options: [
            .transition(.fade(0.3)),
            .cacheOriginalImage
        ])
    }

    private var totalPriceText: String {
        "₺\((viewModel.product.price * viewModel.quantity).formatPrice())"
    }

    // MARK: - Bindings
    private func setupBindings() {
        viewModel.fetchReviews()

        viewModel.reviewsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateReviewUI()
            }
            .store(in: &cancellables)

        viewModel.$quantity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.bottomBarView.configure(totalPrice: self?.totalPriceText ?? "")
            }
            .store(in: &cancellables)
    }

    private func updateReviewUI() {
        ratingView.configure(
            rating: viewModel.averageRatingStars(),
            reviewCount: "\(viewModel.reviews.count)"
        )
    }

    // MARK: - Actions
    @objc private func addToCartTapped() {
        viewModel.addToCart()
        animateAddToCart()
    }

    @objc private func cartButtonTapped() {
        viewModel.didTapCart()
    }

    @objc private func reviewProductTapped() {
        presentReviewSheet()
    }
}



extension ProductDetailViewController {
    private func presentReviewSheet() {
        let reviewVC = ReviewViewController()
        reviewVC.modalPresentationStyle = .pageSheet
        reviewVC.sheetPresentationController?.detents = [.medium()]
        
        reviewVC.onSubmit = { [weak self, weak reviewVC] rating, text in
            guard let self = self else { return }
            self.viewModel.writeReview(rating: rating, text: text)
            reviewVC?.dismiss(animated: true) {
                self.showReviewSubmittedAlert()
            }
        }
        present(reviewVC, animated: true)
    }

    private func presentReviewsList() {
        let sheetVC = ReviewListViewController(reviews: viewModel.reviews)
        sheetVC.modalPresentationStyle = .pageSheet
        sheetVC.sheetPresentationController?.detents = [.medium(), .large()]
        present(sheetVC, animated: true)
    }

    private func showReviewSubmittedAlert() {
        let alert = UIAlertController(title: "Teşekkürler", message: "Yorumun alındı.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}



extension ProductDetailViewController {
    private func animateAddToCart() {
        guard let cartView = navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView,
              let superview = cartView.superview else { return }

        let boxImageView = UIImageView(image: UIImage(systemName: "shippingbox.fill"))
        boxImageView.tintColor = .systemOrange
        boxImageView.contentMode = .scaleAspectFit
        boxImageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)

        let startPoint = bottomBarView.superview?.convert(bottomBarView.center, to: view) ?? .zero
        let targetPoint = superview.convert(cartView.center, to: view)

        boxImageView.center = startPoint
        view.addSubview(boxImageView)

        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            boxImageView.center = targetPoint
            boxImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            boxImageView.alpha = 0.0
        }) { _ in
            boxImageView.removeFromSuperview()
        }
    }
}


extension UIButton {
    func applyFilledStyle(title: String, backgroundColor: UIColor) {
        setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        tintColor = .white
        layer.cornerRadius = 12
        titleLabel?.font = .boldSystemFont(ofSize: 18)
    }
}
