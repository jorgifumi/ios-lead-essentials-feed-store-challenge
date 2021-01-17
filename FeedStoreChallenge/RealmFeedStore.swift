//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Jorge Lucena on 10/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

public final class RealmFeedStore {

	private let configuration: Realm.Configuration

	private var _realm: Realm?

	private let queue = DispatchQueue(label: "\(RealmFeedStore.self)Queue", qos: .userInitiated)
	
	public init(storeURL: URL) {
		configuration = Realm.Configuration(fileURL: storeURL)
	}

	private func getRealm() throws -> Realm {
		try _realm ?? Realm(configuration: configuration, queue: queue)
	}
}

extension RealmFeedStore: FeedStore {
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		queue.async { [weak self] in
			do {
				guard let realm = try self?.getRealm() else {
					return completion(nil)
				}
				try realm.write {
					realm.deleteAll()
					completion(nil)
				}
			} catch let error {
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

		queue.async { [weak self] in
			do {
				guard let realm = try self?.getRealm() else {
					return completion(nil)
				}
				try realm.write {
					realm.deleteAll()
					realm.add(RealmFeedStore.map(feed, timestamp: timestamp))
					completion(nil)
				}
			} catch let error {
				completion(error)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		queue.async { [weak self] in
			do {
				guard let realm = try self?.getRealm() else {
					return completion(.empty)
				}

				if let cache = realm.objects(RealmFeedStoreCache.self).first {
					completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
				} else {
					completion(.empty)
				}
			} catch let error {
				completion(.failure(error))
			}
		}
	}

	private static func map(_ feed: [LocalFeedImage], timestamp: Date) -> RealmFeedStoreCache {
		let realmFeed = List<RealmFeedStoreImage>()
		realmFeed.append(objectsIn: feed.map(RealmFeedStoreImage.init))
		return RealmFeedStoreCache(value: [realmFeed, timestamp])
	}
}

final class RealmFeedStoreCache: Object {
	let feed = List<RealmFeedStoreImage>()
	@objc dynamic var timestamp = Date()
	
	var localFeed: [LocalFeedImage] {
		return feed.compactMap { $0.local }
	}
}

final class RealmFeedStoreImage: Object {
	@objc dynamic var id: String = ""
	@objc dynamic var imageDescription: String? = nil
	@objc dynamic var location: String? = nil
	@objc dynamic var urlString: String = ""
	
	convenience init(_ image: LocalFeedImage) {
		self.init()
		self.id = image.id.uuidString
		self.imageDescription = image.description
		self.location = image.location
		self.urlString = image.url.absoluteString
	}
	
	override class func primaryKey() -> String? {
		"id"
	}
	
	var local: LocalFeedImage? {
		
		guard let id = UUID(uuidString: id),
			  let url = URL(string: urlString) else {
			return nil
		}
		
		return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
}
