import SwiftUI
import PlaygroundSupport
import Foundation

/// This class contains the game logic.
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
    
    /// When user selects a door; if selected door contains the prize a random door will be selected and will be set for decision; if selected door not contains the prize, door that contains the prize will be set for decision.
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
    
    /// All variable in this class will be reseted with this function.
    /// - Parameter numberOfDoors: Number of door can be modified for the next game.
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
                    .padding(5)
                    .background(
                        
                        LinearGradient(gradient: Gradient(colors: [doorHighlightColor(index: index), .white]), startPoint: .top, endPoint: .bottom)
                            .opacity(self.doorHighlight(index: index))
                        
                    )
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
    /// Changes the highlight color of the given index depending on if the door contains prize or selected and game state.
    /// - Parameter index: Index of the door in the array.
    /// - Returns: Highlight color.
    func doorHighlightColor(index: Int) -> Color{
        switch (self.game.gameState){
        case .begining:
            return .white
        case .decisioning:
            return .orange
        case .ending:
            if self.game.indexWithPrize == index{
                return .green
            } else if self.game.selectedIndex == index{
                return .red
            }
        }
        return .white
    }
    /// Determines if door should be highlighted depending on game state, if the door contains prize or if the door seleceted.
    /// - Parameter index: Index of the door in the array.
    /// - Returns: Opacity value between 0-1.
    func doorHighlight(index: Int) -> Double{
        switch (self.game.gameState){
        case .begining:
            break
        case .decisioning:
            if self.game.selectedIndex == index{
                return 1
            }
        case .ending:
            if self.game.indexWithPrize == index || self.game.selectedIndex == index{
                return 1
            }
        }
        return 0
    }
}

PlaygroundPage.current.setLiveView(
    MainView()
        .frame(width: 500, height: 400, alignment: .center)
)


