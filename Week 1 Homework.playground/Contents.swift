import SwiftUI
import PlaygroundSupport
import Foundation

class Game: ObservableObject{
    
    @Published var numberOfDoor: Int
    @Published var indexWithPrize: Int
    @Published var indexForDecision: Int?
    @Published var gameState: GameState
    @Published var selectedIndex: Int?
    @Published var playerState: PlayerState
    
    init(numberOfDoor: Int){
        self.numberOfDoor = numberOfDoor
        self.gameState = .begining
        self.indexWithPrize = Int.random(in: 0..<numberOfDoor)
        self.playerState = .notDetermined
    }
    
    func selectIndexForDecision(){
        if self.selectedIndex == self.indexWithPrize{
            var indexForDecision: Int = Int.random(in: 0..<self.numberOfDoor)
            while indexForDecision == self.indexWithPrize{
                indexForDecision = Int.random(in: 0..<self.numberOfDoor)
            }
            self.indexForDecision = indexForDecision
            return
        }
        self.indexForDecision = self.indexWithPrize
        return
    }
    
    func resetGame(numberOfDoors: Int){
        self.numberOfDoor = numberOfDoors
        self.indexWithPrize = Int.random(in: 0..<numberOfDoors)
        self.indexForDecision = nil
        self.selectedIndex = nil
        self.gameState = .begining
        self.playerState = .notDetermined
    }
    
}

enum GameState{
    case begining, decisioning, ending
}

enum DoorState{
    case opened, closed
}

enum PlayerState: String{
    case notDetermined
    case win = "You win the prize!"
    case lose = "You are now a proud owner of a duck!"
}

struct DoorObject: View{
    
    
    @State var currentState: DoorState = .closed
    @Binding var selection: Int?
    @Binding var indexForDecision: Int?
    @Binding var gameState: GameState
    var doorIndex: Int
    var isContainPrize: Bool
    
    var body: some View{
        
        ZStack{
        
            Image(uiImage: UIImage(named: currentState == .closed ? "Closed Door.png" : "Opened Door.png")!)
                .onChange(of: self.gameState){_ in
                    
                    
                    switch (self.gameState){
                    case .begining:
                        self.currentState = .closed
                    case .decisioning:
                        if self.indexForDecision! != self.doorIndex && !self.isContainPrize && self.selection != self.doorIndex{
                            self.currentState = .opened
                        }
                    case .ending:
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
                
                ForEach(0..<game.numberOfDoor, id: \.self){ index in
                    VStack{
                        Text("Door \(index + 1)")
                        DoorObject(selection: $game.selectedIndex, indexForDecision: $game.indexForDecision, gameState: $game.gameState, doorIndex: index, isContainPrize: game.indexWithPrize == index)
                    }
                }
            }
            Spacer()
            
            switch (game.gameState){
            case .decisioning:
                if game.indexForDecision != nil{
                    VStack(spacing: 20){
                        Text("Would you like to go on with Door \(game.selectedIndex! + 1) or switch to Door \(game.indexForDecision! + 1)?")
                        
                        HStack(spacing: 50){
                            Button("Go On"){
                                self.game.playerState = game.selectedIndex == game.indexWithPrize ? .win : .lose
                                game.gameState = .ending
                            }
                            
                            Button("Switch"){
                                self.game.playerState = game.indexForDecision == game.indexWithPrize ? .win : .lose
                                game.gameState = .ending
                            }
                        }
                    }
                }
            case .ending:
                VStack(spacing: 20){
                    Text(self.game.playerState.rawValue)
                    Button("Play Again"){
                        self.game.resetGame(numberOfDoors: 4)
                    }
                }
            case .begining:
                Text("Select a door!")
                Text("")
            }
            Spacer()
        }
        .onChange(of: game.gameState){ _ in
            if game.gameState == .decisioning{
                game.selectIndexForDecision()
            }
        }
    }
}





PlaygroundPage.current.setLiveView(
    MainView()
        .frame(width: 500, height: 400)
)


