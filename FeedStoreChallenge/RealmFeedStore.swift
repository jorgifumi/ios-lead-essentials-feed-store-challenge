//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Jorge Lucena on 10/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RealmFeedStore {
	
	public init() {
		
	}
}

extension RealmFeedStore: FeedStore {
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
}
