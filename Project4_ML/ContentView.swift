//
//  ContentView.swift
//  Project4_ML
//
//  Created by admin on 10.08.2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUpTime = standartTime
    @State private var amountOfSleep = 8.0
    @State private var coffeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var standartTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(cgColor: .init(red: 0.85, green: 0.35, blue: 0.4, alpha: 0.7))
                    .ignoresSafeArea()
                
                VStack {
                    Text("SleepTime.")
                        .padding(10)
                        .frame(width: 350)
                        .background(.thickMaterial)
                        .foregroundColor(.secondary)
                        .font(.title)
                        .cornerRadius(20)
                        .padding(.bottom)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Coffee you drink a day")
                                .padding(10)
                                .font(.title2)
                            Spacer()
                            Stepper(coffeAmount == 1 ? "\(coffeAmount) cup" : "\(coffeAmount) cups", value: $coffeAmount, in: 0...20, step: 1)
                                .font(.system(size: 15))
                        }
                        
                        Divider()
                        
                        VStack(alignment: .trailing, spacing: 10) {
                            Text("How much do I want to sleep?")
                                .font(.title2)
                            Spacer()
                            Stepper("\(amountOfSleep.formatted()) h", value: $amountOfSleep, in: 4...12, step: 0.25)
                                .font(.system(size: 15))
                                
                        }
                        
                    }
                    .frame(width: 320, height: 200)
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(20)
                    
                    Divider()
                    DatePicker("Pick wake up time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                        .font(.system(size: 20))
                        .datePickerStyle(.graphical)
                        .padding()
                        .background(.thickMaterial)
                        .cornerRadius(20)
                    Spacer()
                    
                    Button("when should I go to bed?") {
                        culculateSleepTime()
                    }
                    .padding(20)
                    .frame(width: 350)
                    .background(.thickMaterial)
                    .foregroundColor(.secondary)
                    .font(.title)
                    .cornerRadius(20)
                    .padding(.bottom)
                    
                    .alert(alertTitle, isPresented: $showingAlert) {
                        Button("Continue") {}
                    }message: {
                        Text(alertMessage)
                    }
                }
                .padding(20)
                .background(.thinMaterial)
                .foregroundColor(.secondary)
                .cornerRadius(30)
                .padding([.trailing,.leading])
                
                .ignoresSafeArea(.container, edges: [.bottom])
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.light)
        }
    }
    func culculateSleepTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hours = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0)  * 60
            
            let pregiction = try model.prediction(wake: Double(hours + minutes),  estimatedSleep: amountOfSleep, coffee: Double(coffeAmount))
            let sleepTime = wakeUpTime - pregiction.actualSleep
            
            alertTitle = "Your ideal bad time is "
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Something went wrong"
            alertMessage = "Sorry we could not calculate your sleep time correctly"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
