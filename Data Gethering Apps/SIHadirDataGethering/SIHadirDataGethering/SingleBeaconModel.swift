//
//  SingleBeaconModel.swift
//  SIHadirDataGethering
//
//  Created by Hilmy Noerfatih on 22/05/24.
//

import Foundation

struct SingleBeaconModel: Decodable, Encodable, Hashable {
    var beacon_id: UUID
    var proximity: String
    var distance: Double
    var rssi: Int
    var actual: Double
    var description: String
    var created_at: Date
}
