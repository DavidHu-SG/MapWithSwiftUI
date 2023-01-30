//
//  ContentView.swift
//  MapWithSwiftUI
//
//  Created by David Hu on 29/1/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct KopiTiam: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct ContentView: View {
    // KopiTiam means cafe or coffe/tea shop in Singapore, also see:
    // https://en.wikipedia.org/wiki/Kopi_tiam
    private var searchQuery: String = "KopiTiam"
    
    // Store the search result
    @State private var searchResults: [KopiTiam] = []
    // Use a fake center location for this demo app, Lau Pa Sat in center of Singapore, wish you can visit and enjoy this place someday.
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.280716, longitude: 103.850442), span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: searchResults) { foodCourt in
            // Add Annotation
            MapAnnotation(coordinate: foodCourt.coordinate) {
                // In this demo, I just put a button here, you can choose whichever you like
                Button(action: {
                    // action
                }) {
                    // UI Components for Annotation
                    Image(systemName: "cup.and.saucer.fill")
                        .resizable()
                        .frame(width: 30, height: 22, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                        .accentColor(.white)
                }
                .frame(width: 44, height: 44)
                .background(.green)
                .cornerRadius(22)
            }
        }
        .ignoresSafeArea() // Usually we need to ignore safe area for map
        .onAppear() {   // Load data when onAppear()
            loadAnnotationsByCurrentLocation()
        }
    }
    
    // MARK: non-UI functions
    // All code & functions below can be move into another file as you want.
    
    // Wrapped load function
    func loadAnnotationsByCurrentLocation() {
        startSearchLocations(searchQuery, region) { results in
            searchResults = mapItemsToKT(mapItems: results)
        }
    }
    
    // Core search codes, using MKLocalSearch
    func startSearchLocations(_ searchKeyword: String, _ region: MKCoordinateRegion, completion: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchKeyword
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("test log Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            completion(response.mapItems)
        }
    }
    
    // Convertion code
    func convertMapItemToKopiTiam(mapItem: MKMapItem) -> KopiTiam {
        // covert code here, add more to info
        return KopiTiam(name: mapItem.name ?? "Unknown Location", coordinate: mapItem.placemark.coordinate)
    }
    
    // Convert map items to a custom struct
    func mapItemsToKT(mapItems: [MKMapItem]) -> [KopiTiam] {
        var result: [KopiTiam] = []
        _ = mapItems.compactMap { item in
            result.append(convertMapItemToKopiTiam(mapItem: item))
        }
        return result
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
