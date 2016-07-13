source 'https://github.com/cocoaPods/Specs.git'
source 'https://github.com/skylib/SnapPods.git'

platform :ios, '8.0'
use_frameworks!

target 'SnapImagePicker' do
    pod 'SnapFonts-iOS'
    
    target 'Example_Project' do
        inherit! :search_paths
        pod 'SnapFonts-iOS'
    end
    
    target 'SnapImagePicker_Snapshot_Tests' do
        inherit! :search_paths
        pod 'SnapFBSnapshotBase'
    end
    
    target 'SnapImagePicker_Unit_Tests' do
        inherit! :search_paths
    end
    
    target 'Example_Project_UI_Tests' do
        inherit! :search_paths
    end
end

