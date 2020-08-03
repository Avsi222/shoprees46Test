# shoprees46Test

[![CI Status](https://img.shields.io/travis/Avsi222/shoprees46Test.svg?style=flat)](https://travis-ci.org/Avsi222/shoprees46Test)
[![Version](https://img.shields.io/cocoapods/v/shoprees46Test.svg?style=flat)](https://cocoapods.org/pods/shoprees46Test)
[![License](https://img.shields.io/cocoapods/l/shoprees46Test.svg?style=flat)](https://cocoapods.org/pods/shoprees46Test)
[![Platform](https://img.shields.io/cocoapods/p/shoprees46Test.svg?style=flat)](https://cocoapods.org/pods/shoprees46Test)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

shoprees46Test is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'shoprees46Test'
```

# Usage

## Track
Send track event to server.
The track method has next events:

1) productView

Params :
id = String

2) categoryView 

Params :
id = String

3) productAddedToFavorities

Params :
id = String

4) productRemovedToFavorities

Params :
id = String

5) productAddedToCart

Params :
id = String

6) productRemovedFromCart

Params :
id = String

7) syncronizeCart

Params :
ids = [String]

8) orderCreated

Params :
orderId = String,
totalValue = Double,
products = [
    ( id = String, amount = Int )
] 

## Recommend
Get recommends product ids.

Input:

blockId  = String
productId = String

Output:

recomended = [Sting] - products ids array
title = String - title block recomend

## Search
Get search response for qeury in two statament ( partial search and full search)

Input:

query = String
search type = SearchType

Output:

categories = [Category]
products =  [Product]
productsTotal =  Int
queries = [Query]

## Author

Avsi222, «dorogin.arseniy@yandex.ru»

## License

shoprees46Test is available under the MIT license. See the LICENSE file for more info.
