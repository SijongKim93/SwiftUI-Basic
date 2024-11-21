//
//  CounterFeature.swift
//  ToDoList_TCA
//
//  Created by SiJongKim on 11/21/24.
//

import Foundation
import ComposableArchitecture

struct CounterFeature: Reducer {
    struct State: Equatable {
        var count: Int = 0
        var isTimerOn: Bool = false
    }
    
    enum Action: Equatable {
        case plusButtonTapped
        case minButtonTapped
        case timerButtonTapped
        case tick
    }
    
    private enum CancelID {
        case timer
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .plusButtonTapped:
                state.count += 1
                
                return .none
                
            case .minButtonTapped:
                state.count -= 1
                
                return .none
                
            case .timerButtonTapped:
                state.isTimerOn.toggle()
                
                if state.isTimerOn {
                    return .run { send in
                        for await _ in Timer.publish(every: 1, on: .main, in: .common).autoconnect().values {
                            await send(.tick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
                
            case .tick:
                state.count += 1
                
                return .none
            }
        }
    }
}

