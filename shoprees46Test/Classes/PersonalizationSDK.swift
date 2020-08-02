//
//  PersonalizationSDK.swift
//  shopTest
//
//  Created by Арсений Дорогин on 29.07.2020.
//

import Foundation

public enum Event {
    case productView (id: String)
    case categoryView (id: String)
    case productAddedToFavorities(id: String)
    case productRemovedToFavorities(id: String)
    case productAddedToCart (id: String)
    case productRemovedFromCart (id: String)
    case syncronizeCart (ids: [String])
    case orderCreated(orderId: String, totalValue: Double, products: [(id: String, amount: Int)])
}

public enum SDKError: Error {
    case incorrectAPIKey
    case initializationFailed
    case noError
    case responseError
    case invalidResponse
    case decodeError
}


public protocol PersonalizationSDK {
    func setProfileData(userEmail: String?, userPhone: String?, userLoyaltyId: String?, birthday: Date?, age: String?, firstName: String?, secondName: String?, lastName: String?, bouthSmth: Bool?, location: String?, gender: Gender?, completion: @escaping (Result<Void, SDKError>) -> Void)
    func track(event: Event, completion: @escaping (Result<Void, SDKError>) -> Void)
    func recommend(blockId: String, currentProductId: String?, completion: @escaping (Result<RecommenderResponse, SDKError>) -> Void)
    func search(query: String, searchType: SearchType, completion: @escaping(Result<SearchResponse, SDKError>) -> Void)
}

public func createPersonalizationSDK(shopId: String, userId: String? = nil, userEmail: String? = nil, userPhone: String? = nil, userLoyaltyId: String? = nil) -> PersonalizationSDK{
    let sdk = SimplePersonaizationSDK(shopId: shopId, userId: userId, userEmail: userEmail, userPhone: userPhone, userLoyaltyId: userLoyaltyId)
    return sdk
}
