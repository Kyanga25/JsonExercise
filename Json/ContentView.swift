//
//  ContentView.swift
//  Json
//
//  Created by Nathanael Mukyanga on 2024-04-17.
//

import SwiftUI


// Define a struct named Decoding that conforms to Hashable and Codable
struct Decoding: Hashable, Codable {
    let name: String
    let image: String
}

// Define a class named ViewModelJson that conforms to the ObservableObject protocol
class ViewModelJson: ObservableObject {
    // Define a published variable named model as an array of Decoding objects
    @Published var model: [Decoding] = []
    
    // Define a function named fetch that fetches data from a URL using async/await
    func fetch() async {
        // Define the URL endpoint to fetch data from
        guard let url = URL(string: "https://iosacademy.io/api/v1/courses/index.php") else { return }
        // if key needed must be  provided it
        //  Create a URLRequest object to set HTTP headers.
                 var request = URLRequest(url: url)
                 request.setValue("apiKey", forHTTPHeaderField: "Authorization")
                 request.httpMethod = "GET"
             
                 
        
        
        
        do {
            // Create a URLSession data task using async/await
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Ensure the HTTP response status code is 200
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Network request failed with response: \(response)")
                return
            }
            
            // Decode the JSON data into an array of Decoding objects
            let decodedModel = try JSONDecoder().decode([Decoding].self, from: data)
            
            // Update the model array on the main thread
            DispatchQueue.main.async {
                self.model = decodedModel
            }
        } catch {
            // Handle any errors
            print("Failed to fetch or decode data: \(error)")
        }
    }
}





struct ContentView: View {
    @StateObject var viewModel = ViewModelJson()
    var body: some View {
        NavigationView{
            List {
                ForEach(viewModel.model ,id:\.self) { course in
                    HStack {
                        AsyncImage(url: URL(string:course.image)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 50, height: 50)
                        
                        Text(course.name)
                            .bold()
                    }.padding(3)
                    
                }
                
            }
            .navigationTitle("Courses")
            .task{
               await viewModel.fetch()
                
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//


// Define a struct named Encoding that conforms to Hashable and Codable
struct Encoding: Hashable, Codable {
    let name: String
    let age: Int
}

// Define a class named ViewModelJson2 that conforms to the ObservableObject protocol
class ViewModelJson2: ObservableObject {
    // Define a published variable named model as an instance of Encoding
    @Published var model = Encoding(name: "", age: 0)

    // Define a function named fetch that fetches data from a URL using a POST request
    func fetch() async {
        // Ensure URL is valid
        guard let url = URL(string: "https://example.com/api/users") else {
            print("Invalid URL")
            return
        }
        
        // Create a URLRequest with the URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Encode the model to JSON data for the HTTP body
            request.httpBody = try JSONEncoder().encode(model)
            
            // Perform the POST request using URLSession
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check the HTTP response status code
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Response status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return
            }

            // Optionally convert the response data to a String for logging/debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            
        } catch {
            // Handle any errors, including encoding errors or network errors
            print("Error during URLSession data task: \(error.localizedDescription)")
        }
    }
}


