//
//  CoreDataPopulated.swift
//  ios_agc_reference
//
//  Created by Stijn Willems on 27/05/16.
//  Copyright © 2016 iCapps. All rights reserved.
//

import Foundation
import CoreData

/**
Reuses a sqlite model with `modelName` that can be found in your application bundle (Add it to your xcode project).

Use the `CoreDataPopulator` to create the _sqlite_ file with `modelName`.

*/

enum CoreDataFromPopulatedSQLiteError: Error {
	case missingSQLiteFile(fileName: String)
}

open class CoreDataFromPopulatedSQLite: NSObject {

	var storeType = NSSQLiteStoreType
	let modelName: String
	let options = [NSMigratePersistentStoresAutomaticallyOption: true,
	               NSInferMappingModelAutomaticallyOption: true]

	/**
	Initialazes a convinience class for dealing with CoreData.
	- parameter modelName: name of youe model. 
	*/
	public init(modelName: String) {
		self.modelName = modelName
		super.init()
	}

	open lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()


	fileprivate lazy var applicationDocumentsDirectory: URL = {

		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls.last!
	}()

	fileprivate lazy var managedObjectModel: NSManagedObjectModel = { [unowned self] in
		let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
		}()

	/**
	- returns: persistentStoreCoordinator with pre filled sqlite.
	*/
	fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = { [unowned self] in
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

		var failureReason = "There was an error creating or loading the application's saved data."

		do {

			let sqliteURL = try self.usePrefilledSQLLiteFromApplicationBundle()
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteURL, options: self.options)

		} catch {

			var dict = [String: Any]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as Any
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as Any

			dict[NSUnderlyingErrorKey] = error as Error
			print("Unresolved error")
			abort()

		}

		return coordinator
		}()

	fileprivate func usePrefilledSQLLiteFromApplicationBundle() throws -> URL  {
		let sqliteURL = self.applicationDocumentsDirectory.appendingPathComponent("\(modelName).sqlite")

		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: sqliteURL.path){
			print("🗼 moving sqlite database into place for reuse.")
			guard let bundleUrl = Bundle.main.url(forResource: modelName, withExtension: ".sqlite") else {
				print("💣 we could not find \(modelName).sqlite in your application bundle. Make sure it is added to the target and in your project.")
				throw CoreDataFromPopulatedSQLiteError.missingSQLiteFile(fileName: "\(modelName).sqlite")
			}

			do {
				try fileManager.copyItem(at: bundleUrl, to: sqliteURL)

			}catch {
				print("💣 failed to preload database. Using database without data.")
				print("💣 error \(error)")
			}
		}else {
			print("🚀We are reusing previous sqlite data")
		}
		return sqliteURL
	}

	// MARK: - Core Data Saving support

	open func saveContext () {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				print("Unresolved error \(error)")
				abort()
			}
		}
	}
}