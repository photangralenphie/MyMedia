//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import Hummingbird
import Observation

@MainActor @Observable
public final class ApiServerManager {
	private let repository: any MediaApiRepository
	private var serverTask: Task<Void, Never>?
	private var generation = UUID()

	public private(set) var status: ApiServerStatus = .stopped
	public private(set) var activePort: Int?

	public init(repository: any MediaApiRepository) {
		self.repository = repository
	}

	public var localURL: URL {
		ApiConfiguration.localURL(port: activePort)
	}

	public func startIfEnabled() async {
		guard ApiConfiguration.isEnabled, ApiConfiguration.startAtLaunch	else { return }
		await start()
	}

	public func restart() async {
		await stop()
		await start()
	}

	public func start() async {
		guard ApiConfiguration.isEnabled, serverTask == nil else { return }

		let port = ApiConfiguration.configuredPort

		if !ApiConfiguration.isValid(port: port) {
			status = .failed("Port must be between 1024 and 65535.")
			return
		}

		status = .starting
		let currentGeneration = UUID()
		generation = currentGeneration

		let router = MediaApiRouter.make(repository: repository)
		let serverConfig = ApplicationConfiguration(address: .hostname("0.0.0.0", port: port), serverName: "MyMedia")
		let application = Application(router: router, configuration: serverConfig) { [weak self] _ in
			await MainActor.run {
				guard let self, self.generation == currentGeneration else { return }
				self.activePort = port
				self.status = .running
			}
		}

		serverTask = Task.detached { [weak self] in
			do {
				try await application.run()
				await self?.serverDidFinish(generation: currentGeneration, error: nil)
			} catch is CancellationError {
				await self?.serverDidFinish(generation: currentGeneration, error: nil)
			} catch {
				await self?.serverDidFinish(generation: currentGeneration, error: error)
			}
		}
	}

	public func stop() async {
		guard let task = serverTask else {
			activePort = nil
			status = .stopped
			return
		}

		status = .stopping
		serverTask = nil
		generation = UUID()

		task.cancel()

		await task.value
		activePort = nil
		status = .stopped
	}

	private func serverDidFinish(generation finishedGeneration: UUID, error: Error?) {
		guard generation == finishedGeneration else { return }

		serverTask = nil
		activePort = nil

		if let error {
			status = .failed(error.localizedDescription)
		} else {
			status = .stopped
		}
	}
}
