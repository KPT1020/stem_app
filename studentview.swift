//
//  studentview.swift
//  iosBleSdkTestApp
//
//  Created by K i on 31/7/2023.
//

import SwiftUI
import FirebaseAuth

struct studentview: View {
    @AppStorage("Studentnames") var students = [String]()
    @State var newStudent = ""
    @ObservedObject var devicemanager = DeviceManagers()
    @State var currindex:Int = -1
    
    var body: some View {
        
        NavigationView {
            VStack{
                List{
                    ForEach(students.indices, id: \.self) {
                        index in
                        if !students.isEmpty{
                            HStack{
                                Spacer()
                                NavigationLink {
                                    
                                    if !devicemanager.devices.isEmpty && index <= self.currindex && self.devicemanager.devices[students[index]] != nil{
                                        ContentView()
                                            .environmentObject(self.devicemanager.devices[students[index]]!)
                                    }
                                } label: {
                                    Text(students[index])
                                        .onAppear(){
                                            self.currindex=self.students.count-1
                                            
                                            self.devicemanager.addDevice(studentname: self.students[index])
                                           
                                        }
                                   
                                }
                            }
                        }
                    }
                    .onDelete { IndexSet in
                        
                        if let index = IndexSet.first {
                            let studentName = students[index]
                            students.remove(atOffsets: IndexSet)
                            self.devicemanager.devices.removeValue(forKey: studentName)
                        }
                        
                    }
                    .onMove { indices, newOffset in
                        students.move(fromOffsets: indices, toOffset: newOffset)
                    }
                 
                }
                
                
                HStack {
                    Spacer()
                    TextField("ADD NEW STUDENT", text: $newStudent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                        }
                    Button("Add") {
                        if !newStudent.isEmpty{
                            students.append(newStudent)
                            
                        }
                        
                        newStudent = ""
                    }
                    Spacer()
                }
                .padding(.horizontal)

                }


                
            }
            
            
        }
        
      
        
        
    }
 



extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
