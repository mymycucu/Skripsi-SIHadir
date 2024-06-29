//
//  ActionDataGetheringViewModel.swift
//  SIHadirDataGethering
//
//  Created by Hilmy Noerfatih on 15/03/24.
//

import Foundation
import Supabase

class ActionDataGetheringViewModel: ObservableObject {

    func postData(door: [BeaconDataModel], inside: [BeaconDataModel], desc: String, behavior: String) async {
        var doorData = door
        var insideData = inside
        var actionDataLst: [ActionDataModel] = []
        
        doorData.sort { $0.created_at < $1.created_at}
        insideData.sort { $0.created_at < $1.created_at}
        
        var actionDataDoorQueue: [String] = []
        var actionDataInsideQueue: [String] = []
        
        let dataCount = doorData.count
        for i in 0...dataCount-1{
            
            if actionDataDoorQueue.count >= 15 {
                actionDataDoorQueue.removeFirst()
                actionDataDoorQueue.append(doorData[i].proximity)
            }else{
                actionDataDoorQueue.append(doorData[i].proximity)
            }
            
            if actionDataInsideQueue.count >= 15 {
                actionDataInsideQueue.removeFirst()
                actionDataInsideQueue.append(insideData[i].proximity)
            }else{
                actionDataInsideQueue.append(insideData[i].proximity)
            }
            
            var tempDataDoor = actionDataDoorQueue
            var tempDataInside = actionDataInsideQueue
            while tempDataDoor.count != 15 {
                tempDataDoor.append("")
            }
            while tempDataInside.count != 15 {
                tempDataInside.append("")
            }
            
            let actionData = ActionDataModel(
                created_at: doorData[i].created_at,
                description: desc,
                door_1: tempDataDoor[0],
                inside_1: tempDataInside[0],
                door_2: tempDataDoor[1],
                inside_2: tempDataInside[1],
                door_3: tempDataDoor[2],
                inside_3: tempDataInside[2],
                door_4: tempDataDoor[3],
                inside_4: tempDataInside[3],
                door_5: tempDataDoor[4],
                inside_5: tempDataInside[4],
                door_6: tempDataDoor[5],
                inside_6: tempDataInside[5],
                door_7: tempDataDoor[6],
                inside_7: tempDataInside[6],
                door_8: tempDataDoor[7],
                inside_8: tempDataInside[7],
                door_9: tempDataDoor[8],
                inside_9: tempDataInside[8],
                door_10: tempDataDoor[9],
                inside_10: tempDataInside[9],
                door_11: tempDataDoor[10],
                inside_11: tempDataInside[10],
                door_12: tempDataDoor[11],
                inside_12: tempDataInside[11],
                door_13: tempDataDoor[12],
                inside_13: tempDataInside[12],
                door_14: tempDataDoor[13],
                inside_14: tempDataInside[13],
                door_15: tempDataDoor[14],
                inside_15: tempDataInside[14],
                behavior: behavior)
            actionDataLst.append(actionData)
        }
        for i in 0...5{
            var tempDataDoor = actionDataDoorQueue
            var tempDataInside = actionDataInsideQueue
            while tempDataDoor.count != 15 {
                tempDataDoor.append("")
            }
            while tempDataInside.count != 15 {
                tempDataInside.append("")
            }
            if actionDataDoorQueue.count >= 15 {
                actionDataDoorQueue.removeFirst()
                actionDataDoorQueue.append("")
            }else{
                actionDataDoorQueue.append("")
            }
            
            if actionDataInsideQueue.count >= 15 {
                actionDataInsideQueue.removeFirst()
                actionDataInsideQueue.append("")
            }else{
                actionDataInsideQueue.append("")
            }
            let actionData = ActionDataModel(
                created_at: doorData[i].created_at,
                description: desc,
                door_1: tempDataDoor[0],
                inside_1: tempDataInside[0],
                door_2: tempDataDoor[1],
                inside_2: tempDataInside[1],
                door_3: tempDataDoor[2],
                inside_3: tempDataInside[2],
                door_4: tempDataDoor[3],
                inside_4: tempDataInside[3],
                door_5: tempDataDoor[4],
                inside_5: tempDataInside[4],
                door_6: tempDataDoor[5],
                inside_6: tempDataInside[5],
                door_7: tempDataDoor[6],
                inside_7: tempDataInside[6],
                door_8: tempDataDoor[7],
                inside_8: tempDataInside[7],
                door_9: tempDataDoor[8],
                inside_9: tempDataInside[8],
                door_10: tempDataDoor[9],
                inside_10: tempDataInside[9],
                door_11: tempDataDoor[10],
                inside_11: tempDataInside[10],
                door_12: tempDataDoor[11],
                inside_12: tempDataInside[11],
                door_13: tempDataDoor[12],
                inside_13: tempDataInside[12],
                door_14: tempDataDoor[13],
                inside_14: tempDataInside[13],
                door_15: tempDataDoor[14],
                inside_15: tempDataInside[14],
                behavior: behavior)
            actionDataLst.append(actionData)
        }
        
        let client = SupabaseClient(supabaseURL: URL(string: "https://edhzzdfkezgmtlrljjlt.supabase.co")!, supabaseKey: Constant.Api.apiKey)
        do{
            try await client.database
                .from("actions")
                .insert(actionDataLst)
                .execute()
        }catch{
            
        }
    }
}
