//
//  AttentanceViewModel.swift
//  SIHadir
//
//  Created by Hilmy Noerfatih on 28/05/24.
//

import Foundation
import Supabase

class AttendanceViewModel: ObservableObject {
    func getHistoryData() async -> [AttendanceHistoryModel]{
        let client = SupabaseClient(supabaseURL: URL(string: "https://edhzzdfkezgmtlrljjlt.supabase.co")!, supabaseKey: Constant.Api.apiKey)
        do {
            let data : [AttendanceActionModel] = try await client
                .from("attendance")
                .select()
                .execute()
                .value
            
            if data.isEmpty{
                return []
            }else{
                return convertToHistoryModel(data)
            }
            
        }catch{
            
        }
        
        return []
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    func convertToHistoryModel(_ actions: [AttendanceActionModel]) -> [AttendanceHistoryModel] {
        return actions.compactMap { action in
            guard let createdAt = action.created_at else { return nil }
            guard let timeOut = action.time_out else {return nil}
            let dateString = formatDate(createdAt)
            var status = 0
            
            if action.time_check == nil {
                status = 1
            } else if action.time_in != nil && action.time_out != nil && action.time_check != nil {
                status = 3
            }

            return AttendanceHistoryModel(date: dateString, status: status)
        }
    }
}

