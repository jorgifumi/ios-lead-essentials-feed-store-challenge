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

	let realm = try! Realm()
	
	public init() {
		
	}
}

extension RealmFeedStore: FeedStore {
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		try! realm.write {
			realm.deleteAll()
			completion(nil)
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let realmFeed = List<RealmFeedImage>()
		realmFeed.append(objectsIn: feed.map(RealmFeedImage.init))
		let cache = Cache(value: [realmFeed, timestamp])
		try! realm.write {
			realm.add(cache)
			completion(nil)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		
		let cache = realm.objects(Cache.self)
		
		if cache.isEmpty {
			completion(.empty)
		} else {
			completion(.found(feed: cache[0].localFeed, timestamp: cache[0].timestamp))
		}
	}
}

class Cache: Object {
	let feed = List<RealmFeedImage>()
	@objc dynamic var timestamp = Date()
	
	var localFeed: [LocalFeedImage] {
		return feed.compactMap { $0.local }
	}
}

class RealmFeedImage: Object {
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
