//
//  ViewController.swift
//  testRxSwift
//
//  Created by yuki.osu on 2021/02/17.
//

import UIKit
import RxSwift
import RxCocoa

enum MyError: Error {
    case error1
}

class ViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var button: UIButton!
    
    let disposeBag = DisposeBag()
    var count: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        button.rx.tap
            .debug()
            .flatMap { [weak self] _ -> Single<String> in
                guard let self = self else {
                    throw MyError.error1
                }

                self.count += 1

                return self.apiCall(param: "call api \(self.count)", interval: 0, isError: self.count == 2)
                    .do(onError: { [weak self] _ in
                        DispatchQueue.main.async { [weak self] in
                            self?.label1.text = "error!!"
                        }
                    })
                    .catchErrorJustReturn("error")
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive(label1.rx.text)
            .disposed(by: disposeBag)
    }

    func apiCall(param: String, interval: Int, isError: Bool) -> Single<String> {
        return Single.create { (observer) -> Disposable in
            DispatchQueue.init(label: "background").async {
                sleep(UInt32(interval))

                if isError {
                    observer(.error(MyError.error1))
                } else {
                    observer(.success(param))
                }
            }

            return Disposables.create()
        }
    }

}
