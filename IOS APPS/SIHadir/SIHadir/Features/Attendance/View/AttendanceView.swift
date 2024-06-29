//
//  DraftView.swift
//  SIHadir
//
//  Created by Hilmy Noerfatih on 29/05/24.
//

import SwiftUI

struct AttendanceView: View {
    @ObservedObject var beaconFinder = BeaconFinder.shared
    @ObservedObject var viewModel = AttendanceViewModel()
    
    @State var showDebug = false
    @State var historyData: [AttendanceHistoryModel] = []

    var body: some View {
        ZStack {
            
            VStack {
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        Text("Muhammad Hilmy Noerfatih").bold()
                            .font(.title2)
                        Text("2006597512")
                            .font(.headline)
                    }
                    Spacer()
                    Button(action: {
                        showDebug.toggle()
                    }, label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.black)
                    })
                    
                }
                .padding()
                .padding(.bottom, 40)
                
                VStack {
                    VStack {
                        HStack(alignment: .top){
                            VStack(alignment: .leading){
                                Text("JarKomDat")
                                    .font(.title)
                                    .bold()
                                Text("13.00 - 14.40")
                            }
                            Spacer()
                            VStack(alignment: .leading){
                                Text("3.3114")
                                    .font(.title)
                            }
                        }
                        
                        HStack(alignment: .top){
                            VStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(beaconFinder.db_data.time_in == nil ? Color.gray : Color("GoldenYellow"))
                                    .frame(height: 10)
                                Text("In")
                                Text(getStringDate(date: beaconFinder.db_data.time_in))
                                    .font(.title2)
                                    .bold()
                            }
                            VStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(beaconFinder.db_data.time_check != nil ? Color("GoldenYellow") : beaconFinder.db_data.time_out == nil ? Color.gray:beaconFinder.isInside ? Color.gray : Color.red )
                                    .frame(height: 10)
                                Text("Check")
                                Text(getStringDate(date: beaconFinder.db_data.time_check))
                                    .font(.title2)
                                    .bold()
                            }
                            VStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(beaconFinder.db_data.time_out == nil ? Color.gray : beaconFinder.db_data.time_check == nil ? beaconFinder.isInside ? Color.gray : Color.red :  Color("GoldenYellow"))
                                    .frame(height: 10)
                                Text("Out")
                                if beaconFinder.isInside{
                                    Text("--:--")
                                        .font(.title2)
                                        .bold()
                                }else{
                                    Text(getStringDate(date: beaconFinder.db_data.time_out))
                                        .font(.title2)
                                        .bold()
                                }
                                
                            }
                        }
                        
                        // check if in checking windows
                        if beaconFinder.isCheckWindow {
                            Divider()
                                .frame(height: 2)
                                .overlay(.gray)
                                
                            Button(action: {
                                beaconFinder.handleBiometricAuthentication()
                            }, label: {
                                Text("Confirm")
                                    .font(.title)
                                    .frame(maxWidth: .infinity)
                            })
                            .padding(.vertical, 10)
                            .foregroundColor(.black)
                            .background(Color("GoldenYellow"))
                            .cornerRadius(10)
                            Text("*You only have 5 Min to confirm your attendance")
                                .foregroundStyle(.red)
                                .font(.footnote)
                        }

                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(8)
                    .shadow(radius: 10, y:5)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    HStack {
                        Text("Attendance History")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            if historyData.isEmpty{
                                Text("Loading...")
                            }else{
                                ForEach(historyData,id: \.self) { i in
                                    HistoryCardLineView(date: i.date, status: i.status)
                                }
                            }
                        }
                        .padding(.top, 1)
                        .frame(maxWidth: .infinity)
                    }
                    .onAppear(perform: {
                        Task{
                            historyData = await viewModel.getHistoryData()
                        }
                    })
                    .refreshable {
                        Task{
                            historyData = await viewModel.getHistoryData()
                        }
                    }
                }
                .offset(y: -50)
                .ignoresSafeArea()
                .background(.white)
                
            }
            if showDebug{
                VStack{
                    Text("\(BeaconFinder.shared.db_data.id ?? -1)")
                        .foregroundStyle(.white)
                    Text(BeaconFinder.shared.behavior)
                        .foregroundStyle(.white)
                    Text(BeaconFinder.shared.isInside.description)
                        .foregroundStyle(.white)
                    Text("in: \(getStringDate(date:BeaconFinder.shared.db_data.time_in))")
                        .foregroundStyle(.white)
                    Text("out: \(getStringDate(date:BeaconFinder.shared.db_data.time_out))")
                        .foregroundStyle(.white)
                    Button(action:{
                        BeaconFinder.shared.resetRandomCheck()
                    } , label: {
                        Text("reset")
                    })
                    Spacer().frame(height: 10)
                    Button(action:{
                        
                        beaconFinder.postAttendanceData(behavior: "In")
                    } , label: {
                        Text("Force push In")
                    })
                    Spacer().frame(height: 10)
                    Button(action:{
                        beaconFinder.postAttendanceData(behavior: "Out")
                    } , label: {
                        Text("Force push Out")
                    })
                    Spacer().frame(height: 10)
                    Button(action:{
                        beaconFinder.postAttendanceData(behavior: "Checked")
                    } , label: {
                        Text("Force push Checked")
                    })
                    Spacer().frame(height: 10)
                    Button(action:{
                        beaconFinder.checkcheck()
                    } , label: {
                        Text("print id")
                    })
                }
                .padding()
                .background(.black)
            }
            
        }
        .background(Color("GoldenYellow"))
    }
    
    func getStringDate(date: Date?) -> String {
        if date == nil {
            return "--:--"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return "\(dateFormatter.string(from: date!))"
        }
    }
}

struct HistoryCardLineView: View {
    var date: String
    var status: Int
    
    func getStatusText(status: Int) -> String {
        if status == 2 {
            return "Exited"
        } else if status == 3 {
            return "Present"
        } else {
            return "Absent"
        }
    }
    
    func getStatusColor(status: Int) -> Color {
        if status == 2 {
            return Color("GoldenYellow")
        } else if status == 3 {
            return Color.green
        } else {
            return Color.red
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("\(date)")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                HStack {
                    Text("Status")
                    Spacer()
                    Text(getStatusText(status: status))
                        .bold()
                        .foregroundStyle(getStatusColor(status: status))
                }
            }
            .padding(.horizontal)
            Divider()
        }
    }
}

#Preview {
    AttendanceView()
}
