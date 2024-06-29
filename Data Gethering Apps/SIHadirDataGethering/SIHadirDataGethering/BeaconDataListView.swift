//
//  BeaconDataListView.swift
//  SIHadirDataGethering
//
//  Created by Hilmy Noerfatih on 13/02/24.
//

import SwiftUI
import Supabase

struct BeaconDataListView: View {
//    @ObservedObject var beaconFinder: BeaconFinder
    @Binding var isLoading: Bool
    @State var actionDataLst: [ActionDataModel] = []
    
    var body: some View {
        VStack{
            Text("Data")
            if actionDataLst.isEmpty{
                Text("-")
            }else{
                List{
                    ForEach(actionDataLst, id: \.self) { actionData in
                        VStack(alignment: .leading){
                            HStack{
//                                Text("\(actionData.time)")
//                                Text("\(actionData.proximity_one)")
//                                Text("\(actionData.distance_one, specifier: "%.2f")")
//                                Text("\(actionData.proximity_two)")
//                                Text("\(actionData.distance_two, specifier: "%.2f")")
                            }
                            Text("\(actionData.description)")
                        }
                    }
                }
                
            }
        }
        .onAppear(perform: {
            Task{
                actionDataLst = await fetchData()
            }
        })
        .refreshable {
            Task{
                actionDataLst = await fetchData()
            }
        }
    }
    
    func fetchData() async -> [ActionDataModel] {
        let client = SupabaseClient(supabaseURL: URL(string: "https://edhzzdfkezgmtlrljjlt.supabase.co")!, supabaseKey: Constant.Api.apiKey)
        var actionData: [ActionDataModel] = []
        
        do{
            actionData = try await client.database
                .from("class_beacon")
                .select("*")
                .execute()
                .value
        }catch{
            
        }
        return actionData
    }
}

//#Preview {
//    BeaconDataListView(beaconFinder: <#BeaconFinder#>, beaconFinder1: <#BeaconFinder#>)
//}
