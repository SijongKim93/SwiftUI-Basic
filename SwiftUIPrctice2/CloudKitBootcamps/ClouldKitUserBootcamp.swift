//
//  ClouldKitUserBootcamp.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/26/24.
//

import SwiftUI
import CloudKit

class CloudKitUserBootcampViewModel: ObservableObject {
    
    @Published var permissionStatus: Bool = false
    @Published var isSignedIntoICloud: Bool = false
    @Published var error: String = ""
    @Published var userName: String = ""
    
    init() {
        getCloudStatus()
        requestPermission()
        fetchiCloudUserRecordID()
        
    }
    
    private func getCloudStatus() {
        CKContainer.default().accountStatus { returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    self.isSignedIntoICloud = true
                case .noAccount:
                    self.error = CloudKitError.iCloudAccountNotFound.rawValue
                case .couldNotDetermine:
                    self.error = CloudKitError.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self.error = CloudKitError.iCloudAccountRestricted.rawValue
                default:
                    self.error = CloudKitError.iCloudAccountUnknown.rawValue
                }
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
    }
    
    func requestPermission() {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { returnedStatus, returnedError in
            DispatchQueue.main.async {
                if returnedStatus == .granted {
                    self.permissionStatus = true
                }
            }
        }
    }
    
    
    func fetchiCloudUserRecordID() {
        CKContainer.default().fetchUserRecordID { [weak self] returnedID, returnedError in
            if let id = returnedID {
                self?.discoveriCloudUser(id: id)
            } else if let error = returnedError {
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func discoveriCloudUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { [weak self] returnedIdentity, returnedError in
            DispatchQueue.main.async {
                if let name = returnedIdentity?.nameComponents?.givenName {
                    self?.userName = name
                } else if let error = returnedError {
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}

struct CloudKitUserBootcamp: View {
    
    @StateObject private var vm = CloudKitUserBootcampViewModel()
    
    var body: some View {
        VStack {
            Text("IS SIGNED IN: \(vm.isSignedIntoICloud.description.uppercased())")
            if !vm.error.isEmpty {
                Text("Error: \(vm.error)").foregroundColor(.red)
            }
            Text("Permisson: \(vm.permissionStatus.description.uppercased())")
            Text("User Name: \(vm.userName)")
        }
    }
}

#Preview {
    CloudKitUserBootcamp()
}
