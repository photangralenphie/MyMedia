//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import SwiftData

struct MyMediaMigrationPlan: SchemaMigrationPlan {

	static var schemas: [any VersionedSchema.Type] {
		[MyMediaSchemaV1.self, MyMediaSchemaV2.self]
	}

	static var stages: [MigrationStage] { [V1toV2Migrator.migrate] }
}
