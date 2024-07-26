//
//  Model+Extensions.swift
//  FileChat
//
//  Created by Peter Sugihara on 8/8/23.
//

import Foundation
import CoreData
import OSLog

enum ModelCreateError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .unknownFormat:
				"Model files must be in .gguf format"
			case .accessNotAllowed(let url):
				"File access not allowed to \(url.absoluteString)"
		}
	}
	
	case unknownFormat
	case accessNotAllowed(_ url: URL)
}

extension Model {
	@available(*, deprecated, message: "use nil instead")
	static let unsetModelId = "unset"
	static let defaultModelUrl = URL(string: "https://huggingface.co/bullerwins/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q6_K.gguf")!
	
	var url: URL? {
		if bookmark == nil { return nil }
		var stale = false
		do {
			let res = try URL(resolvingBookmarkData: bookmark!, options: .withSecurityScope, bookmarkDataIsStale: &stale)
			
			guard res.startAccessingSecurityScopedResource() else {
				print("Error starting security scoped access")
				return nil
			}
			
			if stale {
				print("Renewing stale bookmark", res)
				bookmark = try res.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess])
			}
			
			return res
		} catch {
			print("Error resolving \(name ?? "unknown model") bookmark", error.localizedDescription)
			return nil
		}
	}
	
	public static func create(context: NSManagedObjectContext, fileURL: URL) throws -> Model {
		if fileURL.pathExtension != "gguf" {
			throw ModelCreateError.unknownFormat
		}
		
		// gain access to the directory
		let gotAccess = fileURL.startAccessingSecurityScopedResource()
		
		do {
			let model = Model(context: context)
			model.id = UUID()
			model.name = fileURL.lastPathComponent
			model.bookmark = try fileURL.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess])
			if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path()),
			   let fileSize = attributes[.size] as? Int {
				print("The file size is \(fileSize)")
				model.size = Int32(fileSize / 1000000)
			}
			try context.save()
			if gotAccess {
				fileURL.stopAccessingSecurityScopedResource()
			}
			return model
		} catch {
			print("Error creating Model", error.localizedDescription)
			if gotAccess {
				fileURL.stopAccessingSecurityScopedResource()
			}
			throw error
		}
		
	}
	
	public override func willSave() {
		super.willSave()
		if !isDeleted, changedValues()["updatedAt"] == nil {
			self.setValue(Date(), forKey: "updatedAt")
		}
	}
	
}
