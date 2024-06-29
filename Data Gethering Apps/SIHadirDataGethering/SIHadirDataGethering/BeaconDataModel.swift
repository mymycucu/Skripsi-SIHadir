//
//  BeaconDataModel.swift
//  SIHadirDataGethering
//
//  Created by Hilmy Noerfatih on 13/02/24.
//

import Foundation

struct BeaconDataModel: Decodable, Encodable, Hashable {
    var beacon_id: UUID
    var proximity: String
    var distance: Double
    var rssi: Int
    var description: String
    var created_at: Date
}
