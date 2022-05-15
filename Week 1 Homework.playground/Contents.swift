import SwiftUI
import PlaygroundSupport
import Foundation

class Game: ObservableObject{
    
    
    var numberOfDoor: Int
    @Published var indexWithPrize: Int
    @Published var indexForDecision: Int?
    @Published var gameState: GameState
    @Published var selectedIndex: Int?
    
    init(numberOfDoor: Int){
        self.numberOfDoor = numberOfDoor
        self.gameState = .begining
        self.indexWithPrize = Int.random(in: 0..<numberOfDoor)
        print("Prize is in Door \(self.indexWithPrize + 1)")
    }
    
    func selectIndexForDecision(){
        if self.selectedIndex == self.indexWithPrize{
            var indexForDecision: Int = Int.random(in: 0..<self.numberOfDoor)
            if indexForDecision == self.indexWithPrize{
                if indexForDecision == 0{
                    self.indexForDecision = indexForDecision + 1
                    return
                } else if indexForDecision == self.numberOfDoor - 1{
                    self.indexForDecision = indexForDecision - 1
                    return
                } else {
                    self.indexForDecision = indexForDecision
                    return
                }
            }
        }
        self.indexForDecision = self.selectedIndex
        return
    }
    
}

enum GameState{
    case begining, decisioning, ending
}

enum DoorState{
    case opened, closed
}

struct DoorObject: View{
    
    
    @State var currentState: DoorState = .closed
    @Binding var selection: Int?
    @Binding var gameState: GameState
    var doorIndex: Int
    var isContainPrize: Bool
    
    var body: some View{
        
        ZStack{
        
            Image(uiImage: UIImage(named: currentState == .closed ? "Closed Door.png" : "Opened Door.png")!)
                .onChange(of: self.selection){_ in
                    if self.selection != self.doorIndex && !self.isContainPrize{
                        self.currentState = .opened
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
        .onTapGesture {
            if self.selection == nil{
                self.selection = doorIndex
                self.gameState = .decisioning
            }
        }
    }
    
}

struct MainView: View{
    
    @ObservedObject var game: Game = Game(numberOfDoor: 4)
    
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
                        DoorObject(selection: $game.selectedIndex, gameState: $game.gameState, doorIndex: index, isContainPrize: game.indexWithPrize == index)
                    }
                }
            }
            Spacer()
        }
    }
}





PlaygroundPage.current.setLiveView(
    MainView()
        .frame(width: 500, height: 400)
)


