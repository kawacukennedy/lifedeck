import Foundation
import Combine

class APIService {
    static let shared = APIService()

    private let baseURL = "https://api.lifedeck.app"
    private let session = URLSession.shared

    // MARK: - Daily Cards

    func fetchDailyCards() async throws -> [CoachingCard] {
        let endpoint = "/v1/cards/daily"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add JWT token if available
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let apiResponse = try decoder.decode(DailyCardsResponse.self, from: data)
        return apiResponse.cards.map { apiCard in
            CoachingCard(
                title: apiCard.title,
                description: apiCard.title, // Using title as description for now
                actionText: apiCard.action,
                domain: LifeDomain(rawValue: apiCard.domain) ?? .health,
                actionType: .standard,
                priority: .medium,
                icon: "star", // Default icon
                tips: [],
                benefits: [],
                aiGenerated: true,
                templateId: nil
            )
        }
    }

    // MARK: - Authentication

    func authenticate(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "/v1/auth/login"
        let url = URL(string: baseURL + endpoint)!

        let body = ["email": email, "password": password]
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidCredentials
        }

        let decoder = JSONDecoder()
        let authResponse = try decoder.decode(AuthResponse.self, from: data)

        // Save token
        UserDefaults.standard.set(authResponse.token, forKey: "auth_token")

        return authResponse
    }

    // MARK: - Error Handling

    enum APIError: LocalizedError {
        case invalidResponse
        case httpError(Int)
        case invalidCredentials
        case decodingError
        case networkError

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid server response"
            case .httpError(let code):
                return "HTTP error: \(code)"
            case .invalidCredentials:
                return "Invalid email or password"
            case .decodingError:
                return "Failed to decode response"
            case .networkError:
                return "Network connection error"
            }
        }
    }
}

// MARK: - API Response Models

struct DailyCardsResponse: Codable {
    let cards: [APICard]
}

struct APICard: Codable {
    let id: String
    let title: String
    let domain: String
    let action: String
    let is_premium: Bool
}

struct AuthResponse: Codable {
    let token: String
    let user: APIUser
}

struct APIUser: Codable {
    let id: String
    let email: String
    let subscription_status: String
}