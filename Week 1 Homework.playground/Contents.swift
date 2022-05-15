import SwiftUI
import PlaygroundSupport
import Foundation

class Game: ObservableObject{
    
    
    var numberOfDoor: Int
    @Published var indexWithPrize: Int
    @Published var gameState: GameState
    
    init(numberOfDoor: Int){
        self.numberOfDoor = numberOfDoor
        self.gameState = .begining
        self.indexWithPrize = Int.random(in: 0..<numberOfDoor)
    }
    
    
    
}

enum GameState{
    case begining, switching, ending
}

enum DoorState{
    case opened, closed
}

struct DoorObject: View{
    
    
    @State var currentState: DoorState = .closed
    var doorIndex: Int
    var isContainPrize: Bool
    
    var body: some View{
        
        ZStack{
            
            
            
            Image(uiImage: UIImage(named: currentState == .closed ? "Closed Door.png" : "Opened Door.png")!)
                .onTapGesture {
                    if self.currentState == .closed{
                        self.currentState = .opened
                    } else {
                        self.currentState = .closed
                    }
                }
            
            if self.currentState == .opened{
                if self.isContainPrize{
                    Text("🏆")
                        .font(.largeTitle)
                } else {
                    Text("🦆")
                        .font(.largeTitle)
                }
            }
        }
    }
    
}

struct MainView: View{
    
    @ObservedObject var game: Game = Game(numberOfDoor: 3)
    
    var body: some View{
        VStack{
            Spacer()
            Text("Monty's Hall")
                .font(.title)
                .fontWeight(.medium)
            Spacer()
            HStack{
                
                ForEach(0..<game.numberOfDoor){ index in
                    VStack{
                        Text("Door \(index + 1)")
                        DoorObject(doorIndex: index, isContainPrize: game.indexWithPrize == index)
                    }
                }
            }
            Spacer()
        }
    }
}





PlaygroundPage.current.setLiveView(
    MainView()
        .frame(width: 400, height: 400)
)


