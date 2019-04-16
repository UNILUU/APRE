//
//  News.swift
//  News
//
//  Created by Xiaolu Tian on 3/28/19.
//

import Foundation

struct News : Codable, Equatable{
    let uuid: String
    let title : String
    let main_image : Image
    let published_at : String
    let publisher : String
    let summary: String
}


struct Image : Codable, Equatable{
    let resolutions : [thumbNail]
}

struct thumbNail: Codable, Equatable{
    let url : String
    let height : Int
    let width : Int
}

struct NewsListResponse : Codable{
    let items : NewsResult
    let more : MoreResult
}

struct NewsResult : Codable{
    let result : [News]
}


struct MoreResult: Codable{
    let result : [NewsID]
}
struct NewsID: Codable, Equatable{
    let uuid : String
}


// MARK - Inflatio
struct InflationResponse : Codable{
    let items : NewsResult
}


