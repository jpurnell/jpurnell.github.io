//
//  RSS.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 10/1/24.
//


import Foundation
import Ignite

func RSS(mode: FeedConfiguration.ContentMode = .full, contentCount: Int = 20, path: String = "/feed.rss", image: FeedConfiguration.FeedImage = FeedConfiguration.FeedImage(url: "/images/logos/rss.png", width: 144, height: 152)) -> FeedConfiguration {
	
	return FeedConfiguration(mode: mode, contentCount: contentCount, path: path, image: image)
}
