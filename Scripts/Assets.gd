extends Node

enum AssetState {
	Loading,
	NotReady,
	Ready
}
	
class Asset:
	var state: AssetState
	var path: String 
	var resource: Resource
	
	static func create(path: String) -> Asset:
		var asset = Asset.new()
		asset.path = path
		asset.resource = null
		asset.state = AssetState.NotReady
		
		return asset
		
	func load() -> void:
		if self.state in [AssetState.Loading, AssetState.Ready]:
			printerr('Resource \'', self.path, '\' is already loaded or loading!')
			return
		
		ResourceLoader.load_threaded_request(self.path)
		self.state = AssetState.Loading
		
	func checkState() -> void:
		var loadStatus = ResourceLoader.load_threaded_get_status(self.path)
		
		if loadStatus == ResourceLoader.THREAD_LOAD_LOADED:
			self.resource = ResourceLoader.load_threaded_get(self.path)
			self.state = AssetState.Ready
			
	func getAsset() -> Resource:
		if self.state == AssetState.NotReady:
			printerr('Asset is not ready!!!')
			return null
		elif self.state == AssetState.Loading:
			self.resource = ResourceLoader.load_threaded_get(self.path)
			self.state = AssetState.Ready
			
		return self.resource

var assets: Dictionary = {
	'KiwiRobotModel': Asset.create('res://Scenes/Entities/Robots/Kiwi.tscn'),
	'MechRobotModel': Asset.create('res://Scenes/Entities/Robots/Mech.tscn')
}

func _ready() -> void:
	for assetId in assets.keys():
		assets[assetId].load()


func _process(delta: float) -> void:
	pass


func GetAsset(assetId: String) -> Resource:
	return assets[assetId].getAsset()
