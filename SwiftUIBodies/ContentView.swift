import SwiftUI
import ComposableArchitecture

struct ComponentState: Equatable {
    var message: String = "X"
    var changesCount: Int = 0
}

let componentReducer = Reducer<ComponentState, ComponentAction, ()> { state, action, _ in
    switch action {
    case .change:
        state.message.append("X")
        state.changesCount += 1
    }
    return .none
}

enum ComponentAction {
    case change
}

struct ContentView: View, Traceable {
    
    let store = Store<ComponentState, ComponentAction>(initialState: .init(), reducer: componentReducer, environment: ())
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Section {
                    Button("Trigger change (Add another 'X' to the text)") {
                        print("\n=== Triggering Change: \(viewStore.changesCount + 1) ===\n")
                        viewStore.send(.change)
                    }
                }
                Section {
                    Text("Changes triggered: \(viewStore.changesCount)")
                }
                ComponentView(store: store)
                    .fixedSize()
            }
        }
    }
}

struct ComponentView: View, Traceable {

    let store: Store<ComponentState, ComponentAction>
    
    static var observedViewStore: ViewStore<ComponentState, ComponentAction>?
    
    var body: some View {
        let _ = dump((), name: "-")
        WithViewStore(store) { viewStore in
            let _ = dump(viewStore.message, name: "viewStore.message")
            let _ = Self._printChanges()
            
            // Double-check that viewStore remains the same:
            let _ = dump(String(format: "%p", unsafeBitCast(viewStore, to: Int.self)), name: "viewStore", maxDepth: 1)
            let _ = assert((Self.observedViewStore == nil) || (Self.observedViewStore === viewStore))
            let _ = Self.observedViewStore = viewStore
            
            Section(header: Text("Reference")) {
                HStack {
                    Text("Text(viewStore.message)")
                    Text(viewStore.message)
                }
            }
            Section(header: Text("Problems")) {
                HStack {
                    Text("PlainText({ viewStore.message }):")
                    PlainText({ viewStore.message })
                }
                HStack {
                    Text("PlainText({ viewStore.state.message }):")
                    PlainText({ viewStore.state.message })
                }
                HStack {
                    Text("FancyTextWrapper { Text(viewStore.message) }:")
                    FancyTextWrapper {
                        Text(viewStore.message)
                    }
                }
            }
            Section(header: Text("Workarounds")) {
                let state = viewStore.state
                
                HStack {
                    Text("PlainText({ state.message }):")
                    PlainText({ state.message })
                }

                let tag = state.message // Whatever value different for different states

                HStack {
                    Text("PlainTextWithTag(tag, { viewStore.state.message }):")
                    PlainTextWithTag(tag, { viewStore.message })
                }
                HStack {
                    Text("PlainTextWithTag(tag, { viewStore.message }):")
                    PlainTextWithTag(tag, { viewStore.message })
                }
                
                HStack {
                    Text("FancyWrapper<Text> { Text(viewStore.message) }:")
                    FancyWrapper<Text> {
                        Text(viewStore.message)
                    }
                }
            }
        }.debug(dumpPrefix()).fixedSize()
    }
}

// MARK: - Views -

struct PlainText: View, Traceable {
    let text: () -> String
    
    init(_ text: @escaping () -> String) {
        self.text = text
        dump(self, name: "self")
    }
    
    var body: some View {
        let _ = Self._printChanges()
        Text(text())
    }
}

struct PlainTextWithTag<Tag>: View, Traceable {
    let tag: Tag
    let text: () -> String
    
    init(_ tag: Tag, _ text: @escaping () -> String) {
        self.tag = tag
        self.text = text
        dump(self, name: "self")
    }
    
    var body: some View {
        let _ = Self._printChanges()
        Text(text())
    }
}

struct FancyWrapper<Content: View>: View, Traceable {
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        dump(self, name: "self")
    }
    
    let content: () -> Content
    
    var body: some View {
        let _ = Self._printChanges()
        content()
    }
}

struct FancyTextWrapper: View, Traceable {
    
    init(@ViewBuilder content: @escaping () -> Text) {
        self.content = content
        dump(self, name: "self")
    }

    let content: () -> Text
    
    var body: some View {
        let _ = Self._printChanges()
        content()
    }
}
