import SwiftUI
import PlaygroundSupport
import Foundation

enum DoorState{
    case opened, closed
}

struct DoorObject: View{
    
    @State var currentState: DoorState = .closed
    
    var body: some View{
        Image(uiImage: UIImage(named: currentState == .closed ? "Closed Door.png" : "Opened Door.png")!)
    }
    
}

struct MainView: View{
    var body: some View{
        
        DoorObject()
        
    }
}





PlaygroundPage.current.setLiveView(
    MainView()
        .frame(width: 400, height: 400)
)


