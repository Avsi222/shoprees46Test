# shoprees46Test

[![CI Status](https://img.shields.io/travis/Avsi222/shoprees46Test.svg?style=flat)](https://travis-ci.org/Avsi222/shoprees46Test)
[![Version](https://img.shields.io/cocoapods/v/shoprees46Test.svg?style=flat)](https://cocoapods.org/pods/shoprees46Test)
[![License](https://img.shields.io/cocoapods/l/shoprees46Test.svg?style=flat)](https://cocoapods.org/pods/shoprees46Test)
[![Platform](https://img.shields.io/cocoapods/p/shoprees46Test.svg?style=flat)](https://cocoapods.org/pods/shoprees46Test)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

## CocoaPods

shoprees46Test is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'shoprees46Test'
```

## Swift Package Manager

To install click the upside menu 'File' -> 'Swift Packages' -> 'Add package dependency'. Next insert this url:

```ruby
https://github.com/Avsi222/shoprees46Test.git
```

# Usage
## Initialization

```swift

import shoprees46Test

.....
var sdk = createPersonalizationSDK(shopId: "API_KEY")
```

## Get session id

```swift
let ssid = sdk.getSSID()
```

## Track
Send track event to server.
The track method has next events:

1) Product view

```swift
sdk.track(event: .productView(id: "123")) { _ in
      print("   Product view callback")
}
```

2) Category View 

```swift
sdk.track(event: .categoryView(id: "123")) { _ in
            print("   Category view callback")
}
```

3) Product add to favorites

```swift
sdk.track(event: .productAddedToFavorities(id: "123")) { _ in
            print("   Product added to favorities callback")
}
```

4) Product remove from Favorites

```swift
sdk.track(event: .productRemovedToFavorities(id: "123")) { _ in
            print("   Product removed from favorities callback")
}
```

5) Product add to Cart

```swift
sdk.track(event: .productAddedToCart(id: "123")) { _ in
    print("   Product added to cart callback")
}
```

6) Product remove from cart

```swift
sdk.track(event: .productRemovedFromCart(id: "123")) { _ in
    print("   Product removed from cart callback")
}
```

7) Syncronize cart

```swift
sdk.track(event: .syncronizeCart(ids: ["1", "2"])) { _ in
    print("   Cart syncronized callback")
}
```

8) Create Order

```swift
sdk.track(event: .orderCreated(orderId: "123", totalValue: 33.3, products: [(id: "1", amount: 3), (id: "2", amount: 1)])) { _ in
    print("   Order created callback")
}
```

## Recommend
Get recommends product ids.
```swift
sdk.recommend(blockId: "block_id") { recomendResult in
    print("   Recommendations requested callback")
}
```

Or

```swift
sdk.recommend(blockId: "block_id", currentProductId: "1") { recomendResult in
    print("   Recommendations requested callback")
}
```

Output:

recomended = [Sting] - products ids array; 
title = String - title block recomend

## Search
Get search response for qeury in two statament ( partial search and full search)

Partial search: 

```swift
sdk.search(query: "iphone", searchType: .instant) { searchResult in
    print("   Instant search callback")
}
```

Full search: 

```swift
sdk.search(query: "iphone", searchType: .full) { searchResult in
    print("   Full search callback")
}
```

Output:

categories = [Category]; 
products =  [Product]; 
productsTotal =  Int; 
queries = [Query] .

## Set user data
Send user data

```swift
sdk.setProfileData(userEmail: "email") { (profileDataResp) in
      print("     Profile data callback")
 }
```

Or 

```swift
sdk.setProfileData(userEmail: "email", userPhone: "123", userLoyaltyId: "1", birthday: nil, age: nil, firstName: "Ars", secondName: "test", lastName: nil, location: nil, gender: .male) { (profileDataResp) in
      print("     Profile data callback")
 }
```

## Author

Avsi222, «dorogin.arseniy@yandex.ru»

## License

shoprees46Test is available under the MIT license. See the LICENSE file for more info.
