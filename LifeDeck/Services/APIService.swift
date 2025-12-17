import Foundation
import Combine

class APIService {
    static let shared = APIService()

    #if DEBUG
    private let baseURL = "http://localhost:3000"
    #else
    private let baseURL = "https://api.lifedeck.app"
    #endif

    private let session = URLSession.shared

    private var authToken: String? {
        UserDefaults.standard.string(forKey: "auth_token")
    }

    // MARK: - Daily Cards

    func fetchDailyCards() async throws -> [CoachingCard] {
        let endpoint = "/v1/cards/daily"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add JWT token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let apiResponse = try decoder.decode(DailyCardsResponse.self, from: data)
        return apiResponse.cards.map { apiCard in
            CoachingCard(
                title: apiCard.title,
                description: apiCard.description,
                actionText: apiCard.actionText,
                domain: LifeDomain(rawValue: apiCard.domain.lowercased()) ?? .health,
                actionType: CardActionType(rawValue: apiCard.actionType.lowercased()) ?? .standard,
                priority: CardPriority(rawValue: apiCard.priority.lowercased()) ?? .medium,
                icon: apiCard.icon,
                backgroundColor: apiCard.backgroundColor,
                tips: apiCard.tips,
                benefits: apiCard.benefits,
                aiGenerated: apiCard.aiGenerated,
                templateId: apiCard.templateId
            )
        }
    }

    func completeCard(cardId: String) async throws {
        let endpoint = "/v1/cards/\(cardId)/complete"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    func dismissCard(cardId: String) async throws {
        let endpoint = "/v1/cards/\(cardId)"
        let url = URL(string: baseURL + endpoint)!

        let body = ["status": "DISMISSED"]
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    func snoozeCard(cardId: String, until: Date) async throws {
        let endpoint = "/v1/cards/\(cardId)"
        let url = URL(string: baseURL + endpoint)!

        let body = [
            "status": "SNOOZED",
            "snoozedUntil": ISO8601DateFormatter().string(from: until)
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    func fetchAnalytics() async throws -> AnalyticsData {
        let endpoint = "/v1/analytics"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
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
        return try decoder.decode(AnalyticsData.self, from: data)
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

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw APIError.invalidCredentials
            }
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let authResponse = try decoder.decode(AuthResponse.self, from: data)

        // Save token
        UserDefaults.standard.set(authResponse.access_token, forKey: "auth_token")

        return authResponse
    }

    func register(email: String, password: String, name: String?) async throws -> AuthResponse {
        let endpoint = "/v1/auth/register"
        let url = URL(string: baseURL + endpoint)!

        var body: [String: Any] = ["email": email, "password": password]
        if let name = name {
            body["name"] = name
        }
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 201 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let authResponse = try decoder.decode(AuthResponse.self, from: data)

        // Save token
        UserDefaults.standard.set(authResponse.access_token, forKey: "auth_token")

        return authResponse
    }

    func getProfile() async throws -> APIUser {
        let endpoint = "/v1/auth/profile"
        let url = URL(string: baseURL + endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(APIUser.self, from: data)
    }

    // MARK: - Error Handling

    enum APIError: LocalizedError {
        case invalidResponse
        case httpError(Int)
        case invalidCredentials
        case unauthorized
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
            case .unauthorized:
                return "Authentication required"
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
    let description: String
    let actionText: String
    let domain: String
    let actionType: String
    let priority: String
    let icon: String
    let backgroundColor: String?
    let tips: [String]
    let benefits: [String]
    let status: String
    let createdAt: String
    let aiGenerated: Bool
    let templateId: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, actionText, domain, actionType, priority, icon, backgroundColor, tips, benefits, status, createdAt, aiGenerated, templateId
    }
}

struct AuthResponse: Codable {
    let access_token: String
    let user: APIUser

    enum CodingKeys: String, CodingKey {
        case access_token, user
    }
}

struct APIUser: Codable {
    let id: String
    let email: String
    let name: String?
    let subscriptionTier: String
    let progress: UserProgress

    enum CodingKeys: String, CodingKey {
        case id, email, name, subscriptionTier, progress
    }
}

struct UserProgress: Codable {
    let healthScore: Double
    let financeScore: Double
    let productivityScore: Double
    let mindfulnessScore: Double
    let lifeScore: Double
    let currentStreak: Int
    let lifePoints: Int
    let totalCardsCompleted: Int
}

struct AnalyticsData: Codable {
    let lifeScore: Double
    let weeklyProgress: [String: Double]
    let monthlyStats: [String: Int]
    let achievements: [Achievement]
}

struct Achievement: Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}