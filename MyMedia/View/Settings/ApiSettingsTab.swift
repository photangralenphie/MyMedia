//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import AwesomeSwiftyComponents
import MyMediaAPI
import SwiftUI

struct ApiSettingsTab: View {
	@Environment(ApiServerManager.self) private var apiServer

	@AppStorage(ApiConfiguration.PreferenceKeys.enabled) private var apiEnabled = false
	@AppStorage(ApiConfiguration.PreferenceKeys.startAtLaunch) private var startAtLaunch = false
	@AppStorage(ApiConfiguration.PreferenceKeys.port) private var port = ApiConfiguration.Defaults.port
	@AppStorage(ApiConfiguration.PreferenceKeys.previewArtworkSize) private var previewArtworkSize = ApiConfiguration.Defaults.previewArtworkSize
	@AppStorage(ApiConfiguration.PreferenceKeys.itemsPerPage) private var itemsPerPage = ApiConfiguration.Defaults.itemsPerPage

	private var portIsValid: Bool {
		ApiConfiguration.isValid(port: port)
	}

	private var statusText: String {
		switch apiServer.status {
			case .stopped: String(localized: "Stopped")
			case .starting: String(localized: "Starting")
			case .running: String(localized: "Running")
			case .stopping: String(localized: "Stopping")
			case .failed(let message): String(localized: "Failed: \(message)")
		}
	}

	var body: some View {
		Form {
			Section("Availability") {
				Toggle(isOn: $apiEnabled) {
					Text("Enable API")
					Text("Disabling the API stops the server and hides its configuration.")
				}
			}

			if apiEnabled {
				Section("Server") {
					Toggle("Start API when MyMedia launches", isOn: $startAtLaunch)

					LabeledContent("Status", value: statusText)

					LabeledContent("IP-Address", value: apiServer.localURL.absoluteString)

					TextField("Port", value: $port, format: .number)
						.multilineTextAlignment(.trailing)
						.formRowDescription(String(localized: "Use a port from 1024 through 65535. Restart the API after changing it."))

					if !portIsValid {
						Label("Port must be between 1024 and 65535.", systemImage: "exclamationmark.triangle.fill")
							.foregroundStyle(.red)
					}

					HStack {
						switch apiServer.status {
							case .running:
								Button("Restart API", systemImage: "arrow.clockwise", action: restartApi)
									.disabled(!portIsValid)

							case .starting:
								Button("Starting", systemImage: "hourglass") { }
									.disabled(true)

							case .stopping:
								Button("Stopping", systemImage: "hourglass") { }
									.disabled(true)

							case .stopped, .failed:
								Button("Start API", systemImage: "play.fill", action: startApi)
									.disabled(!portIsValid)
						}

						Button("Stop API", systemImage: "stop.fill", role: .destructive, action: stopApi)
							.disabled(apiServer.status == .stopped || apiServer.status == .stopping)
					}
				}

				Section("Responses - Defaults") {
					Stepper("Preview artwork maximum dimension: \(previewArtworkSize) px", value: $previewArtworkSize, in: 25...1_200, step: 25)

					Stepper("Items per page: \(itemsPerPage)", value: $itemsPerPage, in: 5...200, step: 5)
				}
			}
		}
		.frame(height: apiEnabled ? 420 : 130)
		.onChange(of: apiEnabled) { _, enabled in
			if !enabled {
				stopApi()
			}
		}
	}

	private func startApi() {
		Task { await apiServer.start() }
	}

	private func stopApi() {
		Task { await apiServer.stop() }
	}

	private func restartApi() {
		Task { await apiServer.restart() }
	}
}
