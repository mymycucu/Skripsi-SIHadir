//
//  BeaconView.swift
//  SIHadirDataGethering
//
//  Created by Hilmy Noerfatih on 13/02/24.
//

import SwiftUI
import Supabase

struct BeaconView: View {
    @ObservedObject var beaconFinder: BeaconFinder
    @ObservedObject var beaconFinder1: BeaconFinder
    @Binding var isLoading: Bool
    @State var dataDesc = ""
    @State var counter = 0.0
    
    var body: some View {
        VStack{
            Text("counter : \(String(format: "%.1f", counter))")
                .padding()
            HStack{
                VStack{
                    Text("Beacon 1")
                    Text("\(beaconFinder.lastRssi)")
                    Text(beaconFinder.lastProximity)
                    Text(String(beaconFinder.lastDistance))
                    Text("amount: \(beaconFinder.beaconDataList.count)")
                }
                VStack{
                    Text("Beacon 2")
                    Text("\(beaconFinder1.lastRssi)")
                    Text(beaconFinder1.lastProximity)
                    Text(String(beaconFinder1.lastDistance))
                    Text("amount: \(beaconFinder1.beaconDataList.count)")
                }
            }
            
            TextField("Desc", text: $dataDesc)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Optional: Applies a rounded border style
                .padding()
            
            HStack{
                Button(action: {
                    if counter <= 1 {
                        counter -= 0.1
                    }else{
                        counter -= 1
                    }
                }, label: {
                    Text("- Counter")
                }).padding(.top)
                
                Button(action: {
                    if counter < 0.99  {
                        counter += 0.1
                    }else{
                        counter += 1
                    }
                }, label: {
                    Text("+ Counter")
                }).padding(.top)
            }
            
            Button(action: {
                beaconFinder.toggleRecording(desc: dataDesc)
                beaconFinder1.toggleRecording(desc: dataDesc)
            }, label: {
                if beaconFinder.isRecording{
                    Text("stop recording").foregroundStyle(.red)
                }else{
                    Text("start recording").foregroundStyle(.green)
                }
            }).padding(.top)
            
            Button(action: {
                isLoading = true
                Task{
                    await postRecordOne()
                    isLoading = false
                    beaconFinder.clearData()
                }
            }, label: {
                Text("Upload Data Beacon One")
            }).buttonStyle(.borderedProminent)
                .padding(.top)
            
            Button(action: {
                isLoading = true
                Task{
                    await postRecordTwo()
                    isLoading = false
                    beaconFinder1.clearData()
                }
            }, label: {
                Text("Upload Data Beacon Two")
            }).buttonStyle(.borderedProminent)
                .padding(.top)
            
            Button(action: {
                isLoading = true
                Task{
                    await postRecord()
                    isLoading = false
                    beaconFinder.clearData()
                    beaconFinder1.clearData()
                }
            }, label: {
                Text("Upload Data Both")
            }).buttonStyle(.borderedProminent)
                .padding(.top)
            
            Button(action: {
                beaconFinder.clearData()
                beaconFinder1.clearData()
            }, label: {
                Text("Clear Data")
            }).padding(.top)
        }
        .onAppear(perform: {
            dataDesc = beaconFinder.beaconDataDesc
        })
    }
    
    func postRecord() async {
        let client = SupabaseClient(supabaseURL: URL(string: "https://edhzzdfkezgmtlrljjlt.supabase.co")!, supabaseKey: Constant.Api.apiKey)
        var tempRecords = beaconFinder.beaconDataList + beaconFinder1.beaconDataList
        tempRecords.sort { $0.created_at < $1.created_at }
        
        var records : [SingleBeaconModel] = []
        
        for i in tempRecords{
            records.append(SingleBeaconModel(beacon_id: i.beacon_id, proximity: i.proximity, distance: i.distance, rssi: i.rssi, actual: counter, description: "data-v2 \(dataDesc)" , created_at: i.created_at))
        }
        
        do{
            try await client.database
                .from("beacon")
                .insert(records)
                .execute()
        }catch{
            
        }
    }
    
    func postRecordOne() async {
        let client = SupabaseClient(supabaseURL: URL(string: "https://edhzzdfkezgmtlrljjlt.supabase.co")!, supabaseKey: Constant.Api.apiKey)
        var tempRecords = beaconFinder.beaconDataList
        
        var records : [SingleBeaconModel] = []
        
        for i in tempRecords{
            records.append(SingleBeaconModel(beacon_id: i.beacon_id, proximity: i.proximity, distance: i.distance, rssi: i.rssi, actual: counter, description: "data-v2 \(dataDesc)" , created_at: i.created_at))
        }
        do{
            try await client.database
                .from("beacon")
                .insert(records)
                .execute()
        }catch{
            
        }
    }
    
    func postRecordTwo() async {
        let client = SupabaseClient(supabaseURL: URL(string: "https://edhzzdfkezgmtlrljjlt.supabase.co")!, supabaseKey: Constant.Api.apiKey)
        var tempRecords = beaconFinder1.beaconDataList
        
        var records : [SingleBeaconModel] = []
        
        for i in tempRecords{
            records.append(SingleBeaconModel(beacon_id: i.beacon_id, proximity: i.proximity, distance: i.distance, rssi: i.rssi, actual: counter, description: "data-v2 \(dataDesc)" , created_at: i.created_at))
        }
        do{
            try await client.database
                .from("beacon")
                .insert(records)
                .execute()
        }catch{
            
        }
    }
}

//#Preview {
//    MultiBeaconView()
//}
