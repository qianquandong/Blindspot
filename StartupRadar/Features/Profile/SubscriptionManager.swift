import Combine
import Foundation
import StoreKit

enum SubscriptionTier: String, Comparable {
    case free
    case pro
    case elite

    static func < (lhs: SubscriptionTier, rhs: SubscriptionTier) -> Bool {
        let order: [SubscriptionTier] = [.free, .pro, .elite]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

@MainActor
final class SubscriptionManager: ObservableObject {
    // TODO: 替换成你在 App Store Connect 里配置的真实产品 ID
    private let productIds: Set<String> = [
        "com.startupradar.pro",
        "com.startupradar.elite"
    ]

    @Published var tier: SubscriptionTier = .free
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading: Bool = false
    @Published var lastErrorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await _ in Transaction.updates {
                await self.refreshEntitlements()
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: Array(productIds))
                .sorted(by: { $0.displayName < $1.displayName })
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        // StoreKit2 恢复购买通常通过重新计算 entitlements 即可
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var newTier: SubscriptionTier = .free

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            guard transaction.revocationDate == nil else { continue }
            guard transaction.expirationDate == nil || (transaction.expirationDate ?? .distantPast) > Date() else { continue }

            if transaction.productID == "com.startupradar.elite" {
                newTier = max(newTier, .elite)
            } else if transaction.productID == "com.startupradar.pro" {
                newTier = max(newTier, .pro)
            }
        }

        tier = newTier
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw NSError(domain: "StoreKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Transaction 未通过验证"])
        case .verified(let safe):
            return safe
        }
    }
}

