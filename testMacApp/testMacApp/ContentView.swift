//
//  ContentView.swift
//  testMacApp
//
//  Created by Пользователь on 17.12.2019.
//  Copyright © 2019 mintrocket. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    public let script: Code = Code()

    var body: some View {
        
        VStack {
            Text("Hello, World!")
                .frame(maxWidth: 200, maxHeight: .infinity)
            Button(action: {
                self.script.startGenerate()
            }) {
                Text(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/)
            }
            .frame(width: 50, height: 40, alignment: .bottom)
            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
