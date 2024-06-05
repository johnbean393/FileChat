//
//  GPU.swift
//  FileChat
//
//  Created by Peter Sugihara on 12/16/23.
//

import Foundation
import AppleGPUInfo

final class GPU: ObservableObject {
	
	/// Shared singleton object
	static let shared = GPU()
	
	/// Returns GPU core count
	static var coreCount: Int {
		do {
			let gpuDevice: GPUInfoDevice = try GPUInfoDevice()
			return gpuDevice.coreCount
		} catch {
			return 10
		}
	}
	
	/// Returns if the GPU is available
	@Published private(set) var available: Bool = false
	
	/// Initializer
	init() {
		// LLaMa crashes on intel macs when gpu-layers != 0, not sure why
		available = getMachineHardwareName() == "arm64"
	}
	
	/// Gets the name of the system
	private func getMachineHardwareName() -> String? {
		var sysInfo = utsname()
		let retVal = uname(&sysInfo)
		var finalString: String? = nil
		
		if retVal == EXIT_SUCCESS {
			let bytes = Data(bytes: &sysInfo.machine, count: Int(_SYS_NAMELEN))
			finalString = String(data: bytes, encoding: .utf8)
		}
		
		// _SYS_NAMELEN will include a billion null-terminators. Clear those out so string comparisons work as you expect.
		return finalString?.trimmingCharacters(in: CharacterSet(charactersIn: "\0"))
	}
	
}
