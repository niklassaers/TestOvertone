import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button(action: { MyEngineDemo.shared.playDemo() }) {
                    Text("Play!")
                }
                
                Button(action: { MyEngineDemo.shared.stopDemo() }) {
                    Text("Stop!")
                }
                
                Spacer()
            }
            
            Spacer()
                .frame(height: 8)
            
            Button(action: { MyEngineDemo.shared.toggleEndlessly() }) {
                Text("Toggle endlessly")
            }

            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
