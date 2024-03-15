//
//  ContentView.swift
//  TVShowSearch
//
//  Created by Michael Peters on 3/14/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkModeOn") var isDarkModeOn = false
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
                .padding([.leading, .trailing], 15)
                Spacer()
            }
            HStack {
                Text("TV Show Search")
                    .font(.title)
                    .bold()
            }
            Spacer()
        }
        HStack (spacing: 10) {
            Text("Show:")
            TextField("Enter a show to search for", text: $showToSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    .foregroundStyle(Color.gray)
                Spacer()
                Text(status)
            }
            HStack {
                Text("Type:")
                    .foregroundStyle(Color.gray)
                Spacer()
                Text(type)
            }
            HStack {
                Text("Language:")
                    .foregroundStyle(Color.gray)
                Spacer()
                Text(language)
            }
            HStack {
                let premieredYear = premiered.prefix(4)
                let premieredMonth = premiered.dropFirst(5).prefix(2)
                let premieredDay = premiered.suffix(2)
                
                let endedYear = ended.prefix(4)
                let endedMonth = ended.dropFirst(5).prefix(2)
                let endedDay = ended.suffix(2)
                
                Text("Premiered:")
                    .foregroundStyle(Color.gray)
                Spacer()
                Text("\(premieredMonth)/\(premieredDay)/\(premieredYear)")
                Spacer()
                Text("Ended:")
                    .foregroundStyle(Color.gray)
                Spacer()
                Text("\(endedMonth)/\(endedDay)/\(endedYear)")
            }
            HStack {
                Text("Runtime:")
                    .foregroundStyle(Color.gray)
                Spacer()
                Text("\(String(runtime)) minutes")
            }
            HStack {
                VStack (alignment: .leading) {
                    Text("URL:")
                        .foregroundStyle(Color.gray)
                    Button(url) {
                        openURL(URL(string: url)!)
                    }
                }
            }
            Divider()
            Text("Summary:")
                .foregroundStyle(Color.gray)
            ScrollView {
                Text(summary)
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
    let ended: String
    let runtime: Int
    let url: String
    let summary: String
}

#Preview {
    ContentView()
}
