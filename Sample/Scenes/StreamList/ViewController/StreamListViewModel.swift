//
//  StreamListViewModel.swift
//  YouTubeLiveVideo
//

import Foundation
import YTLiveStreaming
import RxSwift

class StreamListViewModel {

    var dataSource: StreamListDataSource!
    var broadcastsAPI: YTLiveStreaming!

    private let disposeBag = DisposeBag()

    func loadData(_ completion: @escaping (Result<([Stream], [Stream], [Stream]), LVError>) -> Void) {
        dataSource.loadData { (upcomingStreams, currentStreams, pastStreams)  in
            completion(.success((upcomingStreams, currentStreams, pastStreams)))
        }
    }

    func reloadData(_ completion: @escaping (Result<([Stream], [Stream], [Stream]), LVError>) -> Void) {
        dataSource.reloadData { (upcomingStreams, currentStreams, pastStreams)  in
            completion(.success((upcomingStreams, currentStreams, pastStreams)))
        }
    }

    func creadeBroadcast() {
        Alert.sharedInstance.showConfirmCancel("YouTube Live Streaming API",
                                               message: "You realy want to create a new Live broadcast video?",
                                               onConfirm: {
            self.createBroadcast { error in
                if let error = error {
                    Alert.sharedInstance.showOk("Error", message: error.localizedDescription)
                } else {
                    Alert.sharedInstance.showOk("Done",
                                                message: "Please, refresh the table after pair seconds (pull down)")
                }
            }
        })
    }

    private func createBroadcast(title: String = "Live video",
                                 description: String = "Test broadcast video",
                                 _ completion: @escaping (Error?) -> Void) {
        let startDate = Helpers.dateAfter(Date(), after: (hour: 0, minute: 2, second: 0))
        self.broadcastsAPI.createBroadcast(title, description: description, startTime: startDate, completion: { result in
            switch result {
            case .success(let broadcast):
                print("Broadcast \(broadcast.snipped.title) was created successfully")
                completion(nil)
            case .failure(let error):
                switch error {
                case .systemMessage(let code, let message):
                    let err = NSError(domain: message, code: code, userInfo: nil)
                    completion(err)
                default:
                    let err = NSError(domain: error.message(), code: -1, userInfo: nil)
                    completion(err)
                }
            }
        })
    }

    func launchStream(indexPath: IndexPath, viewController: UIViewController) {
        switch indexPath.section {
        case 0:
            assert(false, "Incorrect section number")
        case 1:
            let broadcast = self.dataSource.current(indexPath.row)
            YouTubePlayer.playYoutubeID(broadcast.id, viewController: viewController)
        case 2:
            let broadcast = self.dataSource.past(indexPath.row)
            YouTubePlayer.playYoutubeID(broadcast.id, viewController: viewController)
        default:
            assert(false, "Incorrect section number")
        }
    }
}
