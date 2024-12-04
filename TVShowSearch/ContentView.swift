//
//  ContentView.swift
//  TVShowSearch
//
//  Created by Michael Peters on 3/14/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkModeOn") var isDarkModeOn = false
    // Test 
    
    @State private var isShowingInformationSheet = false
    @State private var isShowingLongPressAlert = false
    
    @State private var showToSearch = ""
    
    @State private var name = ""
    @State private var status = ""
    @State private var type = ""
    @State private var language = ""
    @State private var premiered = ""
    @State private var ended = ""
    @State private var runtime = 0
    @State private var url = ""
    @State private var summary = ""
    
    @Environment(\.openURL) var openURL

    var body: some View {
        ZStack {
            HStack {
                Button {
                    isDarkModeOn.toggle()
                } label: {
                    let image = isDarkModeOn ? "lightbulb" : "lightbulb.fill"
                    Image(systemName: image)
                }
                .padding(.leading, 10)
                Spacer()
            }
            HStack {
                Text("TV Show Search")
                    .font(.title)
                    .bold()
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    // bypass for gestures
                }, label: {
                    Image(systemName: "info.circle")
                })
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                    isShowingLongPressAlert = true
                    PetersHaptics.process.impact(.heavy)
                })
                .simultaneousGesture(TapGesture()
                    .onEnded {
                    isShowingInformationSheet = true
                })
                .alert(isPresented: $isShowingLongPressAlert) {
                    Alert(title: Text("Device Information"),
                          message: Text("Click here to see a detailed listing of the current device's information."))
                }
                .padding(.trailing, 10)
                .sheet(isPresented: $isShowingInformationSheet) {
                    VStack {
                        ZStack {
                            HStack {
                                Button {
                                    isShowingInformationSheet = false
                                } label: {
                                    Text("Close")
                                }
                                .padding([.leading, .top])
                                Spacer()
                            }
                            HStack {
                                Text("Device Information")
                                .padding(.top)
                            }
                        }
                        Spacer()
                        Form {
                            Section ("Device") {
                                LabeledContent("Name", value: UIDevice.current.name)
                                LabeledContent("Model", value: UIDevice.current.model)
                                LabeledContent("Localized Model", value: UIDevice.current.localizedModel)
                                LabeledContent("System Name", value: UIDevice.current.systemName)
                                LabeledContent("Systen Version", value: UIDevice.current.systemVersion)
                                LabeledContent("Identifier", value: UIDevice.current.identifierForVendor?.uuidString ?? "N/A")
                                LabeledContent("Type", value: UIDevice.current.userInterfaceIdiom == .phone ? "iPhone" : "iPad")
                            }
                            Section ("Screen") {
                                LabeledContent("Width", value: "\(UIScreen.main.bounds.width) pixels")
                                LabeledContent("Height", value: "\(UIScreen.main.bounds.height) pixels")
                                LabeledContent("Scale", value: "\(UIScreen.main.scale) (\(Int(UIScreen.main.scale))x)")
                            }
                        }
                    }
                    .presentationDragIndicator(.visible)
                }
            }
        }
        HStack (spacing: 10) {
            Text("Show:")
            TextField("Enter a show to search for", text: $showToSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    Task {
                        let showText = showToSearch.replacingOccurrences(of: " ", with: "%20")
                        
                        let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.tvmaze.com/singlesearch/shows?q=\(showText)")!)
                        let decodedResponse = try? JSONDecoder().decode(show.self, from: data)
                        name = decodedResponse?.name ?? ""
                        status = decodedResponse?.status ?? ""
                        type = decodedResponse?.type ?? ""
                        language = decodedResponse?.language ?? ""
                        premiered = decodedResponse?.premiered ?? ""
                        ended = decodedResponse?.ended ?? ""
                        runtime = decodedResponse?.runtime ?? 0
                        url = decodedResponse?.url ?? ""
                        summary = decodedResponse?.summary.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? ""
                        
                        showToSearch = ""
                        hideKeyboard()
                    }
                }
            Button {
                Task {
                    let showText = showToSearch.replacingOccurrences(of: " ", with: "%20")
                    
                    let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.tvmaze.com/singlesearch/shows?q=\(showText)")!)
                    let decodedResponse = try? JSONDecoder().decode(show.self, from: data)
                    name = decodedResponse?.name ?? ""
                    status = decodedResponse?.status ?? ""
                    type = decodedResponse?.type ?? ""
                    language = decodedResponse?.language ?? ""
                    premiered = decodedResponse?.premiered ?? ""
                    ended = decodedResponse?.ended ?? ""
                    runtime = decodedResponse?.runtime ?? 0
                    url = decodedResponse?.url ?? ""
                    summary = decodedResponse?.summary.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? ""
                    
                    showToSearch = ""
                    hideKeyboard()
                }
            } label: {
                Text("Search")
            }
        }
        .padding([.leading, .trailing], 10)
        VStack (alignment: .leading, spacing: 10) {
            VStack (spacing: 5) {
                Divider()
                Text(name)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                Divider()
            }
            HStack {
                Text("Status:")
                Spacer()
                Text(status)
                    .foregroundStyle(Color.gray)
            }
            HStack {
                Text("Type:")
                Spacer()
                Text(type)
                    .foregroundStyle(Color.gray)
            }
            HStack {
                Text("Language:")
                Spacer()
                Text(language)
                    .foregroundStyle(Color.gray)
            }
            HStack {
                let premieredYear = premiered.prefix(4)
                let premieredMonth = premiered.dropFirst(5).prefix(2)
                let premieredDay = premiered.suffix(2)
                
                let endedYear = ended.prefix(4)
                let endedMonth = ended.dropFirst(5).prefix(2)
                let endedDay = ended.suffix(2)
                
                Text("Premiered:")
                Spacer()
                Text("\(premieredMonth)/\(premieredDay)/\(premieredYear)")
                    .foregroundStyle(Color.gray)
                Spacer()
                Text("Ended:")
                Spacer()
                Text(ended.isEmpty ? "TBD" : "\(endedMonth)/\(endedDay)/\(endedYear)")
                    .foregroundStyle(Color.gray)
            }
            HStack {
                Text("Runtime:")
                Spacer()
                Text("\(String(runtime)) minutes")
                    .foregroundStyle(Color.gray)
            }
            HStack {
                VStack (alignment: .leading) {
                    Text("URL:")
                    Button(url) {
                        openURL(URL(string: url)!)
                    }
                }
            }
            Divider()
            Text("Summary:")
            ScrollView {
                Text(summary)
                    .foregroundStyle(Color.gray)
            }
        }
        .opacity(name.isEmpty ? 0 : 1)
        .overlay {
            if name.isEmpty
            {
                ContentUnavailableView(
                    label:
                        {
                            Label("No show found!", systemImage: "tv.slash")
                        }
                    , description:
                        {
                            Text("Adjust your search criteria and try again.")
                        })
            }
        }
        .preferredColorScheme(isDarkModeOn ? .dark : .light)
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

struct show: Codable {
    let name: String
    let status: String
    let type: String
    let language: String
    let premiered: String
    let ended: String?
    let runtime: Int?
    let url: String
    let summary: String
}

class PetersHaptics {
    static let process = PetersHaptics()
    
    private init() { }
    
    func impact(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notification(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}

#Preview {
    ContentView()
}
