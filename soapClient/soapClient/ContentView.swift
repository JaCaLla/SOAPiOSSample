//
//  ContentView.swift
//  soapClient
//
//  Created by Javier Calatrava on 21/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var result: String = ""
    @State private var aStr: String = ""
    @State private var bStr: String = ""

    var body: some View {
        VStack {
            Group {
                TextField("a", text: $aStr)
                TextField("b", text: $bStr)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            Button("Do remote addition") {
                guard let aInt = Int(aStr), let bInt = Int(bStr) else {
                    return
                }
                callSoapService(a: aInt, b: bInt) { response in
                    DispatchQueue.main.async {
                        self.result = response
                    }
                }
            }            .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
            
            Text("a+b= \(result)")
                .font(.title)
                .padding()
        }
    }

    func callSoapService(a: Int, b: Int, completion: @escaping (String) -> Void) {
        let soapMessage = """
        <?xml version="1.0" encoding="UTF-8"?>
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://example.com/soap">
          <soapenv:Body>
            <tns:AddNumbers>
              <a>\(a)</a>
              <b>\(b)</b>
            </tns:AddNumbers>
          </soapenv:Body>
        </soapenv:Envelope>
        """

        let url = URL(string: "http://localhost:8000/wsdl")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = soapMessage.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                if let result = extractResult(from: responseString) {
                    completion(result)
                } else {
                    completion("Error parsing response")
                }
            } else {
                completion("Invalid response")
            }
        }
        task.resume()
    }

    func extractResult(from response: String) -> String? {
        let pattern = "<tns:result>(\\d+)</tns:result>"
        if let range = response.range(of: pattern, options: .regularExpression) {
            return String(response[range].dropFirst(8+4).dropLast(9+4))
        }
        return nil
    }
}

#Preview {
    ContentView()
}
