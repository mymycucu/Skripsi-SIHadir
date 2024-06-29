//
//  AttendanceActionModel.swift
//  SIHadir
//
//  Created by Hilmy Noerfatih on 30/05/24.
//

import Foundation

struct AttendanceActionModel: Codable, Hashable {
    var id: Int?
    var created_at: Date?
    var device_id: String?
    var class_id: Int?
    var student_id: Int?
    var time_in: Date?
    var time_out: Date?
    var time_check: Date?
}
