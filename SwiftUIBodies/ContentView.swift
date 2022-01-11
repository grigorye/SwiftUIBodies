import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    
    let store = Store<ComponentView.State, ComponentAction>(initialState: .init(tag: 0, stringTag: "0"), reducer: componentReducer, environment: ())
    
    var body: some View {
        List {
            Section {
                Button("Test") {
                    ViewStore(store).send(.test)
                }
            }
            ComponentView(store: store)
                .fixedSize()
        }
    }
}

let componentReducer = Reducer<ComponentView.State, ComponentAction, ()> { state, action, _ in
    switch action {
    case .test:
        state.tag += 1
        state.stringTag = "\(state.tag)"
    }
    return .none
}

enum ComponentAction {
    case test
}

var observedViewStore: ViewStore<ComponentView.State, ComponentAction>?

struct ComponentView: View {
    
    struct State: Equatable {
        var tag: Int
        var stringTag: String
    }
    
    let store: Store<State, ComponentAction>
    
    var body: some View {
        let _ = Self._printChanges()
        WithViewStore(store) { viewStore in
            let _ = dump(viewStore.tag, name: "viewStore.tag")
            let _ = Self._printChanges()
            let _ = assert((observedViewStore == nil) || (observedViewStore === viewStore))
            let _ = dump(String(format: "%p", unsafeBitCast(viewStore, to: Int.self)), name: "viewStore", maxDepth: 1)
            let _ = observedViewStore = viewStore
            
            Section(header: Text("Reference")) {
                HStack {
                    Text("Text(viewStore.tag)")
                    Text("\(viewStore.tag)")
                }
            }
            Section(header: Text("Problems")) {
                HStack {
                    Text("PlaintText({ viewStore.tag }):")
                    PlainText(text: { "\(viewStore.tag)" })
                }
                HStack {
                    Text("PlaintText({ viewStore.stringTag }):")
                    PlainText(text: { viewStore.stringTag })
                }
                HStack {
                    Text("PlaintText({ viewStore.state.stringTag }):")
                    PlainText(text: { viewStore.state.stringTag })
                }
                HStack {
                    Text("FancyTextAlignment({ Text(viewStore.stringTag) }):")
                    FancyTextAlignment(
                        content: {
                            Text(viewStore.stringTag)
                        }
                    )
                }
            }
            Section(header: Text("Workarounds")) {
                let tag = viewStore.tag
                
                HStack {
                    Text("PlaintText({ tag }):")
                    PlainText(text: { "\(tag)" })
                }
                HStack {
                    Text("PlaintText(tag, { viewStore.tag }):")
                    PlainText(tag: tag, text: { "\(viewStore.tag)" })
                }
                HStack {
                    Text("PlaintText(tag, { viewStore.stringTag }):")
                    PlainText(tag: tag, text: { viewStore.stringTag })
                }
                HStack {
                    Text("PlaintText(tag, { tag }):")
                    PlainText(tag: tag, text: { "\(tag)" })
                }
                HStack {
                    Text("FancyAlignment<Text>({ Text(viewStore.stringTag) }):")
                    FancyAlignment<Text>(
                        content: {
                            Text(viewStore.state.stringTag)
                        }
                    )
                }
            }
        }.debug().fixedSize()
    }
}

struct PlainText: View {
    let tag: Int
    let text: () -> String
    
    init(tag: Int = 0, text: @escaping () -> String) {
        print(#function)
        self.tag = tag
        self.text = text
    }
    
    var body: some View {
        let _ = Self._printChanges()
        Text(text())
    }
}

struct FancyAlignment<Content: View>: View {
    @ViewBuilder
    let content: () -> Content
    
    var body: some View {
        let _ = Self._printChanges()
        content()
    }
}

struct FancyTextAlignment: View {
    @ViewBuilder
    let content: () -> Text
    
    var body: some View {
        let _ = Self._printChanges()
        content()
    }
}
