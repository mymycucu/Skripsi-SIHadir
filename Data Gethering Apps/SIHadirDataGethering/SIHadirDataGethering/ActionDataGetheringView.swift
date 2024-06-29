//
//  ActionDataGetheringView.swift
//  SIHadirDataGethering
//
//  Created by Hilmy Noerfatih on 15/03/24.
//

import SwiftUI
import Supabase

struct ActionDataGetheringView: View {
    @ObservedObject var viewModel = ActionDataGetheringViewModel()
    @ObservedObject var beaconFinder: BeaconFinder
    @ObservedObject var beaconFinder1: BeaconFinder
    @Binding var isLoading: Bool
    @State var dataDesc = UserDefaults.standard.string(forKey: "lastDataDesc") ?? "No data saved"
    @State var counter = 1
    
    var body: some View {
        VStack{
            Text("counter : \(counter)")
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
            
            Button(action: {
                beaconFinder.toggleRecording(desc: dataDesc)
                beaconFinder1.toggleRecording(desc: dataDesc)
                UserDefaults.standard.set(dataDesc, forKey: "lastDataDesc")
                
            }, label: {
                if beaconFinder.isRecording{
                    Text("stop recording").foregroundStyle(.red)
                }else{
                    Text("start recording").foregroundStyle(.green)
                }
            }).padding(.top)
            
            Button(action: {
                isLoading = true
                beaconFinder.isRecording = false
                beaconFinder1.isRecording = false
                Task{
                    await viewModel.postData(
                        door:beaconFinder.beaconDataList,
                        inside:beaconFinder1.beaconDataList, desc: "\(dataDesc) IN - \(counter)", behavior: "In")
                    beaconFinder.clearData()
                    beaconFinder1.clearData()
                    isLoading = false
                }
            }, label: {
                Text("Upload Data in")
            }).buttonStyle(.borderedProminent)
                .padding(.top)
            
            Button(action: {
                isLoading = true
                beaconFinder.isRecording = false
                beaconFinder1.isRecording = false
                Task{
                    await viewModel.postData(
                        door:beaconFinder.beaconDataList,
                        inside:beaconFinder1.beaconDataList, desc: "\(dataDesc) PASS - \(counter)", behavior: "Other")
                    beaconFinder.clearData()
                    beaconFinder1.clearData()
                    isLoading = false
                }
            }, label: {
                Text("Upload Data pass")
            }).buttonStyle(.borderedProminent)
                .padding(.top)
            
            Button(action: {
                isLoading = true
                beaconFinder.isRecording = false
                beaconFinder1.isRecording = false
                Task{
                    await viewModel.postData(
                        door:beaconFinder.beaconDataList,
                        inside:beaconFinder1.beaconDataList, desc: "\(dataDesc) OUT - \(counter)", behavior: "Out")
                    beaconFinder.clearData()
                    beaconFinder1.clearData()
                    isLoading = false
                }
            }, label: {
                Text("Upload Data Out")
            }).buttonStyle(.borderedProminent)
                .padding(.top)
            
            HStack{
                Button(action: {
                    counter -= 1
                }, label: {
                    Text("- Counter")
                }).padding(.top)
                
                Button(action: {
                    counter += 1
                }, label: {
                    Text("+ Counter")
                }).padding(.top)
            }
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
}

#Preview {
    ActionDataGetheringView(
        beaconFinder: BeaconFinder(
            beaconUUID: UUID(uuidString: "96B4164C-4EEB-55A7-DC43-BC177AEF8239")!,
            beaconMajor: UInt16(10),
            beaconMinor: UInt16(1)
        ),
        beaconFinder1:
            BeaconFinder(
                beaconUUID: UUID(uuidString: "96B4164C-4EEB-55A7-DC43-BC177AEF8239")!,
                beaconMajor: UInt16(10),
                beaconMinor: UInt16(1)
            )
        , isLoading: .constant(false))
}
