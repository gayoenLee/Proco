//
//  ShowGatheringLocation.swift
//  proco
//
//  Created by 이은호 on 2020/11/29.
//

import SwiftUI
import MapKit

struct ShowGatheringLocation: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    
    var body: some View {
        ZStack{
            
        Map(coordinateRegion: $region)
        }
    }
}

struct ShowGatheringLocation_Previews: PreviewProvider {
    static var previews: some View {
        ShowGatheringLocation()
    }
}
