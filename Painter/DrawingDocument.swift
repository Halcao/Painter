//
//  DrawingDocument.swift
//  Painter
//
//  Created by Halcao on 2019/12/11.
//  Copyright © 2019 twtstudio. All rights reserved.
//

import UIKit

//class DrawingDocument: UIDocument {
//    static func create(completion: @escaping (Result<DrawingDocument>) -> Void) throws {
//
//        let targetURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Untitled").appendingPathExtension("doc")
//
//        DispatchQueue.main.async {
//            let document = UIDocument(fileURL: targetURL)
//            var error: NSError? = nil
//            NSFileCoordinator(filePresenter: nil).coordinate(writingItemAt: targetURL, error: &error) { url in
//                document.save(to: url, for: .forCreating) { success in
//                    DispatchQueue.main.async {
//                        if success {
//                            completion(.success(document))
//                        } else {
//                            completion(.failure(MyDocumentError.unableToSaveDocument))
//                        }
//                    }
//                }
//            }
//            if let error = error {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//}
