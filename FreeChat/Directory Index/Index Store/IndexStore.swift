//
//  IndexStore.swift
//  FileChat
//
//  Created by Bean John on 30/5/2024.
//

import Foundation
import ExtensionKit

class IndexStore: ValueDataModel<IndexedDirectory> {
	
	required init(appDirName: String = Bundle.main.applicationName ?? Bundle.main.description, datastoreName: String = "\(Bundle.main.applicationName ?? Bundle.main.description)") {
		super.init(appDirName: appDirName, datastoreName: datastoreName)
	}
	
}
