
//
//  SimplePersonaliztionSDK.swift
//  shopTest
//
//  Created by Арсений Дорогин on 29.07.2020.
//

import Foundation

class SimplePersonaizationSDK: PersonalizationSDK {
    var shopId: String
    var userSession: String
    var userSeance: String

    var userId: String?
    var userEmail: String?
    var userPhone: String?
    var userLoyaltyId: String?

    var urlSession: URLSession

    var userInfo: InitResponse = InitResponse()

    init(shopId: String, userId: String? = nil, userEmail: String? = nil, userPhone: String? = nil, userLoyaltyId: String? = nil) {
        self.shopId = shopId
        // Generate seance
        userSeance = UUID().uuidString

        // Trying to fetch user session (permanent user ID)
        userSession = UserDefaults.standard.string(forKey: "personalization_ssid") ?? ""

        urlSession = URLSession.shared

        self.sendInitRequest { initResult in
            print("SDK INITED")
            switch initResult {
            case .success:
                let res = try! initResult.get()
                self.userInfo = res
                self.userSeance = res.seance
                self.userSession = res.ssid
            case .failure:
                // TODO: tell about failure
                break
            }
        }
    }

    func setProfileData(userEmail: String?, userPhone: String?, userLoyaltyId: String?, birthday: Date?, age: String?, firstName: String?, secondName: String?, lastName: String?, bouthSmth: Bool?, location: String?, gender: Gender?, completion: @escaping (Result<Void, SDKError>) -> Void) {
        let path = "push_attributes"
        var birthdayString = ""
        if let birthday = birthday {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD"
            birthdayString = dateFormatter.string(from: birthday)
        }
        let params: [String: String] = [
            "shop_id": shopId,
            "ssid": userSession,
            "seance": userSeance,
            "attributes[id]": userId ?? "",
            "attributes[gender]": gender == .male ? "m" : "f",
            "attributes[birthday]": birthdayString,
            "attributes[age]": age ?? "",
            "attributes[email]": userEmail ?? "",
            "attributes[first_name]": firstName ?? "",
            "attributes[middle_name]": secondName ?? "",
            "attributes[last_name]": lastName ?? "",
            "attributes[phone]": userPhone ?? "",
            "attributes[loyality_id]": userLoyaltyId ?? "",
            "attributes[location]": location ?? "",
            "attributes[bought_something]": (bouthSmth ?? false) ? "true" : "false",
        ]

        postRequest(path: path, params: params, completion: { result in
            do {
                let resJSON = try result.get()
                let status = resJSON["status"] as! String
                if status == "success" {
                    completion(.success(Void()))
                } else {
                    completion(.failure(.responseError))
                }
            } catch {
                completion(.failure(.initializationFailed))
            }
        })
    }

    func track(event: Event, completion: @escaping (Result<Void, SDKError>) -> Void) {
        let path = "push"
        var paramEvent = ""
        var params = [
            "shop_id": shopId,
            "ssid": userSession,
            "seance": userSeance,
        ]
        switch event {
        case let .categoryView(id):
            params["item_id[0]"] = id
            paramEvent = "category"
        case let .productView(id):
            params["item_id[0]"] = id
            paramEvent = "view"
        case let .productAddedToCart(id):
            params["item_id[0]"] = id
            paramEvent = "cart"
        case let .productAddedToFavorities(id):
            params["item_id[0]"] = id
            paramEvent = "wish"
        case let .productRemovedFromCart(id):
            params["item_id[0]"] = id
            paramEvent = "remove_from_cart"
        case let .productRemovedToFavorities(id):
            params["item_id[0]"] = id
            paramEvent = "remove_wish"
        case let .orderCreated(orderId, totalValue, products):
            for (index, item) in products.enumerated() {
                params["item_id[\(index)]"] = item.id
                params["amount[\(index)]"] = "\(item.amount)"
            }
            params["order_id"] = orderId
            params["total_value"] = "\(totalValue)"
            paramEvent = "purchase"
        case let .syncronizeCart(ids):
            for (index, item) in ids.enumerated() {
                params["item_id[\(index)]"] = item
            }
            paramEvent = "cart"
        }
        params["event"] = paramEvent

        postRequest(path: path, params: params, completion: { result in
            do {
                let resJSON = try result.get()
                let status = resJSON["status"] as! String
                if status == "success" {
                    completion(.success(Void()))
                } else {
                    completion(.failure(.responseError))
                }
            } catch {
                completion(.failure(.initializationFailed))
            }
        })
    }

    func recommend(blockId: String, currentProductId: String?, completion: @escaping (Result<RecommenderResponse, SDKError>) -> Void) {
        let path = "recommend"
        let params = [
            "shop_id": shopId,
            "ssid": userSession,
            "seance": userSeance,
            "recommender_type": "dynamic",
            "recommender_code": blockId,
            "segment": Bool.random() ? "A" : "B",
        ]

        getRequest(path: path, params: params) { result in
            do {
                let resJSON = try result.get()
                let resultResponse = RecommenderResponse(json: resJSON)
                completion(.success(resultResponse))
            } catch {
                completion(.failure(.initializationFailed))
            }
        }
    }

    func search(query: String, searchType: SearchType, completion: @escaping (Result<SearchResponse, SDKError>) -> Void) {
        let path = "search"
        let params = [
            "shop_id": shopId,
            "ssid": userSession,
            "seance": userSeance,
            "type": searchType == .full ? "full_search" : "instant_search",
            "search_query": query,
        ]
        getRequest(path: path, params: params) { result in
            do {
                let resJSON = try result.get()
                let resultResponse = SearchResponse(json: resJSON)
                completion(.success(resultResponse))
            } catch {
                completion(.failure(.initializationFailed))
            }
        }
    }

    private func sendInitRequest(completion: @escaping (Result<InitResponse, SDKError>) -> Void) {
        let path = "init_script"
        let params = [
            "shop_id": shopId,
        ]

        getRequest(path: path, params: params, true) { result in
            do {
                let resJSON = try result.get()
                let resultResponse = InitResponse(json: resJSON)
                UserDefaults.standard.set(resultResponse.ssid, forKey: "personalization_ssid")
                completion(.success(resultResponse))
            } catch {
                completion(.failure(.initializationFailed))
            }
        }
    }

    private let baseURL = "https://api.rees46.com/"

    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()

    private func getRequest(path: String, params: [String: String], _ isInit: Bool = false, completion: @escaping (Result<[String: Any], SDKError>) -> Void) {
        var url = baseURL + path + "?"

        for (index, item) in params.enumerated() {
            if index == params.count - 1 {
                url += item.key + "=" + item.value
            } else {
                url += item.key + "=" + item.value + "&"
            }
        }
        if let endUrl = URL(string: url) {
            urlSession.dataTask(with: endUrl) { result in
                switch result {
                case .success(let (response, data)):
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200 ..< 299 ~= statusCode else {
                        let json = try? JSONSerialization.jsonObject(with: data)
                        if let jsonObject = json as? [String: Any] {
                            let statusMessage = jsonObject["message"] as? String ?? ""
                            print("Status message: ", statusMessage)
                        }
                        completion(.failure(.invalidResponse))
                        return
                    }
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        if let jsonObject = json as? [String: Any] {
                            completion(.success(jsonObject))
                        } else {
                            completion(.failure(.decodeError))
                        }
                    } catch {
                        completion(.failure(.decodeError))
                    }
                case .failure(_):
                    completion(.failure(.invalidResponse))
                }
            }.resume()
        } else {
            completion(.failure(.invalidResponse))
        }
    }

    

    private func postRequest(path: String, params: [String: String], completion: @escaping (Result<[String: Any], SDKError>) -> Void) {
        if let url = URL(string: baseURL + path) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let postString = self.getPostString(params: params)
            request.httpBody = postString.data(using: .utf8)

            //print(url)
            //print(params["ssid"], params["seance"])

            self.urlSession.postTask(with: request) { result in
                switch result {
                case .success(let (response, data)):
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200 ..< 299 ~= statusCode else {
                        completion(.failure(.invalidResponse))
                        return
                    }
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        if let jsonObject = json as? [String: Any] {
                            completion(.success(jsonObject))
                        } else {
                            completion(.failure(.decodeError))
                        }
                    } catch {
                        completion(.failure(.decodeError))
                    }
                case .failure(_):
                    completion(.failure(.invalidResponse))
                }
            }.resume()
        } else {
            completion(.failure(.invalidResponse))
        }
    }

    private func getPostString(params: [String: Any]) -> String {
        var data = [String]()
        for (key, value) in params {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
}

extension URLSession {
    func dataTask(with url: URL, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { data, response, error in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }

    func postTask(with request: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return uploadTask(with: request, from: nil) { data, response, error in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }
}

/*
 //
 //  SimplePersonaliztionSDK.swift
 //  shopTest
 //
 //  Created by Арсений Дорогин on 29.07.2020.
 //

 import Foundation

 class SimplePersonaizationSDK: PersonalizationSDK {
 var shopId: String
 var userSession: String
 var userSeance: String

 var userId: String?
 var userEmail: String?
 var userPhone: String?
 var userLoyaltyId: String?

 var urlSession: URLSession

 var userInfo: InitResponse = InitResponse()

 init(shopId: String, userId: String? = nil, userEmail: String? = nil, userPhone: String? = nil, userLoyaltyId: String? = nil) {
     self.shopId = shopId
     // Generate seance
     userSeance = UUID().uuidString

     // Trying to fetch user session (permanent user ID)
     userSession = UserDefaults.standard.string(forKey: "personalization_ssid") ?? ""

     urlSession = URLSession.shared

     self.sendInitRequest { initResult in
         print("SDK INITED")
         switch initResult {
         case .success:
             let res = try! initResult.get()
             self.userInfo = res
             self.userSeance = res.seance
             self.userSession = res.ssid
         case .failure:
             // TODO: tell about failure
             break
         }
     }
 }

 func setProfileData(userEmail: String?, userPhone: String?, userLoyaltyId: String?, birthday: Date?, age: String?, firstName: String?, secondName: String?, lastName: String?, bouthSmth: Bool?, location: String?, gender: Gender?, completion: @escaping (Result<Void, SDKError>) -> Void) {
     let path = "push_attributes"
     var birthdayString = ""
     if let birthday = birthday {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "YYYY-MM-DD"
         birthdayString = dateFormatter.string(from: birthday)
     }
     let params: [String: String] = [
         "shop_id": shopId,
         "ssid": userSession,
         "seance": userSeance,
         "attributes[id]": userId ?? "",
         "attributes[gender]": gender == .male ? "m" : "f",
         "attributes[birthday]": birthdayString,
         "attributes[age]": age ?? "",
         "attributes[email]": userEmail ?? "",
         "attributes[first_name]": firstName ?? "",
         "attributes[middle_name]": secondName ?? "",
         "attributes[last_name]": lastName ?? "",
         "attributes[phone]": userPhone ?? "",
         "attributes[loyality_id]": userLoyaltyId ?? "",
         "attributes[location]": location ?? "",
         "attributes[bought_something]": (bouthSmth ?? false) ? "true" : "false",
     ]

     postRequest(path: path, params: params, completion: { result in
         do {
             let resJSON = try result.get()
             let status = resJSON["status"] as! String
             if status == "success" {
                 completion(.success(Void()))
             } else {
                 completion(.failure(.responseError))
             }
         } catch {
             completion(.failure(.initializationFailed))
         }
     })
 }

 func track(event: Event, completion: @escaping (Result<Void, SDKError>) -> Void) {
     let path = "push"
     var paramEvent = ""
     var params = [
         "shop_id": shopId,
         "ssid": userSession,
         "seance": userSeance,
     ]
     switch event {
     case let .categoryView(id):
         params["item_id[0]"] = id
         paramEvent = "category"
     case let .productView(id):
         params["item_id[0]"] = id
         paramEvent = "view"
     case let .productAddedToCart(id):
         params["item_id[0]"] = id
         paramEvent = "cart"
     case let .productAddedToFavorities(id):
         params["item_id[0]"] = id
         paramEvent = "wish"
     case let .productRemovedFromCart(id):
         params["item_id[0]"] = id
         paramEvent = "remove_from_cart"
     case let .productRemovedToFavorities(id):
         params["item_id[0]"] = id
         paramEvent = "remove_wish"
     case let .orderCreated(orderId, totalValue, products):
         for (index, item) in products.enumerated() {
             params["item_id[\(index)]"] = item.id
             params["amount[\(index)]"] = "\(item.amount)"
         }
         params["order_id"] = orderId
         params["total_value"] = "\(totalValue)"
         paramEvent = "purchase"
     case let .syncronizeCart(ids):
         for (index, item) in ids.enumerated() {
             params["item_id[\(index)]"] = item
         }
         paramEvent = "cart"
     }
     params["event"] = paramEvent

     postRequest(path: path, params: params, completion: { result in
         do {
             let resJSON = try result.get()
             let status = resJSON["status"] as! String
             if status == "success" {
                 completion(.success(Void()))
             } else {
                 completion(.failure(.responseError))
             }
         } catch {
             completion(.failure(.initializationFailed))
         }
     })
 }

 func recommend(blockId: String, currentProductId: String?, completion: @escaping (Result<RecommenderResponse, SDKError>) -> Void) {
     let path = "recommend"
     let params = [
         "shop_id": shopId,
         "ssid": userSession,
         "seance": userSeance,
         "recommender_type": "dynamic",
         "recommender_code": blockId,
         "segment": Bool.random() ? "A" : "B",
     ]

     getRequest(path: path, params: params) { result in
         do {
             let resJSON = try result.get()
             let resultResponse = RecommenderResponse(json: resJSON)
             completion(.success(resultResponse))
         } catch {
             completion(.failure(.initializationFailed))
         }
     }
 }

 func search(query: String, searchType: SearchType, completion: @escaping (Result<SearchResponse, SDKError>) -> Void) {
     let path = "search"
     let params = [
         "shop_id": shopId,
         "ssid": userSession,
         "seance": userSeance,
         "type": searchType == .full ? "full_search" : "instant_search",
         "search_query": query,
     ]
     getRequest(path: path, params: params) { result in
         do {
             let resJSON = try result.get()
             let resultResponse = SearchResponse(json: resJSON)
             completion(.success(resultResponse))
         } catch {
             completion(.failure(.initializationFailed))
         }
     }
 }

 private func sendInitRequest(completion: @escaping (Result<InitResponse, SDKError>) -> Void) {
     let path = "init_script"
     let params = [
         "shop_id": shopId,
         "ssid": userSession,
         "seance": userSeance,
     ]

     getRequest(path: path, params: params) { result in
         do {
             let resJSON = try result.get()
             let resultResponse = InitResponse(json: resJSON)
             UserDefaults.standard.set(resultResponse.ssid, forKey: "personalization_ssid")
             completion(.success(resultResponse))
         } catch {
             completion(.failure(.initializationFailed))
         }
     }
 }

 private let baseURL = "https://api.rees46.com/"

 private let jsonDecoder: JSONDecoder = {
     let jsonDecoder = JSONDecoder()
     jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "yyyy-mm-dd"
     jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
     return jsonDecoder
 }()

 private func getRequest(path: String, params: [String: String],_ isInit: Bool = false, completion: @escaping (Result<[String: Any], SDKError>) -> Void) {
     var url = baseURL + path + "?"

     for (index, item) in params.enumerated() {
         if index == params.count - 1 {
             url += item.key + "=" + item.value
         } else {
             url += item.key + "=" + item.value + "&"
         }
     }
     if let endUrl = URL(string: url) {
         if isInit{
             self.urlSession.dataTask(with: endUrl) { result in
                 switch result {
                 case .success(let (response, data)):
                     guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200 ..< 299 ~= statusCode else {
                         let json = try? JSONSerialization.jsonObject(with: data)
                         if let jsonObject = json as? [String: Any] {
                             let statusMessage = jsonObject["message"] as? String ?? ""
                             print("Status message: ", statusMessage)
                         }
                         completion(.failure(.invalidResponse))
                         return
                     }
                     do {
                         let json = try JSONSerialization.jsonObject(with: data)
                         if let jsonObject = json as? [String: Any] {
                             completion(.success(jsonObject))
                         } else {
                             completion(.failure(.decodeError))
                         }
                     } catch {
                         completion(.failure(.decodeError))
                     }
                 case let .failure(error):
                     completion(.failure(.invalidResponse))
                 }
             }.resume()
         }else{
             DispatchQueue.main.async {
                 print(endUrl.absoluteString)
                 print(params["ssid"], params["seance"])
                 self.urlSession.dataTask(with: endUrl) { result in
                     switch result {
                     case .success(let (response, data)):
                         guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200 ..< 299 ~= statusCode else {
                             let json = try? JSONSerialization.jsonObject(with: data)
                             if let jsonObject = json as? [String: Any] {
                                 let statusMessage = jsonObject["message"] as? String ?? ""
                                 print("Status message: ", statusMessage)
                             }
                             completion(.failure(.invalidResponse))
                             return
                         }
                         do {
                             let json = try JSONSerialization.jsonObject(with: data)
                             if let jsonObject = json as? [String: Any] {
                                 completion(.success(jsonObject))
                             } else {
                                 completion(.failure(.decodeError))
                             }
                         } catch {
                             completion(.failure(.decodeError))
                         }
                     case let .failure(error):
                         completion(.failure(.invalidResponse))
                     }
                 }.resume()
             }
         }
     } else {
         completion(.failure(.invalidResponse))
     }
 }

 private func postRequest(path: String, params: [String: String], completion: @escaping (Result<[String: Any], SDKError>) -> Void) {
     if let url = URL(string: baseURL + path) {
         DispatchQueue.main.async {
             print(url.absoluteString)
             print(params["ssid"], params["seance"])
             var request = URLRequest(url: url)
             request.httpMethod = "POST"
             let postString = self.getPostString(params: params)
             request.httpBody = postString.data(using: .utf8)

             self.urlSession.postTask(with: request) { result in
                 switch result {
                 case .success(let (response, data)):
                     guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200 ..< 299 ~= statusCode else {
                         completion(.failure(.invalidResponse))
                         return
                     }
                     do {
                         let json = try JSONSerialization.jsonObject(with: data)
                         if let jsonObject = json as? [String: Any] {
                             completion(.success(jsonObject))
                         } else {
                             completion(.failure(.decodeError))
                         }
                     } catch {
                         completion(.failure(.decodeError))
                     }
                 case let .failure(error):
                     completion(.failure(.invalidResponse))
                 }
             }.resume()
         }
     } else {
         completion(.failure(.invalidResponse))
     }
 }

 private func getPostString(params: [String: Any]) -> String {
     var data = [String]()
     for (key, value) in params {
         data.append(key + "=\(value)")
     }
     return data.map { String($0) }.joined(separator: "&")
 }
 }

 extension URLSession {
 func dataTask(with url: URL, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
     return dataTask(with: url) { data, response, error in
         if let error = error {
             result(.failure(error))
             return
         }
         guard let response = response, let data = data else {
             let error = NSError(domain: "error", code: 0, userInfo: nil)
             result(.failure(error))
             return
         }
         result(.success((response, data)))
     }
 }

 func postTask(with request: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
     return uploadTask(with: request, from: nil) { data, response, error in
         if let error = error {
             result(.failure(error))
             return
         }
         guard let response = response, let data = data else {
             let error = NSError(domain: "error", code: 0, userInfo: nil)
             result(.failure(error))
             return
         }
         result(.success((response, data)))
     }
 }
 }
 */
